"""Check the exact two-gap obstruction and a distance-12 return in ordinary Rule 30."""
import argparse
import json
import subprocess
from itertools import accumulate, product
from pathlib import Path
from runpy import run_path

HERE = Path(__file__).parent
OBSERVER = run_path(str(HERE / "check-return-obstruction.py"))
TRIPLES = list(product((0, 1), repeat=3))


def encode(gaps, width, domains, sample):
    pulses = [0, *accumulate(q + 1 for q in gaps)]
    horizon = pulses[-1]
    drive = set(pulses[:-1])
    cells = []
    nvars = 0
    for t in range(horizon + 1):
        length = width + horizon - t
        cells.append(list(range(nvars + 1, nvars + 1 + length)))
        nvars += length
    clauses = []
    for t in range(horizon):
        for i, out in enumerate(cells[t+1]):
            for l, c, r in TRIPLES:
                if i == 0 and l != (t in drive):
                    continue
                bit = (30 >> (4*l + 2*c + r)) & 1
                clause = ([cells[t][i-1] * (1 - 2*l)] if i else [])
                clause += [cells[t][i] * (1 - 2*c), cells[t][i+1] * (1 - 2*r),
                           out * (2*bit - 1)]
                clauses.append(clause)
    for t, rows in zip(pulses, domains, strict=True):
        if len(rows) == 1:
            clauses.extend([v * (2*((rows[0] >> j) & 1) - 1)]
                           for j, v in enumerate(cells[t][:width]))
            continue
        selectors = list(range(nvars+1, nvars+1+len(rows)))
        nvars += len(rows)
        clauses.append(selectors)
        for selector, row in zip(selectors, rows, strict=True):
            clauses.extend([-selector, v * (2*((row >> j) & 1) - 1)]
                           for j, v in enumerate(cells[t][:width]))
    if sample is not None:
        slot, colour = sample
        clauses.append([cells[pulses[slot]+2][0] * (2*colour - 1)])
    return nvars, clauses, cells[0], pulses


def replay(initial, gaps, width, domains, pulses, sample):
    row = sum(1 << j for j in initial)
    length = width + pulses[-1]
    drive = set(pulses)
    observed = []
    for t in range(pulses[-1]+1):
        if t in drive:
            projected = row & ((1 << width) - 1)
            assert projected in domains[len(observed)]
            observed.append(projected)
        if sample is not None and t == pulses[sample[0]] + 2:
            assert row & 1 == sample[1]
        if t < pulses[-1]:
            length -= 1
            row = (((row << 1) | int(t in drive)) ^ (row | (row >> 1))) & ((1 << length) - 1)
    colors = [int((row & 1) == 0 or (row & 6) == 0) for row in observed]
    if sample is not None:
        assert colors[sample[0]] == sample[1]
    return observed, colors


def solve(directory, name, gaps, width, domains, sample=None):
    nvars, clauses, init_vars, pulses = encode(gaps, width, domains, sample)
    cnf, lrat = directory / (name + ".cnf"), directory / (name + ".lrat")
    with cnf.open("w") as handle:
        handle.write(f"p cnf {nvars} {len(clauses)}\n")
        handle.writelines(" ".join(map(str, c)) + " 0\n" for c in clauses)
    proc = subprocess.run(["cadical", "-q", "--lrat", "--no-binary", cnf, lrat],
                          capture_output=True, text=True)
    (directory / (name + ".cadical")).write_text(proc.stdout + proc.stderr)
    receipt = dict(case=name, width=width, gaps=gaps, pulses=pulses, vars=nvars, clauses=len(clauses),
                   domain_sizes=list(map(len, domains)))
    if proc.returncode == 10:
        yes = {int(v) for line in proc.stdout.splitlines() if line.startswith("v ")
               for v in line.split()[1:]}
        initial = [j for j, var in enumerate(init_vars) if var in yes]
        rows, colors = replay(initial, gaps, width, domains, pulses, sample)
        return dict(**receipt, verdict="SAT", initial_black_indices=initial, rows=rows, samples=colors)
    if proc.returncode != 20:
        raise RuntimeError(proc.stdout + proc.stderr)
    for checker, expected in [("cake_lpr", "s VERIFIED UNSAT"), ("lrat-check", "c VERIFIED")]:
        check = subprocess.run([checker, cnf, lrat], capture_output=True, text=True)
        text = check.stdout + check.stderr
        (directory / (name + "." + checker)).write_text(text)
        assert check.returncode == 0 and expected in text.splitlines(), text
    return dict(**receipt, verdict="UNSAT", checkers=["cake_lpr", "lrat-check"])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("mode", choices=["seam", "path", "white", "black"])
    parser.add_argument("graph", type=Path)
    args = parser.parse_args()
    folder = args.folder
    if args.mode == "seam":
        obstruction = json.loads((folder / "independent-11.json").read_text())["obstruction"]
        domains = obstruction["preceding_base_rows"][-3:]
        result = solve(folder, "seam-11", [12, 12], 29, domains)
        print(json.dumps(result), flush=True)
        return
    witness = json.loads((folder / "independent-12.json").read_text())["witness"]
    gaps = witness["gaps"]
    if args.mode == "path":
        result = solve(folder, "path-12", gaps, 30, [[row] for row in witness["rows"]])
    else:
        rows, edges = OBSERVER["LOAD"](args.graph)
        domains = OBSERVER["base_domains"](rows, edges, [(q,) for q in gaps])
        allowed = [rows[domain].tolist() for domain in domains]
        result = solve(folder, "return-12-" + args.mode, gaps, 29, allowed,
                       (19, int(args.mode == "black")))
    print(json.dumps(result), flush=True)


if __name__ == "__main__":
    main()
