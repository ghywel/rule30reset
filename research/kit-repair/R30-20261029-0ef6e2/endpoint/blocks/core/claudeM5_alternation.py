import math, random
from fractions import Fraction
def convergents(a, n=30):
    # continued fraction of a (float, mpmath-free; use high precision via Fraction approximations)
    import decimal
    res=[]; p0,q0,p1,q1=0,1,1,0
    x=a
    for _ in range(n):
        ai=math.floor(x); p0,q0,p1,q1=p1,q1,ai*p1+p0,ai*q1+q0; res.append((p1,q1))
        f=x-ai
        if f<1e-12: break
        x=1/f
    return res
random.seed(1)
worst=0; strict_viol=0; trials=0
for trial in range(300):
    alpha=random.random(); th=random.random(); gam=random.uniform(0.02,0.98)
    cs=convergents(alpha,12)
    # pick a consecutive pair with q>=10
    pairs=[(cs[i],cs[i+1]) for i in range(1,len(cs)-1) if cs[i][1]>=10 and cs[i+1][1]<=5000]
    if not pairs: continue
    (u,q),(U,Q)=random.choice(pairs)
    S=20*Q
    f1=lambda t: math.floor(th+t*alpha); f2=lambda t: math.floor(th+t*alpha-gam)
    F1=[t for t in range(S) if f1(t+q)-f1(t)!=f1(q)-f1(0) and False]
    # generic increment: the more common value
    inc1=[f1(t+q)-f1(t) for t in range(S)]; inc2=[f2(t+q)-f2(t) for t in range(S)]
    gen=max(set(inc1),key=inc1.count)
    fa=[t for t in range(S) if inc1[t]!=gen]; fb=[t for t in range(S) if inc2[t]!=gen]
    # running discrepancy
    ev=sorted([(t,1) for t in fa]+[(t,-1) for t in fb]); run=0; lo=hi=0
    for t,s in ev: run+=s; lo=min(lo,run); hi=max(hi,run)
    worst=max(worst,hi-lo); trials+=1
    # strict alternation: consecutive same-line events
    seq=[s for t,s in ev]
    if any(seq[i]==seq[i+1] for i in range(len(seq)-1)): strict_viol+=1
print("trials",trials,"max spread of #F1-#F2",worst,"cases with two same-line failures in a row",strict_viol)
