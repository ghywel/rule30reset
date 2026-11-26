"""Follow all width-24 exits from X to the trap or the next cyclic component."""
import argparse
import json
from collections import Counter
from functools import cache
from pathlib import Path

from entry_cells import MASK, records
from replay import step
from tables import literal


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("scc", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    by_code, _ = records(args.scc)
    gate = args.kit / "lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean"
    trap = set(literal(gate, "trapCodes"))

    def dest(word, east):
        return step(step(word | (east << 24), 0), 1) & (2**24-1)

    # Off the listed cyclic components the exterior is acyclic. Stop at the
    # first component (it may have exits of its own) or at physical trap entry.
    @cache
    def downstream(word):
        if word & MASK in trap:
            return 1, frozenset()
        if word in by_code:
            return 0, frozenset([by_code[word]])
        times = 0
        components = set()
        for child in {dest(word, east) for east in range(4)}:
            hit, reached = downstream(child)
            times |= hit << 1
            components.update(reached)
        return times, frozenset(components)

    sources = 0
    edges = []
    for word, label in by_code.items():
        if label != 519:
            continue
        before = len(edges)
        for east in range(4):
            child = dest(word, east)
            if by_code.get(child) == 519:
                continue
            hit, reached = downstream(child)
            assert 519 not in reached
            delays = [d+1 for d in range(hit.bit_length()) if hit >> d & 1]
            edges.append([word, east, child, delays, sorted(reached)])
        sources += before != len(edges)
    print("exit sources, assignments, distinct successors:", sources, len(edges),
          len({e[2] for e in edges}))
    print("first cyclic targets:", Counter(tuple(e[4]) for e in edges).most_common(25))
    bounded = [e for e in edges if not e[4]]
    print("trap guaranteed:", len(bounded), "unique delay:", sum(len(e[3]) == 1 for e in bounded),
          "worst delay:", max((max(e[3]) for e in bounded), default=None))
    args.out.write_text(json.dumps(edges, separators=(",", ":")) + "\n", encoding="ascii")


if __name__ == "__main__":
    main()
