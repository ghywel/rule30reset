"""Replay K75's exact CNFs and distinguish attainable trap entries from impossible observations."""

import argparse
import gzip
import hashlib
import itertools
import json
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import shutil
import subprocess

from audit_thresholds import factored_trace
from claudeCloud_wheel_runs import Cone
from wheel_bridge import table


def digest(data):
    return hashlib.sha256(data).hexdigest()


def sample_bits(word):
    return "1" + "".join("0" * (int(gap) - 1) + "1" for gap in word)


def read_row(row, bits):
    cells = list(map(int, row))
    if len(cells) != 16 + 2 * (len(bits) - 1):
        raise ValueError("Initial cone width")
    for tick in range(2 * (len(bits) - 1)):
        if tick % 2 == 0 and cells[0] != int(bits[tick // 2]):
            raise ValueError("Wrong gate reading")
        left = [tick % 2] + cells
        cells = [left[i] ^ (cells[i] | cells[i + 1]) for i in range(len(cells) - 1)]
    if cells[0] != int(bits[-1]):
        raise ValueError("Wrong final gate reading")
    return sum(b << i for i, b in enumerate(cells))


def published_cone(bits, trap):
    cone = Cone(len(bits))
    for i, bit in enumerate(bits):
        v = cone.gate(i)
        cone.clauses.append([v if bit == "1" else -v])
    cone.forbid_codes(len(bits) - 1, trap)
    header = f"p cnf {cone.nv} {len(cone.clauses)}\n"
    return (header + "".join(" ".join(map(str, clause)) + " 0\n" for clause in cone.clauses)).encode()


def solve(args, folder, label, body):
    cnf, lrat = folder / (label + ".cnf"), folder / (label + ".lrat")
    cnf.write_bytes(body)
    res = subprocess.run([args.cadical, "--quiet", "--lrat", "--no-binary", str(cnf), str(lrat)],
                         capture_output=True)
    if res.returncode == 10:
        return {int(x) for line in res.stdout.splitlines() if line.startswith(b"v ")
                for x in line[2:].split() if int(x) > 0}, None
    if res.returncode != 20:
        raise RuntimeError((args.cadical, res.returncode, res.stderr))
    for checker, signature in ((args.lrat, b"c VERIFIED"), (args.cake, b"s VERIFIED UNSAT")):
        check = subprocess.run([checker, str(cnf), str(lrat)], capture_output=True)
        if check.returncode or signature not in check.stdout.splitlines():
            raise RuntimeError((checker, check.stdout[-800:], check.stderr[-800:]))
    proof = lrat.read_bytes()
    (folder / (label + ".lrat.gz")).write_bytes(gzip.compress(proof, mtime=0))
    return None, {"cnf": digest(body), "lrat": digest(proof)}


def audit(args, record, trap):
    word = record["word"]
    bits = sample_bits(word)
    body = published_cone(bits, trap)
    if digest(body) != record["cnf_sha256"]:
        raise ValueError("K75 CNF digest mismatch for " + word)
    result = {"word": word, "samples": len(bits), "cnf_sha256": digest(body)}
    if record["status"] == "SAT":
        window = read_row(record["row"], bits)
        assert window == record["final_window"] and window not in trap
        return dict(result, status="outside", window=window)
    assert record["status"] == "UNSAT"
    folder = args.output / word
    folder.mkdir(parents=True, exist_ok=True)
    model, proof = solve(args, folder, "outside", body)
    assert model is None
    result["outside_proof"] = proof
    # An empty trap list leaves the endpoint free. This second encoder numbers
    # time backwards and factors the OR in each update into its own variable.
    open_cone = factored_trace(bits, [])
    model, proof = solve(args, folder, "unrestricted", open_cone)
    if model is None:
        return dict(result, status="impossible", unrestricted_proof=proof)
    ticks = 2 * (len(bits) - 1)
    start = 1 + sum(16 + s for s in range(ticks))
    row = "".join("1" if i in model else "0" for i in range(start, start + 16 + ticks))
    window = read_row(row, bits)
    assert window in trap
    return dict(result, status="forces", witness=row, window=window, unrestricted_cnf=digest(open_cone))


def main(args):
    data = Path(__file__).parent / "data"
    records = [json.loads(line) for name in ("claudeCloud-wheel-forcing-sat.jsonl",
                                             "claudeCloud-wheel-forcing-sat-7.jsonl")
               for line in (data / name).read_text().splitlines()]
    expected = {"".join(w) for n in range(1, 8) for w in itertools.product("35", repeat=n)}
    assert len(records) == len(expected) and {r["word"] for r in records} == expected
    trap = sorted(table(args.kit, "trapCodes", "Rule30Certificates/GateTrap"))
    assert len(trap) == len(set(trap)) == 829
    args.output.mkdir(parents=True, exist_ok=True)
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        results = list(pool.map(lambda r: audit(args, r, trap), records))
    (args.output / "audit.json").write_bytes((json.dumps(results, indent=2) + "\n").encode())
    print({s: sum(r["status"] == s for r in results) for s in ("outside", "forces", "impossible")})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--workers", type=int, default=3)
    for name, program in (("cadical", "cadical"), ("lrat", "lrat-check"), ("cake", "cake_lpr")):
        parser.add_argument("--" + name, default=shutil.which(program))
    main(parser.parse_args())
