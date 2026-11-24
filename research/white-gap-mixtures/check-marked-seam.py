"""Check all ordinary two-gap completions at an I82 diamond's first discrepancy."""
import argparse
import json
from pathlib import Path

import numpy as np


def advance(rows, ticks):
    # The driven site pulses on the first update of each gap.
    for t in range(ticks):
        rows = ((rows << 1) | int(t == 0)) ^ (rows | (rows >> 1))
    return rows


def seam(width, left, middle, right):
    # Ten then eleven ticks can see exactly 21 cells beyond the carried row.
    mask = (1 << width) - 1
    many = 0
    least = None
    for lo in range(0, 1 << 21, 1 << 15):
        high = np.arange(lo, lo + (1 << 15), dtype=np.uint64)
        seeds = (high << width) | left
        mids = advance(seeds, 10)
        possible = (mids & mask) == middle
        ends = advance(mids[possible], 11)
        hits = seeds[possible][(ends & mask) == right]
        if hits.size and least is None:
            least = int(hits[0])
        many += hits.size
    return many, least


def replay_cells(seed, width, middle, right):
    # Shrink the exact cone cell by cell. Also return the first-neighbour
    # sample 2 ticks after the second pulse, independently of the strip code.
    cells = [seed >> i & 1 for i in range(width + 21)]
    for tick in range(1, 22):
        west = int(tick in (1, 11))
        cells = [a ^ (b | c) for a, b, c in zip([west] + cells, cells, cells[1:])]
        if tick in (10, 21):
            value = sum(bit << i for i, bit in enumerate(cells[:width]))
            assert value == (middle if tick == 10 else right)
        if tick == 12:
            sample = cells[0]
    return sample


def check(path):
    clock = json.loads(path.read_bytes())
    frames = clock['frames']
    pulse = clock['unequal_interval']
    previous, centre, following = frames[pulse-1:pulse+2]
    assert [clock['word'][frame[0]] for frame in (previous, centre)] == [9, 10]
    assert sum(clock['word'][frame[0]] + 1 for frame in frames[:pulse]) + 2 == clock['unequal_physical_tick']
    for width in sorted({27, clock['width']}):
        mask = (1 << width) - 1
        colors = []
        for lane in (1, 2):
            left, middle, right = (frame[lane] & mask for frame in (previous, centre, following))
            count, seed = seam(width, left, middle, right)
            sample = int((middle & 1) == 0 or (middle & 6) == 0)
            colors.append(sample)
            if seed is not None:
                assert replay_cells(seed, width, middle, right) == sample
            example = hex(seed) if seed is not None else 'none'
            print(f"h={max(clock['word'])} W={width} lane={lane} rows={left},{middle},{right}"
                  f" sample={sample} completions={count} seed={example}", flush=True)
        assert colors[0] != colors[1]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('diamonds', type=Path, nargs='+')
    for filename in parser.parse_args().diamonds:
        check(filename)
