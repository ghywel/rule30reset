"""claudeM5_r5_frontlaw.py: the period-3 ether's front as 24 states; the recurrent class, its exact potential, and the
times at which the front can reach column 1, over every right side."""
import pathlib, sys,itertools,collections
from fractions import Fraction
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f
P,K=f.ether_pattern(72)
E=collections.defaultdict(set)
for l in range(3):
    for D in range(36,48):
        for c in (0,1):
            st=((D+4*l)%12,int(c!=P[l][D+1]))
            for d2,c2 in f.step_fronts(P,K,l,D,(c,)):
                if d2==K+1: continue
                E[st].add((((d2+4*(l+1))%12,int(c2[0]!=P[(l+1)%3][d2+1])),d2-D))
B=(10,1)
good=[s for s in E if s!=B]
# potential: 5 dD + 2 = psi(old)-psi(new). find recurrent class
def reach(s):
    seen={s};todo=[s]
    while todo:
        a=todo.pop()
        for b,_ in E[a]:
            if b not in seen: seen.add(b);todo.append(b)
    return seen
R={s:reach(s) for s in good}
rec=[s for s in good if all(s in R[t] for t in R[s] if t!=B)]
print('good',len(good),'B reachable from good:',any(B in R[s] for s in good),'recurrent',len(rec),sorted(rec))
psi={}
s0=sorted(rec)[0]; psi[s0]=0; todo=[s0]; ok=True
while todo:
    a=todo.pop()
    for b,dd in E[a]:
        v=psi[a]-(5*dd+2)
        if b in psi: ok&=(psi[b]==v)
        else: psi[b]=v; todo.append(b)
print('exact potential on the recurrent class:',ok,sorted(psi.items()),'range',min(psi.values()),max(psi.values()))
# transient good states: do they also admit exact potential?
todo=list(psi)
pred=collections.defaultdict(set)
for a in good:
    for b,dd in E[a]: pred[b].add((a,dd))
amb={}
for a in good:
    if a in psi: continue
    amb[a]=sorted({psi[b]+5*dd+2 for b,dd in E[a] if b in psi}) 
print('transient states and the values their successors would need:',amb)
# arrival times at D = 1 from every (state, D0), all exteriors
import functools
def arrivals(st,D):
    cur={(st,D)}; t=0; out=set()
    while cur and t<400:
        nx=set()
        for s,d in cur:
            if d==1: out.add(t); continue
            for b,dd in E[s]:
                if s==B: continue
                nx.add((b,d+dd))
        cur=nx; t+=1
    return out
bad=0; spread=collections.Counter()
for s in good:
    for D in range(2,40):
        a=arrivals(s,D); spread[max(a)-min(a)]+=1
print('spread of the arrival time at column 1 over all exteriors:',dict(spread))
for s in sorted(rec): print(s,[sorted(arrivals(s,D)) for D in (2,3,4,5,6,14,26)])
