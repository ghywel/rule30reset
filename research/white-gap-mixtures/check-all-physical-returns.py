"""Use one continuous Rule 30 cone for every gap choice at a given return spacing."""
import argparse
import json
import subprocess
from itertools import accumulate
from pathlib import Path
from runpy import run_path

HERE = Path(__file__).parent
FIXED = run_path(str(HERE / "certify-return-cones.py"))
OBSERVER = FIXED["OBSERVER"]
WIDTH = 29


class Cone:
    def __init__(self):
        self.variables = 0
        self.clauses = []

    def fresh(self, n):
        start = self.variables + 1
        self.variables += n
        return list(range(start, start+n))

    def evolve(self, previous, pulse):
        current = self.fresh(len(previous)-1)
        for i, out in enumerate(current):
            for l, c, r in FIXED["TRIPLES"]:
                if i == 0 and l != pulse:
                    continue
                bit = (30 >> (4*l + 2*c + r)) & 1
                left = [previous[i-1] * (1 - 2*l)] if i else []
                self.clauses.append(left + [previous[i] * (1 - 2*c),
                                            previous[i+1] * (1 - 2*r), out * (2*bit - 1)])
        return current

    def select_row(self, window, rows, domain):
        indices = sorted(i for i, yes in enumerate(domain) if yes)
        selectors = dict(zip(indices, self.fresh(len(indices)), strict=True))
        self.clauses.append(list(selectors.values()))
        for i, selector in selectors.items():
            row = int(rows[i])
            self.clauses.extend([-selector, var * (2*((row >> j) & 1) - 1)]
                                for j, var in enumerate(window[:WIDTH]))
        return selectors

    def check_adjacency(self, graph, source, chosen, target):
        for q, selector in chosen.items():
            m = graph[q]
            for i, src in source.items():
                ids = m.indices[m.indptr[i]:m.indptr[i+1]]
                self.clauses.append([-src, -selector] + [target[j] for j in ids if j in target])


def build(slots, rows, edges, domains, mark):
    cone = Cone()
    initial = cone.fresh(WIDTH + sum(max(qs)+1 for qs in slots))
    row = initial
    choices = []
    membership = cone.select_row(row, rows, domains[0]) if domains is not None else None
    for i, gaps in enumerate(slots):
        chosen = dict(zip(gaps, cone.fresh(len(gaps)), strict=True))
        cone.clauses.append(list(chosen.values()))
        for index, selector in enumerate(chosen.values()):
            cone.clauses.extend([-selector, -other] for other in list(chosen.values())[:index])
        next_width = len(row) - max(gaps) - 1
        evolved = row
        outputs = cone.fresh(next_width)
        for t in range(1, max(gaps)+2):
            evolved = cone.evolve(evolved, t == 1)
            if i == mark and t == 2:
                cone.clauses.append([evolved[0]])
            selector = chosen.get(t-1)
            if selector is not None:
                for source, dest in zip(evolved[:next_width], outputs, strict=True):
                    cone.clauses.extend(([-selector, -source, dest], [-selector, source, -dest]))
        if domains is not None:
            dest_membership = cone.select_row(outputs, rows, domains[i+1])
            cone.check_adjacency(edges, membership, chosen, dest_membership)
            membership = dest_membership
        row = outputs
        choices.append(chosen)
    return cone, initial, choices


def run(graph, output, distance, control, second_black):
    slots = OBSERVER["DISTANCES"](distance)
    rows, edges = OBSERVER["LOAD"](graph)
    domains = None if control else OBSERVER["base_domains"](rows, edges, slots)
    mark = distance + 7 if second_black else None
    cone, initial, choices = build(slots, rows, edges, domains, mark)
    suffix = "-control" if control else "-black" if second_black else ""
    stem = output / (f"all-{distance}" + suffix)
    cnf, proof = stem.with_suffix(".cnf"), stem.with_suffix(".lrat")
    with cnf.open("w") as handle:
        handle.write(f"p cnf {cone.variables} {len(cone.clauses)}\n")
        handle.writelines(" ".join(map(str, c)) + " 0\n" for c in cone.clauses)
    receipt = dict(distance=distance, control=control, second_black=second_black, vars=cone.variables, clauses=len(cone.clauses))
    print(json.dumps(receipt), flush=True)
    proc = subprocess.run(["cadical", "-q", "--lrat", "--no-binary", cnf, proof],
                          capture_output=True, text=True)
    stem.with_suffix(".cadical").write_text(proc.stdout + proc.stderr)
    if proc.returncode == 10:
        yes = {int(v) for line in proc.stdout.splitlines() if line.startswith("v ")
               for v in line.split()[1:]}
        word = [next(q for q, var in choice.items() if var in yes) for choice in choices]
        pulses = [0, *accumulate(q+1 for q in word)]
        black = [i for i, var in enumerate(initial[:WIDTH + pulses[-1]]) if var in yes]
        allowed = ([rows[d].tolist() for d in domains] if domains is not None else None)
        if allowed is None:
            # Permit any row during the independent evolution.
            class AnyRow:
                def __contains__(self, row):
                    return True
            allowed = [AnyRow()] * len(pulses)
        sample = (mark, 1) if mark is not None else None
        observed, samples = FIXED["replay"](black, word, WIDTH, allowed, pulses, sample)
        return dict(**receipt, verdict="SAT", word=word, pulses=pulses,
                    initial_black_indices=black, rows=observed, samples=samples)
    if proc.returncode != 20:
        raise RuntimeError(proc.stdout + proc.stderr)
    for checker, marker in [("cake_lpr", "s VERIFIED UNSAT"), ("lrat-check", "c VERIFIED")]:
        done = subprocess.run([checker, cnf, proof], capture_output=True, text=True)
        receipt_text = done.stdout + done.stderr
        stem.with_suffix("." + checker).write_text(receipt_text)
        assert done.returncode == 0 and marker in receipt_text.splitlines(), receipt_text
    return dict(**receipt, verdict="UNSAT", checkers=["cake_lpr", "lrat-check"])


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("graph", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("distance", type=int)
    modes = p.add_mutually_exclusive_group()
    modes.add_argument("--control", action="store_true")
    modes.add_argument("--second-black", action="store_true")
    args = p.parse_args()
    print(json.dumps(run(args.graph, args.output, args.distance, args.control, args.second_black)), flush=True)
