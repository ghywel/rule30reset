"""The configuration torus of half-circle codings at the golden and silver angles (claudeIntel, N9).

Setting (N8). c(t) = floor(x0 + t*g) mod 2 with g = sqrt5 - 1 (golden) or 2 - sqrt2 (silver); Z[g] = Z[sqrt d].
At a lag q with P = round(q*g) even and eps = q*g - P, time t is a mismatch iff w = x0 + t*g - m lies in
I_eps = [-eps, 0) (eps > 0) or [0, -eps) (eps < 0) for some integer m. Write lam = t*g - m = a + b*sqrt(d), so
w = x0 + lam and t = (lam - lam')/Delta, Delta = g - g'.

The torus. Put the phase's configuration as the affine lattice {(x0 + lam', x0 + lam)} = M + (x0, x0) in R^2,
M = {(lam', lam)} the Minkowski lattice, with time t = (W - W')/Delta for a point (W', W). In coordinates
theta with (W', W) = theta1*(1, 1) + theta2*(-sqrt d, sqrt d), the phase x0 is theta = (x0, 0) mod Z^2.
The norm-one unit u^2 (golden 9 - 4 sqrt5, silver 3 - 2 sqrt2) carries scale n to scale n + 1: internal
coordinates are divided by u^2, physical ones by u'^2, so the scale-n configuration is D^n (x0, 0) mod Z^2 with
D = [[9, 20], [4, 9]] (golden) or [[3, 4], [2, 3]] (silver). Exactly, t = (u^{2n} W - u'^{2n} W')/Delta, so in the
limit the normalised time is tau = -W'/Delta and the normalised excess of a run is tau2 - 2*tau1 - tau_q.

f(theta) is the largest normalised excess over one fundamental domain of lag families (|eps| in (u^2, 1],
|N(eps)| <= 2(A+1)|Delta| by N8's norm cut, P even), as a fraction of the lag. A phase's word has excess at least
c*q - O(1) at scale n whenever f(D^n theta0) >= c. If the maximal D-invariant subset of {f <= c} is empty, every
phase is excluded by Jen's bound, with linear excess in every bounded window of scales. If it is the fixed point
0 alone, exactly the phases whose orbit tends to 0, the cut orbit x0 in Z + Z g, can pass.

Part 1 (calibration, not a test): direct integer excesses at rational phases against f at the matching torus point.
Part 2 (the frozen test): grid N x N with k x k samples per cell, a cell "passes" if a sample has f <= c; the cell
map of D is exact (integer parallelograms); iterate S <- S & succ(S) & pred(S) to the fixpoint. Floating point and
sampling: an exploratory outer approximation, not a certificate.

Predictions, frozen with this file (dilated marks: a cell passes if it or a neighbour has a passing sample):
  P1 (0.7)  golden, N = 256, c = 0.005: the fixpoint is empty.
  P2 (0.55) silver, N = 256, c = 0.005: the fixpoint is nonempty and every surviving cell lies within 8/N of 0.
  P3 (0.75) for both angles the passing fraction of cells (undilated, N = 256) lies between 0.02 and 0.4.
Secondary, reported without prediction: c = 0 and c = 0.02, and N = 128.

Usage: python claudeIntel_configuration_torus.py calibrate|run OUTFILE
"""
from fractions import Fraction as Fr
from math import isqrt, sqrt, floor, ceil
import sys
import numpy as np

ANGLES = {
    'golden': dict(d=5, g=(-1, 1), D=((9, 20), (4, 9)), u2=(9, -4), A=4),
    'silver': dict(d=2, g=(2, -1), D=((3, 4), (2, 3)), u2=(3, -2), A=2),
}
C_THRESH = 0.005


class Angle:
    def __init__(self, name):
        p = ANGLES[name]
        self.name = name
        self.d = p['d']
        self.sd = sqrt(self.d)
        self.g0, self.g1 = p['g']
        self.Delta = 2 * self.g1 * self.sd            # g - g'
        self.Dm = p['D']
        self.u2 = p['u2']
        self.u2f = self.u2[0] + self.u2[1] * self.sd
        self.A = p['A']
        self.cap = int(2 * (self.A + 1) * abs(self.Delta))
        self.families = self.make_families()

    # exact Z[sqrt d] helpers on integer pairs
    def mul(self, x, y):
        return (x[0] * y[0] + self.d * x[1] * y[1], x[0] * y[1] + x[1] * y[0])

    def val(self, x):
        return x[0] + x[1] * self.sd

    def conjval(self, x):
        return x[0] - x[1] * self.sd

    def lag_of(self, eps):
        """q and P for eps = a + b sqrt d, if eps = q g - P with q integer."""
        a, b = eps
        if b % self.g1:
            return None
        q = b // self.g1
        P = q * self.g0 - a
        return q, P

    def make_families(self):
        fams = []
        lo = self.u2f
        bmax = int(self.cap / lo / (2 * self.sd)) + 3
        for b in range(-bmax, bmax + 1):
            for a in range(floor(-1 - b * self.sd) - 1, ceil(1 - b * self.sd) + 2):
                e = a + b * self.sd
                if not (lo < abs(e) <= 1):
                    continue
                n = a * a - self.d * b * b
                if n == 0 or abs(n) > self.cap:
                    continue
                qp = self.lag_of((a, b))
                if qp is None:
                    continue
                q, P = qp
                if q < 1 or P % 2:
                    continue
                fams.append(self.family((a, b)))
        fams.sort(key=lambda f: f['tauq'])
        return fams

    def family(self, eps):
        e = self.val(eps)
        tauq = -self.conjval(eps) / self.Delta
        lo, hi = (-e, 0.0) if e > 0 else (0.0, -e)
        G = 2 * (self.A + 1) / abs(e)
        T = 2.2 * G + tauq
        return dict(eps=eps, e=e, tauq=tauq, lo=lo, hi=hi, T=T, norm=eps[0] ** 2 - self.d * eps[1] ** 2)

    def mismatch_taus(self, th1, th2, fam, kmax=6):
        """Smallest kmax normalised mismatch times tau in [0, T] for samples (th1, th2) (arrays)."""
        sd, Dl, T = self.sd, self.Delta, fam['T']
        Bs = [(Dl * tau + W) / (2 * sd) for tau in (0.0, T) for W in (-1.0, 1.0)]
        b = np.arange(floor(min(Bs)) - 2, ceil(max(Bs)) + 3, dtype=np.float64)
        B = th2[:, None] + b[None, :]
        a = np.ceil(fam['lo'] - th1[:, None] - B * sd)
        W = th1[:, None] + a + B * sd
        tau = (2 * B * sd - W) / Dl
        ok = (W < fam['hi']) & (tau >= 0) & (tau <= T)
        tm = np.where(ok, tau, np.inf)
        k = min(kmax, tm.shape[1])
        part = np.partition(tm, k - 1, axis=1)[:, :k]
        part.sort(axis=1)
        return part

    def f_family(self, th1, th2, fam):
        ts = self.mismatch_taus(th1, th2, fam)
        T, tq = fam['T'], fam['tauq']
        t1 = ts[:, 0]
        best = np.where(np.isfinite(t1), t1 - tq, T - tq)
        for i in range(ts.shape[1] - 1):
            ti, tj = ts[:, i], ts[:, i + 1]
            tj_eff = np.where(np.isfinite(tj), tj, T)
            val = np.where(np.isfinite(ti), tj_eff - 2 * ti - tq, -np.inf)
            best = np.maximum(best, val)
        return best / tq

    def f(self, th1, th2):
        out = np.full(th1.shape, -np.inf)
        for fam in self.families:
            out = np.maximum(out, self.f_family(th1, th2, fam))
        return out

    # exact orbit on the torus for rational phases
    def orbit_point(self, x0, n):
        th = (Fr(x0), Fr(0))
        (p, q), (r, s) = self.Dm
        for _ in range(n):
            th = ((p * th[0] + q * th[1]) % 1, (r * th[0] + s * th[1]) % 1)
        return th

    # direct integer words
    def word(self, x0, L):
        """c(t) = floor(x0 + t g) mod 2, t < L, for rational x0."""
        r, s = x0.numerator, x0.denominator
        out = []
        for t in range(L):
            y = s * t * self.g1
            if t == 0:
                F = 0
            elif y > 0:
                F = isqrt(self.d * y * y)
            else:
                F = -isqrt(self.d * y * y) - 1
            out.append(((r + s * t * self.g0 + F) // s) % 2)
        return out

    def direct_excess(self, w, q):
        L = len(w) - q
        mm = [t for t in range(L) if w[t] != w[t + q]]
        best = (mm[0] - 1 - q) if mm else None
        for i in range(len(mm) - 1):
            best = max(best, mm[i + 1] - 2 * mm[i] - q - 3)
        return best, mm[:3]


def lag_family_at_scale(an, q):
    """eps of lag q, its scale n and normalised representative eps * u^{-2n}, if P is even."""
    gq = q * (an.g0 + an.g1 * an.sd)
    P = round(gq)
    if P % 2:
        return None
    eps = (q * an.g0 - P, q * an.g1)
    rep, n = eps, 0
    uinv = (an.u2[0], -an.u2[1])
    while abs(an.val(rep)) <= an.u2f:
        rep, n = an.mul(rep, uinv), n + 1
    return eps, n, rep


def calibrate(out):
    for name in ('golden', 'silver'):
        an = Angle(name)
        out.append('%s: cap |N| <= %d, %d families in one fundamental domain' % (name, an.cap, len(an.families)))
        for fam in an.families:
            q, P = an.lag_of(fam['eps'])
            out.append('  eps=%s N=%d e=%.5f tau_q=%.4f q0=%d' % (fam['eps'], fam['norm'], fam['e'], fam['tauq'], q))
        for x0 in (1e-9, 1 - 1e-9, 0.5):
            v = an.f(np.array([x0]), np.array([0.0]))[0]
            out.append('  f(theta=(%.9f, 0)) = %.6f' % (x0, v))
        for x0 in (Fr(1, 3), Fr(2, 7), Fr(3, 5)):
            w = an.word(x0, 60000)
            for q in range(5, 9000):
                lf = lag_family_at_scale(an, q)
                if lf is None:
                    continue
                eps, n, rep = lf
                if abs(rep[0] ** 2 - an.d * rep[1] ** 2) > 4:
                    continue
                E, mm = an.direct_excess(w, q)
                th = an.orbit_point(x0, n)
                fam = an.family(rep)
                fv = an.f_family(np.array([float(th[0])]), np.array([float(th[1])]), fam)[0]
                out.append('  x0=%s q=%d n=%d rep=%s: direct E=%d E/q=%.4f, torus f=%.4f' % (
                    x0, q, n, rep, E, E / q, fv))


def run(out):
    for name in ('golden', 'silver'):
        an = Angle(name)
        for N in (128, 256):
            k = 3
            grid = (np.arange(N * k) + 0.5) / (N * k)
            passed = np.zeros((N, N), dtype=bool)
            fmin = np.full((N, N), np.inf)
            for i in range(N * k):
                th1 = np.full(N * k, grid[i])
                v = an.f(th1, grid)
                ci = i // k
                cell_min = v.reshape(N, k).min(axis=1)
                fmin[ci] = np.minimum(fmin[ci], cell_min)
            (p, q), (r, s) = an.Dm
            offs = cell_offsets(p, q, r, s)
            I, J = np.meshgrid(np.arange(N), np.arange(N), indexing='ij')
            out.append('%s N=%d: %d cell-map offsets' % (name, N, len(offs)))
            for cth in (C_THRESH, 0.0, 0.02):
              passed = fmin <= cth
              dil = passed.copy()
              for di in (-1, 0, 1):
                  for dj in (-1, 0, 1):
                      dil |= np.roll(np.roll(passed, di, axis=0), dj, axis=1)
              out.append(' c=%g: passing fraction %.4f (dilated %.4f)' % (cth, passed.mean(), dil.mean()))
              for label, S0 in (('undilated', passed), ('dilated', dil)):
                S = S0.copy()
                it = 0
                while True:
                    it += 1
                    succ = np.zeros_like(S)
                    pred = np.zeros_like(S)
                    for di, dj in offs:
                        ti = (p * I + q * J + di) % N
                        tj = (r * I + s * J + dj) % N
                        succ |= S[ti, tj]
                        tmp = np.zeros_like(S)
                        tmp[ti, tj] = S          # a bijection of cells, since det D = 1
                        pred |= tmp
                    Sn = S & succ & pred
                    if (Sn == S).all():
                        break
                    S = Sn
                cells = np.argwhere(S)
                dist = [max(min(c[0], N - 1 - c[0]), min(c[1], N - 1 - c[1])) for c in cells]
                out.append('  %s: fixpoint after %d sweeps: %d cells; max torus distance from 0: %s cells' % (
                    label, it, len(cells), max(dist) if dist else '-'))
                if 0 < len(cells) <= 40:
                    out.append('    cells: %s' % [tuple(int(x) for x in c) for c in cells])


def cell_offsets(p, q, r, s):
    """Cells [i,i+1]x[j,j+1] meeting the closed parallelogram spanned by (p, r) and (q, s)."""
    V = [(0, 0), (p, r), (q, s), (p + q, r + s)]
    xs = [v[0] for v in V]
    ys = [v[1] for v in V]
    axes = [(1, 0), (0, 1), (-r, p), (-s, q)]
    offs = []
    for i in range(min(xs) - 1, max(xs) + 1):
        for j in range(min(ys) - 1, max(ys) + 1):
            C = [(i, j), (i + 1, j), (i, j + 1), (i + 1, j + 1)]
            ok = True
            for ax in axes:
                pv = [ax[0] * v[0] + ax[1] * v[1] for v in V]
                pc = [ax[0] * c[0] + ax[1] * c[1] for c in C]
                if max(pv) < min(pc) or max(pc) < min(pv):
                    ok = False
                    break
            if ok:
                offs.append((i, j))
    return offs


if __name__ == '__main__':
    mode, path = sys.argv[1], sys.argv[2]
    out = []
    (calibrate if mode == 'calibrate' else run)(out)
    with open(path, 'w', newline='\n') as fh:
        fh.write('\n'.join(out) + '\n')
    print('\n'.join(out[:200]))
