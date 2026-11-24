"""Replay the single-lane N12 test on one frozen all-gap graph of width 29 to 32."""

import hashlib
import json
import sys
from pathlib import Path

import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components


def load(path):
    with path.open("rb") as f:
        read = lambda n: np.fromfile(f, dtype="<u4", count=n)
        count = int(read(1)[0])
        rows = read(count)
        by_gap = {}
        for gap in range(9, 17):
            n = int(read(1)[0])
            offsets, indices = read(count + 1), read(n)
            assert offsets[0] == 0 and offsets[-1] == n and (indices < count).all()
            by_gap[gap] = csr_matrix((np.ones(n, dtype=bool), indices, offsets), shape=(count, count))
        assert not f.read(1)
    graph = sum(by_gap.values())
    assert connected_components(graph, directed=True, connection="strong", return_labels=False) == 1
    assert by_gap[9].nnz and by_gap[10].nnz
    return rows, by_gap


def ambiguous_words(edges, colour):
    # A prefix can be prepended only if both terminal colours remain possible.
    states = {(): (colour, ~colour)}
    counts = []
    for _ in range(8):
        next_states = {}
        for word, (black, white) in states.items():
            for gap, m in edges.items():
                b = m @ black
                if b.any():
                    w = m @ white
                    if w.any():
                        next_states[(gap,) + word] = (b, w)
        states = next_states
        counts.append(len(states))
    return counts, sorted(states)


def nine_runs(edges, colour):
    forward = {gap: m.T.tocsr() for gap, m in edges.items()}
    contexts = [(x,) for x in range(11, 17)] + [(y, 10) for y in range(9, 17)]
    receipts = []
    for prefix in contexts:
        s = np.ones(len(colour), bool)
        for x in prefix:
            s = forward[x] @ s
        seen = {}
        j = 0
        while True:
            j += 1
            s = forward[9] @ s
            if j >= 2:
                assert not ((s & colour).any() and (s & ~colour).any())
            if not s.any():
                receipts.append([prefix, "empty", j])
                break
            key = np.packbits(s).tobytes()
            if key in seen:
                receipts.append([prefix, "repeat", j, seen[key]])
                break
            seen[key] = j
    return receipts


if __name__ == "__main__":
    src, dst = map(Path, sys.argv[1:])
    width = int(src.stem[1:])
    rows, edges = load(src)
    colour = ((rows & 1) == 0) | ((rows & 6) == 0)
    counts, words = ambiguous_words(edges, colour)
    families = {h: [w for w in words if w[-5:] == (h, 12, 12, 10, 9)] for h in (13, 14)}
    other = sorted(set(words) - set(families[13]) - set(families[14]))
    if width == 29:
        assert counts == [1, 2, 5, 6, 6, 10, 11, 17]
    if width == 32:
        assert counts == [1, 2, 5, 6, 6, 8, 11, 14]
    assert len(families[13]) == 1 and other == [(9,) * 8, (10,) + (9,) * 7]
    result = {
        "width": width,
        "graph_sha256": hashlib.sha256(src.read_bytes()).hexdigest(),
        "rows": len(rows),
        "edges": sum(m.nnz for m in edges.values()),
        "ambiguous_counts": counts,
        "ambiguous_words": words,
        "runs": nine_runs(edges, colour),
    }
    dst.write_text(json.dumps(result, indent=2) + "\n", encoding="utf8")
    print(result["rows"], result["edges"], counts, result["runs"])
