"""Reproduce I224's finite Rule 30 implications and positive controls.

Run with --out DIR to write independent DIMACS instances for LRAT checking.
--controls also enumerates the observed edge traces and replays their models.
Column 1 is the gate. An even local physical tick has a white wall.
"""

import argparse
import itertools
import json
from pathlib import Path

import claudeM5_m9_sat as gate
from gptIntel_refutation_core import preceding, step


KIT = Path(__file__).resolve().parents[2] / "Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean"
WORD = "355555353"
EDGE_TRACES = ("010010", "010100", "010110", "011010")
STARTS = {11: (5084300695, 13674235287, 56623908247), 12: (13674235287,)}
SEED = 3802889643133324895142591828659


def forbidden(variables, bits):
    return [-v if b else v for v, b in zip(variables, bits, strict=True)]


def low_bits(x, width):
    return [(x >> i) & 1 for i in range(width)]


def strip(trap, width, delay, word):
    """Update sites 1..width. The last column in each row is the freely chosen exterior."""
    readings = gate.heads_of(word)
    ticks = 2 * (delay + len(readings) - 1)
    stride = width + 1
    rows = [list(range(1 + t * stride, 1 + (t + 1) * stride)) for t in range(ticks + 1)]
    clauses = []
    for t, (row, following) in enumerate(zip(rows, rows[1:])):
        for j in range(width):
            for a, b, c in itertools.product((0, 1), repeat=3):
                if j == 0 and a != t % 2:
                    continue
                premise = forbidden(row[j:j+2], (b, c))
                if j:
                    premise.append(-row[j-1] if a else row[j-1])
                y = following[j]
                clauses.append(premise + [y if a ^ (b | c) else -y])
    last = rows[-1][-1]
    selectors = list(range(last + 1, last + len(trap) + 1))
    clauses.append(selectors)
    for code, selector in zip(trap, selectors, strict=True):
        for v, b in zip(rows[0][:16], low_bits(code, 16), strict=True):
            clauses.append([-selector, v if b else -v])
    for k, b in enumerate(readings):
        v = rows[2*(delay+k)][0]
        clauses.append([v if b else -v])
    return clauses, rows, selectors[-1]


def triple(rows, tick):
    return [rows[tick][-2], rows[tick][-1], rows[tick+1][-1]]


def instances(trap):
    clauses, cells, n, _ = gate.build(trap, WORD, 11)
    yield "entry17", n, clauses + [forbidden([cells[0, j] for j in range(1, 18)], low_bits(65180, 17))]

    clauses, cells, n, _ = gate.build(trap, WORD, 12)
    # The only unit clauses in this builder are the gate readings.
    base = [c for c in clauses if len(c) != 1]
    four = [[cells[2*(12+i), 1]] for i in (0, 3, 28, 31)]
    yield "ninth", n, base + four + [[cells[2*(12+31), 9]]]

    for delay, starts in STARTS.items():
        clauses, rows, n = strip(trap, 36, delay, WORD)
        vs = rows[2*delay][:36]
        yield f"starts{delay}", n, clauses + [forbidden(vs, low_bits(x, 36)) for x in starts]
        if delay == 12:
            vs = triple(rows, 23) + triple(rows, 26)
            yield "edge", n, clauses + [forbidden(vs, map(int, s)) for s in EDGE_TRACES]

    clauses, rows, n = strip(trap, 29, 9, "355535355553")
    for tick, black_left in ((31, 0), (32, 0), (33, 1)):
        clauses.append(forbidden(triple(rows, tick), (black_left, 1, black_left)))
    yield "other", n, clauses


def physical_controls(trap):
    x = step(SEED, 1)
    assert x % (1 << 17) == 65180
    history = []
    for sample in range(51):
        assert x % 65536 in trap
        if sample == 42:
            assert (x >> 8) & 1
        history.append(x & 1)
        x = step(step(x, 0), 1)
    assert history[11:] == gate.heads_of(WORD)
    parents = {x % 65536 for x in preceding(17, 19, 65180)}
    assert parents == {3745, 15126, 30369, 46753, 56086}
    assert all(x % 4 == 1 or x % 16 == 6 for x in parents)
    assert all(x % 4 != 1 and x % 16 != 6 for x in trap)
    assert {x % 65536 for x in preceding(16, 18, 65180)} & set(trap) == {28110}
    for code, modulus, residue in ((646567, 64, 8), (1236391, 2048, 936)):
        assert {x % modulus for x in preceding(22, 24, code)} == {residue}
        assert all(x % modulus != residue for x in trap)


def strip_controls(trap, delay):
    from pysat.solvers import Cadical195

    clauses, rows, _ = strip(trap, 36, delay, WORD)
    reports = []
    projections = {"start": rows[2*delay][:36]}
    if delay == 12:
        projections["edge"] = triple(rows, 23) + triple(rows, 26)
    for name, vs in projections.items():
        found = set()
        with Cadical195(bootstrap_with=clauses) as solver:
            while solver.solve():
                model = set(solver.get_model())
                exterior = [int(r[-1] in model) for r in rows[:-1]]
                x = sum(1 << j for j, v in enumerate(rows[0][:36]) if v in model)
                initial = x
                readings = []
                for t, row in enumerate(rows):
                    assert low_bits(x, 36) == [int(v in model) for v in row[:36]]
                    if t % 2 == 0:
                        assert x % 65536 in trap
                        readings.append(x & 1)
                    if t < len(exterior):
                        x = step(x | (exterior[t] << 36), t % 2) % (1 << 36)
                assert readings[delay:] == gate.heads_of(WORD)
                bits = [int(v in model) for v in vs]
                value = sum(b << j for j, b in enumerate(bits)) if name == "start" else "".join(map(str, bits))
                found.add(value)
                reports.append(dict(delay=delay, projection=name, value=value, initial=initial,
                                    exterior="".join(map(str, exterior))))
                solver.add_clause(forbidden(vs, bits))
        assert found == set(STARTS[delay] if name == "start" else EDGE_TRACES)
    return reports


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--controls", action="store_true")
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    trap = sorted(gate.trap_codes(KIT))
    physical_controls(trap)
    (args.out / "trap.txt").write_text(" ".join(map(str, trap)) + "\n", encoding="ascii")
    for label, nvars, clauses in instances(trap):
        with (args.out / f"{label}.cnf").open("w", encoding="ascii", newline="\n") as f:
            print(f"p cnf {nvars} {len(clauses)}", file=f)
            for clause in clauses:
                print(*clause, 0, file=f)
    if args.controls:
        reports = strip_controls(trap, 11) + strip_controls(trap, 12)
        (args.out / "controls.json").write_text(json.dumps(reports, indent=2) + "\n", encoding="ascii")
