"""Shortest distance between two N12 marks, with overlap and exact physical capture controls."""
import argparse
import json
from functools import cache
from pathlib import Path
from runpy import run_path

import numpy as np

HERE = Path(__file__).parent
ALL = tuple(range(9, 17))
FACTOR = ((10, 14), (12,), (14,), (12,), (12,), (10,), (9,), (10,), (10, 12))


def two_marks(distance):
    allowed = [set(ALL) for _ in range(distance + len(FACTOR))]
    for start in (0, distance):
        for offset, letters in enumerate(FACTOR):
            allowed[start + offset].intersection_update(letters)
    return tuple(tuple(sorted(s)) for s in allowed)


def strip(path):
    load = run_path(str(HERE / "gptIntel-n12-read.py"))["load"]
    rows, edges = load(path)
    forward = {q: m.T.tocsr() for q, m in edges.items()}

    @cache
    def union(letters):
        return sum(forward[q] for q in letters).tocsr()

    counts = []
    for distance in range(1, 18):
        word = two_marks(distance)
        if not all(word):
            counts.append(0)
            continue
        states = [np.ones(len(rows), bool)]
        for letters in word:
            states.append(union(letters) @ states[-1])
            if not states[-1].any():
                break
        counts.append(int(states[-1].sum()))
        if not counts[-1]:
            continue
        dest = int(np.flatnonzero(states[-1])[0])
        path_rows, labels = [dest], []
        for letters, source in reversed(list(zip(word, states[:-1], strict=True))):
            for q in letters:
                m = forward[q]
                pred = m.indices[m.indptr[dest]:m.indptr[dest + 1]]
                valid = pred[source[pred]]
                if len(valid):
                    dest = int(valid[0])
                    path_rows.append(dest)
                    labels.append(q)
                    break
            else:
                raise AssertionError("missing witness predecessor")
        path_rows.reverse()
        labels.reverse()
        assert all(q in allowed and edges[q][i, j] for q, allowed, i, j in
                   zip(labels, word, path_rows[:-1], path_rows[1:], strict=True))
        return dict(counts=counts, first=distance, gaps=labels, rows=rows[path_rows].tolist())
    raise AssertionError("I82 projects a return within 17 gaps")


def capture(width):
    # Use all strip rows and both free exterior bits at every tick.
    kit = run_path(str(HERE / "claudeCloud_three_gap_upper.py"))
    good = kit["GSET"]
    size = 1 << width
    all_rows = np.arange(size, dtype=np.uint32)
    trans = {}
    for driver in (0, 1):
        for exterior in (0, 1):
            trans[driver, exterior] = (((all_rows << 1) | driver) ^
                                       (all_rows | (all_rows >> 1) | (exterior << (width - 1)))) & (size - 1)

    def tick(rows, driver):
        return np.union1d(trans[driver, 0][rows], trans[driver, 1][rows])

    def advance(rows, letters):
        current = tick(rows, 1)
        ends = []
        for q in range(1, max(letters) + 1):
            current = tick(current, 0)
            if q in letters:
                ends.append(current)
        return np.unique(np.concatenate(ends))

    @cache
    def image(word):
        if not word:
            return all_rows
        return advance(image(word[:-1]), word[-1])

    # Cross-check the existing independently implemented tick propagation on one
    # positive and one negative three-gap control before accepting any distances.
    for gaps in [(16, 16, 16), (9, 9, 9)]:
        assert np.array_equal(image(tuple((q,) for q in gaps)), kit["reach"](gaps, width))

    records = []
    for distance in range(1, 18):
        word = two_marks(distance)
        if all(word):
            states = image(word)
            low = np.unique(states & 255)
            outside = low[~good[low]]
            records.append(dict(distance=distance, end_rows=len(states), low8=low.tolist(),
                                outside_G=outside.tolist()))
    return records


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=["strip", "capture"])
    parser.add_argument("graph_dir", type=Path)
    parser.add_argument("low", type=int)
    parser.add_argument("high", type=int)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    with args.output.open("w") as out:
        for width in range(args.low, args.high + 1):
            result = strip(args.graph_dir / f"g{width}.bin") if args.mode == "strip" else capture(width)
            print(json.dumps(dict(width=width, result=result)), file=out, flush=True)
