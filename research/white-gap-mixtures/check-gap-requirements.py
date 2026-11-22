"""Check synchronized paths independently from a CSV of ordinary (source, gap, target) edges."""
import argparse
import csv
from collections import defaultdict, deque
from pathlib import Path

import networkx as nx


def mixed_components(edge_file, allowed, forbidden):
    graph = nx.DiGraph()
    edges = []
    with edge_file.open(newline="") as source:
        for row, gap, target in (map(int, line) for line in csv.reader(source)):
            if gap not in allowed:
                continue
            for phase in range(max(1, len(forbidden))):
                tail = forbidden[:phase] + (gap,)
                if forbidden and tail[-len(forbidden):] == forbidden:
                    continue
                new_phase = max((j for j in range(1, len(forbidden))
                                 if tail[-j:] == forbidden[:j]), default=0)
                left, right = (row, phase), (target, new_phase)
                graph.add_edge(left, right)
                edges.append((left, gap, right))
    components = list(nx.strongly_connected_components(graph))
    owner = {node: i for i, component in enumerate(components) for node in component}
    inside = defaultdict(list)
    for x, gap, y in edges:
        if owner[x] == owner[y]:
            inside[owner[x]].append((x, gap, y))
    for index, component in enumerate(components):
        local = inside[index]
        if {9, 10} <= {q for _, q, _ in local} and len({color(x) for x in component}) == 2:
            yield sorted(component), local


def color(node):
    row, _ = node
    return not (row & 1) or not (row & 6)


def closure(neighbors):
    n = len(neighbors)
    reached = {x*n + x for x in range(n)}
    pending = deque(reached)
    while pending:
        x, y = divmod(pending.popleft(), n)
        for gap, left in neighbors[x].items():
            for a in left:
                for b in neighbors[y].get(gap, ()):
                    key = min(a, b)*n + max(a, b)
                    if key not in reached:
                        reached.add(key)
                        pending.append(key)
    return reached


def verify(nodes, edges):
    n = len(nodes)
    index = {node: i for i, node in enumerate(nodes)}
    forward = [defaultdict(list) for _ in nodes]
    backward = [defaultdict(list) for _ in nodes]
    for x, gap, y in edges:
        a, b = index[x], index[y]
        forward[a][gap].append(b)
        backward[b][gap].append(a)
    starts, ends = closure(forward), closure(backward)
    common = starts & ends
    different = sum(color(nodes[pair//n]) != color(nodes[pair % n]) for pair in common)
    print(f"{n} rows, {len(edges)} edges, {len(starts)} forward, {len(ends)} backward, "
          f"{len(common)} common, {different} with different colors")
    return different == 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv", type=Path)
    parser.add_argument("--allow", default="9,10,11,12,13,14,15,16")
    parser.add_argument("--avoid", default="")
    args = parser.parse_args()
    letters = set(map(int, args.allow.split(",")))
    pattern = tuple(map(int, args.avoid.split(","))) if args.avoid else ()
    assert {9, 10} <= letters <= set(range(9, 17))
    checks = [verify(nodes, edges) for nodes, edges in mixed_components(args.csv, letters, pattern)]
    raise SystemExit(0 if all(checks) else 1)
