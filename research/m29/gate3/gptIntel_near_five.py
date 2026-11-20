#!/usr/bin/env python3
"""Finite check for irregular perturbations of the period-five pulse train.

Source pulse spacings are 5 except for at least one spacing of 4 or 6.
There are at least h ordinary spacings between consecutive exceptions,
cyclically. The proposed lemma concerns a periodic source of odd weight.

Run: python gptIntel_near_five.py --ordinary 5 --width 63
Wheel j is bit j-1 of a row. Wheel 0 is white and wheel 2 is black.
"""
import argparse
import json
from collections import Counter


def first_reset(row, width, minimum_length=1):
    run = 0
    for wheel in range(1, width+1):
        if row & (1 << (wheel-1)):
            run += 1
        else:
            if run >= minimum_length and run % 3 == 1:
                return wheel
            run = 0
    return 0


def endpoint_image(states, width, ordinary, collect=False):
    mask = (1 << width) - 1
    ends = set()
    rows = set()
    common = {}
    longer_by_start = {}

    def gap(row, length):
        """The pulse acts on the first tick of this gap."""
        panel = 0
        longer = width + 1
        for k in range(length):
            row = (((row << 2) ^ ((row << 1) | row)) & mask) ^ (k == 0)
            if collect:
                rows.add(row)
                panel |= row
                j = first_reset(row, width, 4)
                if j:
                    longer = min(longer, j)
        return row, panel, longer

    for before in states:
        for defect in (4, 6):
            row, panel, earliest = gap(before, defect)
            for _ in range(ordinary):
                row, black, longer = gap(row, 5)
                earliest = min(earliest, longer)
                panel |= black
            if collect:
                colour = before & 1
                key = (defect, colour)
                longer_by_start[key] = max(longer_by_start.get(key, 0), earliest)
                common[colour] = common.get(colour, mask) & panel
            # The next defect may start here or after any number of additional
            # 5-gaps. List the finite tail and a full cycle of possible ends.
            seen = set()
            while row not in seen:
                seen.add(row)
                row, _, _ = gap(row, 5)
            ends.update(seen)
    return ends, rows, common, longer_by_start


def certificate(width, ordinary):
    if width < 3 or ordinary < 0:
        raise ValueError('width must be at least 3, ordinary a nonnegative integer')
    states = {2, 3}  # all possible rows just before an exceptional gap, at width two
    for w in range(3, width+1):
        # Truncation commutes with every step. Lift each previous row by
        # both next bits. Each member of a periodic orbit has a predecessor,
        # so replacing the set by its one-block image drops no such orbit.
        states |= {row | (1 << (w-1)) for row in states}
        while True:
            image, _, _, _ = endpoint_image(states, w, ordinary)
            assert image <= states
            if image == states:
                break
            states = image

    _, rows, common, longer = endpoint_image(states, width, ordinary, True)
    assert set(common) == {0, 1}
    counts = Counter(first_reset(x, width) for x in rows)
    last = max(counts)
    # The same exceptional gap recurs after P ticks. Since the source
    # has odd weight, the wheel-1 colour complements over those P ticks.
    # If either colour's guaranteed panel sees a wheel black, it cannot
    # be the all-white return anywhere in the corresponding doubled strip.
    # Each exceptional gap recurs in both colours, so take the better of its two bounds.
    by_defect = {d: min(longer[d, c] for c in (0, 1)) for d in (4, 6)}
    first_longer = max(by_defect.values())
    seen_black = common[0] | common[1]
    missing = [j for j in range(1,width+1) if not seen_black & (1 << (j-1))]
    return dict(width=width, ordinary=ordinary, endpoints=len(states), rows=len(rows),
                first_reset=dict(sorted(counts.items())), latest=last,
                longer_run_guaranteed_by=first_longer if first_longer <= width else None,
                longer_by_defect={d: j if j <= width else None for d,j in by_defect.items()},
                common_by_colour=[common[0],common[1]], missing_wheels=missing,
                passed=not counts[0] and all(j > last for j in missing)), states, rows


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ordinary', type=int, default=5)
    parser.add_argument('--width', type=int, default=63)
    args = parser.parse_args()
    result, _, _ = certificate(args.width,args.ordinary)
    print(json.dumps(result,sort_keys=True))
