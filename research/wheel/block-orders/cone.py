"""Solve a requested block order on a genuine physical light cone and replay it."""
import argparse
import sys
from pathlib import Path

from pysat.solvers import Cadical195
from check import gate, target

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from claudeCloud_wheel_runs import Cone


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("order")
    p.add_argument("output",type=Path)
    p.add_argument("--long-run",type=int,default=5)
    a=p.parse_args()
    if not a.order or set(a.order)-set("AB"):
        p.error("order must be a nonempty word on A,B")
    word=target(a.order,a.long_run)+"1001"
    cone=Cone(len(word))
    with Cadical195(bootstrap_with=cone.clauses) as solver:
        for j,c in enumerate(word):
            v=cone.gate(j)
            solver.add_clause([v if c=="1" else -v])
        print("physical samples",len(word),"variables",cone.nv,flush=True)
        if not solver.solve():
            print("UNSAT: requires a separate proof replay",flush=True)
        else:
            model=set(v for v in solver.get_model() if v>0)
            prefix="".join("1" if cone.var[0,j] in model else "0" for j in range(1,2*len(word)))
            assert gate(prefix,len(word))==word
            a.output.write_text(a.order+"\t"+prefix+"\n",encoding="ascii")
            print("SAT with independently checked physical row",flush=True)
