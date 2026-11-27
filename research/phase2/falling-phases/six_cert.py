"""Build and independently check a decreasing rank and periodic pair for six sites."""
from itertools import product
import networkx as nx

from pairs import cyclic_classes, varying_mask
from probe import transitions


def build(phases, steps):
    graph = nx.DiGraph()
    graph.add_nodes_from((t, s) for t in range(3) for s in range(64))
    for t, s in graph:
        allowed = sum(1 << j for j, p in enumerate(phases) if t == p)
        for dest, falls in steps[s]:
            if not falls & ~allowed:
                graph.add_edge((t, s), ((t + 1) % 3, dest))
    dag = nx.condensation(graph)
    rank = {c: k for k, c in enumerate(reversed(list(nx.topological_sort(dag))))}
    table = {}
    for c, rec in dag.nodes.data():
        nodes = rec['members']
        if len(nodes) == 1:
            # One tick changes the time phase, so these components have no internal edge.
            t, s = next(iter(nodes))
            table[t,s] = (rank[c], 0, (s & 3,))
            continue
        comp = graph.subgraph(nodes)
        classes = cyclic_classes(comp)
        varied = varying_mask(classes)
        j = next(i for i in range(5) if ((varied >> i) & 3) == 0)
        by_phase = [rows[0] >> j & 3 for rows in classes]
        start = next(iter(comp))
        distances = nx.single_source_shortest_path_length(comp, start)
        p = next(d for d in range(1, len(classes)+1) if all(
            bit == by_phase[(k+d) % len(classes)] for k, bit in enumerate(by_phase)))
        for node, dist in distances.items():
            future = tuple(by_phase[(dist+k) % len(classes)] for k in range(p))
            table[node] = (rank[c], j, future)
    return table


def verify(phases, table):
    # Reconstruct every possible edge cell by cell, without consulting the graph.
    rule = (0, 1, 1, 1, 1, 0, 0, 0)
    for (t, row), (rank, j, future) in table.items():
        assert (row >> j) & 3 == future[0] and 0 <= j < 5
        for w, e in product(range(2), repeat=2):
            cells = [w] + [(row >> i) & 1 for i in range(6)] + [e]
            nxt = [rule[4*a + 2*b + c] for a, b, c in zip(cells, cells[1:], cells[2:])]
            if any(cells[i+1] and not b and phases[i] != t for i,b in enumerate(nxt)):
                continue
            dest = sum(b << i for i,b in enumerate(nxt))
            nr, nj, nf = table[(t+1)%3, dest]
            assert nr < rank or (nr == rank and nj == j and nf == future[1:] + future[:1])


if __name__ == '__main__':
    steps = [set() for _ in range(64)]
    for s, d, f in transitions(6):
        steps[s].add((d, f))
    periods = set()
    for rest in product(range(3), repeat=5):
        phases = (0, *rest)
        table = build(phases, steps)
        verify(phases, table)
        periods.update(len(f) for _, _, f in table.values())
    print('243 tables; 46,656 time-phase/row states; all allowed edges verified.')
    print('periods in the pair certificates:', sorted(periods))
