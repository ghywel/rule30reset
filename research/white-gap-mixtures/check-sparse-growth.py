"""Verify integer exponential bounds against the generated observer. Python 3 / NumPy."""
from pathlib import Path
import json
import numpy as np
import sys

def check(width):
    file=Path(f'observer-{width}.txt')
    with file.open() as source:
        n,start,dead=map(int,source.readline().split())
        t=np.loadtxt(source,dtype=np.int32)
    assert t.shape==(n,8) and t.min()>=0 and t.max()<n and np.all(t[dead]==dead)
    h=np.full(n,10**10,dtype=np.int64);h[dead]=0
    for _ in range(130):
        # Scale with Python integers. Use coarse fixed-point downscaling within int64 bounds.
        a=h[t].sum(axis=1);a[dead]=0
        h=(a*10**8)//max(1,int(a.max())//100+1)
        assert 0<=h.min() and h.max()<=10**10
    a=h[t].sum(axis=1)
    lo,hi={26:(3008,3010),27:(2951,2953)}[width]
    assert h[start]>0 and np.all(h[np.arange(n)!=dead]>0)
    assert (lo*h<=1000*a).all() and (1000*a<=hi*h).all()
    result={'width':width,'states':n,'lower_numerator':lo,'upper_numerator':hi,'denominator':1000}
    if width==27:
        cost=np.ones(n,dtype=np.int64);cost[dead]=0
        for it in range(1000):
            assert cost.max()<10**8
            new=np.maximum(cost,(cost[t].sum(axis=1)+2)//3)
            if np.array_equal(new,cost):break
            cost=new
        assert (cost[t].sum(axis=1)<=3*cost).all() and cost[start]==474
        result.update(three_weight=int(cost[start]),iterations=it)
    print(result,flush=True)
    Path(f'exact-growth-{width}.json').write_text(json.dumps(result,indent=2))
if __name__=='__main__':
    for w in map(int,sys.argv[1:]):check(w)
