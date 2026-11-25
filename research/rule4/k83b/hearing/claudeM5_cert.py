"""Uniform bounds on the OR words beside any wall (claudeM5, M191): exact integer certificates, no Lean.

    python3 -I claudeM5_cert.py CELLS AHEAD ITERATIONS P/Q

The state is the set of strips of CELLS cells right of the wall that agree with the readings so far; the cell beyond is free.
At a white wall the OR reading is the first cell, at a black one it is black. A weight depends on the state and on the next AHEAD
wall bits (the look-ahead is Galindo's, R30-20261125-70fb8c). The program finds weights in floating point, rounds them up to
integers, and checks for every state, every known future and either next wall bit, in integers:
    Q * (sum over the OR readings of the next weights) <= P * weight.
Then every wall word of length n has at most C (P/Q)^n OR words, C the largest weight of the full set over the smallest weight.
"""
import sys
from fractions import Fraction
import numpy as np

w, k, iters, target = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), Fraction(sys.argv[4])
N = 1 << w


def step(x, b, e):
    r = 0
    for j in range(w):
        l = (x >> (j - 1) & 1) if j else b
        r |= (l ^ ((x >> j & 1) | (e if j == w - 1 else x >> (j + 1) & 1))) << j
    return r


tables = []
for b, o in ((0, 0), (0, 1), (1, 1)):
    image = [(1 << step(x, b, 0)) | (1 << step(x, b, 1)) if (b | (x & 1)) == o else 0 for x in range(N)]
    rows = []
    for c in range((N + 7) // 8):
        row = [0] * 256
        for v in range(1, 256):
            s = c * 8 + (v & -v).bit_length() - 1
            row[v] = row[v & (v - 1)] | (image[s] if s < N else 0)
        rows.append(row)
    tables.append(rows)


def apply(t, S):
    r = c = 0
    while S:
        if S & 255:
            r |= t[c][S & 255]
        S >>= 8
        c += 1
    return r


states, index, nxt = [(1 << N) - 1], {(1 << N) - 1: 0}, []
i = 0
while i < len(states):
    row = []
    for t in tables:
        r = apply(t, states[i])
        if r and r not in index:
            index[r] = len(states)
            states.append(r)
        row.append(index[r] if r else -1)
    nxt.append(row)
    i += 1
n, K = len(states), 1 << k
nx = np.array(nxt)
nx[nx < 0] = n                                   # the empty set: weight 0


def following(V, f, nb):                         # weights one tick later, for known future f and next known bit nb
    x = V[(f >> 1) | (nb << (k - 1))]
    return x[nx[:, 0]] + x[nx[:, 1]] if f & 1 == 0 else x[nx[:, 2]]


V = np.ones((K, n + 1))
V[:, n] = 0
best = 9.0
for _ in range(iters):
    U = np.zeros_like(V)
    for f in range(K):
        U[f, :n] = np.maximum(following(V, f, 0), following(V, f, 1))
    best = min(best, (U[:, :n] / V[:, :n]).max())
    V = 0.5 * V + 0.5 * U / best
    V /= V.max()
W = np.ceil(V * 10**11).astype(np.int64)
W[:, n] = 0
p, q = target.numerator, target.denominator
assert W[:, :n].min() > 0 and int(W.max()) * 2 * q < 2**62 and int(W.max()) * p < 2**62
bad = sum(int((following(W, f, nb) * q > W[f, :n] * p).sum()) for f in range(K) for nb in (0, 1))
print('cells %d, wall bits ahead %d: %d states, %d weights; float %.6f; %s = %.5f bits a tick, %.4f in 12 ticks: violations %d'
      % (w, k, n, n * K, best, target, np.log2(float(target)), float(target) ** 12, bad))
if bad:
    sys.exit(1)
