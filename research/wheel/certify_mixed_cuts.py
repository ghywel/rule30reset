"""Check the K77 finite strip cut formulas and retain their LRAT certificates."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

from claudeCloud_wheel_exterior_sat import instance
from wheel_bridge import table


def sha256(path):
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def verified_solve(out, nv, clauses, args, expected_hash=None):
    out.mkdir(parents=True, exist_ok=True)
    cnf, proof = out / "strip.cnf", out / "strip.lrat"
    with cnf.open("w", encoding="ascii", newline="\n") as f:
        f.write(f"p cnf {nv} {len(clauses)}\n")
        f.writelines(" ".join(map(str, c)) + " 0\n" for c in clauses)
    cnf_digest = sha256(cnf)
    if expected_hash is not None and not cnf_digest.startswith(expected_hash):
        raise ValueError(f"Published CNF digest mismatch at {out}")
    result = subprocess.run(
        [args.cadical, "--quiet", "--modelalllits", "--lrat", "--no-binary", str(cnf), str(proof)], capture_output=True
    )
    receipt = {"cnf": cnf_digest, "variables": nv, "clauses": len(clauses)}
    if result.returncode == 10:
        model = {
            int(v)
            for line in result.stdout.splitlines()
            if line.startswith(b"v ")
            for v in line[2:].split()
            if int(v) > 0
        }
        return receipt, model
    if result.returncode != 20:
        raise RuntimeError((out, result.returncode, result.stderr[-500:]))
    receipt.update(check_proof(args, cnf, proof))
    return receipt, None


def check_proof(args, cnf, proof):
    for checker, signature in ((args.lrat, b"c VERIFIED"), (args.cake, b"s VERIFIED UNSAT")):
        flags = []
        heap = 512
        while True:
            check = subprocess.run([checker, *flags, str(cnf), str(proof)], capture_output=True)
            if check.returncode == 0 and signature in check.stdout.splitlines():
                break
            if checker == args.cake and b"CakeML heap space exhausted" in check.stderr:
                flags = [f"--CML_HEAP_SIZE={heap}"]
                heap *= 2
                continue
            raise RuntimeError((checker, cnf, check.stdout[-500:], check.stderr[-500:]))
    with proof.open("rb") as src, proof.with_suffix(".lrat.gz").open("wb") as dst:
        with gzip.GzipFile(filename="", mode="wb", fileobj=dst, mtime=0, compresslevel=1) as packed:
            shutil.copyfileobj(src, packed)
    return {
        "lrat": sha256(proof),
        "proof_bytes": proof.stat().st_size,
        "checkers": ["lrat-check", "cake_lpr"],
    }


def replay(gate, initial, east, width, trap):
    row, mask = initial, (1 << width) - 1
    for t in range(len(east) + 1):
        if t % 2 == 0:
            assert (row & 1) == int(gate[t // 2]) and (row & 65535) not in trap
        if t < len(east):
            row = (((row << 1) | (t % 2)) ^ (row | (row >> 1) | (east[t] << (width - 1)))) & mask


def published(args):
    source = Path(__file__).with_name("data") / "claudeCloud-wheel-exterior-sat.txt"
    jobs = []
    for line in source.read_text().splitlines():
        match = re.fullmatch(
            r"gaps (\d+), (\d+) columns, (\d+) repetitions \(\d+ samples\): (SAT, replays: True|UNSAT); (\d+) variables, (\d+) clauses, cnf ([0-9a-f]+), .*",
            line,
        )
        if not match:
            raise ValueError(line)
        gaps, width, count, status, nv, nc, digest = match.groups()
        if status == "UNSAT" or (gaps, int(width), int(count)) in (("333355", 44, 8), ("33355", 55, 6)):
            jobs.append((gaps, int(width), int(count), status, int(nv), int(nc), digest))
    assert len(jobs) == 12 and sum(j[3] == "UNSAT" for j in jobs) == 10
    trap = sorted(table(args.kit, "trapCodes", "Rule30Certificates/GateTrap"))
    assert len(set(trap)) == len(trap) == 829

    def run(job):
        gaps, width, count, status, nv, nc, digest = job
        out = args.output / f"public-{gaps}-{width}-{count}"
        gate, _, ticks, var, n, clauses = instance(trap, gaps, width, count)
        assert n == nv and len(clauses) == nc
        cnf = out / "strip.cnf"
        proof = out / "strip.lrat"
        done = out / "receipt.json"
        if args.resume and done.exists():
            kept = json.loads(done.read_bytes())
            assert kept["cnf"] == sha256(cnf) and kept["cnf"].startswith(digest)
            assert kept["status"] == status.split(",")[0] and kept["variables"] == n
            if status == "UNSAT":
                assert kept["lrat"] == sha256(proof) and kept["checkers"] == ["lrat-check", "cake_lpr"]
            else:
                replay(gate, int(kept["initial"], 16), list(map(int, kept["east"])), width, set(trap))
            return kept
        if args.resume and status == "UNSAT" and cnf.exists() and proof.exists() and proof.stat().st_size:
            assert sha256(cnf).startswith(digest)
            receipt = {"cnf": sha256(cnf), "variables": n, "clauses": len(clauses)}
            receipt.update(check_proof(args, cnf, proof))
            model = None
        else:
            receipt, model = verified_solve(out, n, clauses, args, digest)
        assert (model is None) == (status == "UNSAT")
        if model is not None:
            initial = sum(int(var[0, j] in model) << (j - 1) for j in range(1, width + 1))
            east = [int(var[t, width + 1] in model) for t in range(ticks)]
            replay(gate, initial, east, width, set(trap))
            receipt.update(initial=hex(initial), east="".join(map(str, east)))
        receipt.update(gaps=gaps, width=width, repeats=count, ticks=ticks, status=status.split(",")[0])
        (out / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
        print(out.name, receipt["status"], flush=True)
        return receipt

    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        records = list(pool.map(run, jobs))
    (args.output / "published.json").write_bytes((json.dumps(records, indent=2) + "\n").encode())


def options():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("--workers", type=int, default=2)
    p.add_argument(
        "--resume", action="store_true", help="Reuse locally completed receipts and recheck existing proofs."
    )
    for name, exe in (("cadical", "cadical"), ("lrat", "lrat-check"), ("cake", "cake_lpr")):
        p.add_argument("--" + name, default=shutil.which(exe))
    return p.parse_args()


if __name__ == "__main__":
    published(options())
