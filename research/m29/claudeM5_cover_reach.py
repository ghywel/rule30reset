#!/usr/bin/env python3
"""Pull M29 (M31): which words of S1's cover S(a) do narrow seeds actually reach at age a?

For every seed 1 <= y < 2^B, the top a - 6 cells of F^a(y) are compared with the cover S(a) of
research/r2/claudeM5_r8_replay.py and with its words that fail the four-layer scan (`closes`). A band outside S(a)
would contradict the cover (control).
Usage: claudeM5_cover_reach.py OUTFILE [--B 15] [--ages 59,70,79]
"""
import argparse, json, os, random, sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r2'))
from claudeM5_r8_replay import cover, closes, F, top  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--B', type=int, default=15)
    ap.add_argument('--ages', default='59,70,79')
    a = ap.parse_args()
    rnd = random.Random(20261118)
    res = {'B': a.B, 'by_age': []}
    for age in [int(x) for x in a.ages.split(',')]:
        S, w = cover(age, rnd)
        bad = {p for p in S if closes((p, w))}
        reached = set()
        for y in range(1, 1 << a.B):
            r = y
            for _ in range(age):
                r = F(r)
            reached.add(top(r, w))
        row = {'age': age, 'width': w, 'cover_words': len(S), 'failing_words': len(bad),
               'reached_cover_words': len(reached & S), 'reached_failing_words': len(reached & bad),
               'reached_outside_cover': len(reached - S)}
        res['by_age'].append(row)
        print(json.dumps(row), flush=True)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)


if __name__ == '__main__':
    main()
