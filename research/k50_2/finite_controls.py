"""Complete finite Rule 30 cones for three kick-gap factors under an alternating centre.

Run with a new or empty evidence directory. Requires cadical, cake_lpr and lrat-check.
Bit j of a reported seed represents site j-H; all sites outside [-H,H] are white.
"""
import argparse
from hashlib import sha256
from itertools import accumulate, product
import json
from pathlib import Path
import subprocess


def cone(gaps):
    kicks = {0, *accumulate(gaps)}
    horizon = 2 * sum(gaps) + 4  # include the four future observations used to recognize words
    ids = {(t, x): 0 for t in range(horizon + 1)
           for x in range(t - horizon, horizon - t + 1)}
    for i, p in enumerate(ids, 1):
        ids[p] = i
    clauses = []
    for (t, x), out in ids.items():
        if not t:
            continue
        parents = [ids[t-1, x+j] for j in (-1, 0, 1)]
        for vals in product((0, 1), repeat=3):
            a, b, c = vals
            result = a ^ (b | c)
            clauses.append([(-v if bit else v) for v, bit in zip(parents, vals)] +
                           [out if result else -out])
    for t in range(horizon + 1):
        clauses.append([ids[t, 0] * (1 if t % 2 else -1)])
    for s in range(sum(gaps) + 1):
        clauses.append([ids[2*s, 1] * (1 if s in kicks else -1)])
    lines = [f"p cnf {len(ids)} {len(clauses)}"] + [" ".join(map(str, c))+" 0" for c in clauses]
    return ids, horizon, ("\n".join(lines)+"\n").encode()


def scalar_replay(seed, gaps, horizon):
    """Independent whole-line update by Wolfram rule-table lookup."""
    black = set(seed)
    kicks = []
    events = []
    for t in range(horizon + 1):
        assert (0 in black) == bool(t % 2)
        if t <= 2 * sum(gaps) and t % 2 == 0:
            if 1 in black:
                kicks.append(t//2)
            bits = ''.join('1' if x in black else '0' for x in range(-4, 3))
            assert (bits == '0101001') == (1 not in black and 2 in black)
            if bits == '0101001':
                events.append(t//2)
        if t < horizon:
            black = {x for x in range(min(black, default=0)-1, max(black, default=0)+2)
                     if (30 >> (4*((x-1) in black) + 2*(x in black) + ((x+1) in black))) & 1}
    assert kicks == [0, *accumulate(gaps)]
    return {"kicks": kicks, "events": events}


def run(gaps, evidence):
    ids, horizon, data = cone(gaps)
    tag = ''.join(map(str, gaps))
    cnf_file, proof = evidence / (tag+".cnf"), evidence / (tag+".lrat")
    cnf_file.write_bytes(data)
    record = {"gaps": gaps, "horizon": horizon, "variables": len(ids), "cnf_sha256": sha256(data).hexdigest()}
    proc = subprocess.run(["cadical", "-q", "--lrat", "--no-binary", "-t", "18", str(cnf_file), str(proof)],
                          capture_output=True, text=True, timeout=21)
    if proc.returncode == 10:
        model = {int(bit) for line in proc.stdout.splitlines() if line.startswith("v ")
                 for bit in line[2:].split()}
        seed = [x for x in range(-horizon, horizon + 1) if ids[0,x] in model]
        record.update(result="SAT", seed=str(sum(1 << (x+horizon) for x in seed)),
                      black_sites=seed, **scalar_replay(seed, gaps, horizon))
    elif proc.returncode == 20:
        for exe in ("cake_lpr", "lrat-check"):
            check = subprocess.run([exe, str(cnf_file), str(proof)], capture_output=True, text=True, timeout=10)
            audit = check.stdout + check.stderr
            if check.returncode or "VERIFIED" not in audit.upper():
                raise RuntimeError(f"{exe} failed to verify LRAT: {audit[-1500:]}")
        record.update(result="UNSAT", proof_sha256=sha256(proof.read_bytes()).hexdigest(),
                      verified_by=["cake_lpr", "lrat-check"])
    elif proc.returncode == 0 and "UNKNOWN" in proc.stdout:
        record.update(result="UNKNOWN")
    else:
        raise RuntimeError(f"CaDiCaL failed ({proc.returncode}): {proc.stderr[-500:]}")
    print(json.dumps(record, sort_keys=True), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("evidence", type=Path)
    args = parser.parse_args()
    args.evidence.mkdir(parents=True, exist_ok=True)
    if any(args.evidence.iterdir()):
        parser.error("Use an empty directory so existing evidence is preserved")
    for test in ((5,2,5), (5,2,2,5), (5,2,2,4,5)):
        run(test, args.evidence)
