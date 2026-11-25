"""Independently replay short marked returns with a literal Rule 30 transition."""
import argparse
import json
from functools import cache
from pathlib import Path
from runpy import run_path

import numpy as np

HERE = Path(__file__).parent
BASE = 29
DISTANCES = run_path(str(HERE / "check-mark-spacing.py"))["two_marks"]
LOAD = run_path(str(HERE / "gptIntel-n12-read.py"))["load"]


def base_domains(rows, backward, word):
    forward = {q: m.T.tocsr() for q, m in backward.items()}
    reachable = [np.ones(len(rows), dtype=bool)]
    can_finish = [np.ones(len(rows), dtype=bool)]
    for slot in word:
        reachable.append(np.logical_or.reduce([forward[q] @ reachable[-1] for q in slot]))
    for slot in reversed(word):
        can_finish.append(np.logical_or.reduce([backward[q] @ can_finish[-1] for q in slot]))
    return [a & b for a, b in zip(reachable, reversed(can_finish), strict=True)]


def tick(row, boundary):
    left = (row << 1) | boundary
    right = row >> 1
    # The four 1 entries of the elementary-rule truth table.
    return ((~left & ~row & right) | (~left & row & ~right) |
            (~left & row & right) | (left & ~row & ~right))


@cache
def tails(ticks):
    return np.arange(1 << ticks, dtype=np.uint64) << 30


def possible_next(source, q, desired):
    ticks = q + 1
    low_mask = (1 << (30 - ticks)) - 1
    drive = [1] + [0] * q

    def evolve(row):
        for west in drive:
            row = tick(row, west)
        return row & ((1 << 30) - 1)

    prefix = evolve(source) & low_mask
    candidates = np.array([r for r in desired if (r & low_mask) == prefix], dtype=np.uint64)
    if not candidates.size:
        return []
    result = evolve(tails(ticks) | np.uint64(source))
    return [int(r) for r in candidates if r in result]


def lifted(rows, edges, word, domains):
    index = {int(r): i for i, r in enumerate(rows)}
    initial = np.flatnonzero(domains[0])
    parents = [{int(rows[j]) | (b << BASE): None for j in initial for b in (0, 1)}]
    for t, choices in enumerate(word):
        prior = parents[-1]
        next_rows = {}
        for source in sorted(prior):
            i = index[source & ((1 << BASE) - 1)]
            for q in choices:
                graph = edges[q]
                live = [j for j in graph.indices[graph.indptr[i]:graph.indptr[i+1]]
                        if domains[t+1][j]]
                expected = [int(rows[j]) | (b << BASE) for j in live for b in (0, 1)]
                for target in possible_next(source, q, expected):
                    next_rows.setdefault(target, (source, q))
        parents.append(next_rows)
        if not next_rows:
            break
    return parents


def check(path, distance, run_lift):
    rows, edges = LOAD(path)
    word = DISTANCES(distance)
    domains = base_domains(rows, edges, word)
    colour = ((rows & 1) == 0) | ((rows & 6) == 0)
    result = dict(distance=distance, base_counts=[int(s.sum()) for s in domains],
                  second_mark_black=int((domains[distance+7] & colour).sum()),
                  second_mark_white=int((domains[distance+7] & ~colour).sum()))
    if not run_lift:
        return result
    paths = lifted(rows, edges, word, domains)
    result["lift_counts"] = list(map(len, paths))
    if paths[-1]:
        current = min(paths[-1])
        witness = [current]
        labels = []
        for layer in reversed(paths[1:]):
            current, q = layer[current]
            witness.append(current)
            labels.append(q)
        result["witness"] = dict(rows=witness[::-1], gaps=labels[::-1])
    else:
        stop = len(paths) - 1
        result["obstruction"] = dict(
            first_empty_slot=stop,
            preceding_slots=[sorted(p) for p in paths[max(0,stop-3):stop]],
            preceding_base_rows=[rows[s].tolist() for s in domains[max(0,stop-3):stop+1]],
            incoming_gaps=word[stop-1],
            destination_from_each_value={
                r: [possible_next(r, q, [int(s) | (b << BASE) for s in rows[domains[stop]]
                                         for b in (0, 1)]) for q in word[stop-1]]
                for r in sorted(set(v for s in rows[domains[stop-1]]
                                    for v in (int(s), int(s) | (1 << BASE))))
            },
        )
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("graph", type=Path)
    parser.add_argument("distance", type=int)
    parser.add_argument("--base-only", action="store_true")
    args = parser.parse_args()
    print(json.dumps(check(args.graph, args.distance, not args.base_only)))
