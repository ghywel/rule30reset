"""Bound the ordinary run needed to test a Rule 30 periodic source at finite width.

Gaps are measured between exceptional ticks, so gap g has one exceptional update
and g-1 ordinary updates. Wheel 1 is bit zero and wheel 2 stays black.
"""
import argparse
from math import lcm

from gptIntel_three_holes import base_cycles
from gptIntel_three_pulses import anchored, step


def plateau(width, ordinary):
    """Uniform time to cycles and a common multiple of their periods."""
    if width < 2:
        raise ValueError('need both wheels 1 and 2')
    if ordinary:
        cycles = base_cycles(width)
        return max(max(bounds) for _, bounds in cycles), lcm(*(len(c) for c, _ in cycles))
    black, t_black = anchored(width)
    white, t_white = anchored(width - 1)
    return max(t_black, t_white), lcm(len(black), len(white))


def representative(gap, settling, period):
    """Keep a full settled circuit, including when the original gap is shortened."""
    if gap < 1:
        raise ValueError('gap must be positive')
    first = settling + period + 1
    return gap if gap < first else first + (gap - first) % period


def check_small():
    # Exercise the actual maps on every admissible entry, not just the settled rows.
    for width in range(2, 11):
        mask = (1 << width) - 1
        for ordinary in (0, 1):
            settling, period = plateau(width, ordinary)
            upper = settling + 3 * period + 1
            for start in range(1 << width):
                if not start & 2:
                    continue
                row = step(start, mask) ^ (1 - ordinary)
                visited = {row}
                ends = {}
                for gap in range(1, upper + 1):
                    small = representative(gap, settling, period)
                    if small == gap:
                        ends[gap] = (row, frozenset(visited))
                    else:
                        assert ends[small] == (row, visited)
                    row = step(row, mask) ^ ordinary
                    visited.add(row)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('width', type=int, nargs='?', default=140)
    parser.add_argument('--controls', action='store_true')
    args = parser.parse_args()
    if args.controls:
        check_small()
        print('Every entry, width 2 through 10: same endpoint and set of rows.')
    for ordinary in (0, 1):
        settling, period = plateau(args.width, ordinary)
        print(f'width={args.width} ordinary={ordinary} settling={settling} '
              f'cycle_multiple={period} largest_representative={settling+2*period}')
