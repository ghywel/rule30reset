# claudeM5, 26 November 2026 (M210). Exploration for the S27 core port, part 2: a single line's failures at lag q
# are not balanced over windows, so the window count cannot be bounded line by line at one scale.
# Prints: tests 392, unbalanced 317, outside {L-1, L, L+1} 257. Standard library only; about 5 s.
import math, random
from fractions import Fraction as Fr
from decimal import Decimal, getcontext
getcontext().prec=60
def cf_convergents(x, n=25):
    res=[]; p0,q0,p1,q1=0,1,1,0
    for _ in range(n):
        a=int(x); p0,q0,p1,q1=p1,q1,a*p1+p0,a*q1+q0; res.append((p1,q1))
        f=x-a
        if f==0: break
        x=1/f
    return res
random.seed(5)
bad_single=0; bad_lambda=0; tests=0
for trial in range(400):
    alpha=Decimal(random.random()); th=Decimal(random.random())
    cs=cf_convergents(alpha,14)
    pairs=[(cs[i],cs[i+1]) for i in range(1,len(cs)-1) if 3<=cs[i][1]<=200 and cs[i+1][1]<=3000]
    if not pairs: continue
    (u,q),(U,Q)=random.choice(pairs)
    S=12*Q+50
    fl=[int((th+t*alpha).__floor__()) for t in range(S+q+1)]
    g=lambda n: int((n*alpha).__floor__())
    inc=[fl[t+q]-fl[t] for t in range(S)]
    gen=g(q)  # generic increment
    phi=[1 if inc[t]!=gen else 0 for t in range(S)]
    pre=[0]
    for x in phi: pre.append(pre[-1]+x)
    tests+=1
    for n in range(1,4*Q,7):
        cnts=[pre[s+n]-pre[s] for s in range(0,S-n,3)]
        if max(cnts)-min(cnts)>1: bad_single+=1; break
    # check counts lie in {L(n), L(n)+1} with L(n)=|g(qn)-n*g(q)| style
    for n in range(1,4*Q,11):
        L=abs(g(q*n)-n*gen) if gen==u else abs(g(q*n)-n*gen)
        cnts=set(pre[s+n]-pre[s] for s in range(0,S-n,5))
        if not cnts <= {L,L+1, L-1}: bad_lambda+=1; break
print("tests",tests,"cases where a single line's failures are unbalanced",bad_single,"cases outside {L-1,L,L+1}",bad_lambda)
