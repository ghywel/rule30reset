#!/usr/bin/env python3
"""claudeM5_r5_checks.py: pull R5, third block (ledger M135). The checkpoints of each trunk column.

The trunk is t001's pattern P[l][j], labels l mod 21, columns j = 0..38, column 0 the drive. Suppose columns 1..j are on
it. They stay on it as long as column j does, and column j's next cell needs column j + 1 only at j's WHITE labels, where
the pattern fixes what it must be. So column j is a drive c(l) = P[l][j] for the half-line beyond it, and at each white
label there is one CHECK: the first cell beyond must be P[l][j + 1].

For w cells beyond column j let S[l] be the windows at label l with an endless past in which every check passed (the cell
beyond the window free at every tick). A white label is a CHECKPOINT if S[l] holds a window that fails its check. A
column with no checkpoint is a wall: columns 1..j on the trunk and the w cells in S stay so for ever.

  python3 claudeM5_r5_checks.py selftest
  python3 claudeM5_r5_checks.py table W          every column, at W cells beyond: the checkpoints and the window counts
  python3 claudeM5_r5_checks.py column J W1 W2   one column at each width: checkpoints, counts, components
  python3 claudeM5_r5_checks.py keys J LABEL     the words that fail the check at LABEL, read at the start of the black run
                                                 before it
"""
import itertools, json, math, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f

T001 = f.load('t001')
P, K = f.pattern(T001)
M = 21


def step(w, c, z, r):
    full = (r << 1) | c | (z << (w + 1))
    return (((full << 1) ^ (full | (full >> 1))) >> 1) & ((1 << w) - 1)


def drive(j):
    return [P[l][j] for l in range(M)]


def need(j):
    """the required first cell at each white label of column j: from column j's own next value"""
    out = {}
    for l in range(M):
        if P[l][j] == 0:
            if j == 0:
                out[l] = P[l][1]
            else:
                v = P[(l + 1) % M][j] ^ P[l][j - 1]
                assert j == K or v == P[l][j + 1]
                out[l] = v
    return out


def intact(j, w, start=None):
    """S[l]: sets of windows with an endless intact past, checks not yet applied at l"""
    c, q = drive(j), need(j)
    S = start or [set(range(1 << w)) for _ in range(M)]
    ok = lambda l, r: l not in q or (r & 1) == q[l]
    while True:
        changed = False
        for l in range(M):
            m = (l + 1) % M
            img = set()
            for r in S[l]:
                if ok(l, r):
                    img.add(step(w, c[l], 0, r))
                    img.add(step(w, c[l], 1, r))
            new = S[m] & img
            if len(new) != len(S[m]):
                S[m] = new
                changed = True
        if not changed:
            return S


def lift(S, w):
    return [s | {r | (1 << w) for r in s} for s in S]


def checkpoints(j, S):
    q = need(j)
    return {l: sum(1 for r in S[l] if (r & 1) != q[l]) for l in q if any((r & 1) != q[l] for r in S[l])}


def components(j, w, S):
    """cyclic components of the intact graph (checks applied); closed means no window of it can fail a check or leave"""
    c, q = drive(j), need(j)
    nodes = [(l, r) for l in range(M) for r in S[l]]
    ns = set(nodes)
    fail = {(l, r) for l, r in nodes if l in q and (r & 1) != q[l]}
    succ = {}
    for l, r in nodes:
        succ[(l, r)] = [] if (l, r) in fail else [x for x in {((l + 1) % M, step(w, c[l], z, r)) for z in (0, 1)} if x in ns]
    idx, low, on, st, out, n = {}, {}, set(), [], [], 0
    for s in nodes:
        if s in idx:
            continue
        idx[s] = low[s] = n; n += 1; st.append(s); on.add(s)
        work = [(s, iter(succ[s]))]
        while work:
            v, it = work[-1]
            adv = False
            for x in it:
                if x not in idx:
                    idx[x] = low[x] = n; n += 1; st.append(x); on.add(x)
                    work.append((x, iter(succ[x]))); adv = True
                    break
                elif x in on:
                    low[v] = min(low[v], idx[x])
            if adv:
                continue
            work.pop()
            if work:
                low[work[-1][0]] = min(low[work[-1][0]], low[v])
            if low[v] == idx[v]:
                comp = []
                while True:
                    x = st.pop(); on.discard(x); comp.append(x)
                    if x == v:
                        break
                if len(comp) > 1:
                    out.append(comp)
    res = []
    for comp in out:
        cs = set(comp)
        closed = all(v not in fail and all(x in cs for x in succ[v]) for v in comp)
        res.append((len(comp), 'CLOSED' if closed else 'open', sum(1 for v in comp if v in fail)))
    return sorted(res, reverse=True), out, succ


def run_before(j, label):
    """labels of the black run of column j that ends just before `label`"""
    c, r, l = drive(j), [], (label - 1) % M
    while c[l] == 1:
        r.append(l)
        l = (l - 1) % M
    return r[::-1]


def keys(j, label, S=None, w=None):
    """words at the start of the black run before `label` whose first cell fails the check at `label`"""
    q, run = need(j), run_before(j, label)
    r = len(run)
    bad = []
    for word in range(1 << (r + 1)):
        x = word
        for k in range(r):
            width = r + 1 - k
            x = step(width - 1, 1, (x >> (width - 1)) & 1, x & ((1 << (width - 1)) - 1))
        if (x & 1) != q[label]:
            bad.append(word)
    return run, bad


def show(word, n):
    return ''.join('.#'[(word >> i) & 1] for i in range(n))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['selftest']:
        ok = True
        # the trap's own nine cells beyond column 38 pass every check and are in S
        S = intact(38, 9)
        nine = [(l, s >> 38) for s, l in zip(T001['st'], T001['lab'])]
        q = need(38)
        inS = all(r in S[l] for l, r in nine)
        passes = all(l not in q or (r & 1) == q[l] for l, r in nine)
        print('t001: its last nine columns are in S[l] at column 38:', inS, '| and pass every check:', passes)
        # one random history: an intact trunk stays the trunk
        import random
        rng = random.Random(3)
        bad = 0
        for _ in range(2000):
            j = rng.randrange(1, 38); l = rng.randrange(M)
            row = [P[l][i] for i in range(j + 1)] + [rng.randrange(2) for _ in range(30)]
            good = l not in need(j) or row[j + 1] == need(j)[l]
            new = [P[(l + 1) % M][0]] + [row[i - 1] ^ (row[i] | row[i + 1]) for i in range(1, j + 1)]
            bad += (new == [P[(l + 1) % M][i] for i in range(j + 1)]) != good
        print('2,000 random rows: columns 1..j stay on the trunk exactly when the check passes, failures', bad)
        ok = inS and passes and bad == 0
        print('SELFTEST', 'PASS' if ok else 'FAIL')
    elif a[:1] == ['table']:
        W = int(a[1])
        for j in range(0, K + 1):
            w = min(W, 8); S = intact(j, w)
            while w < W:
                S = intact(j, w + 1, lift(S, w)); w += 1
            c = drive(j)
            runs = max(len(run_before(j, l)) for l in range(M) if c[l] == 0)
            cp = checkpoints(j, S)
            print(json.dumps(dict(column=j, word=''.join('.#'[x] for x in c), white=c.count(0), longest_run=runs, w=w,
                                  windows=sum(map(len, S)), checkpoints={str(k): v for k, v in sorted(cp.items())})), flush=True)
    elif a[:1] == ['column']:
        j, w1, w2 = map(int, a[1:4])
        w = min(w1, 8); S = intact(j, w)
        while True:
            if w >= w1:
                comps, _, _ = components(j, w, S)
                print(json.dumps(dict(column=j, w=w, windows=sum(map(len, S)),
                                      checkpoints={str(k): v for k, v in sorted(checkpoints(j, S).items())},
                                      components=comps[:8])), flush=True)
            if w >= w2:
                break
            S = intact(j, w + 1, lift(S, w)); w += 1
    elif a[:1] == ['keys']:
        j, label = int(a[1]), int(a[2])
        run, bad = keys(j, label)
        n = len(run) + 1
        w = max(n, 8)
        S = intact(j, 8); ww = 8
        while ww < max(w, 14):
            S = intact(j, ww + 1, lift(S, ww)); ww += 1
        live = {r & ((1 << n) - 1) for r in S[run[0]]} if run else set()
        print(json.dumps(dict(column=j, check=label, run=run, cells=n, failing_words=[show(x, n) for x in bad],
                              readable_words=len(live), failing_and_readable=[show(x, n) for x in bad if x in live])))
    else:
        sys.exit(__doc__)
