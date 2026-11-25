"""Bound the physical gate growth rate with exact path counts on factor overlaps."""

import argparse
from collections import defaultdict
from pathlib import Path
from fractions import Fraction


def overlap_graph(words, context, readings):
    suffix_mask = (1 << context) - 1
    shift = readings - context - 1
    edges = defaultdict(set)
    for word in words:
        block = word >> shift
        edges[block >> 1].add(block & suffix_mask)
    vertices = sorted(edges)
    index = {word: i for i, word in enumerate(vertices)}
    # A dead end contributes no continuations. All physical walks continue.
    return [[index[dst] for dst in edges[src] if dst in index] for src in vertices]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("words", type=Path)
    parser.add_argument("readings", type=int)
    parser.add_argument("context", type=int)
    parser.add_argument("rate", type=Fraction)
    parser.add_argument("power", type=int)
    args = parser.parse_args()
    if not 0 < args.context < args.readings or args.rate <= 1:
        raise ValueError("need 0 < context < readings and rate greater than one")
    with args.words.open(encoding="utf-8-sig") as stream:
        words = {int(line) for line in stream}
    graph = overlap_graph(words, args.context, args.readings)
    print(f"factors={len(words)} vertices={len(graph)} live_edges={sum(map(len, graph))}")
    counts = [1] * len(graph)
    p, q = args.rate.numerator, args.rate.denominator
    for k in range(1, args.power + 1):
        counts = [sum(counts[next_vertex] for next_vertex in row) for row in graph]
        largest = max(counts)
        if largest * q**k <= p**k:
            print(f"power={k} max_extensions={largest} rate={p}/{q}")
            return
    print(f"power={args.power} max_extensions={max(counts)} target not certified")
    raise SystemExit(1)


if __name__ == "__main__":
    main()
