"""Check the three sufficient wheel markers with a second physical cone encoding."""

import argparse
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

from physical_thresholds import replay
from wheel_bridge import U, table


MARKERS = ((12, 33), (21, 29), (26, 29))
STARTS = (27, 13, 22)


def factored_cone(samples, phase, trap):
    # Number the terminal row first. Give the OR in every Rule 30 update its own variable.
    T = 2*(samples-1)
    rows, size, clauses = {}, 0, []
    for t in range(T,-1,-1):
        rows[t] = list(range(size+1, size+17+T-t))
        size += len(rows[t])
    for t in range(T-1,-1,-1):
        initial, after = rows[t], rows[t+1]
        for j, z in enumerate(after):
            b,c = initial[j:j+2]
            size += 1
            g = size
            clauses.extend(([-b,g],[-c,g],[b,c,-g]))
            if j:
                a = initial[j-1]
                clauses.extend(([-a,-g,-z],[a,g,-z],[a,-g,z],[-a,g,z]))
            else:
                wire = -g if t%2 else g
                clauses.extend(([-wire,z],[wire,-z]))
    for i in range(samples):
        v = rows[2*i][0]
        clauses.append([v if U[2*((phase+i)%28)] == "1" else -v])
    for code in trap:
        clauses.append([-x if (code>>i)&1 else x for i,x in enumerate(rows[T])])
    lines = [f"p cnf {size} {len(clauses)}", *(" ".join(map(str,c))+" 0" for c in clauses)]
    return ("\n".join(lines)+"\n").encode()


def main(args):
    trap = table(args.kit,"trapCodes","Rule30Certificates/GateTrap")
    results = json.loads((args.sweep/"physical.json").read_bytes())
    by_case = {(r["kind"],r["phase"]): r for r in results}
    evidence = {"kit": "8e1cc847a758a892ec4b51182cdf325b1c483f9a", "white_samples": [],
                "markers": [], "physical_witnesses": []}
    for phase in STARTS:
        r = by_case["full",phase]
        evidence["physical_witnesses"].append(dict(phase=phase,samples=r["last_outside"],
            cells_positive_first=r["row"],final_window=r["window"]))
    for p in range(28):
        # The earliest ending of any of the three future markers is an upper bound.
        upper = min((q-p)%28+n for q,n in MARKERS)
        # A suffix of a true full-trace witness gives a lower bound. Its initial
        # row is the corresponding later finite row, still with a white boundary.
        lower = max(r["samples"]-(p-r["phase"])%28 for r in evidence["physical_witnesses"])
        assert upper == lower+1 == by_case["visible",p]["first_forces"] == by_case["full",p]["first_forces"]
        evidence["white_samples"].append(upper)
    for r in evidence["physical_witnesses"]:
        assert replay(r["cells_positive_first"],r["samples"],r["phase"],True,trap) == r["final_window"]
    args.output.mkdir(parents=True,exist_ok=True)
    for p,n in MARKERS:
        body = factored_cone(n,p,trap)
        cnf = args.output/f"marker-{p}.cnf"
        proof = args.output/f"marker-{p}.lrat"
        cnf.write_bytes(body)
        result = subprocess.run([args.cadical,"--quiet","--lrat","--no-binary",str(cnf),str(proof)],capture_output=True)
        assert result.returncode == 20, result.stdout
        for checker,signature in ((args.lrat,b"VERIFIED"),(args.cake,b"s VERIFIED UNSAT")):
            v = subprocess.run([checker,str(cnf),str(proof)],capture_output=True)
            assert v.returncode == 0 and signature in v.stdout, (checker,v.stdout,v.stderr)
        data = proof.read_bytes()
        proof.with_suffix(".lrat.gz").write_bytes(gzip.compress(data,mtime=0))
        evidence["markers"].append(dict(phase=p,samples=n,
            word="".join(U[2*((p+j)%28)] for j in range(n)),cnf_sha256=hashlib.sha256(body).hexdigest(),
            lrat_sha256=hashlib.sha256(data).hexdigest(),checkers=["lrat-check","cake_lpr"]))
        print("Verified marker",p,n,flush=True)
    (args.output/"thresholds.json").write_bytes((json.dumps(evidence,indent=2)+"\n").encode())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit",type=Path)
    parser.add_argument("sweep",type=Path)
    parser.add_argument("output",type=Path)
    parser.add_argument("--cadical",default=shutil.which("cadical"))
    parser.add_argument("--lrat",default=shutil.which("lrat-check"))
    parser.add_argument("--cake",default=shutil.which("cake_lpr"))
    main(parser.parse_args())
