# Own check of the two-step obstruction (claudeM5): forward lifting, graphs of triples, my own trimming and SCC test.
import json, itertools, sys
F=sys.argv[1]
d=json.load(open(F)); E=[tuple(e) for e in d['edges']]
# physical triples from scratch: letter = 2*west+east at two adjacent sites over 3 ticks; sites -2..3, observe 0 and 1
phys=set()
for cells in itertools.product((0,1),repeat=6):
    x={i-2:cells[i] for i in range(6)}; w=[]
    for t in range(3):
        w.append(2*x[0]+x[1]); x={j:x[j-1]^(x[j]|x[j+1]) for j in x if j-1 in x and j+1 in x}
    phys.add(tuple(w))
assert phys==set(E) and len(E)==32, (len(phys),len(E))
def graph(mask): return [E[i] for i in range(32) if mask>>i&1]
def trim(T):
    T=set(T)
    while True:
        src={(a,b) for a,b,c in T}; dst={(b,c) for a,b,c in T}
        Y={t for t in T if (t[0],t[1]) in dst and (t[1],t[2]) in src}
        if Y==T: return Y
        T=Y
def maskof(T): return sum(1<<E.index(t) for t in T)
def lifts(T,word):
    """Is there c with the word (b,c) in the graph T, with Rule 30 at every step? forward."""
    a=[w>>1 for w in word]; b=[w&1 for w in word]; V={(t[0],t[1]) for t in T}|{(t[1],t[2]) for t in T}
    St={(p,q) for p in (0,1) for q in (0,1) if b[1]==a[0]^(b[0]|p) and (2*b[0]+p,2*b[1]+q) in V}
    for t in range(1,len(word)-1):
        N=set()
        for p,q in St:
            if b[t+1]!=a[t]^(b[t]|q): continue
            for r in (0,1):
                if (2*b[t-1]+p,2*b[t]+q,2*b[t+1]+r) in T: N.add((q,r))
        St=N
    return bool(St)
def simple(T):
    """No strongly connected component has a vertex with two internal out-edges (Tarjan-free: reachability)."""
    V=sorted({(t[0],t[1]) for t in T}|{(t[1],t[2]) for t in T}); out={v:[(t[1],t[2]) for t in T if (t[0],t[1])==v] for v in V}
    reach={}
    for v in V:
        seen=set(); st=list(out[v])
        while st:
            x=st.pop()
            if x in seen: continue
            seen.add(x); st+=out[x]
        reach[v]=seen
    return all(sum(1 for y in out[v] if v in reach[y])<=1 for v in V if v in reach[v])
proof={int(k):v for k,v in d['proof'].items()}
root=trim(E); st=[maskof(root)]; seen=set(); kinds={}
while st:
    m=st.pop()
    if m in seen: continue
    seen.add(m); T=trim(graph(m)); assert maskof(T)==m,'not trimmed'
    kind,*arg=proof[m]; kinds[kind]=kinds.get(kind,0)+1
    if kind=='cycles': assert simple(T)
    elif kind=='miss':
        w=arg[0]; assert len(w)>=2
        if len(w)>2: assert all(t in T for t in zip(w,w[1:],w[2:]))
        else: assert (w[0],w[1]) in {(t[0],t[1]) for t in T}
        assert not lifts(T,w),('lift',m,w)
        kids=[T-{t} for t in set(zip(w,w[1:],w[2:]))] if len(w)>2 else [{t for t in T if (w[0],w[1]) not in ((t[0],t[1]),(t[1],t[2]))}]
        for K in kids:
            K=trim(K); k=maskof(K); assert (not K) or k in proof,('missing child',m); 
            if K: st.append(k)
    else: raise SystemExit(kind)
print('checked',len(seen),'nodes of',len(proof),kinds)
