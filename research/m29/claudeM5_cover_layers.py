#!/usr/bin/env python3
"""Pull M29: at which inverse layer do the cover scan's failures occur? (claudeM5, after the M30 scan; see M31.)

The scan of research/r2/claudeM5_r8_replay.py (`closes`) gives each word of the cover S(a) every incoming register
pair on each of four layers, and stops a branch at the first layer whose parent is not white beyond the edge. Here
the same scan is rewritten to record that layer. A failure at layer d weighs 4^(4 - d) in `closes`; the weighted
total is checked against `closes` for every word (control).

Why it matters. A failure at layer d <= 2 is a register choice under which a one- or two-tick ancestor of an age-a
row would be infinite. For a >= 24 the kit proves every two-tick ancestor of an aged row finite
(Rule30AgeTwentyFourInverse, and Rule30AgeEightInverse for one tick), so no real row makes that choice: the branch
is unrealised. Only failures at layers 3 and 4 can be real. If none occurs at age a >= 24, every four-tick history of
every row at age a closes, and by monotonicity in age (M30) f(4) <= a.
Usage: claudeM5_cover_layers.py OUTFILE [--lo 26] [--hi 80]
"""
import argparse, json, os, random, sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r2'))
from claudeM5_r8_replay import cover, closes, EXTRA  # noqa: E402


def fails_by_layer(word, w):
    n = w + EXTRA
    img0 = [(word >> k) & 1 for k in range(w)] + [0] * EXTRA
    out = [0, 0, 0, 0, 0]                                 # out[d]: failing register branches at layer d

    def layer(img, depth):
        for pm1 in (0, 1):
            for p0 in (0, 1):
                P = [pm1, p0]
                for k in range(n):
                    P.append(img[k] ^ (P[k + 1] | P[k]))
                par = P[1:n + 1]
                if not (all(x == 0 for x in par[w - depth:]) and P[n + 1] == 0):
                    out[depth] += 1
                elif depth < 4:
                    layer(par, depth + 1)
    layer(img0, 1)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--lo', type=int, default=26)
    ap.add_argument('--hi', type=int, default=80)
    a = ap.parse_args()
    rnd = random.Random(20261118)
    rows, control_ok = [], True
    for age in range(a.lo, a.hi + 1):
        S, w = cover(age, rnd)
        tot = [0, 0, 0, 0, 0]
        words = [0, 0, 0, 0, 0]
        for p in S:
            f = fails_by_layer(p, w)
            control_ok &= sum(f[d] * 4 ** (4 - d) for d in range(1, 5)) == closes((p, w))
            for d in range(1, 5):
                tot[d] += f[d]
                words[d] += f[d] > 0
        rows.append({'age': age, 'width': w, 'words': len(S),
                     'failing_branches_by_layer': tot[1:], 'words_failing_by_layer': words[1:],
                     'real_candidates': tot[3] + tot[4]})
        print(json.dumps(rows[-1]), flush=True)
    clean = [r['age'] for r in rows if r['real_candidates'] == 0 and r['age'] >= 24]
    res = {'control_weighted_equals_closes': control_ok, 'by_age': rows,
           'least_age_with_failures_only_at_layers_1_2': min(clean) if clean else None,
           'clean_from_there_on': bool(clean) and all(r['real_candidates'] == 0 for r in rows if r['age'] >= min(clean))}
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: res[k] for k in res if k != 'by_age'}))


if __name__ == '__main__':
    main()
