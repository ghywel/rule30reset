#!/usr/bin/env python3
"""Check five marked source ticks with four consecutive gaps 1..8 and a bounded fifth.

python gptIntel_five_cluster_box.py 319 --jobs 6
The default cap is 139 so a completed box verifies the prediction "below 140".
"""
import argparse
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass
from itertools import product

from claudeCloud_excursions import excursion, first_resets
from gptIntel_three_pulse_census import trace_first


@dataclass
class Results:
    classes: int = 0
    phases: int = 0
    peak: int = 0
    peak_cases: int = 0
    witness: tuple = ()
    misses: int = 0
    first_miss: tuple = ()

    def merge(self, other):
        self.classes += other.classes
        self.phases += other.phases
        self.misses += other.misses
        if other.first_miss and not self.first_miss:
            self.first_miss = other.first_miss
        if other.peak == self.peak:
            self.peak_cases += other.peak_cases
        elif other.peak > self.peak:
            self.peak = other.peak
            self.peak_cases = other.peak_cases
            self.witness = other.witness

    def record(self, gaps, q, latest, pending, white):
        self.classes += 1
        self.phases += q
        if pending:
            self.misses += 1
            if not self.first_miss:
                self.first_miss = (gaps, pending, white)
        elif latest > self.peak:
            self.peak, self.witness, self.peak_cases = latest, gaps, 1
        elif latest == self.peak:
            self.peak_cases += 1


def cyclic_representative(gaps):
    """Outside the short cube the sole gap greater than eight is always last."""
    return gaps[-1] > 8 or all(gaps < gaps[i:] + gaps[:i] for i in range(1, 5))


def first_column(gaps):
    a, b, c, d, e = gaps
    period = a + b + c + d + e
    # Prefix XOR starts white. Apart from tick 0 it is white after the
    # second mark through the third, and after the fourth through the fifth.
    white = 1 | (((1 << b) - 1) << (a + 1)) | (((1 << d) - 1) << (a + b + c + 1))
    return (((1 << period) - 1) ^ white) | (white << period)


def at_free_gap(job):
    free_gap, cap = job
    results = [Results(), Results()]
    for short in product(range(1, 9), repeat=4):
        gaps = short + (free_gap,)
        if not cyclic_representative(gaps):
            continue
        period = sum(gaps)
        q = 2 * period
        first = first_column(gaps)
        results[0].record(gaps, q, *trace_first(first, q, cap))
        if period % 2 == 0:
            # Switching the marked colour complements each source tick, so
            # its prefix XOR is inverted at precisely the odd time indices.
            alternating = 2 * (((1 << q) - 1) // 3)
            results[1].record(gaps, q, *trace_first(first ^ alternating, q, cap))
    return results


def source_word(gaps, holes):
    mark, rest = ('0', '1') if holes else ('1', '0')
    return ''.join(mark + rest * (g - 1) for g in gaps)


def replay(gaps, holes, cap):
    word = source_word(gaps, holes)
    wheels, white = excursion(word, cap)
    catches = first_resets(wheels[:-1] if white else wheels)
    latest = max((j for j in catches if j is not None), default=0)
    return latest, catches.index(latest) if latest else None, catches.count(None), white


def controls(cap):
    # The excluded equal gaps encode a period-five word repeated five times.
    gaps = (5,) * 5
    _, pending, white = trace_first(first_column(gaps), 50, 40)
    assert (pending, white) == (10, 23)
    for g in [(1, 2, 3, 4, 6), (2, 1, 1, 2, 18), (3, 5, 8, 4, 3)]:
        for holes in [False, True]:
            p = sum(g)
            if holes and p % 2:
                continue
            first = first_column(g)
            if holes:
                first ^= 2 * (((1 << (2*p)) - 1) // 3)
            last, pending, _ = trace_first(first, 2*p, cap)
            direct, _, bare, _ = replay(g, holes, cap)
            assert (last, pending) == (direct, bare)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('max_gap', type=int)
    parser.add_argument('--cap', type=int, default=139)
    parser.add_argument('--jobs', type=int, default=1)
    args = parser.parse_args()
    if args.max_gap < 8 or args.cap < 3 or args.jobs < 1:
        parser.error('max_gap must be at least 8, cap at least 3, jobs positive')
    controls(args.cap)
    jobs = [(length, args.cap) for length in range(1, args.max_gap + 1)]
    totals = [Results(), Results()]
    long = [Results(), Results()]
    with ProcessPoolExecutor(max_workers=args.jobs) as pool:
        for length, result in enumerate(pool.map(at_free_gap, jobs), 1):
            for summary, partial in zip(totals, result):
                summary.merge(partial)
            if length >= 279:
                for summary, partial in zip(long, result):
                    summary.merge(partial)
    # A nonconstant five-gap word has five distinct rotations. Every tuple in
    # the cube is available. Beyond it the exceptional last gap fixes the rotation.
    expected = (8**5 - 8) // 5 + (args.max_gap - 8) * 8**4
    for holes, result in enumerate(totals):
        assert result.classes == expected // (1 + holes)
        print(f'holes={holes} classes={result.classes} doubled_phases={result.phases} '
              f'misses={result.misses} first_miss={result.first_miss} peak={result.peak} '
              f'peak_cases={result.peak_cases} gaps={result.witness}', flush=True)
        if result.witness:
            direct, phase, bare, white = replay(result.witness, holes, args.cap)
            assert direct == result.peak and not bare
            print(f'  scalar P={sum(result.witness)} phase={phase} closure={direct} '
                  f'first_white_within_cap={white}', flush=True)
        if long[holes].classes:
            tail = long[holes]
            print(f'  L=279..{args.max_gap} classes={tail.classes} misses={tail.misses} '
                  f'peak={tail.peak} gaps={tail.witness}', flush=True)
    if any(summary.misses for summary in totals):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
