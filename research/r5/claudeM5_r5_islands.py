"""claudeM5_r5_islands.py W: the small components of the 001 limit graph, lifted one column at a time to width W.
The limit windows at width 16 are found by direct iteration; every cyclic component is lifted to 22, then the small ones
alone (a cycle at width w + 1 projects to a closed walk at width w). Prints sizes, periods, closed ones and gates."""
# lift the small components of the 001 limit graph, one column at a time, from width 22
import pathlib, sys, collections, math, subprocess
DR=[0,0,1]
def stp(w,c,z,r):
    f=(r<<1)|c|(z<<(w+1)); return (((f<<1)^(f|(f>>1)))>>1)&((1<<w)-1)
def sccs(nodes,w):
    ns=set(nodes); succ={}
    for (p,r) in ns:
        succ[(p,r)]=[x for x in {((p+1)%3,stp(w,DR[p],0,r)),((p+1)%3,stp(w,DR[p],1,r))} if x in ns]
    idx={};low={};on=set();st=[];out=[];cnt=0
    for s in ns:
        if s in idx: continue
        idx[s]=low[s]=cnt;cnt+=1;st.append(s);on.add(s);work=[(s,iter(succ[s]))]
        while work:
            v,it=work[-1];adv=False
            for x in it:
                if x not in idx:
                    idx[x]=low[x]=cnt;cnt+=1;st.append(x);on.add(x);work.append((x,iter(succ[x])));adv=True;break
                elif x in on: low[v]=min(low[v],idx[x])
            if adv: continue
            work.pop()
            if work: low[work[-1][0]]=min(low[work[-1][0]],low[v])
            if low[v]==idx[v]:
                c=[]
                while True:
                    x=st.pop();on.discard(x);c.append(x)
                    if x==v: break
                if len(c)>1: out.append(c)
    return out,succ
def period(c,succ):
    cs=set(c);L={c[0]:0};q=[c[0]];g=0
    for v in q:
        for x in succ[v]:
            if x not in cs: continue
            if x not in L: L[x]=L[v]+1;q.append(x)
            else: g=math.gcd(g,abs(L[v]+1-L[x]))
    return g
def closed(c,w):
    cs=set(c)
    return all(((p+1)%3,stp(w,DR[p],z,r)) in cs for p,r in c for z in (0,1))
def gate(c,succ,w):
    """column 1 at phase 1 along class levels, if constant on each class"""
    g=period(c,succ);cs=set(c);L={c[0]:0};q=[c[0]];cl={}
    for v in q:
        cl.setdefault(L[v]%g,set()).add((v[0],v[1]&1))
        for x in succ[v]:
            if x in cs and x not in L: L[x]=L[v]+1;q.append(x)
    s=''
    for k in range(g):
        vals=cl.get(k,set()); ph={p for p,_ in vals}; b={x for _,x in vals}
        s+=('|' if ph=={0} else '')+('?' if len(b)>1 else '.#'[b.pop()])
    return s
# start: limit windows at width 22 by direct iteration in C is done elsewhere; here rebuild at width 16 and lift everything small
def limit(w):
    S=[set(range(1<<w)) for _ in range(3)]
    while True:
        N=[set() for _ in range(3)]
        for p in range(3):
            for r in S[p]:
                N[(p+1)%3].add(stp(w,DR[p],0,r));N[(p+1)%3].add(stp(w,DR[p],1,r))
        N=[N[p]&S[p] for p in range(3)]
        if all(len(N[p])==len(S[p]) for p in range(3)): return S
        S=N
w=16; S=limit(w); nodes=[(p,r) for p in range(3) for r in S[p]]
while True:
    comps,succ=sccs(nodes,w); comps.sort(key=len,reverse=True)
    big=[c for c in comps if len(c)>5000]
    small=[c for c in comps if len(c)<=5000]
    print('width',w,'limit/kept nodes',len(nodes),'giant',[len(c) for c in big],'| small:',[(len(c),period(c,succ),'CLOSED' if closed(c,w) else '') for c in small],flush=True)
    if w>=22 or not big: break
    # lift everything up to 22
    N=[]
    for c in comps:
        for (p,r) in c: N+= [(p,r),(p,r|(1<<w))]
    w+=1; nodes=N
small=[c for c in comps if len(c)<=5000 and period(c,succ)!=3]
for c in small: print('   gate of the component of size',len(c),gate(c,succ,w))
while small and w<int(sys.argv[1]):
    N=[]
    for c in small:
        for (p,r) in c: N+=[(p,r),(p,r|(1<<w))]
    w+=1; comps,succ=sccs(N,w); small=comps; small.sort(key=len,reverse=True)
    print('width',w,[(len(c),period(c,succ),'CLOSED' if closed(c,w) else '') for c in small],flush=True)
    if sum(map(len,small))>400000: break
for c in small[:6]: print(len(c),gate(c,succ,w))
