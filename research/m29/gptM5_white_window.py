"""Look for a reset-free pointed neighborhood of a white anchor in a finite past.
The finite window allows arbitrary boundary input and arbitrary initial interior.
Only UNSAT proves a local forcing law. SAT gives a finite spacetime patch.
"""
import argparse
import json
import re
import z3

def check(radius, height, cutoff, avoid=1):
    if not 1 <= avoid <= height+1: raise ValueError("invalid observation height")
    width=2*radius+1
    row=[z3.BitVec(f'r{t}',width) for t in range(height+1)]
    solver=z3.SolverFor("QF_BV")
    solver.set(timeout=cutoff)
    for r in row:
        solver.add(z3.Extract(radius,radius,r)==0,
                   z3.Extract(radius+2,radius+2,r)==1)
    for r,s in zip(row,row[1:]):
        solver.add(z3.LShR(s,2)==z3.LShR(((r<<2)^((r<<1)|r)),2))
    # Black-run DFA, allowing a partial run at each outer boundary.
    for obs in row[-avoid:]:
        b=[z3.Extract(i,i,obs)==1 for i in range(width)]
        for i in range(width):
            for j in range(i+2,width,3):
                solver.add(z3.Or(b[i],b[j],*[z3.Not(b[k]) for k in range(i+1,j)]))
    status=solver.check()
    out=dict(radius=radius,height=height,status=str(status),avoid=avoid)
    if status==z3.sat:
        values=[solver.model().eval(r).as_long() for r in row]
        for r in values:assert not (r>>radius)&1 and (r>>(radius+2))&1
        mask=(1<<width)-4
        for r,s in zip(values,values[1:]):assert not (s^((r<<2)^((r<<1)|r)))&mask
        for value in values[-avoid:]:
            assert not re.search(r'01(?:111)*0',format(value,f'0{width}b'))
        out['rows']=[hex(v) for v in values]
    return out

if __name__=="__main__":
    ap=argparse.ArgumentParser(); ap.add_argument('radius',type=int); ap.add_argument('height',nargs='+',type=int)
    ap.add_argument('--avoid',type=int,default=1); ap.add_argument('--ms',default=10000,type=int);a=ap.parse_args()
    for h in a.height:print(json.dumps(check(a.radius,h,a.ms,a.avoid)),flush=True)
