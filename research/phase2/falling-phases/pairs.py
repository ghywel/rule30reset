"""Check which fixed adjacent outputs are periodic in each recurrent strip component."""
from collections import deque
from itertools import product
from math import gcd

import networkx as nx

from probe import transitions


def cyclic_classes(component):
    # In a strongly connected graph the gcd of the edge discrepancies is the
    # period. Distances modulo that period advance by one on every edge.
    root = next(iter(component))
    distance = nx.single_source_shortest_path_length(component, root)
    period = 0
    for old, new in component.edges:
        period = gcd(period, distance[old] + 1 - distance[new])
    assert period > 0
    classes = [[] for _ in range(period)]
    for node, d in distance.items():
        classes[d % period].append(node[1])
    return classes


def components(width, phases, steps):
    graph = nx.DiGraph()
    for t in range(3):
        allowed = sum(1 << j for j, phase in enumerate(phases) if phase == t)
        for old, new, falls in steps:
            if falls & ~allowed == 0:
                graph.add_edge((t, old), ((t + 1) % 3, new))
    return (graph.subgraph(s) for s in nx.strongly_connected_components(graph) if len(s) > 1)


def varying_mask(classes):
    mask = 0
    for rows in classes:
        for row in rows[1:]:
            mask |= row ^ rows[0]
    return mask


def main():
    for width in range(2, 7):
        steps = list(transitions(width))
        survivors = []
        for tail in product(range(3), repeat=width-1):
            phases = (0, *tail)
            for comp in components(width, phases, steps):
                varied = varying_mask(cyclic_classes(comp))
                if all((varied >> j) & 3 for j in range(width-1)):
                    survivors.append(phases)
                    break
        print(width, len(survivors), 'of', 3**(width-1), 'first:', survivors[:4])


if __name__ == '__main__':
    main()
