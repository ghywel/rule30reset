# exact check of the Farey-pair route: slopes as quadratic surds and continued fractions with chosen digits (exact rationals far beyond the range)
from fractions import Fraction as F
import random, math
def cf_value(digits):
    x=F(digits[-1])
    for a in reversed(digits[:-1]): x=a+1/x
    return x
def check(beta, M, H, N, TMAX):
    fl=lambda t: math.floor(t*beta)
    # Farey pair (lower, upper)
    v=(fl(1),1); w=(fl(1)+1,1)
    stats=[]
    def low(p): return p[1]*beta>p[0]
    def med(a,b): return (a[0]+b[0],a[1]+b[1])
    def step(a,b):
        """pair as (a,b) unordered: returns kept, new"""
        m=med(a,b)
        if low(m)==low(a): return b,m    # a replaced, b kept
        return a,m
    pairs=0
    out=[]
    a,b=v,w
    while min(a[1],b[1])<TMAX:
        # step lemma: for 1<=t<D : f(t+d)=f(t)+u, both ways, on a bounded window
        for (x,y) in ((a,b),(b,a)):
            top=min(y[1]-1,400)
            for t in list(range(1,top+1))+[y[1]-1]:
                if t>=1: assert fl(t+x[1])==fl(t)+x[0],(x,y,t)
        # sharpness of the far end
        if min(a[1],b[1])>=M:
            p,q=a,b; path=''
            if p[0]%2 and q[0]%2:
                k,m=step(p,q); path+='o'
            else:
                k,m=(p,q) if p[0]%2 else (q,p)
            # k odd numerator, m even numerator
            assert k[0]%2==1 and m[0]%2==0
            k2,m2=step(k,m)
            if k2==m: # even kept
                path+='E'; i,j=H,H+m[1]
                ok=all((fl(i+s)-fl(j+s))%2==0 for s in list(range(0,min(j,300)))+list(range(max(0,j-50),j)))
                K=0
            else:
                big=m2 # k+m, odd
                k3,m3=step(k,big)
                if k3==big:
                    path+='D'; i,j=k[1]+1,big[1]+1; K=2
                    rng=range(0,j-K)
                    ok=all((fl(i+s)-fl(j+s))%2==0 for s in list(rng)[:300]+list(rng)[-50:])
                else:
                    k4,m4=step(k,m3)
                    if k4==m3:
                        path+='E2'; i,j=H,H+m3[1]; K=0
                    else:
                        path+='T'; i,j=H,H+2*k[1]; K=0
                    rng=range(0,j-K)
                    ok=all((fl(i+s)-fl(j+s))%2==0 for s in list(rng)[:300]+list(rng)[-50:])
            assert ok and i>=H and j-i>=N,(beta,path,i,j)
            out.append(path); pairs+=1
        a,b=step(a,b)
        if pairs>60: break
    return out
random.seed(5)
from collections import Counter
C=Counter(); n=0
fam=[[1]*60,[0]+[2]*50,[1]+[2]*50,[0]+[3]*50,[0]+[4]*40,[0,2]+[1,2]*30,[3]+[2]*50,[-2]+[2]*50,[-1]+[1]*60,[0]+list(range(1,30))]
for _ in range(60): fam.append([random.randint(-3,3)]+[random.choice([1,1,2,2,2,3,4,7]) for _ in range(45)])
for ds in fam:
    beta=cf_value(ds+[10**9])   # rational with denominator far beyond the range: floors agree with the irrational's on the range
    H=random.randint(1,12); N=random.randint(1,12); M=max(2*H,N)+1
    o=check(beta,M,H,N,20000); C.update(o); n+=1
print(n,'slopes',dict(C))
