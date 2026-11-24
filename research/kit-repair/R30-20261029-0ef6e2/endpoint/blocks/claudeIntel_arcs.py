# repeats of one-arc orders with a rational arc (gap 3 inside, 5 outside): largest 8n-10j in the gaps (Lowry) and n-j in the readings (Jen), by range of lags (claudeIntel, N17)
import numpy as np
from math import isqrt
def scan(s,lo,hi,f):
    best=None
    for q in range(lo,hi):
        n=len(s)-q
        ne=np.flatnonzero(s[:n]!=s[q:q+n])
        A=np.concatenate(([-1],ne))[:-1]; B=ne
        if len(A)==0: continue
        v=f(A+1,q,B-A-1); k=int(np.argmax(v))
        if best is None or v[k]>best[0]: best=(int(v[k]),q,int(A[k]+1),int(B[k]-A[k]-1))
    return best
# {t*alpha} in [0,p/q) with alpha=sqrt(D)-c : floor(q t sqrt D) mod q < p
def order(D,p,q,N,end):
    out=[]
    for t in range(N):
        if end=='L': x=isqrt(q*q*t*t*D)%q; out.append(x<p)
        else:
            # start at p/q : {t alpha + p/q}
            x=(isqrt(q*q*t*t*D)+p)%q; out.append(x<p)
    return out
for name,D,p,q in (('sqrt3 1/6',3,1,6),('sqrt3 2/11',3,2,11),('sqrt5 1/5',5,1,5)):
    for end in 'LR':
        o=order(D,p,q,40000,end)
        g=np.array([3 if x else 5 for x in o],dtype=np.int8)
        r=[scan(g,lo,hi,lambda a,k,n:8*n-10*(a+k)) for lo,hi in ((1,64),(64,512),(512,4096),(4096,9000))]
        w=[]
        for x in g[:24000]: w+=[1]+[0]*(int(x)-1)
        w=np.array(w[:100000],dtype=np.int8)
        r2=[scan(w,lo,hi,lambda a,k,n:n-(a+k)) for lo,hi in ((1,64),(64,512),(512,4096),(4096,12000))]
        print(name,end,'gaps 8n-10j:',r,'readings n-j:',r2,flush=True)
