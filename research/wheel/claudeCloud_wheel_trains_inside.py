#!/usr/bin/env python3
"""claudeCloud_wheel_trains_inside.py: can a strip spell a trapped train N times? (ledger K81, addendum 1)

claudeCloud_wheel_trains.py's finite strip keeps every sample OUTSIDE the gate trap, which suits the trains of X and
Y. A train of 3- and 5-gaps lives inside the trap, so this script drops that one condition and changes nothing else:
columns 1..W for N copies of the gap word from a kick, the wall alternating, column W + 1 free at every tick.

If no W-column strip spells N copies, no right half of any support reads N copies in a row (its first W columns would
be such a strip). A model is replayed tick by tick. UNSAT is COMPUTED only (python-sat, CaDiCaL 1.9.5).

    python3 claudeCloud_wheel_trains_inside.py GAPS W N [N ...]        GAPS as in claudeCloud_wheel_trains.py
"""
import hashlib
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'm9'))
import claudeCloud_wheel_trains as T                 # noqa: E402


def instance(gaps, W, n):
    gate = '1' + ''.join('0' * (int(g) - 1) + '1' for g in gaps * n)
    S = len(gate)
    Tt = 2 * (S - 1)
    var, nv = {}, 0
    for t in range(Tt + 1):
        for x in range(1, W + 2):
            nv += 1
            var[(t, x)] = nv
    clauses = []
    for t in range(Tt):
        wall = t % 2
        for x in range(1, W + 1):
            new, c, r = var[(t + 1, x)], var[(t, x)], var[(t, x + 1)]
            if x == 1:
                clauses += ([[-c, new], [-r, new], [c, r, -new]] if wall == 0 else [[-c, -new], [-r, -new], [c, r, new]])
            else:
                l = var[(t, x - 1)]
                clauses += [[-c, -new, -l], [-c, new, l], [-r, -new, -l], [-r, new, l], [c, r, -new, l], [c, r, new, -l]]
    for s, ch in enumerate(gate):
        v = var[(2 * s, 1)]
        clauses.append([v if ch == '1' else -v])
    return gate, S, Tt, var, nv, clauses


def main():
    gaps, W = T.word(sys.argv[1]), int(sys.argv[2])
    from pysat.solvers import Cadical195
    for n in map(int, sys.argv[3:]):
        t0 = time.time()
        gate, S, Tt, var, nv, clauses = instance(gaps, W, n)
        h = hashlib.sha256()
        h.update(('p cnf %d %d\n' % (nv, len(clauses))).encode())
        for cl in clauses:
            h.update((' '.join(map(str, cl)) + ' 0\n').encode())
        with Cadical195(bootstrap_with=clauses) as sol:
            sol.conf_budget(30_000_000)
            r = sol.solve_limited()
            status = 'SAT' if r else ('UNSAT' if r is False else 'UNKNOWN')
            replay = None
            if r:
                model = set(v for v in sol.get_model() if v > 0)
                row = [1 if var[(0, x)] in model else 0 for x in range(1, W + 1)]
                replay = True
                for t in range(Tt + 1):
                    if t % 2 == 0 and row[0] != int(gate[t // 2]):
                        replay = False
                    if t == Tt:
                        break
                    east = 1 if var[(t, W + 1)] in model else 0
                    ext = [t % 2] + row + [east]
                    row = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, W + 1)]
        print(json.dumps(dict(word=sys.argv[1], gaps=gaps, columns=W, copies=n, samples=S, status=status,
                              replays=replay, cnf_sha256=h.hexdigest(), seconds=round(time.time() - t0, 1))))
        sys.stdout.flush()


if __name__ == '__main__':
    main()
