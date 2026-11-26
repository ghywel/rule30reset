"""Independent replay: explicit physical rows, literal Rule 30, edge-first inverse filtering.

python3 threshold_replay.py 4:71 4:72 7:130 7:131 8:131 8:132
python3 threshold_replay.py --causes
"""
import argparse
from bisect import bisect_left
from itertools import groupby

import numpy as np


def physical_rows():
    # Integer MSB at the black edge, LSB immediately beside the wall.
    rows = {2, 3}
    while True:
        yield rows
        outputs = set()
        for row in rows:
            zero = (row >> 1) ^ (row | row << 1)
            outputs.add(zero)
            outputs.add(zero if row & 1 else zero ^ 1)
        rows = outputs


def failing(rows, k):
    """Each cut state is a pair per layer. Derive each transition from the literal truth table."""
    transitions = [[], []]
    for symbol in (0, 1):
        for state in range(4**k):
            new = 0
            above = symbol
            for layer in range(k):
                current = (state >> (2 * layer)) & 1
                east = (state >> (2 * layer + 1)) & 1
                west = next(b for b in (0, 1)
                            if ((30 >> (4*b + 2*current + east)) & 1) == above)
                new |= (west + 2*current) << (2 * layer)
                above = current
            transitions[symbol].append(new)
    table = np.array(transitions, dtype=np.int32)
    width = rows[0].bit_length()
    def descend(lo, hi, remaining, mask):
        if lo == hi or not mask.any():
            return 0, 0
        if not remaining:
            assert hi == lo + 1
            return 1, int(mask.sum())
        half = 1 << (remaining - 1)
        split = bisect_left(rows, (rows[lo] & -(2 * half)) + half, lo, hi)
        left = descend(lo, split, remaining - 1, mask[table[0]]) if lo < split else (0, 0)
        right = descend(split, hi, remaining - 1, mask[table[1]]) if split < hi else (0, 0)
        return left[0] + right[0], left[1] + right[1]
    return descend(0, len(rows), width, np.arange(4**k) != 0)


FOUR_STEM = '110111101100111000101100001101100000011001100000111000110110111'


def causes():
    """Track each excluded four-tick prefix from the first time its entire band fits."""
    for tail in ('011', '111011'):
        word = FOUR_STEM + tail
        width = len(word)
        row_source = physical_rows()
        for _ in range(width - 1):
            entrants = next(row_source)
        target = int(word, 2)
        bands = list(entrants)
        counts = []
        for age in range(width-2, 73):
            counts.append(bands.count(target))
            if age in (70, 71):
                # Only entrants whose next word agrees up to the penultimate cell.
                triples = set()
                for band in bands:
                    child = (band >> 2) ^ ((band >> 1) | band)
                    if child >> 1 == target >> 1:
                        triples.add(format(band & 7, '03b'))
                print(f'width {width}, age {age} -> {age+1}, last triples {sorted(triples)}')
            bands = [(v >> 2) ^ ((v >> 1) | v) for v in bands]
        print(f'width {width}, {len(entrants)} entrants, ages {width-2}..72: {counts}')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('cases', nargs='*', metavar='K:AGE')
    parser.add_argument('--causes', action='store_true')
    args = parser.parse_args()
    if args.causes:
        causes()
    cases = sorted((tuple(map(int, spec.split(':'))) for spec in args.cases), key=lambda x:x[1])
    source = physical_rows()
    current = -1
    for age, group in groupby(cases, key=lambda x:x[1]):
        while current < age:
            rows = next(source)
            current += 1
        ordered = sorted(rows)
        for k, _ in group:
            if not 0 < k < age + 2:
                parser.error('require 0 < K < AGE+2')
            bad, pairs = failing(ordered, k)
            print(f'k={k} age={age} rows={len(rows)} bad={bad} bad_pairs={pairs}', flush=True)


if __name__ == '__main__':
    main()
