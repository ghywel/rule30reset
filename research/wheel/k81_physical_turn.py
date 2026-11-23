"""Find the longest returning near-wall prefix in one real turn of a K81 rhythm."""

import argparse
import hashlib
import json
from pathlib import Path

from audit_gap_observers import solve


def make_cone(gaps, width, phase):
    period = 2 * sum(map(int, gaps))
    kicks = {2 * sum(map(int, gaps[:i])) for i in range(len(gaps))}
    size = max(width, 1) + period
    # The spatial triangle shrinks from size positive cells to size-period.
    # Variable zero is unused. The wall itself needs no variables.
    j = 0
    layers = []
    for tick in range(period + 1):
        row = list(range(j + 1, j + size - tick + 1))
        layers.append(row)
        j += len(row)
    clauses = []
    for tick, row in enumerate(layers):
        t = (tick + phase) % period
        if t % 2 == 0:
            clauses.append([row[0] if t in kicks else -row[0]])
        if tick == period:
            break
        for x, after in enumerate(layers[tick + 1]):
            mid, east = row[x:x+2]
            j += 1
            union = j
            clauses += [[union, -mid], [union, -east], [-union, mid, east]]
            if x == 0:
                if t % 2 == 0:
                    clauses += [[-union, after], [union, -after]]
                else:
                    clauses += [[union, after], [-union, -after]]
            else:
                west = row[x-1]
                clauses += [[west, union, -after], [-west, -union, -after],
                            [west, -union, after], [-west, union, after]]
    for first, last in zip(layers[0][:width], layers[-1][:width]):
        clauses += [[first, -last], [-first, last]]
    header = f"p cnf {j} {len(clauses)}\n"
    body = header + "".join(" ".join(map(str, clause)) + " 0\n" for clause in clauses)
    return body.encode(), layers[0], period, kicks


def check(seed, gaps, width, phase):
    period = 2 * sum(map(int, gaps))
    kicks = {2 * sum(map(int, gaps[:i])) for i in range(len(gaps))}
    row = seed
    for tick in range(period + 1):
        t = (tick + phase) % period
        if t % 2 == 0:
            assert (row & 1) == (t in kicks), (tick, row)
        if tick < period:
            row = (2 * row + (t % 2)) ^ (row | (row >> 1))
    diff = seed ^ row
    assert diff and diff & ((1 << width) - 1) == 0
    return (diff & -diff).bit_length()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("gaps", choices=["3555", "355555"])
    parser.add_argument("width", type=int)
    parser.add_argument("output", type=Path)
    parser.add_argument("--phase", type=int, default=0)
    for arg in ("cadical", "lrat", "cake"):
        parser.add_argument("--" + arg, required=True)
    args = parser.parse_args()
    out = args.output / f"{args.gaps}-phase{args.phase}-width{args.width}"
    out.mkdir(parents=True, exist_ok=True)
    body, start, period, _ = make_cone(args.gaps, args.width, args.phase)
    model, proof = solve(args, out, "turn", body)
    receipt = {"gaps": args.gaps, "period": period, "width": args.width,
               "phase": args.phase, "cnf_sha256": hashlib.sha256(body).hexdigest()}
    if model is None:
        receipt["proof"] = proof
    else:
        seed = sum(1 << x for x, v in enumerate(start) if v in model)
        receipt["finite_initial_row"] = hex(seed)
        receipt["first_different_site"] = check(seed, args.gaps, args.width, args.phase)
    (out / "receipt.json").write_bytes((json.dumps(receipt, indent=2) + "\n").encode())
    print(json.dumps(receipt))


if __name__ == "__main__":
    main()
