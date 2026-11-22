"""Check all surviving two- and three-gap cycles by exact finite-set propagation."""
from functools import cache


@cache
def transitions(width):
    limit = (1 << width) - 1
    # With exterior zero and target white. The target flips bit zero;
    # a black exterior toggles the high output bit only when its centre is white.
    high = 1 << (width - 1)
    zero = [(row << 1 ^ (row | row >> 1)) & limit for row in range(limit + 1)]
    one = [out if row & high else out ^ high for row, out in enumerate(zero)]
    return zero, one


def settle(gaps, width):
    pulse = [bit for gap in gaps for bit in [1] + [0] * gap]
    neighbor = [bit for gap in gaps for bit in [1, 0, 0] + [1] * (gap - 2)]
    zero, one = transitions(width)
    rows = set(range(1 << width))
    tick = 0
    last_bad = None
    while True:
        before = rows
        for driver, expected in zip(pulse, neighbor):
            if any(row & 1 != expected for row in rows):
                last_bad = tick
            rows = {zero[row] ^ driver for row in rows} | {one[row] ^ driver for row in rows}
            tick += 1
        if rows == before:
            assert last_bad is None or last_bad < tick - len(pulse), (gaps, last_bad)
            return last_bad


def main():
    cases = [((9, 10), 15, 75), ((10, 9), 15, 86)]
    # A cyclic three-gap word containing 10 followed by 9 rotates to (10,9,q).
    for q, width, last in [
        (9, 15, 54), (10, 17, 55), (11, 18, 56), (12, 15, 57),
        (13, 15, 93), (14, 15, 23), (15, 12, 23), (16, 12, 23),
    ]:
        cases.append(((10, 9, q), width, last))
    for gaps, width, expected in cases:
        observed = settle(gaps, width)
        assert observed == expected, (gaps, observed, expected)
        print(f"{gaps} at width {width}: every neighbor agrees from tick {observed + 1}")


if __name__ == "__main__":
    main()
