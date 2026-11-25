"""Test one black pulse observation across consecutive nine-gap factors."""

import argparse
from itertools import accumulate
import json
from pathlib import Path
import subprocess

import numpy as np
from runpy import run_path


HERE = Path(__file__).parent
SPACING = run_path(str(HERE / "check-mark-spacing.py"))
PHYSICAL = run_path(str(HERE / "check-all-physical-returns.py"))
LOAD = PHYSICAL["OBSERVER"]["LOAD"]
WIDTH = PHYSICAL["WIDTH"]
FACTOR = SPACING["FACTOR"]
ALPHABET = SPACING["ALL"]


def word_slots(starts):
    slots = [set(ALPHABET) for _ in range(starts[-1] + len(FACTOR))]
    for start in starts:
        for offset, letters in enumerate(FACTOR):
            slots[start + offset].intersection_update(letters)
    return [tuple(sorted(letters)) for letters in slots]


def domains_for(rows, graph, slots, mark):
    """Intersect paths from each end, through a black sample at the chosen mark."""
    forward = {q: m.T.tocsr() for q, m in graph.items()}
    black = ((rows & 1) == 0) | ((rows & 6) == 0)

    def propagate(matrices, word, sample_at):
        layers = [black.copy() if sample_at == 0 else np.ones(len(rows), dtype=bool)]
        for i, letters in enumerate(word, start=1):
            layer = np.logical_or.reduce([matrices[q] @ layers[-1] for q in letters])
            layers.append(layer & black if i == sample_at else layer)
        return layers

    before = propagate(forward, slots, mark)
    after = propagate(graph, reversed(slots), len(slots) - mark)
    return [a & b for a, b in zip(before, reversed(after), strict=True)]


def replay(seed, gaps, projected, starts):
    """Replay with growing physical support and read every observation afresh."""
    row = seed
    pulse_rows = []
    sample_bits = {}
    samples = {7 + start for start in starts}
    for i, gap in enumerate(gaps):
        pulse_rows.append(row & ((1 << WIDTH) - 1))
        for tick in range(1, gap + 2):
            row = ((row << 1) | int(tick == 1)) ^ (row | (row >> 1))
            if tick == 2 and i in samples:
                sample_bits[i] = row & 1
    pulse_rows.append(row & ((1 << WIDTH) - 1))
    if projected is not None:
        assert all(x in allowed for x, allowed in zip(pulse_rows, projected, strict=True))
    return pulse_rows, sample_bits


def run(args):
    starts = list(accumulate([0, *args.separations]))
    mark = starts[args.black] + 7
    slots = word_slots(starts)
    rows, edges = LOAD(args.graph)
    domains = None if args.free else domains_for(rows, edges, slots, mark)
    receipt = dict(starts=starts, black=mark, free=args.free,
                   counts=None if domains is None else [int(d.sum()) for d in domains])
    print(json.dumps(receipt), flush=True)
    if domains is not None and not domains[mark].any():
        return dict(**receipt, verdict="empty strip")
    if args.strip_only:
        return dict(**receipt, verdict="strip path")

    lo, hi = args.crop or (0, len(slots))
    assert 0 <= lo < hi <= len(slots)
    # A cropped graph test retains the conditions projected from the entire word.
    # If the sample lies outside the crop, its colour is only a graph constraint.
    local_mark = mark-lo if lo <= mark < hi else None
    assert not args.free or local_mark is not None
    slots = slots[lo:hi]
    domains = None if domains is None else domains[lo:hi+1]
    cone, initial, choices = PHYSICAL["build"](slots, rows, edges, domains, local_mark)
    cnf, proof = (args.output.with_suffix(ext) for ext in (".cnf", ".lrat"))
    with cnf.open("w") as out:
        out.write(f"p cnf {cone.variables} {len(cone.clauses)}\n")
        out.writelines(" ".join(map(str, clause)) + " 0\n" for clause in cone.clauses)
    receipt.update(crop=[lo, hi], variables=cone.variables, clauses=len(cone.clauses))
    result = subprocess.run(["cadical", "-q", "--lrat", "--no-binary", cnf, proof],
                            capture_output=True, text=True)
    args.output.with_suffix(".cadical").write_text(result.stdout + result.stderr)
    if result.returncode == 10:
        literals = {int(v) for line in result.stdout.splitlines() if line.startswith("v ")
                    for v in line.split()[1:]}
        gaps = [next(q for q, var in choice.items() if var in literals) for choice in choices]
        seed = sum(1 << j for j, var in enumerate(initial) if var in literals)
        projected = None if domains is None else [set(rows[d].tolist()) for d in domains]
        observed, samples = replay(seed, gaps, projected, [s-lo for s in starts])
        if local_mark is not None:
            assert samples[local_mark] == 1
        return dict(**receipt, verdict="SAT", gaps=gaps, rows=observed, samples=samples,
                    initial_hex=hex(seed), physical_ticks=sum(q+1 for q in gaps))
    if result.returncode != 20:
        raise RuntimeError(result.stdout + result.stderr)
    for name, marker in (("cake_lpr", "s VERIFIED UNSAT"), ("lrat-check", "c VERIFIED")):
        checked = subprocess.run([name, cnf, proof], capture_output=True, text=True)
        report = checked.stdout + checked.stderr
        args.output.with_suffix("." + name).write_text(report)
        if checked.returncode or marker not in report.splitlines():
            raise RuntimeError(report)
    return dict(**receipt, verdict="UNSAT", checkers=["cake_lpr", "lrat-check"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("graph", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("separations", type=int, nargs="+")
    parser.add_argument("--black", type=int, required=True, help="index of the black mark")
    parser.add_argument("--free", action="store_true", help="all initial rows, no strip constraints")
    parser.add_argument("--strip-only", action="store_true")
    parser.add_argument("--crop", type=int, nargs=2, metavar=("FIRST_PULSE", "LAST_PULSE"))
    print(json.dumps(run(parser.parse_args())), flush=True)
