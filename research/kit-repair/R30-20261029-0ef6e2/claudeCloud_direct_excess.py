#!/usr/bin/env python3
"""claudeCloud_direct_excess.py: a control of N9's torus statements that does not use the torus (ledger K72, addendum 3).

The half-circle word is c(t) = floor(x0 + t*g) mod 2, with g = sqrt(5) - 1 (golden) or g = 2 - sqrt(2) (silver).
This script computes the word itself, takes the lags of one scale from their definition, finds the mismatches
c(t) != c(t + q) by comparing the word with its shift, and measures

    R(x0, n) = max over the lags q of scale n and over their runs of (E + 3) / q,

where a run between consecutive mismatches t1 < t2 has excess E = t2 - 2*t1 - q - 3 and the prefix run, before the first
mismatch t1, has E = t1 - q - 1. N9's statements, read on R:
    golden: R(x0, n) >= 0.0999 for every phase x0 and every scale n >= 3;
    silver: for every phase off the cut orbit, R(x0, n) >= 0.0099 at infinitely many scales n.

Nothing is taken from claudeIntel's or gptIntel's scripts: not the families, not the arcs, not the function f.
  - Lags of scale n: the q >= 1 with P = round(q*g) even, |N(q*g - P)| <= cut (44 golden, 16 silver: N8's norm cut) and
    v^(n+1) < |q*g - P| <= v^n, where v = 9 - 4*sqrt(5) or 3 - 2*sqrt(2). They are found by enumerating q.
  - The word is computed in 80-bit floating point with the phase an exact multiple of 2^-60; every floor whose argument
    is within 1e-9 of an integer is redone in exact integer arithmetic. `selftest` compares this with an all-integer
    computation at rational phases.
  - Horizon: per lag, 12/|eps| + 4*q ticks. A run cut by the horizon is counted by its part inside it, so R is a lower
    bound for the true maximum.
The torus enters only to spread the phases: the phase for a target (a, b) of the unit square is the x0 in [0, 1) whose
scale-n torus point of N9, x0 * (first column of D^n) mod 1, is nearest the target.

    python3 claudeCloud_direct_excess.py selftest
    python3 claudeCloud_direct_excess.py map ANGLE N GRID [PART OF]     R on a GRID x GRID set of targets at scale N
    python3 claudeCloud_direct_excess.py zoom ANGLE N A B HALF STEPS    R on a finer square around the target (A, B)
"""
import math
import sys

import numpy as np

LD = np.longdouble
ANGLES = {
    'golden': dict(d=5, cut=44, D=((9, 20), (4, 9))),
    'silver': dict(d=2, cut=16, D=((3, 4), (2, 3))),
}


def root(d):
    return np.sqrt(LD(d))


def slope(angle):
    return root(5) - 1 if angle == 'golden' else 2 - root(2)


def unit(angle):
    return 9 - 4 * root(5) if angle == 'golden' else 3 - 2 * root(2)


def norm(angle, q, P):
    """The norm of q*g - P in Z[sqrt d], an exact integer."""
    if angle == 'golden':        # q*(sqrt5 - 1) - P = -(q + P) + q*sqrt5
        return (q + P) * (q + P) - 5 * q * q
    return (2 * q - P) * (2 * q - P) - 2 * q * q   # q*(2 - sqrt2) - P = (2q - P) - q*sqrt2


def lags(angle, n):
    """The lags of scale n, as (q, eps) with eps = q*g - P."""
    g, v, cut = slope(angle), unit(angle), ANGLES[angle]['cut']
    lo, hi = v ** (n + 1), v ** n
    delta = 2 * root(ANGLES[angle]['d'])
    qmax = int(cut / (delta * lo)) + 2
    q = np.arange(1, qmax + 1, dtype=np.int64)
    qg = q.astype(LD) * g
    P = np.rint(qg).astype(np.int64)
    eps = qg - P.astype(LD)
    N = norm(angle, q, P)
    keep = (P % 2 == 0) & (np.abs(N) <= cut) & (np.abs(eps) > lo) & (np.abs(eps) <= hi)
    return [(int(a), float(b)) for a, b in zip(q[keep], eps[keep])]


def exact_floor(angle, a60, t):
    """floor(a60/2^60 + t*g), in integers."""
    two = 1 << 60
    if angle == 'golden':        # a + t*sqrt5 - t, a = a60/2^60
        k = math.isqrt(5 * t * t)                      # floor(t*sqrt5)
        # floor(a + t*sqrt5) = k + [frac(t*sqrt5) >= 1 - a]  for 0 <= a < 1
        need = (k + 1) * two - a60                     # (k + 1 - a) * 2^60 > 0
        up = 5 * t * t * two * two >= need * need
        return k + (1 if up else 0) - t
    k = math.isqrt(2 * t * t)                          # floor(t*sqrt2); t*sqrt2 is irrational for t > 0
    # floor(a - t*sqrt2) + 2t ; a - t*sqrt2 lies in (-k-1+a, -k+a)
    if t == 0:
        return 0
    # a - t*sqrt2 >= -k  iff  a + k >= t*sqrt2  iff (a + k)^2 >= 2 t^2
    lhs = a60 + k * two
    ge = lhs * lhs >= 2 * t * t * two * two
    return (-k if ge else -k - 1) + 2 * t


def word(angle, a60, T):
    """c(0..T-1) for the phase a60/2^60."""
    g = slope(angle)
    t = np.arange(T, dtype=np.int64)
    y = LD(a60) / LD(1 << 60) + t.astype(LD) * g
    fl = np.floor(y)
    frac = y - fl
    fl = fl.astype(np.int64)
    doubt = np.nonzero((frac < 1e-9) | (frac > 1 - 1e-9))[0]
    for i in doubt:
        fl[i] = exact_floor(angle, a60, int(i))
    return (fl & 1).astype(np.uint8), len(doubt)


def best(c, lag_list):
    """max (E+3)/q over the lags and their runs; returns (ratio, q, kind, t1, t2)."""
    top = (-1e9, 0, '', 0, 0)
    for q, eps in lag_list:
        Th = min(len(c) - q, int(12 / abs(eps)) + 4 * q)
        mis = np.nonzero(c[:Th] != c[q:q + Th])[0]
        if len(mis) == 0:
            cand = [(Th - q - 1, 'prefix, cut by the horizon', 0, Th)]
        else:
            cand = [(int(mis[0]) - q - 1, 'prefix', 0, int(mis[0]))]
            if len(mis) > 1:
                E = mis[1:] - 2 * mis[:-1] - q - 3
                j = int(np.argmax(E))
                cand.append((int(E[j]), 'interior', int(mis[j]), int(mis[j + 1])))
            cand.append((Th - 2 * int(mis[-1]) - q - 3, 'last, cut by the horizon', int(mis[-1]), Th))
        E, kind, t1, t2 = max(cand)
        r = (E + 3) / q
        if r > top[0]:
            top = (r, q, kind, t1, t2)
    return top


def power_column(angle, n):
    (a, b), (c, d) = ANGLES[angle]['D']
    x, y = 1, 0
    for _ in range(n):
        x, y = a * x + b * y, c * x + d * y
    return x, y


def phase_for(angle, n, target):
    """The multiple of 2^-60 in [0, 1) whose scale-n torus point is nearest the target."""
    an, cn = power_column(angle, n)
    k = np.arange(an, dtype=np.float64)
    x0 = (target[0] + k) / an
    second = (cn * x0) % 1.0
    dist = np.abs(second - target[1])
    dist = np.minimum(dist, 1 - dist)
    j = int(np.argmin(dist))
    a60 = int(round(float(x0[j]) * (1 << 60))) % (1 << 60)
    return a60, float(dist[j])


def length_needed(lag_list):
    return max(int(12 / abs(e)) + 5 * q for q, e in lag_list) + 8


def run_targets(angle, n, targets, label):
    lag_list = lags(angle, n)
    T = length_needed(lag_list)
    out, doubts = [], 0
    for tg in targets:
        a60, miss = phase_for(angle, n, tg)
        c, nd = word(angle, a60, T)
        doubts += nd
        r, q, kind, t1, t2 = best(c, lag_list)
        out.append((r, tg, a60, q, kind, t1, t2))
    out.sort()
    rs = np.array([o[0] for o in out])
    print('%s %s scale %d: %d lags, word length %d, %d phases, %d floors redone exactly' % (
        label, angle, n, len(lag_list), T, len(out), doubts))
    print('  R: min %.5f  1%% %.5f  10%% %.5f  median %.5f  max %.5f' % (
        rs[0], np.quantile(rs, 0.01), np.quantile(rs, 0.1), np.median(rs), rs[-1]))
    for thr in (0.0099, 0.0999, 0.15, 0.2):
        print('  phases with R < %.4f: %d (%.2f%%)' % (thr, int((rs < thr).sum()), 100.0 * (rs < thr).mean()))
    for r, tg, a60, q, kind, t1, t2 in out[:5]:
        print('  low: R %.5f at target (%.4f, %.4f), x0 = %d/2^60, lag %d, %s run, t1 %d, t2 %d' % (
            r, tg[0], tg[1], a60, q, kind, t1, t2))
    return out


def selftest():
    ok = True
    # 1. lags per scale
    for angle, want in (('golden', 36), ('silver', 12)):
        for n in (1, 2, 3):
            got = len(lags(angle, n))
            print('lags %s scale %d: %d (N9 has %d families)' % (angle, n, got, want))
    # 2. the 80-bit word against an all-integer word at dyadic phases with few bits, and at phase 0
    for angle in ANGLES:
        for a60 in (0, 1 << 59, 3 << 58, 12345 << 40, (1 << 60) - 1):
            c, nd = word(angle, a60, 20000)
            ref = np.array([exact_floor(angle, a60, t) & 1 for t in range(20000)], dtype=np.uint8)
            same = bool((c == ref).all())
            ok &= same
            print('word %s x0 = %d/2^60: %s (%d floors redone)' % (angle, a60, 'agrees with integers' if same else 'DIFFERS', nd))
    # 3. known values: silver phase 0 has E = -3 on the Pell lags (so R = 0); golden phase 0 tends to 0.618; silver 1/2 to 0.561
    for angle, a60, n, note in (('silver', 0, 4, 'silver-pell: E = -3, R = 0'), ('golden', 0, 3, 'N9: 0.618'),
                                ('silver', 1 << 59, 4, 'I128/N9: 0.561'), ('silver', 1 << 58, 4, 'x0 = 1/4')):
        lag_list = lags(angle, n)
        c, nd = word(angle, a60, length_needed(lag_list))
        r, q, kind, t1, t2 = best(c, lag_list)
        print('known %s x0 = %d/2^60 scale %d: R = %.5f at lag %d, %s (%s)' % (angle, a60, n, r, q, kind, note))
    print('selftest', 'passed' if ok else 'FAILED')


def main():
    mode = sys.argv[1]
    if mode == 'selftest':
        selftest()
    elif mode == 'map':
        angle, n, G = sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
        part, of = (int(sys.argv[5]), int(sys.argv[6])) if len(sys.argv) > 6 else (0, 1)
        targets = [((i + 0.5) / G, (j + 0.5) / G) for i in range(G) for j in range(G)]
        targets = targets[part::of]
        out = run_targets(angle, n, targets, 'map %dx%d part %d of %d' % (G, G, part, of))
        if len(sys.argv) > 7:
            with open(sys.argv[7], 'w') as f:
                for r, tg, a60, q, kind, t1, t2 in sorted(out, key=lambda o: o[1]):
                    f.write('%.6f %.6f %.6f %d %d\n' % (tg[0], tg[1], r, a60, q))
    elif mode == 'zoom':
        angle, n = sys.argv[2], int(sys.argv[3])
        A, B, half, steps = float(sys.argv[4]), float(sys.argv[5]), float(sys.argv[6]), int(sys.argv[7])
        targets = [((A - half + 2 * half * i / (steps - 1)) % 1.0, (B - half + 2 * half * j / (steps - 1)) % 1.0)
                   for i in range(steps) for j in range(steps)]
        run_targets(angle, n, targets, 'zoom around (%.4f, %.4f) half-width %.4f' % (A, B, half))


if __name__ == '__main__':
    main()
