"""Check M152's two trap lists using the three-tick light cone of one initial row.

Run with the path to the frozen Rule30Submission.lean. Bit zero is column one.
Only the trap lists are read from the submission. The elementary-rule lookup,
graph, and enumeration of the exterior are reconstructed here.
"""
from argparse import ArgumentParser
from collections import deque
from pathlib import Path
import re


def block(stencil):
    """Eight consecutive outputs from ten input bits, westernmost at bit zero."""
    result = 0
    for i in range(8):
        left, centre, right = ((stencil >> (i + offset)) & 1 for offset in range(3))
        neighbourhood = (left << 2) | (centre << 1) | right
        result |= ((30 >> neighbourhood) & 1) << i
    return result


BLOCKS = tuple(block(i) for i in range(1024))


def tick(row, wall, width):
    stencil = 2 * row + wall
    result = 0
    for i in range(0, width, 8):
        result |= BLOCKS[(stencil >> i) & 1023] << i
    return result & ((1 << width) - 1)


def period(row, extension, width, drive):
    row |= extension << width
    for remaining, wall in zip((2, 1, 0), drive):
        row = tick(row, wall, width + remaining)
    return row


def successors(row, width, drive):
    return {period(row, extension, width, drive) for extension in range(8)}


def free_boundary_successors(row, width, drive):
    """Comparison with a fresh independent eastern boundary input at each tick."""
    rows = {row}
    for wall in drive:
        rows = {tick(x | (e << width), wall, width) for x in rows for e in (0, 1)}
    return rows


def trap_reach(graph, trap):
    reverse = {x: set() for x in trap}
    for x in trap:
        assert graph[x] <= trap
        for target in graph[x]:
            reverse[target].add(x)
    root = min(trap)
    return reachable(graph, root), reachable(reverse, root), reverse


def reachable(graph, root):
    seen = {root}
    pending = deque([root])
    while pending:
        new = graph[pending.popleft()] - seen
        seen.update(new)
        pending.extend(new)
    return seen


def exterior(rows, graph):
    """Keep exactly the rows on arbitrarily long two-sided exterior paths."""
    while rows:
        incoming = set()
        outgoing = set()
        for x in rows:
            targets = rows.intersection(graph[x])
            if targets:
                incoming.update(targets)
                outgoing.add(x)
        inside = incoming & outgoing
        if inside == rows:
            break
        rows = inside
    return rows


def check(source, word, drive, expected_size, expected_reach, missing_parent, last_width, expected_exterior):
    match = re.search(r'^def trap' + word + r' : List Nat := \[([\d,\s]+)\]', source, re.M)
    if not match:
        raise ValueError(f'Missing trap list for {word}')
    literals = [int(v) for v in re.findall(r'\d+', match[1])]
    trap = set(literals)
    assert len(trap) == len(literals) == expected_size and all(0 <= x < 2**14 for x in trap)
    graph = {x: successors(x, 14, drive) for x in range(2**14)}
    ahead, behind, reverse = trap_reach(graph, trap)
    assert len(ahead) == expected_reach and behind == trap
    assert missing_parent in trap and not reverse[missing_parent]
    relaxed = {x: free_boundary_successors(x, 14, drive) for x in trap}
    relaxed_ahead, relaxed_behind, relaxed_reverse = trap_reach(relaxed, trap)
    assert relaxed_ahead == relaxed_behind == trap
    assert all(graph[x] <= relaxed[x] for x in trap)
    print(f'{word}: physical reach from/to {min(trap)}: {len(ahead)}/{len(behind)}. '
          f'{missing_parent} has zero physical parents in the trap; '
          f'{len(relaxed_reverse[missing_parent])} in the independent-boundary graph, '
          f'which is strongly connected ({len(trap)} states).')
    # Removing this member invalidates closure, with an explicit initial row witness.
    root = min(trap)
    parent = min(reverse[root] - {root})
    extension = next(e for e in range(8) if period(parent, e, 14, drive) == root)
    print(f'{word}: physical closure breaks on removing {root}: {parent} + 2^14 * {extension} -> {root}.')
    rows = exterior(set(graph) - trap, graph)
    counts = [len(rows)]
    for width in range(15, last_width + 1):
        rows |= {x + (1 << (width - 1)) for x in rows}
        graph = {x: successors(x, width, drive) for x in rows}
        rows = exterior(rows, graph)
        counts.append(len(rows))
    print(f'{word}: widths 14..{last_width}: {counts}; final {sorted(rows)}.')
    assert rows == expected_exterior
    assert all(graph[x] & rows == {x} for x in rows)


if __name__ == '__main__':
    parser = ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    source = parser.parse_args().source.read_text(encoding='utf-8')
    check(source, '001', (0, 1, 0), 1286, 1195, 675, 14, {9278, 12831})
    check(source, '011', (0, 1, 1), 747, 691, 893, 30, {142378952})
