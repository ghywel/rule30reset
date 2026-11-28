"""Extend each unresolved calendar with physical cells whose falls are unrestricted."""
from collections import Counter
from functools import lru_cache
from sys import argv

from claudeM5_two_certs import permit
from survivor_joint_replay import (
    accepts, actual_tail, block_tails, calendars, components, edges_for,
    glue, has_pairs, live_rows, rigid_columns, scan,
)


@lru_cache(None)
def extend(calendar, direction, depth):
    width = len(calendar)
    live = block_tails(calendar)
    for extra in range(1,depth+1):
        span = width+extra
        shift = extra if direction == "west" else 0
        extra_mask = ((1 << span)-1) ^ (((1 << width)-1) << shift)
        allowed = [extra_mask | (permit(calendar,p) << shift) for p in (0,1)]
        next_live = set()
        for tail in live:
            nodes = [(p, ((row << 1) | bit) if direction == "west" else (row | (bit << (span-1))))
                     for p in (0,1) for row in tail[p] for bit in (0,1)]
            adj = edges_for(span,nodes,allowed)
            for part in components(adj):
                if has_pairs(span,(nodes[u][1] for u in part)) and len(rigid_columns(nodes,adj,part,span)) < 2:
                    next_live.add(live_rows(nodes,[part]))
        live = tuple(sorted(next_live))
        if not live:
            return extra
    return None


def join_with_extra_east(left, right):
    middle = len(left)
    width = middle+1+len(right)
    mask = [permit(left,p) | (1 << middle) | (permit(right,p) << (middle+1)) for p in (0,1)]
    extended_mask = [m | (1 << width) for m in mask]
    # Each side's tail is computed with first parity zero and shifted back here.
    west = block_tails(tuple(x ^ left[0] for x in left))
    east = block_tails(tuple(x ^ right[0] for x in right))
    hits = []
    for l in west:
        for r in east:
            nodes = glue((l[left[0]],l[1-left[0]]),(r[right[0]],r[1-right[0]]),middle)
            edges = edges_for(width,nodes,mask)
            for part in components(edges):
                if not actual_tail(nodes,edges,part,width,middle,True):
                    continue
                live = live_rows(nodes,[part])
                extended = [(p,row | (bit << width)) for p in (0,1) for row in live[p] for bit in (0,1)]
                next_edges = edges_for(width+1,extended,extended_mask)
                hits.append((len(part),accepts(extended,next_edges,width+1,middle,True)))
    return sorted(hits)


def scan_after_padding(upper, lower, depth):
    known = calendars()
    one_site_bound = 23
    if any(extend(word, "east", 5) is None for word in known[one_site_bound]):
        raise RuntimeError("Could not verify the 23-column starting bound")
    for width in range(lower-one_site_bound, one_site_bound):
        known[width] = tuple(word for word in known[width]
                             if extend(word,"east",depth) is None and extend(word,"west",depth) is None)
    for span in range(upper,lower-1,-1):
        k = min(6,span-one_site_bound)
        frames, lifted, remaining = scan(span,k,known,True,one_site_bound)
        print(span,k,"frame survivors",frames,"full products",lifted,"remaining",sum(remaining.values()),flush=True)
        unresolved = False
        for (j,r,a,b,n),count in sorted(remaining.items()):
            padding = join_with_extra_east(a,b)
            if not padding:
                raise RuntimeError("Lost an identified component during the east extension")
            print(j,r,''.join(map(str,a)),''.join(map(str,b)),n,count,
                  "east extension",padding,flush=True)
            unresolved |= any(after for _,after in padding)
        if unresolved:
            break


def scan_padding(upper, lower, limit):
    known = calendars()
    for width in range(upper,lower-1,-1):
        outcomes = Counter()
        surviving = []
        for word in known[width]:
            east = extend(word,"east",limit)
            west = extend(word,"west",limit) if east is None else None
            if east:
                outcomes["east",east] += 1
            elif west:
                outcomes["west",west] += 1
            else:
                surviving.append("".join(map(str,word)))
        print(width,dict(sorted(outcomes.items())),surviving,flush=True)
        if surviving:
            break


if __name__ == "__main__":
    if argv[1] == "--joint":
        scan_after_padding(*(int(arg) for arg in argv[2:]))
    elif argv[1] == "--east-join":
        left, right = (tuple(map(int, word)) for word in argv[2:4])
        print(join_with_extra_east(left, right))
    else:
        scan_padding(*(int(arg) for arg in argv[1:]))
