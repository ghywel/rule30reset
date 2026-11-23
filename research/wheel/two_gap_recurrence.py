"""Find a finite strip on which every recurring 101 is eventually frequent."""
import argparse
import json
from pathlib import Path

import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components


def double(rows):
    first = (rows << 1) ^ (rows | (rows >> 1))
    return ((first << 1) | 1) ^ (first | (first >> 1))


def unresolved(rows, width, length, marker):
    """Keep only cyclic components admitting both a mark and an unmarked stretch."""
    n = len(rows)
    mask = (1 << width) - 1
    indices = np.arange(n, dtype=np.int32)
    sources, targets = [], []
    for east in range(4):
        target = double(rows | (east << width)) & mask
        j = np.minimum(np.searchsorted(rows, target), n-1)
        hits = rows[j] == target
        sources.append(indices[hits])
        targets.append(j[hits].astype(np.int32))
    src, dst = np.concatenate(sources), np.concatenate(targets)
    graph = csr_matrix((np.ones(len(src), dtype=np.uint8), (src, dst)), shape=(n,n))
    count, component = connected_components(graph, directed=True, connection="strong")
    internal = component[src] == component[dst]
    src, dst = src[internal], dst[internal]
    if marker == "101":
        mark = ((rows & 1) == 1) & ((double(rows) & 1) == 0) & ((double(double(rows)) & 1) == 1)
        needed = length - 2
    else:
        mark = (rows & 3) == 1  # spatial 10, read from the gate east
        needed = length
    marked = np.zeros(count, dtype=bool)
    marked[component[mark]] = True
    alive = ~mark
    for _ in range(needed - 1):
        previous = np.zeros(n, dtype=bool)
        previous[src[alive[dst]]] = True
        alive = previous & ~mark
    long_free = np.zeros(count, dtype=bool)
    long_free[component[alive]] = True
    keep = (marked & long_free)[component]
    # Any kept component contains a marked and an unmarked vertex, hence is cyclic.
    return rows[keep], {"width": width, "candidates": n, "remaining": int(keep.sum()),
                        "ambiguous_components": int((marked & long_free).sum())}


def check(length, maximum, marker):
    rows = np.arange(32, dtype=np.int64)
    stages = []
    for width in range(5, maximum+1):
        keep, record = unresolved(rows, width, length, marker)
        stages.append(record)
        print(record, flush=True)
        if not len(keep):
            break
        rows = np.concatenate((keep, keep | (1 << width)))
    return {"samples": length, "marker": marker, "proved": stages[-1]["remaining"] == 0, "stages": stages}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--length", type=int, default=43)
    parser.add_argument("--width", type=int, default=43)
    parser.add_argument("--marker", choices=("101","spatial10"), default="101")
    args = parser.parse_args()
    if args.length < 4 or not 5 <= args.width <= 56:
        parser.error("Use a block of at least four samples and widths between five and 56.")
    result = check(args.length, args.width, args.marker)
    args.output.write_bytes((json.dumps(result, indent=2)+"\n").encode())
