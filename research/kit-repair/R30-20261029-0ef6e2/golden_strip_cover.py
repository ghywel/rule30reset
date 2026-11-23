"""Check the golden two-embedding cover in Z[sqrt(5)]. Python standard library only.

For internal coordinate s in [0,1], list the consecutive crossings at each
of six base lags. Each pair witnesses a repeat throughout an interval of the
physical coordinate z. Check that these intervals cover [-1,5] on every slab.
See golden-strip-cover.md for the connection to finite scales and Rule 30.
"""
from dataclasses import dataclass
from itertools import pairwise
from math import isqrt


@dataclass(frozen=True)
class Quad:
    a: int
    b: int = 0

    def __add__(self, other):
        return Quad(self.a + other.a, self.b + other.b)

    def __sub__(self, other):
        return Quad(self.a - other.a, self.b - other.b)

    def __mul__(self, k):
        return Quad(k * self.a, k * self.b)

    def __lt__(self, other):
        a, b = self.a - other.a, self.b - other.b
        if b == 0:
            return a < 0
        if b > 0:
            return a < 0 and a*a > 5*b*b
        return a <= 0 or a*a < 5*b*b

    def time_part(self):
        return Quad(-self.a, self.b)


ZERO, ONE = Quad(0), Quad(1)
FAMILIES = (Quad(-3, 1), Quad(-4, 2), Quad(-7, 3),
            Quad(-11, 5), Quad(-18, 8), Quad(-29, 13))


def crossing_strips(e, first_b, last_b):
    """(point, left, right) for every strip meeting [0,1] in this b-window."""
    lo, hi = sorted((ZERO, ZERO - e))
    strips = []
    for b in range(first_b, last_b + 1):
        # a differs from -b sqrt(5) by at most two since 0<=s<=1, |W|<1.
        k = isqrt(5*b*b) * (1 if b >= 0 else -1)
        for a in range(-k-3, -k+4):
            point = Quad(a, b)
            left, right = lo - point, hi - point
            if left < right and not ONE < left and ZERO < right:
                strips.append((point, left, right))
    return strips


def rectangle_cover(families=FAMILIES, first_b=-32, last_b=64):
    by_family = {}
    edges = {ZERO, ONE}
    for e in families:
        if not ZERO < e.time_part() or not (ZERO-ONE < e < ONE) or (e.a + e.b) % 2:
            raise ValueError(f'invalid lag family {e}')
        strips = crossing_strips(e, first_b, last_b)
        by_family[e] = strips
        for _, left, right in strips:
            edges.update(v for v in (left, right) if ZERO < v < ONE)

    # The sign tests above and comparisons below are the only order oracle.
    # At a left endpoint each half-open strip takes its value to the right.
    used = set()
    max_chain = 0
    for s in sorted(edges):  # s=1 is checked as a singleton
        intervals = []
        for e, strips in by_family.items():
            active = [p for p, left, right in strips if not s < left and s < right]
            for p, r in pairwise(active):
                u, v, q = p.time_part(), r.time_part(), e.time_part()
                # z+v >= 11q/10 and v-2u-z >= 11q/10.
                lo = q*11 - v*10
                hi = (v-u*2)*10 - q*11
                if not hi < lo:
                    intervals.append((lo, hi, (e, p, r)))
        intervals.sort(key=lambda iv: iv[0])
        reach, end = Quad(-10), Quad(50)  # ten times z
        i = count = 0
        while reach < end:
            best, witness = reach, None
            while i < len(intervals) and not reach < intervals[i][0]:
                _, right, candidate = intervals[i]
                if best < right:
                    best, witness = right, candidate
                i += 1
            if witness is None:
                raise ValueError(f'uncovered at s={s}, immediately above 10z={reach}')
            used.add(witness)
            reach = best
            count += 1
        max_chain = max(max_chain, count)
    return len(edges), used, max_chain


if __name__ == '__main__':
    edges, used, depth = rectangle_cover()
    print(f'{edges-1} half-open slabs and upper endpoint covered; {len(used)} distinct pairs')
    print(f'maximum intervals per cover: {depth}')
    print('witness families (a,b):', sorted({(e.a, e.b) for e, _, _ in used}))
    print('witness b range:', min(p.b for _, p, _ in used), max(r.b for _, _, r in used))
