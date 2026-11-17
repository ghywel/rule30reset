#!/usr/bin/env python3
"""Extra to claudeM5's carrying read of R8: actual four-tick failures below age 80, for every seed y < 2^9.

For each seed and age 26..95: whether all 16 four-tick wall histories end in finite rows; and, at even ages, whether
the twin (the row two ticks back reached through the other choice at t - 1, head at t - 2 black) has a finite
black-headed two-tick parent. Also whether each such seed survives (black at the wall at every even tick to t).
Usage: claudeM5_r8_ages.py OUTFILE
"""
import json, multiprocessing, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from claudeM5_r8_replay import F, histories


def survives(y, t):
    row = y
    for s in range(t + 1):
        if s % 2 == 0 and not row & 1:
            return False
        row = F(row)
    return True


def work(y):
    rows = [y]
    for _ in range(96):
        rows.append(F(rows[-1]))
    out = []
    for t in range(26, 96):
        H = histories(rows[t], 4)
        fin = sum(1 for _, p in H if p is not None)
        twin = None
        if t % 2 == 0:
            head = rows[t - 1] & 1
            tw = [p for hs, p in H if hs[1] == 1 and hs[3] == 1 and hs[0] != head]
            twin = sum(1 for p in tw if p is not None)
        if fin < 16:
            out.append({'y': y, 't': t, 'finite_of_16': fin, 'twin_finite_of_2': twin, 'survives': survives(y, t)})
    return out


def main():
    with multiprocessing.Pool(8) as pool:
        fails = [f for o in pool.map(work, range(1, 1 << 9)) for f in o]
    res = {'seeds': (1 << 9) - 1, 'ages': [26, 95], 'cases_with_an_unclosed_history': len(fails),
           'ages_with_failures': sorted({f['t'] for f in fails}),
           'latest_failure_age': max((f['t'] for f in fails), default=None),
           'even_age_twin_leaves': [f for f in fails if f['t'] % 2 == 0 and f['t'] >= 46 and f['twin_finite_of_2'] == 0],
           'any_survivor_among_failures': any(f['survives'] for f in fails)}
    with open(sys.argv[1], 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: v for k, v in res.items() if k != 'even_age_twin_leaves'}, indent=1))
    print('even-age twin leaves at t >= 46:', [(f['y'], f['t'], f['survives']) for f in res['even_age_twin_leaves']])


if __name__ == '__main__':
    main()
