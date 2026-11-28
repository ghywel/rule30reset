"""Independently replay the joint recurrence screen and lift any surviving projection."""
from collections import Counter, defaultdict
from functools import lru_cache
from math import gcd
from sys import argv

from claudeM5_two_certs import permit
from survivor_frames import calendars
from survivor_obligations import step


def components(edges):
    """Cyclic components via two DFS passes (Kosaraju)."""
    reverse = [[] for _ in edges]
    for u, successors in enumerate(edges):
        for v in successors:
            reverse[v].append(u)
    seen = set()
    finish = []
    for root in range(len(edges)):
        if root in seen:
            continue
        seen.add(root)
        stack = [(root, iter(edges[root]))]
        while stack:
            u, tail = stack[-1]
            v = next(tail, None)
            if v is None:
                finish.append(u)
                stack.pop()
            elif v not in seen:
                seen.add(v)
                stack.append((v, iter(edges[v])))
    seen.clear()
    for root in reversed(finish):
        if root in seen:
            continue
        seen.add(root)
        part = [root]
        for u in part:
            for v in reverse[u]:
                if v not in seen:
                    seen.add(v)
                    part.append(v)
        if len(part) > 1 or root in edges[root]:
            yield part


def edges_for(width, nodes, allowed):
    by_node = {node: i for i, node in enumerate(nodes)}
    edges = []
    for phase, row in nodes:
        successors = {step(width, a, b, row) for a in (0, 1) for b in (0, 1)}
        edges.append(sorted(by_node[1-phase, new] for new in successors
                            if (1-phase, new) in by_node and row & ~new & ~allowed[phase] == 0))
    return edges


@lru_cache(None)
def half_states(calendar):
    width = len(calendar)
    nodes = [(phase, row) for phase in (0, 1) for row in range(1 << width)]
    parts = components(edges_for(width, nodes, [permit(calendar, p) for p in (0, 1)]))
    return live_rows(nodes, parts)


def live_rows(nodes, parts):
    rows = [[], []]
    for part in parts:
        for v in part:
            phase, row = nodes[v]
            rows[phase].append(row)
    return tuple(tuple(sorted(r)) for r in rows)


def has_pairs(width, rows):
    found = 0
    for row in rows:
        found |= row & (row >> 1)
    return found == (1 << (width-1))-1


@lru_cache(None)
def block_tails(calendar):
    width = len(calendar)
    cut = width // 2 - 1
    left, right = half_states(calendar[:cut]), half_states(calendar[cut:])
    nodes = [(p, a | (b << cut)) for p in (0, 1) for a in left[p] for b in right[p]]
    edges = edges_for(width, nodes, [permit(calendar, p) for p in (0, 1)])
    return tuple(live_rows(nodes, [part]) for part in components(edges)
                 if has_pairs(width, (nodes[v][1] for v in part)))


def covers(width, known, k, east_end):
    out = defaultdict(set)
    cut = width-k if east_end else 0
    for calendar in known[width]:
        for tail in block_tails(calendar):
            for flip in (0, 1):
                rows = (tail[flip], tail[1-flip])
                frame = tuple(tuple(sorted({r >> cut & ((1 << k)-1) for r in phase})) for phase in rows)
                out[frame].add((tuple(p ^ flip for p in calendar), rows))
    return dict(out)


def glue(a,b,left_width):
    return [(p, x | (middle << left_width) | (y << (left_width+1)))
            for p in (0,1) for x in a[p] for y in b[p] for middle in (0,1)]


def rigid_columns(nodes, edges, part, width):
    inside = set(part)
    levels = {part[0]: 0}
    reach = [part[0]]
    lag = 0
    for u in reach:
        for v in edges[u]:
            if v not in inside:
                continue
            if v not in levels:
                levels[v] = levels[u]+1
                reach.append(v)
            lag = gcd(lag, levels[u]+1-levels[v])
    bases = {}
    differences = 0
    for u in part:
        row = nodes[u][1]
        base = bases.setdefault(levels[u] % lag, row)
        differences |= row ^ base
    return [j for j in range(width) if not (differences >> j & 1)]


def accepts(nodes, edges, width, middle, use_jen=False):
    for part in components(edges):
        if not has_pairs(width, (nodes[v][1] for v in part)):
            continue
        comp = set(part)
        mask = 0
        for u in part:
            phase, row = nodes[u]
            if row >> middle & 1 and any(v in comp and not (nodes[v][1] >> middle & 1) for v in edges[u]):
                mask |= 1 << phase
        if mask == 3 and (not use_jen or len(rigid_columns(nodes, edges, part, width)) < 2):
            return len(part)
    return 0


@lru_cache(None)
def passes_frames(a,b,k):
    nodes = glue(a,b,k)
    width = 2*k+1
    return accepts(nodes,edges_for(width,nodes,[~0,~0]),width,k)


def scan(span, k, known, use_jen=False):
    projected = lifted = 0
    remaining = Counter()
    for j in range(span-27,27):
        r = span-1-j
        assert j >= k and r >= k
        a = covers(j,known,k,True)
        b = covers(r,known,k,False)
        for l in a:
            for h in b:
                if not passes_frames(l,h,k):
                    continue
                projected += 1
                for (lc,ls) in a[l]:
                    for (rc,rs) in b[h]:
                        n = glue(ls,rs,j)
                        masks = [permit(lc,p) | (1 << j) | (permit(rc,p) << (j+1)) for p in (0,1)]
                        lifted += 1
                        hit = accepts(n,edges_for(span,n,masks),span,j,use_jen)
                        if hit:
                            remaining[(j,r,lc,rc,hit)] += 1
    return projected, lifted, remaining


if __name__ == "__main__":
    use_jen = argv[-1] == "--jen"
    start, end, depth = map(int, argv[1:-1] if use_jen else argv[1:])
    known = calendars()
    for span in range(start,end-1,-1):
        k = min(depth,span-27)
        fr, lifted, remaining = scan(span,k,known,use_jen)
        print(span, k,"frame survivors",fr,"full products",lifted,"remaining",sum(remaining.values()),flush=True)
        for (j,r,a,b,n),count in sorted(remaining.items()):
            print(j,r,''.join(map(str,a)),''.join(map(str,b)),n,count,flush=True)
        if remaining:
            break
