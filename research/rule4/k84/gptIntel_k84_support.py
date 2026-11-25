"""Replay the coupled boundary and freeze finite CNFs for independent proof checking."""

import argparse
import json
from pathlib import Path

from claudeCloud_k84_coupled import build, replay_full


def write_cnf(path, clauses, variables):
    with path.open("w", encoding="ascii", newline="\n") as stream:
        stream.write(f"p cnf {variables} {len(clauses)}\n")
        for clause in clauses:
            stream.write(" ".join(map(str, clause)) + " 0\n")


def pack(bits):
    return format(sum(bit << depth for depth, bit in enumerate(bits)), "x")


def replay_model(path, variables, width, ticks):
    model = {
        int(lit)
        for line in path.read_text(encoding="ascii").splitlines()
        if line.startswith("v ")
        for lit in line.split()[1:]
        if int(lit) > 0
    }
    west = [int(variables.get(("z", d, 0)) in model) for d in range(1, width + 1)]
    east = [int(variables[("x", j, 0)] in model) for j in range(1, ticks + 1)]
    expected = [1 - t % 2 for t in range(ticks + 1)]
    if replay_full(west, east, ticks) != expected:
        raise ValueError("full-line replay failed")
    return {"B": width, "T": ticks, "west_hex": pack(west),
            "right_hex": pack(east), "literal_replay": True}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("cnf", "replay"))
    parser.add_argument("width", type=int)
    parser.add_argument("ticks", type=int)
    parser.add_argument("path", type=Path)
    args = parser.parse_args()
    variables, clauses, count = build(args.width, args.ticks)
    if args.mode == "cnf":
        write_cnf(args.path, clauses, count)
    else:
        print(json.dumps(replay_model(args.path, variables, args.width, args.ticks)))


if __name__ == "__main__":
    main()

