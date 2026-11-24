"""Replay the 64 infinite seven-lock continuations and rebuild both LRAT inputs.

Usage: python k83a_escape_check.py lock-certified.json OUTPUT_DIR
The Rule30PrizeKit checkout is expected in the root of this repository.
"""
import argparse
import ast
import hashlib
import itertools
import json
import re
from pathlib import Path


KIT = Path(__file__).resolve().parents[2] / "Rule30PrizeKit/lean/Ruliology/CellularAutomata"
PREFIX = 157190921
TWIN = 150212610825
BAD = PREFIX | (87 << 28)
WORD = (0, 0, 0, 0, 1, 0, 1)
HASHES = {
    "prefix28-read48": "af20f29568ee131c3a965a2a85041c5f0d7fef77eac2b1a022240c953c4632c6",
    "prefix35-white48": "015a0885c22bff8fd3db0949e57dc993d787f5697aa009bdd90c44f9bbdb6903",
}


def windows(seed, samples):
    """Physical site-by-site evolution with enough eastern cells for every observation."""
    row = [(seed >> i) & 1 for i in range(30 + 2 * samples - 1)]
    for tick in range(2 * samples - 1):
        west = [1 - tick % 2] + row[:-1]
        row = [a ^ (b | c) for a, b, c in zip(west, row, row[1:])]
        if tick % 2 == 0:
            yield sum(b << i for i, b in enumerate(row[:30]))


def check_witnesses(path):
    src = (KIT / "Rule30SidewaysLocks.lean").read_text(encoding="utf8")
    groups = ast.literal_eval(re.search(r"def lock7Codes : List \(List Nat\) := (\[.*?\n\])", src, re.S)[1])
    # Independently check that each published phase has one gate colour and advances
    # on every assignment to the two sites that can enter during one strobe step.
    for phase, group in enumerate(groups):
        assert {x & 1 for x in group} == {WORD[(phase - 4) % 7]}
        for win, east in itertools.product(group, range(4)):
            full = win | (east << 30)
            black_time = (full << 1) ^ (full | (full >> 1))
            white_time = ((black_time << 1) | 1) ^ (black_time | (black_time >> 1))
            assert white_time % (1 << 30) in groups[(phase + 1) % 7]
    # The 29-site good child enters the published phase at the first white sample.
    for east in range(4):
        assert next(windows(PREFIX | (east << 29), 1)) in groups[4]
    seeds = {int(k): v for k, v in json.loads(path.read_bytes()).items()}
    assert set(seeds) == set(range(64))
    for branch, (encoded, hit) in seeds.items():
        seed = int(encoded, 16)
        assert seed % (1 << 34) == PREFIX | (branch << 28)
        for s, win in enumerate(windows(seed, hit + 1)):
            assert win & 1 == WORD[s % 7]
            assert (win in groups[(4+s) % 7]) == (s == hit)
    trap_src = (KIT / "Rule30Certificates/GateTrap.lean").read_text(encoding="utf8")
    traps = set(ast.literal_eval(trap_src.split("def trapCodes : List Nat := ", 1)[1].split("]", 1)[0] + "]"))
    twin = list(windows(TWIN, 49))
    assert TWIN % (1 << 28) == PREFIX and (TWIN >> 28) & 1
    assert next(s for s, win in enumerate(twin) if win % (1 << 16) in traps) == 41
    assert next(s for s, win in enumerate(twin) if win & 1 != WORD[s % 7]) == 48
    print("64 aligned infinite continuations checked; latest capture", max(hit for _, hit in seeds.values()))


def write_instance(folder, name, samples, width, low, last_only):
    clocks = []
    clauses = []
    count = 0
    for tick in range(2 * samples):
        old = clocks[-1] if clocks else []
        row = list(range(count + 1, count + 1 + 2 * samples - tick))
        count = row[-1]
        clocks.append(row)
        if not old:
            continue
        for j, output in enumerate(row):
            for a, b, c in itertools.product(range(2), repeat=3):
                if j == 0 and a != tick % 2:
                    continue
                clause = [-old[j] if b else old[j], -old[j+1] if c else old[j+1],
                          output if a ^ (b | c) else -output]
                if j:
                    clause.append(-old[j-1] if a else old[j-1])
                clauses.append(clause)
    clauses.extend([v if low >> j & 1 else -v] for j, v in enumerate(clocks[0][:width]))
    if last_only:
        assert WORD[(samples-1) % 7] == 1
        clauses.append([clocks[-1][0]])
    else:
        clauses.append([(-1 if WORD[s % 7] else 1) * clocks[2*s+1][0] for s in range(samples)])
    path = folder / (name + ".cnf")
    with path.open("w", encoding="ascii", newline="\n") as out:
        print("p cnf", count, len(clauses), file=out)
        for clause in clauses:
            print(*clause, 0, file=out)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    assert digest == HASHES[name]
    print(name, count, "variables", len(clauses), "clauses", digest)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("witnesses", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    check_witnesses(args.witnesses)
    args.output.mkdir(parents=True, exist_ok=True)
    write_instance(args.output, "prefix28-read48", 48, 28, PREFIX, False)
    write_instance(args.output, "prefix35-white48", 49, 35, BAD, True)
