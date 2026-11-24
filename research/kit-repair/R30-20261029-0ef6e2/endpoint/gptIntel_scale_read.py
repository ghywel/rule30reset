"""Check the Farey carry on every intercept cell of finite quadratic rotation orbits."""

import json
from collections import Counter
from math import isqrt

import numpy as np


def quadratic_floor(a, b, radicand, divisor, n):
    """floor(n*(a+b*sqrt(radicand))/divisor), including negative n and b."""
    v = b * n
    root = isqrt(v * v * radicand)
    term = root if v >= 0 else -root - 1
    return (n * a + term) // divisor


def scales(floor, limit):
    low, high = (floor(1), 1), (floor(1) + 1, 1)
    previous = None
    result = []
    while max(low[1], high[1]) <= limit:
        p, q = low[0] + high[0], low[1] + high[1]
        if p <= floor(q):
            kept, replaced, low = high, low, (p, q)
        else:
            kept, replaced, high = low, high, (p, q)
        if previous is not None and previous[1] != kept:
            result.append(previous)
        previous = replaced, kept
    return result


def measure(params, limit=255):
    def floor(n):
        return quadratic_floor(*params, n)

    sequence = scales(floor, limit)
    horizon = max(r + 2 * d for (_, r), (_, d) in sequence)
    # Every possible vector of floors through the horizon occurs at the LEFT
    # endpoint of one of these intercept intervals, theta = {-j*alpha}.
    g = np.array([floor(t) for t in range(-horizon, horizon + 1)])
    counts = Counter()
    for j in range(horizon + 1):
        f = g[horizon - j : 2 * horizon - j + 1] - floor(-j)
        past = []
        for (x, r), (u, d) in sequence:
            D = r + d
            assert abs(x * d - u * r) == 1
            assert (g[horizon + d + 1 : horizon + d + D] - g[horizon + 1 : horizon + D] == u).all()
            failures = np.flatnonzero(f[d + 1 : 2 * d] - f[1:d] != u) + 1
            assert len(failures) <= 1
            m = int(failures[0]) if len(failures) else None
            hits = np.flatnonzero(f[d + 1 : d + D] - f[1:D] != u) + 1
            assert (np.diff(hits) >= D).all()
            if m is not None and past and past[-1][2] is not None:
                old_r, old_d, old_m = past[-1]
                assert m == old_m + old_d and m > old_d
                counts['lower carries' if u <= floor(d) else 'upper carries'] += 1
                if len(past) >= 2 and past[-2][2] is not None:
                    r0, d0, m0 = past[-2]
                    if 2*m0 > r0 and 2*old_m > old_r and 2*m > r:
                        assert old_r == r0 + 2*d0 and 2*old_m - old_r == 2*m0 - r0
                        counts['three positive failures'] += 1
            past.append((r, d, m))
    return {'slope': params, 'intercept_cells': horizon + 1, 'scales': len(sequence), **counts}


def half_arc(params, limit=10000):
    def floor(n):
        return quadratic_floor(*params, n)

    result = []
    for (_, r), (u, d) in scales(floor, limit):
        def shifted(t):
            return (floor(2*t) + 1) // 2

        m = next((t for t in range(1, d) if shifted(t+d) != shifted(t)+u), None)
        result.append([r, d, None if m is None else 2*m-r])
    return result


if __name__ == '__main__':
    slopes = [(0, 1, 2, 2), (-1, 1, 2, 1), (1, -1, 2, 1), (-1, 1, 5, 2),
              (1, -1, 5, 2), (1, 1, 13, 2), (-1, -1, 13, 2)]
    rows = [measure(s) for s in slopes]
    for key in ('lower carries', 'upper carries', 'three positive failures'):
        assert sum(row.get(key, 0) for row in rows) > 0
    print(json.dumps({'controls': rows, 'half_arc': {str(s): half_arc(s) for s in slopes[:2]}}, indent=2))
