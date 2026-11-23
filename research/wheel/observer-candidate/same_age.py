"""Look for the exterior exceptional 47-bit observation at a fixed white-sample age."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from audit_gap_observers import solve
from claudeCloud_wheel_runs import Cone
from complete_observer import dimacs
from observer_controls import black_predecessor
from wheel_bridge import table


EXCEPTION = "00001001000010010000100001000010000100100001000"
INNER_SEED = 0x4319fc9fcd612848b70077729985e4b9


def replay(seed, samples, black_first):
    """Literal site-by-site truth table on the complete finite light cone."""
    extra = int(black_first)
    steps = 2 * (samples - 1) + extra
    row = [(seed >> i) & 1 for i in range(16 + steps)]
    bits = []
    windows = []
    for t in range(steps + 1):
        wall = (t + extra) % 2
        if not wall:
            bits.append(str(row[0]))
            windows.append(sum(b << i for i, b in enumerate(row[:16])))
        if t < steps:
            left = [wall, *row]
            row = [0 < 4 * a + 2 * b + c < 5 for a, b, c in zip(left, row, row[1:])]
            row = [int(b) for b in row]
    return "".join(bits), windows


def run(kit, folder, age, black_first):
    trap = sorted(table(kit, "trapCodes", "Rule30Certificates/GateTrap"))
    samples = age + len(EXCEPTION)
    cone = Cone(samples)
    initial = (black_predecessor(cone) if black_first
               else [cone.var[0, j] for j in range(1, 17 + cone.T)])
    for s, bit in enumerate(EXCEPTION, age):
        gate = cone.gate(s)
        cone.clauses.append([gate if bit == "1" else -gate])
    cone.forbid_codes(samples - 1, trap)
    body = dimacs(cone.nv, cone.clauses)
    label = f"age{age}-{'black' if black_first else 'white'}"
    folder.mkdir(parents=True, exist_ok=True)
    programs = argparse.Namespace(cadical=shutil.which("cadical"), lrat=shutil.which("lrat-check"),
                                  cake=shutil.which("cake_lpr"))
    model, proof = solve(programs, folder, label, body)
    record = dict(start_age=age, black_first=black_first, exception=EXCEPTION,
                  cnf_sha256=hashlib.sha256(body).hexdigest(), status="UNSAT" if model is None else "SAT")
    if model is None:
        record.update(proof=proof, verified_by=["lrat-check", "cake_lpr"])
    else:
        seed = sum(1 << i for i, v in enumerate(initial) if v in model)
        bits, windows = replay(seed, samples, black_first)
        assert bits[age:] == EXCEPTION and windows[-1] not in trap
        record.update(seed=hex(seed), final_window=windows[-1], all_earlier_outside=all(x not in trap for x in windows))
    inside_bits, inside_windows = replay(INNER_SEED, 57, True)
    assert inside_bits[10:] == EXCEPTION and all(x in trap for x in inside_windows)
    record.update(inner_control={"black_first_seed":hex(INNER_SEED), "start_age":10, "final_window":inside_windows[-1]})
    (folder / (label + ".json")).write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(record))


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("age", type=int)
    p.add_argument("--black-first", action="store_true")
    a = p.parse_args()
    if a.age < 0:
        p.error("age must be nonnegative")
    run(a.kit, a.output, a.age, a.black_first)
