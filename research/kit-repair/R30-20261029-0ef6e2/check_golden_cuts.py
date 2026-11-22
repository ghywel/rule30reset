"""Certify the two N7 examples at the preselected lag 144 of the exact golden rotation."""

from math import isqrt

from claudeIntel_near_square_followup import two_arc_cases


DEN = 2**64
LAG = 144
NEAREST_INTEGER = 89
LAST = 4095


def floor_scaled_orbit(t):
    """floor(2^64 * t * (sqrt(5)-1)/2), with integer arithmetic."""
    x = DEN * t
    return (isqrt(5 * x * x) - x) // 2


def best_run(agreements):
    """Largest excess among runs with a witnessed right flank in the supplied range."""
    start = 0
    runs = []
    for t, agrees in enumerate(agreements):
        if not agrees:
            if start < t:
                runs.append((t - 1 - 2 * start - LAG, start, t - 1))
            start = t + 1
    return max(runs)


def check(theta, arcs):
    endpoints = [end for arc in arcs for end in arc]
    cuts = [(end - theta) % DEN for end in endpoints]
    assert 0 not in cuts and len(set(cuts)) == 4
    positions = [floor_scaled_orbit(t) for t in range(LAST + LAG + 1)]
    assert abs(positions[LAG] - DEN * NEAREST_INTEGER) < DEN // 100
    circle = [(v + theta) % DEN for v in positions]
    letters = [any(lo <= v < hi for lo, hi in arcs) for v in circle]
    equal = [letters[t] == letters[t + LAG] for t in range(LAST + 1)]
    # For each cut, the two lifts lie in the same unit interval iff it was not crossed.
    # Positive-time samples are irrational, and the nonzero cuts also miss the origin.
    clear = [all((positions[t] - cut) // DEN ==
                 (positions[t + LAG] - cut) // DEN - NEAREST_INTEGER for cut in cuts)
             for t in range(LAST + 1)]
    assert all(not free or same for free, same in zip(clear, equal))
    return best_run(equal), best_run(clear), cuts


if __name__ == "__main__":
    cases = two_arc_cases()
    for index in (9, 19):
        letter_run, cut_run, cuts = check(*cases[index])
        print(f"#{index} lag {LAG}, (excess,first,last): letters {letter_run}, cut-free {cut_run}")
        print(f"  cut numerators relative to the phase, in encoding order: {cuts}")
