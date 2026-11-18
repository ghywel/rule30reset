#!/usr/bin/env python3
"""claudeM5's carrying read of R23 (f(3) = 31) and R25 (f(4) <= 72), written without reusing gptM5's code.

The seed-anchored cover (R23): for seeds of width >= 8, start from all 128 top-eight-bit words at age 0; keep the
width at 8 for two ticks (the top w cells of F(row) depend only on the top w cells of row); from age 2 grow the
width by one cell per tick, keeping both values of the next interior bit. At age a the width is a + 6. Each step is
computed here with F on padded integer rows and checked to be independent of the padding (as in `cover` of
research/r2/claudeM5_r8_replay.py), not with gptM5's edge formula R.

The scan: `fails_by_layer` of research/m29/claudeM5_cover_layers.py (claudeM5's rewrite of S1's register scan,
matched to `closes` in M31) gives the failing register branches at each layer. k-tick closure of a word is no failure
at layers 1 .. k.
The narrow seeds (1 .. 127): every one of the 2^k wall histories at age a, by `histories` of the R8 replay (finite
parents checked by applying F).

Reported, for (k, a) in (3, 30), (3, 31), (4, 71), (4, 72): width, words, failing words and branches at layers
<= k, and the narrow seeds with an unclosed k-tick history. R23/R25 claim: age 31, 653 words of width 37, no failure;
age 72, 27,004 words of width 78, no failure; 12 failing words at 71; every narrow seed closed at 31 and 72.
Also: seed 617 at age 30 fails three ticks on wall heads 000, and seed 7815 at age 58 fails four ticks (M30, R23).
Usage: claudeM5_seed_cover_read.py OUTFILE [--procs 8]
"""
import argparse, json, multiprocessing, os, random, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'r2'))
sys.path.insert(0, HERE)
from claudeM5_r8_replay import F, top, histories  # noqa: E402
from claudeM5_cover_layers import fails_by_layer   # noqa: E402

PAD = 9


def step(words, w, grow, rnd):
    """One tick of the band: fixed width (grow False) or width w + 1 with a free interior bit (grow True)."""
    out = set()
    for p in words:
        for b in ((0, 1) if grow else (None,)):
            base = ((p << 1) | b) if grow else p
            res = set()
            for pad in (0, (1 << PAD) - 1, rnd.getrandbits(PAD)):
                res.add(top(F((base << PAD) | pad), w + (1 if grow else 0)))
            assert len(res) == 1, 'band step depends on the padding'
            out |= res
    return out


def seed_cover(age, rnd):
    S, w = {p for p in range(1 << 7, 1 << 8)}, 8
    for t in range(age):
        if t < 2:
            S = step(S, w, False, rnd)
        else:
            S, w = step(S, w, True, rnd), w + 1
    return S, w


def scan(job):
    p, w = job
    return fails_by_layer(p, w)


def narrow(age, k):
    bad = []
    for y in range(1, 1 << 7):
        r = y
        for _ in range(age):
            r = F(r)
        if any(q is None for _, q in histories(r, k)):
            bad.append(y)
    return bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--procs', type=int, default=8)
    a = ap.parse_args()
    rnd = random.Random(20261118)
    rows = []
    with multiprocessing.Pool(a.procs) as pool:
        for k, age in ((3, 30), (3, 31), (4, 71), (4, 72)):
            S, w = seed_cover(age, rnd)
            res = pool.map(scan, [(p, w) for p in sorted(S)], chunksize=64)
            fail_words = sum(1 for f in res if any(f[1:k + 1]))
            branches = [sum(f[d] for f in res) for d in range(1, 5)]
            row = {'k': k, 'age': age, 'width': w, 'words': len(S), 'failing_words': fail_words,
                   'failing_branches_by_layer': branches, 'passes': fail_words == 0,
                   'narrow_seeds_unclosed': narrow(age, k)}
            rows.append(row)
            print(json.dumps(row), flush=True)
    r617 = 617
    for _ in range(30):
        r617 = F(r617)
    h617 = [hs for hs, q in histories(r617, 3) if q is None]
    r7815 = 7815
    for _ in range(58):
        r7815 = F(r7815)
    h7815 = [hs for hs, q in histories(r7815, 4) if q is None]
    res = {'rows': rows, 'seed_617_age_30_unclosed_heads': h617, 'seed_7815_age_58_unclosed_heads': h7815,
           'R23_claim_holds': rows[1]['passes'] and rows[1]['words'] == 653 and rows[1]['width'] == 37
           and not rows[1]['narrow_seeds_unclosed'] and bool(h617),
           'R25_claim_holds': rows[3]['passes'] and rows[3]['words'] == 27004 and rows[3]['width'] == 78
           and not rows[3]['narrow_seeds_unclosed'] and rows[2]['failing_words'] == 12}
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: res[k] for k in res if k != 'rows'}))


if __name__ == '__main__':
    main()
