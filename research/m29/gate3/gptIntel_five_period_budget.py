#!/usr/bin/env python3
"""Bound the period of a possible failure with five black ticks, whatever the clock.

python gptIntel_five_period_budget.py --controls

Fix a longest pulse spacing L and put it last. The other four spacings are at
most L. On a width known to settle inside L, look for a bare row. Only the
largest arrival time at a given state matters for an upper bound on the period.
"""
import argparse

from gptIntel_marked_path_core import is_bare, ordinary_cycles, retained_paths
from gptIntel_three_pulses import first_catch, step

MARKS = 5


def required_gaps(limit):
    """A settled endpoint plus at least one black witness on every wheel."""
    result = {}
    required = 0
    for width in range(3, limit + 1):
        cycles = ordinary_cycles(width, 0)
        # At elapsed delay all entries are on the relevant cycle. A gap
        # of length L contains L - delay settled rows, endpoint included.
        guarantees = []
        for cycle, delay in cycles:
            colours = [bool(r & (1 << (width - 1))) for r in cycle]
            if any(colours):
                span = max(next(j + 1 for j in range(len(cycle))
                                if colours[(phase + j) % len(cycle)])
                           for phase in range(len(cycle)))
                guarantees.append(delay + span)
        # Repeating the same gap after an odd-weight period supplies the
        # opposite colour. Either plateau can witness black on this wheel.
        # Earlier wheels keep their own bounds, checked at their own widths.
        assert guarantees
        required = max(required, min(guarantees), max(delay + 1 for _, delay in cycles))
        result[width] = required
    return result


def longest_period(width, longest_gap, retained, floor):
    """Maximum admitted period at least floor, or zero if there is none."""
    mask = (1 << width) - 1
    # Pulse one is at tick zero, immediately after the chosen long gap.
    starts = {step(row, mask) ^ 1: 0 for row in retained[0]
              if (step(row, mask) ^ 1) in retained[1]}
    best = 0
    for k in range(1, MARKS + 1):
        next_starts = {}
        for row, arrival in starts.items():
            for gap in range(1, longest_gap + 1):
                if row not in retained[k]:
                    break
                # Row follows mark k and gap-1 ordinary ticks. If it is bare,
                # complete each unchosen gap, including the designated last
                # gap, with length L to obtain the largest possible period.
                if is_bare(row, width):
                    upper = arrival + (MARKS - k + 1) * longest_gap
                    if upper >= floor:
                        best = max(best, upper)
                row = step(row, mask)
                if k < MARKS:
                    next_arrival = arrival + gap
                    upper = next_arrival + (MARKS - k) * longest_gap
                    marked = row ^ 1
                    if upper >= max(floor, best) and marked in retained[k + 1]:
                        next_starts[marked] = max(next_starts.get(marked, 0), next_arrival)
        starts = next_starts
    return best


def direct_check(width, longest_gap):
    """Literal small-alphabet control, with unpruned states and every gap length."""
    mask = (1 << width) - 1

    def visit(row, k, elapsed, seen_bare):
        best = 0
        row = step(row, mask) ^ 1
        for gap in range(1, longest_gap + 1):
            seen_bare |= not first_catch(row, width)
            if k < MARKS:
                best = max(best, visit(row, k + 1, elapsed + gap, seen_bare))
            row = step(row, mask)
        if k == MARKS and seen_bare:
            return elapsed + longest_gap
        return best

    return max(visit(r, 1, 0, False) for cycle, _ in ordinary_cycles(width, 0) for r in cycle)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--controls', action='store_true')
    parser.add_argument('--verbose', action='store_true')
    args = parser.parse_args()
    # If all five distances are at least 20, I25 already gives a reset by
    # wheel 20. Otherwise P <= 19+4L. For L <= 104 this gives P <= 435.
    floor = 436
    first_gap = 105
    limit = 108
    needed = required_gaps(limit)
    # At the terminal width the unbudgeted graph must be empty, proving
    # every spacing L at least its entry bound independently of the period.
    chosen = {g: max(w for w, bound in needed.items() if bound <= g)
              for g in range(first_gap, needed[limit])}
    previous = None
    worst, witness_gap = floor - 1, None
    for width in range(3, limit + 1):
        retained, counts = retained_paths(width, 0, MARKS, previous)
        if args.controls and width in (18, 26, 36):
            for test_gap in (5, 8):
                actual = direct_check(width, test_gap)
                assert longest_period(width, test_gap, retained, 0) == actual
                assert longest_period(width, test_gap, retained, actual + 1) == 0
        for g, w in chosen.items():
            if w == width:
                upper = longest_period(width, g, retained, floor)
                if args.verbose:
                    print('L', g, 'width', w, 'max period at least', floor, upper)
                if upper > worst:
                    worst, witness_gap = upper, g
        previous = retained
    assert not any(counts)
    print('longest gaps', first_gap, 'through', needed[limit] - 1,
          'largest unresolved period bound', worst, 'at gap', witness_gap,
          'all periods at least', worst + 1, 'pass')


if __name__ == '__main__':
    main()
