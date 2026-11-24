"""Exact control of the block argument (claudeIntel, N15).  Letters c(t) = floor(t a + th) - floor(t a); letter v stands for a block
of length L[v].  T(n) = length of the first n blocks.  At each scale (r, d) with first failing time m it checks: first repeats;
2 T(m) <= T(r) + M when m + d <= r; at three failing scales in a row r' = r + 2 d and T(r) - 2 T(m) returns after two scales; and,
in the concatenated word itself with random block contents, the near-square the proof names, letter by letter."""
import math, random, sys
from fractions import Fraction as F
from collections import Counter

def cf(digits):
    x = F(digits[-1])
    for a in reversed(digits[:-1]): x = a + 1 / x
    return x

def run(digits, th, L, TMAX, st, rng):
    al = cf(digits + [10 ** 15]); NMAX = 3 * TMAX
    P, Q = al.numerator, al.denominator; p2, q2 = th.numerator, th.denominator
    g = [t * P // Q for t in range(NMAX)]
    f = [(t * P * q2 + p2 * Q) // (Q * q2) for t in range(NMAX)]
    vals = sorted(set(f[t] - g[t] for t in range(1, NMAX)))
    len_ = {v: L[v % 2] for v in vals}; len_[f[0] - g[0]] = len_.get(f[0] - g[0], L[(f[0] - g[0]) % 2])
    B = {v: [rng.randrange(2) for _ in range(len_[v])] for v in len_}
    T = [0]
    for t in range(NMAX): T.append(T[-1] + len_[f[t] - g[t]])
    word = []
    for t in range(NMAX): word += B[f[t] - g[t]]
    M = sum(len_.values()) + 1
    low = lambda p: p[1] * al > p[0]
    a, b = (g[1], 1), (g[1] + 1, 1)
    hist = []           # (r, d, m, Delta) at consecutive failing scales
    def near(i, j, K):  # in the concatenated word, places T(i), T(j)
        I, J = T[i], T[j]
        n = max(0, J - K); n = min(n, len(word) - J)
        idx = range(n) if n < 800 else list(range(400)) + list(range(n - 400, n))
        return all(word[I + s] == word[J + s] for s in idx)
    while True:
        m1 = (a[0] + b[0], a[1] + b[1])
        kept, old = (b, a) if low(m1) == low(a) else (a, b)
        m2 = (kept[0] + m1[0], kept[1] + m1[1])
        if low(m2) == low(kept):
            (x, r), (u, d), (U, D) = old, kept, m1
            if D + d >= TMAX: return
            m = next((t for t in range(1, d) if f[t + d] != f[t] + u), None)
            if m is None:
                st['first'] += 1; hist = []
                if d > 3: assert near(1, 1 + d, 4 * M)
            else:
                if m + d <= r: assert 2 * T[m] <= T[r] + M; st['fits'] += 1
                Delta = T[r] - 2 * T[m]
                ok = m < r and Delta + M >= 0
                if ok and d > 3:
                    st['second'] += 1
                    assert near(m + 1, m + 1 + d, M + 2 * M + 4)
                if not ok: st['short'] += 1
                if hist:
                    assert m == hist[-1][2] + hist[-1][1]
                hist.append((r, d, m, Delta, ok))
                if len(hist) >= 3 and m < r:
                    (r0, d0, m0, D0, _), (r1, d1, m1_, D1, _), (r2, d2, m2_, D2, _) = hist[-3:]
                    if m0 < r0 and r0 < m0 + d0 and r1 < m1_ + d1 and m1_ < r1:
                        assert r1 == r0 + 2 * d0, (hist[-3:],)
                        if r2 == r1 + 2 * d1:
                            assert D2 == D0, (D0, D1, D2); st['conserved'] += 1
                if m < r and d > 3:
                    S = max(0, -Delta)
                    assert near(m + 1, m + 1 + d, S + 2 * M + 4); st['near S'] += 1
        a, b = kept, m1

if __name__ == '__main__':
    rng = random.Random(21); st = Counter(); n = 0
    fam = [[0] + [1] * 60, [0] + [2] * 60, [0, 1] + [2] * 60, [0, 3] + [2] * 60, [0] + [1, 2] * 30, [0] + [3] * 40, [0] + [2, 2, 1] * 20, [0, 1, 1, 1] + [2] * 50, [0] + [2, 3] * 30]
    for _ in range(40): fam.append([rng.randint(-2, 2)] + [rng.choice([1, 1, 2, 2, 2, 3, 5]) for _ in range(50)])
    for ds in fam:
        for th in [F(1, 2), F(1, 3), F(2, 3), F(1, 4)] + [F(rng.getrandbits(60), 2 ** 60) for _ in range(10)]:
            for L in ((3, 5), (18, 23), (1, 7)):
                run(ds, th, L, 700, st, rng); n += 1
    print(n, 'runs', dict(st))
    # the exceptional case: silver slope and shifts of one half
    for ds in ([0, 1] + [2] * 60, [0, 3] + [2] * 60):
        al = cf(ds + [10 ** 15])
        for k in (0, -3, 2, 5, -7):
            s2 = Counter(); run(ds, (F(1, 2) + k * al), (3, 5), 4000, s2, rng); print(ds[:3], 'half arc moved by', k, dict(s2))
