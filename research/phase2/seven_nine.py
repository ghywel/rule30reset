"""First test for I295.1 against Galindo's width-12 F and E, using Python 3."""
import argparse
from collections import deque
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


def audit_reset(outer, inner, word):
    """Independently enumerate up to the discovered length with the literal rule."""
    rule = (0, 1, 1, 1, 1, 0, 0, 0)

    def next_code(code, wall, east):
        cells = [wall] + [(code >> i) & 1 for i in range(WIDTH)] + [east]
        neighbours = zip(cells, cells[1:], cells[2:])
        return sum(rule[4 * l + 2 * c + r] << i
                   for i, (l, c, r) in enumerate(neighbours))

    steps = {(r, w): {next_code(r, w, e) for e in (0, 1)}
             for r in range(2**WIDTH) for w in (0, 1)}
    images = {}
    for r in outer:
        for q in GAPS:
            frontier = {r}
            for wall in [1] + [0] * q:
                frontier = {v for u in frontier for v in steps[u, wall]}
            assert frontier == macro({r}, q)
            images[r, q] = frontier

    def advance(rows, q):
        return set().union(*(images[r, q] for r in rows))

    matches = []

    def visit(prefix, rows):
        if prefix and rows <= inner:
            matches.append(prefix)
        if len(prefix) < len(word):
            for q in GAPS:
                visit(prefix + (q,), advance(rows, q))

    visit((), outer)
    assert word in matches and all(len(w) == len(word) for w in matches)
    print(f"all shortest resets: {matches}")
    rows = outer
    for q in word:
        rows = advance(rows, q)
    print(f"final full image: {len(rows)} states, {len(rows - inner)} outside E")


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
    # A nonempty fixed set lets an avoiding path take either requested label.
    safe = outside.copy()
    while True:
        keep = {r for r in safe if all(arcs[r][q] & safe for q in GAPS)}
        if keep == safe:
            break
        safe = keep
    print(f"greatest set with an avoiding successor for each label: {len(safe)}")
    for length in range(1, 7):
        resets = []
        for word in product(GAPS, repeat=length):
            current = outside
            for q in word:
                current = {dest for r in current for dest in arcs[r][q]}
            if not current:
                resets.append(word)
        print(f"length {length}: {len(resets)} reset words, first {resets[:1]}")
    # The image set records all possible avoiding states after reading a word.
    # Equal image sets have identical futures, irrespective of the prefix.
    start = frozenset(outside)
    todo, seen = deque([(start, ())]), {start}
    while todo:
        states, word = todo.popleft()
        for q in GAPS:
            after = frozenset(v for u in states for v in arcs[u][q])
            if not after:
                print(f"shortest reset: {word + (q,)}")
                audit_reset(outer, inner, word + (q,))
                return
            if after not in seen:
                seen.add(after)
                todo.append((after, word + (q,)))
    print(f"all {len(seen)} reachable images are nonempty; no reset word at any length")


if __name__ == "__main__":
    main()
