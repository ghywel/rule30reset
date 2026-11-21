"""Sharp minimum mean excursion spacing from a complete deterministic spacing table.

Each alphabet column denotes one exact unary class of loop counts. Parallel
edges with the same endpoints need only their least representative. A cycle
attaining the mean gives the upper bound. An integer potential on every
reachable state proves the matching lower bound for arbitrary infinite walks.
"""
import argparse
from fractions import Fraction
import json
from pathlib import Path


def edges_of(machine):
    classes = machine["spacing_classes"]
    transitions = machine["transitions"]
    nstates = len(transitions)
    assert nstates > 0 and machine["start"] == 0
    best = {}
    for u, row in enumerate(transitions):
        assert len(row) == len(classes)
        for cls, v in zip(classes, row):
            n = cls["first"]
            assert n >= 0 and cls["period"] >= 0 and -1 <= v < nstates
            if v != -1:
                best[u, v] = min(n, best.get((u, v), n))
    edges = [(u, v, n) for (u, v), n in sorted(best.items())]
    reached = {0}
    while True:
        wider = reached | {v for u, v, _ in edges if u in reached}
        if wider == reached:
            break
        reached = wider
    assert len(reached) == nstates
    return nstates, edges


def negative_cycle_or_potential(count, edges, bound):
    """Bellman–Ford with a zero-cost virtual source to all states."""
    potential = [0] * count
    parent = [None] * count
    for _ in range(count):
        last = None
        for u, v, n in edges:
            distance = potential[u] + n * bound.denominator - bound.numerator
            if distance < potential[v]:
                potential[v] = distance
                parent[v] = (u, v, n)
                last = v
        if last is None:
            return None, potential
    v = last
    for _ in range(count):
        v = parent[v][0]
    start, backwards = v, []
    while True:
        edge = parent[v]
        backwards.append(edge)
        v = edge[0]
        if v == start:
            break
    cycle = list(reversed(backwards))
    assert Fraction(sum(n for _, _, n in cycle), len(cycle)) < bound
    return cycle, None


def analyse(machine):
    count, edges = edges_of(machine)
    bound = Fraction(max(n for _, _, n in edges) + 1)
    witness = None
    while True:
        cycle, potential = negative_cycle_or_potential(count, edges, bound)
        if cycle is None:
            break
        witness = cycle
        bound = Fraction(sum(n for _, _, n in cycle), len(cycle))
    assert witness is not None, "no infinite walk with recurring excursions"
    p, q = bound.numerator, bound.denominator
    weights = {(u, v): n for u, v, n in edges}
    for u, v, n in edges:
        assert q*n-p + potential[u]-potential[v] >= 0
    for (u, v, n), (successor, _, _) in zip(witness, witness[1:] + witness[:1]):
        assert v == successor and weights[u, v] == n
        assert q*n-p + potential[u]-potential[v] == 0
    return {"live_states": count, "minimum_single": min(weights.values()),
            "minimum_mean_loops": str(bound), "double_steps_per_excursion": str(34+7*bound),
            "attaining_cycle": witness, "integer_potential": potential}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("machines", type=Path, nargs="+")
    args = parser.parse_args()
    expected = {"spacing_classes": [{"first": n, "period": 0} for n in (4, 6, 7)],
                "transitions": [[1, 0, 0], [-1, -1, 0]], "start": 0}
    assert analyse(expected)["double_steps_per_excursion"] == "145/2"
    for path in args.machines:
        print(json.dumps({"machine": path.name, **analyse(json.loads(path.read_text()))}, sort_keys=True))


if __name__ == "__main__":
    main()
