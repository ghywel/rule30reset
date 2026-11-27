"""First test for I295.1 against Galindo's width-12 F and E, using Python 3."""
import argparse
from itertools import product
from pathlib import Path
import re


WIDTH = 12
GAPS = (7, 9)


def members(source, name):
    pattern = rf"^def {name} : Nat := (0x[0-9a-fA-F]+)$"
    bitmap = int(re.search(pattern, source, re.MULTILINE)[1], 16)
    return {i for i in range(2**WIDTH) if bitmap >> i & 1}


def macro(rows, gap):
    for wall in [1] + [0] * gap:
        rows = {(((r << 1) | wall) ^ (r | (r >> 1) | (east << (WIDTH-1))))
                & (2**WIDTH - 1) for r in rows for east in (0, 1)}
    return rows


def reachable(root, edges):
    seen = {root}
    todo = [root]
    while todo:
        new = edges[todo.pop()] - seen
        todo.extend(new)
        seen.update(new)
    return seen


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    source = (parser.parse_args().kit / "lean/Ruliology/CellularAutomata/"
              "Rule30Certificates/MixedGapClocks.lean").read_text(encoding="utf-8")
    outer, inner = members(source, "F"), members(source, "E")
    assert inner <= outer and macro(outer, 22) <= inner
    for gap in GAPS:
        assert macro(set(range(2**WIDTH)), gap) <= outer
        assert macro(inner, gap) <= inner
    outside = outer - inner
    arcs = {r: {q: macro({r}, q) - inner for q in GAPS} for r in outside}
    edges = {r: set.union(*labels.values()) for r, labels in arcs.items()}
    reverse = {r: set() for r in outside}
    for r in outside:
        for dest in edges[r]:
            reverse[dest].add(r)
    remaining, mixed = outside.copy(), []
    while remaining:
        root = min(remaining)
        scc = reachable(root, edges) & reachable(root, reverse)
        remaining -= scc
        if all(any(arcs[r][q] & scc for r in scc) for q in GAPS):
            mixed.append((min(scc), len(scc)))
    print(f"F={len(outer)}, E={len(inner)}, mixed components (min code, size)={mixed}")
    for length in range(1, 7):
        resets = []
        for word in product(GAPS, repeat=length):
            current = outside
            for q in word:
                current = {dest for r in current for dest in arcs[r][q]}
            if not current:
                resets.append(word)
        print(f"length {length}: {len(resets)} reset words, first {resets[:1]}")


if __name__ == "__main__":
    main()
