"""Check two cofinal-parity sites in shorter bands by joining survivor boundary frames."""
from functools import lru_cache
from pathlib import Path
import json
import re

from survivor_obligations import compressed_graph, cyclic_parts, step


def calendars():
    data = Path(__file__).with_name("addon") / "kit" / "Rule30Certificates" / "FallParityData.lean"
    text = data.read_text(encoding="utf-8")
    return {int(w): tuple(map(tuple, json.loads(v)))
            for w, v in re.findall(r"private def two(\d+) : List \(List Nat\) := (\[.*?\])\n", text)}


@lru_cache(None)
def physical_tail(calendar):
    """Any actual tail must have every 11 pair, so drop components missing one."""
    nodes, edges, _, _ = compressed_graph(calendar, len(calendar) // 2)
    parts = []
    for component in cyclic_parts(edges):
        states = [nodes[u] for u in component]
        if all(any(row >> j & 3 == 3 for _, row in states) for j in range(len(calendar)-1)):
            parts.append(states)
    return parts


def frames(states, width, k, east_end):
    cut = width-k if east_end else 0
    return [{row >> cut & ((1 << k)-1) for q, row in states if q == p} for p in (0, 1)]


def join(left, right, k, flip):
    nodes = [(p, a | (c << k) | (b << (k+1))) for p in (0, 1)
             for a in sorted(left[p]) for b in sorted(right[p ^ flip]) for c in (0, 1)]
    core = set(nodes)
    # Independent sink stripping checks absence of directed cycles.
    while core:
        keep = {(p, row) for p, row in core
                if any((1-p, step(2*k+1, a, b, row)) in core for a in (0, 1) for b in (0, 1))}
        if keep == core:
            break
        core = keep
    return len(nodes), len(core)


def test(length, known, k):
    count, failed = 0, []
    for middle in range(length-27, 27):
        r = length-middle-1
        for a in known[middle]:
            for b in known[r]:
                for lhs in physical_tail(a):
                    west = frames(lhs, middle, k, True)
                    for rhs in physical_tail(b):
                        east = frames(rhs, r, k, False)
                        for flip in (0, 1):
                            count += 1
                            size, core = join(west, east, k, flip)
                            if core:
                                failed.append((middle, r, flip, size, core))
    return count, failed


if __name__ == "__main__":
    known = calendars()
    for length in range(53, 48, -1):
        for k in (4, 6, 8):
            count, failed = test(length, known, k)
            print(length, k, count, len(failed), failed[:6])
            if not failed:
                break
