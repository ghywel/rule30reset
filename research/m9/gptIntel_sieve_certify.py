"""K65: certify the first forbidden delays already isolated in the sieve's JSONL answers.

Run under Linux with the frozen K60 CNF builder. Pass the candidate list, GateTrap.lean,
an output directory, and the answer files. Repeated passes retain completed proof packets.
"""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

import claudeM5_m9_sat as gate


def sha(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def answers(paths):
    known = {}
    for path in paths:
        with path.open("rb") as stream:
            for line in stream:
                if not line.endswith(b"\n"):
                    break  # A live writer may still be appending this record.
                row = json.loads(line)
                if row["status"] not in ("SAT", "UNSAT"):
                    continue
                key = (row["spec"], row["P"])
                previous = known.get(key)
                if previous and (previous["status"], previous["cnf_sha"]) != (row["status"], row["cnf_sha"]):
                    raise ValueError(f"Conflicting answers for {key}")
                known[key] = row
    return known


def replay_lower(row, word, trap):
    if not row.get("verified"):
        raise ValueError("Missing checked SAT model")
    heads = gate.heads_of(word)
    phase = row["P"]
    orbit = gate.simulate([int(bit) for bit in row["initial_row"]], 2 * (phase + len(heads) - 1))
    strobes = orbit[::2]
    if [cells[1] for cells in strobes[phase:]] != list(heads):
        raise ValueError("Lower witness does not spell the word")
    trapset = set(trap)
    if any(sum(cells[j + 1] << j for j in range(16)) not in trapset for cells in strobes):
        raise ValueError("Lower witness left the gate trap")


def verified_proof(folder, cadical, checker, binary, success, checker_options=()):
    proof = folder / ("binary.lrat" if binary else "text.lrat")
    command = [cadical, "-q", "--lrat=true", "--binary=" + str(binary).lower(), "instance.cnf", proof.name]
    solve = subprocess.run(command, cwd=folder, capture_output=True)
    if solve.returncode != 20:
        raise RuntimeError(f"CaDiCaL returned {solve.returncode} for {proof}: {solve.stderr[-500:]!r}")
    check = subprocess.run([checker, *checker_options, "instance.cnf", proof.name], cwd=folder, capture_output=True)
    output = (check.stdout + check.stderr).decode(errors="replace").splitlines()
    if check.returncode != 0 or success not in (line.strip() for line in output):
        raise RuntimeError(f"{checker} failed for {proof}: {output[-5:]}")
    packed = proof.with_suffix(".lrat.gz")
    with proof.open("rb") as source, gzip.open(packed, "wb", compresslevel=1) as target:
        shutil.copyfileobj(source, target)
    record = dict(checker=Path(checker).name, verdict=success, bytes=proof.stat().st_size,
                  sha256=sha(proof), archive=packed.name, archive_sha256=sha(packed))
    if checker_options:
        record["checker_options"] = list(checker_options)
    proof.unlink()
    return record


def certify(args, row, lower, trap):
    spec, onset = row["spec"], row["P"]
    folder = args.output / (spec.replace(":", "-") + f"-P{onset}")
    receipt = folder / "receipt.json"
    if receipt.exists():
        old = json.loads(receipt.read_bytes())
        proofs = old["proofs"]
        if (old["cnf_sha"] != row["cnf_sha"] or (old["spec"], old["onset"]) != (spec, onset)
                or {p["archive"] for p in proofs} != {"binary.lrat.gz", "text.lrat.gz"}
                or not all((folder / p["archive"]).is_file() for p in proofs)):
            raise ValueError(f"Inconsistent existing packet {folder}")
        if args.final and (sha(folder / "instance.cnf") != old["cnf_sha"]
                           or any(sha(folder / p["archive"]) != p["archive_sha256"] for p in proofs)):
            raise ValueError(f"Checksum mismatch in final packet {folder}")
        return
    word = gate.gap_word(spec)
    if onset:
        replay_lower(lower, word, trap)
    clauses, _, variables, _ = gate.build(trap, word, onset)
    with tempfile.TemporaryDirectory(dir=args.output) as tmp:
        pending = Path(tmp) / "packet"
        pending.mkdir()
        cnf = pending / "instance.cnf"
        gate.dimacs(clauses, variables, cnf)
        if sha(cnf) != row["cnf_sha"]:
            raise ValueError(f"CNF differs from the judge: {spec} at {onset}")
        cake_options = [] if args.cake_heap_mib is None else [f"--CML_HEAP_SIZE={args.cake_heap_mib}"]
        proofs = [verified_proof(pending, args.cadical, args.cake, True, "s VERIFIED UNSAT", cake_options),
                  verified_proof(pending, args.cadical, args.lrat, False, "c VERIFIED")]
        data = dict(spec=spec, onset=onset, cnf_sha=row["cnf_sha"], proofs=proofs,
                    lower_witness=lower if onset else None)
        (pending / "receipt.json").write_text(json.dumps(data, indent=2) + "\n")
        os.rename(pending, folder)
    print(f"{spec} from {onset}: both LRAT checks passed", flush=True)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("candidates", type=Path)
    p.add_argument("kitfile", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("records", nargs="+", type=Path)
    p.add_argument("--cadical", default="cadical")
    p.add_argument("--cake", default="cake_lpr")
    p.add_argument("--cake-heap-mib", type=int, help="heap size for the CakeML checker, in MiB")
    p.add_argument("--lrat", default="lrat-check")
    p.add_argument("--final", action="store_true", help="require a decision and every onset for the registered cohort")
    args = p.parse_args()
    if args.cake_heap_mib is not None and args.cake_heap_mib < 1:
        p.error("--cake-heap-mib must be positive")
    args.output.mkdir(parents=True, exist_ok=True)
    known = answers(args.records)
    trap = gate.trap_codes(args.kitfile)
    incomplete = []
    for c in json.loads(args.candidates.read_bytes()):
        if c["samples"] > 180:  # The eight longer words are outside the registered K60 cohort.
            continue
        spec = "R:" + c["word"].replace(",", ".")
        rows = [row for (s, _), row in known.items() if s == spec]
        onset = min((row["P"] for row in rows if row["status"] == "UNSAT"), default=None)
        last_sat = max((row["P"] for row in rows if row["status"] == "SAT"), default=-1)
        if onset is not None and last_sat >= onset:
            raise ValueError(f"Nonmonotone answers for {spec}")
        if onset is not None and last_sat + 1 == onset:
            certify(args, known[spec, onset], known.get((spec, last_sat)), trap)
        elif onset is not None or last_sat < 40:
            incomplete.append(spec)
    if args.final and incomplete:
        p.exit(1, f"Unresolved K60 words: {incomplete}\n")


if __name__ == "__main__":
    main()
