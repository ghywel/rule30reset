"""Find exact phase-by-phase wheel-to-trap thresholds in the physical Rule 30 cone."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import gzip
import hashlib
import itertools
import json
from pathlib import Path
import shutil
import subprocess

from wheel_bridge import U, table


def instance(samples, phase, full, trap):
    tick = 2 * (samples - 1)
    width = 16 + tick
    offsets = [1 + t*width - t*(t-1)//2 for t in range(tick+1)]
    clauses = []
    for t in range(tick):
        for j in range(width-t-1):
            here = offsets[t] + j
            inputs = [here-1, here, here+1] if j else [here, here+1]
            out = offsets[t+1] + j
            for bits in itertools.product((0, 1), repeat=len(inputs)):
                left, mid, right = bits if j else (t % 2, *bits)
                value = left ^ (mid | right)
                clauses.append([(-x if b else x) for x, b in zip(inputs, bits)] + [out if value else -out])
    for t in range(0, tick+1, 1 if full else 2):
        clauses.append([offsets[t] if U[(2*phase+t) % 56] == "1" else -offsets[t]])
    for code in trap:
        clauses.append([(-1 if (code >> j) & 1 else 1)*(offsets[-1]+j) for j in range(16)])
    lines = [f"p cnf {offsets[-1]+15} {len(clauses)}"]
    lines.extend(" ".join(map(str, c)) + " 0" for c in clauses)
    return ("\n".join(lines)+"\n").encode(), width


def replay(row, samples, phase, full, trap):
    cells = [int(b) for b in row]
    for t in range(2*samples-1):
        if full or t % 2 == 0:
            assert str(cells[0]) == U[(2*phase+t) % 56]
        if t == 2*samples-2:
            state = sum(b << i for i,b in enumerate(cells[:16]))
            assert len(cells) >= 16 and state not in trap
            return state
        left = [t % 2] + cells
        cells = [left[i] ^ (cells[i] | cells[i+1]) for i in range(len(cells)-1)]


def search(args, trap, kind, phase):
    full = kind == "full"
    label = f"{kind}-{phase:02d}"
    dest = args.output / label
    dest.mkdir(parents=True, exist_ok=True)
    cnf = dest / "cone.cnf"
    lrat = dest / "first-impossible.lrat"
    def solve(n, certify=False):
        content, width = instance(n, phase, full, trap)
        cnf.write_bytes(content)
        command = [args.cadical, "--quiet"]
        if certify:
            command.extend(["--lrat", "--no-binary"])
        command.append(str(cnf))
        if certify:
            command.append(str(lrat))
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if result.returncode == 20:
            return None
        if result.returncode != 10:
            raise RuntimeError(result.stdout.decode(errors="replace"))
        pos = {int(n) for line in result.stdout.splitlines() if line.startswith(b"v ") for n in line[2:].split() if int(n)>0}
        row = "".join("1" if i in pos else "0" for i in range(1,width+1))
        replay(row, n, phase, full, trap)
        return row

    lo, hi = 1, 67
    while hi-lo>1:
        mid = (lo+hi)//2
        if solve(mid) is None:
            hi = mid
        else:
            lo = mid
    row = solve(lo)
    if row is None or solve(hi, certify=True) is not None:
        raise ValueError(f"Boundary check failed at {label}, {lo} / {hi}")
    state = replay(row, lo, phase, full, trap)
    checked = subprocess.run([args.checker,str(cnf),str(lrat)], capture_output=True)
    if checked.returncode or b"c VERIFIED" not in checked.stdout.splitlines():
        raise RuntimeError((checked.stdout+checked.stderr).decode(errors="replace"))
    proof = lrat.read_bytes()
    (dest / "first-impossible.lrat.gz").write_bytes(gzip.compress(proof, mtime=0))
    lrat.unlink()
    rec = dict(kind=kind,phase=phase,first_forces=hi,last_outside=lo,row=row,window=state,
               cnf_sha256=hashlib.sha256(cnf.read_bytes()).hexdigest(),lrat_sha256=hashlib.sha256(proof).hexdigest())
    (dest/"result.json").write_text(json.dumps(rec,indent=2)+"\n")
    print(label,hi,flush=True)
    return rec


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit",type=Path)
    parser.add_argument("output",type=Path)
    parser.add_argument("--cadical",default=shutil.which("cadical"))
    parser.add_argument("--checker",default=shutil.which("lrat-check"))
    parser.add_argument("--workers",type=int,default=2)
    args = parser.parse_args()
    trap = table(args.kit,"trapCodes","Rule30Certificates/GateTrap")
    cases = list(itertools.product(("visible","full"),range(28)))
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        results = list(pool.map(lambda k: search(args,trap,*k), cases))
    (args.output/"physical.json").write_text(json.dumps(results,indent=2)+"\n")
