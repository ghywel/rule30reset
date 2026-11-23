"""Replay the sharp mixed-gap controls, or search for physical lower witnesses anew."""

import argparse
import json
from pathlib import Path
import shutil
import subprocess

from audit_gap_observers import read_row, sample_bits
from mixed_cut_strength import formula
from wheel_bridge import table, tick


def replay_witness(record, trap):
    word = record["gaps"]
    bits = sample_bits(word * record["repetitions"])
    row = int(record["row_site_one_low"], 16)
    assert row.bit_length() == record["rightmost_black"]
    width = 16 + 2 * (len(bits) - 1)
    initial = format(row, f"0{width}b")[::-1]
    assert read_row(initial, bits) == record["final_window"]
    first = None
    for t in range(2 * len(bits) - 1):
        if t % 2 == 0:
            assert row & 1 == int(bits[t // 2])
            if first is None and row & 65535 in trap:
                first = (t, row & 65535)
        row = tick(row, t % 2)
    assert first == (record["trap_entry_tick"], record["entry_window"])
    print(word, record["repetitions"], "physical repetitions, first trap entry", first)


def find_witness(word, count, output, solver):
    bits = sample_bits(word * count)
    rows, nv, clauses = formula(bits, None, (), physical=True)
    cnf = output / f"physical-{word}-{count}.cnf"
    with cnf.open("w", encoding="ascii", newline="\n") as target:
        target.write(f"p cnf {nv} {len(clauses)}\n")
        target.writelines(" ".join(map(str, clause)) + " 0\n" for clause in clauses)
    result = subprocess.run([solver, "--quiet", "--modelalllits", str(cnf)], capture_output=True)
    if result.returncode != 10:
        raise RuntimeError((word, count, result.returncode, result.stderr[-500:]))
    positive = {
        int(v)
        for line in result.stdout.splitlines()
        if line.startswith(b"v ")
        for v in line[2:].split()
        if int(v) > 0
    }
    row = "".join(str(int(v in positive)) for v in rows[0])
    final = read_row(row, bits)
    print(word, count, "fresh physical witness", hex(int(row[::-1], 2)), "terminal window", final)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("--search", type=Path, help="Generate fresh SAT witnesses in this directory.")
    parser.add_argument("--cadical", default=shutil.which("cadical"))
    args = parser.parse_args()
    trap = set(table(args.kit, "trapCodes", "Rule30Certificates/GateTrap"))
    records = json.loads((Path(__file__).parent / "data/mixed-cut-receipts.json").read_bytes())[
        "physical_witnesses"
    ]
    for record in records:
        replay_witness(record, trap)
        if args.search:
            args.search.mkdir(parents=True, exist_ok=True)
            find_witness(record["gaps"], record["repetitions"], args.search, args.cadical)
