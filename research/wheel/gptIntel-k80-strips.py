"""Check the periodic-strip bounds by SAT on a temporal cylinder with a free last column."""
import argparse
import hashlib
from itertools import product
import json
from pathlib import Path
import shutil
import subprocess


REPORTED = {2:3, 4:5, 6:3, 8:11, 10:6, 12:8, 14:6, 16:22, 18:9, 20:8, 22:14, 24:11}


def equation(l, b, r, n):
    for left, centre, right in product((0, 1), repeat=3):
        out = left ^ (centre | right)
        yield [-l if left else l, -b if centre else b, -r if right else r, n if out else -n]


def gate_columns(n):
    """Temporal gate observations up to phase, solely from the four primitive gap words."""
    found=set()
    for gaps in ((2,), (3,), (5,), (2,5)):
        base=''.join('1'+'0'*(g-1) for g in gaps)
        m=n//2
        if m % len(base):
            continue
        full=base*(m//len(base))
        found.update(full[i:]+full[:i] for i in range(len(base)))
    return sorted(found)


def cylinder(n, width, out):
    def var(x,t):
        return x*n+t%n+1
    clauses=[[var(0,t) if t%2 else -var(0,t)] for t in range(n)]
    for x in range(1,width):
        for t in range(n):
            clauses.extend(equation(var(x-1,t),var(x,t),var(x+1,t),var(x,t+1)))
    # The right edge of the last periodic column is unrestricted at each tick.
    # Its one-period choices suffice: its cell, new cell and left neighbour are periodic.
    for t in range(n):
        clauses.extend(equation(var(width-1,t),var(width,t),var(width+1,t),var(width,t+1)))
    for word in gate_columns(n):
        clauses.append([-var(1,2*i) if bit=='1' else var(1,2*i) for i,bit in enumerate(word)])
    cnf=out/f"strip-{n}-{width}.cnf"
    proof=cnf.with_suffix(".lrat")
    cnf.write_bytes((f"p cnf {(width+2)*n} {len(clauses)}\n"+
                     ''.join(' '.join(map(str,cl))+' 0\n' for cl in clauses)).encode())
    run=subprocess.run([shutil.which("cadical"),"--quiet","--lrat","--no-binary",str(cnf),str(proof)],
                       capture_output=True)
    if run.returncode==10:
        black={v for line in run.stdout.splitlines() if line.startswith(b"v ") for v in map(int,line[2:].split()) if v>0}
        cols=[''.join('1' if var(x,t) in black else '0' for t in range(n)) for x in range(width+2)]
        assert cols[0]=='01'*(n//2)
        assert cols[1][::2] not in gate_columns(n)
        for x in range(1,width+1):
            for t in range(n):
                assert int(cols[x][(t+1)%n]) == (int(cols[x-1][t])^(int(cols[x][t])|int(cols[x+1][t])))
        return dict(width=width,status="SAT",columns=cols)
    if run.returncode!=20:
        raise RuntimeError(run.stderr)
    for checker,line in (("lrat-check",b"c VERIFIED"),("cake_lpr",b"s VERIFIED UNSAT")):
        r=subprocess.run([checker,str(cnf),str(proof)],capture_output=True)
        if r.returncode or line not in r.stdout.splitlines():
            raise RuntimeError((checker,r.stdout,r.stderr))
    return dict(width=width,status="VERIFIED UNSAT",cnf=hashlib.sha256(cnf.read_bytes()).hexdigest(),
                lrat=hashlib.sha256(proof.read_bytes()).hexdigest(),proof_bytes=proof.stat().st_size)


def main(out):
    out.mkdir(parents=True,exist_ok=True)
    result=[]
    for n,width in REPORTED.items():
        # Check the advertised version, then measure the least gate-only width.
        # The original search excluded entire ring columns, a stronger predicate.
        first=cylinder(n,width,out)
        assert first["status"]=="VERIFIED UNSAT"
        trials=[first]
        for w in range(width-1,0,-1):
            trials.append(cylinder(n,w,out))
            if trials[-1]["status"]=="SAT":
                break
        record=dict(period=n,advertised=width,gate_only_width=min(d["width"] for d in trials if d["status"]=="VERIFIED UNSAT"),
                    trials=trials)
        result.append(record)
        print(n,width,record["gate_only_width"],flush=True)
    (out/"periodic-strips.json").write_text(json.dumps(result,indent=2)+"\n")


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__);p.add_argument("out",type=Path)
    main(p.parse_args().out.resolve())
