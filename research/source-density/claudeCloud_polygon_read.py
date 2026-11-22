#!/usr/bin/env python3
"""claudeCloud_polygon_read.py: carrying read of the finite parts of gptIntel's I72 (ledger K64, path 3): the density
polygon of a site's black cells C and its 10 readings A. Written from the post and research/source-density/README.md;
nothing of gptIntel's code is used.

Rule 30 on a ring of w cells: new(i) = old(i - 1) xor (old(i) or old(i + 1)). At a site j over T ticks, C counts its
black ticks and A the ticks where (j, j + 1) reads 10.

1. The local identity behind 2C <= T + 2A + 1: (j, j + 1) reads 11 at tick t exactly when site j + 1 goes from black
   at t to white at t + 1. Checked on every (left, j, j + 1, j + 2) pattern.
2. The three inequalities 3C <= T + 5A + 3, 2C <= T + 2A + 1, 6C <= 5T + A + 5, on every interval of every
   evolution of every ring of 3 to 14 cells for 64 ticks (all starts), and of 200,000 random rings of 15 to 60 cells.
3. The polygon: the lines a = 0, 3c = 1 + 5a, 2c = 1 + 2a, 6c = 5 + a and a = c meet at the five stated vertices.
4. The five vertices are attained by rings that are periodic in time: (0, 0) and (1, 1) by hand; (1/3, 0) at width 12
   with time period 3 and (3/4, 1/4) at width 7 with time period 4, by enumeration of every ring; (9/10, 2/5) with
   time period 10 by SAT at width 155, the stated witness, and at every width from 1 to 160 to find the least.

    python3 claudeCloud_polygon_read.py
"""
import random
from fractions import Fraction as Fr
from pysat.solvers import Cadical195


def step(r):
    w = len(r)
    return [r[i - 1] ^ (r[i] | r[(i + 1) % w]) for i in range(w)]


def check_intervals(hist, j):
    """hist: list of rows. Checks the three bounds on every interval [s, s + T) at site j."""
    w = len(hist[0]); n = len(hist)
    c = [h[j] for h in hist]; a = [h[j] & (1 - h[(j + 1) % w]) for h in hist]
    pc = [0]; pa = [0]
    for t in range(n):
        pc.append(pc[-1] + c[t]); pa.append(pa[-1] + a[t])
    for s in range(n):
        for e in range(s + 1, n + 1):
            T = e - s; C = pc[e] - pc[s]; A = pa[e] - pa[s]
            if not (3 * C <= T + 5 * A + 3 and 2 * C <= T + 2 * A + 1 and 6 * C <= 5 * T + A + 5 and 0 <= A <= C <= T):
                return (s, e, C, A)
    return None


def main():
    # 1
    ok = True
    for l in (0, 1):
        for x in (0, 1):
            for y in (0, 1):
                for z in (0, 1):
                    ny = x ^ (y | z)
                    ok &= ((x == 1 and y == 1) == (y == 1 and ny == 0))
    print('1. 11 at (j, j+1) at t  <=>  j+1 black at t and white at t+1: %s' % ('every pattern' if ok else 'FAILS'))
    # 2
    bad = None; count = 0
    for w in range(3, 15):
        for code in range(1 << w):
            r = [(code >> i) & 1 for i in range(w)]
            hist = [r]
            for _ in range(63):
                hist.append(step(hist[-1]))
            b = check_intervals(hist, 0); count += 1
            if b:
                bad = (w, code, b); break
        if bad:
            break
    rnd = random.Random(20261122)
    if not bad:
        for _ in range(200000):
            w = rnd.randint(15, 60); r = [rnd.randint(0, 1) for _ in range(w)]
            hist = [r]
            for _ in range(rnd.randint(8, 40)):
                hist.append(step(hist[-1]))
            b = check_intervals(hist, rnd.randrange(w)); count += 1
            if b:
                bad = (w, r, b); break
    print('2. the three bounds on every interval: %s (%d evolutions)' % ('hold' if not bad else 'FAIL at %s' % (bad,), count))
    # 3
    V = [(Fr(0), Fr(0)), (Fr(1, 3), Fr(0)), (Fr(3, 4), Fr(1, 4)), (Fr(9, 10), Fr(2, 5)), (Fr(1), Fr(1))]
    lines = {'a = 0': lambda c, a: a == 0, '3c = 1 + 5a': lambda c, a: 3 * c == 1 + 5 * a, '2c = 1 + 2a': lambda c, a: 2 * c == 1 + 2 * a,
             '6c = 5 + a': lambda c, a: 6 * c == 5 + a, 'a = c': lambda c, a: a == c}
    for v in V:
        on = [k for k, f in lines.items() if f(*v)]
        inside = all([3 * v[0] <= 1 + 5 * v[1], 2 * v[0] <= 1 + 2 * v[1], 6 * v[0] <= 5 + v[1], 0 <= v[1] <= v[0] <= 1])
        print('3. vertex (%s, %s): on %s; satisfies all bounds: %s' % (v[0], v[1], ', '.join(on), inside))
    # 4
    print('4. (0, 0): the white ring of width 1 is fixed. (1, 1): the ring 10 is fixed:', step([1, 0]) == [1, 0])
    for w, q, target in ((12, 3, (1, 0)), (7, 4, (3, 1))):
        found = []
        for code in range(1 << w):
            r = [(code >> i) & 1 for i in range(w)]
            h = [r]
            for _ in range(q):
                h.append(step(h[-1]))
            if h[q] != r:
                continue
            for j in range(w):
                C = sum(h[t][j] for t in range(q)); A = sum(h[t][j] & (1 - h[t][(j + 1) % w]) for t in range(q))
                if (C, A) == target:
                    found.append((code, j))
        print('   width %d, time period %d, counts (C, A) = %s per period: %d (ring, site) pairs, e.g. ring %s'
              % (w, q, target, len(found), format(found[0][0], '0%db' % w)[::-1] if found else '-'))
    least = None
    for w in list(range(1, 161)):
        if solve_vertex(w, 10, (9, 4)):
            least = w; break
    print('   time period 10, counts (9, 4): least width %s; width 155: %s' % (least, 'SAT' if solve_vertex(155, 10, (9, 4)) else 'UNSAT'))


def solve_vertex(w, q, target):
    """Is there a ring of width w with F^q = identity and site 0 counting (C, A) = target over one period?"""
    n = [0]
    def v():
        n[0] += 1; return n[0]
    X = [[v() for _ in range(w)] for _ in range(q)]
    cl = []
    for t in range(q):
        nxt = X[(t + 1) % q]
        for i in range(w):
            a, b, c, z = X[t][i - 1], X[t][i], X[t][(i + 1) % w], nxt[i]
            for va in (0, 1):
                for vb in (0, 1):
                    for vc in (0, 1):
                        f = va ^ (vb | vc)
                        cl.append([(-a if va else a), (-b if vb else b), (-c if vc else c), (z if f else -z)])
    # C: site 0 black at exactly target[0] of the q ticks; A: 10 at (0, 1) at exactly target[1]
    from pysat.card import CardEnc, EncType
    blacks = [X[t][0] for t in range(q)]
    tens = []
    for t in range(q):
        y = v(); s0, s1 = X[t][0], X[t][1 % w]
        cl += [[-y, s0], [-y, -s1], [y, -s0, s1]]
        tens.append(y)
    e1 = CardEnc.equals(lits=blacks, bound=target[0], top_id=n[0], encoding=EncType.seqcounter); n[0] = max(n[0], e1.nv)
    e2 = CardEnc.equals(lits=tens, bound=target[1], top_id=n[0], encoding=EncType.seqcounter); n[0] = max(n[0], e2.nv)
    with Cadical195(bootstrap_with=cl + e1.clauses + e2.clauses) as s:
        if not s.solve():
            return False
        m = set(l for l in s.get_model() if l > 0)
    rows = [[1 if X[t][i] in m else 0 for i in range(w)] for t in range(q)]
    r = rows[0]; h = [r]
    for _ in range(q):
        h.append(step(h[-1]))
    assert h[q] == r and sum(h[t][0] for t in range(q)) == target[0] and sum(h[t][0] & (1 - h[t][1 % w]) for t in range(q)) == target[1]
    return True


if __name__ == '__main__':
    main()
