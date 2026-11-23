"""A uniform bound on the number of five-gaps in a finite 3/5 run outside the trap."""
import argparse
from collections import deque
import json
from pathlib import Path

import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components

from claudeCloud_wheel_exterior import gap_edges, trap_table
from wheel_bridge import table


def one_five(nodes, threes, fives):
    """Reachable after a last five-edge and zero or more three-edges."""
    reached = np.zeros(nodes, dtype=bool)
    reached[fives[1]] = True
    src, dst = threes
    while True:
        new = dst[reached[src] & ~reached[dst]]
        if not len(new):
            return reached
        reached[new] = True


def restrict(edges, alive):
    indices = np.cumsum(alive) - 1
    result = {}
    for letter, (src, dst) in edges.items():
        keep = alive[src] & alive[dst]
        result[letter] = indices[src[keep]], indices[dst[keep]]
    return result


def trim(nodes, edges, limit=None):
    """One round charges at most one five-gap at each end of the path."""
    rounds = 0
    while len(nodes) and (limit is None or rounds < limit):
        left = one_five(len(nodes), edges[3], edges[5])
        right = one_five(len(nodes), edges[3][::-1], edges[5][::-1])
        alive = left & right
        if alive.all():
            break
        rounds += 1
        edges = restrict(edges, alive)
        nodes = nodes[alive]
    return nodes, edges, rounds


def avoidance_machine(words):
    prefixes = sorted({word[:i] for word in words for i in range(len(word))}, key=lambda s:(len(s),s))
    transitions = []
    for prefix in prefixes:
        row = {}
        for letter in (3,5):
            word = prefix + str(letter)
            if not any(word.endswith(cut) for cut in words):
                suffix = max((p for p in prefixes if word.endswith(p)), key=len)
                row[letter] = prefixes.index(suffix)
        transitions.append(row)
    return transitions


def longest(nodes, edges, cuts, duration=False):
    """Reachable product with a word-avoidance automaton, accepting all start and end windows."""
    transitions = avoidance_machine(cuts)
    adjacency = [[] for _ in nodes]
    for gap, (src,dst) in edges.items():
        for i,j in zip(src.tolist(),dst.tolist()):
            adjacency[i].append((gap,j))
    states = [(i,0) for i in range(len(nodes))]
    ids = {state:i for i,state in enumerate(states)}
    graph = {3:([],[]), 5:([],[])}
    for i,(window,history) in enumerate(states):
        for letter,j in adjacency[window]:
            nxt = transitions[history].get(letter)
            if nxt is None:
                continue
            target = j,nxt
            if target not in ids:
                ids[target] = len(states)
                states.append(target)
            graph[letter][0].append(i)
            graph[letter][1].append(ids[target])
    n = len(states)
    src = graph[3][0]+graph[5][0]
    dst = graph[3][1]+graph[5][1]
    matrix = csr_matrix((np.ones(len(src),np.uint8),(src,dst)),shape=(n,n))
    nc, lab = connected_components(matrix,directed=True,connection="strong")
    dag = [{} for _ in range(nc)]
    indegree = [0]*nc
    for letter,(sources,targets) in graph.items():
        for i,j in zip(sources,targets):
            a,b = int(lab[i]),int(lab[j])
            weight = letter if duration else int(letter == 5)
            if a == b:
                if weight:
                    return {"vertices":n,"components":nc,"max_cost":None}
            else:
                if b not in dag[a]:
                    indegree[b] += 1
                dag[a][b] = max(dag[a].get(b,0),weight)
    queue = deque(i for i,v in enumerate(indegree) if not v)
    cost = [0]*nc
    while queue:
        i = queue.popleft()
        for j,w in dag[i].items():
            cost[j] = max(cost[j],cost[i]+w)
            indegree[j] -= 1
            if not indegree[j]:
                queue.append(j)
    assert not any(indegree)
    # Vertex potential certifies each zero/one inequality on the original product.
    for letter,(sources,targets) in graph.items():
        assert all(cost[lab[j]] >= cost[lab[i]] + (letter if duration else int(letter==5)) for i,j in zip(sources,targets))
    return {"vertices":n,"components":nc,"max_cost":max(cost,default=0)}


def run(kit, stop, trim_every=1, trim_limit=None):
    inside = trap_table(table(kit,"trapCodes","Rule30Certificates/GateTrap"))
    nodes = np.arange(1,1<<16,2,dtype=np.int64)
    nodes = nodes[~inside[nodes]]
    cuts = ["33355"*7,"333355"*9]
    cumulative = 0
    records = []
    for width in range(16,stop+1):
        if width>16:
            nodes = np.concatenate((nodes, nodes+(1<<(width-1))))
        edges = gap_edges(nodes,width,inside)
        # The bound before trimming this width can be stronger.
        incoming = len(nodes)
        before = longest(nodes,edges,cuts) if width==stop else None
        timed = longest(nodes,edges,cuts+["3"*8],duration=True) if width==stop else None
        rounds = 0
        if (width-16) % trim_every == 0:
            nodes,edges,rounds = trim(nodes,edges,trim_limit)
        record={"width":width,"initial":incoming,"trim_rounds":rounds,"core":len(nodes),"prior_rounds":cumulative}
        if before is not None:
            record.update(vertices=before["vertices"],components=before["components"],max_fives=before["max_cost"])
            if before["max_cost"] is not None:
                record["outside_bound"] = 2*cumulative+before["max_cost"]
            if timed["max_cost"] is not None:
                record["no_eight_threes"] = dict(timed, sample_bound=52*cumulative+timed["max_cost"])
        records.append(record)
        print(json.dumps(record),flush=True)
        cumulative += rounds
    return {"trim_every":trim_every,"trim_limit":trim_limit,"forbidden_factors":cuts,"widths":records}


if __name__ == "__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path)
    p.add_argument("output",type=Path)
    p.add_argument("--width",type=int,default=31)
    p.add_argument("--trim-every",type=int,default=5)
    p.add_argument("--trim-limit",type=int,default=1)
    a=p.parse_args()
    result=run(a.kit,a.width,a.trim_every,a.trim_limit)
    a.output.write_text(json.dumps(result,indent=2)+"\n",encoding="utf-8")
