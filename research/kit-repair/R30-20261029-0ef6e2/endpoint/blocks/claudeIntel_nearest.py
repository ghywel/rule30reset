# the example order (blocks 3555 / 35555 by parity of floor(t sqrt2)): do Lowry's gap bound or Jen's bound already exclude it?
import numpy as np
from math import isqrt
o=[isqrt(2*t*t)%2 for t in range(1,6000)]
gaps=[]
for x in o: gaps+= [3]+[5]*(4 if x else 3)
g=np.array(gaps[:20000],dtype=np.int8)
w=[]
for x in gaps[:16000]: w+=[1]+[0]*(x-1)
w=np.array(w[:60000],dtype=np.int8)
def scan(s,qmax,f):
    best=None
    for q in range(1,qmax):
        n=len(s)-q
        ne=np.flatnonzero(s[:n]!=s[q:q+n])
        A=np.concatenate(([-1],ne)); B=np.concatenate((ne,[n]))
        A,B=A[:-1],B[:-1]           # drop the cut last run
        if len(A)==0: continue
        v=f(A+1,q,B-A-1); k=int(np.argmax(v)); 
        if best is None or v[k]>best[0]: best=(int(v[k]),q,int(A[k]+1),int(B[k]-A[k]-1))
    return best
print('gap order: max of 8n-10j over lags<3000 (value, lag, i, n):',scan(g,3000,lambda a,q,n:8*n-10*(a+q)))
print('gap order: max of n-j:',scan(g,3000,lambda a,q,n:n-(a+q)))
print('readings: max of n-j (Jen needs this unbounded) over lags<9000:',scan(w,9000,lambda a,q,n:n-(a+q)))
# growth over dyadic ranges
for lo,hi in((8,64),(64,512),(512,4096),(4096,9000)):
    b=None
    for q in range(lo,hi):
        n=len(w)-q; ne=np.flatnonzero(w[:n]!=w[q:q+n]); A=np.concatenate(([-1],ne))[:-1]; B=ne
        if len(A)==0: continue
        v=(B-A-1)-(A+1+q); k=int(np.argmax(v))
        if b is None or v[k]>b[0]: b=(int(v[k]),q)
    print('readings, lags %d..%d: best n-j = %d at lag %d'%(lo,hi-1,b[0],b[1]))
