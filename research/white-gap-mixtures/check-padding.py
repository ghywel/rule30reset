"""Replay the strip witness, actual 92-tick histories, counter examples and exact padding radii."""
import json
from pathlib import Path
import sys
import numpy as np

def evolve(row,width,driver,exterior):
    result=0
    for site in range(width):
        left=driver if site==0 else (row>>(site-1))&1
        center=(row>>site)&1
        right=exterior if site+1==width else (row>>(site+1))&1
        result|=(left^(center|right))<<site
    return result

def one_gap(row, gap, width):
    """Every actual endpoint is determined by the next gap+1 initial cells."""
    mask = (1 << width) - 1
    extra = np.arange(1 << (gap + 1), dtype=np.uint64)
    actual = row | (extra << width)
    free = {row}
    for tick in range(gap + 1):
        pulse = int(tick == 0)
        actual = ((actual << 1) | pulse) ^ (actual | (actual >> 1))
        free = {
            (((state << 1) | pulse) ^ (state | (state >> 1) | (b << (width - 1)))) & mask
            for state in free for b in (0, 1)
        }
    endpoints = set(map(int, np.unique(actual & mask)))
    assert endpoints <= free
    return endpoints, free

def witness(cert):
    w=cert['width'];word=cert['gaps'];start=cert['row']
    observations=[]
    for path in cert['paths']:
        row=start;seen=[]
        incompatible = 0
        for j,(q,ext) in enumerate(zip(word,path['exterior'])):
            assert row==path['rows'][j] and 9<=q<=16
            actual, free = one_gap(row, q, w)
            if j == 0:
                assert (len(actual), len(free)) == (13, 21)
            incompatible += path['rows'][j+1] not in actual
            for t in range(q+1):
                if t==2:seen.append(row&1)
                row=evolve(row,w,int(t==0),(ext>>t)&1)
        assert row==start and seen==path['bits']
        assert incompatible == 10
        observations.append(seen)
    diff=[i for i,(a,b) in enumerate(zip(*observations)) if a!=b]
    assert diff==[7] and sum(q+1 for q in word[:7])+2==92
    assert sum(q+1 for q in word)==252
    drive=[b for q in word for b in [1]+[0]*q]
    for seed,expected in [(0x1ffffffffffffffff81b8425,0),(0x1fffffffffffc7fe081b8425,1)]:
        assert seed% (1<<w)==start
        for b in drive[:92]:
            seed=((seed<<1)|b)^(seed|(seed>>1))
        assert seed&1==expected

def radii(file,anchor):
    data=np.fromfile(file,dtype='<i4')
    n=int(data[0]);verts=data[1:n+1];idx=int(np.flatnonzero(verts==anchor)[0])
    ptr=n+1;ends=[];counts=[]
    for _ in verts:
        count=0
        for _ in range(8):
            size=int(data[ptr]);ptr+=1
            if size:ends.append(data[ptr:ptr+size])
            ptr+=size;count+=size
        counts.append(count)
    assert ptr==len(data) and n==163889
    dest=np.concatenate(ends);source=np.repeat(np.arange(n,dtype=np.int32),counts)
    def all_at(a,b):
        active=np.zeros(n,dtype=bool);active[idx]=True
        for t in range(1,100):
            new=np.zeros(n,dtype=bool);new[b[active[a]]]=True
            if new.all():return t
            active=new
        raise AssertionError('all-row bound exceeds test horizon')
    assert (all_at(source,dest),all_at(dest,source))==(16,13)
if __name__=='__main__':
    cert=json.loads(Path(sys.argv[1] if len(sys.argv)>1 else Path(__file__).with_name('padding-witness.json')).read_text())
    witness(cert)
    if len(sys.argv)>2:radii(Path(sys.argv[2]),cert['row'])
    print('All supplied checks passed.')
