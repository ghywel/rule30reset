"""Site-by-site replay of the five controllable regimes and steering examples."""
from pathlib import Path
from itertools import product
import json
D=Path(__file__).parent
def rule(l,c,r): return (30>>(4*l+2*c+r))&1
def bits(x,w): return [(x>>i)&1 for i in range(w)]
def integer(row): return sum(a<<i for i,a in enumerate(row))
def advance(x,w,new,ext):
    row=bits(x,w)+[ext]
    return new+sum(rule(row[i-1],row[i],row[i+1])<<i for i in range(1,w))
data=json.loads((D/'source-policies.json').read_text())
# 0: choose the next center zero, independent of every other cell.
# 1: the prefix 101 is invariant when the next center is black.
for ext in range(2):
    assert advance(5,3,1,ext)==5
q=data['third']
w=q['width'];allowed=[i for i in range(1<<w) if (q['state_mask']>>i)&1]
assert q['start'] in allowed
for x in allowed:
    assert x&3!=1
    for r in (0,1):
        y=advance(x,w,(q['control_mask']>>x)&1,r)
        assert y in allowed and data['credit'][x&63]-data['credit'][y&63]==3*(x&1)-1
print('one third:',w,len(allowed),'both exterior bits verified at every state')
for label,rec in data['locks'].items():
    P,W=rec['period'],rec['width'];graph=set(map(tuple,rec['rows']))
    assert (rec['start'],0) in graph
    for x,t in graph:
        c,r,e,f=bits(x,4)
        assert (c,r)==(rec['center']>>t&1,rec['neighbor']>>t&1)
        new=(e|f) if r else 1
        for ext in (0,1):
            assert (advance(x,W,new,ext),(t+1)%P) in graph
    print(label,W,len(graph),'counts',rec['center'].bit_count(),(rec['center']&~rec['neighbor']).bit_count())
def drive(row,controls):
    for v in controls:row=[v]+[rule(a,b,c) for a,b,c in zip(row,row[1:],row[2:])]
    return row
for w in range(1,6):
    for seed in range(1<<(2*w)):
        row=bits(seed,2*w)
        assert len({integer(drive(row,cc)) for cc in product((0,1),repeat=w)})==1<<w
print('triangular steering is bijective for every cone through width 5.')
