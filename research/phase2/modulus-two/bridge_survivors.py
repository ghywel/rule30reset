"""Can two maximum one-parity strips coexist across one unrestricted column?"""
from collections import Counter
from math import gcd
from survivor_obligations import CALENDAR, compressed_graph, cyclic_parts, step


WIDTH = len(CALENDAR)


def bridge(west, east, swap):
    shift = WIDTH + 1
    total = 2 * WIDTH + 1
    nodes = [(phase, left | (bit << WIDTH) | (right << shift))
             for phase in (0, 1) for left in west[phase]
             for right in east[phase ^ swap] for bit in (0, 1)]
    index = {node: i for i, node in enumerate(nodes)}
    edges = []
    for phase, row in nodes:
        nxt = {step(total, a, b, row) for a in (0, 1) for b in (0, 1)}
        edges.append([index[1 - phase, s] for s in sorted(nxt) if (1 - phase, s) in index])
    return nodes, edges


def from_component(nodes, edges, part):
    seen = {part[0]: 0}
    queue = [part[0]]
    inside = set(part)
    period = 0
    for u in queue:
        for v in edges[u]:
            if v not in inside:
                continue
            if v not in seen:
                seen[v] = seen[u] + 1
                queue.append(v)
            period = gcd(period, seen[u] + 1 - seen[v])
    masks = [[] for _ in range(period)]
    for u in part:
        masks[seen[u] % period].append(nodes[u][1])
    ones = set(range(2 * WIDTH + 1))
    for rows in masks:
        first = rows[0]
        diff = 0
        for row in rows[1:]:
            diff |= row ^ first
        ones = {j for j in ones if not (diff >> j & 1)}
    can_fall = [False, False]
    for u in part:
        phase, row = nodes[u]
        can_fall[phase] |= any(v in inside and (row & ~nodes[v][1]) >> WIDTH & 1 for v in edges[u])
    return len(part), period, tuple(sorted(ones)), tuple(can_fall)


def main():
    calendar = tuple(map(int, CALENDAR))
    nodes, edges, _, _ = compressed_graph(calendar, 13)
    part = max(cyclic_parts(edges), key=len)
    assert len(part) == 94
    west = [sorted(nodes[k][1] for k in part if nodes[k][0] == p) for p in (0, 1)]
    for swap in (0, 1):
        full, edges = bridge(west, west, swap)
        parts = cyclic_parts(edges)
        if not parts:
            print(swap, len(full), "acyclic")
            continue
        info = Counter(from_component(full, edges, part) for part in parts)
        print(swap, len(full), "cyclic components:", len(parts), "largest:", max(info))
        counts = Counter()
        for (size, period, rigid, falls), multiplicity in info.items():
            counts[(period, len(rigid) < 2, falls)] += multiplicity
        print("period, fewer than two rigid columns, both phase falls possible:", dict(sorted(counts.items())))


if __name__ == "__main__":
    main()
