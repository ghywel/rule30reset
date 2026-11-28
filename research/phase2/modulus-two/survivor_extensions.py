"""Extend each unresolved calendar with physical cells whose falls are unrestricted."""
from collections import Counter
from functools import lru_cache
from sys import argv

from claudeM5_two_certs import permit
from survivor_joint_replay import block_tails, calendars, components, edges_for, has_pairs, live_rows, rigid_columns


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


if __name__ == "__main__":
    upper, lower, limit = map(int,argv[1:])
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
