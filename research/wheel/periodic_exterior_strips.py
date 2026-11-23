"""Can a time-periodic spatial strip realize each candidate exterior gate?"""

import argparse
import json
from pathlib import Path
import shutil
import subprocess

from audit_gap_observers import digest, solve


def instance(word, width):
    gaps = list(map(int, word))
    period = 2 * sum(gaps)
    kicks = {sum(gaps[:i]) for i in range(len(gaps))}

    def var(t, j):
        return 1 + (t % period) * (width + 2) + j

    clauses = []
    for t in range(period):
        clauses.append([var(t, 0) if t % 2 else -var(t, 0)])
        if t % 2 == 0:
            clauses.append([var(t, 1) if t // 2 in kicks else -var(t, 1)])
        for j in range(1, width + 1):
            inputs = [var(t, j-1), var(t, j), var(t, j+1)]
            for k in range(8):
                a, b, c = [(k >> n) & 1 for n in range(3)]
                clause = [-v if k & (1 << n) else v for n, v in enumerate(inputs)]
                clause.append(var(t+1, j) if a ^ (b | c) else -var(t+1, j))
                clauses.append(clause)
    header = f"p cnf {period * (width+2)} {len(clauses)}\n"
    return (header + "".join(" ".join(map(str, c)) + " 0\n" for c in clauses)).encode(), period


def run(args, word):
    out = args.output / word
    out.mkdir(parents=True, exist_ok=True)

    def passes(width):
        body, _ = instance(word, width)
        res = subprocess.run([args.cadical, "--quiet"], input=body, capture_output=True)
        if res.returncode not in (10, 20):
            raise RuntimeError(res.stderr)
        return res.returncode == 10

    # A satisfying strip restricts to every smaller width. Bracket its boundary.
    lo, hi = 0, 1
    while passes(hi):
        lo = hi
        if hi == args.width:
            break
        hi = min(2 * hi, args.width)
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if passes(mid):
            lo = mid
        else:
            hi = mid

    assert lo > 0
    body, period = instance(word, lo)
    model, _ = solve(args, out, "last-model", body)
    assert model is not None
    rows = [[int(1 + t * (lo+2) + j in model) for j in range(lo+2)] for t in range(period)]
    kicks = [j for j in range(period // 2) if rows[2*j][1]]
    assert kicks[0] == 0
    assert [b - a for a, b in zip(kicks, kicks[1:] + [period // 2])] == list(map(int, word))
    assert all(row[0] == t % 2 for t, row in enumerate(rows))
    assert all(rows[(t+1) % period][j] == (row[j-1] ^ (row[j] | row[j+1]))
               for t, row in enumerate(rows) for j in range(1, lo+1))
    result = {"gaps": word, "ticks": period, "largest_checked_model": lo, "model_cnf": digest(body),
              "cyclic_rows": ["".join(map(str, row)) for row in rows], "first_impossible": None}
    if lo != hi:
        body, _ = instance(word, hi)
        model, proof = solve(args, out, "first-obstruction", body)
        assert model is None
        result.update(first_impossible=hi, proof=proof)
    (out / "result.json").write_bytes((json.dumps(result, indent=2) + "\n").encode())
    print(word, period, lo, result["first_impossible"], flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--width", type=int, default=84)
    for name, program in (("cadical", "cadical"), ("lrat", "lrat-check"), ("cake", "cake_lpr")):
        parser.add_argument("--" + name, default=shutil.which(program))
    args = parser.parse_args()
    if args.width < 1:
        parser.error("--width must be positive")
    for word in ("3", "33355", "333355"):
        run(args, word)
