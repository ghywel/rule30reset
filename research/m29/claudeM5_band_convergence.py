#!/usr/bin/env python3
"""Pull M29, M33's test 2: by what age is the top of every row on the edge band's limit cycle?

S1's cover S(a) (research/r2/claudeM5_r8_replay.py, `cover`: C20 at age 26, one free interior bit per tick) holds the
top a - 6 cells of every nonzero finite row at age a >= 26. The top w cells evolve on their own (the band map), so
the windows T_w(a) = {top w cells of p : p in S(a)} satisfy T_w(a + 1) = band map of T_w(a), and once inside the limit
cycle they stay there. g(w) = the first age a with T_w(a) inside the cycle at width w. Then every row of age >= g(w)
has its top w cells on the cycle.

Computed for w = 20 .. 100: S(w + 6) at full width w, then the band map at fixed width until the set is inside the
cycle. Control: g(20) <= 26, since C20 is the cycle at width 20 (M33). Cross-check: at a few (w, a), T_w(a) taken
directly from S(a) agrees with the iterated set.
Prediction (M33): g(20) <= 26, and g(w) grows about linearly with slope 1-2.
Usage: claudeM5_band_convergence.py OUTFILE [--wmax 100]
"""
import argparse, json, os, random, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'r2'))
sys.path.insert(0, HERE)
from claudeM5_r8_replay import F, top, C20  # noqa: E402
from claudeM5_strip_capacity import cycle  # noqa: E402


def grow(S, w):
    out = set()
    for p in S:
        out.add(top(F((p << 1) << 9), w + 1))
        out.add(top(F(((p << 1) | 1) << 9), w + 1))
    return out


def fixed(T, w):
    return {top(F(p << 9), w) for p in T}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--wmax', type=int, default=100)
    a = ap.parse_args()
    S, w, age = set(C20), 20, 26
    full = {}                                         # width -> S at age width + 6
    while w <= a.wmax:
        full[w] = set(S)
        S, w, age = grow(S, w), w + 1, age + 1
    res = {'g': {}, 'cross_checks': []}
    for w in range(20, a.wmax + 1):
        cyc, _ = cycle(w)
        cyc = set(cyc)
        T, t = set(full[w]), w + 6
        while not T <= cyc:
            T, t = fixed(T, w), t + 1
            if t > 2000:
                t = None
                break
        res['g'][w] = {'g': t, 'cover_words_at_full_width': len(full[w]), 'cycle_period': len(cyc)}
        print(json.dumps({'w': w, 'g': t, 'words': len(full[w]), 'period': len(cyc)}), flush=True)
    # cross-check: windows read straight from S(a) at a few ages
    S, w, age = set(C20), 20, 26
    checks = {(30, 40), (40, 60), (60, 90), (80, 100)}
    T = {}
    while age <= 100:
        for (ww, aa) in checks:
            if aa == age:
                direct = {top(p, ww) for p in S}
                it = set(full[ww])
                for _ in range(aa - (ww + 6)):
                    it = fixed(it, ww)
                res['cross_checks'].append({'w': ww, 'age': aa, 'agree': direct == it})
        S, w, age = grow(S, w), w + 1, age + 1
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res['cross_checks']))


if __name__ == '__main__':
    main()
