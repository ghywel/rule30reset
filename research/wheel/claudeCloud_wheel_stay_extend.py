#!/usr/bin/env python3
"""claudeCloud_wheel_stay_extend.py: can a stay in Y that a right half has read be continued? (ledger K79, addendum 7)

claudeCloud_wheel_stay.py asks the whole light cone for a stay of N samples in Y: a gate word of (2 | 45 | 4525)*
with a gap of 4 inside every 57 samples, the last window outside the trap. This script asks for a longer one whose
gate BEGINS with the gate of a stay already found (the first P samples of a witness): the row itself is left free.
The cone, the automaton and the two conditions are the frozen ones; only the fixed beginning of the gate is added.

A model is replayed cell by cell and checked as in the stay script. If the solver refuses, that says only that this
beginning cannot be continued so far; it says nothing about other stays.

    python3 claudeCloud_wheel_stay_extend.py KITFILE WITNESS.json P N [--budget B]
        WITNESS.json = an output of claudeCloud_wheel_stay.py (or of this script) with status SAT
        P = how many samples of its gate to keep (at most its length), N = the length asked for
"""
import json
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_runs as R       # noqa: E402
import claudeCloud_wheel_budget as B     # noqa: E402
import claudeCloud_wheel_stay as ST      # noqa: E402


def main():
    args = sys.argv[1:]
    budget = 50_000_000
    if '--budget' in args:
        i = args.index('--budget')
        budget = int(args[i + 1])
        del args[i:i + 2]
    kit, path, P, N = args[0], args[1], int(args[2]), int(args[3])
    trap = [int(c) for c in L.trap_codes(kit)]
    old = json.loads(open(path).read().strip().split('\n')[-1])
    assert old['status'] == 'SAT' and old.get('verified')
    row = [int(ch) for ch in old['row']]
    gate0, _ = R.simulate(row, old['samples'])
    assert P <= len(gate0)
    t0 = time.time()
    cone = R.Cone(N)
    B.add_automaton(cone, B.Y_DFA, 'u', 0)
    ST.recurrence(cone, '10001', 57)
    for s in range(P):
        cone.clauses.append([cone.gate(s) if gate0[s] else -cone.gate(s)])
    cone.forbid_codes(N - 1, trap)
    status, row = cone.solve(budget)
    out = dict(mode='ystay-extend', kept_samples=P, samples=N, window=57, status=status, variables=cone.nv,
               clauses=len(cone.clauses), cnf_sha256=cone.digest())
    if row is not None:
        gate, codes = R.simulate(row, N)
        bits = ''.join(map(str, gate))
        gaps = B.gaps_of(gate)
        s = ''.join(map(str, gaps))
        parsed = B.count_y(gaps)
        recurs = all('10001' in bits[i: i + 57] for i in range(N - 57 + 1))
        out['verified'] = bool(gate[0] == 1 and parsed is not None and recurs and codes[-1] not in set(trap)
                               and gate[:P] == gate0[:P])
        out['excursions'] = parsed
        out['read'] = re.sub(r'2{3,}', lambda m: ' 2x%d ' % len(m.group(0)), s).split()
        out['row'] = ''.join(map(str, row))
        out['final_window'] = codes[-1]
    out['seconds'] = round(time.time() - t0, 1)
    print(json.dumps(out))


if __name__ == '__main__':
    main()
