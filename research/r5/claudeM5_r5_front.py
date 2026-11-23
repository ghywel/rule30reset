#!/usr/bin/env python3
"""claudeM5_r5_front.py: pull R5, second block (ledger M133). Traps for the 001 drive as moving fronts.

Frame (kit Rule30EtherThree, Rule30EtherThreeTrap). Column 0 is driven by 0, 0, 1 repeated. A right half is a row
x_1, x_2, ... and evolves by new x_j = x_(j-1) xor (x_j or x_(j+1)). A trap has labels mod m (m a multiple of 3, the
label's phase mod 3 being the drive's). Its first K columns are functions of the label: the PATTERN P[l][j], j = 1..K.

THE FRONT. Fix a label l for the present tick. D is the least j in 1..K with x_j != P[l][j], and D = K + 1 (written
INF) when the row reads the pattern on columns 1..K. One tick later the label is l + 1 and the front is D'. The set
of D' that some choice of the cells beyond D allows is computed exactly (step_fronts). Taking the cells beyond D as
free again at every tick gives the FRONT GRAPH, which contains every real history. With `look` cells beyond D kept in
the node it contains fewer paths and is still an over-approximation.

  python3 claudeM5_r5_front.py selftest            the two kit tables are closed and read as the kit says; the empty half
                                                   enters t001 at tick 1270 in state 597; one tick of the front graph is
                                                   checked against whole rows
  python3 claudeM5_r5_front.py traps               patterns, K, and the columns' black counts
  python3 claudeM5_r5_front.py barrier TRAP LOOK   from which columns the front can reach INF in the front graph, and the
                                                   deepest column a front that starts at column 1 can reach
  python3 claudeM5_r5_front.py ether LOOK          the ether's own front: least and greatest mean speed over all cycles
  python3 claudeM5_r5_front.py ethercut            how far the 001 ether agrees with each trap's pattern
"""
import itertools, json, pathlib, re, sys

sys.set_int_max_str_digits(0)

ROOT = pathlib.Path(__file__).resolve().parents[2]
KIT = ROOT / 'Rule30PrizeKit/lean/Ruliology/CellularAutomata'
ETHER = [[0, 0, 1], [0, 0, 1], [0, 1, 1], [1, 1, 0], [0, 1, 0], [0, 1, 0],
         [1, 1, 0], [1, 0, 1], [1, 0, 0], [1, 0, 0], [1, 0, 1], [0, 1, 1]]
A001 = [(0, 0), (1, 0), (4, 2), (5, 2), (8, 1), (9, 1)]
DRIVE = [0, 0, 1]


def lean_nat(text, name):
    m = re.search(r'def %s : Nat := (\d+)' % name, text)
    return int(m.group(1))


def load(name):
    """The kit's packed PTrap tables: states, labels, successors."""
    f, pre = {'t001': ('Rule30EtherThreeTrap.lean', 't001'),
              'fifteen': ('Rule30EtherThreeNotAbsorption.lean', 'trap001fifteen')}[name]
    text = (KIT / f).read_text()
    body = re.search(r'def %s : PTrap :=\s*\{(.*?)\}' % pre, text, re.S).group(1)
    val = lambda k: (lambda v: int(v) if v.isdigit() else lean_nat(text, v))(re.search(r'\b%s := (\w+)' % k, body).group(1))
    b, m, n, lb, ib, u, R, L, S = map(val, ('b', 'm', 'n', 'lb', 'ib', 'u', 'R', 'L', 'S'))
    st = [(R >> (b * i)) % 2 ** b for i in range(n)]
    lab = [(L >> (lb * i)) % 2 ** lb for i in range(n)]
    nxt = [[(S >> (ib * (2 * i + z))) % 2 ** ib for z in (0, 1)] for i in range(n)]
    return dict(name=name, b=b, m=m, n=n, u=u, st=st, lab=lab, nxt=nxt)


def strip_step(b, c, z, r):
    """Cells 1..b are the bits 0..b-1 of r; column 0 is c, column b + 1 is z."""
    full = (r << 1) | c | (z << (b + 1))
    new = (full << 1) ^ (full | (full >> 1))        # bit p of new is the new cell p, for p >= 1
    return (new >> 1) & ((1 << b) - 1)


def pattern(T):
    """P[l][j] for j = 0..K, with P[l][0] the drive; K is the greatest depth on which every label has one reading."""
    m, b = T['m'], T['b']
    by = {}
    for s, l in zip(T['st'], T['lab']):
        by.setdefault(l, []).append(s)
    K = 0
    while K < b and all(len({(s >> K) & 1 for s in v}) == 1 for v in by.values()) and len(by) == m:
        K += 1
    P = [[DRIVE[l % 3]] + [(by[l][0] >> j) & 1 for j in range(K)] for l in range(m)]
    return P, K


def ether_pattern(width):
    """The aligned ether as a pattern with m = 3, for the alignment (0, 0): column j at label l is ETHER[j][l]."""
    return [[ETHER[j % 12][l] for j in range(width + 1)] for l in range(3)], width


def step_fronts(P, K, l, D, cells):
    """P a pattern, the row reads P[l] on 1..D-1, differs at D, and reads `cells` on D+1..D+len(cells); every cell beyond
    is free. Returns {(D', cells'): True} for the next tick, with len(cells') = len(cells), cells' taken over every
    choice of the free cells. D' = K + 1 stands for agreement on 1..K (no cells kept)."""
    m, look = len(P), len(cells)
    X, Y = P[l], P[(l + 1) % m]
    out = set()
    # the old row from column D - 1 on: known, then free. A depth-first walk over the free cells, only as far as needed.
    base = {}
    for j in range(D):
        base[j] = X[j]
    base[D] = 1 - X[D]
    for i, c in enumerate(cells):
        base[D + 1 + i] = c

    def walk(row, j, front, kept):
        """New cell j next; `row` old cells known so far; front = D' if found; kept = cells read after it."""
        if front is None and j > K:
            out.add((K + 1, ()))
            return
        if front is not None and len(kept) == look:
            out.add((front, tuple(kept)))
            return
        need = [p for p in (j - 1, j, j + 1) if p not in row]
        for bits in itertools.product((0, 1), repeat=len(need)):
            r = row if not need else dict(row)
            for p, v in zip(need, bits):
                r[p] = v
            v = r[j - 1] ^ (r[j] | r[j + 1])
            if front is None:
                if v != Y[j]:
                    walk(r, j + 1, j, [])
                else:
                    walk(r, j + 1, None, None)
            else:
                walk(r, j + 1, front, kept + [v])
    # columns up to D - 2 agree; start at D - 1 (or 1)
    walk(base, max(1, D - 1), None, None)
    return out


def front_graph(P, K, look):
    """All nodes (l, D, cells) with edges; nodes with D = K + 1 are absorbing here (INF)."""
    m = len(P)
    nodes = [(l, D, c) for l in range(m) for D in range(1, K + 1) for c in itertools.product((0, 1), repeat=look)]
    edges = {}
    for l, D, c in nodes:
        edges[(l, D, c)] = [((l + 1) % m, d2, c2) for d2, c2 in step_fronts(P, K, l, D, c)]
    return nodes, edges


def can_reach_inf(P, K, look):
    nodes, edges = front_graph(P, K, look)
    rev = {}
    for a, bs in edges.items():
        for b in bs:
            rev.setdefault(b, []).append(a)
    seen, todo = set(), [b for b in rev if b[1] == K + 1]
    while todo:
        b = todo.pop()
        for a in rev.get(b, []):
            if a not in seen:
                seen.add(a)
                todo.append(a)
    return nodes, edges, seen


def forward(edges, start):
    seen, todo = set(start), list(start)
    while todo:
        a = todo.pop()
        for b in edges.get(a, []):
            if b not in seen:
                seen.add(b)
                todo.append(b)
    return seen


def cmd_barrier(name, look):
    T = load(name)
    P, K = pattern(T)
    nodes, edges, reach = can_reach_inf(P, K, look)
    ds = sorted({D for _, D, _ in reach})
    first = [a for a in nodes if a[1] == 1]
    fw = forward(edges, first)
    deep = max(a[1] for a in fw)
    res = dict(trap=name, K=K, m=T['m'], look=look, nodes=len(nodes), edges=sum(map(len, edges.values())),
               columns_that_can_reach_INF=ds, nodes_that_can_reach_INF=len(reach),
               deepest_front_from_column_1=deep,
               INF_from_column_1=any(a in reach for a in first))
    print(json.dumps(res))


def cmd_ether(look):
    """Mean speed of the ether's front, over every cycle of the graph on (class, cells): Karp's least and greatest mean.
    The front graph is taken on the two-sided ether: node (class c = column D's ether column at label 0, label), the
    front far from column 0."""
    W = 12 * 6
    P, K = ether_pattern(W)
    mid = 12 * 3
    nodes, edges = set(), {}
    start = [(l, D, c) for l in range(3) for D in range(mid, mid + 12) for c in itertools.product((0, 1), repeat=look)]
    far = 0
    for l, D, c in start:
        key = (l, D % 12, c)
        for d2, c2 in step_fronts(P, K, l, D, c):
            if d2 == K + 1:
                far += 1
                continue
            edges.setdefault(key, set()).add((((l + 1) % 3, d2 % 12, c2), d2 - D))
        nodes.add(key)
    # moves of D in one tick, over all nodes
    moves = {}
    for k, v in edges.items():
        for _, dd in v:
            moves[dd] = moves.get(dd, 0) + 1
    # strongly connected components (iterative Tarjan), then Karp on each
    idx, low, on, stack, comps, counter = {}, {}, set(), [], [], [0]
    for root in nodes:
        if root in idx:
            continue
        work = [(root, iter(sorted(b for b, _ in edges.get(root, []))))]
        idx[root] = low[root] = counter[0]; counter[0] += 1; stack.append(root); on.add(root)
        while work:
            v, it = work[-1]
            adv = False
            for w in it:
                if w not in idx:
                    idx[w] = low[w] = counter[0]; counter[0] += 1; stack.append(w); on.add(w)
                    work.append((w, iter(sorted(b for b, _ in edges.get(w, [])))))
                    adv = True
                    break
                elif w in on:
                    low[v] = min(low[v], idx[w])
            if adv:
                continue
            work.pop()
            if work:
                low[work[-1][0]] = min(low[work[-1][0]], low[v])
            if low[v] == idx[v]:
                comp = []
                while True:
                    w = stack.pop(); on.discard(w); comp.append(w)
                    if w == v:
                        break
                comps.append(comp)
    from fractions import Fraction
    res = []
    for comp in comps:
        cs = set(comp)
        e = [(a, b, dd) for a in comp for b, dd in edges.get(a, []) if b in cs]
        if not e:
            continue
        for sign in (1, -1):
            n = len(comp)
            INFV = float('inf')
            dist = [{a: INFV for a in comp} for _ in range(n + 1)]
            dist[0][comp[0]] = 0
            for k in range(1, n + 1):
                dk, dp = dist[k], dist[k - 1]
                for a, b, dd in e:
                    if dp[a] < INFV and dp[a] + sign * dd < dk[b]:
                        dk[b] = dp[a] + sign * dd
            best = None
            for a in comp:
                if dist[n][a] < INFV:
                    worst = max(Fraction(dist[n][a] - dist[k][a], n - k) for k in range(n) if dist[k][a] < INFV)
                    best = worst if best is None or worst < best else best
            res.append((len(comp), 'least' if sign == 1 else 'greatest', str(sign * best)))
    print(json.dumps(dict(look=look, nodes=len(nodes), edges=sum(len(v) for v in edges.values()),
                          one_tick_moves={str(k): v for k, v in sorted(moves.items())}, jumps_beyond_window=far,
                          components=res)))


def cmd_ethercut():
    for name in ('t001', 'fifteen'):
        T = load(name)
        P, K = pattern(T)
        rows = []
        for j0, s in A001:
            for t in range(3):
                for l in range(T['m']):
                    if l % 3 != t % 3:
                        continue
                    D = next((j for j in range(1, K + 1) if ETHER[(j0 + j) % 12][(t + s) % 3] != P[l][j]), K + 1)
                    rows.append(D)
        print(json.dumps(dict(trap=name, K=K, deepest_agreement_with_the_ether=max(rows) - 1,
                              distribution={str(d): rows.count(d) for d in sorted(set(rows))})))


def cmd_traps():
    for name in ('t001', 'fifteen'):
        T = load(name)
        P, K = pattern(T)
        print(name, 'b', T['b'], 'm', T['m'], 'n', T['n'], 'K', K)
        for j in range(K + 1):
            print('%3d' % j, ''.join('.#'[P[l][j]] for l in range(T['m'])))


def cmd_selftest():
    ok = True
    for name in ('t001', 'fifteen'):
        T = load(name)
        idx = {(s, l): i for i, (s, l) in enumerate(zip(T['st'], T['lab']))}
        good = len(idx) == T['n']
        for i in range(T['n']):
            for z in (0, 1):
                j = T['nxt'][i][z]
                good &= j < T['n'] and T['st'][j] == strip_step(T['b'], DRIVE[T['lab'][i] % 3], z, T['st'][i])
                good &= T['lab'][j] == (T['lab'][i] + 1) % T['m']
            good &= DRIVE[T['lab'][i] % 3] == 1 or ((T['u'] >> T['lab'][i]) & 1) == (T['st'][i] & 1)
        P, K = pattern(T)
        pat = all(P[(l + 1) % T['m']][j] == P[l][j - 1] ^ (P[l][j] | P[l][j + 1]) for l in range(T['m']) for j in range(1, K))
        print(name, 'closed and labelled:', good, '| K =', K, '| the pattern is a rule-30 orbit:', pat)
        ok &= good and pat
    T = load('t001')
    row, t = 0, 0
    where = {(s, l % 3): i for i, (s, l) in enumerate(zip(T['st'], T['lab']))}
    first = None
    while first is None and t < 3000:
        if (row & (2 ** 47 - 1), t % 3) in where:
            first = (t, where[(row & (2 ** 47 - 1), t % 3)])
            break
        row = strip_step(t + 60, DRIVE[t % 3], 0, row)
        t += 1
    print('the empty half enters t001 at', first, '(the kit: 1270, 597)')
    ok &= first == (1270, 597)
    # one tick of the front graph against whole rows
    import random
    rng = random.Random(1)
    P, K = pattern(T)
    bad = 0
    for _ in range(20000):
        l, D, look = rng.randrange(21), rng.randrange(1, K + 1), 3
        row = [P[l][j] for j in range(D)] + [1 - P[l][D]] + [rng.randrange(2) for _ in range(K + 12)]
        new = [0] + [row[j - 1] ^ (row[j] | row[j + 1]) for j in range(1, len(row) - 1)]
        Y = P[(l + 1) % 21]
        d2 = next((j for j in range(1, K + 1) if new[j] != Y[j]), K + 1)
        c2 = () if d2 == K + 1 else tuple(new[d2 + 1:d2 + 1 + look])
        if (d2, c2) not in step_fronts(P, K, l, D, tuple(row[D + 1:D + 1 + look])):
            bad += 1
    print('20,000 random rows: the next front is among those listed, misses =', bad)
    ok &= bad == 0
    print('SELFTEST', 'PASS' if ok else 'FAIL')


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['selftest']:
        cmd_selftest()
    elif a[:1] == ['traps']:
        cmd_traps()
    elif a[:1] == ['barrier']:
        cmd_barrier(a[1], int(a[2]))
    elif a[:1] == ['ether']:
        cmd_ether(int(a[1]))
    elif a[:1] == ['ethercut']:
        cmd_ethercut()
    else:
        sys.exit(__doc__)
