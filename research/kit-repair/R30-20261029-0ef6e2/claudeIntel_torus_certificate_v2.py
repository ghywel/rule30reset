"""Interval certificate v2 for the configuration torus (claudeIntel, N9 addendum 3).

v1 (claudeIntel_torus_certificate.py, 0e6032b6...) split every ambiguous point independently, which admits status
patterns that no point of the cell realises. Its golden failures and silver far survivors are of that kind: in the
failing golden cell at (0.99805, 0.20605) the sampled f is 0.171 to 0.395 while v1 gives 0.034.

v2 resolves the W-ambiguity exactly. Every point has W = s + c with s = theta1 + theta2 sqrt d and c = a + b sqrt d.
So a point changes status only where s crosses lo - c or hi - c. These thresholds lie in Z[sqrt d] and are compared
exactly as integer pairs. The thresholds of all families together cut the cell into slabs on which every W-status of
every family is constant; it is read at the slab's midpoint (distinct thresholds differ by more than 1e-6 here). The
bound is the minimum over slabs of the maximum over families, since different families dominate on the two sides of
an exact-hit line (W = 0 is an end of every family's arc). Points whose tau-range meets the time origin or the window
end are still split both ways. A run's value is bounded at the cell's corners, as in v1.

Everything else is as in v1: the frozen families of claudeIntel_configuration_torus.py, the margins (W 1e-9,
tau 1e-6, valid for n >= 3 golden and n >= 4 silver), the 256 x 256 grid, golden splitting to depth 3, silver
fixpoint under the exact cell map. v1's bound is used first; v2 runs only on cells v1 leaves below threshold.

Predictions, frozen with this file:
  V1 (0.8)  golden: every cell is certified with f_lo >= 0.1 within three splittings.
  V2 (0.6)  silver, c = 0.01: the fixpoint is nonempty, every survivor lies within 12 cells of 0, and the survivors
            fit in a box of half-width rho with 8 rho < 1 (so the local hyperbolicity step applies).

Usage: python claudeIntel_torus_certificate_v2.py OUTFILE
"""
import sys
from itertools import product
from math import floor, ceil
import numpy as np

import claudeIntel_configuration_torus as base
import claudeIntel_torus_certificate as v1

MW, MT = v1.MW, v1.MT
TAU_AMB_MAX = 4
N, DEPTH = v1.N, v1.DEPTH
C_GOLD, C_SILVER = v1.C_GOLD, v1.C_SILVER


def ends(an, fam):
    """lo and hi of I_eps as exact pairs."""
    a, b = fam['eps']
    neg = (-a, -b)
    return (neg, (0, 0)) if fam['e'] > 0 else ((0, 0), neg)


def cell_points2(an, fam, x0, x1, y0, y1):
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
            w_in = (Wlo > fam['lo'] + MW) and (Whi < fam['hi'] - MW)
            t_in = tlo > MT and thi < T
            out.append(dict(tlo=tlo, thi=thi, cs=cs, w_in=w_in, t_in=t_in, a=aa, b=bb))
    return out


def runs_bound(fam, mm):
    T, tq = fam['T'], fam['tauq']
    mm = sorted(mm, key=lambda p: p['tlo'])
    best = (max(mm[0]['tlo'], 0.0) - tq) if mm else (T - tq)
    if all(B['tlo'] > A['thi'] for A, B in zip(mm, mm[1:])):
        for A, B in zip(mm, mm[1:]):
            best = max(best, min(cb - 2 * ca for ca, cb in zip(A['cs'], B['cs'])) - tq)
    return best


def thresholds(an, fam, pts, s_lo, s_hi):
    lo, hi = ends(an, fam)
    thr = set()
    for p in pts:
        if p['w_in']:
            continue
        for e in (lo, hi):
            t = (e[0] - p['a'], e[1] - p['b'])
            if s_lo < t[0] + t[1] * an.sd < s_hi:
                thr.add(t)
    return thr


def slab_family_bound(an, fam, pts, mid):
    """Bound for one family on the slab containing s = mid (W-statuses fixed there)."""
    sd = an.sd
    fixed, split = [], []
    for p in pts:
        if p['w_in']:
            status = True
        else:
            W = mid + p['a'] + p['b'] * sd
            if min(abs(W - fam['lo']), abs(W - fam['hi'])) < 1e-7:
                split.append(p)              # within rounding of an end: keep both statuses
                continue
            status = fam['lo'] <= W < fam['hi']
        if not status:
            continue
        (fixed if p['t_in'] else split).append(p)
    if len(split) > TAU_AMB_MAX:
        return -np.inf
    worst = np.inf
    for choice in product((False, True), repeat=len(split)):
        mm = fixed + [p for p, ch in zip(split, choice) if ch]
        worst = min(worst, runs_bound(fam, mm))
    return worst / fam['tauq']


def f_lo2(an, x0, x1, y0, y1, early):
    """min over slabs (thresholds of all families together) of max over families."""
    best = v1.f_lo(an, x0, x1, y0, y1, early=early)
    if best >= early:
        return best
    s_lo, s_hi = x0 + y0 * an.sd, x1 + y1 * an.sd
    data = [(fam, cell_points2(an, fam, x0, x1, y0, y1)) for fam in an.families]
    thr = set()
    for fam, pts in data:
        thr |= thresholds(an, fam, pts, s_lo, s_hi)
    edges = [s_lo] + sorted(t[0] + t[1] * an.sd for t in thr) + [s_hi]
    worst = np.inf
    for k in range(len(edges) - 1):
        mid = (edges[k] + edges[k + 1]) / 2
        b = -np.inf
        for fam, pts in data:
            b = max(b, slab_family_bound(an, fam, pts, mid))
            if b >= early:
                break
        worst = min(worst, b)
    return max(best, worst)


def certify_golden(out):
    an = base.Angle('golden')
    split, fails, lows = 0, [], []
    stack = [(i / N, (i + 1) / N, j / N, (j + 1) / N, 0) for i in range(N) for j in range(N)]
    while stack:
        x0, x1, y0, y1, dep = stack.pop()
        v = f_lo2(an, x0, x1, y0, y1, early=C_GOLD)
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
    if fails:
        out.append('  smallest failing bound: %.4f' % min(f[3] for f in fails))
    for f in fails[:40]:
        out.append('  failure: cell at theta=(%.6f, %.6f), depth %d, f_lo=%.4f' % f)


def certify_silver(out):
    an = base.Angle('silver')
    S0 = np.zeros((N, N), dtype=bool)
    for i in range(N):
        for j in range(N):
            S0[i, j] = f_lo2(an, i / N, (i + 1) / N, j / N, (j + 1) / N, early=C_SILVER + 1e-12) <= C_SILVER
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
    if dist:
        rho = (max(dist) + 1) / N
        out.append('  fixpoint after %d sweeps: %d cells, max distance from 0: %d cells; box half-width %.4f, '
                   '8*rho = %.3f' % (sweeps, len(cells), max(dist), rho, 8 * rho))
    else:
        out.append('  fixpoint after %d sweeps: empty' % sweeps)
    out.append('  cells: %s' % cells[:80])


if __name__ == '__main__':
    out = []
    certify_silver(out)
    certify_golden(out)
    with open(sys.argv[1], 'w', newline='\n') as fh:
        fh.write('\n'.join(out) + '\n')
    print('\n'.join(out))
