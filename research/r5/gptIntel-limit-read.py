"""Independent 001 window map and 15-trap closure for the M134 carrying read."""
import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
import re

import numpy as np
from scipy.sparse import csr_matrix
from scipy.sparse.csgraph import connected_components

DRIVE = (0, 0, 1)


def successors(width, x, wall):
    """All successor words. Only the high bit can depend on the exterior cell."""
    mask = (1 << width) - 1
    left = (x << 1) | wall
    centre_or_east = x | (x >> 1)
    return (left ^ centre_or_east) & mask, (left ^ (centre_or_east | (1 << (width-1)))) & mask


def rings(width):
    """Enumerate cyclic twelve-cell rows of period dividing three with the 001 wall."""
    def tick(x):
        left = ((x << 1) | (x >> 11)) & 4095
        right = (x >> 1) | ((x & 1) << 11)
        return left ^ (x | right)
    def prefix(x):
        return sum(((x >> ((i+1)%12)) & 1) << i for i in range(width))
    result = []
    for x in range(4096):
        rows = [x, tick(x), tick(tick(x))]
        if tuple(r & 1 for r in rows) == DRIVE and tick(rows[2]) == x:
            result.append(tuple(prefix(r) for r in rows))
    return result


def trap_states(kit):
    text = (kit/'lean/Ruliology/CellularAutomata/Rule30EtherThreeNotAbsorption.lean').read_text('utf-8')
    def table(name):
        return int(re.search(r'def trap001fifteen_'+name+r' : Nat := (\d+)',text).group(1))
    pool, labels = table('R'), table('L')
    return [(labels >> (4*i) & 15, pool >> (52*i) & ((1<<52)-1)) for i in range(153)]


def closure(width, states):
    N = 1<<width
    rows = np.arange(N,dtype=np.int32)
    moves = [successors(width,rows,wall) for wall in DRIVE]
    reach = np.zeros((3,N),dtype=bool)
    for label,x in states:
        reach[label%3,x%(1<<width)] = True
    while True:
        old = reach.copy()
        for p, (a,b) in enumerate(moves):
            reach[p] |= old[(p+1)%3, a] | old[(p+1)%3, b]
        if np.array_equal(reach,old):
            break
    sparse = [(p,int(r)) for p in range(3) for r in np.flatnonzero(reach[p])]
    ether = rings(width)
    return {'size':len(sparse),'sha256_repr':hashlib.sha256(repr(sparse).encode()).hexdigest(),
            'white':sum(int(reach[p,0]) for p in range(3)),
            'aligned_ether':sum(int(reach[p,r]) for v in ether for p,r in enumerate(v))}


def realize_transient(seq, width, t, candidates):
    """Seek a genuine finite row for a graph endpoint, using the exact triangular cone."""
    from pysat.solvers import Cadical195
    with Cadical195() as solver:
        v=0
        def fresh():
            nonlocal v
            v+=1
            return v
        rows=[[fresh() for _ in range(width+t-i+1)] for i in range(t+1)]
        for k,row in enumerate(rows):
            solver.add_clause([row[0] if DRIVE[k%3] else -row[0]])
            if k==0:
                for j in range(width): solver.add_clause([row[j+1] if (seq[0]>>j)&1 else -row[j+1]])
            if k==t: break
            for j in range(1,len(row)-1):
                a,b,c=row[j-1:j+2]; u=rows[k+1][j]
                for i in range(8):
                    aa,bb,cc=(int(bool(i&q)) for q in (4,2,1))
                    solver.add_clause([(-a if aa else a),(-b if bb else b),(-c if cc else c),
                                       (u if aa^(bb|cc) else -u)])
        selectors=[]
        for w in candidates:
            choose=fresh();selectors.append(choose)
            for j in range(width):
                odd=(w>>j)&1
                solver.add_clause([-choose,rows[-1][j+1] if odd else -rows[-1][j+1]])
        solver.add_clause(selectors)
        if not solver.solve(): return None
        pos={i for i in solver.get_model() if i>0}
        return sum((1<<j) for j,x in enumerate(rows[0][1:]) if x in pos)


def run(width, states):
    N = 1<<width
    all_rows = np.arange(N,dtype=np.int32)
    # Intersect all image layers, starting with every row at every driver phase.
    active = [all_rows]*3
    t = 0
    while True:
        images = [None]*3
        for p,(x,c) in enumerate(zip(active,DRIVE,strict=True)):
            a,b=successors(width,x,c)
            mask=np.zeros(N,dtype=bool)
            mask[a]=True
            mask[b]=True
            images[(p+1)%3]=np.flatnonzero(mask).astype(np.int32)
        if all(np.array_equal(a,b) for a,b in zip(active,images,strict=True)):
            break
        active=images
        t+=1
    ids=np.concatenate([x+p*N for p,x in enumerate(active)])
    dest=[]
    for p,x in enumerate(active):
        a,b=successors(width,x,DRIVE[p]); dest.append(np.column_stack([a,b])+((p+1)%3)*N)
    target=np.concatenate(dest)
    es=np.searchsorted(ids,target)
    assert np.all(ids[es]==target)
    mat=csr_matrix((np.ones(es.size,dtype=bool),es.ravel(),np.arange(0,2*len(ids)+1,2)),shape=(len(ids),)*2)
    _,labels=connected_components(mat, directed=True,connection='strong')
    sizes=np.bincount(labels)
    # Driver phase advances each step, so singleton components have no cycles.
    cyclic=np.flatnonzero(sizes>1)
    giant=int(np.argmax(sizes))
    def reachable(start):
        seen=set(start); todo=deque(seen)
        while todo:
            for j in es[todo.popleft()]:
                if (k:=int(j)) not in seen: seen.add(k); todo.append(k)
        return seen
    def gate_word(comp):
        group=np.flatnonzero(labels==comp)
        if sizes[comp]==123382: return None
        phase={int(group[0]):0}; todo=list(phase)
        while todo:
            v=todo.pop()
            for u in es[v]:
                u=int(u)
                if labels[u]!=comp: continue
                if u not in phase: phase[u]=(phase[v]+1)%15; todo.append(u)
                elif phase[u]!=(phase[v]+1)%15: return None
        colors=[set() for _ in range(15)]
        for i,h in phase.items():
            if ids[i]//N==1: colors[h].add(int(ids[i])&1)
        if any(len(v)>1 for v in colors): return 'varies'
        word=''.join(str(next(iter(v))) for v in colors if v)
        return min(word[j:]+word[:j] for j in range(len(word)))
    ether=rings(width)
    roots = [int(np.searchsorted(ids,seq[p]+p*N)) for seq in ether for p in range(3)]
    assert all(sizes[labels[i]]==3 for i in roots)
    reaches=[]
    for comp in cyclic:
        seed=np.flatnonzero(labels==comp)
        s=reachable(seed)
        dest_sizes=sorted({int(sizes[labels[i]]) for i in s if labels[i]!=comp and sizes[labels[i]]>1})
        reaches.append({'size':int(sizes[comp]),'reachable':len(s),'other_cycles':dest_sizes,
                        'gate_necklace':gate_word(comp)})
    # From each aligned ether row, can a transient window still disagree at site 1?
    # If so its graph membership cannot be inferred from the first visible difference.
    early=[]
    for seq in ether:
        seen=reachable([int(np.searchsorted(ids,seq[0]))])
        off=[int(ids[i]) for i in seen if labels[i]!=giant and (int(ids[i])^seq[ids[i]//N])&1]
        early.append({'ether':seq,'off_before_giant':len(off),'example':min(off) if off else None})
    physical=None
    for n in range(22,85):
        for seq in ether:
            eth0=seq[0]&4095
            initial=sum(((eth0>>(i%12))&1)<<i for i in range(n))
            x=initial
            first=enter=None
            at_departure=None
            for tick in range(512):
                packed=(tick%3)*N+x%N
                idx=int(np.searchsorted(ids,packed))
                assert ids[idx]==packed
                if first is None and (x^seq[tick%3])&1:
                    first=tick
                    at_departure={'row_low22':int(x%N),'scc_size':int(sizes[labels[idx]])}
                if labels[idx]==giant and enter is None: enter=tick
                if first is not None and enter is not None: break
                x=((x<<1)|DRIVE[tick%3])^(x|(x>>1))
            if enter is not None and first is not None and first<enter:
                physical={'cut_width':n,'initial_row_hex':hex(initial),'ether':seq,
                          'first_site1_departure':first,'at_departure':at_departure,
                          'first_giant_entry':enter}
                break
        if physical: break
    tested=[]
    if not physical:
        for seq in ether:
            ids_seq=[int(np.searchsorted(ids,r+p*N)) for p,r in enumerate(seq)]
            layer={ids_seq[0]}
            for t0 in range(1,151):
                layer={int(j) for i in layer for j in es[i] if labels[j]!=giant}
                candidates=sorted({int(ids[i])%N for i in layer if (int(ids[i])^seq[t0%3])&1})
                if not candidates: continue
                tested.append([seq[0],t0,len(candidates)])
                x=realize_transient(seq,width,t0,candidates)
                if x is None: continue
                initial=x; first=None
                for tick in range(512):
                    idx=int(np.searchsorted(ids,(tick%3)*N+x%N))
                    if first is None and (x^seq[tick%3])&1:
                        first=tick
                        at_departure={'row_low22':int(x%N),'scc_size':int(sizes[labels[idx]])}
                    if labels[idx]==giant: break
                    x=((x<<1)|DRIVE[tick%3])^(x|(x>>1))
                assert first is not None and first<tick and labels[idx]==giant
                physical={'cut_width':width,'initial_row_hex':hex(initial),'ether':seq,
                          'first_site1_departure':first,'at_departure':at_departure,
                          'first_giant_entry':tick}
                break
            if physical: break
    c15=set((l%3,(x%N)) for l,x in states)
    pred=mat.transpose().tocsr()
    reachable_from=set(int(np.searchsorted(ids,r+p*N)) for p,r in c15)
    todo=deque(reachable_from)
    while todo:
        i=todo.popleft()
        for j in pred.indices[pred.indptr[i]:pred.indptr[i+1]]:
            j=int(j)
            if j not in reachable_from: reachable_from.add(j); todo.append(j)
    return {'width':width,'stabilized':t,'phase_counts':[len(a) for a in active],'scc':reaches,
            'ether_checks':early,'physical_transient':physical,'physical_queries':tested,'late_15_basin':len(reachable_from)}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kit',type=Path); parser.add_argument('output',type=Path); args=parser.parse_args()
    states=trap_states(args.kit)
    data={'limit':run(22,states),'closure':{w:closure(w,states) for w in (16,20)}}
    # Longest initially aligned ether prefix for a full physical 15-trap state.
    best=(0,None)
    for v in rings(52):
        for l,x in states:
            diff=x^v[l%3]; k=(diff&-diff).bit_length()-1
            if k>best[0]: best=(k,{'label':l,'state':x,'reference':v})
    data['fifteen_ether_prefix']=best
    args.output.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(data))
