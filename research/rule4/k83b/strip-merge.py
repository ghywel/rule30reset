"""Merge equivalent labeled futures and union the physical row sets within each class.

The output uses the same certificate format as strip-cover and must pass strip-check.
Usage: python strip-merge.py original.bin merged.bin
"""
import argparse
import struct
from pathlib import Path

import numpy as np

HEADER = struct.Struct("<8sIIQQ")
PREFIX = struct.Struct("<BQ4I")
ABSENT = (1 << 32) - 1


def widen(mask, source_width, target_width):
    for width in range(source_width, target_width):
        mask |= mask << (1 << width)
    return mask


def read(path):
    with path.open("rb") as f:
        magic, width, size, num, den = HEADER.unpack(f.read(HEADER.size))
        assert magic == b"R30B4V01"
        edges = np.empty((size, 4), dtype=np.uint32)
        rows = []
        for i in range(size):
            w, v, *outgoing = PREFIX.unpack(f.read(PREFIX.size))
            edges[i] = outgoing
            mask = int.from_bytes(f.read(8 * (((1 << w) + 63)//64)), "little")
            rows.append((w, v, mask))
        assert not f.read(1)
    return width, num, den, rows, edges


def partition(edges):
    n = len(edges)
    labels = np.zeros(n+1, dtype=np.uint32)
    labels[-1] = 1
    lookup = np.where(edges == ABSENT, n, edges)
    while True:
        sig = labels[lookup]
        order = np.lexsort(sig.T)
        changed = np.any(sig[order[1:]] != sig[order[:-1]], axis=1)
        classes = 1 + int(np.sum(changed))
        updated = np.empty_like(labels)
        updated[order[0]] = 0
        updated[order[1:]] = np.cumsum(changed)
        updated[-1] = classes
        if classes == labels[-1]:
            # Output state zero must be the original universal initial state.
            first = updated[0]
            zeros = updated == 0
            updated[updated == first] = 0
            updated[zeros] = first
            return updated[:-1], classes
        labels = updated


def merge(source, output):
    width, num, den, rows, edges = read(source)
    group, nc = partition(edges)
    geometry = [0] * nc
    weights = [0] * nc
    for i, (w, v, mask) in enumerate(rows):
        c = group[i]
        geometry[c] |= widen(mask, w, width)
        weights[c] = max(weights[c], v)
    representatives = np.zeros(nc, dtype=np.int64)
    representatives[group] = np.arange(len(group))
    dest = edges[representatives].copy()
    live = dest != ABSENT
    dest[live] = group[dest[live]]
    # Store only relevant eastern bits. Keep enough bits to check all outgoing rows.
    widths = np.full(nc, width, dtype=np.int32)
    for i, m in enumerate(geometry):
        w = width
        while w > 1:
            half = 1 << (w-1)
            lo = m & ((1 << half)-1)
            if lo != m >> half:
                break
            m = lo
            w -= 1
        widths[i] = w
        geometry[i] = m
    original_widths = widths.copy()
    while True:
        nxt = np.append(widths, 0)[np.where(live, dest, nc)].max(axis=1)
        new = np.maximum(widths, nxt-1)
        if np.array_equal(widths, new):
            break
        widths = new
    with output.open("wb") as f:
        f.write(HEADER.pack(b"R30B4V01",width,nc,num,den))
        for i in range(nc):
            w = int(widths[i])
            m = widen(geometry[i], int(original_widths[i]), w)
            f.write(PREFIX.pack(w,weights[i],*dest[i]))
            f.write(m.to_bytes(8 * (((1 << w)+63)//64),"little"))
    print(f"{len(rows)} states -> {nc} states; integer rate bound {num}/{den}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    merge(args.source, args.output)
