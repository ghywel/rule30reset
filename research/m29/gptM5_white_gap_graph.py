"""Exact finite interval dynamics with two white ends and black second column.
Prune to temporal cycles, then test for a path to the swapped half-period pair.
Independent of the length of the temporal word. Unknowns report the product cap.
"""
import argparse
import json
import re
from collections import defaultdict
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components

BAD = re.compile(r"01(?:111)*0")

def components(nodes, edges):
    index={v:i for i,v in enumerate(nodes)}
    src=[]; dst=[]
    for v in nodes:
        for w in edges[v]:
            if w in index:
                src.append(index[v]); dst.append(index[w])
    matrix=csr_matrix(([1]*len(src),(src,dst)), shape=(len(nodes),len(nodes)))
    _, labels=connected_components(matrix,directed=True,connection="strong")
    groups=defaultdict(list)
    for v,g in zip(nodes,labels):
        groups[int(g)].append(v)
    return [g for g in groups.values() if len(g)>1 or g[0] in edges[g[0]]]

def gap_graph(n, cap):
    mask=(1<<n)-1
    def legal(v):
        return ((v>>(n-1))^(v>>(n-2)))&1==0
    nodes=[v for v in range(4,1<<n,2) if v&4 and legal(v)]
    def nexts(v):
        base=(((v<<2)^((v<<1)|v)) & mask) & ~2
        return [w for w in (base,base|2) if legal(w)]
    edges={v:nexts(v) for v in nodes}
    groups=components(nodes,edges)
    bad={v for v in nodes if not BAD.search(format(v,f'0{n+1}b'))}
    result=dict(gap=n,nodes=len(nodes),cyclic=sum(map(len,groups)),components=len(groups),
                bad_cyclic=0,untested_pairs=0,swappable_bad_pairs=0,swappable_pairs=0)
    for group in groups:
        selected=bad.intersection(group)
        result['bad_cyclic']+=len(selected)
        if not selected:continue
        left=[v for v in group if v & 2]; right=[v for v in group if not v&2]
        size=2*len(left)*len(right)
        if size>cap:
            result['untested_pairs']+=size
            continue
        pairs=[(x,y) for x in group for y in (right if x&2 else left)]
        product={pair:[(a,b) for a in edges[pair[0]] for b in edges[pair[1]] if (a^b)&2]
                 for pair in pairs}
        for cyc in components(pairs,product):
            states=set(cyc)
            for a,b in cyc:
                if (b,a) in states:
                    result['swappable_pairs']+=1
                    result['swappable_bad_pairs']+=a in selected
    return result

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("gaps",type=int,nargs="+"); ap.add_argument("--cap",type=int,default=500000)
    args=ap.parse_args()
    for n in args.gaps:print(json.dumps(gap_graph(n,args.cap)),flush=True)
