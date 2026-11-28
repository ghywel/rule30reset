"""Combine the cofinal black-pair and middle-fall obligations with S34's calendars."""
from functools import lru_cache
from hashlib import sha256
from sys import argv

from survivor_frames import calendars, frames, physical_tail
from survivor_obligations import cyclic_parts


def cell_update(width, west, east, row):
    return ((row << 1 | west) ^ (row | row >> 1 | east << (width-1))) & ((1 << width)-1)


@lru_cache(None)
def check(k, west, east):
    span = 2*k+1
    nodes = [(p, a | (c << k) | (b << (k+1))) for p in (0, 1)
             for a in west[p] for b in east[p] for c in (0, 1)]
    idx = {node:i for i,node in enumerate(nodes)}
    edges = []
    for p, state in nodes:
        successors = {cell_update(span, w, e, state) for w in (0, 1) for e in (0, 1)}
        edges.append([idx[1-p,s] for s in sorted(successors) if (1-p,s) in idx])
    for comp in cyclic_parts(edges):
        positions = set(comp)
        pairs = 0
        falls = 0
        for x in comp:
            p, row = nodes[x]
            pairs |= row & (row >> 1)
            if row >> k & 1 and any(y in positions and not (nodes[y][1] >> k & 1) for y in edges[x]):
                falls |= 1 << p
        if pairs == (1 << (span-1))-1 and falls == 3:
            return len(comp)
    return 0


def profiles(known, k, east_end):
    out = {}
    for width, cc in known.items():
        if width < k:
            continue
        pp = set()
        for c in cc:
            for component in physical_tail(c):
                a, b = tuple(tuple(sorted(s)) for s in frames(component, width, k, east_end))
                pp.add((a,b))
                pp.add((b,a))
        out[width] = sorted(pp)
    return out


def scan(upper, lower, depth):
    known = calendars()
    west = profiles(known, depth, True)
    east = profiles(known, depth, False)
    for span in range(upper, lower-1, -1):
        counts = []
        for j in range(span-27,27):
            r = span-j-1
            if j < depth or r < depth:
                counts.append((j,r,None,None))
                continue
            cases = [(a,b,check(depth,a,b)) for a in west[j] for b in east[r]]
            survivors = [(a,b,m) for a,b,m in cases if m]
            mark = sha256(repr(survivors).encode()).hexdigest()[:12] if survivors else ""
            counts.append((j,r,len(cases),len(survivors),mark))
        failed = sum(row[3] or 0 for row in counts)
        short = sum(row[3] is None for row in counts)
        print(span, depth, "products", sum(row[2] or 0 for row in counts),
              "survivors", failed, "short flanks", short, flush=True)
        if failed:
            print([row for row in counts if row[3]],flush=True)
            # The first surviving span bounds this particular fixed-depth screen.
            break


if __name__ == "__main__":
    scan(*(int(arg) for arg in argv[1:]))
