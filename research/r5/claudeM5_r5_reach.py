"""claudeM5_r5_reach.py W: second code for the component map (dictionary graph, Kosaraju). Which cyclic components of
the 001 limit graph at width W reach which."""
# which cyclic components of the 001 limit graph at width 22 reach which (own code: dictionary graph, Kosaraju)
import pathlib, sys,collections
sys.setrecursionlimit(10000)
w=int(sys.argv[1]); DR=[0,0,1]; M=(1<<w)-1
def stp(c,z,r):
    f=(r<<1)|c|(z<<(w+1)); return (((f<<1)^(f|(f>>1)))>>1)&M
# limit by lifting from 14
def stpw(ww,c,z,r):
    f=(r<<1)|c|(z<<(ww+1)); return (((f<<1)^(f|(f>>1)))>>1)&((1<<ww)-1)
S=[set(range(1<<12)) for _ in range(3)]; ww=12
def fix(S,ww):
    while True:
        N=[set(),set(),set()]
        for p in range(3):
            c=DR[p]
            for r in S[p]:
                N[(p+1)%3].add(stpw(ww,c,0,r)); N[(p+1)%3].add(stpw(ww,c,1,r))
        N=[N[p]&S[p] for p in range(3)]
        if all(len(N[p])==len(S[p]) for p in range(3)): return N
        S=N
S=fix(S,ww)
while ww<w:
    S=[S[p]|{r|(1<<ww) for r in S[p]} for p in range(3)]; ww+=1; S=fix(S,ww)
print('limit',w,[len(x) for x in S])
nodes=[(p,r) for p in range(3) for r in S[p]]; ns=set(nodes)
succ={v:[x for x in {((v[0]+1)%3,stp(DR[v[0]],0,v[1])),((v[0]+1)%3,stp(DR[v[0]],1,v[1]))}] for v in nodes}
bad=sum(1 for v in nodes for x in succ[v] if x not in ns); print('edges leaving the limit:',bad)
# Kosaraju
order=[];seen=set()
for s in nodes:
    if s in seen: continue
    seen.add(s);st=[(s,iter(succ[s]))]
    while st:
        v,it=st[-1]
        for x in it:
            if x not in seen: seen.add(x);st.append((x,iter(succ[x])));break
        else: order.append(v);st.pop()
pred=collections.defaultdict(list)
for v in nodes:
    for x in succ[v]: pred[x].append(v)
comp={};k=0;size=[]
for s in reversed(order):
    if s in comp: continue
    comp[s]=k;q=[s];n=0
    while q:
        v=q.pop();n+=1
        for x in pred[v]:
            if x not in comp: comp[x]=k;q.append(x)
    size.append(n);k+=1
cyc=[c for c in range(k) if size[c]>1]
print('cyclic components',sorted([size[c] for c in cyc],reverse=True))
rep={c:next(v for v in nodes if comp[v]==c) for c in cyc}
for c in sorted(cyc,key=lambda c:-size[c]):
    seen={rep[c]};q=[rep[c]]
    for v in q:
        for x in succ[v]:
            if x not in seen: seen.add(x);q.append(x)
    r={comp[v] for v in seen}
    print('size',size[c],'example phase %d'%rep[c][0],''.join('.#'[(rep[c][1]>>i)&1] for i in range(w)),'reaches cyclic components of sizes',sorted([size[d] for d in cyc if d in r and d!=c]),'| windows reachable',len(seen))
