#!/usr/bin/env python3
"""claudeCloud_m10_matrix.py: pull M10, first block (ledger K44). Which exact laws of rule 30 beside a white wall do
the barrier controls share?

SYSTEMS (depth d >= 1 counts cells away from a white wall at depth 0; a row is an int, bit d = depth d):
  r30      new(d) = x(d+1) xor (x(d) or x(d-1))                  the zero-boundary left half
  r90      new(d) = x(d+1) xor x(d-1)                            kit Rule30WallDeadlines: Q01 holds
  r150     new(d) = x(d+1) xor x(d) xor x(d-1)                   kit Rule30WallDeadlines: Q01 holds
  hybrid   new(d) = x(d+1) xor x(d-1) xor (x(d) if d odd)        kit Rule30HybridWall: immortal finite rows
  planted L = 2, 3, 4:  T = psi . r30 . psiInv                   kit Rule30PlantedSurvivor: one immortal finite row
Each is left-permutive in the deeper cell, so a row y has two predecessors, one for each value of depth 1, and each
is finite or not.

LAWS, each tested literally, on every nonzero row of width <= W and its images:
  edge      the deepest black cell moves one depth further at each tick
  finite    at age A, all four two-step predecessors of the row are finite, with the edge two cells behind
            (rule 30: kit Rule30AgeTwentyFourInverse, from age 24; age 23 is sharp)
  twin      at age A - 2, the row has a twin: another finite row of the same width and the same depth-1 cell with
            the same image two ticks later (rule 30: kit Rule30LateTwins, from tick 46)
  reset     the row at tick 0, 1 or 2 contains a word 0 1^(3m+1) 0 (rule 30: kit Rule30ResetFreeThree)
  survive   how many rows of width <= W keep depth 1 black at every even tick through 2W + 40 (Q01 itself)
  heal      a flip of free bit s is felt to a bounded depth in some contexts (rule 30: K41); for the linear systems
            the flip is one fixed pattern, and its deepest change within depth D is printed

  python3 claudeCloud_m10_matrix.py matrix W       the whole table for rows of width <= W
  python3 claudeCloud_m10_matrix.py check          controls on known facts
"""
import json
import sys

ODD = sum(1 << d for d in range(1, 4000, 2))


def step30(x):
    return ((x >> 1) ^ (x | (x << 1))) & ~1


def step90(x):
    return ((x >> 1) ^ (x << 1)) & ~1


def step150(x):
    return ((x >> 1) ^ x ^ (x << 1)) & ~1


def stepH(x):
    return ((x >> 1) ^ (x << 1) ^ (x & ODD)) & ~1


def g30(d, a, b):
    return a | b


def g90(d, a, b):
    return b


def g150(d, a, b):
    return a ^ b


def gH(d, a, b):
    return b ^ (a if d % 2 == 1 else 0)


def top(x):
    return x.bit_length() - 1


def pred(y, b, g, extra=8):
    """The predecessor of y with depth 1 equal to b: z(d+1) = y(d) xor g(d, z(d), z(d-1)). Returns (z, finite)."""
    m = max(top(y), 1)
    z = [0, b]
    for d in range(1, m + extra):
        z.append(((y >> d) & 1) ^ g(d, z[d], z[d - 1]))
    finite = z[-1] == 0 and z[-2] == 0 and z[-3] == 0
    val = sum(v << i for i, v in enumerate(z))
    return val, finite


# --- the planted survivor (kit Rule30PlantedSurvivor) ---

def stripe(k):
    return k % 2


def psi(L, x):
    """Flip every odd depth k >= 2L + 1 at which x agrees with the stripe at all depths below k. x finite."""
    p = 0
    while ((x >> (p + 1)) & 1) == stripe(p + 1):
        p += 1
        if p > top(x) + 2:          # x is finite, the stripe is not: agreement ends within two depths of the top
            break
    out = x
    k = 2 * L + 1
    while k - 1 <= p:
        out ^= 1 << k
        k += 2
    return out


def psi_inv(L, y):
    """Returns the inverse image, or None when it is the infinite stripe (y = trunc(2L - 1))."""
    x = 0
    ok = True
    for k in range(1, top(y) + 6):
        site = k % 2 == 1 and k >= 2 * L + 1
        bit = ((y >> k) & 1) ^ (1 if (site and ok) else 0)
        x |= bit << k
        ok = ok and bit == stripe(k)
    return None if ok else x


def trunc(n):
    """The stripe cut at depth n: black at the odd depths up to n."""
    return sum(1 << d for d in range(1, n + 1, 2))


def make_planted(L):
    def stepT(y):
        v = psi_inv(L, y)
        if v is None:
            return y                                  # the planted row is fixed (kit T_fixed)
        return psi(L, step30(v))

    def predT(y, b):
        """The predecessor under T with depth 1 equal to b (psi fixes depths up to 2L)."""
        v = psi_inv(L, y)
        if v is None:                                 # predecessors of the stripe under rule 30: itself, and one infinite row
            return (y, True) if b == 1 else (0, False)
        z, fin = pred(v, b, g30)
        return (psi(L, z), True) if fin else (0, False)
    return stepT, predT


def systems():
    out = {'r30': (step30, lambda y, b: pred(y, b, g30)), 'r90': (step90, lambda y, b: pred(y, b, g90)),
           'r150': (step150, lambda y, b: pred(y, b, g150)), 'hybrid': (stepH, lambda y, b: pred(y, b, gH))}
    for L in (2, 3, 4):
        out['planted%d' % L] = make_planted(L)
    return out


def has_reset(x):
    """A word 0 1^(3m+1) 0 in the row (the wall at depth 0 and everything beyond the top are white)."""
    run = 0
    for d in range(1, top(x) + 2):
        if (x >> d) & 1:
            run += 1
        else:
            if run % 3 == 1:
                return True
            run = 0
    return False


def two_step_preds(y, predf):
    out = []
    for b1 in (0, 1):
        w, f1 = predf(y, b1)
        for b0 in (0, 1):
            if not f1:
                out.append((None, False))
                continue
            out.append(predf(w, b0))
    return out


def matrix(W, ages=(23, 24, 48), twin_ticks=(46, 48)):
    res = {}
    rows = range(2, 1 << (W + 1), 2)                  # every nonzero row of width <= W
    for name, (stepf, predf) in systems().items():
        r = {'rows': len(rows)}
        edge_ok = edge_n = 0
        reset_ok = 0
        survive = 0
        fin = {A: [0, 0, 0] for A in ages}            # tested, all four finite, and with the edge two cells behind
        twin = {t: [0, 0] for t in twin_ticks}
        horizon = max(max(ages), max(twin_ticks), 2 * W + 40)
        for x in rows:
            orbit = [x]
            for _ in range(horizon):
                orbit.append(stepf(orbit[-1]))
            for t in range(horizon):
                if orbit[t]:
                    edge_n += 1
                    edge_ok += top(orbit[t + 1]) == top(orbit[t]) + 1
            reset_ok += any(has_reset(orbit[t]) for t in (0, 1, 2))
            survive += all((orbit[t] >> 1) & 1 for t in range(0, 2 * W + 41, 2))
            for A in ages:
                y = orbit[A]
                if y == 0:
                    continue
                fin[A][0] += 1
                ps = two_step_preds(y, predf)
                if all(f for _, f in ps):
                    fin[A][1] += 1
                    fin[A][2] += all(top(z) == top(y) - 2 for z, _ in ps)
            for t in twin_ticks:
                v = orbit[t - 2]
                if v == 0:
                    continue
                twin[t][0] += 1
                y = orbit[t]
                w = orbit[t - 1]
                w2, f1 = predf(y, 1 - ((w >> 1) & 1))            # the other predecessor of the image
                if f1:
                    v2, f2 = predf(w2, (v >> 1) & 1)             # same depth-1 cell as v
                    twin[t][1] += f2 and v2 != v and top(v2) == top(v)
        r['edge'] = [edge_ok, edge_n]
        r['reset'] = [reset_ok, len(rows)]
        r['survive'] = survive
        r['finite'] = fin
        r['twin'] = twin
        res[name] = r
        print('%-9s edge %d/%d  reset %d/%d  survivors through tick %d: %d' % (
            name, edge_ok, edge_n, reset_ok, len(rows), 2 * W + 40, survive))
        for A in ages:
            print('          age %2d: all four two-step predecessors finite %d/%d; with the edge two behind %d' % (
                A, fin[A][1], fin[A][0], fin[A][2]))
        for t in twin_ticks:
            print('          tick %2d: a twin exists %d/%d' % (t, twin[t][1], twin[t][0]))
        sys.stdout.flush()
    return res


def flip_reach(g, s, L=60):
    """Linear systems: the deepest depth <= 2L + 1 changed in the constrained start by flipping free bit s."""
    D = 2 * L + 1

    def row(col):
        z = {(t, 0): 0 for t in range(D + 1)}
        for t in range(D):
            z[(t, 1)] = (col >> t) & 1
        for d in range(1, D):
            for t in range(D - d):
                z[(t, d + 1)] = z[(t + 1, d)] ^ g(d, z[(t, d)], z[(t, d - 1)])
        return sum(z[(0, d)] << d for d in range(1, D + 1))
    base = sum(1 << (2 * i) for i in range(L + 1))
    return (row(base) ^ row(base ^ (1 << (2 * s + 1)))).bit_length() - 1


def check():
    ok = True
    # 1. predecessors: stepping either predecessor of an image gives the image back (all four left-permutive systems)
    for name, (stepf, predf) in systems().items():
        good = True
        for x in range(2, 1 << 11, 2):
            y = stepf(stepf(stepf(x)))
            for b in (0, 1):
                z, f = predf(y, b)
                if f:
                    good &= stepf(z) == y
            good &= any(predf(stepf(x), b) == (x, True) for b in (0, 1))
        print('1. %-9s every finite predecessor steps to its image, and each row is a predecessor of its image: %s' % (name, good))
        ok &= good
    # 2. planted: psi and psiInv are inverse; T fixes trunc(2L - 1); depth 1 of T^n y is depth 1 of rule 30 on psiInv y
    for L in (2, 3, 4):
        stepT, _ = make_planted(L)
        good = stepT(trunc(2 * L - 1)) == trunc(2 * L - 1)
        for x in range(2, 1 << 12, 2):
            good &= psi_inv(L, psi(L, x)) == x
            v = psi_inv(L, x)
            if v is not None:
                good &= psi(L, v) == x
                a, b = x, v
                for _ in range(12):
                    a, b = stepT(a), step30(b)
                    good &= ((a >> 1) & 1) == ((b >> 1) & 1)
        print('2. planted L = %d: psi inverse, the planted row fixed, depth 1 as rule 30 through psi: %s' % (L, good))
        ok &= good
    # 3. kit deadlines: rule 90 of width <= W turns depth 1 white at an even tick by kstar(W) - 1; rule 150 by 2((W+1)/2)
    def kstar(W):
        k = W + 1
        while k % 2 == 0 or k % 3 == 0:
            k += 1
        return k
    good = True
    for W in range(1, 11):
        for x in range(2, 1 << (W + 1), 2):
            if top(x) != W:
                continue
            for stepf, deadline in ((step90, kstar(W) - 1), (step150, 2 * ((W + 1) // 2))):
                y, dead = x, False
                for t in range(deadline + 1):
                    if t % 2 == 0 and not (y >> 1) & 1:
                        dead = True
                    y = stepf(y)
                good &= dead
    print('3. the kit deadlines for rules 90 and 150 hold for every row of width <= 10: %s' % good)
    ok &= good
    # 4. hybrid (kit Rule30HybridWall): the rows of width <= W that never turn depth 1 white at an even tick number
    #    2^(W/2 - 1), and the only one of width 2 or 3 has depths 1 and 2 black
    def immortal(x):
        y = x
        for t in range(300):
            if t % 2 == 0 and not (y >> 1) & 1:
                return False
            y = stepH(y)
        return True
    counts = [sum(immortal(x) for x in range(2, 1 << (W + 1), 2)) for W in (2, 3, 4, 6, 8, 10)]
    good = counts == [1, 1, 2, 4, 8, 16] and immortal(0b110)
    print('4. hybrid: immortal rows of width <= 2, 3, 4, 6, 8, 10 number %s (kit: 1, 1, 2, 4, 8, 16): %s' % (counts, good))
    ok &= good
    # 5. rule 30, kit Rule30ResetFreeThree: every nonzero row of width <= 14 shows a reset word within three rows
    good = all(any(has_reset(v) for v in (x, step30(x), step30(step30(x)))) for x in range(2, 1 << 15, 2))
    print('5. rule 30: a reset word at tick 0, 1 or 2 for every row of width <= 14: %s' % good)
    ok &= good
    print('CONTROLS:', 'PASS' if ok else 'FAIL')
    return ok


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[0] == 'check':
        sys.exit(0 if check() else 1)
    if a[0] == 'matrix':
        res = matrix(int(a[1]))
        for name, g in (('r90', g90), ('r150', g150), ('hybrid', gH)):
            res[name]['heal'] = [flip_reach(g, s) for s in range(6)]
            print('%-9s deepest change within depth 121 from a flip of free bit 0..5: %s' % (name, res[name]['heal']))
        print('JSON ' + json.dumps(res))
