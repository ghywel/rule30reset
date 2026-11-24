#!/usr/bin/env python3
"""claudeM5_i66_light.py (ledger M155): GE2's nine words for every right half beside 01, from twelve cells.

A window is the first W cells at a white tick; a step is the white tick and the black one after it; a window has the four images
that one row can give. Prints, by width, the components with a cycle and the gaps they read; and at width 12 the closed component,
the windows that stay outside it for ever, the entry line and the death of the nine words inside it.
"""
import numpy as np
import scipy.sparse as sp
from scipy.sparse.csgraph import connected_components
U = np.uint64


def step(x, W):
    out = []
    for e in range(4):
        r = x | U(e << W)
        for d in (0, 1):
            r = ((r << U(1)) | U(d)) ^ (r | (r >> U(1)))
        out.append(r & U((1 << W) - 1))
    return out


def among(a, x):
    if len(a) == 0:
        return np.zeros(len(x), bool)
    p = np.searchsorted(a, x)
    p[p == len(a)] = 0
    return a[p] == x


def components(W):
    N = 1 << W
    cols = np.concatenate(step(np.arange(N, dtype=U), W)).astype(np.int64)
    rows = np.concatenate([np.arange(N)] * 4)
    k, lab = connected_components(sp.csr_matrix((np.ones(len(rows), np.int8), (rows, cols)), shape=(N, N)), directed=True,
                                  connection='strong')
    cyc, left = np.zeros(k, bool), np.zeros(k, bool)
    cyc[lab[rows[lab[rows] == lab[cols]]]] = True
    left[lab[rows[lab[rows] != lab[cols]]]] = True
    out = []
    for c in np.nonzero(cyc)[0]:
        m = (lab[rows] == c) & (lab[cols] == c)
        nx = {}
        for a, b in zip(rows[m].tolist(), cols[m].tolist()):
            nx.setdefault(a, set()).add(b)
        cur, gaps = {y for x in nx if x & 1 for y in nx[x]}, []
        for g in range(1, 9):
            if any(y & 1 for y in cur):
                gaps.append(g)
            cur = {z for y in cur if not y & 1 for z in nx.get(y, ())}
        out.append((int((lab == c).sum()), bool(left[c]), gaps, np.nonzero(lab == c)[0].astype(U)))
    return sorted(out, key=lambda t: -t[0])


def two_way(O, W):
    while True:
        c, ok = len(O), np.zeros(len(O), bool)
        for y in step(O, W):
            ok |= among(O, y)
        O = O[ok]
        if len(O):
            O = O[among(np.unique(np.concatenate(step(O, W))), O)]
        if len(O) == c:
            return O


def sweep(L, W):
    for t in range(len(L) - 2, -1, -1):
        ok = np.zeros(len(L[t]), bool)
        for y in step(L[t], W):
            ok |= among(L[t + 1], y)
        L[t] = L[t][ok]
    for t in range(1, len(L)):
        r = np.unique(np.concatenate(step(L[t - 1], W))) if len(L[t - 1]) else L[t - 1]
        L[t] = L[t][among(r, L[t])]


for W in range(10, 17):
    print('cells', W, [(n, 'left by a path' if o else 'closed', 'gaps', g) for n, o, g, _ in components(W)])
W0 = 12
K = [v for _, o, _, v in components(W0) if not o][0]
x = np.arange(1 << W0, dtype=U)
M = two_way(x[~among(K, x)], W0)
O, W, s = M, W0, [(W0, len(M))]
while W < 16:
    O, W = two_way(np.sort(np.concatenate([O, O | U(1 << W)])), W + 1), W + 1
    s.append((W, len(O)))
print('closed', len(K), 'outside for ever by width', s)
for m, n in ((8, 16), (10, 20)):
    L = [np.array([0, 1], dtype=U) for _ in range(n + 1)]
    for W in range(1, 20):
        if W > 1:
            L = [np.concatenate([z, z + U(1 << (W - 1))]) for z in L]
        if W == W0:
            L = [z[~among(K, z)] for z in L]
            L[m] = L[m][~among(M, L[m])]
        sweep(L, W)
        if sum(map(len, L)) == 0:
            break
    print('outside at', n + 1, 'white ticks in a row, and not one of the', len(M), 'windows at the', m, 'th: dies at width', W)
for w in ("11", "00000", "101001", "100101", "10010001", "1000101", "10001001", "100010001", "1000010001"):
    L = [np.array([int(c)], dtype=U) for c in w]
    for W in range(1, 20):
        if W > 1:
            L = [np.concatenate([z, z + U(1 << (W - 1))]) for z in L]
        if W == W0:
            L = [z[among(K, z)] for z in L]
        sweep(L, W)
        if sum(map(len, L)) == 0:
            break
    print('word', w, 'from the closed set dies at width', W)
