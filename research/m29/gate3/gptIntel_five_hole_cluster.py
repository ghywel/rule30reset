#!/usr/bin/env python3
"""Five white ticks, four short gaps and a long final gap, by explicit row orbits.

Read from immediately before the first hole. For the big gap every initial
row is on the constantly black input cycle. Enumerate that cycle's possible
phases, then follow the cluster and the transient back to the same cycle.
Choose the phase of the next cluster by the length of the final gap modulo
the cycle period. Orbits of this finite map give every possible periodic lift.
"""
import argparse
from functools import lru_cache
from itertools import product

from claudeCloud_excursions import excursion, first_resets
from gptIntel_three_holes import base_cycles
from gptIntel_three_pulses import first_catch, step


def replay(gaps, width):
    word = ''.join('0' + '1'*(gap-1) for gap in gaps)
    wheels, white = excursion(word, width)
    catches = first_resets(wheels[:-1] if white else wheels)
    assert None not in catches
    return max(catches), catches.index(max(catches))


def has_directed_cycle(edges):
    """Kahn pruning on a tiny adjacency list (one vertex per anchor phase)."""
    live = set(range(len(edges)))
    while live:
        incoming = {j for i in live for j in edges[i] if j in live}
        if live == incoming:
            return True
        live = incoming
    return False


def verify(width=59, short=8, mixed=False):
    cycles = base_cycles(width)
    if len(cycles) != 1:
        raise ValueError('this certificate assumes one anchor cycle')
    anchors, delays = cycles[0]
    indices = {row: i for i, row in enumerate(anchors)}
    period = len(anchors)
    assert period % 2 == 0
    threshold = max(delays) + period + 1
    mask = (1 << width) - 1
    anchor_cover = 0
    for row in anchors:
        anchor_cover |= row
    white_graphs = {wheel: [set() for _ in anchors] for wheel in range(1, width+1)
                    if not anchor_cover & (1 << (wheel-1))}
    largest_mixed_catch = 0
    mixed_bare = 0

    @lru_cache(maxsize=None)
    def catch(row):
        return first_catch(row, width)

    @lru_cache(maxsize=None)
    def ordinary_tail(row):
        cover = anchor_cover
        latest = max(map(catch, anchors))
        bare = any(catch(x) == 0 for x in anchors)
        length = 0
        while row not in indices:
            cover |= row
            first = catch(row)
            bare |= not first
            latest = max(first, latest)
            row = step(row, mask) ^ 1
            length += 1
            assert length <= max(delays)
        return indices[row], length, cover, latest, bare

    classes = orbits = peak = worst_transient = 0
    witness = None
    for gaps in product(range(1, short+1), repeat=4):
        segments = []
        for row in anchors:
            cover, latest, bare = row, catch(row), not catch(row)
            for gap in gaps:
                for t in range(gap):
                    row = step(row, mask) ^ (t != 0)
                    cover |= row
                    first = catch(row)
                    latest = max(first, latest)
                    bare |= not first
            # Fifth white input, then the long ordinary (black) stretch.
            index, length, tail_cover, tail_latest, tail_bare = ordinary_tail(step(row, mask))
            segments.append((index, length, cover | tail_cover, max(latest, tail_latest), bare or tail_bare))
            worst_transient = max(worst_transient, length)

        for gap in range(threshold, threshold + period):
            if mixed:
                # In a mixed word an individual cluster's black weight may be
                # either parity, irrespective of the total source parity.
                for i, (index, length, panel, last, bare) in enumerate(segments):
                    mixed_bare += int(bare)
                    largest_mixed_catch = max(largest_mixed_catch, last)
                    endpoint = (index + gap-1 - length) % period
                    for wheel, edges in white_graphs.items():
                        if not panel & (1 << (wheel-1)):
                            edges[i].add(endpoint)
            if (sum(gaps) + gap) % 2:
                continue
            classes += 1
            # Each long gap spends gap-1 black inputs after its white input.
            successor = [(index + gap-1 - length) % period for index, length, *_ in segments]
            remaining = set(range(period))
            while remaining:
                start = next(iter(remaining))
                seen = set()
                while start in remaining:
                    remaining.remove(start)
                    seen.add(start)
                    start = successor[start]
                if start not in seen:
                    continue
                i = start
                cover = latest = 0
                while True:
                    _, _, panel, last, bare = segments[i]
                    assert not bare, (gaps, gap, i, 'bare at width')
                    latest = max(latest, last)
                    cover |= panel
                    i = successor[i]
                    if i == start:
                        break
                # Every wheel through the closing wheel was black at least
                # once. A true earlier permanently white wheel is impossible.
                assert cover & ((1 << latest)-1) == (1 << latest)-1, (gaps, gap, start, 'early white')
                orbits += 1
                if latest > peak:
                    peak, witness = latest, gaps+(gap,)
    exact, phase = replay(witness, width)
    assert exact == peak
    print(f'width={width} transient={max(delays)} period={period} threshold={threshold} '
          f'four_gaps=1..{short} representatives={classes} orbits={orbits} '
          f'longest_observed_transient={worst_transient} peak={peak} gaps={witness} phase={phase}')
    if mixed:
        print(f'mixed starts={short**4 * period**2} bare={mixed_bare} peak={largest_mixed_catch}', flush=True)
        for wheel, edges in white_graphs.items():
            print(f'wheel={wheel} edges={sum(len(e) for e in edges)} cycle={has_directed_cycle(edges)}')
        assert mixed_bare == 0
        assert all(not has_directed_cycle(edges) for edges in white_graphs.values())
    return peak


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--width', type=int, default=59)
    p.add_argument('--short', type=int, default=8)
    p.add_argument('--mixed', action='store_true')
    verify(**vars(p.parse_args()))
