"""Count recurrent components and transient steps along allowable six-strip paths."""
from collections import Counter
from pathlib import Path
import sys

import networkx as nx

sys.path.insert(0, str(Path.cwd() / "research/phase2/falling-phases"))
from probe import transitions


def profile(assignment, steps):
    graph = nx.DiGraph()
    for t in range(3):
        graph.add_nodes_from((t, row) for row in range(64))
        allowed = sum(1 << j for j, phase in enumerate(assignment) if phase == t)
        for row, nxt, falls in steps:
            if not falls & ~allowed:
                graph.add_edge((t, row), ((t + 1) % 3, nxt))
    dag = nx.condensation(graph)
    scores = {}
    totals = {}
    for v in reversed(list(nx.topological_sort(dag))):
        recurrent = len(dag.nodes[v]["members"]) > 1
        assert recurrent or not any(graph.has_edge(n, n) for n in dag.nodes[v]["members"])
        after = {0: 0}
        for w in dag.successors(v):
            for q, b in scores[w].items():
                after[q] = max(after.get(q, 0), b)
        # With x = age+c, one recurrent visit costs at most x -> 2x.
        # A transient SCC is a single state, x -> x+1. Compose suffix costs.
        scores[v] = {q + int(recurrent): (b if recurrent else b + 2**q)
                     for q, b in after.items()}
        for q, b in scores[v].items():
            totals[q] = max(totals.get(q, 0), b)
    return totals


steps = list(transitions(6))
hist = Counter()
offsets = {}
for a in range(243):
    phases = (0,) + tuple((a // 3**j) % 3 for j in range(5))
    totals = profile(phases, steps)
    hist[max(totals)] += 1
    for q,b in totals.items():
        offsets[q] = max(offsets.get(q, 0), b)
print("maximum recurrent components per assignment (histogram):", sorted(hist.items()))
print("worst possible weighted transient offset for each recurrent count:", sorted(offsets.items()))
