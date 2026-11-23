#!/usr/bin/env python3
"""claudeM5_ring_rewind.py (ledger M144): the left half forced by the pure-three gate, its first mismatch with a left edge
(the table of finite-right-pure3.md), and Lowry's rewind (kit Rule30LateObservation) tried on it.

Beside the alternating column (black at even ticks here) with gate 100 at the white ticks, every cell of the columns
p <= -1 is fixed by c(t, p-1) = c(t+1, p) xor (c(t, p) or c(t, p+1)); a black column 0 masks column 1.
"""
P = 6
col = {0: [1, 0, 1, 0, 1, 0], 1: [0, 1, 0, 0, 0, 0]}     # column 1 at white ticks 1, 3, 5: 1, 0, 0 (black ticks: masked)


def left(N):
    for p in range(0, -N, -1):
        col[p - 1] = [col[p][(t + 1) % P] ^ (col[p][t] | col[p + 1][t]) for t in range(P)]


left(700)
per = next(q for q in range(1, 400) if all(col[-p] == col[-p - q] for p in range(60, 160)))
start = next(s for s in range(0, 200) if all(col[-p] == col[-p - per] for p in range(s, 250)))
print('left columns: spatial period', per, 'from column', -start, '; black density', sum(col[-p][0] for p in range(84, 84 + per)) / per)
from collections import Counter
for s in range(P):
    cnt = Counter()
    for W in range(1, per + 1):
        d = W if col[-W][s] == 0 else next(e for e in range(W + 1, W + 60) if col[-e][s] == 1)
        cnt[d - W] += 1
    print('phase', s, 'first mismatch minus W:', sorted(cnt.items()))


def ring(t, p):
    return col[p if p <= 0 else p - per * ((p + per) // per)][t % P]


# Lowry's pull: from the pair (x_r, x_{r+1}) one tick earlier and the row y = step x at r, r-1, ..., the pair at r - n
def reset(t, r, cap=400):
    S = {(a, b) for a in (0, 1) for b in (0, 1)}
    for n in range(1, cap):
        y = ring(t, r - n + 1 - 4 * per)
        S = {(y ^ (u | v), u) for (u, v) in S}
        if len(S) == 1:
            return n
    return None


R = [[reset(t, r) for r in range(per)] for t in range(P)]
print('synchronizing suffix: shortest and longest over right ends, by phase:', [(min(x for x in row if x) if any(row) else None, max(x for x in row if x) if any(row) else None, sum(x is None for x in row)) for row in R])
if all(any(row) for row in R):
    # state (t, r mod per): the row at phase t is known up to r; step back to phase t - 1, right end r' - n + 1 for r' <= r
    states = [(t, r) for t in range(P) for r in range(per)]
    def moves(t, r):
        out = {}
        for wait in range(0, per):
            rr = (r - wait) % per
            n = R[t][rr]
            if n is None:
                continue
            cost = wait + n - 1
            key = ((t - 1) % P, (rr - n + 1) % per)
            if key not in out or out[key] > cost:
                out[key] = cost
        return out
    M = {s: moves(*s) for s in states}
    # minimum mean cost cycle by Karp on the 504 states
    n = len(states); idx = {s: i for i, s in enumerate(states)}
    INF = float('inf')
    D = [[0] * n]
    for k in range(1, n + 1):
        cur = [INF] * n
        for s in states:
            a = D[-1][idx[s]]
            if a < INF:
                for q, c in M[s].items():
                    j = idx[q]
                    if a + c < cur[j]:
                        cur[j] = a + c
        D.append(cur)
    lam = min(max((D[n][v] - D[k][v]) / (n - k) for k in range(n) if D[k][v] < INF) for v in range(n) if D[n][v] < INF)
    print('least mean step of the right end per tick back:', lam, '-> a burst from age b of n ticks needs about n < %.4f b + const' % ((lam - 1) / (lam + 1)))

# the rate again, without the mean-cycle program: rewind with the best right end each time (dynamic programming over 300 ticks)
ends = {0}
K = 300
t = 0
for k in range(K):
    nxt = {}
    for r in ends:
        for wait in range(0, 40):
            rr = r - wait
            n = R[t][rr % per]
            q = rr - n + 1
            nxt[q % per] = max(nxt.get(q % per, -10 ** 9), q)
    top = max(nxt.values())
    ends = {q for q in nxt.values() if q > top - per}
    t = (t - 1) % P
print('after', K, 'ticks back the right end is at', max(ends), ': mean step', -max(ends) / K)
