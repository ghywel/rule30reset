"""Certify the short-history wheel bounds with physical Rule 30 light cones.

Every first row is finite with arbitrary first T+1 bits. Free cells farther
east cannot reach a tested cell by tick T. Tick zero is a white-wall tick.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import shutil

from audit_gap_observers import solve
from kick_predictor import WHEEL, sensor_table


def cone(history, target, lead, rule, initial_white=True):
    # The history starts at start and includes the issue tick. If it starts at
    # a black tick, its preceding white row exists in a white-started run.
    start_phase = (target - lead - history + 1) % 56
    start = start_phase % 2 if initial_white else 0
    phase0 = start_phase - start
    issue = start + history - 1
    end = issue + lead
    clauses = []
    # The rows decrease in width by one per tick, from end+1 to one.
    def cell(t, j):
        return t * (end + 1) - t * (t - 1) // 2 + j

    nvars = cell(end, 1)
    def conjunction(lits):
        nonlocal nvars
        nvars += 1
        clauses.extend([[-nvars, x] for x in lits])
        clauses.append([nvars] + [-x for x in lits])
        return nvars

    def bit(t):
        g = cell(t, 1)
        return g if WHEEL[(phase0+t) % 56] == "1" else -g

    for t in range(end):
        for j in range(1, end-t+1):
            b, c, out = cell(t,j), cell(t,j+1), cell(t+1,j)
            for left in (0,1):
                if j == 1 and (t+phase0) % 2 != left:
                    continue
                guard = [] if j == 1 else [cell(t,j-1) * (-1 if left else 1)]
                y = -out if left else out
                clauses.extend([guard + [-b,y], guard + [-c,y], guard + [b,c,-y]])
    clauses.extend([[bit(t)] for t in range(start,issue+1)])
    if rule is None:
        assert lead == 1
        clauses.append([-bit(end)])
    else:
        actual = conjunction([bit(t) for t in range(issue+1,end)] + [-bit(end)])
        # Forbid every correct (pattern, label) pair. This also catches
        # patterns that the table incorrectly calls impossible.
        for label, patterns in ((True, rule["depart_if"]), (False, rule["stay_or_other_departure_if"])):
            for word in patterns:
                clause = [cell(issue,site) * (1 if ch == '0' else -1)
                          for site, ch in zip(rule["sites"], word, strict=True)]
                clauses.append([*clause, -actual if label else actual])
    dimacs = (f"p cnf {nvars} {len(clauses)}\n" +
              "".join(" ".join(map(str,clause))+" 0\n" for clause in clauses)).encode()
    return dimacs, (end, issue, phase0, start)


def replay(row, info, rule):
    end, issue, phase0, start = info
    words = []
    for t in range(end+1):
        words.append(row)
        row = ((row << 1) | ((phase0+t) % 2)) ^ (row | (row >> 1))
    matches = [w & 1 == int(WHEEL[(phase0+t) % 56]) for t,w in enumerate(words)]
    assert all(matches[start:issue+1])
    first = next((i for i in range(issue+1,end+1) if not matches[i]), None)
    if rule is None:
        assert first == end
        pattern = None
    else:
        pattern = "".join(str(words[issue] >> (j-1) & 1) for j in rule["sites"])
        assert pattern not in rule["depart_if" if first == end else "stay_or_other_departure_if"]
    return dict(initial_row=hex(words[0]), initial_phase=phase0, history_start=start,
                issue=issue, sensor=pattern, first_departure=first)


def main(args):
    tests = [(args.history, r["target_phase"], r["lead"], r) for r in sensor_table()] if args.mode == "sensors" else [
        (args.history,target,1,None) for target in range(56)]
    if args.target is not None:
        tests = [a for a in tests if a[1] == args.target and (not args.lead or a[2] == args.lead)]
    def certify(case):
        history, target, lead, rule = case
        name = f"{args.mode}-{history}-{target}-{lead}"
        folder = args.output/name
        folder.mkdir(parents=True, exist_ok=True)
        problem, info = cone(*case, initial_white=not args.free_start)
        model, receipt = solve(args,folder,"query",problem)
        if model is None:
            return name, {"status":"UNSAT", **receipt}
        row = sum(1 << j for j in range(info[0]+1) if 1+j in model)
        return name, {"status":"SAT","cnf":hashlib.sha256(problem).hexdigest(),**replay(row,info,rule)}
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        results = dict(pool.map(certify,tests))
    name = f"{args.mode}-{args.history}"
    if args.target is not None:
        name += f"-{args.target}-{args.lead}"
    (args.output/(name+".json")).write_text(json.dumps(results,indent=2)+"\n",encoding="utf8")
    print(f"{name}: {len(results)} queries. SAT:", [k for k,v in results.items() if v["status"]=="SAT"])


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("mode", choices=["sensors","positions"])
    p.add_argument("history", type=int)
    p.add_argument("output", type=Path)
    p.add_argument("--target", type=int)
    p.add_argument("--lead", type=int)
    p.add_argument("--free-start",action="store_true",help="Allow arbitrary first row in either wall colour.")
    p.add_argument("--workers",type=int,default=3)
    for name, prog in (("cadical","cadical"), ("lrat","lrat-check"), ("cake","cake_lpr")):
        p.add_argument("--"+name, default=shutil.which(prog))
    main(p.parse_args())
