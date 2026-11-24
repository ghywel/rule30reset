"""Decode kicks from the white phase of Lowry's arrival parity.

A strip edge takes two Rule 30 ticks. The eastern bit is free at each tick.
The two gap graphs are separate controls; neither is used to generate strips.
"""

import argparse
from itertools import product


def scalar(row, wall):
    padded = (wall, *row)
    return tuple(a ^ (b | c) for a, b, c in zip(padded, padded[1:], padded[2:]))


def marker_control():
    for history in (0, 1):
        misses = []
        for row in product((0, 1), repeat=4 + history):
            old = scalar(row, 1) if history else row
            new = scalar(scalar(old, 0), 1)
            zeros = old[0] == old[1] and new[0] == new[1]
            if zeros != bool(new[0] and new[1]):
                misses.append(''.join(map(str, row)))
        print('previous black ticks', history, 'assignments', 2**(4+history), 'failures', misses)
        assert misses == ([] if history else ['1100'])


def gap_graph(refined):
    pairs = {2: (2, 4, 5), 3: (3, 5), 4: (5,), 5: (2, 3, 5)}
    # Number (saturated at two) of successive 2-gaps through the current gap.
    states = [(g, i, run) for g in pairs for i in range(g)
              for run in ((1, 2) if g == 2 and refined else (int(g == 2),))]
    edges = []
    for g, i, run in states:
        if i + 1 < g:
            dest = [(g, i+1, run)]
        else:
            dest = [(h, 0, min(2, run+1) if h == 2 and refined else int(h == 2))
                    for h in pairs[g] if not (refined and run == 2 and h == 5)]
        edges.append([states.index(x) for x in dest])
    return edges, [int((g-i) % 2 == 0) for g, i, _ in states], [int(i == 0) for _, i, _ in states]


def strip_graph(width):
    def tick(row, wall, east):
        return (((row << 1) | wall) ^ (row | (row >> 1) | (east << (width-1)))) & ((1 << width)-1)

    full = [sorted({tick(tick(row, 0, a), 1, b) for a, b in product((0, 1), repeat=2)})
            for row in range(1 << width)]
    warm = set(range(len(full)))
    depth = 0
    while True:
        following = {y for x in warm for y in full[x]}
        if following == warm:
            break
        depth += 1
        warm = following
    rows = sorted(warm)
    number = {r: i for i, r in enumerate(rows)}
    return ([[number[y] for y in full[x]] for x in rows],
            [(x ^ (x >> 1)) & 1 for x in rows], [x & 1 for x in rows], depth)


def bits(mask):
    while mask:
        bit = mask & -mask
        yield bit.bit_length()-1
        mask ^= bit


def windows(edges, labels, gates, radius):
    """Pairs (past, future) that determine the centre gate, including both ends."""
    rows = len(edges)
    reverse = [[] for _ in edges]
    for x, ys in enumerate(edges):
        for y in ys:
            reverse[y].append(x)
    all_rows = (1 << rows)-1
    lab1 = sum(1 << x for x in range(rows) if labels[x])
    gate1 = sum(1 << x for x in range(rows) if gates[x])

    def contexts(adj):
        jump = [sum(1 << y for y in set(ys)) for ys in adj]
        level = {v for v in (all_rows ^ lab1, lab1) if v}
        levels = [level]
        for _ in range(radius):
            next_level = set()
            for mask in level:
                reached = 0
                for x in bits(mask):
                    reached |= jump[x]
                next_level.update((reached & lab1, reached & ~lab1))
            level = next_level - {0}
            levels.append(level)
        return levels

    past, future = contexts(edges), contexts(reverse)
    frontier = []
    for left, leftsets in enumerate(past):
        for right, rightsets in enumerate(future):
            if any(l <= left and r <= right for l, r in frontier):
                continue
            if all(not (s & f & gate1 and s & f & ~gate1) for s in leftsets for f in rightsets):
                frontier.append((left, right))
    return frontier


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--widths', type=int, nargs='*', default=[6, 9, 11, 12, 13])
    parser.add_argument('--radius', type=int, default=10)
    args = parser.parse_args()
    marker_control()
    for refined in (False, True):
        graph = gap_graph(refined)
        print('gap graph; exclude 2,2,5', refined, 'states', len(graph[0]),
              'minimal (past,future) through radius', args.radius, windows(*graph, args.radius), flush=True)
    for w in args.widths:
        adj, labels, gates, warmup = strip_graph(w)
        print('strip', w, 'warmup', warmup, 'surviving rows', len(adj),
              'minimal (past,future)', windows(adj, labels, gates, args.radius), flush=True)
