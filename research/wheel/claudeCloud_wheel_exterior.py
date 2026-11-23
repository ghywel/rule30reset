#!/usr/bin/env python3
"""claudeCloud_wheel_exterior.py: a replay of gptIntel's exterior results (I162, I164, I166) and kick sensors (I168,
I169) with code that shares nothing with theirs, and the two mixed exterior gates followed to wider windows
(ledger K77).

Frame as in claudeCloud_wheel_runs.py: a window is columns 1..W at a sample (a tick at which column 0 is white),
bit i = column i + 1; a kick is a black column 1 at a sample; the exterior is every window whose first sixteen
columns are not in the kit's trap; two free bits enter at the right edge in each double step.

  lift WMAX          the kick windows that lie on a two-sided endless path of 3-gaps and 5-gaps outside the trap, at
                     W = 16, 17, ..., WMAX, each width from the last (a window on such a path projects to one a
                     column narrower); the strongly connected components and the gap word each one repeats
  words W0 WMAX      from width W0 on, the same for one prescribed repeating gap word at a time (3, 33355, 333355):
                     the kick windows on a two-sided endless path that spells the word, followed to WMAX or to the
                     width at which none is left
  strips             columns 1..W that all repeat with the gate's own period, by SAT, with a free input at the
                     right: 33355 in 38 ticks at 54 and 55 columns, 333355 in 44 ticks at 37 and 38, the doubled
                     periods, and 3 in 6 ticks at 84 as a control; every model is replayed tick by tick
  attain FILE ...    which of K75's forcing words can be read at all (no condition on the last window)
  sensors FILE       gptIntel's 18 sensor rules (research/wheel/data/kick-sensors.json) on real rows by SAT: after
                     140 matched ticks of the wheel, the stated cells at the issue tick decide whether the first
                     departure comes exactly `lead` ticks later; and the six-tick relay of I168

    python3 claudeCloud_wheel_exterior.py KITFILE MODE ...
SAT answers: a model is replayed here, so SAT is rigorous; UNSAT is COMPUTED only (python-sat's CaDiCaL 1.9.5).
"""
import json
import math
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_runs as R       # noqa: E402

U = '00010011010001001101000100110100010011010001001101001101'


# ---------------------------------------------------------------- edges between kick windows outside the trap

def gap_edges(nodes, W, inside):
    """nodes: sorted int64 array of black windows of width W. Returns {3: (src, dst), 5: (src, dst)} as index arrays
    into nodes: dst is reached from src after exactly 3 or 5 samples, white in between, every window outside the
    trap, for some choice of the free bits; only targets that are themselves in nodes are kept."""
    empty = np.zeros(0, dtype=np.int64)
    if len(nodes) == 0:
        return {3: (empty, empty), 5: (empty, empty)}
    if W > 61:
        return gap_edges_py(nodes, W, inside)
    out = {}
    src = np.arange(len(nodes), dtype=np.int64)
    cur = nodes.copy()
    for step in range(1, 6):
        s2, c2 = [], []
        for x1 in (0, 1):
            for x2 in (0, 1):
                v = L.step2(cur, x1, x2, W)
                keep = ~inside[v & 0xFFFF]
                s2.append(src[keep])
                c2.append(v[keep])
        s2 = np.concatenate(s2)
        c2 = np.concatenate(c2)
        if len(s2):
            order = np.lexsort((c2, s2))
            s2, c2 = s2[order], c2[order]
            first = np.ones(len(s2), bool)
            first[1:] = (s2[1:] != s2[:-1]) | (c2[1:] != c2[:-1])
            s2, c2 = s2[first], c2[first]
        black = (c2 & 1) == 1
        if step in (3, 5):
            sb, cb = s2[black], c2[black]
            pos = np.searchsorted(nodes, cb)
            pos[pos >= len(nodes)] = 0
            ok = nodes[pos] == cb if len(nodes) else np.zeros(0, bool)
            out[step] = (sb[ok], pos[ok])
        src, cur = s2[~black], c2[~black]
    return out


def gap_edges_py(nodes, W, inside):
    """The same in Python integers, for windows wider than 61 columns. nodes: a sorted list of Python ints."""
    index = {w: i for i, w in enumerate(nodes)}
    mask = (1 << W) - 1
    out = {3: ([], []), 5: ([], [])}

    def step2(w, x1, x2):
        r = (w << 1) | (x1 << (W + 1))
        w = (r ^ ((r >> 1) | (r >> 2))) & mask
        r = (w << 1) | 1 | (x2 << (W + 1))
        return (r ^ ((r >> 1) | (r >> 2))) & mask

    for i, w0 in enumerate(nodes):
        cur = {w0}
        for step in range(1, 6):
            nxt = set()
            for w in cur:
                for x1 in (0, 1):
                    for x2 in (0, 1):
                        v = step2(w, x1, x2)
                        if not inside[v & 0xFFFF]:
                            nxt.add(v)
            black = {v for v in nxt if v & 1}
            if step in (3, 5):
                for v in black:
                    j = index.get(v)
                    if j is not None:
                        out[step][0].append(i)
                        out[step][1].append(j)
            cur = nxt - black
            if not cur:
                break
    return {g: (np.array(s, dtype=np.int64), np.array(d, dtype=np.int64)) for g, (s, d) in out.items()}


def prune(n, edges):
    """Largest set of nodes each with an edge in and an edge out inside the set. edges: list of (src, dst)."""
    alive = np.ones(n, bool)
    while True:
        has_out = np.zeros(n, bool)
        has_in = np.zeros(n, bool)
        for s, d in edges:
            ok = alive[s] & alive[d]
            has_out[s[ok]] = True
            has_in[d[ok]] = True
        new = alive & has_out & has_in
        if np.array_equal(new, alive):
            return alive
        alive = new


def components(n, src, dst):
    """Strongly connected components (iterative Tarjan). Returns comp[node] and the number of components."""
    order = np.argsort(src, kind='stable')
    src_s, dst_s = src[order], dst[order]
    start = np.searchsorted(src_s, np.arange(n + 1))
    index = [-1] * n
    low = [0] * n
    onstack = [False] * n
    comp = [-1] * n
    stack = []
    counter = 0
    ncomp = 0
    dst_l = dst_s.tolist()
    start_l = start.tolist()
    for root in range(n):
        if index[root] != -1:
            continue
        work = [(root, start_l[root])]
        index[root] = low[root] = counter
        counter += 1
        stack.append(root)
        onstack[root] = True
        while work:
            v, ptr = work[-1]
            if ptr < start_l[v + 1]:
                work[-1] = (v, ptr + 1)
                w = dst_l[ptr]
                if index[w] == -1:
                    index[w] = low[w] = counter
                    counter += 1
                    stack.append(w)
                    onstack[w] = True
                    work.append((w, start_l[w]))
                elif onstack[w]:
                    if index[w] < low[v]:
                        low[v] = index[w]
            else:
                work.pop()
                if work:
                    u = work[-1][0]
                    if low[v] < low[u]:
                        low[u] = low[v]
                if low[v] == index[v]:
                    while True:
                        w = stack.pop()
                        onstack[w] = False
                        comp[w] = ncomp
                        if w == v:
                            break
                    ncomp += 1
    return np.array(comp), ncomp


def necklace(word):
    return min(word[i:] + word[:i] for i in range(len(word)))


def component_words(n, e3, e5):
    """For each cyclic component: the gap word it repeats (as a necklace), or 'variable'."""
    src = np.concatenate([e3[0], e5[0]])
    dst = np.concatenate([e3[1], e5[1]])
    lab = np.concatenate([np.full(len(e3[0]), 3), np.full(len(e5[0]), 5)])
    comp, ncomp = components(n, src, dst)
    inner = comp[src] == comp[dst]
    res = []
    for c in np.unique(comp[src[inner]]):
        m = inner & (comp[src] == c)
        s, d, l = src[m], dst[m], lab[m]
        nodes = np.unique(np.concatenate([s, d]))
        # levels by breadth-first search inside the component
        adj = {}
        for a, b in zip(s.tolist(), d.tolist()):
            adj.setdefault(a, []).append(b)
        root = int(nodes[0])
        level = {root: 0}
        queue = [root]
        for v in queue:
            for w in adj.get(v, ()):
                if w not in level:
                    level[w] = level[v] + 1
                    queue.append(w)
        g = 0
        for a, b in zip(s.tolist(), d.tolist()):
            g = math.gcd(g, level[a] + 1 - level[b])
        g = abs(g)
        word = [None] * g
        fixed = g > 0
        if fixed:
            for a, x in zip(s.tolist(), l.tolist()):
                r = level[a] % g
                if word[r] is None:
                    word[r] = x
                elif word[r] != x:
                    fixed = False
                    break
        if fixed:
            w = ''.join(map(str, word))
            # reduce to the primitive word
            for k in range(1, len(w) + 1):
                if len(w) % k == 0 and w[:k] * (len(w) // k) == w:
                    w = w[:k]
                    break
            res.append((necklace(w), int(len(nodes))))
        else:
            res.append(('variable', int(len(nodes))))
    return res


def trap_table(trap):
    inside = np.zeros(1 << 16, bool)
    inside[np.array(trap)] = True
    return inside


def lift(trap, wmax):
    inside = trap_table(trap)
    nodes = None
    for W in range(16, wmax + 1):
        t0 = time.time()
        if W == 16:
            allw = np.arange(1 << 16, dtype=np.int64)
            cand = allw[(~inside[allw]) & ((allw & 1) == 1)]
        else:
            cand = np.sort(np.concatenate([nodes, nodes | (np.int64(1) << (W - 1))]))
        e = gap_edges(cand, W, inside)
        alive = prune(len(cand), [e[3], e[5]])
        idx = np.cumsum(alive) - 1
        nodes = cand[alive]
        e3 = (idx[e[3][0][alive[e[3][0]] & alive[e[3][1]]]], idx[e[3][1][alive[e[3][0]] & alive[e[3][1]]]])
        e5 = (idx[e[5][0][alive[e[5][0]] & alive[e[5][1]]]], idx[e[5][1][alive[e[5][0]] & alive[e[5][1]]]])
        words = component_words(len(nodes), e3, e5)
        summary = {}
        for w, k in words:
            summary.setdefault(w, [0, 0])
            summary[w][0] += 1
            summary[w][1] += k
        print(json.dumps(dict(W=W, kick_windows_on_endless_paths=int(len(nodes)), edges_3=int(len(e3[0])),
                              edges_5=int(len(e5[0])),
                              components={w: dict(count=v[0], windows=v[1]) for w, v in sorted(summary.items())},
                              seconds=round(time.time() - t0, 1))))
        sys.stdout.flush()
    return nodes


def word_sets(trap, w0, wmax, words):
    """For each repeating gap word: states (kick window, position in the word) on a two-sided endless path spelling
    the word, at each width from w0 (from scratch there, over the lift's surviving windows) to wmax."""
    inside = trap_table(trap)
    base = lift_quiet(trap, w0, inside)
    for word in words:
        k = len(word)
        nodes = base
        for W in range(w0, wmax + 1):
            t0 = time.time()
            if W > w0:
                if W <= 61:
                    nodes = np.sort(np.unique(np.concatenate([nodes, nodes | (np.int64(1) << (W - 1))])))
                else:
                    plain = [int(v) for v in nodes]
                    nodes = sorted(set(plain) | {v | (1 << (W - 1)) for v in plain})
            e = gap_edges(nodes, W, inside)
            n = len(nodes)
            # states (node, i): edge (u, i) -> (v, i + 1 mod k) by the gap word[i]
            edges = []
            for i, ch in enumerate(word):
                s, d = e[int(ch)]
                edges.append((s + i * n, d + ((i + 1) % k) * n))
            alive = prune(n * k, edges)
            keep = alive.reshape(k, n).any(axis=0)
            states = int(alive.sum())
            nodes = nodes[keep] if W <= 61 else [v for v, kp in zip(nodes, keep) if kp]
            print(json.dumps(dict(word=word, W=W, kick_windows=int(keep.sum()), states=states,
                                  seconds=round(time.time() - t0, 1))))
            sys.stdout.flush()
            if states == 0:
                break


def lift_quiet(trap, w0, inside):
    nodes = None
    for W in range(16, w0 + 1):
        if W == 16:
            allw = np.arange(1 << 16, dtype=np.int64)
            cand = allw[(~inside[allw]) & ((allw & 1) == 1)]
        else:
            cand = np.sort(np.concatenate([nodes, nodes | (np.int64(1) << (W - 1))]))
        e = gap_edges(cand, W, inside)
        alive = prune(len(cand), [e[3], e[5]])
        nodes = cand[alive]
    return nodes


# ---------------------------------------------------------------- periodic strips by SAT

def strip(gaps, period, W, budget=5_000_000):
    """Columns 1..W on a time circle of `period` ticks, wall white at even ticks, column W + 1 free; the gate reads
    the cyclic gap word. Returns the status, and on SAT whether the model replays."""
    gate = ''.join('1' + '0' * (int(g) - 1) for g in gaps)
    assert 2 * len(gate) * (period // (2 * len(gate))) == period
    gate = gate * (period // (2 * len(gate)))
    var = {}
    nv = 0
    for t in range(period):
        for x in range(1, W + 2):
            nv += 1
            var[(t, x)] = nv
    clauses = []
    for t in range(period):
        t1 = (t + 1) % period
        wall = t % 2
        for x in range(1, W + 1):
            n, c, r = var[(t1, x)], var[(t, x)], var[(t, x + 1)]
            if x == 1:
                clauses += ([[-c, n], [-r, n], [c, r, -n]] if wall == 0 else [[-c, -n], [-r, -n], [c, r, n]])
            else:
                l = var[(t, x - 1)]
                clauses += [[-c, -n, -l], [-c, n, l], [-r, -n, -l], [-r, n, l], [c, r, -n, l], [c, r, n, -l]]
    for s, ch in enumerate(gate):
        v = var[(2 * s, 1)]
        clauses.append([v if ch == '1' else -v])
    from pysat.solvers import Cadical195
    with Cadical195(bootstrap_with=clauses) as sol:
        sol.conf_budget(budget)
        r = sol.solve_limited()
        if not r:
            return ('UNSAT' if r is False else 'UNKNOWN'), None, nv, len(clauses)
        model = set(v for v in sol.get_model() if v > 0)
    # replay: evolve the row with the model's free column, one tick at a time, around the whole circle
    row = [1 if var[(0, x)] in model else 0 for x in range(1, W + 1)]
    first = list(row)
    ok = True
    for t in range(period):
        if t % 2 == 0 and row[0] != int(gate[t // 2]):
            ok = False
        east = 1 if var[(t, W + 1)] in model else 0
        ext = [t % 2] + row + [east]
        row = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, W + 1)]
    ok &= row == first
    return 'SAT', ok, nv, len(clauses)


def strips():
    cases = [('3', 6, 84, 'SAT'), ('33355', 38, 54, 'SAT'), ('33355', 38, 55, 'UNSAT'),
             ('333355', 44, 37, 'SAT'), ('333355', 44, 38, 'UNSAT'),
             ('33355', 76, 54, 'SAT'), ('33355', 76, 55, 'UNSAT'), ('333355', 88, 38, 'SAT')]
    good = True
    for gaps, period, W, want in cases:
        t0 = time.time()
        status, replay, nv, nc = strip(gaps, period, W)
        agree = status == want and (replay is not False)
        good &= agree
        print(json.dumps(dict(gaps=gaps, ticks=period, columns=W, status=status, model_replays=replay,
                              stated=want, agrees=agree, variables=nv, clauses=nc,
                              seconds=round(time.time() - t0, 1))))
        sys.stdout.flush()
    print('strips', 'agree' if good else 'DISAGREE')


# ---------------------------------------------------------------- attainability of forcing words

def attain(trap, files):
    forcing = []
    for path in files:
        for line in open(path):
            r = json.loads(line)
            if r['status'] == 'UNSAT':
                forcing.append(r['word'])
    forcing = sorted(set(forcing), key=lambda w: (len(w), w))
    can, cannot = [], []
    for w in forcing:
        bits = '1' + ''.join('0' * (int(g) - 1) + '1' for g in w)
        cone = R.Cone(len(bits))
        for i, ch in enumerate(bits):
            cone.clauses.append([cone.gate(i) if ch == '1' else -cone.gate(i)])
        status, row = cone.solve(5_000_000)
        if status == 'SAT':
            gate, codes = R.simulate(row, len(bits))
            assert ''.join(map(str, gate)) == bits
            can.append(w)
        elif status == 'UNSAT':
            cannot.append(w)
        else:
            raise SystemExit('UNKNOWN for ' + w)
    fs = set(forcing)
    minimal = [w for w in forcing if not any(w[i:j] in fs for i in range(len(w)) for j in range(i + 1, len(w) + 1)
                                             if (i, j) != (0, len(w)))]
    print(json.dumps(dict(forcing_words=len(forcing), can_be_read=len(can), cannot_be_read=cannot,
                          minimal=len(minimal), minimal_that_cannot_be_read=[w for w in minimal if w in cannot],
                          shortest_readable=can[0] if can else None)))


# ---------------------------------------------------------------- the sensor rules

def sensor_case(trap, target, lead, sites, pattern, depart, history=140):
    """History: column 1 equals the wheel at the `history` ticks ending at the issue tick. The cells `sites` at the
    issue tick read `pattern`. depart = True: the first departure is at issue + lead; False: it is not (the wheel
    is kept through the target, or left earlier). Returns SAT (with a replayed row) or UNSAT."""
    issue = history                    # cone tick 0 is one tick before the history, a white tick
    assert (target - lead - history) % 2 == 0
    T = issue + lead
    S = T // 2 + 1
    cone = R.Cone(S)
    idx = lambda t: (target - T + t) % 56
    for t in range(1, issue + 1):
        v = cone.var[(t, 1)]
        cone.clauses.append([v if U[idx(t)] == '1' else -v])
    for s, ch in zip(sites, pattern):
        v = cone.var[(issue, s)]
        cone.clauses.append([v if ch == '1' else -v])
    fut = [cone.var[(t, 1)] for t in range(issue + 1, T + 1)]
    want = [U[idx(t)] == '1' for t in range(issue + 1, T + 1)]
    lits_match = [(v if w else -v) for v, w in zip(fut, want)]
    if depart:
        for lit in lits_match[:-1]:
            cone.clauses.append([lit])
        cone.clauses.append([-lits_match[-1]])
    else:
        # not (match on all but the last and mismatch on the last)
        cone.clauses.append([-lit for lit in lits_match[:-1]] + [lits_match[-1]])
    status, row = cone.solve(5_000_000)
    ok = None
    if row is not None:
        n = len(row)
        x = sum(int(b) << i for i, b in enumerate(row))
        width = n
        col = []
        cells = None
        for t in range(T + 1):
            col.append(x & 1)
            if t == issue:
                cells = ''.join(str((x >> (s - 1)) & 1) for s in sites)
            if t == T:
                break
            r = (x << 1) | (t % 2)
            x = (r ^ ((r >> 1) | (r >> 2))) & ((1 << (width - 1)) - 1)
            width -= 1
        hist_ok = all(col[t] == int(U[idx(t)]) for t in range(1, issue + 1))
        m = [col[t] == int(U[idx(t)]) for t in range(issue + 1, T + 1)]
        first_dep = all(m[:-1]) and not m[-1]
        ok = hist_ok and cells == pattern and (first_dep == depart)
    return status, ok


def sensors(trap, path):
    d = json.load(open(path))
    good = True
    for rule in d['sensors']:
        target, lead, sites = rule['target_phase'], rule['lead'], rule['sites']
        yes, no = rule['depart_if'], rule['stay_or_other_departure_if']
        k = len(sites)
        allp = [format(i, '0%db' % k) for i in range(1 << k)]
        res = {}
        for p in allp:
            a, oka = sensor_case(trap, target, lead, sites, p, True)
            b, okb = sensor_case(trap, target, lead, sites, p, False)
            res[p] = (a, b)
            if (a == 'SAT' and not oka) or (b == 'SAT' and not okb):
                good = False
        # stated: for p in yes, departure always (SAT, UNSAT); for p in no, never (UNSAT, SAT); others never occur
        agree = all(res[p] == ('SAT', 'UNSAT') for p in yes) and all(res[p] == ('UNSAT', 'SAT') for p in no) and \
            all(res[p] == ('UNSAT', 'UNSAT') for p in allp if p not in yes and p not in no)
        good &= agree
        print(json.dumps(dict(target=target, lead=lead, sites=sites, depart_if=yes, otherwise=no, agrees=agree,
                              cases={p: '/'.join(v) for p, v in res.items()})))
        sys.stdout.flush()
    # the six-tick relay: sites 1..4 = 1110 at a white tick, b = site 5: column 1 spells 1 1 0 1 0 0 b
    bad = 0
    for row in range(1 << 12):
        if row & 15 != 0b0111:
            continue
        x, width, col = row, 12, []
        for t in range(7):
            col.append(x & 1)
            r = (x << 1) | (t % 2)
            x = (r ^ ((r >> 1) | (r >> 2))) & ((1 << (width - 1)) - 1)
            width -= 1
        b = (row >> 4) & 1
        if col != [1, 1, 0, 1, 0, 0, b]:
            bad += 1
    pulses = [c for c in trap if c & 1]
    prefix = sum(1 for c in pulses if c & 15 == 0b0111)
    short = sum(1 for c in pulses if (c >> 4) & 1)
    good &= bad == 0 and prefix == len(pulses)
    print(json.dumps(dict(relay_exceptions_over_all_rows=bad, trap_pulse_windows=len(pulses),
                          with_prefix_1110=prefix, with_site_5_black=short)))
    print('sensors', 'agree' if good else 'DISAGREE')


def selftest(trap):
    ok = True
    inside = trap_table(trap)
    # 1. the two edge routines agree
    nodes = lift_quiet(trap, 18, inside)
    a = gap_edges(nodes, 18, inside)
    b = gap_edges_py([int(v) for v in nodes], 18, inside)
    same = all(sorted(zip(a[g][0].tolist(), a[g][1].tolist())) == sorted(zip(b[g][0].tolist(), b[g][1].tolist()))
               for g in (3, 5))
    ok &= same
    print('edges by numpy and by Python integers agree at 18 columns: %s' % same)
    # 2. components against plain reachability on random graphs
    rng = np.random.default_rng(7)
    good = True
    for _ in range(40):
        n = int(rng.integers(2, 14))
        m = int(rng.integers(1, 3 * n))
        src = rng.integers(0, n, m)
        dst = rng.integers(0, n, m)
        comp, _ = components(n, src.astype(np.int64), dst.astype(np.int64))
        reach = np.eye(n, dtype=bool)
        reach[src, dst] = True
        for k in range(n):
            reach |= reach[:, [k]] & reach[[k], :]
        for i in range(n):
            for j in range(n):
                if (comp[i] == comp[j]) != bool(reach[i, j] and reach[j, i]):
                    good = False
    ok &= good
    print('strongly connected components against plain reachability on 40 random graphs: %s' % good)
    # 3. component_words on built graphs: a cycle spelling 33355 twice, and a graph with a choice
    e3 = (np.array([0, 1, 2, 5, 6, 7]), np.array([1, 2, 3, 6, 7, 8]))
    e5 = (np.array([3, 4, 8, 9]), np.array([4, 5, 9, 0]))
    w1 = component_words(10, e3, e5)
    e3b = (np.array([0, 1]), np.array([1, 0]))
    e5b = (np.array([0]), np.array([0]))
    w2 = component_words(2, e3b, e5b)
    good = w1 == [('33355', 10)] and w2 == [('variable', 2)]
    ok &= good
    print('gap words of two built graphs: %s and %s: %s' % (w1, w2, good))
    # 4. the period-six strip is found and replays
    status, replay, _, _ = strip('3', 6, 12)
    good = status == 'SAT' and replay is True
    ok &= good
    print('a 12-column strip with gaps of 3 in 6 ticks: %s, replays: %s' % (status, replay))
    print('selftest', 'passed' if ok else 'FAILED')
    return ok


def main():
    kit, mode = sys.argv[1], sys.argv[2]
    trap = [int(c) for c in L.trap_codes(kit)]
    if mode == 'selftest':
        sys.exit(0 if selftest(trap) else 1)
    if mode == 'lift':
        lift(trap, int(sys.argv[3]))
    elif mode == 'words':
        word_sets(trap, int(sys.argv[3]), int(sys.argv[4]), sys.argv[5:] or ['3', '33355', '333355'])
    elif mode == 'strips':
        strips()
    elif mode == 'attain':
        attain(trap, sys.argv[3:])
    elif mode == 'sensors':
        sensors(trap, sys.argv[3])
    else:
        raise SystemExit('unknown mode')


if __name__ == '__main__':
    main()
