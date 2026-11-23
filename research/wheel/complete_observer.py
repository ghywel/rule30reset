"""Sharp gate-only recognition of the trap by a finite forbidden-factor language."""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

import numpy as np
from pysat.solvers import Cadical195

from audit_gap_observers import read_row, solve
from claudeCloud_wheel_runs import Cone
from exterior_gap_core import successors
from wheel_bridge import table

FACTORS = ("00000","11","101","10001","1001001")


def transitions():
    prefixes = sorted({w[:i] for w in FACTORS for i in range(len(w))}, key=lambda s:(len(s),s))
    edges = []
    for p in prefixes:
        for bit in (0,1):
            w = p + str(bit)
            if not any(w.endswith(f) for f in FACTORS):
                suffix = max((q for q in prefixes if w.endswith(q)),key=len)
                edges.append((prefixes.index(p),bit,prefixes.index(suffix)))
    return prefixes, edges


def strip16(trap):
    outside = np.ones(65536,dtype=bool)
    outside[trap] = False
    states = np.arange(65536,dtype=np.int64)
    prefixes, edges = transitions()
    active = np.zeros((len(prefixes),65536),dtype=bool)
    active[0] = outside
    moves = list(successors(states,16))
    sample = 0
    seen = {}
    while True:
        key = hashlib.sha256(active.tobytes()).digest()
        if key in seen:
            return {"cycle_from":seen[key],"cycle_return":sample}
        seen[key] = sample
        nxt = np.zeros_like(active)
        survives = False
        for start,bit,end in edges:
            indices = np.flatnonzero(active[start] & ((states & 1)==bit))
            survives |= bool(len(indices))
            for dest in moves:
                nxt[end,dest[indices]] = True
        sample += 1
        if not survives:
            return {"first_impossible":sample}
        nxt &= outside
        active = nxt


def cone(samples,trap):
    c = Cone(samples)
    for word in FACTORS:
        for start in range(samples-len(word)+1):
            c.clauses.append([(-c.gate(start+i) if b=="1" else c.gate(start+i)) for i,b in enumerate(word)])
    # Closure permits these redundant intermediate clauses as a speedup.
    for t in range(samples):
        c.forbid_codes(t,trap)
    return c


def model_result(c, model, trap):
    chosen = {x for x in model if x>0}
    row = "".join("1" if c.var[0,j] in chosen else "0" for j in range(1,17+c.T))
    bits = "".join("1" if c.gate(i) in chosen else "0" for i in range(c.S))
    final = read_row(row,bits)
    assert all(f not in bits for f in FACTORS) and final not in trap
    return {"samples":c.S,"row":row,"gate":bits,"final_window":final}


def factorized(samples, trap, previous_black):
    """Exact physical cone with OR auxiliaries. Only the final trap code is constrained."""
    extra = int(previous_black)
    steps = 2*(samples-1)+extra
    from pysat.formula import CNF
    f=CNF()
    rows=[]
    counter=0
    for t in range(steps+1):
        length=16+steps-t
        rows.append(list(range(counter+1,counter+length+1)))
        counter+=length
    for t in range(steps):
        for j,z in enumerate(rows[t+1]):
            b,c = rows[t][j:j+2]
            counter+=1
            g=counter
            f.extend([[-b,g],[-c,g],[b,c,-g]])
            if j:
                a=rows[t][j-1]
                f.extend([[-a,-g,-z],[a,g,-z],[a,-g,z],[-a,g,z]])
            else:
                rhs = -g if (t+extra)%2 else g
                f.extend([[-rhs,z],[rhs,-z]])
    gate=[rows[2*s+extra][0] for s in range(samples)]
    for i in range(samples):
        for pat in FACTORS:
            if i+len(pat)<=samples:
                f.append([-g if b=="1" else g for b,g in zip(pat,gate[i:])])
    for v in trap:
        f.append([-x if (v>>i)&1 else x for i,x in enumerate(rows[-1])])
    return f, rows, gate


def dimacs(n,clauses):
    return (f"p cnf {n} {len(clauses)}\n"+"".join(" ".join(map(str,c))+" 0\n" for c in clauses)).encode()


def certify(folder, trap):
    folder.mkdir(exist_ok=True,parents=True)
    programs=argparse.Namespace(**{k:shutil.which(v) for k,v in [("cadical","cadical"),("lrat","lrat-check"),("cake","cake_lpr")]})
    n=48
    c=cone(n,trap)
    f,_,_=factorized(n,trap,False)
    result={"samples":n,"forbidden":FACTORS,"proofs":{}}
    for name,body in [("exterior",dimacs(c.nv,c.clauses)),("terminal",dimacs(f.nv,f.clauses))]:
        model,receipt=solve(programs,folder,name,body)
        assert model is None
        result["proofs"][name]=receipt
    f,rows,gate=factorized(n-1,trap,True)
    with Cadical195(bootstrap_with=f.clauses) as sat:
        assert sat.solve()
        model={x for x in sat.get_model() if x>0}
    row=sum(1<<i for i,x in enumerate(rows[0]) if x in model)
    width=len(rows[0])
    white=(((row<<1)|1)^(row|(row>>1))) & ((1<<(width-1))-1)
    bits="".join("1" if x in model else "0" for x in gate)
    final=read_row(format(white,f"0{width-1}b")[::-1],bits)
    assert final not in trap and all(w not in bits for w in FACTORS)
    result["sharp_black_start"]={"initial_row_low_site_one":hex(row),"white_gate":bits,"final_window":final}
    return result


if __name__ == "__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit",type=Path)
    parser.add_argument("samples",nargs="*",type=int)
    parser.add_argument("--strip",action="store_true")
    parser.add_argument("--certify",type=Path, help="Write two independent soundness proofs and a sharp reachable witness")
    args=parser.parse_args()
    trap=table(args.kit,"trapCodes","Rule30Certificates/GateTrap")
    if args.certify:
        result=certify(args.certify,trap)
        (args.certify/"summary.json").write_bytes((json.dumps(result,indent=2)+"\n").encode())
        print(json.dumps(result),flush=True)
    if args.strip:
        print(json.dumps(strip16(trap)),flush=True)
    for samples in args.samples:
        c=cone(samples,trap)
        with Cadical195(bootstrap_with=c.clauses) as solver:
            found=solver.solve()
            print(json.dumps(model_result(c,solver.get_model(),trap) if found else {"unsat":samples}),flush=True)
