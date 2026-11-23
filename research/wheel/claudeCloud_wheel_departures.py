#!/usr/bin/env python3
"""claudeCloud_wheel_departures.py: at which positions of the 56-tick wheel can a first departure come, after H
matched ticks? (ledger K77, addendum 1; a read of the statement in research/wheel/kick-predictor.md that after 140
matched ticks only the positions 32, 42 and 52 are left)

For each position j of the wheel word U: column 1 equals U at the H ticks ending at position j - 1, and differs at
position j. Real rows, by SAT on the light cone, with K75's encoder; no window graph and no trap condition.

    python3 claudeCloud_wheel_departures.py H [H ...]
SAT: the row is replayed cell by cell. UNSAT: COMPUTED only.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_wheel_runs as R       # noqa: E402

U = '00010011010001001101000100110100010011010001001101001101'


def case(H, j):
    a = (j - H) % 2                # cone tick 0 is white; the target tick a + H must have the parity of j
    T = a + H
    S = (T + 1) // 2 + 1
    cone = R.Cone(S)
    idx = lambda t: (j - T + t) % 56
    for t in range(a, T):
        v = cone.var[(t, 1)]
        cone.clauses.append([v if U[idx(t)] == '1' else -v])
    v = cone.var[(T, 1)]
    cone.clauses.append([-v if U[j] == '1' else v])
    status, row = cone.solve(5_000_000)
    ok = None
    if row is not None:
        x = sum(int(b) << i for i, b in enumerate(row))
        width = len(row)
        col = []
        for t in range(T + 1):
            col.append(x & 1)
            if t == T:
                break
            r = (x << 1) | (t % 2)
            x = (r ^ ((r >> 1) | (r >> 2))) & ((1 << (width - 1)) - 1)
            width -= 1
        ok = all(col[t] == int(U[idx(t)]) for t in range(a, T)) and col[T] != int(U[j])
    return status, ok


def main():
    for H in map(int, sys.argv[1:]):
        can, bad = [], []
        for j in range(56):
            status, ok = case(H, j)
            if status == 'SAT':
                can.append(j)
                if not ok:
                    bad.append(j)
            elif status != 'UNSAT':
                bad.append(j)
        print('after %d matched ticks a first departure can come at positions %s%s' % (
            H, can, '' if not bad else '; NOT REPLAYED OR UNKNOWN: %s' % bad))
        sys.stdout.flush()


if __name__ == '__main__':
    main()
