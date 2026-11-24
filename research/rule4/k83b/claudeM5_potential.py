# Own check of the westward-speed potentials (claudeM5): cells as explicit tuples, written from the statement in lower.md.
import json, sys
import numpy as np
def check(w, D, P):
    n=1<<w; P=np.array(P,dtype=object if max(abs(int(x)) for x in P)>2**40 else np.int64)
    s=np.arange(n*n); A=s//n; B=s%n
    bit=lambda X,i:(X>>i)&1
    best=None
    for e in range(4):
        ea,eb=e&1,e>>1; tot=np.zeros(n*n,dtype=np.int64)
        for c in (0,1):
            for u in (0,1):
                adv=((bit(A,0)!=bit(B,0)) & (c==0))
                def upd(X,ext):
                    # cells of one copy: site m-2 = u, m-1 = c, m.. = X bits, m+w = ext
                    get=lambda j: (np.full(n*n,u) if j==-2 else np.full(n*n,c) if j==-1 else (bit(X,j) if j<w else np.full(n*n,ext)))
                    rule=lambda j: get(j-1)^(get(j)|get(j+1))
                    stay=sum(rule(k)<<k for k in range(w))
                    move=sum(rule(k-1)<<k for k in range(w))
                    return stay,move
                sa,ma=upd(A,ea); sb,mb=upd(B,eb)
                nxt=np.where(adv,ma,sa)*n+np.where(adv,mb,sb)
                tot+=D*adv.astype(np.int64)+P[nxt]-P[s]
        m=int(tot.max()); best=m if best is None else max(best,m)
    return best
if __name__=='__main__':
    hand=[0,7,4,7,7,0,5,0,4,5,-6,5,7,0,5,-2]
    print('hand width 2, D=5: max', check(2,5,hand), 'so v <=', check(2,5,hand),'/ 20')
    for w in (2,3,4,5,6,7,8):
        d=json.load(open('%s/width%d.json'%(sys.argv[1],w))); print(w,check(w,d['scale'],d['potential']), d['upper_numerator'], d['upper_numerator']/d['upper_denominator'])
    P=json.load(open(sys.argv[1]+'/width8.json'))['potential']; print('oscillation', max(P)-min(P))
