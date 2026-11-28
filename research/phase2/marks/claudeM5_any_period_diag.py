# K92.4, claudeM5 (M233): a third, plain check of the modulus-two certificates, after the runs.
# Rule 30 cell by cell, the fall-phase strip graph with both exterior cells free, Kosaraju's components, each
# component's period from breadth-first levels, and the adjacent pairs constant on every cyclic class.
# Usage: python3 claudeM5_any_period_diag.py ASSIGNMENT ...   (west cell first, 0 = even ticks, 1 = odd ticks)
# Prints, per nontrivial component: its size, its period and the first rigid pairs; "certified" when every
# component has one. Practical to width 20.
import sys
from math import gcd
sys.setrecursionlimit(10000)
def run(a):
    W=len(a); par=[int(c) for c in a]
    def step(r,zw,ze):
        d=0
        for i in range(W):
            l= zw if i==0 else (r>>(i-1))&1
            s=(r>>i)&1
            rt= ze if i==W-1 else (r>>(i+1))&1
            if l^(s|rt): d|=1<<i
        return d
    N=2<<W
    succ=[[] for _ in range(N)]
    for v in range(N):
        r,p=v>>1,v&1
        for k in range(4):
            d=step(r,k>>1,k&1)
            fall=r&~d
            if any((fall>>i)&1 and par[i]!=p for i in range(W)): continue
            succ[v].append(2*d+(1-p))
    # Kosaraju with explicit stacks
    pred=[[] for _ in range(N)]
    for v in range(N):
        for w in succ[v]: pred[w].append(v)
    seen=[False]*N; order=[]
    for s in range(N):
        if seen[s]: continue
        st=[(s,0)]; seen[s]=True
        while st:
            v,i=st[-1]
            if i<len(succ[v]):
                st[-1]=(v,i+1); w=succ[v][i]
                if not seen[w]: seen[w]=True; st.append((w,0))
            else: order.append(v); st.pop()
    comp=[-1]*N; comps=[]
    for s in reversed(order):
        if comp[s]!=-1: continue
        c=len(comps); comp[s]=c; mem=[]; st=[s]
        while st:
            v=st.pop(); mem.append(v)
            for u in pred[v]:
                if comp[u]==-1: comp[u]=c; st.append(u)
        comps.append(mem)
    out=[]
    for c,mem in enumerate(comps):
        if len(mem)==1 and mem[0] not in succ[mem[0]]: continue
        lev={mem[0]:0}; q=[mem[0]]; g=0
        for v in q:
            for w in succ[v]:
                if comp[w]!=c: continue
                if w not in lev: lev[w]=lev[v]+1; q.append(w)
                else: g=gcd(g,abs(lev[v]+1-lev[w]))
        rig=[]
        for j in range(W-1):
            cls={}
            ok=True
            for v in mem:
                rd=(v>>1>>j)&3; k=lev[v]%g
                if cls.setdefault(k,rd)!=rd: ok=False;break
            if ok: rig.append(j)
        out.append((len(mem),g,rig))
    return out
for a in sys.argv[1:]:
    res=run(a)
    cert=all(r[2] for r in res)
    print(a,'certified' if cert else 'NOT certified',[(n,d,rg[:3]) for n,d,rg in res])
