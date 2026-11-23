"""Independent kick-to-kick graph for checking the three possible exterior tails."""

import argparse
from collections import Counter, deque
from math import gcd
import json
from pathlib import Path

import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components

from wheel_bridge import table


def tick(row, wall, east, w):
    # The exterior input supplies only the right neighbour of the final cell.
    right = (row >> 1) | (east << (w-1))
    return ((row | right) ^ ((row << 1) | wall)) & ((1 << w) - 1)


def first_gap(row, w):
    # At these widths the first five future gate readings are independent of the exterior.
    for g in range(1, 6):
        row = tick(tick(row, 0, 0, w), 1, 0, w)
        if row & 1:
            return g
    return None


def targets(row, w, gap):
    layer = {row}
    for t in range(2*gap):
        layer = {tick(x, t % 2, east, w) for x in layer for east in (0, 1)}
    return layer


def canonical(seq):
    seq = "".join(map(str, seq))
    prim = next(seq[:k] for k in range(1, len(seq)+1) if seq[:k] * (len(seq)//k) == seq)
    return min(prim[i:]+prim[:i] for i in range(len(prim)))


def recurrent(candidates, w):
    candidates = sorted(candidates)
    index = {v:i for i,v in enumerate(candidates)}
    adj, letters, source, dest = [], [], [], []
    for i, code in enumerate(candidates):
        gap = first_gap(code, w)
        letters.append(gap)
        edges = sorted(index[v] for v in targets(code,w,gap) if v in index) if gap in (3,5) else []
        adj.append(edges)
        source.extend([i]*len(edges))
        dest.extend(edges)
    n = len(candidates)
    matrix = csr_matrix((np.ones(len(source),dtype=np.uint8),(source,dest)),shape=(n,n))
    _, label = connected_components(matrix, directed=True, connection="strong")
    groups = {}
    for i, group in enumerate(label):
        groups.setdefault(int(group), []).append(i)
    survive, forms = set(), Counter()
    for group, nodes in groups.items():
        root = nodes[0]
        if len(nodes) == 1 and root not in adj[root]:
            continue
        survive.update(candidates[i] for i in nodes)
        distance = {root:0}
        q = deque([root])
        period = 0
        while q:
            i = q.popleft()
            for j in adj[i]:
                if label[j] != group:
                    continue
                if j not in distance:
                    distance[j] = distance[i]+1
                    q.append(j)
                period = gcd(period, abs(distance[i]+1-distance[j]))
        symbols = [set() for _ in range(period)]
        for i in nodes:
            symbols[distance[i] % period].add(letters[i])
        name = canonical([min(s) for s in symbols]) if all(len(s)==1 for s in symbols) else "variable"
        forms[name] += 1
    return survive, forms


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit",type=Path)
    parser.add_argument("through",type=int)
    args = parser.parse_args()
    trap = set(table(args.kit,"trapCodes","Rule30Certificates/GateTrap"))
    candidates = set(range(1,1<<16,2)) - trap
    for w in range(16,args.through+1):
        if w>16:
            candidates = survive | {v+(1<<(w-1)) for v in survive}
        survive, forms = recurrent(candidates,w)
        print(json.dumps(dict(width=w,cyclic_kick_windows=len(survive),components=forms)),flush=True)
