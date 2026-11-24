#!/usr/bin/env python3
"""make_table.py OUT.json [m,n]: the table of the closed set at period two (ledger M156; mechanism of S10, S15, S16).

A row contains columns 1, 2, ... of a right half at a white sample of a black-first alternating boundary,
read as a number (bit i = column i + 1). One step between white samples is two Rule 30 updates. Time lines share a mask:
  K      bits 0, 1: the rows of the trap and their images, so the trap is closed. The trap is the one closed component of the
         graph of all 2^12 windows of 12 cells, with the four images of a window under one period of one row
  entry  steps 0..m from every row, then m..n from the rows whose first W1 cells are not in M: ends in the trap
  M      one bit: the first W1 cells are in M, the windows that can stay outside the trap for ever
  words  from a row of the trap, a gate word that no row of it reads ('?' reads anything)
Each line is lifted a column at a time and swept backward ("in": no allowed successor) and forward ("out": not reached). The
walk in the Lean is the proof; this only proposes a table. It also runs the walk and the leaf checks, and counts the steps.
"""
import json
import sys
import numpy as np
import scipy.sparse as sp
from scipy.sparse.csgraph import connected_components

U = np.uint64
OUT = sys.argv[1]
WORD, DR = '01', [0, 1]
GATE = 0
W0 = 12
W1, m, n = 12, 10, 20
WORDS = ['11', '00000', '101001', '100101', '10010001', '1000101', '10001001', '100010001', '1000010001', '1010100001']
if len(sys.argv) > 2:
    m, n = map(int, sys.argv[2].split(','))


def among(a, x):
    if len(a) == 0:
        return np.zeros(len(x), bool)
    p = np.searchsorted(a, x)
    p[p == len(a)] = 0
    return a[p] == x


def period(x, W):
    out = []
    for e in range(4):
        r = x | U(e << W)
        for d in DR:
            r = (r << U(1) | U(d)) ^ (r | (r >> U(1)))
        out.append(r & U((1 << W) - 1))
    return out


def trap():
    """the one closed component of the graph of all windows of W0 cells"""
    N = 1 << W0
    cols = np.concatenate(period(np.arange(N, dtype=U), W0)).astype(np.int64)
    rows = np.concatenate([np.arange(N)] * 4)
    k, lab = connected_components(sp.csr_matrix((np.ones(len(rows), np.int8), (rows, cols)), shape=(N, N)), directed=True,
                                  connection='strong')
    left = np.zeros(k, bool)
    left[lab[rows[lab[rows] != lab[cols]]]] = True
    closed = [c for c in range(k) if not left[c]]
    assert len(closed) == 1
    return np.nonzero(lab == closed[0])[0].astype(U)


def two_way(O, W):
    """windows with an image and a preimage among them"""
    while True:
        c, ok = len(O), np.zeros(len(O), bool)
        for y in period(O, W):
            ok |= among(O, y)
        O = O[ok]
        if len(O):
            O = O[among(np.unique(np.concatenate(period(O, W))), O)]
        if len(O) == c:
            return O


KG = trap()
MG, W = np.arange(1 << W0, dtype=U), W0
MG = two_way(MG[~among(KG, MG)], W)
while W < W1:
    MG, W = two_way(np.sort(np.concatenate([MG, MG | U(1 << W)])), W + 1), W + 1
inm, alive = {}, set()


def setin(W, vs, bit):
    for v in vs.tolist():
        inm[(W, v)] = inm.get((W, v), 0) | (1 << bit)


def live(W, vs):
    alive.update((W, v) for v in vs.tolist())


def sweep(L, W, mark):
    for t in range(len(L) - 2, -1, -1):
        ok = np.zeros(len(L[t]), bool)
        for y in period(L[t], W):
            ok |= among(L[t + 1], y)
        mark(t, L[t][~ok])
        L[t] = L[t][ok]
    for t in range(1, len(L)):
        r = np.unique(np.concatenate(period(L[t - 1], W))) if len(L[t - 1]) else L[t - 1]
        L[t] = L[t][among(r, L[t])]


for b in (0, 1):
    setin(W0, KG, b)
for w in range(1, W0):
    live(w, np.unique(KG & U((1 << w) - 1)))
A, B = 2, 2 + m + 1
Mb = B + (n - m) + 1


def mark_entry(W):
    def f(t, x):
        if t <= m:
            setin(W, x, A + t)
        if t >= m:
            setin(W, x, B + t - m)
    return f


L, W = [np.array([0, 1], dtype=U) for _ in range(n + 1)], 1
while True:
    mk = mark_entry(W)
    if W == W0:
        for t in range(n + 1):
            k = among(KG, L[t])
            mk(t, L[t][k])
            L[t] = L[t][~k]
    if W == W1:
        k = among(MG, L[m])
        setin(W, L[m][k], A + m)
        L[m] = L[m][~k]
    sweep(L, W, mk)
    for x in L:
        live(W, x)
    if sum(map(len, L)) == 0:
        break
    assert W < W1 + 8
    L, W = [np.concatenate([x, x + U(1 << W)]) for x in L], W + 1
setin(W1, MG, Mb)
for w in range(1, W1):
    live(w, np.unique(MG & U((1 << w) - 1)))
tgt = {1: '?'}
tgt.update((A + t, '?') for t in range(1, m + 1))
tgt.update((B + t, '?') for t in range(1, n - m + 1))
off, wordlines = Mb + 1, []
for w in WORDS:
    wordlines.append((off, w))
    L, W = [np.array([0, 1] if c == '?' else [int(c)], dtype=U) for c in w], 1
    while True:
        if W == W0:
            L = [x[among(KG, x)] for x in L]
        sweep(L, W, lambda t, x: setin(W, x, off + t))
        for x in L:
            live(W, x)
        if sum(map(len, L)) == 0:
            break
        assert W < 30
        L, W = [np.concatenate([x, x + U(1 << W)]) for x in L], W + 1
    tgt.update((off + t, w[t]) for t in range(1, len(w)))
    off += len(w)
sys.setrecursionlimit(100000)
ids, nodes = {}, []


def node(k):
    if k not in ids:
        ids[k] = len(nodes)
        nodes.append(k)
    return ids[k]


def grow(W, v, acc):
    acc |= inm.get((W, v), 0)
    if (W, v) not in alive:
        return node(('L', acc))
    x, y = grow(W + 1, v, acc), grow(W + 1, v + (1 << W), acc)
    return x if x == y and nodes[x][0] == 'L' else node(('N', x, y))


root = node(('N', grow(1, 0, 0), grow(1, 1, 0)))
leaves = [i for i, k in enumerate(nodes) if k[0] == 'L']
inner = [i for i, k in enumerate(nodes) if k[0] == 'N']
lo, hi = {}, {}
for i, k in enumerate(nodes):
    lo[i] = k[1] if k[0] == 'L' else lo[k[1]] & lo[k[2]]
    hi[i] = k[1] if k[0] == 'L' else hi[k[1]] | hi[k[2]]
white = sum(1 << b for b, c in tgt.items() if c in '?0')
black = sum(1 << b for b, c in tgt.items() if c in '?1')


def child(i, b):
    return i if nodes[i][0] == 'L' else nodes[i][1 + b]


def follow(i, x, k):
    for j in range(k):
        i = child(i, (x >> j) & 1)
    return i


steps = 0


def walk(col, a, b, st, fuel):
    global steps
    steps += 1
    if ((hi[a] << 1) & col) & ~lo[b] == 0:
        return True
    if fuel == 0:
        return False
    x1, x2, y0, y1 = st
    for bit in (0, 1):
        y2 = x1 ^ (x2 | bit)
        if not walk(col, child(a, bit), child(b, y0 ^ (y1 | y2)), (x2, bit, y1, y2), fuel - 1):
            return False
    return True


ok = True
for p in range(8):
    x = [(p >> j) & 1 for j in range(3)]
    y = [DR[0] ^ (x[0] | x[1]), x[0] ^ (x[1] | x[2])]
    w0 = DR[1] ^ (y[0] | y[1])
    ok &= walk(black if w0 else white, follow(root, p, 3), child(root, w0), (x[1], x[2], y[0], y[1]), 46)


def under(i):
    st, seen, out = [i], set(), set()
    while st:
        j = st.pop()
        if j not in seen:
            seen.add(j)
            if nodes[j][0] == 'L':
                out.add(nodes[j][1])
            else:
                st += nodes[j][1:]
    return out


tb = lambda x, b: (x >> b) & 1
al = under(root)
leaf = [all(tb(x, A) for x in al), all(not tb(x, A + m) or tb(x, B) or tb(x, Mb) for x in al),
        all(not tb(x, B + n - m) or tb(x, 0) for x in al), all(tb(x, 0) == tb(x, 1) for x in al)]
for o, w in wordlines:
    for b in (0, 1):
        lv = under(child(root, b))
        if w[0] in '?%d' % b:
            leaf.append(all(not tb(x, 0) or tb(x, o) for x in lv))
        if w[-1] in '?%d' % b:
            leaf.append(all(not tb(x, o + len(w) - 1) for x in lv))
print(WORD, 'trap', len(KG), 'M', len(MG), 'of', W1, 'cells; bits', off, 'time sets', len(leaves), 'branches', len(inner),
      'walk', ok, 'in', steps, 'steps; leaf checks', all(leaf))
new = {i: j for j, i in enumerate(leaves + inner)}
assert inner[-1] == root
json.dump(dict(word=WORD, DR=DR, W0=W0, W1=W1, m=m, n=n, A=A, B=B, Mb=Mb, bits=off, words=wordlines, gate=GATE, white=white,
               black=black, leaves=[nodes[i][1] for i in leaves], branches=[(new[nodes[i][1]], new[nodes[i][2]]) for i in inner],
               K=KG.tolist(), M=MG.tolist()), open(OUT, 'w'))
