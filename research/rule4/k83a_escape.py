"""Shortest prefixes that prevent a specified finite gate word beside the alternating wall.

The initial wall is black, the first site is the low bit, and H readings end at physical
tick 2H-1. Run from the repository with python-sat installed.
"""

import argparse
import json
from pathlib import Path

def trace(row, horizon):
    readings = []
    for tick in range(2 * horizon - 1):
        left = 1 - tick % 2
        row = ((row << 1) | left) ^ (row | (row >> 1))
        if tick % 2 == 0:
            readings.append(row & 1)
    return readings


def seeds():
    receipt = Path(__file__).resolve().parents[1] / "wheel/gptIntel-k80-results.json"
    train = json.loads(receipt.read_bytes())["Y"]["finite_black_predecessor"]
    return {"trap": 3802889643133324895142591828659, "train": int(train, 16),
            "lock": 157190921, "trap-twin": 150212610825}


def literals(variables, row):
    return [v if row >> i & 1 else -v for i, v in enumerate(variables)]


def gate_cone(solver, horizon):
    width = 2 * horizon
    initial = list(range(1, width + 1))
    row = initial
    last = width
    readings = []
    for tick in range(1, width):
        following = list(range(last + 1, last + len(row)))
        last = following[-1]
        for j, y in enumerate(following):
            b, c = row[j:j+2]
            for a in (0, 1):
                if j == 0 and a != tick % 2:
                    continue
                guard = [] if j == 0 else [-row[j-1] if a else row[j-1]]
                out = -y if a else y
                for clause in ([-b, out], [-c, out], [b, c, -out]):
                    solver.add_clause(guard + clause)
        row = following
        if tick % 2:
            readings.append(row[0])
    return initial, readings, last + 1


def prefix_escape(seed, width, horizon, depth):
    from pysat.solvers import Cadical195

    if width < 0 or horizon < 1 or depth < 0 or width + depth > 2 * horizon:
        raise ValueError("the extension must fit within the physical cone")
    target = trace(seed, horizon)
    with Cadical195() as solver:
        initial, gates, switch = gate_cone(solver, horizon)
        same = [v if b else -v for v, b in zip(gates, target)]
        prefix = literals(initial[:width], seed)
        solver.add_clause([-switch] + [-lit for lit in same])
        if not solver.solve(assumptions=prefix + [switch]):
            return {"result": "forced"}
        # At each depth keep an actual matching completion for every live cylinder.
        parents = {0: seed}
        for k in range(1, depth + 1):
            live = {}
            missing = []
            mask = (1 << (width + k)) - 1
            for word in range(1 << k):
                low = (seed % (1 << width)) | (word << width)
                parent = parents[word % (1 << (k - 1))]
                if parent & mask == low:
                    live[word] = parent
                    continue
                candidate = (seed & ~mask) | low
                if trace(candidate, horizon) != target:
                    if not solver.solve(assumptions=same + literals(initial[:width+k], low)):
                        missing.append(word)
                        continue
                    model = set(solver.get_model())
                    candidate = sum(1 << j for j, v in enumerate(initial) if v in model)
                    assert candidate & mask == low and trace(candidate, horizon) == target
                live[word] = candidate
            if missing:
                return {"result": "miss", "k": k, "misses": missing,
                        "parents": [hex(x) for x in parents.values()]}
            parents = live
        return {"result": "greater", "k": depth, "parents": [hex(x) for x in parents.values()]}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("label", choices=seeds())
    parser.add_argument("width", type=int)
    parser.add_argument("horizon", type=int)
    parser.add_argument("depth", type=int)
    args = parser.parse_args()
    print(json.dumps(prefix_escape(seeds()[args.label], args.width, args.horizon, args.depth)))
