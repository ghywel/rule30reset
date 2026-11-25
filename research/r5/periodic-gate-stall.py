"""Solve and replay a candidate front path in one genuine Rule 30 cone."""
import argparse
import json
from pathlib import Path

from pysat.formula import CNF
from pysat.solvers import Cadical195


def run(data, steps, dimacs, witness):
    cycle, background = data["cycle"], data["background"]
    stride = data.get("stride",1)
    observed = max(row[1] for row in cycle)+1
    phase = cycle[0][0]
    variables, next_index = [], 1
    for t in range(steps+1):
        width=observed+steps-t
        variables.append(list(range(next_index,next_index+width)))
        next_index+=width
    cnf=CNF()
    for t in range(steps):
        old,new=variables[t:t+2]
        wall=background[(phase+t)%len(background)][0]
        c,r,z=old[0],old[1],new[0]
        if wall:
            z=-z
        cnf.extend([[-c,z],[-r,z],[c,r,-z]])
        for p in range(1,len(new)):
            l,c,r=old[p-1:p+2]
            z=new[p]
            cnf.extend([[-c,-z,-l],[-c,z,l],[-r,-z,-l],[-r,z,l],[c,r,-z,l],[c,r,z,-l]])
    for t,row in enumerate(variables):
        if t % stride:
            continue
        phase_t,d,b=cycle[(t//stride)%len(cycle)]
        ref=background[phase_t]
        assert phase_t==(phase+t)%len(background)
        for p in range(1,d+2):
            bit=ref[p%len(ref)] ^ (1 if p==d else b if p==d+1 else 0)
            cnf.append([row[p-1] if bit else -row[p-1]])
    if dimacs:
        cnf.to_file(str(dimacs))
    with Cadical195(bootstrap_with=cnf.clauses) as solver:
        if not solver.solve():
            print(f"{steps} updates UNSAT ({cnf.nv} variables, {len(cnf.clauses)} clauses)")
            return
        model=set(v for v in solver.get_model() if v>0)
    row=[int(v in model) for v in variables[0]]
    seed="".join(map(str,row))
    for t in range(steps+1):
        ref=background[(phase+t)%len(background)]
        if t % stride == 0:
            _,d,b=cycle[(t//stride)%len(cycle)]
            assert all(row[p-1]==ref[p%len(ref)] for p in range(1,d))
            assert row[d-1]!=ref[d%len(ref)]
            assert row[d]^ref[(d+1)%len(ref)]==b
        padded=[ref[0]]+row
        row=[padded[i]^(padded[i+1]|padded[i+2]) for i in range(len(row)-1)]
    print(f"{steps} updates SAT, {len(seed)}-cell witness {seed}")
    if witness:
        witness.write_text(seed+"\n",encoding="ascii")


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("cycle",type=Path)
    p.add_argument("steps",type=int)
    p.add_argument("--cnf",type=Path)
    p.add_argument("--witness",type=Path)
    a=p.parse_args()
    if a.steps<0:
        p.error("steps must be nonnegative")
    run(json.loads(a.cycle.read_text()),a.steps,a.cnf,a.witness)
