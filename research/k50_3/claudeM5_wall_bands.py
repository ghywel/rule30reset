#!/usr/bin/env python3
"""claudeM5_wall_bands.py: the band at the edge beside a driven wall (K50.3, K63's open form, M196).

  python3 -I research/k50_3/claudeM5_wall_bands.py

A row of n cells, 0..n-1, black at 0 and arbitrary after; white to the left; its right neighbour at every tick s is
a prescribed wall value w(s) (the driven half of K63). Rule 30: c'(q) = c(q-1) xor (c(q) or c(q+1)). The edge moves
one cell left each tick, so at age t it is at -t. The band at age t is the w cells from the edge, edge cell first, as
a binary number (Rule30TwoSidedInverse.band). Hughes's good bands are 200 and 222 for w = 8 (EdgeGood8). The wall
value at tick s reaches the band at age t only if s <= w - 1 - n, whatever t is, so the band is a function of the row
and the first w - n wall values. This prints, for each n, how many (row, wall prefix) pairs give a good band at age 8
and every later age to 40, and which ones fail. It simulates the half at every age; claudeM5_wall_bands.cpp is the
second program, which applies R once the row is 8 or 20 cells wide.
"""
import itertools

GOOD8 = {200, 222}


def run(row, wall, t):
    """the cells -t .. n-1 at age t, as a dict; wall is a function of the tick"""
    n = len(row)
    c = {q: row[q] for q in range(n)}
    for s in range(t):
        lo = -s
        new = {}
        for q in range(lo - 1, n):
            l = c.get(q - 1, 0)
            m = c.get(q, 0)
            r = wall(s) if q + 1 == n else c.get(q + 1, 0)
            new[q] = l ^ (m | r)
        c = new
    return c


def band(c, t, w=8):
    return int(''.join(str(c.get(-t + j, 0)) for j in range(w)), 2)


def main():
    for n in range(1, 13):
        need = max(0, 8 - n)              # wall ticks that can reach the band
        total = bad = 0
        fails = []
        for tail in itertools.product((0, 1), repeat=n - 1):
            row = (1,) + tail
            for pre in itertools.product((0, 1), repeat=need):
                total += 1
                # later wall values are irrelevant; take them alternating 1, 0, ... as a control
                wall = lambda s, pre=pre: pre[s] if s < len(pre) else (s + 1) % 2
                ok = True
                for t in range(8, 41):
                    ct = run(row, wall, t)
                    if band(ct, t) not in GOOD8:
                        ok = False
                        break
                if not ok:
                    bad += 1
                    if len(fails) < 4:
                        fails.append((''.join(map(str, row)), ''.join(map(str, pre))))
        print('n=%2d  wall ticks that matter: %d  pairs %5d  bad at some age 8..40: %4d  %s' % (n, need, total, bad, fails))


if __name__ == '__main__':
    main()
