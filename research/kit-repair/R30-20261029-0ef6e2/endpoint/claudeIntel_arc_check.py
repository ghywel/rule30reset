"""Exact control of the one-arc argument (claudeIntel, N13).  Floors of t*a and t*a + th in rational arithmetic, with a of a
denominator far beyond the range.  At each scale (v kept for the last time, W = w + v kept next) it finds the first failing time m
of the second line at lag d, and checks: the first line copies before r + d; failing times are at least r + d apart; the carry
m' = m + d at consecutive failing scales; three failures in a row force k = 1 and keep the shortfall 2m - r; and every near-square
that the proof names, by direct comparison of the word."""
import math, random, sys
from fractions import Fraction as F
from collections import Counter

def cf(digits):
    x = F(digits[-1])
    for a in reversed(digits[:-1]):
        x = a + 1 / x
    return x

def run(digits, th, TMAX, stats, H=3):
    al = cf(digits + [10 ** 15])
    g = lambda t: math.floor(t * al)
    f = lambda t: math.floor(t * al + th)
    low = lambda p: p[1] * al > p[0]
    med = lambda p, q: (p[0] + q[0], p[1] + q[1])
    a, b = (g(1), 1), (g(1) + 1, 1)
    prev = None            # (m, d, S) when the previous scale failed
    hist = []
    while max(a[1], b[1]) < TMAX:
        # a step; find scales: v kept, then W = other + v kept next
        m1 = med(a, b)
        if low(m1) == low(a):
            kept, oldo = b, a
        else:
            kept, oldo = a, b
        m2 = med(kept, m1)
        if low(m2) == low(kept):   # m2 replaces kept: m1 is kept next -> a scale with x/r = oldo, v = kept, W = m1
            (x, r), (u, d), (U, D) = oldo, kept, m1
            assert U == x + u and D == r + d
            for t in list(range(1, min(D, 200))) + [D - 1]:
                if 1 <= t < D:
                    assert g(t + d) == g(t) + u
            bad = [t for t in range(1, min(3 * D, 4000)) if f(t + d) != f(t) + u]
            assert all(q - p >= D for p, q in zip(bad, bad[1:])), (bad, D)
            m = bad[0] if bad and bad[0] < d else None
            c = lambda t: f(t) - g(t)
            def ns(i, j, K):
                rng = range(0, j - K)
                rng = list(rng) if len(rng) < 600 else list(rng[:300]) + list(rng[-300:])
                return all(c(i + s) == c(j + s) for s in rng)
            if m is None:
                stats['first'] += 1
                assert ns(H + 1, H + 1 + d, 2 * H + 2)
                prev = None; hist.append(0)
            else:
                S = 2 * m - r
                assert ns(m + 1 + H, m + 1 + H + d, max(S, 0) + 2 * H + 2)
                if S <= 0:
                    stats['second'] += 1; prev = None; hist.append(0)
                else:
                    stats['fail'] += 1
                    if prev is not None:
                        stats['carry'] += 1
                        assert m == prev[0] + prev[1], (m, prev)
                        if len(hist) >= 2 and hist[-1] and hist[-2]:
                            stats['three'] += 1
                            # the middle scale has r' = d'' + (r'' + d'') i.e. its own S equals the one before
                            assert hist_S[-1] == hist_S[-2], (hist_S[-2:],)
                    prev = (m, d, S); hist.append(1)
            if not hist[-1:]: pass
            hist_S.append(2 * m - r if m is not None else None)
        a, b = kept, m1

if __name__ == '__main__':
    random.seed(11)
    st = Counter(); n = 0
    fam = [[0] + [1] * 60, [0] + [2] * 60, [1] + [2] * 60, [0] + [1, 2] * 30, [0] + [3] * 40, [0] + [2, 2, 1] * 20, [0] + [2, 2, 2, 1] * 15, [-2] + [1, 1, 2] * 20]
    for _ in range(60):
        fam.append([random.randint(-2, 2)] + [random.choice([1, 1, 2, 2, 2, 3, 5]) for _ in range(50)])
    for ds in fam:
        for th in [F(1, 2), F(1, 3), F(2, 3), F(1, 4), F(1, 5)] + [F(random.getrandbits(60), 2 ** 60) for _ in range(25)]:
            hist_S = []
            run(ds, th, 2500, st); n += 1
    print(n, 'pairs of slope and arc', dict(st))
    # the persistent failure: silver, arc of one half (and points of its orbit)
    for th in (F(1, 2),):
        hist_S = []
        s2 = Counter(); run([0] + [2] * 60, th, 200000, s2); print('silver, half:', dict(s2), 'shortfalls', hist_S[-8:])
        hist_S = []
        s2 = Counter(); run([1] + [2] * 60, th, 200000, s2); print('silver + 1, half:', dict(s2), 'shortfalls', hist_S[-8:])
