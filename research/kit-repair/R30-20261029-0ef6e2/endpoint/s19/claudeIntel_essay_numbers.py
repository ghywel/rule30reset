# independent check of every number in packet b's essay (exact rational arithmetic, 120-digit square roots)
from math import isqrt, floor
from fractions import Fraction as F
D=10**120
def rt(n): return F(isqrt(n*D*D),D)
r2=rt(2); al=r2/2
def word_diff(a,th,n): return [floor(t*a+th)-floor(t*a) for t in range(n)]
def slack(w,q):
    p=[0]+[k+1 for k in range(len(w)-q) if w[k+q]!=w[k]]
    return min(2*p[k]+q+1-p[k+1] for k in range(len(p)-1))
def conv(x,n):
    out=[];h0,h1,k0,k1=0,1,1,0
    for _ in range(n):
        a=floor(x); h0,h1=h1,a*h1+h0; k0,k1=k1,a*k1+k0; out.append((h1,k1)); x=1/(x-a)
    return out
def scales(a,th,n):
    c=conv(a,n+1); f=lambda t: floor(t*a+th); res=[]
    for k in range(1,n):
        u,d=c[k]; r=c[k+1][1]-d; m=1
        while m<d and f(m+d)==f(m)+u: m+=1
        res.append((d,r,m,2*m-r) if m<d else (d,r,None,None))
    return res
th=F(1,2)-3*al
print('scales, 1/2-3*sqrt2/2:',scales(al,th,11))
print('half circle shortfalls:',[x[3] for x in scales(al,F(1,2),8)])
w=word_diff(al,th,6000); h=word_diff(al,F(1,2),6000)
print('slacks shifted',[slack(w,q) for q in(41,99,239,577)],'half',[slack(h,q) for q in(41,99,239,577)])
# left columns
def arc(a,g,n): return [1 if (t*a)%1<g else 0 for t in range(n)]
v=arc(al,F(1,2),150); n=2*len(v)-1
a=[t%2 for t in range(n)]; b=[1 if t%2 else 1-v[t//2] for t in range(n)]
cols=[b]; first,last=a,b
for _ in range(n-1):
    new=[last[t+1]^(last[t]|first[t]) for t in range(len(last)-1)]
    first,last=last,new; cols.append(new)
row=[c[0] for c in cols]
print('first row',len(row),'black',sum(row),'last black at',max(i for i,x in enumerate(row) if x)+1,'cells left of the clock')
# the tables
from decimal import Decimal,getcontext
getcontext().prec=60
e=F(int(Decimal(1).exp()*Decimal(10)**55),10**55); phi=(1+rt(5))/2
for nm,aa,g in(('sqrt2-1, 1/5',r2-1,F(1,5)),('e, 3/10',e,F(3,10)),('1/phi, 1/sqrt3',1/phi,1/rt(3))):
    ww=arc(aa,g,4000); L=[slack(ww,q) for q in range(1,601)]
    print(nm,'lags with slack<=2:',[q+1 for q,x in enumerate(L) if x<=2])
