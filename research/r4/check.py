"""Independent cone, source multiplicity and horizon checks for R4."""
from collections import Counter, defaultdict
import json


def check_cones(max_radius):
    cases = 0
    for radius in range(1, max_radius + 1):
        width = 2 * radius + 1
        for word in range(1 << width):
            # Positions are read left to right. Clip one cell at both ends per tick.
            row = [(word >> i) & 1 for i in range(width)]
            hit = False
            for gap in range(radius, 0, -1):
                hit |= bool(row[2 * gap - 2])  # position gap - 2 in [-gap,gap]
                row = [l ^ (c | r) for l, c, r in zip(row, row[1:], row[2:])]
            assert (not hit and row == [0]) == (word == 0), (radius, word)
            cases += 1
    return cases


def bit(row, age, pos):
    index = age + pos
    return (row >> index) & 1 if index >= 0 else 0


def multiplicity(row, age):
    if not bit(row, age, -1):
        return 0
    left = right = 1
    while bit(row, age, -1 - left):
        left += 1
    while bit(row, age, -1 + right):
        right += 1
    # The right run ends at right-2. Its first white has index right-1.
    return min(left, right - (1 - bit(row, age, right)))


def check_seed(horizon):
    rows = [1]
    for _ in range(horizon):
        row = rows[-1]
        rows.append((row << 2) ^ ((row << 1) | row))
    groups = defaultdict(list)
    counts = Counter()
    for t in range(2, horizon + 1):
        if bit(rows[t], t, 0):
            continue
        gap = next(j for j in range(1, t + 1) if bit(rows[t-j], t-j, j-2))
        groups[t-gap].append(gap)
        counts[gap] += 1
    previous = None
    for u, row in enumerate(rows):
        m = multiplicity(row, u)
        assert groups.get(u, []) == list(range(1, min(m, horizon-u) + 1)), u
        if m >= 2:
            if previous is not None:
                v, length = previous
                assert u >= v + length + 1
            previous = u, m
    tails = {}
    for k in range(1, max(counts) + 2):
        observed = sum(n for gap, n in counts.items() if gap > k)
        vacuum = sum(all(bit(rows[s], s, i) == 0 for i in range(-k, k+1))
                     for s in range(max(0, 2-k), horizon-k+1))
        assert observed == vacuum, k
        tails[k] = observed
    return dict(horizon=horizon, white_ticks=sum(counts.values()), sources=len(groups),
                max_gap=max(counts), gap_tail=tails)


if __name__ == '__main__':
    print(json.dumps(dict(cone_words=check_cones(7), seed=check_seed(4096)), indent=2))
