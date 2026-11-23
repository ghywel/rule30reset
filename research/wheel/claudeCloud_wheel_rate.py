#!/usr/bin/env python3
"""claudeCloud_wheel_rate.py: does the mean run of a trapped gate depend on what lies far to the right? (ledger K75,
addendum 2, test T7)

A right half is driven by the alternating column 0 (white at the samples). Its cells 1..30 are random with cell 30
black, as in K56's cohort, and the cells beyond follow the chosen FAR FIELD out to the edge of the light cone:
  empty      white (the cohort of K56 and of T4: a control)
  uniform    independent fair bits
  p25, p75   independent bits, black with probability 1/4 or 3/4
  black      all black
  alt        black on even columns
  per3       black on every third column
Rows that are in the kit's trap by sample 100 are followed S samples; runs of 5-gaps between 3-gaps are counted from
200 samples after entry. Reported per far field: rows, rows entered, rows that end in 5-gaps only (locked: no 3-gap
in the last quarter), and for the others the mean run with a standard error over rows.

    python3 claudeCloud_wheel_rate.py KITFILE ROWS S [FIELD ...]
"""
import multiprocessing
import os
import random
import sys
import zlib

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L      # noqa: E402

FIELDS = ('empty', 'uniform', 'p25', 'p75', 'black', 'alt', 'per3')
TRAP = None


def far(field, rnd, n):
    if field == 'empty':
        return 0
    if field == 'uniform':
        return rnd.getrandbits(n)
    if field == 'p25':
        return rnd.getrandbits(n) & rnd.getrandbits(n)
    if field == 'p75':
        return rnd.getrandbits(n) | rnd.getrandbits(n)
    if field == 'black':
        return (1 << n) - 1
    if field == 'alt':
        return int('01' * (n // 2 + 1), 2) & ((1 << n) - 1)
    if field == 'per3':
        return int('001' * (n // 3 + 1), 2) & ((1 << n) - 1)
    raise SystemExit('unknown far field')


def one(job):
    field, seed, S = job
    rnd = random.Random(zlib.crc32(('%s:%d' % (field, seed)).encode()))
    n = 2 * S + 40
    x = (rnd.getrandbits(29) | (1 << 29)) | (far(field, rnd, n) << 30)
    width = n + 30
    entered = None
    kicks = []
    for s in range(S):
        if entered is None:
            if (x & 0xFFFF) in TRAP:
                entered = s
            elif s > 100:
                return None
        if entered is not None and x & 1:
            kicks.append(s)
        for wall in (0, 1):
            r = (x << 1) | wall
            x = (r ^ ((r >> 1) | (r >> 2))) & ((1 << (width - 1)) - 1)
            width -= 1
    gaps = [(b, b - a) for a, b in zip(kicks, kicks[1:]) if a >= entered + 200]
    if any(g not in (3, 5) for _, g in gaps):
        return ('bad', seed)
    threes = [s for s, g in gaps if g == 3]
    if not threes or threes[-1] < S - S // 4:
        return ('locked', seed)
    fives = sum(1 for s, g in gaps if g == 5 and threes[0] < s <= threes[-1])
    return (len(threes) - 1, fives)


def main():
    global TRAP
    kit, rows, S = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    fields = sys.argv[4:] or FIELDS
    TRAP = set(int(c) for c in L.trap_codes(kit))
    with multiprocessing.Pool(4) as pool:
        for field in fields:
            res = pool.map(one, [(field, seed, S) for seed in range(rows)])
            entered = [r for r in res if r is not None]
            locked = [r for r in entered if r[0] == 'locked']
            bad = [r for r in entered if r[0] == 'bad']
            good = [r for r in entered if r[0] not in ('locked', 'bad') and r[0] > 0]
            runs = sum(r[0] for r in good)
            fives = sum(r[1] for r in good)
            if runs:
                m = fives / runs
                # standard error from the spread of the rows' own totals (ratio estimator)
                var = sum((r[1] - m * r[0]) ** 2 for r in good) / max(len(good) - 1, 1)
                se = (var * len(good)) ** 0.5 / runs
                print('%-8s rows %d, entered by sample 100: %d, locked: %d, gaps other than 3 and 5 after entry: %d; '
                      'runs %d, mean run %.4f, standard error %.4f' % (field, rows, len(entered), len(locked), len(bad), runs, m, se))
            else:
                print('%-8s rows %d, entered by sample 100: %d, locked: %d, other gaps: %d; no runs' % (field, rows, len(entered), len(locked), len(bad)))
            sys.stdout.flush()


if __name__ == '__main__':
    main()
