"""Decode the unique finite left for an alternating target, then count eligible right words.

Input: tab-separated wall,H,word,count,denominator from k83a-gate-mass.cpp.
Word digits are chronological; site -1 is the low bit of the decoded integer.
"""
import argparse
import csv
from collections import Counter, defaultdict
from fractions import Fraction


def left_for_word(first, word):
    ticks = 2 * len(word) - (1 - first)
    centre = [first ^ (t % 2) for t in range(ticks + 1)]
    gates = iter(map(int, word))
    current = [centre[t+1] ^ (1 if centre[t] else next(gates)) for t in range(ticks)]
    assert next(gates, None) is None
    east = centre
    left = 0
    for j in range(ticks):
        left |= current[0] << j
        east, current = current, [a ^ (b | c) for a, b, c in zip(current[1:], current, east)]
    return left


def direct_control(max_ticks=7):
    """Independently count left choices for every finite right word by full-row evolution."""
    for ticks in range(1, max_ticks + 1):
        for first in range(2):
            for right in range(1 << ticks):
                work = right
                word = []
                for t in range(ticks):
                    boundary = first ^ (t % 2)
                    if not boundary:
                        word.append(str(work & 1))
                    work = ((work << 1) | boundary) ^ (work | (work >> 1))
                # Keep cases ending directly after a white gate was read.
                if (ticks - 1) % 2 != first:
                    continue
                candidates = []
                for left in range(1 << ticks):
                    west = int(f"{left:0{ticks}b}"[::-1], 2)
                    row = west | (first << ticks) | (right << (ticks+1))
                    for t in range(1, ticks + 1):
                        row = (row << 1) ^ (row | (row >> 1))
                        if ((row >> ticks) & 1) != (first ^ (t % 2)):
                            break
                    else:
                        candidates.append(left)
                assert candidates == [left_for_word(first, "".join(word))]


def bounded_survival(path, cutoffs):
    groups = defaultdict(dict)
    denominators = {}
    with open(path, encoding="utf8", newline="") as stream:
        for row in csv.DictReader(stream, delimiter="\t"):
            phase, horizon = row["wall"], int(row["H"])
            word = row["word"]
            key = (phase, horizon)
            assert len(word) == horizon and word not in groups[key]
            groups[key][word] = int(row["count"])
            denominators[key] = int(row["denominator"])
    previous = {}
    print("phase H ticks denominator least_depth mode_left " + " ".join("B"+str(b) for b in cutoffs))
    for (phase, horizon), counts in sorted(groups.items()):
        first = int(phase == "black")
        ticks = 2*horizon - (1-first)
        weights = Counter()
        assert sum(counts.values()) == denominators[phase, horizon] == 1 << ticks
        for word, count in counts.items():
            left = left_for_word(first, word)
            assert left not in weights
            weights[left] = count
        bounds = [sum(n for left, n in weights.items() if left.bit_length() <= b) for b in cutoffs]
        for b, n in zip(cutoffs, bounds):
            prob = Fraction(n, 1 << ticks)
            assert prob <= previous.get((phase, b), 1)
            previous[phase, b] = prob
        print(phase, horizon, ticks, 1 << ticks, min(n.bit_length() for n in weights),
              max(weights, key=weights.get), *bounds)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("histogram")
    args = parser.parse_args()
    direct_control()
    bounded_survival(args.histogram, (0, 1, 2, 4, 8, 16, 19, 20, 24))
