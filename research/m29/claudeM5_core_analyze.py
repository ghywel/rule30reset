#!/usr/bin/env python3
"""Pull M29 (M44, exploratory; written and run while the frozen M44 probe ran, not frozen). From the cyclic part of G_n
(found by claudeM5_core_window.py), every doubling at every period. A doubling of half-period h is a walk of length
h from (x,y) to (y,x) in the pair graph (pairs of rows of one component with complementary bit 1, both rows
stepping, complementary bit 1 kept). It lies in one pair-SCC D. The lengths of such walks are, for large h, exactly
the h = r mod g_D (g_D the period of D), and a long walk can visit all of D, so it is whole if the rows of D cover
the interior. Reports per gap: components (size, period, whole, bad), swappable pairs, swappable bad pairs, and the
half-period classes (g_D, r, whole) of every swappable bad pair.
Usage: claudeM5_core_analyze.py NMIN NMAX K [ROWS_OUT_JSONL]"""
import json, math, re, sys
from collections import deque
sys.path.insert(0, sys.path[0])
from claudeM5_core_window import enum, cyclic, succs
BAD = re.compile(r'01(?:111)*0')

def sccs(nodes, E):
    idx, low, st, on, comps, c = {}, {}, [], set(), [], [0]
    for root in nodes:
        if root in idx: continue
        stack = [(root, iter(E[root]))]
        idx[root] = low[root] = c[0]; c[0] += 1; st.append(root); on.add(root)
        while stack:
            v, it = stack[-1]
            nxt = next(it, None)
            if nxt is not None:
                if nxt not in idx:
                    idx[nxt] = low[nxt] = c[0]; c[0] += 1; st.append(nxt); on.add(nxt)
                    stack.append((nxt, iter(E[nxt])))
                elif nxt in on:
                    low[v] = min(low[v], idx[nxt])
            else:
                stack.pop()
                if stack: low[stack[-1][0]] = min(low[stack[-1][0]], low[v])
                if low[v] == idx[v]:
                    comp = []
                    while True:
                        x = st.pop(); on.discard(x); comp.append(x)
                        if x == v: break
                    comps.append(comp)
    return comps

def period(comp, E):
    S = set(comp); d = {comp[0]: 0}; q = deque([comp[0]]); g = 0
    while q:
        u = q.popleft()
        for v in E[u]:
            if v not in S: continue
            if v not in d: d[v] = d[u] + 1; q.append(v)
            else: g = math.gcd(g, d[u] + 1 - d[v])
    return abs(g), d

def analyze(n, comps):
    full = (1 << n) - 2
    rmask = lambda w: sum(w[i] << i for i in range(1, n))
    out = []
    for C in comps:
        S = set(C)
        E = {w: [x for x in succs(w, n) if x in S] for w in C}
        g, _ = period(C, E)
        cover = 0
        for w in C: cover |= rmask(w)
        bad = [w for w in C if not BAD.search(''.join(map(str, w)))]
        P = [(x, y) for x in C for y in C if x[1] != y[1]]
        PE = {(x, y): [(a, b) for a in E[x] for b in E[y] if a[1] != b[1]] for x, y in P}
        pc = sccs(P, PE)
        cid = {p: i for i, cp in enumerate(pc) for p in cp}
        swaps, badswaps, halfs = 0, 0, set()
        for i, D in enumerate(pc):
            Dset = set(D)
            if len(D) == 1 and D[0] not in PE[D[0]]: continue
            sw = [(x, y) for x, y in D if (y, x) in Dset]
            if not sw: continue
            gD, dist = period(D, PE)
            coverD = 0
            for x, y in D: coverD |= rmask(x) | rmask(y)
            swaps += len(sw)
            bsw = [(x, y) for x, y in sw if not BAD.search(''.join(map(str, x)))]
            badswaps += len(bsw)
            for x, y in bsw:
                r = (dist[(y, x)] - dist[(x, y)]) % gD if gD else None
                halfs.add((gD, r, coverD == full))
        out.append({'size': len(C), 'period': g, 'whole': cover == full, 'bad': len(bad), 'pairs': len(P),
                    'swappable': swaps, 'swappable_bad': badswaps,
                    'bad_swap_classes': sorted(halfs)})
    return out

def dyadic_possible(classes):
    """some h = 2^m (any m >= 0, large m allowed) with h = r mod gD, in a whole pair-SCC"""
    hits = []
    for gD, r, whole in classes:
        if not whole: continue
        res = {pow(2, m, gD) for m in range(0, 64 + gD)}
        if r in res: hits.append((gD, r))
    return hits

if __name__ == '__main__':
    nmin, nmax, k = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])
    for n in range(nmin, nmax + 1):
        rows, complete = enum(n, k)
        alive, cyc = cyclic(rows, n)
        res = analyze(n, cyc)
        allc = [c for comp in res for c in comp['bad_swap_classes']]
        if len(sys.argv) > 4:
            with open(sys.argv[4], 'a') as fh:
                fh.write(json.dumps({'gap': n, 'components': [[''.join(map(str, w)) for w in C] for C in cyc]}) + '\n')
        print(json.dumps({'gap': n, 'k': k, 'R_k': len(rows), 'complete': complete,
                          'cyclic_rows': sum(len(c) for c in cyc), 'components': res,
                          'swappable_bad': sum(c['swappable_bad'] for c in res),
                          'dyadic_hits': dyadic_possible(allc)}), flush=True)
