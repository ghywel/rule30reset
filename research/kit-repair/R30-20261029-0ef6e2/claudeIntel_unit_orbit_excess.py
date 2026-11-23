"""Exact excess along unit orbits for half-circle codings at quadratic phases (claudeIntel, N8).

The half-circle coding of the rotation by alpha at phase theta is c(t) = floor(x0 + t*g) mod 2, with x0 = 2*theta and
g = 2*alpha: golden g = sqrt5 - 1, silver g = 2 - sqrt2. Phases are x0 = (a + b*sqrt d)/4, so xi = (x0 - x0')/D lies
in (-1, 0], where D = g - g'. At a lag q put P = round(q*g) and eps = q*g - P. When P is even, t is a mismatch exactly
when the segment from x0 + t*g to x0 + t*g + eps crosses an integer m; record w = x0 + t*g - m.

N8's identity. For consecutive crossings w1 (time t1) and w2 (time t2) the run [t1+1, t2-1] has excess
E = t2 - 2*t1 - q - 3. With z = w2 - 2*w1 - eps,
    E + 3 = z/D - z'/D + xi.
The prefix run [0, t2-1] has E + 1 = z0/D - z0'/D - xi, with z0 = w2 - eps. A unit k = 1 mod 4 with 0 < k < 1 and
k' = 1/k preserves x0 + Z[g] and multiplies every w and eps by k. So along the orbit, z/D is multiplied by k^s and
Phi = -z'/D by k^-s. A crossing is eventually at positive time iff u = -w'/D > 0, and order is kept.

Part 1 checks at s = 1, by direct integer evaluation, that the crossing set at the transported lag is exactly the
image of the base crossing set, and that every predicted excess is that integer.
Part 2 classifies each phase over one fundamental domain of lags [30, k^-1 * 31], keeping the orbits with P even and
|N(eps)| <= 2(A+1)|D| (A = largest partial quotient of g mod 1; a run of length l misses an arc of length |eps| only if
l < 2(A+1)/|eps|). JEN if some family has Phi > 0 (excess tends to infinity along its orbit); otherwise a survivor
candidate (every relevant family has Phi < 0, so the excess tends to minus infinity on every relevant lag).

Predictions, frozen with this file:
  P1 (0.97) Part 1 passes for all 30 phases.
  P2 (0.95) No family at these 30 off-orbit phases has Phi = 0.
  P3 (0.95) The silver phase x0 = 1/2 (I128's quarter phase) is JEN.
  P4 (0.6)  At least one of the other 29 phases is a survivor candidate.

Usage: python claudeIntel_unit_orbit_excess.py OUTFILE
"""
from fractions import Fraction as Fr
from math import ceil, isqrt, sqrt
import sys

# name, d, g = g0 + g1*sqrt(d), unit k = k0 + k1*sqrt(d) (k = 1 mod 4, 0 < k < 1, norm 1), A
ANGLES = [
    ('golden', 5, (-1, 1), (9, -4), 4),
    ('silver', 2, (2, -1), (17, -12), 2),
]
DEN = 4
Q_LO = 30
PART1_LAGS = 3
PART1_FAMILIES = 7


class Field:
    """Q(sqrt d) with elements (r, s) = r + s*sqrt(d), r and s Fractions."""

    def __init__(self, d):
        self.d = d

    def add(self, x, y):
        return (x[0] + y[0], x[1] + y[1])

    def sub(self, x, y):
        return (x[0] - y[0], x[1] - y[1])

    def mul(self, x, y):
        return (x[0] * y[0] + self.d * x[1] * y[1], x[0] * y[1] + x[1] * y[0])

    def conj(self, x):
        return (x[0], -x[1])

    def scale(self, c, x):
        return (c * x[0], c * x[1])

    def div(self, x, y):
        n = y[0] * y[0] - self.d * y[1] * y[1]
        num = self.mul(x, self.conj(y))
        return (Fr(num[0]) / n, Fr(num[1]) / n)

    def sign(self, x):
        r, s = x
        if s == 0:
            return (r > 0) - (r < 0)
        if r == 0:
            return (s > 0) - (s < 0)
        if (r > 0) == (s > 0):
            return 1 if r > 0 else -1
        r_wins = r * r > self.d * s * s
        if r > 0:
            return 1 if r_wins else -1
        return -1 if r_wins else 1

    def val(self, x):
        return float(x[0]) + float(x[1]) * sqrt(self.d)


def floor_q(R, S, d, den):
    """floor((R + S*sqrt d)/den) for integers, d not a square, den > 0."""
    if S > 0:
        f = isqrt(S * S * d)
    elif S < 0:
        f = -isqrt(S * S * d) - 1
    else:
        f = 0
    return (R + f) // den


class Word:
    def __init__(self, ang, a, b):
        self.name, self.d, (self.g0, self.g1), (k0, k1), self.A = ang
        self.a, self.b = a, b
        self.f = Field(self.d)
        self.k = (Fr(k0), Fr(k1))
        self.tau = 1 / self.f.val(self.k)
        self.D = (Fr(0), Fr(2 * self.g1))
        self.x0 = (Fr(a, DEN), Fr(b, DEN))
        xi = self.f.div(self.f.sub(self.x0, self.f.conj(self.x0)), self.D)
        assert xi[1] == 0
        self.xi = xi[0]
        self._lo, self._fl = 0, []

    def floor_x(self, t):
        return floor_q(self.a + DEN * t * self.g0, self.b + DEN * t * self.g1, self.d, DEN)

    def table(self, t0, t1):
        self._lo = t0
        self._fl = [self.floor_x(t) for t in range(t0, t1 + 1)]

    def F(self, t):
        return self._fl[t - self._lo]

    def lag(self, q):
        P = floor_q(2 * q * self.g0 + 1, 2 * q * self.g1, self.d, 2)
        eps = (Fr(q * self.g0 - P), Fr(q * self.g1))
        norm = (q * self.g0 - P) ** 2 - self.d * (q * self.g1) ** 2
        return P, eps, norm

    def crossings(self, q, P, eps, t0, t1):
        """All crossings at lag q for t in [t0, t1]; the floor table must cover [t0, t1 + q]."""
        up = self.f.sign(eps) > 0
        out = []
        for t in range(t0, t1 + 1):
            ft = self.F(t)
            diff = self.F(t + q) - ft - P
            if diff == 0:
                continue
            assert diff == (1 if up else -1), (self.name, self.a, self.b, q, t, diff)
            m = ft + 1 if diff == 1 else ft
            out.append((t, (Fr(self.a + DEN * t * self.g0, DEN) - m, Fr(self.b + DEN * t * self.g1, DEN))))
        return out

    def u_positive(self, w):
        return self.f.sign(self.f.scale(-1, self.f.div(self.f.conj(w), self.D))) > 0

    def families(self, q, eps, cr):
        """(kind, t1, t2, base excess, z) for the prefix and the interior runs among eventually positive crossings."""
        pos = [(t, w) for t, w in cr if self.u_positive(w)]
        fam = []
        if pos:
            t2, w2 = pos[0]
            fam.append(('prefix', None, t2, t2 - 1 - q, self.f.sub(w2, eps)))
        for (t1, w1), (t2, w2) in zip(pos, pos[1:]):
            z = self.f.sub(self.f.sub(w2, self.f.scale(2, w1)), eps)
            fam.append(('run', t1, t2, t2 - 2 * t1 - q - 3, z))
        return fam

    def rational_part(self, z):
        """(z - z')/D, which must be rational."""
        r = self.f.div(self.f.sub(z, self.f.conj(z)), self.D)
        assert r[1] == 0
        return r[0]

    def excess_from(self, kind, z):
        return self.rational_part(z) + (self.xi - 3 if kind == 'run' else -self.xi - 1)

    def phi(self, z):
        return self.f.scale(-1, self.f.div(self.f.conj(z), self.D))

    def scan_end(self, q, eps):
        return ceil(4 * (self.A + 1) / abs(self.f.val(eps))) + q + 10

    def norm_cap(self):
        return int(2 * (self.A + 1) * abs(self.f.val(self.D)))

    def domain(self):
        q_hi = ceil(self.tau * (Q_LO + 1))
        out = []
        for q in range(Q_LO, q_hi + 1):
            P, eps, norm = self.lag(q)
            if P % 2 == 0 and abs(norm) <= self.norm_cap():
                out.append((q, P, eps, norm))
        return out


def part1(word, lines):
    failures = []
    for q, P, eps, norm in word.domain()[:PART1_LAGS]:
        N = word.scan_end(q, eps)
        word.table(-3, N + q)
        base = word.crossings(q, P, eps, -3, N)
        fam = word.families(q, eps, base)
        for kind, t1, t2, E, z in fam:
            if word.excess_from(kind, z) != E:
                failures.append(f'base identity {q} {kind} {t1} {t2}')
        f = word.f
        eps_s = f.mul(word.k, eps)
        q_s, P_s = eps_s[1] / word.g1, None
        assert q_s.denominator == 1 and q_s > 0
        q_s = int(q_s)
        P_s = q_s * word.g0 - eps_s[0]
        assert P_s.denominator == 1 and P_s % 2 == 0
        images = {}
        for t, w in base:
            w_s = f.mul(word.k, w)
            t_s = (w_s[1] - word.x0[1]) / word.g1
            m_s = t_s * word.g0 - (w_s[0] - word.x0[0])
            assert t_s.denominator == 1 and m_s.denominator == 1
            images[int(t_s)] = w_s
        W = int(word.tau * (N - 3))
        word.table(0, W + q_s)
        direct = dict(word.crossings(q_s, int(P_s), eps_s, 0, W))
        expected = {t: w for t, w in images.items() if 0 <= t <= W}
        if direct != expected:
            failures.append(f'crossing set at lag {q_s} from {q}: {len(direct)} direct, {len(expected)} images')
        times = sorted(direct)
        checked = 0
        for kind, t1, t2, E, z in fam[:PART1_FAMILIES]:
            pred = word.excess_from(kind, f.mul(word.k, z))
            if pred.denominator != 1:
                failures.append(f'non-integer prediction {q} {kind}')
                continue
            if kind == 'prefix':
                actual = times[0] - 1 - q_s if times else None
            else:
                i1 = [t for t, w in images.items() if w == f.mul(word.k, dict(base)[t1])][0]
                i2 = [t for t, w in images.items() if w == f.mul(word.k, dict(base)[t2])][0]
                actual = i2 - 2 * i1 - q_s - 3 if times.index(i2) == times.index(i1) + 1 else None
            if actual != pred:
                failures.append(f'excess at lag {q_s} from {q} {kind} {t1} {t2}: predicted {pred}, direct {actual}')
            checked += 1
        lines.append(f'  part 1 lag {q} -> {q_s}: {len(base)} base crossings, {len(direct)} direct in [0, {W}], '
                     f'{checked} families checked')
    return failures


def part2(word, lines):
    best, n_pos, n_zero, n_fam, n_orb = None, 0, 0, 0, 0
    first_pos = []
    for q, P, eps, norm in word.domain():
        n_orb += 1
        N = word.scan_end(q, eps)
        word.table(0, N + q)
        for kind, t1, t2, E, z in word.families(q, eps, word.crossings(q, P, eps, 0, N)):
            n_fam += 1
            ph = word.phi(z)
            sg = word.f.sign(ph)
            v = word.f.val(ph)
            if sg == 0:
                n_zero += 1
            if sg > 0:
                n_pos += 1
                if len(first_pos) < 3:
                    first_pos.append(f'lag {q} (N = {norm}) {kind} [{"0" if t1 is None else t1 + 1}, {t2 - 1}] '
                                     f'E = {E}, Phi = {v:.4f}')
            if best is None or v > best[0]:
                best = (v, q, norm, kind, t1, t2, E)
    verdict = 'JEN' if n_pos else ('F' if n_zero else 'SURVIVOR CANDIDATE')
    v, q, norm, kind, t1, t2, E = best
    lines.append(f'  part 2: {n_orb} orbit lags, {n_fam} families, Phi > 0: {n_pos}, Phi = 0: {n_zero} -> {verdict}')
    lines.append(f'    max Phi {v:.4f} at lag {q} (N = {norm}) {kind} t1 = {t1}, t2 = {t2}, base E = {E}')
    for s in first_pos:
        lines.append(f'    first Phi > 0: {s}')
    return verdict, n_zero


def main(path):
    lines = []
    summary = []
    p1_fail, p2_zero = [], 0
    for ang in ANGLES:
        for a in range(DEN):
            for b in (range(0, -DEN, -1) if ang[2][1] > 0 else range(DEN)):
                if a == 0 and b == 0:
                    continue
                word = Word(ang, a, b)
                lines.append(f'{word.name} x0 = ({a} + {b} sqrt{word.d})/{DEN}, xi = {word.xi}, '
                             f'unit tau = {word.tau:.4f}, norm cap {word.norm_cap()}')
                fails = part1(word, lines)
                p1_fail += [f'{word.name} ({a},{b}): {s}' for s in fails]
                verdict, zero = part2(word, lines)
                p2_zero += zero
                summary.append((word.name, a, b, verdict))
    lines.append('')
    lines.append(f'P1 part 1 failures: {len(p1_fail)}')
    lines += ['  ' + s for s in p1_fail]
    lines.append(f'P2 families with Phi = 0: {p2_zero}')
    lines.append('P3 silver x0 = 1/2: ' + [v for n, a, b, v in summary if (n, a, b) == ('silver', 2, 0)][0])
    surv = [(n, a, b) for n, a, b, v in summary if v == 'SURVIVOR CANDIDATE' and (n, a, b) != ('silver', 2, 0)]
    lines.append(f'P4 survivor candidates among the other 29: {len(surv)} {surv}')
    for n in ('golden', 'silver'):
        lines.append(f'  {n}: ' + ', '.join(f'({a},{b}) {v}' for m, a, b, v in summary if m == n))
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main(sys.argv[1])
