"""Recover the all-length excursion-spacing and gap-factor automata of an X core.

python3 gptM5_x_spacing.py X40-dfa.txt X40-spacing.json
A = kick gaps 25, E = 33535555. An exponent counts whole copies of A *between*
two successive E blocks. A missing transition rejects. State 0 is the start.
"""
from collections import deque
import argparse
import json
from math import lcm
from pathlib import Path

GAPS = (2, 3, 4, 5)
A = (2, 5)
E = (3, 3, 5, 3, 5, 5, 5, 5)


def load_dfa(path):
    lines = path.read_text().splitlines()
    assert lines and lines[-1].startswith("# complete ")
    table = []
    for line in lines:
        if line.startswith("#"):
            continue
        state, count, *row = map(int, line.split())
        assert state == len(table) and count > 0 and len(row) == len(GAPS)
        table.append(row)
    assert int(lines[-1].split()[2]) == len(table)
    assert all(-1 <= r < len(table) for row in table for r in row)
    return table


def minimize(table):
    """All states accept, except the implicit absorbing dead state -1."""
    groups = [0] * len(table)
    while True:
        classes = {}
        finer = []
        for q, row in enumerate(table):
            key = (groups[q], tuple(-1 if t < 0 else groups[t] for t in row))
            finer.append(classes.setdefault(key, len(classes)))
        if finer == groups:
            break
        groups = finer
    quotient = [None] * len(set(groups))
    for q, row in enumerate(table):
        image = [-1 if r < 0 else groups[r] for r in row]
        old = quotient[groups[q]]
        assert old is None or old == image
        quotient[groups[q]] = image
    return quotient


def read(table, q, word):
    for gap in word:
        if q < 0:
            return -1
        q = table[q][GAPS.index(gap)]
    return q


def spacing_dfa(table):
    boundary = [read(table, 0, E)]
    assert boundary[0] >= 0
    position = {boundary[0]: 0}
    unary = []
    for q in boundary:
        seen = {}
        orbit = []
        while q not in seen:
            seen[q] = len(orbit)
            target = read(table, q, E)
            if target >= 0 and target not in position:
                position[target] = len(boundary)
                boundary.append(target)
            orbit.append(position.get(target, -1))
            q = read(table, q, A)
        entry = seen[q]
        unary.append((orbit, entry, len(orbit) - entry))

    cutoff = max(entry for _, entry, _ in unary)
    period = lcm(*(p for _, _, p in unary))
    assert cutoff + period <= 100000, "joint unary orbit limit"

    def lookup(orbit, entry, p, n):
        return orbit[n] if n < entry else orbit[entry + (n - entry) % p]

    expanded = [[lookup(row, entry, p, n) for n in range(cutoff + period)]
                for row, entry, p in unary]
    quot = minimize(expanded)

    # Shrink the common unary period and remove redundant tail positions.
    def column(n):
        return tuple(row[n if n < cutoff else cutoff + (n - cutoff) % period] for row in quot)

    tail = [column(cutoff + j) for j in range(period)]
    p = next(k for k in range(1, period + 1)
             if period % k == 0 and all(col == tail[j % k] for j, col in enumerate(tail)))
    t = cutoff
    while t > 0 and column(t-1) == column(t-1+p):
        t -= 1

    transitions = [[column(n)[s] for n in range(t + p)] for s in range(len(quot))]
    # Give minimal states stable breadth-first names in increasing spacing order.
    order = [0]
    ids = {0: 0}
    for q in order:
        for target in transitions[q]:
            if target >= 0 and target not in ids:
                ids[target] = len(order)
                order.append(target)
    assert len(order) == len(quot)
    result = [[ids.get(target, -1) for target in transitions[q]] for q in order]
    classes = [{"first": n, "period": 0 if n < t else p} for n in range(t + p)]
    return classes, result, len(boundary), t, p


def factor_graph(table, cutoff, period):
    """Expand arbitrary partial A and E blocks into a nondeterministic gap graph."""
    edges = []

    def node():
        edges.append({g: set() for g in GAPS})
        return len(edges) - 1

    control = [[node() for _ in range(cutoff + period)] for _ in table]

    def add(start, word, finish):
        cur = start
        for i, gap in enumerate(word):
            nxt = finish if i == len(word) - 1 else node()
            edges[cur][gap].add(nxt)
            cur = nxt

    for q, row in enumerate(table):
        for n, after in enumerate(row):
            nxt = n+1 if n+1 < len(row) else cutoff
            add(control[q][n], A, control[q][nxt])
            if after >= 0:
                add(control[q][n], E, control[after][0])
    return edges


def check_factors(graph, table):
    """Compare whole finite factor languages including partial blocks on either end."""
    pair = (frozenset(range(len(graph))), 0)
    todo = deque([pair])
    prior = {pair: None}
    while todo:
        subset, q = todo.popleft()
        for j, g in enumerate(GAPS):
            new = frozenset(x for v in subset for x in graph[v][g])
            nxt = -1 if q < 0 else table[q][j]
            if bool(new) != (nxt >= 0):
                path, prefix = [g], (subset, q)
                while prior[prefix] is not None:
                    prefix, gap = prior[prefix]
                    path.append(gap)
                raise ValueError(f"Factor mismatch on {path[::-1]} (grammar={bool(new)})")
            pair = new, nxt
            if pair not in prior:
                prior[pair] = ((subset, q), g)
                todo.append(pair)
    return len(prior)


def main():
    argv = argparse.ArgumentParser(description=__doc__)
    argv.add_argument("dfa", type=Path)
    argv.add_argument("output", type=Path)
    args = argv.parse_args()
    raw = load_dfa(args.dfa)
    classes, matrix, boundary_count, t, p = spacing_dfa(raw)
    minimal_gap = minimize(raw)
    graph = factor_graph(matrix, t, p)
    checked_pairs = check_factors(graph, minimal_gap)
    spacing = {"start": 0, "spacing_classes": classes, "transitions": matrix,
               "raw_boundaries": boundary_count, "minimum": min(c["first"] for j, c in enumerate(classes)
                   if matrix[0][j] >= 0), "gap_dfa_states": len(raw), "minimal_gap_dfa": minimal_gap,
               "gap_alphabet": GAPS, "factor_product_pairs": checked_pairs}
    args.output.write_text(json.dumps(spacing, indent=2) + "\n")
    print(f"{len(raw)} gap subsets, {len(minimal_gap)} minimized; "
          f"{boundary_count} boundary subsets, {len(matrix)} minimized; "
          f"unary cutoff {t}, period {p}, minimum {spacing['minimum']}; "
          f"full factor-language equality at {checked_pairs} product pairs")
    for q, row in enumerate(matrix):
        print(f"state {q}: {row}")


if __name__ == "__main__":
    main()
