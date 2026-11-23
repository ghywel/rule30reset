"""Recurrent kick patterns outside the 16-cell trap at increasing strip widths."""

import argparse
from collections import Counter
from functools import reduce
import json
from math import gcd
from pathlib import Path

import networkx as nx
import numpy as np

from wheel_bridge import table


def successors(windows, width):
    """Two physical ticks. The free eastern inputs are chosen independently at each tick."""
    mask = (1 << width) - 1
    for east0 in (0, 1):
        row = windows | (east0 << width)
        mid = ((row << 1) ^ (row | (row >> 1))) & mask
        for east1 in (0, 1):
            row = mid | (east1 << width)
            yield (((row << 1) | 1) ^ (row | (row >> 1))) & mask


def arrivals(phases, successor):
    # State r means that r samples have elapsed since the most recent kick.
    # Only states 2 and 4 may enter another kick (return to state zero).
    return np.where(successor & 1, (phases & 20) != 0, (phases << 1) & 30).astype(np.uint8)


def reachable_core(width, trap):
    n = 1 << width
    inside = np.zeros(65536, dtype=bool)
    inside[trap] = True
    one = np.where(inside, 0, np.where(np.arange(65536) & 1, 1, 30)).astype(np.uint8)
    phase = np.tile(one, n // 65536)
    rounds = 0
    while True:
        nxt = np.zeros_like(phase)
        for start in range(0, n, 1 << 17):
            present = phase[start:start + (1 << 17)]
            idx = np.flatnonzero(present).astype(np.uint32)
            if not len(idx):
                continue
            states = present[idx]
            for v in successors(idx + start, width):
                keep = ~inside[v & 65535]
                np.bitwise_or.at(nxt, v[keep], arrivals(states[keep], v[keep]))
        if np.array_equal(nxt, phase):
            break
        phase = nxt
        rounds += 1
    # The fixed point can still contain exits from recurrent components.
    # Only edges internal to a cyclic SCC can be traversed infinitely often.
    graph = nx.DiGraph()
    for w in np.flatnonzero(phase).tolist():
        for r in range(5):
            if not (int(phase[w]) & (1 << r)):
                continue
            graph.add_node((w, r))
            for v in successors(w, width):
                if v & 1:
                    if r not in (2, 4):
                        continue
                    target = 0
                else:
                    if r == 4:
                        continue
                    target = r + 1
                if int(phase[v]) & (1 << target):
                    graph.add_edge((w, r), (v, target))
    return graph, rounds


def period_necklace(word):
    primitive = next(word[:l] for l in range(1, len(word)+1)
                     if len(word) % l == 0 and word[:l] * (len(word)//l) == word)
    return min(primitive[i:] + primitive[:i] for i in range(len(primitive)))


def component_record(graph, nodes):
    sub = graph.subgraph(nodes)
    root = min(nodes)
    levels = nx.single_source_shortest_path_length(sub, root)
    period = reduce(gcd, (abs(levels[u] + 1 - levels[v]) for u, v in sub.edges), 0)
    assert period > 0
    symbols = [set() for _ in range(period)]
    for node in nodes:
        symbols[levels[node] % period].add(str(node[0] & 1))
    word = None
    if all(len(s) == 1 for s in symbols):
        word = period_necklace("".join(next(iter(s)) for s in symbols))
    return {"vertices": len(nodes), "edges": sub.number_of_edges(), "period": period,
            "five_edges": sum(u[1] == 4 and v[1] == 0 for u, v in sub.edges),
            "gate_necklace": word}


def cyclic_components(graph):
    return [nodes for nodes in nx.strongly_connected_components(graph)
            if len(nodes) > 1 or any(graph.has_edge(x, x) for x in nodes)]


def lift(nodes, width):
    candidates = nodes | {(w + (1 << (width-1)), r) for w, r in nodes}
    graph = nx.DiGraph()
    for w, r in candidates:
        for v in successors(w, width):
            if v & 1 and r in (2, 4):
                target = (v, 0)
            elif not v & 1 and r < 4:
                target = (v, r + 1)
            else:
                continue
            if target in candidates:
                graph.add_edge((w, r), target)
    return graph


def describe(graph, components, width, rounds):
    comps = [component_record(graph, nodes) for nodes in components]
    groups = Counter(json.dumps(c, sort_keys=True) for c in comps)
    return {"width": width, "image_rounds": rounds, "surviving_sample_states": len(graph),
            "cyclic_scc": len(comps), "scc_with_fives": sum(c["five_edges"] > 0 for c in comps),
            "scc_with_variable_output": sum(c["gate_necklace"] is None for c in comps),
            "component_types": [dict(json.loads(s), count=count) for s, count in sorted(groups.items())]}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("widths", type=int, nargs="+")
    parser.add_argument("--lift-through", type=int,
                        help="Lift the last width by one column at a time, stopping when no 5-gap recurs.")
    args = parser.parse_args()
    trap = table(args.kit, "trapCodes", "Rule30Certificates/GateTrap")
    for w in args.widths:
        graph, rounds = reachable_core(w, trap)
        components = cyclic_components(graph)
        print(json.dumps(describe(graph, components, w, rounds)), flush=True)
    if args.lift_through:
        for w in range(w + 1, args.lift_through + 1):
            graph = lift(set.union(*components), w)
            components = cyclic_components(graph)
            record = describe(graph, components, w, None)
            print(json.dumps(record), flush=True)
            if not record["scc_with_fives"]:
                break
