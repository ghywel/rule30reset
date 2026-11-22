"""Lift only rows lying on a complete path for the specified word.

The open strip may have a different width at each sampled time. Two physical
ticks on sufficiently many input cells determine the entire next strip.
Every real row survives both sweeps and projection to any smaller width.
"""
import argparse
import re
from pathlib import Path

import numpy as np


def trap_codes(path):
    body = re.search(r"def trapCodes : List Nat := \[(.*?)\]",
                     Path(path).read_text(encoding="utf-8"), re.S)[1]
    codes = np.array(sorted(map(int, re.findall(r"\d+", body))), dtype=np.int64)
    assert len(codes) == len(np.unique(codes)) == 829
    return codes


def allowed(sorted_values, query):
    if not len(sorted_values):
        return np.zeros(len(query), dtype=bool)
    i = np.searchsorted(sorted_values, query)
    return sorted_values[np.minimum(i, len(sorted_values) - 1)] == query


def tick(row, left):
    return ((row << 1) | left) ^ (row | (row >> 1))


def successors(rows, before, after):
    mask = (1 << after) - 1
    for extra in range(1 << max(0, after + 2 - before)):
        full = rows | (extra << before)
        yield tick(tick(full, 0), 1) & mask


def sweep(layers, widths):
    for t in range(len(layers) - 1):
        images = np.unique(np.concatenate(list(successors(layers[t], *widths[t:t+2]))))
        layers[t+1] = layers[t+1][allowed(images, layers[t+1])]
        if not len(layers[t+1]):
            return False
    for t in reversed(range(len(layers) - 1)):
        supported = np.zeros(len(layers[t]), dtype=bool)
        for image in successors(layers[t], *widths[t:t+2]):
            supported |= allowed(layers[t+1], image)
        layers[t] = layers[t][supported]
    return True


def run(kit, delay, gaps, max_width, limit):
    codes = trap_codes(kit)
    samples = [-1] * delay + [1]
    for gap in map(int, gaps):
        samples += [0] * (gap - 1) + [1]
    layers = [codes if colour < 0 else codes[(codes & 1) == colour] for colour in samples]
    widths = [16] * len(layers)
    for iteration in range(max_width * len(layers)):
        alive = sweep(layers, widths)
        counts = list(map(len, layers))
        print(iteration, "width", min(widths), max(widths), "total", sum(counts),
              "largest", max(counts), "middle", counts[len(counts)//2],
              "alive", alive, flush=True)
        if not alive:
            return "EMPTY"
        # Bound the number of explicit rows in one slice by keeping its current
        # precision. A later sweep can shrink it enough to refine it again.
        proposed = [w + int(w < max_width and n <= limit//2)
                    for w, n in zip(widths, counts)]
        # Keep adjacent widths within two bits, so at most 16 images are needed.
        for i in range(1, len(proposed)):
            proposed[i] = min(proposed[i], proposed[i-1] + 2)
        for i in reversed(range(len(proposed)-1)):
            proposed[i] = min(proposed[i], proposed[i+1] + 2)
        if proposed == widths:
            return "PATH" if min(widths) == max_width else "ABSTRACT PATH"
        for i, (old,new) in enumerate(zip(widths,proposed)):
            if old != new:
                layers[i] = np.concatenate((layers[i],layers[i] | (1 << old)))
        widths = proposed
    raise AssertionError("every pass must increase a width")


if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("kit")
    cli.add_argument("delay", type=int)
    cli.add_argument("gaps")
    cli.add_argument("--width", type=int, default=46, choices=range(16,59))
    cli.add_argument("--rows-per-slice", type=int, default=65536)
    args = cli.parse_args()
    print(run(args.kit, args.delay, args.gaps, args.width, args.rows_per_slice), flush=True)
