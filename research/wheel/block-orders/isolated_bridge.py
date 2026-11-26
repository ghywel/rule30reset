"""Find or replay a Y loop, an X crossing and a second Y loop on a free-east strip."""
import argparse
from itertools import product
import json
from pathlib import Path
import subprocess

from check import target


def edges(turns):
    left, right = turns
    return ("AB" * left, "A", "AB" * right)


def verify(model):
    row = list(map(int, model["initial"]))
    width = model["width"]
    assert width > 0 and len(row) == width and set(row) <= {0, 1}
    exterior = model["east"]
    jumps = edges(model["turns"])
    assert min(model["turns"]) >= 1 and len(exterior) == len(jumps)
    seams = [row.copy()]
    for blocks, inputs in zip(jumps, exterior):
        word = target(blocks)
        assert len(inputs) == 2 * len(word) and set(inputs) <= {"0", "1"}
        for t, bit in enumerate(inputs):
            if t % 2 == 0:
                assert row[0] == int(word[t // 2])
            extended = [t % 2] + row + [int(bit)]
            row = [l ^ (c | r) for l, c, r in zip(extended, extended[1:], extended[2:])]
        seams.append(row.copy())
    assert seams[0] == seams[1] and seams[2] == seams[3]
    first = next((i for i, (l, r) in enumerate(zip(seams[1], seams[2]), 1) if l != r), None)
    print(f"width {width}, {model['turns']} Y turns: loops and X crossing replay; first seam difference {first}")


def cnf(width, turns):
    words = [target(edge) for edge in edges(turns)]
    cuts = [0]
    for word in words:
        cuts.append(cuts[-1] + 2 * len(word))
    # Only the physical cells at the two ends of each Y loop are identified.
    aliases = {cuts[1]: cuts[0], cuts[3]: cuts[2]}

    def var(t, p):
        time = aliases.get(t, t) if 1 <= p <= width else t
        return 1 + time * (width + 2) + p

    clauses = []
    word = "".join(words)
    for t in range(cuts[-1]):
        clauses.append([var(t, 0) if t % 2 else -var(t, 0)])
        if t % 2 == 0:
            clauses.append([var(t, 1) if word[t // 2] == "1" else -var(t, 1)])
        for p in range(1, width + 1):
            inputs = [var(t, i) for i in (p - 1, p, p + 1)]
            out = var(t + 1, p)
            for bits in product((0, 1), repeat=3):
                code = 4 * bits[0] + 2 * bits[1] + bits[2]
                clause = [-i if bit else i for i, bit in zip(inputs, bits)]
                clauses.append(clause + [out if (30 >> code) & 1 else -out])
    head = f"p cnf {(cuts[-1] + 1) * (width + 2)} {len(clauses)}\n"
    body = head + "".join(" ".join(map(str, c)) + " 0\n" for c in clauses)
    return body, var, cuts


def search(width, turns, seconds):
    body, var, cuts = cnf(width, turns)
    run = subprocess.run(["cadical", "-q", "-t", str(seconds)], input=body, capture_output=True, text=True)
    if run.returncode in (0, 20):
        print("timeout" if run.returncode == 0 else "two-loop template UNSAT (solver only)")
        return None
    if run.returncode != 10:
        raise RuntimeError((run.returncode, run.stderr))
    black = {int(i) for line in run.stdout.splitlines() if line.startswith("v ") for i in line[2:].split() if int(i) > 0}

    def bit(t, p):
        return str(int(var(t, p) in black))

    return {"width": width, "turns": turns, "initial": "".join(bit(0, p) for p in range(1, width + 1)),
            "east": ["".join(bit(t, width + 1) for t in range(a, b)) for a, b in zip(cuts, cuts[1:])]}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("model", type=Path)
    parser.add_argument("--search", type=int, metavar="WIDTH")
    parser.add_argument("--seconds", type=int, default=60)
    parser.add_argument("--turns", type=int, nargs=2, default=(1, 1), metavar=("LEFT", "RIGHT"))
    parser.add_argument("--cnf", action="store_true", help="write the DIMACS instance instead of solving")
    args = parser.parse_args()
    if not __debug__ or args.seconds <= 0 or min(args.turns) < 1 or (args.cnf and args.search is None) or (args.search is not None and args.search <= 0):
        parser.error("enable assertions and use positive limits")
    if args.search is None:
        verify(json.loads(args.model.read_text()))
    elif args.cnf:
        body, _, _ = cnf(args.search, args.turns)
        args.model.write_bytes(body.encode("ascii"))
    else:
        model = search(args.search, args.turns, args.seconds)
        if model:
            verify(model)
            args.model.write_text(json.dumps(model, indent=2) + "\n")
