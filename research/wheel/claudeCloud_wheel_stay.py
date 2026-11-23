#!/usr/bin/env python3
"""claudeCloud_wheel_stay.py: how long can ANY right half keep making excursions outside the gate trap?
(ledger K79, addendum 4)

In the variable component Y of the window graph (R69, 40 to 43 columns) the gate is a word of (2 | 45 | 4525)* in
which a gap of 4 returns within 57 samples (at most 22 gaps of 2 between two excursions). In X it is a word of
(A | E)*, A = 25, E = 33535555, with no bound on the loops between excursions.

A right half that stays in Y's variable component for ever keeps both properties for ever, and both are closed
conditions: if the whole light cone refuses them at some length N, no right half of any support stays that long, and
RD's Y half is settled for every support. If the cone accepts them at every length reached, an endless stay is
consistent as far as the solver sees.

    ystay N [M]      from a kick, N samples: a word of (2 | 45 | 4525)*, the reading 10001 (a gap of 4) inside every
                     M consecutive samples (default 57), the last window outside the trap
    xstay N M        from a kick, N samples: a word of (A | E)*, the reading 1001001 (the two 3-gaps that open an
                     excursion) inside every M consecutive samples, the last window outside the trap
                     (M = 48 + 7 n allows up to n loops between excursions)

A model is replayed cell by cell and the two properties are checked again on the replayed gate. UNSAT is COMPUTED
only (python-sat, CaDiCaL 1.9.5).

    python3 claudeCloud_wheel_stay.py KITFILE MODE N [M] [--budget B]
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


def recurrence(cone, marker, M):
    """The bit word `marker` is read inside every M consecutive samples."""
    k = len(marker)
    here = []
    for p in range(cone.S - k + 1):
        cone.nv += 1
        m = cone.nv
        lits = [(cone.gate(p + i) if ch == '1' else -cone.gate(p + i)) for i, ch in enumerate(marker)]
        for lit in lits:
            cone.clauses.append([-m, lit])                 # m -> the marker is read at p
        here.append(m)
    for s in range(cone.S - M + 1):
        cone.clauses.append(here[s: s + M - k + 1])


def solve(trap, mode, N, M, budget):
    cone = R.Cone(N)
    if mode == 'ystay':
        B.add_automaton(cone, B.Y_DFA, 'u', 0)
        marker = '10001'
    else:
        B.add_automaton(cone, B.X_DFA, 'u', 0)
        marker = '1001001'
    recurrence(cone, marker, M)
    cone.forbid_codes(N - 1, trap)
    status, row = cone.solve(budget)
    out = dict(mode=mode, samples=N, window=M, status=status, variables=cone.nv, clauses=len(cone.clauses),
               cnf_sha256=cone.digest())
    if row is not None:
        gate, codes = R.simulate(row, N)
        bits = ''.join(map(str, gate))
        gaps = B.gaps_of(gate)
        s = ''.join(map(str, gaps))
        parsed = (B.count_y(gaps) if mode == 'ystay' else B.count_x(gaps))
        recurs = all(marker in bits[i: i + M] for i in range(N - M + 1))
        out['verified'] = bool(gate[0] == 1 and parsed is not None and recurs and codes[-1] not in set(trap))
        out['excursions'] = parsed
        if mode == 'ystay':
            out['read'] = re.sub(r'2{3,}', lambda m: ' 2x%d ' % len(m.group(0)), s).split()
        else:
            out['read'] = re.sub(r'(25)+', lambda m: ' A%d ' % (len(m.group(0)) // 2), s.replace('33535555', ' E ')).split()
        out['row'] = ''.join(map(str, row))
        out['final_window'] = codes[-1]
    return out


def main():
    args = sys.argv[1:]
    budget = 50_000_000
    if '--budget' in args:
        i = args.index('--budget')
        budget = int(args[i + 1])
        del args[i:i + 2]
    kit, mode, N = args[0], args[1], int(args[2])
    M = int(args[3]) if len(args) > 3 else 57
    trap = [int(c) for c in L.trap_codes(kit)]
    t0 = time.time()
    out = solve(trap, mode, N, M, budget)
    out['seconds'] = round(time.time() - t0, 1)
    print(json.dumps(out))


if __name__ == '__main__':
    main()
