"""Check visibility limits and confirmation latency on physical inside and outside rows."""
import argparse
from pathlib import Path
import json
import numpy as np
from pysat.solvers import Cadical195
from claudeCloud_wheel_runs import Cone
from complete_observer import FACTORS
from exterior_gap_core import successors
from wheel_bridge import table


def black_predecessor(c):
    n=16+c.T
    initial=list(range(c.nv+1,c.nv+n+2))
    c.nv+=n+1
    for j in range(n):
        new=c.var[0,j+1]
        b,e=initial[j:j+2]
        if j:
            a=initial[j-1]
            c.clauses.extend([[-b,-new,-a],[-b,new,a],[-e,-new,-a],[-e,new,a],[b,e,-new,a],[b,e,new,-a]])
        else:
            c.clauses.extend([[-b,-new],[-e,-new],[b,e,new]])
    return initial


def physical(bits, trap, mature=10, extra=None):
    c=Cone(len(bits)+mature)
    initial=black_predecessor(c)
    c.require_codes(0,trap)
    for i,b in enumerate(bits):
        if b in "01":
            c.clauses.append([c.gate(i+mature) if b=="1" else -c.gate(i+mature)])
    if extra:
        for i,w in extra:
            for j,b in enumerate(w):
                c.clauses.append([c.gate(i+j) if b=="1" else -c.gate(i+j)])
    with Cadical195(bootstrap_with=c.clauses) as solver:
        if not solver.solve():
            return None
        model=set(solver.get_model())
    value=sum(1<<j for j,v in enumerate(initial) if v in model)
    start=value
    bits_real=""
    for t in range(2*c.S):
        if t%2:
            bits_real+=str(value&1)
            assert value&65535 in trap
        value=((value<<1)|(1-t%2))^(value|(value>>1))
    assert all(b=="?" or b==r for b,r in zip(bits,bits_real[mature:],strict=True))
    if extra:
        assert all(bits_real[i:i+len(w)]==w for i,w in extra)
    return {"finite_black_start":hex(start),"sampled_from_entry":bits_real,"tracked_word":bits_real[mature:]}


def delay_bounds(trap):
    # All physically possible prefixes since entry project into these sampled strip edges.
    nodes=np.array(sorted(trap))
    transitions=list(successors(nodes,16))
    where={w:i for i,w in enumerate(nodes)}
    targets=np.array([[where[j] for j in row] for row in transitions])
    possible=np.ones(len(nodes),dtype=bool)
    records=[]
    for start in range(11):
        allowed=[]
        for word in FACTORS:
            here=possible.copy()
            for j,b in enumerate(word):
                here &= (nodes&1)==int(b)
                if j+1<len(word):
                    nxt=np.zeros(len(nodes),dtype=bool)
                    nxt[targets[:,here]]=True
                    here=nxt
            if np.any(here):
                allowed.append(word)
        records.append(allowed)
        nxt=np.zeros(len(nodes),dtype=bool)
        nxt[targets[:,possible]]=True
        possible=nxt
    return records


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path)
    p.add_argument("output",type=Path)
    args=p.parse_args()
    trap=set(table(args.kit,"trapCodes","Rule30Certificates/GateTrap"))
    outer=json.loads((Path(__file__).parent/"data/complete-observer.json").read_bytes())["sharp_black_start"]
    same=physical(outer["white_gate"],trap)
    print("Same 47",same,flush=True)
    late=delay_bounds(trap)
    print("Forbidden words from entry",late,flush=True)
    age=max((i for i,a in enumerate(late) if a),default=-1)
    witness=None
    if age>=0:
        for w in late[age]:
            witness=physical("?"*(age+len(w)),trap,mature=0,extra=[(age,w)])
            if witness is not None:
                break
    print("Latest",age,witness,flush=True)
    result={"mature_inside_same_47":same,"allowed_forbidden_words_by_start":late,"latest_start_witness":witness}
    args.output.write_bytes((json.dumps(result,indent=2)+"\n").encode())
