"""Is S19's one-arc exclusion already implied by the known right-half rules?  Exact: return times of a rotation to an arc.
For slope a (exact rational with a huge denominator) and arc length g, the return times are p, q, p+q with
p = first time n with 0 < frac(n a) < g (a step forward), q = first time with 0 < 1 - frac(n a) < g (a step back)."""
from fractions import Fraction as F
import random
NINE = {(2,2),(2,4),(2,5),(3,3),(3,5),(4,5),(5,2),(5,3),(5,5)}
random.seed(4)

def returns(a, g):
    """partition of the arc [0, g) by return time, exact"""
    p = q = None; n = 1
    while p is None or q is None:
        x = (n * a) % 1
        if p is None and 0 < x < g: p = (n, x)
        if q is None and 0 < 1 - x < g: q = (n, 1 - x)
        n += 1
        if n > 4000: return None
    return p, q

def classify(a, g):
    r = returns(a, g)
    if r is None: return 'too long'
    (p, A), (q, B) = r
    lp, lq, lm = g - A, g - B, A + B - g      # lengths of the three pieces
    assert lm >= 0
    times = [p] * (lp > 0) + [q] * (lq > 0) + [p + q] * (lm > 0)
    # consecutive pairs: image of each piece meets which pieces (open intervals, exact)
    pieces = [(F(0), g - A, p, A)] if lp > 0 else []
    if lm > 0: pieces.append((g - A, B, p + q, A - B))
    if lq > 0: pieces.append((B, g, q, -B))
    pairs = set()
    for (x0, x1, t, s) in pieces:
        for (y0, y1, u, _) in pieces:
            if max(x0 + s, y0) < min(x1 + s, y1): pairs.add((t, u))
    if 1 in times: return 'adjacent blacks'
    if not all(t in (2, 3, 4, 5) for t in times): return 'gap above 5'
    if not pairs <= NINE: return 'pair not among the nine'
    return 'survives %s %s' % (sorted(set(times)), 'three pieces' if lm > 0 and lp > 0 and lq > 0 else 'two pieces')

from collections import Counter
C = Counter()
Q = 10 ** 40
for _ in range(200000):
    a = F(random.randrange(1, Q), Q); g = F(random.randrange(1, Q), Q)
    C[classify(a, g)] += 1
print('random arcs:', dict(C))
# near the possible slopes, every arc with all return times at most 5
C2 = Counter()
for _ in range(200000):
    lo, hi = random.choice([(F(1, 3), F(1, 2)), (F(1, 5), F(1, 2)), (F(1, 2), F(4, 5)), (F(2, 5), F(1, 2)), (F(1, 3), F(2, 5))])
    a = lo + (hi - lo) * F(random.randrange(1, Q), Q); g = F(random.randrange(1, Q), Q) / 2
    C2[classify(a, g)] += 1
print('slopes 1/5..4/5, arcs to 1/2:', dict(C2))
C3 = Counter()
for _ in range(40000):
    a = F(random.randrange(1, Q), Q); k = random.randrange(1, 12)
    for g in ((k * a) % 1, 1 - (k * a) % 1):
        C3[classify(a, g)] += 1
print('arcs with both ends on one orbit:', dict(C3))
# half-circles: adjacent blacks always
C4 = Counter()
for _ in range(20000):
    a = F(random.randrange(1, Q), Q); C4[classify(a, F(1, 2))] += 1
print('half-circles:', dict(C4))
