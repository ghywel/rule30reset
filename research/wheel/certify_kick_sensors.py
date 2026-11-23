"""Refute errors in the prospective sensors with an independent factorized space-time CNF."""

import argparse
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import shutil

from audit_gap_observers import solve
from kick_predictor import WHEEL


def counterexample(record, sufficient_only):
    width = 16
    lead, phase, history = (record[k] for k in ("lead", "target_phase", "history"))
    launch = history - 1
    end = launch + lead
    first_phase = phase - end
    # Each row includes wall, positive cells 1..16 and one unconstrained east input.
    def cell(t, j):
        return 1 + t * (width+2) + j

    clauses = []
    num = cell(end, width+1)

    def fresh():
        nonlocal num
        num += 1
        return num

    def conj(literals):
        z = fresh()
        clauses.extend([[-z, x] for x in literals])
        clauses.append([z, *(-x for x in literals)])
        return z

    for t in range(end+1):
        wall = cell(t, 0)
        clauses.append([wall if (first_phase+t) % 2 else -wall])
        if t <= launch:
            gate = cell(t, 1)
            clauses.append([gate if WHEEL[(first_phase+t) % 56] == "1" else -gate])
        if t == end:
            break
        for j in range(1,width+1):
            a, b, c = (cell(t,k) for k in (j-1,j,j+1))
            z = cell(t+1,j)
            g = fresh()
            clauses.extend([[-b,g],[-c,g],[b,c,-g]])
            clauses.extend([[-a,-g,-z],[a,g,-z],[a,-g,z],[-a,g,z]])

    future = []
    for t in range(launch+1, end+1):
        bit = WHEEL[(first_phase+t) % 56] == "1"
        positive = bit if t < end else not bit
        future.append(cell(t,1) if positive else -cell(t,1))
    actual = conj(future)
    patterns = []
    for word in record["depart_if"]:
        patterns.append(conj([cell(launch,j) if b == "1" else -cell(launch,j)
                              for j,b in zip(record["sites"], word, strict=True)]))
    if sufficient_only:
        clauses.extend([patterns, [-actual]])
    else:
        signal = -conj([-p for p in patterns])
        clauses.extend([[signal, actual],[-signal, -actual]])
    header = f"p cnf {num} {len(clauses)}\n"
    return (header + "".join(" ".join(map(str,c)) + " 0\n" for c in clauses)).encode()


def main(args):
    data = json.loads(args.sensors.read_bytes())
    tests = [(r, False) for r in data["sensors"]]
    for old in data["earlier_signatures"]:
        item = old.copy()
        if item["lead"] == 4:
            phase = item["target_phase"]
            word = "110" if phase == 52 else "000" if phase in (19,39,49) else "011"
            item.update(sites=[3,4,5], depart_if=[word])
        else:
            item.update(sites=list(range(6,12)), depart_if=["110"+w for w in ("000","001","100","101","111")])
        tests.append((item, True))

    def verify(test):
        item, sufficient = test
        name = f"{'old' if sufficient else 'selector'}-{item['target_phase']}-{item['lead']}"
        folder = args.output / name
        folder.mkdir(parents=True, exist_ok=True)
        body = counterexample(item, sufficient)
        model, proof = solve(args, folder, "no-error", body)
        if model is not None:
            raise ValueError(f"Counterexample to {name}")
        return name, proof

    with ThreadPoolExecutor(max_workers=3) as pool:
        receipts = dict(pool.map(verify, tests))
    (args.output/"receipts.json").write_bytes((json.dumps(receipts, indent=2)+"\n").encode())
    print(f"{len(receipts)} independent CNFs passed both LRAT checkers.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sensors", type=Path)
    parser.add_argument("output", type=Path)
    for name, program in (("cadical","cadical"),("lrat","lrat-check"),("cake","cake_lpr")):
        parser.add_argument("--"+name, default=shutil.which(program))
    main(parser.parse_args())
