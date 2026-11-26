"""claudeIntel's independent checks for the I270 carrying read (N28). No code shared with
six_cut_controls.py or the Lean.

The coding is Lean's `arc`: letter n is true iff frac(theta + n*alpha) < gamma. A lag-q
mismatch at n means letter n+q differs from letter n. A trial at a, with S = q + E, succeeds
iff there is no mismatch in [a, 2a+S); `repeat_of_span` searches a in [H, 4H+3S]
(2a + S <= 8H + 7S).

1. All-six arithmetic: the pairs (p, q) -> (q, 6q+p), unimodularity, q <= 7p, the gear-128
   margin (6*128+16) q <= 128 Q, and opposite signs of q*alpha - p and Q*alpha - q.
2. Separation: for random arcs and phases at consecutive convergents p/q, p'/Q, no three
   lag-q mismatches lie within a span below Q.
3. The positive statement at concrete lags: if 6(H+S) < Q, some trial in range succeeds.
4. I270's boundary construction: for 3(H+S) <= Q <= 6(H+S), the arc and phase it builds
   have exactly the mismatches u, v, z in [H, z], and every trial in range fails, including
   Q = 6(H+S).
"""
import random
from decimal import Decimal, getcontext

getcontext().prec = 80
D = Decimal


def floor(x):
    return int(x // 1) if x >= 0 else -int((-x) // 1) - (0 if (-x) % 1 == 0 else 1)


def fr(x):
    return x - floor(x)


def constant_angle(d):
    """[0; d, d, d, ...] = (sqrt(d^2+4) - d)/2."""
    return ((D(d) * d + 4).sqrt() - d) / 2


def convergents(alpha, count):
    """(p, q) of the continued fraction of alpha, from 0/1."""
    out, x = [], alpha
    a0 = floor(x)
    x = x - a0
    h0, h1, k0, k1 = 1, a0, 0, 1
    out.append((h1, k1))
    for _ in range(count):
        x = 1 / x
        a = floor(x)
        x = x - a
        h0, h1 = h1, a * h1 + h0
        k0, k1 = k1, a * k1 + k0
        out.append((h1, k1))
    return out


def code(alpha, gamma, theta, n):
    return fr(theta + n * alpha) < gamma


def mismatches(alpha, gamma, theta, q, upto):
    x, letters = fr(theta), []
    for n in range(upto + q + 1):          # x = frac(theta + n alpha), kept exactly to 80 digits
        letters.append(x < gamma)
        x += alpha
        if x >= 1:
            x -= 1
    return [n for n in range(upto + 1) if letters[n + q] != letters[n]]


def method_succeeds(mis, H, S):
    ms = set(mis)
    for a in range(H, 4 * H + 3 * S + 1):
        if not any(t in ms for t in range(a, 2 * a + S)):
            return a
    return None


def all_six():
    alpha = constant_angle(6)
    assert abs(alpha * alpha + 6 * alpha - 1) < D(10) ** -70 and alpha > 0
    p, q = 1, 6
    rows = []
    for _ in range(8):
        Q = 6 * q + p
        s = p * Q - q * q
        assert s * s == 1 and q <= 7 * p and (6 * 128 + 16) * q <= 128 * Q
        assert (q * alpha - p) * (Q * alpha - q) < 0
        rows.append((p, q, Q, s))
        p, q = q, Q
    conv = [c for c in convergents(alpha, 9)[1:]]
    assert [(r[0], r[1]) for r in rows[:6]] == conv[:6], (rows[:6], conv[:6])
    print(f"1. all-six pairs {[(r[0], r[1]) for r in rows[:5]]}...: unimodular, q <= 7p, gear 128 margin, "
          f"opposite signs; they are the convergents of sqrt(10)-3")
    return alpha


def separation(rng, trials=40):
    checked = 0
    for d in (3, 5, 6, 7):
        alpha = constant_angle(d)
        conv = convergents(alpha, 7)
        for idx in range(2, 4):
            (p, q), (p2, Q) = conv[idx], conv[idx + 1]
            pairs = [(p, q, p2, Q)]
            # (p2 + k p)/(Q + k q) never straddles alpha with p/q, so Q is the largest partner of lag q
            assert (q * alpha - p) * ((Q + q) * alpha - (p2 + p)) > 0
            for (p, q, p2, Q) in pairs:
                for _ in range(trials):
                    theta, gamma = D(rng.random()), D(rng.random() * 0.98 + 0.01)
                    span = 3 * Q
                    mis = mismatches(alpha, gamma, theta, q, span)
                    for i in range(len(mis) - 2):
                        assert mis[i + 2] - mis[i] >= Q, (d, q, Q, float(theta), float(gamma), mis[i:i + 3])
                    checked += 1
    print(f"2. no three lag-q mismatches within a span below Q: {checked} random arcs and phases, "
          f"angles [0;3,3,..], [0;5,..], [0;6,..], [0;7,..] at consecutive convergents")


def positive(rng, alpha, trials=30):
    conv = convergents(alpha, 7)
    tested = 0
    for idx in range(2, 5):
        (p, q), (_, Q) = conv[idx], conv[idx + 1]
        for H in (0, 1, 3):
            top = (Q - 1) // 6 - H - q            # the largest E with 6(H+S) < Q
            for E in sorted({0, top // 2, top}):
                S = q + E
                if E < 0 or not 6 * (H + S) < Q:
                    continue
                for _ in range(trials):
                    theta, gamma = D(rng.random()), D(rng.random() * 0.98 + 0.01)
                    mis = mismatches(alpha, gamma, theta, q, 8 * H + 7 * S + 2)
                    assert method_succeeds(mis, H, S) is not None, (q, Q, H, E)
                    tested += 1
    print(f"3. at the all-six lags, whenever 6(H+S) < Q a trial in range succeeds: {tested} random arcs and phases")


def boundary(alpha, q, p, Q, p2, H, E):
    S = q + E
    assert 3 * (H + S) <= Q <= 6 * (H + S)
    delta, Delta = q * alpha - p, Q * alpha - p2
    assert delta * Delta < 0 and 0 < abs(Delta) < abs(delta) < D(1) / 2
    u, v = 2 * H + S - 1, 4 * H + 3 * S - 1
    z = u + Q
    # cut one at 0: put x_u at -(delta+Delta)/2 relative to it
    theta = fr(-(delta + Delta) / 2 - u * alpha)
    # cut two at gamma: put x_v at the centre -delta/2 of its strip
    gamma = fr(theta + v * alpha + delta / 2)
    assert 0 < gamma < 1
    mis = mismatches(alpha, gamma, theta, q, z + 1)
    inside = [n for n in mis if H <= n <= z]
    fails = method_succeeds(mis, H, S) is None
    return inside == [u, v, z] and fails, (u, v, z), inside


def boundaries(rng):
    cases = equal = 0
    # I270's equality case: all six, q = 37, Q = 228, H = 0, E = 1
    alpha6 = constant_angle(6)
    ok, uvz, inside = boundary(alpha6, 37, 6, 228, 37, 0, 1)
    assert ok, inside
    print(f"4. all six, q=37, Q=228, H=0, E=1 (Q = 6(H+S)): mismatches in [H,z] exactly {inside}; every trial fails")
    for d in range(3, 10):
        alpha = constant_angle(d)
        conv = convergents(alpha, 7)
        for idx in range(2, 5):
            (p, q), (p2, Q) = conv[idx], conv[idx + 1]
            for H in range(0, 6):
                for E in range(0, 60):
                    S = q + E
                    if 3 * (H + S) <= Q <= 6 * (H + S):
                        if rng.random() < 0.5 and not Q == 6 * (H + S):
                            continue
                        ok, uvz, inside = boundary(alpha, q, p, Q, p2, H, E)
                        assert ok, (d, q, Q, H, E, uvz, inside)
                        cases += 1
                        equal += Q == 6 * (H + S)
    print(f"   the construction holds in all {cases} further cases (digits 3 to 9, H up to 5), {equal} of them at Q = 6(H+S)")


if __name__ == "__main__":
    rng = random.Random(270)
    alpha6 = all_six()
    separation(rng)
    positive(rng, alpha6)
    boundaries(rng)
    print("all checks pass")
