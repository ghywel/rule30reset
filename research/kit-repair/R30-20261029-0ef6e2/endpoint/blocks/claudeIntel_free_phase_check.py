# claudeIntel, N20: exact checks of I252 and of the frequency step.  Own code; angle [0; 7, 7, ...] = (sqrt 53 - 7)/2, rational phases and arcs, floors by isqrt.
import random, sys
from fractions import Fraction as F
from math import isqrt
def fl(n, off):                                 # floor(off + n*alpha), off a fraction
    d = off.denominator; a = 2*off.numerator - 7*n*d; b = n*d
    r = isqrt(53*b*b) if b >= 0 else -isqrt(53*b*b) - (0 if isqrt(53*b*b)**2 == 53*b*b else 1)
    return (a + r)//(2*d)
s = [0, 1]
while len(s) < 9: s.append(7*s[-1]+s[-2])
def arc(n, th, g): return fl(n, th) - fl(n, th-g)
rng = random.Random(252)
# 1. the number of visits in q consecutive steps: range over many starts and phases (Lean says at most 7)
worst = {}
for q in s[2:6]:
    for _ in range(6):
        th = F(rng.randrange(1, 9973), 9973); g = F(rng.randrange(1, 997), 997); L = 3000 if q < 400 else 6000
        w = [arc(n, th, g) for n in range(L+q)]; assert set(w) <= {0, 1}
        c = sum(w[:q]); lo = hi = c
        for a in range(L): c += w[a+q]-w[a]; lo = min(lo, c); hi = max(hi, c)
        worst[q] = max(worst.get(q, 0), hi-lo); assert lo <= q*g+1 and hi >= q*g-1 and abs(F(lo)-q*g) <= 4 and abs(F(hi)-q*g) <= 4
print('visits in q consecutive steps, largest range over starts:', worst)
# 2. cuts: in a window of length Q two mismatches never have one label ; 3. three trials ; 4. weighted surplus
tr = {1: 0, 2: 0, 3: 0}; weighted = {}
for k in (4, 5, 6):
    q, Q = s[k], s[k+1]
    for _ in range(60 if k < 6 else 12):
        th = F(rng.randrange(0, 10007), 10007); g = F(rng.randrange(1, 10007), 10007); p = s[k-1]
        cut = [[fl(n, th-c) for n in range(Q+q)] for c in (0, g)]; w = [x-y for x, y in zip(*cut)]
        bad = [t for t in range(Q) if w[t] != w[t+q]]; lab = [cut[0][t+q]-cut[0][t] == p for t in bad]
        assert len(bad) == len(set(lab)) <= 2, (k, th, g, bad)
        E = q//60; H = min(5, (Q-7*(q+E))//8)
        if H < 0: continue
        a, n = H, 1
        while any(a <= t < 2*a+q+E for t in bad): a = min(t for t in bad if a <= t < 2*a+q+E)+1; n += 1
        assert n <= 3 and 2*a+q+E <= 8*H+7*(q+E) <= Q and w[a:2*a+q+E] == w[a+q:2*a+2*q+E][:a+q+E]; tr[n] += 1
        for ln in ((18, 28), (28, 18), (1, 2), (3, 100)):
            T = [0]
            for x in w[:2*a+2*q+E]: T.append(T[-1]+ln[x])
            sur = T[2*a+q+E]-T[a]-T[a+q]; m = weighted.setdefault((q, ln), [sur, sur]); m[0] = min(m[0], sur); m[1] = max(m[1], sur)
print('trials used', tr)
for k in sorted(weighted): print('  q %d lengths %s: weighted surplus from %d to %d' % (k[0], k[1], *weighted[k]))
# 5. the same identity as in the read: T(a+l) - T(a) - T(b) = T(2a+E) - 2 T(a) for a repeat of length b + E at lag q = b - a
print('done')
