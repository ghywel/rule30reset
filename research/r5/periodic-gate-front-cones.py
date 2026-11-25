"""Refine the local ether-front graph using exact multi-tick cones."""
import argparse
import json
from importlib import import_module
from itertools import product
from pathlib import Path

from pysat.solvers import Cadical195

from_background = import_module("periodic-gate-background")


def refine(background, horizon):
    phases, width = len(background), len(background[0])
    abstract = {}
    for t,p,b in product(range(phases),range(width),(0,1)):
        edges, repeat = from_background.moves(background,t,p,b)
        if repeat:
            raise ValueError("unbounded first-defect jump needs a separate model")
        abstract[t,p,b] = edges

    start = horizon+2
    result = {}
    total = 0
    for phase,p,ubit in abstract:
        ends = {(0,ubit)}
        for k in range(horizon):
            ends = {(shift+delta,bit)
                    for shift,old in ends
                    for delta,bit in abstract[(phase+k)%phases,(p+shift)%width,old]}
        if not ends:
            result[phase,p,ubit] = set()
            continue
        total += len(ends)
        edge = start+max(delta for delta,_ in ends)+1
        x = []
        index = 1
        for k in range(horizon+1):
            span = edge+horizon-k
            x.append(list(range(index,index+span)))
            index+=span

        def cell(t,q):
            return background[(phase+t)%phases][(p+q-start)%width]

        def require(t,d,u):
            return [v if cell(t,q) ^ (1 if q==d else u if q==d+1 else 0) else -v
                    for q,v in enumerate(x[t][:d+1],1)]

        with Cadical195(bootstrap_with=[[a] for a in require(0,start,ubit)]) as solver:
            for t in range(horizon):
                old,new = x[t:t+2]
                for i,nxt in enumerate(new):
                    inputs=old[max(0,i-1):i+2]
                    for assignment in product((0,1),repeat=len(inputs)):
                        l,c,r = assignment if i else (cell(t,0),*assignment)
                        output=l^(c|r)
                        clause=[-v if bit else v for v,bit in zip(inputs,assignment)]
                        solver.add_clause(clause+[nxt if output else -nxt])
            result[phase,p,ubit] = {
                (shift,u) for shift,u in ends if solver.solve(assumptions=require(horizon,start+shift,u))
            }
    print("abstract endpoints",total,"physical endpoints",sum(map(len,result.values())),flush=True)
    return result


if __name__ == "__main__":
    a=argparse.ArgumentParser(description=__doc__)
    a.add_argument("data",type=Path)
    a.add_argument("horizon",type=int)
    a.add_argument("--emit",type=Path)
    p=a.parse_args()
    if p.horizon < 1:
        a.error("positive horizon required")
    bg=json.loads(p.data.read_text())["background"]
    edges=refine(bg,p.horizon)
    cycle=from_background.slab_cycle(edges,len(bg[0]),len(bg),p.horizon)
    if cycle and p.emit:
        p.emit.write_text(json.dumps({"background":bg,"stride":p.horizon,"cycle":cycle})+"\n",encoding="ascii")
