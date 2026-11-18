#!/usr/bin/env python3
"""Pull M29, second test (frozen in ledger M30): S1's own four-tick cover scan at ages below 80.

For each age a, S(a) is the moving outer-band cover of research/r2/claudeM5_r8_replay.py (`cover`): S(26) = C20 (the
kit's band_from_age_twenty_six), and S(a + 1) is the top w + 1 cells of F over every band (p, b), p in S(a), b free.
So S(a) holds the top a - 6 cells of every nonzero finite row at age a. `closes` scans each word of S(a) with every
incoming register pair on each of the four inverse layers (256 per word) and counts the pairs whose history does
not close.

A pass at age a (no unclosed pair) shows that every four-tick history of every row at age a closes. Since the rows
at age a + 1 are rows at age a of other seeds (M30, fact 1), it then holds at every later age: f(4) <= a.

Control: at age 80 the cover has width 74 and 3,657 words, and no pair is unclosed (R8, M17, S1).
Prediction (M30): the first pass lies between 66 and 80. Kill: a first pass at 80 (no slack at four ticks).
Usage: claudeM5_cover_scan.py OUTFILE [--lo 59] [--hi 80] [--procs 8]
"""
import argparse, json, multiprocessing, os, random, sys, time

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r2'))
from claudeM5_r8_replay import cover, closes  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--lo', type=int, default=59)
    ap.add_argument('--hi', type=int, default=80)
    ap.add_argument('--procs', type=int, default=8)
    a = ap.parse_args()
    rnd = random.Random(20261118)
    rows = []
    with multiprocessing.Pool(a.procs) as pool:
        for age in range(a.hi, a.lo - 1, -1):          # the control (age 80) first
            t0 = time.time()
            S, w = cover(age, rnd)
            fails = pool.map(closes, [(p, w) for p in sorted(S)], chunksize=16)
            row = {'age': age, 'width': w, 'words': len(S), 'pairs': 256 * len(S),
                   'unclosed_pairs': sum(fails), 'failing_words': sum(1 for f in fails if f),
                   'passes': sum(fails) == 0, 'seconds': round(time.time() - t0, 1)}
            rows.append(row)
            print(json.dumps(row), flush=True)
    rows.sort(key=lambda r: r['age'])
    passing = [r['age'] for r in rows if r['passes']]
    res = {'by_age': rows, 'control_age_80': next((r for r in rows if r['age'] == 80), None),
           'first_pass': min(passing) if passing else None,
           'passes_from_first_pass_on': bool(passing) and all(r['passes'] for r in rows if r['age'] >= min(passing))}
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: res[k] for k in ('first_pass', 'passes_from_first_pass_on')}))


if __name__ == '__main__':
    main()
