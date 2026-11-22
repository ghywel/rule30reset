"""Exact endpoint and finite-prefix controls for the phase-zero G143 word.

Run with Python 3. The unbounded argument is in the accompanying hand proof.
"""

from math import isqrt


def silver_bit(t):
    # floor(t*(2-sqrt(2))) has the parity of ceil(t*sqrt(2)).
    return (isqrt(2 * t * t) + (t > 0)) % 2


def check_prefix(q, p, next_q):
    """Enumerate every completed run up to 4*next_q, including the origin."""
    matches = []
    start = None
    for t in range(4 * next_q + 1):
        if silver_bit(t) == silver_bit(t + q):
            if start is None:
                start = t
        elif start is not None:
            matches.append((start, t - 1))
            start = None
    assert (p + 1, next_q - 1) in matches
    best = max(b - 2 * a - q for a, b in matches)
    winners = [(a, b) for a, b in matches if b - 2 * a - q == best]
    expected = [(p + 1, next_q - 1)]
    if q == 1:
        expected = [(0, 0)]
    elif q == 7:
        expected.insert(0, (0, 4))
    assert winners == expected, (q, winners)
    assert best == (-1 if q == 1 else -3), (q, best)
    return best


if __name__ == "__main__":
    q, p = 1, 1
    for n in range(1, 129):
        next_q, next_p = q + 2 * p, q + p
        a, b = p + 1, next_q - 1
        for t, agree in [(a - 1, False), (a, True), (b, True), (b + 1, False)]:
            assert (silver_bit(t) == silver_bit(t + q)) == agree, (n, t)
        assert b - a + 1 == a + q - 2
        if q <= 47321:
            best = check_prefix(q, p, next_q)
            print(f"lag {q}: [{a}, {b}], best completed excess {best}")
        q, p = next_q, next_p
    print("Exact flanks and slack checked at both parities through exponent 128.")
