"""An adversarial white-to-white interval. Bit t of a column is its value at tick t.
Search for a reset-free phase at a period doubling. UNSAT covers that (P,gap) only.
A timeout is unknown. A SAT model is checked directly as a spacetime rectangle.
"""
import argparse
import json
import re

import z3

def check(p, gap, milliseconds):
    period=2*p
    d=[z3.BitVec(f"d{j}",period) for j in range(gap+1)]
    solver=z3.SolverFor("QF_BV")
    solver.set(timeout=milliseconds)
    solver.add(d[0]==0, d[gap]==0, z3.RotateRight(d[1],p)==~d[1])
    for j in range(1,gap):
        solver.add(d[j]!=0)   # the next white wheel, excluding any intermediate white
    for j in range(2,gap+1):
        solver.add(z3.RotateRight(d[j],1)==d[j-2]^(d[j-1]|d[j]))
    bits=[z3.Extract(0,0,col)==1 for col in d]
    # The last white delimiting a black run is in the interval, including endpoints.
    for a in range(gap):
        for b in range(a+2,gap+1,3):
            solver.add(z3.Or(bits[a],bits[b],*[z3.Not(bits[k]) for k in range(a+1,b)]))
    status=solver.check()
    result=dict(p=p,gap=gap,status=str(status))
    if status==z3.sat:
        vals=[solver.model().eval(col).as_long() for col in d]
        rot=lambda x:(x>>1)|((x&1)<<(period-1))
        mask=(1<<period)-1
        assert vals[0]==vals[-1]==0 and all(vals[1:-1])
        assert all(rot(vals[j])==vals[j-2]^(vals[j-1]|vals[j]) for j in range(2,gap+1))
        assert (vals[1]>>p)^(vals[1]&((1<<p)-1))==(1<<p)-1
        row=''.join(str(x&1) for x in vals)
        assert not re.search(r'01(?:111)*0',row)
        b=rot(vals[1])^vals[1]
        assert b==(b&((1<<p)-1))*(1+(1<<p)) and (b&((1<<p)-1)).bit_count()%2
        result.update(row=row,source=b&((1<<p)-1),columns=[hex(v&mask) for v in vals])
    return result

if __name__=="__main__":
    ap=argparse.ArgumentParser()
    ap.add_argument("period",type=int)
    ap.add_argument("gaps",type=int,nargs="+")
    ap.add_argument("--ms",type=int,default=10000)
    a=ap.parse_args()
    for gap in a.gaps:
        print(json.dumps(check(a.period,gap,a.ms)),flush=True)
