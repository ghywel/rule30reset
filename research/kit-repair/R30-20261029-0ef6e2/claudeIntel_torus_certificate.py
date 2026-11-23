"""Interval certificate for the configuration torus (claudeIntel, N9 addendum 2).

The torus, the families and the function f are those of claudeIntel_configuration_torus.py (frozen, 7089d08b...),
imported unchanged. Here f is bounded below on whole cells instead of sampled.

Cells. For a cell [x0, x1] x [y0, y1] in theta, a lattice point (a, b) has
  W   = theta1 + a + (theta2 + b) sqrt d                (increasing in both coordinates)
  tau = ((theta2 + b) sqrt d - theta1 - a) / Delta      (affine)
A point is a possible mismatch of a family if its W-range meets [lo, hi] and tau >= -MT somewhere; it is certain
if its W-range lies in (lo + MW, hi - MW) and tau > MT on the whole cell; otherwise it is ambiguous.

Finite scales. At scale n the exact normalised time is tau + v^{2n} W / Delta, and (E + 3)/q differs from the limit
by a relative O(v^{2n}). MT = 1e-6 absorbs the time shift for n >= 3 (golden) and n >= 4 (silver). MW = 1e-9 covers
floating error in W, whose test is exact at every scale.

Lower bound on a cell. For each family, every assignment of the ambiguous points (at most AMB of them) gives a set of
mismatches. Its runs are bounded below exactly: the prefix by min tau of the first mismatch, an interior run between
neighbours A, B (tau-ranges disjoint) by the minimum over the corners of tau_B - 2 tau_A - tau_q. The family's bound is
the minimum over assignments of the best run. f_lo = max over families / tau_q <= f on the whole cell, both one-sided
conventions included. With more than AMB ambiguous points the family gives no bound.

Golden: every cell of the 256 x 256 grid must reach f_lo >= C_GOLD, splitting a failing cell into four up to DEPTH
times. Silver: cells with f_lo <= C_SILVER on the 256 x 256 grid; the exact cell map of D; the fixpoint of
S <- S & succ(S) & pred(S).

Predictions, frozen with this file:
  C1 (0.75) golden: every cell is certified with f_lo >= 0.1 within DEPTH = 3 splittings.
  C2 (0.65) silver: the fixpoint is nonempty and every surviving cell lies within 2 cells of 0.
  C3 (0.9)  the parity of P is preserved along every family for 6 scales (P even at each member).

Usage: python claudeIntel_torus_certificate.py OUTFILE
"""
import sys
from itertools import product
from math import floor, ceil
import numpy as np

import claudeIntel_configuration_torus as base

MW = 1e-9
MT = 1e-6
AMB = 4
C_GOLD = 0.1
C_SILVER = 0.01
DEPTH = 3
N = 256


def cell_points(an, fam, x0, x1, y0, y1):
    """Possible mismatch points of a family on one cell: (tlo, thi, certain, corners)."""
    sd, Dl, T = an.sd, an.Delta, fam['T']
    Bs = [(Dl * tau + W) / (2 * sd) for tau in (0.0, T) for W in (-1.0, 1.0)]
    out = []
    for bb in range(floor(min(Bs) - y1) - 3, ceil(max(Bs) - y0) + 4):
        amin = ceil(fam['lo'] - x1 - (y1 + bb) * sd - MW)
        amax = floor(fam['hi'] - x0 - (y0 + bb) * sd + MW)
        for aa in range(amin, amax + 1):
            Wlo = x0 + aa + (y0 + bb) * sd
            Whi = x1 + aa + (y1 + bb) * sd
            if Whi < fam['lo'] - MW or Wlo > fam['hi'] + MW:
                continue
            cs = tuple(((y + bb) * sd - x - aa) / Dl for x in (x0, x1) for y in (y0, y1))
            tlo, thi = min(cs), max(cs)
            if thi < -MT or tlo > T:
                continue
            cert = (Wlo > fam['lo'] + MW) and (Whi < fam['hi'] - MW) and tlo > MT and thi < T
            out.append((tlo, thi, cert, cs))
    return out


def family_bound(fam, pts):
    T, tq = fam['T'], fam['tauq']
    amb = [p for p in pts if not p[2]]
    cert = [p for p in pts if p[2]]
    if len(amb) > AMB:
        return -np.inf
    worst = np.inf
    for choice in product((False, True), repeat=len(amb)):
        mm = sorted(cert + [p for p, c in zip(amb, choice) if c], key=lambda p: p[0])
        best = (max(mm[0][0], 0.0) - tq) if mm else (T - tq)
        if all(B[0] > A[1] for A, B in zip(mm, mm[1:])):      # the order of the mismatches is fixed on the cell
            for A, B in zip(mm, mm[1:]):
                v = min(cb - 2 * ca for ca, cb in zip(A[3], B[3])) - tq
                best = max(best, v)
        worst = min(worst, best)
    return worst / tq


def f_lo(an, x0, x1, y0, y1, early=None):
    best = -np.inf
    for fam in an.families:
        best = max(best, family_bound(fam, cell_points(an, fam, x0, x1, y0, y1)))
        if early is not None and best >= early:
            break
    return best


def certify_golden(out):
    an = base.Angle('golden')
    worst, split, fails = np.inf, 0, []
    stack = [(i / N, (i + 1) / N, j / N, (j + 1) / N, 0) for i in range(N) for j in range(N)]
    while stack:
        x0, x1, y0, y1, dep = stack.pop()
        v = f_lo(an, x0, x1, y0, y1, early=C_GOLD)
        if v >= C_GOLD:
            continue
        if dep == DEPTH:
            fails.append((x0, y0, dep, v))
            continue
        split += 1
        xm, ym = (x0 + x1) / 2, (y0 + y1) / 2
        stack += [(x0, xm, y0, ym, dep + 1), (xm, x1, y0, ym, dep + 1),
                  (x0, xm, ym, y1, dep + 1), (xm, x1, ym, y1, dep + 1)]
    out.append('golden: %d x %d cells, certified f_lo >= %g; %d cells split; %d failures' % (
        N, N, C_GOLD, split, len(fails)))
    for f in fails[:40]:
        out.append('  failure: cell at theta=(%.6f, %.6f), depth %d, f_lo=%.4f' % f)


def certify_silver(out):
    an = base.Angle('silver')
    flo = np.empty((N, N))
    for i in range(N):
        for j in range(N):
            flo[i, j] = f_lo(an, i / N, (i + 1) / N, j / N, (j + 1) / N, early=C_SILVER + 1e-12)
    S0 = flo <= C_SILVER
    (p, q), (r, s) = an.Dm
    offs = base.cell_offsets(p, q, r, s)
    I, J = np.meshgrid(np.arange(N), np.arange(N), indexing='ij')
    maps = [((p * I + q * J + di) % N, (r * I + s * J + dj) % N) for di, dj in offs]
    S, sweeps = S0.copy(), 0
    while True:
        sweeps += 1
        succ = np.zeros_like(S)
        pred = np.zeros_like(S)
        for ti, tj in maps:
            succ |= S[ti, tj]
            tmp = np.zeros_like(S)
            tmp[ti, tj] = S
            pred |= tmp
        Sn = S & succ & pred
        if (Sn == S).all():
            break
        S = Sn
    cells = [tuple(int(x) for x in c) for c in np.argwhere(S)]
    dist = [max(min(a, N - 1 - a), min(b, N - 1 - b)) for a, b in cells]
    out.append('silver: %d x %d cells, possibly passing (f_lo <= %g): %d (fraction %.4f)' % (
        N, N, C_SILVER, int(S0.sum()), S0.mean()))
    out.append('  fixpoint after %d sweeps: %d cells, max distance from 0: %s cells' % (
        sweeps, len(cells), max(dist) if dist else '-'))
    out.append('  cells: %s' % cells[:60])


def check_parity(out):
    for name in ('golden', 'silver'):
        an = base.Angle(name)
        bad = 0
        for fam in an.families:
            e = fam['eps']
            for _ in range(6):
                e = an.mul(e, an.u2)
                q, P = an.lag_of(e)
                if q < 1 or P % 2:
                    bad += 1
        out.append('%s: %d families x 6 scales, members with q < 1 or P odd: %d' % (name, len(an.families), bad))


if __name__ == '__main__':
    out = []
    check_parity(out)
    certify_silver(out)
    certify_golden(out)
    with open(sys.argv[1], 'w', newline='\n') as fh:
        fh.write('\n'.join(out) + '\n')
    print('\n'.join(out))
