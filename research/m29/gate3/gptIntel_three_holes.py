#!/usr/bin/env python3
"""Long-gap certificate for sources with three white ticks (holes) in the fundamental word.

A regular tick of black input toggles wheel 1; a white tick omits that toggle.
"""
import argparse
from gptIntel_three_pulses import first_catch, step


def base_cycles(width):
    """All eventual cycles of the constantly black input, plus a common transient bound."""
    cycles = [([2, 3], [0, 0])]
    for w in range(3, width + 1):
        mask = (1 << w) - 1
        lifted = []
        for lower, bounds in cycles:
            size = len(lower)
            black = [x >> (w - 2) & 1 for x in lower]
            # Over each lower phase there are just two upper-bit choices.
            used = set()
            for high in (0, 1):
                start = lower[0] | (high << (w - 1))
                for _ in range(size):
                    start = step(start, mask) ^ 1
                if start in used:
                    continue
                seq, upper = [], []
                v = start
                while v not in used:
                    q = len(seq) % size
                    assert v & ((1 << (w - 1))-1) == lower[q]
                    seq.append(v)
                    used.add(v)
                    d = bounds[q]
                    if any(black):
                        while not black[(q + d) % size]:
                            d += 1
                        d += 1
                    upper.append(d)
                    v = step(v, mask) ^ 1
                assert v == start
                lifted.append((seq, upper))
        cycles = lifted
    return cycles


def after_hole(rows, mask, ban=0):
    """All states from one white input followed by any number of black inputs.
    If ban has one bit set, keep only paths along which that wheel stayed white.
    """
    seen = set()
    for x in rows:
        y = step(x, mask)
        while y not in seen and not y & ban:
            seen.add(y)
            y = step(y, mask) ^ 1
    return seen


def measure(width):
    mask = (1 << width) - 1
    cycles = base_cycles(width)
    limit = max(max(ds) + len(c) for c, ds in cycles)
    anchors = set(x for c, ds in cycles for x in c)
    counts, rows = [], anchors
    for k in range(4):
        catches = [first_catch(x,width) for x in rows]
        counts.append((len(rows), catches.count(0), max(catches)))
        if k < 3:
            rows = after_hole(rows,mask)
    possible = {k: [] for k in (1, 2, 3)}
    restricted_counts = {}
    for j in range(1,width + 1):
        bit = 1 << (j-1)
        # Start in a full anchor cycle and finish with another long run. We
        # allow the final cycle and phase to be independent of the first.
        steady_white = {x for c, ds in cycles if all(not x & bit for x in c) for x in c}
        if not steady_white:
            continue
        paths = steady_white
        restricted_counts[j] = [len(paths)]
        for k in range(1, 4):
            paths = after_hole(paths,mask,bit)
            restricted_counts[j].append(len(paths))
            # A long final gap must arrive at a compatible wholly white cycle.
            if paths & steady_white:
                possible[k].append(j)
    print(f'w={width} anchor_cycles={[len(c) for c,d in cycles]} gap={limit} '
          f'levels={counts} restricted={restricted_counts} possible_white={possible}', flush=True)
    return limit, counts, possible


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('widths', nargs='+', type=int)
    for w in parser.parse_args().widths:
        measure(w)
