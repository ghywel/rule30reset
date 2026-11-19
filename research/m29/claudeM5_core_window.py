#!/usr/bin/env python3
"""Pull M29 (M44, exploratory; written and run while the frozen M44 probe ran, not frozen). Enumerate R_k(n), the rows
of G_n with a forward and a backward walk of length k, by SAT on a window of 2k+1 rows with blocking clauses on the
centre row. Then the cyclic part of G_n is the cyclic part of the graph induced on R_k (every cycle of G_n lies in
R_k for every k). The enumeration is complete when the solver (pysat's CaDiCaL 1.9.5) reports no further centre row.
Usage: claudeM5_core_window.py NMIN NMAX K"""
import json, sys, time
from pysat.solvers import Solver

def window(n, k):
    L = 2 * k + 1
    v = [[0] * (n + 1) for _ in range(L)]
    nv = 0
    for t in range(L):
        for j in range(n + 1):
            nv += 1; v[t][j] = nv
    cl = []
    for t in range(L):
        cl += [[-v[t][0]], [-v[t][n]], [v[t][2]], [v[t][n - 1], -v[t][n - 2]], [-v[t][n - 1], v[t][n - 2]]]
    for t in range(L - 1):
        for j in range(2, n + 1):
            a, b, c, y = v[t][j - 2], v[t][j - 1], v[t][j], v[t + 1][j]
            for va in (0, 1):
                for vb in (0, 1):
                    for vc in (0, 1):
                        f = va ^ (vb | vc)
                        cl.append([(-a if va else a), (-b if vb else b), (-c if vc else c), (y if f else -y)])
    return v, cl

def enum(n, k, solver='cd19', cap=200000):
    v, cl = window(n, k)
    free = [v[k][1]] + [v[k][j] for j in range(3, n - 1)]
    rows = []
    with Solver(name=solver, bootstrap_with=cl) as s:
        while s.solve():
            m = s.get_model()
            val = {abs(x): x > 0 for x in m}
            row = tuple(int(val[v[k][j]]) for j in range(n + 1))
            rows.append(row)
            s.add_clause([-x if val[x] else x for x in free])
            if len(rows) >= cap:
                return rows, False
    return rows, True

def succs(w, n):
    out = []
    for b in (0, 1):
        x = [0] * (n + 1); x[1] = b
        for j in range(2, n + 1):
            x[j] = w[j - 2] ^ (w[j - 1] | w[j])
        if x[n] == 0 and x[n - 2] == x[n - 1]:
            out.append(tuple(x))
    return out

def cyclic(rows, n):
    S = set(rows)
    E = {w: [x for x in succs(w, n) if x in S] for w in rows}
    # iteratively strip rows with no successor or no predecessor inside the set, then SCCs
    alive = set(rows)
    while True:
        pred = {w: 0 for w in alive}
        for w in alive:
            for x in E[w]:
                if x in alive: pred[x] += 1
        new = {w for w in alive if pred[w] and any(x in alive for x in E[w])}
        if new == alive: break
        alive = new
    # Tarjan on alive
    idx, low, st, on, comps, c = {}, {}, [], set(), [], [0]
    sys.setrecursionlimit(100000)
    def sc(w):
        idx[w] = low[w] = c[0]; c[0] += 1; st.append(w); on.add(w)
        for x in E[w]:
            if x not in alive: continue
            if x not in idx: sc(x); low[w] = min(low[w], low[x])
            elif x in on: low[w] = min(low[w], idx[x])
        if low[w] == idx[w]:
            comp = []
            while True:
                x = st.pop(); on.discard(x); comp.append(x)
                if x == w: break
            comps.append(comp)
    for w in alive:
        if w not in idx: sc(w)
    cyc = [cp for cp in comps if len(cp) > 1 or any(x == cp[0] for x in E[cp[0]])]
    return alive, cyc

if __name__ == '__main__':
    nmin, nmax, k = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])
    for n in range(nmin, nmax + 1):
        t0 = time.time()
        rows, complete = enum(n, k)
        alive, cyc = cyclic(rows, n)
        print(json.dumps({'gap': n, 'k': k, 'R_k': len(rows), 'complete': complete, 'core_in_R': len(alive),
                          'cyclic_rows': sum(len(c) for c in cyc), 'components': sorted(len(c) for c in cyc),
                          'seconds': round(time.time() - t0, 2)}), flush=True)
