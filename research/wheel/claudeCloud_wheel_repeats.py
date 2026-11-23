#!/usr/bin/env python3
"""claudeCloud_wheel_repeats.py: how many times in a row can the trapped gate repeat one run? (ledger K81)

Inside the kit's gate trap the gaps between kicks are 3 or 5, and from ten samples after entry no two 3-gaps are
adjacent. So the gate is a sequence of RUNS: the numbers of 5-gaps between successive 3-gaps. gptIntel's 17/56
wheel is the gate whose runs are all 5 (gaps 3 5 5 5 5 5, 28 samples, 56 ticks); a kick of the wheel is a run that
is not 5. A gate that repeats one run for ever is periodic.

This script asks the whole light cone (so the answer is for every right half of every support) whether K closed
runs of R in a row can be read: the gaps  3 (5^R 3)^K  from a kick.

    plain      no other condition: can any right half read it at all?
    late P     the sixteen-column window is in the trap at sample 0 and the word begins at a kick at sample P:
               can a right half that has already spent P samples in the trap read it?

A model is replayed cell by cell. UNSAT is COMPUTED only (python-sat, CaDiCaL 1.9.5): then no right half reads it.

    python3 claudeCloud_wheel_repeats.py KITFILE R K [P] [--budget B]
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_runs as R       # noqa: E402


def main():
    args = sys.argv[1:]
    budget = 30_000_000
    if '--budget' in args:
        i = args.index('--budget')
        budget = int(args[i + 1])
        del args[i:i + 2]
    kit, r, k = args[0], int(args[1]), int(args[2])
    P = int(args[3]) if len(args) > 3 else None
    trap = [int(c) for c in L.trap_codes(kit)]
    trapset = set(trap)
    gaps = '3' + ('5' * r + '3') * k
    bits = '1' + ''.join('0' * (int(g) - 1) + '1' for g in gaps)
    start = P or 0
    N = start + len(bits)
    t0 = time.time()
    cone = R.Cone(N)
    if P is not None:
        cone.require_codes(0, trap)
    for i, ch in enumerate(bits):
        cone.clauses.append([cone.gate(start + i) if ch == '1' else -cone.gate(start + i)])
    status, row = cone.solve(budget)
    out = dict(run=r, copies=k, after_samples_in_trap=P, samples=N, status=status, variables=cone.nv,
               clauses=len(cone.clauses), cnf_sha256=cone.digest())
    if row is not None:
        gate, codes = R.simulate(row, N)
        ok = ''.join(map(str, gate[start:])) == bits
        if P is not None:
            ok = ok and codes[0] in trapset and all(c in trapset for c in codes)
        out['verified'] = bool(ok)
        out['in_trap_at_the_end'] = codes[-1] in trapset
        out['row'] = ''.join(map(str, row))
    out['seconds'] = round(time.time() - t0, 1)
    print(json.dumps(out))


if __name__ == '__main__':
    main()
