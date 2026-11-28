"""First failed even tests of the I330 reference truncated at width W.

Track the difference at (t, W-t+d) for d=0..slack. Before it reaches the
wall, each bit is XORed with a function of two lower bits. The reference
feed repeats every 36 ticks in its spatial tail. The word at t=W-83 is
therefore obtained by a finite permutation, followed by the last 83 ticks
and the tests as the moving coordinates cross the wall.
"""

from collections import Counter
from math import lcm
import argparse

from edge150_check import tick


def reference():
    """The 90 columns before repetition, packed by physical time."""
    east, here = 0, 3551
    columns = []
    for _ in range(90):
        columns.append(here)
        next_time = (here >> 1) | ((here & 1) << 11)
        side = ((here ^ east) & 1365) | ((here & ~east) & 2730)
        east, here = here, next_time ^ side
    assert (east, here) == (columns[80], columns[81])
    return columns


COLUMNS = reference()
PERIOD = lcm(12, 9)
JOIN = 83


def bit(t, i):
    if i < 0:
        return 0
    j = i if i < 81 else 81 + (i - 81) % 9
    return (COLUMNS[j] >> (t % 12)) & 1


def packed_ref(t, index, lanes):
    return sum(bit(t, index + d) << d for d in range(lanes))


def transition(t, index, lanes):
    centre = packed_ref(t, index - 1, lanes)
    east = packed_ref(t, index - 2, lanes)
    mask = ((1 << lanes) - 1) & (-1 << max(0, 1 - index))
    return t % 2, centre, east, mask


def update(delta, phase, centre, east, mask):
    a = delta << 1
    b = delta << 2
    if phase == 0:
        change = a ^ b
    else:
        change = (a & ~east) ^ (b & centre) ^ (a & b)
    return (delta ^ change) & mask


def scan(delta, steps):
    for step in steps:
        delta = update(delta, *step)
    return delta


def after_cut(delta, steps, width):
    """Read the wall at physical times W+s as it crosses the strip."""
    for s, step in enumerate(steps):
        if (width + s) % 2 == 0 and (delta >> s) & 1:
            return s
        delta = update(delta, *step)
    return None


def cut_classes(slack):
    lanes = slack + 1
    result = []
    for residue in range(PERIOD):
        width = JOIN + residue
        start = packed_ref(0, width, lanes)
        cycle = [transition(t, width + PERIOD - t, lanes) for t in range(PERIOD)]
        lead = cycle[:residue]
        approach = [transition(residue + j, JOIN - j, lanes) for j in range(JOIN)]
        after = [transition(residue + JOIN + s, -s, lanes) for s in range(lanes)]
        state = start
        counts = []
        while True:
            at_cut = scan(scan(state, lead), approach)
            counts.append(after_cut(at_cut, after, width))
            state = scan(state, cycle)
            if state == start:
                break
            assert len(counts) < 1 << lanes
        assert len(counts) & (len(counts) - 1) == 0
        result.append(counts)
    return result


def check_direct(result, slack):
    # An independent rule-table replay uses the complete finite physical rows.
    for width in range(JOIN, JOIN + 3 * PERIOD):
        q, r = divmod(width - JOIN, PERIOD)
        exact = result[r][q % len(result[r])]
        row = {-i - 1 for i in range(width) if bit(0, i)}
        found = None
        for t in range(width + slack + 1):
            if t % 2 == 0 and -1 not in row:
                found = t - width
                break
            row = tick(row, (150, 180)[t % 2], wall=0)
        assert found == exact, (width, found, exact)
    print('direct table controls:', 3 * PERIOD)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--slack', type=int, default=12)
    args = parser.parse_args()
    if args.slack < 0:
        parser.error('slack must be nonnegative')
    found = cut_classes(args.slack)
    for r, pattern in enumerate(found):
        width = JOIN + r
        first_difference = next(d for d in range(9) if bit(0, width + d))
        print(width, first_difference, len(pattern), dict(Counter(pattern)), pattern[:32])
    print('cutoff sample W=83+r, first omitted black index minus W, cycle size, lag counts, first lags')
    print('full-width period:', PERIOD * lcm(*(len(pattern) for pattern in found)))
    print('exact combined lag histogram:', dict(Counter(s for pattern in found for s in pattern)))
    print('first widths beyond each tested bound:',
          [(d, min((JOIN + r + PERIOD * q for r, values in enumerate(found)
                    for q, s in enumerate(values) if s is None or s > d), default=None))
           for d in range(args.slack + 1)])
    check_direct(found, args.slack)


if __name__ == '__main__':
    main()
