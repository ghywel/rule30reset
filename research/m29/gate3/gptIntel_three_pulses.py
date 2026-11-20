#!/usr/bin/env python3
"""Certificate for Rule 30 doubled excursions with exactly three source pulses.

Bit zero is wheel 1. During a hold its colour stays fixed. A pulse toggles only
that output bit. The input gap is the cyclic distance between consecutive pulses.
"""
import argparse


def step(row, mask):
    return ((row << 2) ^ ((row << 1) | row)) & mask


def anchored(width):
    """Construct the unique ordinary anchored cycle and a uniform transient bound."""
    cycle, bound = [1], [0]
    for w in range(2, width + 1):
        mask = (1 << w) - 1
        previous = len(cycle)
        black = [t for t, x in enumerate(cycle) if x & (1 << (w - 2))]
        y = cycle[0]
        for _ in range(previous):
            y = step(y, mask)
        first = y
        ext = []
        while not ext or y != first:
            ext.append(y)
            assert len(ext) <= 2 * previous
            y = step(y, mask)
        assert all(x & ((1 << (w - 1)) - 1) == cycle[t % previous]
                   for t, x in enumerate(ext))
        # Over an always-white terminal wheel the two high-bit choices
        # both occur over each lower phase iff the extension doubles.
        assert len(ext) == (previous if black else 2 * previous)
        # p denotes the asymptotic phase at absolute time zero. After
        # bound[p] ticks the lower prefix agrees, then the first forcing black
        # tick fixes the added bit. In a doubled cycle either high bit fits.
        upper = []
        for phase in range(len(ext)):
            d = bound[phase % previous]
            if black:
                while not cycle[(phase + d) % previous] & (1 << (w - 2)):
                    d += 1
                d += 1
            upper.append(d)
        cycle, bound = ext, upper
    return cycle, max(bound)


def closure(seeds, mask):
    """All possible rows after at least zero holds from one of these seeds."""
    seen = set()
    for y in seeds:
        while y not in seen:
            seen.add(y)
            y = step(y, mask)
    return seen


def first_catch(row, width):
    """Closing white of the first closed black run of length 1 mod 3, or zero."""
    run = 0
    for wheel in range(1, width + 1):
        if row & 1:
            run += 1
        else:
            if run % 3 == 1:
                return wheel
            run = 0
        row >>= 1
    return 0


def long_gap(width, verbose=True):
    mask = (1 << width) - 1
    black, t_black = anchored(width)
    white, t_white = anchored(width - 1)
    initial = set(black) | {x << 1 for x in white}
    coverage = 0
    for x in initial:
        coverage |= x
    assert coverage == mask, 'a wheel remains white in both full settled plateaus'
    gap = max(t_black + len(black), t_white + len(white))
    rows = initial
    worst, missed = 0, 0
    counts = []
    for pulses in range(4):
        catches = [first_catch(x, width) for x in rows]
        misses = catches.count(0)
        worst = max(worst, max(catches))
        missed += misses
        counts.append((len(rows), misses, max(catches)))
        if pulses < 3:
            rows = closure((step(x, mask) ^ 1 for x in rows), mask)
    if verbose:
        print(f'w={width} Tblack={t_black} Twhite={t_white} cycle={len(black)},{len(white)} '
              f'gap={gap} levels={counts} latest={worst} missed={missed}', flush=True)
    return gap, worst, missed


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('widths', type=int, nargs='+')
    for w in p.parse_args().widths:
        long_gap(w)
