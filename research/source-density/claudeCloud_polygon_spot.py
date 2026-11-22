#!/usr/bin/env python3
"""claudeCloud_polygon_spot.py: spot checks for the carrying read of path 3 (ledger K67), beside the Lean replay.
Independent of Lean: the five corner films and the singleton are simulated here from the rule.

  1. The five films of Rule30SourceDensityCorners.lean, read from that file as data: each is periodic in space and
     time under new(i) = old(i - 1) xor (old(i) or old(i + 1)), with the stated counts (C, A) at sites 0 and 1.
  2. `optimal_startup`: on the fourth film the three additive constants 3, 1 and 5 are attained on the stated
     intervals.
  3. The single seed: at sites -3..3 the two deficits 2T + 7A - 5C and 6T + 3A - 8C against the Lean margins
     k - 4 and k - 6 at every T up to 2^16, and where the pair (C/T, A/T) sits.
  4. The five corners against the five facets, and the Farkas multipliers used in Rule30DensityPolygon.lean, on a
     grid of integer (alpha, beta, gamma).

    python3 claudeCloud_polygon_spot.py Rule30SourceDensityCorners.lean
"""
import re
import sys


def film_ok(rows, w, p):
    grid = [[(rows[t] >> i) & 1 for i in range(w)] for t in range(p)]
    for t in range(p):
        for i in range(w):
            if grid[(t + 1) % p][i] != grid[t][(i - 1) % w] ^ (grid[t][i] | grid[t][(i + 1) % w]):
                return None
    return grid


def counts(grid, s, n, w):
    p = len(grid)
    C = sum(grid[(s + t) % p][0] for t in range(n))
    A = sum(grid[(s + t) % p][0] & (1 - grid[(s + t) % p][1 % w]) for t in range(n))
    return C, A


def main():
    text = open(sys.argv[1]).read()
    arrays = {int(k): [int(x) for x in body.split(',')] for k, body in re.findall(r'def rows(\d) : Array Nat := #\[(.*?)\]', text)}
    shape = {0: (1, 1, (0, 0)), 1: (12, 3, (1, 0)), 2: (7, 4, (3, 1)), 3: (155, 10, (9, 4)), 4: (2, 1, (1, 1))}
    print('1. The five films.')
    grids = {}
    for k in range(5):
        w, p, want = shape[k]
        g = film_ok(arrays[k], w, p)
        grids[k] = g
        print('   film %d: width %d, time period %d: a Rule 30 history: %s; counts over one period %s (stated %s)'
              % (k, w, p, g is not None, counts(g, 0, p, w) if g else None, want))
    g = grids[3]
    print('2. The sharp constants on film 3.')
    for name, (s, n), f, want in (('3C - 5A - T', (2, 3), lambda C, A, T: 3 * C - 5 * A - T, 3),
                                  ('2C - 2A - T', (8, 9), lambda C, A, T: 2 * C - 2 * A - T, 1),
                                  ('6C - A - 5T', (4, 9), lambda C, A, T: 6 * C - A - 5 * T, 5)):
        C, A = counts(g, s, n, 155)
        print('   %s on [%d, %d): %d (stated %d)' % (name, s, s + n, f(C, A, n), want))
    print('3. The single seed.')
    T = 1 << 16
    lo = -T - 8
    cur = 1 << (0 - lo)
    cols = {j: [] for j in range(-3, 5)}
    for t in range(T + 1):
        for j in cols:
            cols[j].append((cur >> (j - lo)) & 1)
        cur = (cur << 1) ^ (cur | (cur >> 1))           # bit b is cell lo + b; the left neighbour is bit b - 1
    assert [cols[0][t] for t in range(8)] == [1, 1, 0, 1, 1, 1, 0, 0], 'the centre column must start 1,1,0,1,1,1,0,0'
    for j in range(-3, 4):
        worst = {False: None, True: None}
        for high in (False, True):
            p = 10 if high else 4
            d = [abs(j)]
            while d[-1] <= T:
                d.append(2 * d[-1] + abs(j) + 2 * p + 3)
            C = A = 0; k = 0; ok = True; least_gap = None
            for n in range(1, T + 1):
                C += cols[j][n - 1]; A += cols[j][n - 1] & (1 - cols[j + 1][n - 1])
                while k + 1 < len(d) and d[k + 1] <= n:
                    k += 1
                if n >= d[0]:
                    deficit = (6 * n + 3 * A - 8 * C) if high else (2 * n + 7 * A - 5 * C)
                    bound = k - (6 if high else 4)
                    ok &= deficit >= bound
                    gap = deficit - bound
                    least_gap = gap if least_gap is None else min(least_gap, gap)
            worst[high] = (ok, least_gap, deficit)
        print('   site %2d: C/T = %.4f, A/T = %.4f at T = 2^16; margin 3/4: holds %s (least slack %d, deficit at the end %d); '
              'margin 9/10: holds %s (least slack %d, deficit at the end %d)'
              % (j, C / T, A / T, worst[False][0], worst[False][1], worst[False][2], worst[True][0], worst[True][1], worst[True][2]))
    print('4. Corners, facets and multipliers.')
    V = [(1, 0, 0), (3, 1, 0), (4, 3, 1), (10, 9, 4), (1, 1, 1)]                       # (T, C, A)
    facets = {'A >= 0': lambda T, C, A: A, '3C <= T + 5A': lambda T, C, A: T + 5 * A - 3 * C,
              '2C <= T + 2A': lambda T, C, A: T + 2 * A - 2 * C, '6C <= 5T + A': lambda T, C, A: 5 * T + A - 6 * C,
              'A <= C': lambda T, C, A: C - A}
    for v in V:
        print('   corner (T, C, A) = %s: tight on %s; every facet holds: %s'
              % (v, [n for n, f in facets.items() if f(*v) == 0], all(f(*v) >= 0 for f in facets.values())))
    bad = 0; n = 0
    R = range(-12, 13)
    for al in R:
        for be in R:
            for ga in R:
                at = ga >= 0 and al <= 3 * ga and 3 * al + be <= 4 * ga and 9 * al + 4 * be <= 10 * ga and al + be <= ga
                if not at:
                    continue
                n += 1
                if al + be >= 0:
                    if al + 6 * be <= 0:
                        mult = (10, {'2C <= T + 2A': -al - 6 * be, '6C <= 5T + A': 2 * (al + be)}, 10 * ga - (9 * al + 4 * be))
                    else:
                        mult = (5, {'6C <= 5T + A': al + be, 'A <= C': al + 6 * be}, 5 * (ga - (al + be)))
                elif 5 * al + 3 * be >= 0:
                    mult = (4, {'3C <= T + 5A': -2 * (al + be), '2C <= T + 2A': 5 * al + 3 * be}, 4 * ga - (3 * al + be))
                elif al >= 0:
                    mult = (3, {'A >= 0': -5 * al - 3 * be, '3C <= T + 5A': al}, 3 * ga - al)
                else:
                    mult = (1, {'A >= 0': -al - be, 'A <= C': -al}, ga)
                d, lam, slackT = mult
                if any(x < 0 for x in lam.values()) or slackT < 0:
                    bad += 1; continue
                # the identity d*(gamma*T - alpha*C - beta*A) = sum lam_f * f(T, C, A) + slackT * T, on a few points
                for (T_, C_, A_) in ((7, 3, 2), (11, 5, 0), (2, 9, 4), (13, 1, 1)):
                    lhs = d * (ga * T_ - al * C_ - be * A_)
                    rhs = sum(l * facets[f](T_, C_, A_) for f, l in lam.items()) + slackT * T_
                    if lhs != rhs:
                        bad += 1
    print('   %d integer triples (alpha, beta, gamma) in [-12, 12]^3 hold at the corners; the multipliers of '
          'Rule30DensityPolygon.lean are nonnegative and give the identity for every one: %s' % (n, bad == 0))


if __name__ == '__main__':
    main()
