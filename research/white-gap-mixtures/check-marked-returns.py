"""Check the marked second-white sample on consecutive N12 factors in a recurrent strip."""
import hashlib
import itertools
import json
import sys
from pathlib import Path
from runpy import run_path

import numpy as np


def advance(edges, state, word):
    for gap in word:
        state = edges[gap] @ state
    return state


def check(path):
    load = run_path(str(Path(__file__).with_name("gptIntel-n12-read.py")))["load"]
    rows, backward = load(path)
    forward = {q: edges.T.tocsr() for q, edges in backward.items()}
    all_rows = np.ones(len(rows), dtype=bool)
    # Evolve the three nearest cells twice with a black then a white boundary.
    first = 1 ^ ((rows & 1) | ((rows >> 1) & 1))
    second = (rows & 1) ^ (((rows >> 1) & 1) | ((rows >> 2) & 1))
    black = (first | second).astype(bool)
    assert np.array_equal(black, ((rows & 1) == 0) | ((rows & 6) == 0))
    colours = (~black, black)
    blocks = list(itertools.product((10, 14), (10, 12)))

    def head(a):
        return (a, 12, 14, 12, 12, 10, 9)

    def tail(b):
        return (10, b)

    def after_blocks(start):
        """Rows after each first block grouped by its own marked sample."""
        out = {}
        for a, b in blocks:
            at_mark = advance(forward, start, head(a))
            out[a, b] = [advance(forward, at_mark & c, tail(b)) for c in colours]
        return out

    # Backward masks retain only second-mark rows admitting the trailing (10,b).
    targets = {}
    for a, b in blocks:
        admits_tail = advance(backward, all_rows, reversed(tail(b)))
        targets[a, b] = [advance(backward, c & admits_tail, reversed(head(a))) for c in colours]

    def join(left, separators):
        result = []
        for block1, start_by_colour in left.items():
            for separator in separators:
                for block2, end_by_colour in targets.items():
                    matrix = [[int(np.count_nonzero(x & advance(backward, y, reversed(separator))))
                               for y in end_by_colour] for x in start_by_colour]
                    result.append(dict(first=block1, between=separator, second=block2, join_counts=matrix))
        return result

    left = after_blocks(all_rows)
    records = join(left, [()] + [(q,) for q in range(9, 17)])
    # Remove tile boundaries with no arbitrarily long past of complete blocks.
    past = all_rows
    sizes = [int(past.sum())]
    while True:
        reachable = np.logical_or.reduce([s for ends in left.values() for s in ends])
        assert not np.any(reachable & ~past)
        sizes.append(int(reachable.sum()))
        if np.array_equal(reachable, past):
            break
        past = reachable
        left = after_blocks(past)
    results = dict(graph_sha256=hashlib.sha256(path.read_bytes()).hexdigest(), rows=len(rows),
                   edges=sum(m.nnz for m in backward.values()), cases=records,
                   tiled_boundary_sizes=sizes, tiled_cases=join(left, [()]))
    return results


if __name__ == "__main__":
    src, dst = map(Path, sys.argv[1:])
    dst.write_text(json.dumps(check(src), indent=1) + "\n")
