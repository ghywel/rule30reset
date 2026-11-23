"""Rebuild the two K80 CNFs and independently check the stronger unrestricted word."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

from audit_thresholds import factored_trace
from claudeCloud_wheel_runs import Cone
from wheel_bridge import table


def trace(gaps):
    return "1" + "".join("0" * (g - 1) + "1" for g in gaps)


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def main(kit, out, case):
    out.mkdir(parents=True, exist_ok=True)
    excursion = [3, 3, 5, 3, 5, 5, 5, 5]
    loops = [2, 5] * 6
    gaps = excursion + loops + excursion + loops + excursion
    if case == "cloud-plus-two":
        gaps.append(2)
    bits = trace(gaps)
    cnf = out / (case + ".cnf")
    proof = out / (case + ".lrat")
    if case == "unrestricted":
        # Independent reverse-row numbering and a separate OR/XOR per update.
        # Keep the cone's full physical edges and drop the terminal trap predicate.
        cnf.write_bytes(factored_trace(bits, []))
    else:
        c = Cone(len(bits))
        for i, bit in enumerate(bits):
            c.clauses.append([c.gate(i) if bit == "1" else -c.gate(i)])
        c.forbid_codes(len(bits) - 1, sorted(table(kit, "trapCodes", "Rule30Certificates/GateTrap")))
        with cnf.open("wb") as f:
            f.write(f"p cnf {c.nv} {len(c.clauses)}\n".encode())
            for clause in c.clauses:
                f.write((" ".join(map(str, clause)) + " 0\n").encode())
        expected = {"cloud-original": "0d3ca734e513174f99ff95fb7e37ad70474e27b20d27cbe212f66047b0497cde",
                    "cloud-plus-two": "66ccb9156c94f0b8b44bf9625f0a23f65e12e8d43a83e40f62140049fc40b141"}
        assert digest(cnf) == expected[case]
    with (out / (case + ".solver.log")).open("wb") as log:
        run = subprocess.run([shutil.which("cadical"), "--lrat", "--no-binary",
                              str(cnf), str(proof)], stdout=log, stderr=subprocess.STDOUT)
    if run.returncode != 20:
        raise RuntimeError(f"Expected UNSAT, solver returned {run.returncode}. See {case}.solver.log")
    for checker, signature in (("lrat-check", b"c VERIFIED"), ("cake_lpr", b"s VERIFIED UNSAT")):
        with (out / (case + "." + checker + ".log")).open("wb") as log:
            run = subprocess.run([checker, str(cnf), str(proof)], stdout=log, stderr=subprocess.STDOUT)
        output = (out / (case + "." + checker + ".log")).read_bytes().splitlines()
        if run.returncode != 0 or signature not in output:
            raise RuntimeError(f"{checker} did not verify {case}")
    record = dict(case=case, samples=len(bits), gaps="".join(map(str,gaps)),
                  terminal_outside=case != "unrestricted", cnf_sha256=digest(cnf),
                  lrat_sha256=digest(proof), proof_bytes=proof.stat().st_size,
                  checkers=["lrat-check", "cake_lpr"], status="VERIFIED UNSAT")
    (out / (case + ".json")).write_text(json.dumps(record, indent=2) + "\n")
    print(record, flush=True)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit", type=Path)
    p.add_argument("out", type=Path)
    p.add_argument("case", choices=["cloud-original", "cloud-plus-two", "unrestricted"])
    a = p.parse_args()
    main(a.kit.resolve(), a.out.resolve(), a.case)
