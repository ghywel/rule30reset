#!/usr/bin/env python3
"""Finite prefix certificate for doubled Rule 30 excursions with variable pulse spacings.

Run: python gptIntel_spacing.py MIN_GAP MAX_WIDTH [--holes] [--limit N].
A row has wheels 1..w in bits 0..w-1; wheel 0 is white and wheel 2 is black.
At a marked tick the horizontal map flips bit 0 relative to its usual update.
By default marks are source black ticks. --holes marks white ticks in a black background.
All cyclic spacings >= MIN_GAP are allowed. No source period or maximum gap is imposed.
A FAIL at a width is a failure of this certificate, not a counterexample to (DL).
"""
import argparse


def cyclic_components(graph):
    """Iterative Kosaraju. Return component IDs only for vertices lying on cycles."""
    reverse = {v: [] for v in graph}
    for v, edges in graph.items():
        for u in edges:
            reverse[u].append(v)
    order, seen = [], set()
    for root in graph:
        if root in seen:
            continue
        seen.add(root)
        stack = [(root, iter(graph[root]))]
        while stack:
            v, edges = stack[-1]
            u = next(edges, None)
            if u is None:
                order.append(v)
                stack.pop()
            elif u not in seen:
                seen.add(u)
                stack.append((u, iter(graph[u])))
    seen.clear()
    comp = {}
    for root in reversed(order):
        if root in seen:
            continue
        part, todo = [], [root]
        seen.add(root)
        while todo:
            v = todo.pop()
            part.append(v)
            for u in reverse[v]:
                if u not in seen:
                    seen.add(u)
                    todo.append(u)
        if len(part) > 1 or root in graph[root]:
            comp.update((v, root) for v in part)
    return comp


def catch(row, width):
    run = 0
    for i in range(width):
        if row >> i & 1:
            run += 1
        else:
            if run % 3 == 1:
                return i + 1
            run = 0
    return 0


def gap_orbit(x, mask, minimum, holes):
    """All distinct endpoint/visited-set alternatives for a single gap."""
    def hold(y):
        return (((y << 2) ^ ((y << 1) | y)) & mask) ^ holes
    y = hold(x) ^ 1
    states, index = [], {}
    while y not in index:
        index[y] = len(states)
        states.append(y)
        y = hold(y)
    mu = index[y]
    period = len(states) - mu
    # At h = gap-1, the endpoint has seen states 0..h. Beyond this cutoff
    # exactly the same endpoint and full set of rows occur one lap earlier.
    bound = max(mu, minimum - 1) + 2 * period - 1
    for h in range(bound + 1):
        yield h + 1, states[h if h < len(states) else mu + (h - mu) % period]


def width_graph(candidates, width, minimum, holes):
    mask = (1 << width) - 1
    graph = {x: {} for x in candidates}
    for x in candidates:
        for gap, y in gap_orbit(x, mask, minimum, holes):
            if gap >= minimum and y in candidates:
                graph[x][y] = None
    comp = cyclic_components(graph)
    return comp


def inspect(comp, width, minimum, holes):
    mask = (1 << width) - 1
    # Each edge holds the AND of the ORs along its alternative gap lengths:
    # a zero bit means some allowed gap stays white at that wheel.
    may_white = {}
    rows = set()
    for x in comp:
        edges = {}
        may_white[x] = edges
        segment = []
        lit = 0
        for gap, y in gap_orbit(x, mask, minimum, holes):
            segment.append(y)
            lit |= y
            if gap >= minimum and comp.get(y) == comp[x]:
                rows.update(segment)
                segment.clear()
                edges[y] = edges.get(y, mask) & lit
    catches = {x: catch(x, width) for x in rows}
    first_white = None
    for i in range(width):
        white = {x: [y for y, lit in edges.items() if not (lit >> i & 1)]
                 for x, edges in may_white.items()}
        if cyclic_components(white):
            first_white = i + 1
            break
    bare = sum(c == 0 for c in catches.values())
    last = max(catches.values(), default=0)
    return len(rows), bare, last, first_white


def study(minimum, max_width, holes=False, limit=100000, start_report=2):
    if minimum < 1 or max_width < 2:
        raise ValueError('expected a positive gap and at least two wheels')
    comp = {2: 0, 3: 0}
    for w in range(2, max_width + 1):
        candidates = set(comp) if w == 2 else set(comp) | {x | (1 << (w - 1)) for x in comp}
        if len(candidates) > limit:
            print(f'stopped before width {w}: {len(candidates)} candidates exceed {limit}', flush=True)
            return
        comp = width_graph(candidates, w, minimum, holes)
        if w < start_report:
            continue
        rows, bare, last, white = inspect(comp, w, minimum, holes)
        ok = bare == 0 and (white is None or white > last)
        print(f'w={w} pre={len(comp)} rows={rows} bare={bare} latest={last} '
              f'earliest_possible_white={white} pass={ok}', flush=True)
        if ok:
            return


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('minimum', type=int)
    p.add_argument('max_width', type=int)
    p.add_argument('--holes', action='store_true')
    p.add_argument('--limit', type=int, default=100000)
    p.add_argument('--start-report', type=int, default=2)
    args = p.parse_args()
    study(args.minimum, args.max_width, args.holes, args.limit, args.start_report)
