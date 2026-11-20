#!/usr/bin/env python3
"""Prefix certificates for arbitrary spacings after a long constant-source interval.

python gptIntel_marked_path_core.py --ordinary 0 --marks 5 --width 140 --controls
python gptIntel_marked_path_core.py --ordinary 1 --marks 5 --width 140

Bit zero is wheel 1. A path starts on the eventual ordinary-input cycle and
takes up to the stated number of exceptional ticks. Between them it may take
any number of ordinary ticks. We track paths ending in a row with no closed
black run of length 1 modulo 3. A second check rules out an early white return.
"""
import argparse
from collections import deque
from functools import reduce
from operator import or_

from gptIntel_three_holes import after_hole, base_cycles
from gptIntel_three_pulses import anchored, first_catch, step


def ordinary_cycles(width, ordinary):
    """Return (cycle, transient bound) for all anchor phases."""
    if ordinary:
        return [(cycle, max(bounds)) for cycle, bounds in base_cycles(width)]
    black, delay_black = anchored(width)
    white, delay_white = anchored(width - 1)
    return [(black, delay_black), ([row << 1 for row in white], delay_white)]


def is_bare(row, width):
    """Skip maximal black and white runs. A run touching the far cut is still open."""
    depth = 0
    while row:
        white = (row & -row).bit_length() - 1
        row >>= white
        black = (row ^ (row + 1)).bit_length() - 1
        depth += white + black
        if black % 3 == 1 and depth < width:
            return False
        row >>= black
    return True


def retained_paths(width, ordinary, marks, previous):
    """All reachable states that can still lead to a bare row at this width."""
    mask = (1 << width) - 1
    lower_mask = mask >> 1
    cycles = ordinary_cycles(width, ordinary)
    seeds = {row for cycle, _ in cycles for row in cycle}
    reached = []
    for k in range(marks + 1):
        # A bare row at width w is bare at w-1. Its entire history therefore
        # projects to a retained path at w-1, including intermediate rows
        # which have resets of their own.
        allowed = previous[k] if previous is not None else None
        here = set()
        for row in seeds:
            while row not in here and (allowed is None or (row & lower_mask) in allowed):
                here.add(row)
                row = step(row, mask) ^ ordinary
        reached.append(here)
        if k < marks:
            seeds = {step(row, mask) ^ (1 - ordinary) for row in here}

    retained = [set() for _ in reached]
    bare_counts = [0 for _ in reached]
    for k in range(marks, -1, -1):
        # At fixed k the ordinary successor is deterministic. Walk until
        # a bare row, an admissible mark leading to a retained row, a
        # previous decision, a cut boundary, or a closed ordinary cycle.
        here = reached[k]
        useful = retained[k]
        while here:
            row = here.pop()
            trail = [row]
            while True:
                bare = is_bare(row, width)
                bare_counts[k] += bare
                successor = step(row, mask) ^ ordinary
                mark_works = k < marks and (successor ^ 1) in retained[k + 1]
                if bare or mark_works or successor in useful:
                    useful.update(trail)
                    break
                if successor not in here:
                    break
                here.remove(successor)
                trail.append(successor)
                row = successor
    return retained, bare_counts


def unrestricted_counts(width, ordinary, marks):
    """Independent small-width control. Keep every reachable state, with no pruning."""
    mask = (1 << width) - 1
    rows = {r for cycle, _ in ordinary_cycles(width, ordinary) for r in cycle}
    counts = []
    for k in range(marks + 1):
        counts.append(sum(first_catch(r, width) == 0 for r in rows))
        if k < marks:
            tails = set()
            for r in rows:
                r = step(r, mask) ^ (1 - ordinary)
                while r not in tails:
                    tails.add(r)
                    r = step(r, mask) ^ ordinary
            rows = tails
    return counts


def white_returns(width, ordinary, marks):
    """Could a permanently white wheel survive up to the next long gap?"""
    cycles = ordinary_cycles(width, ordinary)
    columns = [reduce(or_, cycle, 0) for cycle, _ in cycles]
    gap = max(delay + len(cycle) for cycle, delay in cycles)
    mask = (1 << width) - 1
    if not ordinary:
        # Both colours occur in repeats of a long gap one odd-weight period apart.
        assert reduce(or_, columns, 0) == mask
        return gap, {}, []

    counts = {}
    possible = []
    for wheel in range(1, width + 1):
        bit = 1 << (wheel - 1)
        if all(col & bit for col in columns):
            continue
        # Project at the candidate column. Autonomy makes this sufficient:
        # if no projected path works, no path at full width can work.
        projected = ordinary_cycles(wheel, ordinary) if wheel >= 2 else [([0, 1], 0)]
        settled_white = {r for cycle, _ in projected
                         if all(not (v & bit) for v in cycle) for r in cycle}
        paths = settled_white
        counts[wheel] = []
        for k in range(1, marks + 1):
            paths = after_hole(paths, (1 << wheel) - 1, bit)
            endpoints = len(paths & settled_white)
            counts[wheel].append((len(paths), endpoints))
            if k == marks and endpoints:
                possible.append(wheel)
    return gap, counts, possible


def representative(width, ordinary, marks, retained):
    """One concrete tick history from a settled row to a maximal-width bare target."""
    mask = (1 << width) - 1
    seeds = [(0, r) for cycle, _ in ordinary_cycles(width, ordinary)
             for r in cycle if r in retained[0]]
    parents = {s: None for s in seeds}
    queue = deque(seeds)
    while queue:
        k, row = node = queue.popleft()
        if is_bare(row, width):
            ticks = []
            while parents[node] is not None:
                node, source = parents[node]
                ticks.append(source)
            return node[1], list(reversed(ticks))
        default = step(row, mask) ^ ordinary
        for extra in range(2):
            nxt = (k + extra, default ^ extra)
            if nxt[0] <= marks and nxt[1] in retained[nxt[0]] and nxt not in parents:
                parents[nxt] = node, ordinary ^ extra
                queue.append(nxt)
    raise AssertionError('nonempty retained graph has no witness')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ordinary', type=int, choices=(0, 1), required=True)
    parser.add_argument('--marks', type=int, default=5)
    parser.add_argument('--width', type=int, default=140)
    parser.add_argument('--controls', action='store_true', help='compare full state sets through width 24')
    parser.add_argument('--verbose', action='store_true')
    args = parser.parse_args()
    if args.width < 3 or args.marks < 1:
        parser.error('width must be at least 3 and marks positive')
    previous = None
    previous_counts = None
    for width in range(3, args.width + 1):
        kept, counts = retained_paths(width, args.ordinary, args.marks, previous)
        if args.controls and width <= 24:
            assert unrestricted_counts(width, args.ordinary, args.marks) == counts
        if args.verbose or width % 10 == 0 or not any(counts):
            print('width', width, 'bare', counts, 'retained', [len(s) for s in kept], flush=True)
        if not any(counts):
            assert not any(kept)
            gap, white, possible = white_returns(width, args.ordinary, args.marks)
            print('ordinary', args.ordinary, 'marks', args.marks, 'closing_width', width,
                  'long_gap', gap, 'candidate_white_paths_and_endpoints', white,
                  'possible_white_returns', possible)
            if previous is not None:
                start, ticks = representative(width - 1, args.ordinary, args.marks, previous)
                print('previous_width', width - 1, 'bare', previous_counts,
                      'start_row', start, 'history_length', len(ticks),
                      'marked_ticks', [i for i, t in enumerate(ticks) if t != args.ordinary])
            if possible:
                print('The reset width is computed; the early white return test is unresolved.')
            return
        previous, previous_counts = kept, counts
    print('UNRESOLVED at width cutoff', args.width)


if __name__ == '__main__':
    main()
