"""Examine S34's width-26 survivor with eventual half-strip bounds."""
from collections import Counter
from math import gcd
import sys

from claudeM5_two_certs import graph, heights, permit, scc


CALENDAR = "00000010000000100000000000"
WINDOWS = ("001 100", "000 011 100", "000 010 110", "000 100 110",
           "001 010 111", "000 010 100 101", "000 011 110")


def step(width, west, east, row):
    padded = (east << (width + 1)) | (row << 1) | west
    out = 0
    for j in range(width):
        triple = (padded >> j) & 7
        if (triple & 1) ^ bool(triple & 6):
            out |= 1 << j
    return out


def cyclic_parts(edges):
    group, size = scc(edges)
    _, members = heights(edges, group, size)
    return [part for part in members if len(part) > 1 or part[0] in edges[part[0]]]


def half_rows(calendar):
    width = len(calendar)
    rows = [set(), set()]
    for part in cyclic_parts(graph(calendar)):
        for n in part:
            phase, row = divmod(n, 1 << width)
            rows[phase].add(row)
    return rows


def compressed_graph(calendar, cut):
    width = len(calendar)
    masks = [permit(calendar, p) for p in range(2)]
    west = half_rows(calendar[:cut])
    east = half_rows(calendar[cut:])
    nodes = [(p, a | (b << cut)) for p in range(2) for a in sorted(west[p]) for b in sorted(east[p])]
    index = {node: i for i, node in enumerate(nodes)}
    edges = []
    for p, row in nodes:
        steps = {step(width, w, e, row) for w in range(2) for e in range(2)}
        edges.append(sorted(index[1-p, nxt] for nxt in steps
                            if (1-p, nxt) in index and row & ~nxt & ~masks[p] == 0))
    return nodes, edges, tuple(map(len, west)), tuple(map(len, east))


def report(calendar, cut):
    calendar = tuple(map(int, calendar))
    nodes, edges, west, east = compressed_graph(calendar, cut)
    print("width, cut, west and east cyclic rows by phase, product nodes:", len(calendar), cut, west, east, len(nodes))
    info = []
    windows = [set(int(k[::-1], 2) for k in group.split()) for group in WINDOWS]
    for part in cyclic_parts(edges):
        if len(part) == 2 and all(row == nodes[part[0]][1] for _, row in (nodes[v] for v in part)):
            info.append(("constant",))
            continue
        inside = set(part)
        offsets = {part[0]: 0}
        queue = [part[0]]
        period = 0
        for u in queue:
            for v in edges[u]:
                if v not in inside:
                    continue
                if v not in offsets:
                    offsets[v] = offsets[u]+1
                    queue.append(v)
                period = gcd(period, offsets[u]+1-offsets[v])
        columns = []
        for j in range(len(calendar)):
            symbols = [set() for _ in range(period)]
            for u in part:
                symbols[offsets[u] % period].add((nodes[u][1] >> j) & 1)
            if all(len(s) == 1 for s in symbols):
                columns.append(j)
        pairs_missing = [j for j in range(len(calendar)-1)
                         if not any((nodes[u][1] >> j) & 3 == 3 for u in part)]
        windows_missing = [(j, k+1) for j in range(len(calendar)-2) for k, group in enumerate(windows)
                           if not any((nodes[u][1] >> j) & 7 in group for u in part)]
        forced_single_mod4 = []
        for j in range(len(calendar)):
            residues = set()
            for u in part:
                if any(v in inside and (nodes[u][1] & ~nodes[v][1]) >> j & 1 for v in edges[u]):
                    base = nodes[part[0]][0]+offsets[u]
                    residues.update((base + k*period) % 4 for k in range(4))
            if len(residues) <= 1:
                forced_single_mod4.append(j)
        forced_six = [j for j in range(len(calendar)-5)
                      if set(range(j, j+6)) <= set(forced_single_mod4)]
        info.append((len(part),period,tuple(columns),tuple(pairs_missing),
                     tuple(windows_missing),tuple(forced_six)))
    print("multiplicity: (size, period, rigid columns, missing 11, missing window obligations, modulus-4 blocked starts)")
    for row, n in sorted(Counter(info).items(), key=lambda item: (len(item[0]),item[0])):
        print(n, row)
    return Counter(info)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        report(sys.argv[1], len(sys.argv[1]) // 2)
    else:
        first = report(CALENDAR, 13)
        assert first == report(CALENDAR, 12)
