"""Fit a period-three pair tag to each component of the six-column phase graph.

Each entry is 512 * rank + tag in the same 17-bit layout as SixTables.lean.
With --output, write one packed hexadecimal integer for each normalized
assignment and phase, in increasing assignment and phase order.
"""
import argparse
from collections import Counter
from itertools import product
from pathlib import Path

import networkx as nx

from probe import transitions


def matching_tags():
    options = {}
    for t in range(3):
        for row in range(64):
            options[t, row] = {
                j + 8 * bits for j in range(5) for bits in range(64)
                if ((row >> j) & 3) == ((bits >> (2*t)) & 3)
            }
    return options


def build(phases, steps, options):
    graph = nx.DiGraph()
    graph.add_nodes_from(options)
    for t in range(3):
        allowed = sum(1 << j for j, p in enumerate(phases) if p == t)
        for row, dest, falls in steps:
            if (falls & ~allowed) == 0:
                graph.add_edge((t, row), ((t+1) % 3, dest))
    dag = nx.condensation(graph)
    assigned = {}
    for c in reversed(list(nx.topological_sort(dag))):
        members = dag.nodes[c]['members']
        choices = set.intersection(*(options[node] for node in members))
        assert choices, (phases, members)
        children = [assigned[child] for child in dag.successors(c)]
        def score(tag):
            return max((rank + (other != tag) for rank, other in children), default=0)
        assigned[c] = min((score(tag), tag) for tag in choices)
    return {node: assigned[c] for node, c in dag.graph['mapping'].items()}


def pack_row(table, t):
    return sum((512*rank + tag) << (17*row) for row in range(64)
               for rank, tag in [table[t, row]])


def verify(phases, masks):
    # Re-read the serialized entries and reconstruct the successors cell by cell.
    rule = (0, 1, 1, 1, 1, 0, 0, 0)
    def entry(t, row):
        return divmod((masks[t] >> (17*row)) & 0x1ffff, 512)
    checked = 0
    for t in range(3):
        for row in range(64):
            rank, tag = entry(t, row)
            bits, j = divmod(tag, 8)
            assert j < 5 and ((row >> j) & 3) == ((bits >> (2*t)) & 3)
            for west, east in product(range(2), repeat=2):
                cells = [west, *[(row >> i) & 1 for i in range(6)], east]
                nxt = [rule[4*l + 2*c + r] for l,c,r in zip(cells, cells[1:], cells[2:])]
                if any(old and not new and phase != t
                       for old, new, phase in zip(cells[1:7], nxt, phases)):
                    continue
                dest = sum(bit << i for i, bit in enumerate(nxt))
                child_rank, child_tag = entry((t+1) % 3, dest)
                assert child_rank <= rank and (child_rank < rank or child_tag == tag)
                checked += 1
    return checked


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    options = matching_tags()
    steps = list(transitions(6))
    peaks = Counter()
    packed = []
    checks = 0
    for a in range(243):
        phases = (0,) + tuple((a // (3**j)) % 3 for j in range(5))
        table = build(phases, steps, options)
        peak = max(rank for rank, _ in table.values())
        assert peak < 256
        peaks[peak] += 1
        masks = [pack_row(table, t) for t in range(3)]
        checks += verify(phases, masks)
        packed.extend(hex(mask) for mask in masks)
    if args.output:
        args.output.write_text('\n'.join(packed) + '\n', encoding='ascii', newline='\n')
    print(f"Maximum rank {max(peaks)}. Assignments grouped by maximum: {dict(sorted(peaks.items()))}.")
    print(f"Verified {243*3*64} states and {checks} allowed exterior-bit transitions.")


if __name__ == '__main__':
    main()
