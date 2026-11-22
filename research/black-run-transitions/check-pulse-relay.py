"""Replay the ordinary pulse controls and compute the guaranteed period exclusions."""
from functools import cache

# Each pair is (right-hand 01 pairs, consecutive black ticks sufficient to fix them).
BLOCKS = ((1, 9), (5, 44), (8, 70), (15, 128))


def certified_pairs(black_ticks, blocks):
    @cache
    def best(n):
        result = (0, ())
        for width, duration in blocks:
            if duration <= n:
                value, later = best(n - duration + 2 * width)
                if width + value > result[0]:
                    result = width + value, (width,) + later
        return result

    return best(black_ticks)


def update(row, drive):
    return ((row << 1) | drive) ^ (row | (row >> 1))


def run(row, drive, ticks):
    for t in range(ticks):
        row = update(row, (drive >> t) & 1)
    return row


def one_pair():
    # The first 11 right cells contain the complete 9-tick cone of cell 2.
    for row in range(1 << 11):
        assert run(row, (1 << 9) - 1, 9) & 3 == 2
    assert run(19, 255, 8) & 2 == 0
    for n in range(9, 201):
        row = 19
        for t in range(n + 3):
            if 9 <= t < n + 2:
                assert row & 2
            if t in (8, n + 2):
                assert row & 2 == 0
            row = update(row, int(t < n))


def horizon_controls():
    # Words are packed from the nearest right cell or earliest time in the low bit.
    tests = [
        (2, 26, 30), (26, 442, 74), (62, 746, 234), (310, 103338, 126122),
        (6673618, 25780906, 4734634), (139736600, 410823338, 424266410),
        (1119936524, 7294511786, 7251897002),
    ]
    for j, (drive, left, right) in enumerate(tests, 1):
        end = 4 * j + (4 if j >= 5 else 0)
        stripe = sum(1 << (2 * i + 1) for i in range(j))
        mask = (1 << (2 * j)) - 1
        assert left & mask == right & mask == stripe and drive & 1 == 0
        for t in range(end):
            assert left & 1 == right & 1
            left = update(left, drive >> t & 1)
            right = update(right, drive >> t & 1)
        assert (left ^ right) & 1


if __name__ == "__main__":
    one_pair()
    horizon_controls()
    for ticks in (16, 44, 128, 350):
        pairs, schedule = certified_pairs(ticks, BLOCKS)
        print(f"{ticks} black ticks: {pairs} pairs, {4*pairs} following ticks, blocks {schedule}")
