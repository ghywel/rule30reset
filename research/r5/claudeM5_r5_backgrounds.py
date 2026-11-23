"""claudeM5_r5_backgrounds.py P: every rule-30 background of temporal period at most P, and the exact least and greatest
mean speed of its front over the cycles of the front graph (one and two cells kept)."""
import pathlib, sys,itertools,collections,json
from fractions import Fraction
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f
def rot(x,P): return ((x>>1)|((x&1)<<(P-1)))          # x(t+1)
def backgrounds(P):
    """all cycles of the leftward column map (u,v)->(left,u), left(t)=u(t+1)^(u(t)|v(t)); words are bit t."""
    M=1<<P
    import numpy as np
    u=np.repeat(np.arange(M,dtype=np.int64),M); v=np.tile(np.arange(M,dtype=np.int64),M)
    r=((u>>1)|((u&1)<<(P-1)))
    left=r^(u|v); nxt=left*M+u
    # find cycle elements: iterate image
    cur=nxt.copy(); 
    # repeated squaring to a large power, image = cyclic elements
    pw=nxt.copy()
    for _ in range(2*P+2): pw=pw[pw]
    cyc=np.unique(pw)
    cyc=set(cyc.tolist()); out=[]
    nx=nxt
    while cyc:
        a=next(iter(cyc)); c=[a]; b=int(nx[a])
        while b!=a: c.append(b); b=int(nx[b])
        for x in c: cyc.discard(x)
        # columns right to left: u words; c[i]=(u_i,v_i) with v_i = column to the right of u_i
        cols=[x//M for x in c][::-1]      # left to right
        out.append(cols)
    return out
def canon(cols,P):
    S=len(cols); rows=[tuple((cols[j]>>t)&1 for j in range(S)) for t in range(P)]
    best=None
    for r in rows:
        for k in range(S):
            q=r[k:]+r[:k]
            if best is None or q<best: best=q
    return best
def least(cols,P):
    for p in range(1,P+1):
        if P%p==0 and all(((c>>t)&1)==((c>>((t+p)%P))&1) for c in cols for t in range(P)): return p
def speeds(cols,P,look):
    S=len(cols); reps=max(3,(60//S)+2)
    W=S*reps*2
    Pt=[[(cols[j%S]>>l)&1 for j in range(W+1)] for l in range(P)]
    mid=S*reps
    E=collections.defaultdict(set); far=0
    for l in range(P):
        for D in range(mid,mid+S):
            for c in itertools.product((0,1),repeat=look):
                for d2,c2 in f.step_fronts(Pt,W,l,D,c):
                    if d2==W+1: far+=1; continue
                    E[(l,D%S,c)].add((((l+1)%P,d2%S,c2),d2-D))
    # SCCs
    import networkx as nx
    G=nx.DiGraph()
    for a,bs in E.items():
        for b,dd in bs: G.add_edge(a,b)
    res=[]
    for comp in nx.strongly_connected_components(G):
        cs=set(comp); ed=[(a,b,dd) for a in comp for b,dd in E.get(a,()) if b in cs]
        if not ed: continue
        # exact means by Karp
        n=len(comp); idx={a:i for i,a in enumerate(comp)}
        rng=[]
        for sg in (1,-1):
            INF=10**9; d=[[INF]*n for _ in range(n+1)]; d[0][0]=0
            el=[(idx[a],idx[b],sg*dd) for a,b,dd in ed]
            for k in range(1,n+1):
                dk,dp=d[k],d[k-1]
                for a,b,w in el:
                    if dp[a]<INF and dp[a]+w<dk[b]: dk[b]=dp[a]+w
            best=None
            for i in range(n):
                if d[n][i]<INF:
                    wv=max(Fraction(d[n][i]-d[k][i],n-k) for k in range(n) if d[k][i]<INF)
                    best=wv if best is None or wv<best else best
            rng.append(sg*best)
        res.append((n,str(rng[0]),str(rng[1])))
    res.sort(reverse=True)
    return len(E),far,res
if __name__=='__main__':
    for P in range(1,int(sys.argv[1])+1):
        seen=set()
        for cols in backgrounds(P):
            if least(cols,P)!=P: continue
            k=canon(cols,P)
            if k in seen: continue
            seen.add(k)
            S=len(cols)
            for look in (1,2):
                if P*S*2**look>6000: continue
                n,far,res=speeds(cols,P,look)
                print('period',P,'space',S,'look',look,'nodes',n,'far',far,'components (size, least, greatest mean):',res[:6],flush=True)
