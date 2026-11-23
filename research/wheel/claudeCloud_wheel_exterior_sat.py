#!/usr/bin/env python3
"""claudeCloud_wheel_exterior_sat.py: a second method for K77's two deaths (ledger K77, addendum 1).

K77's lift finds no window of 44 columns on an endless path spelling 333355 outside the trap, and none of 55 columns
for 33355. If that is right, a strip of that width can spell the word only for a bounded time. This script asks
SAT directly: columns 1..W for n repetitions of the word, the wall alternating, column W + 1 free at every tick,
every sixteen-column window at a sample outside the kit's trap, the gate spelling the word from a kick. It shares
only the trap file with the lift.

    python3 claudeCloud_wheel_exterior_sat.py KITFILE GAPS W N [N ...]
SAT: the model is replayed tick by tick here. UNSAT: COMPUTED only (python-sat's CaDiCaL 1.9.5).
"""
import hashlib
import os
import sys
import time

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L      # noqa: E402


def instance(trap, gaps, W, n):
    gate = ('1' + ''.join('0' * (int(g) - 1) + '1' for g in gaps * n))        # kick, then n repetitions
    S = len(gate)
    T = 2 * (S - 1)
    var, nv = {}, 0
    for t in range(T + 1):
        for x in range(1, W + 2):
            nv += 1
            var[(t, x)] = nv
    clauses = []
    for t in range(T):
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
        w = [var[(2 * s, x)] for x in range(1, 17)]
        for code in trap:
            clauses.append([(-w[i] if (code >> i) & 1 else w[i]) for i in range(16)])
    return gate, S, T, var, nv, clauses


def main():
    kit, gaps, W = sys.argv[1], sys.argv[2], int(sys.argv[3])
    trap = [int(c) for c in L.trap_codes(kit)]
    trapset = set(trap)
    from pysat.solvers import Cadical195
    for n in map(int, sys.argv[4:]):
        t0 = time.time()
        gate, S, T, var, nv, clauses = instance(trap, gaps, W, n)
        h = hashlib.sha256()
        h.update(('p cnf %d %d\n' % (nv, len(clauses))).encode())
        for cl in clauses:
            h.update((' '.join(map(str, cl)) + ' 0\n').encode())
        with Cadical195(bootstrap_with=clauses) as sol:
            sol.conf_budget(20_000_000)
            r = sol.solve_limited()
            status = 'SAT' if r else ('UNSAT' if r is False else 'UNKNOWN')
            replay = None
            if r:
                model = set(v for v in sol.get_model() if v > 0)
                row = [1 if var[(0, x)] in model else 0 for x in range(1, W + 1)]
                replay = True
                for t in range(T + 1):
                    if t % 2 == 0:
                        s = t // 2
                        code = sum(row[i] << i for i in range(16))
                        if row[0] != int(gate[s]) or code in trapset:
                            replay = False
                    if t == T:
                        break
                    east = 1 if var[(t, W + 1)] in model else 0
                    ext = [t % 2] + row + [east]
                    row = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, W + 1)]
        print('gaps %s, %d columns, %d repetitions (%d samples): %s%s; %d variables, %d clauses, cnf %s, %.1f s'
              % (gaps, W, n, S, status, '' if replay is None else ', replays: %s' % replay, nv, len(clauses),
                 h.hexdigest()[:16], time.time() - t0))
        sys.stdout.flush()


if __name__ == '__main__':
    main()
