# claudeIntel, comb of the parked pulls: multilevel splitting on genuine initial right halves for a STAY ON Y's SCHEDULE beside the alternating wall (white first).
# Schedule (K79, K80): gate 1 at sample 0; gaps parse as (2 | 45 | 4525)*; every 57 consecutive samples hold 10001.  Score = samples read before the first violation.
# usage: python ysplit.py N K RMAX SEED [LO HI]
import sys, time
import numpy as np
N, K, RM, SEED = map(int, sys.argv[1:5])
LO, HI = (float(sys.argv[5]), float(sys.argv[6])) if len(sys.argv) > 6 else (0.2, 1.1)
rng = np.random.default_rng(SEED)
M = 2 * RM + 66; NW = (M + 63) // 64
U = np.uint64
# states: 0 u, 1 y4, 2 yS, 3 yS2, 4 dead ; table NX[state, gap]
NX = np.full((5, 8), 4, dtype=np.int8)
NX[0, 2] = 0; NX[0, 4] = 1; NX[1, 5] = 2; NX[2, 2] = 3; NX[2, 4] = 1; NX[3, 5] = 0; NX[3, 2] = 0; NX[3, 4] = 1
MX = np.array([4, 5, 4, 5, 0], dtype=np.int32)
def score(P, stop):
    A = P.copy(); n = A.shape[1]
    alive = (A[0] & U(1)).astype(bool); sc = np.where(alive, stop, 0).astype(np.int32)
    st = np.zeros(n, np.int8); last = np.zeros(n, np.int32); l4 = np.full(n, -10**6, np.int32)
    for s in range(1, stop):
        m = min(NW, (2 * (stop - s) + 130) // 64 + 1)
        for wall in (0, 1):
            X = A[:m]
            c = np.empty_like(X); c[1:] = X[:-1] >> U(63); c[0] = U(wall)
            r = X >> U(1); r[:-1] |= X[1:] << U(63)
            if m < NW: r[-1] |= A[m] << U(63)
            A[:m] = ((X << U(1)) | c) ^ (X | r)
        b = (A[0] & U(1)).astype(bool); g = np.minimum(s - last, 7)
        ns = NX[st, g]
        bad = np.where(b, ns == 4, (s - last) >= MX[st])
        four = b & (g == 4) & ~bad
        l4 = np.where(four, s, l4)
        st = np.where(b & ~bad, ns, st); last = np.where(b, s, last)
        if s >= 56: bad = bad | (l4 < s - 52)
        kill = alive & bad
        sc[kill] = s; alive &= ~bad
        if not alive.any(): break
    return sc
def mutate(P, L):
    n = P.shape[1]; f = LO + (HI - LO) * rng.random(n); x = np.minimum((f * L).astype(np.int64), M - 1)
    w = (x >> 6)[None, :]; b = (x & 63).astype(np.uint64)[None, :]; idx = np.arange(NW)[:, None]
    R = rng.integers(0, 2**64, size=P.shape, dtype=np.uint64)
    low = (U(1) << b) - U(1)
    mask = np.where(idx < w, ~U(0), np.where(idx == w, low, U(0)))
    return (P & mask) | (R & ~mask)
t0 = time.time()
P = rng.integers(0, 2**64, size=(NW, N), dtype=np.uint64); P[0] |= U(1)
sc = score(P, RM); lm = -1.0; it = 0; rep = 0
while True:
    L = int(np.sort(sc)[int(0.3 * N)]) + 1
    if sc.min() >= RM: break
    L = min(L, RM)
    ok = np.flatnonzero(sc >= L)
    if len(ok) == 0:
        L = int(sc.max()); ok = np.flatnonzero(sc >= L)
    lm += np.log2(len(ok) / N)
    dead = np.flatnonzero(sc < L); src = rng.choice(ok, size=len(dead))
    P[:, dead] = P[:, src]; sc[dead] = sc[src]
    acc = 0
    for k in range(K):
        Q = mutate(P, L); q = score(Q, RM); y = q >= L; acc += y.mean()
        P[:, y] = Q[:, y]; sc[y] = q[y]
    it += 1
    if it % 5 == 0 or sc.min() >= RM:
        print('iter %d level %d total %.2f bits, best %d, accept %.3f, %.0f s' % (it, L, lm, sc.max(), acc / K, time.time() - t0), flush=True)
    if sc.max() >= RM and rep == 0:
        rep = 1; j = int(np.argmax(sc)); row = sum(int(P[k, j]) << (64 * k) for k in range(NW)) & ((1 << M) - 1)
        print('FOUND row with %d readings: %s' % (RM, hex(row)), flush=True)
    if sc.min() >= RM: break
print('done: all particles read %d, log2 mass %.2f' % (RM, lm))
