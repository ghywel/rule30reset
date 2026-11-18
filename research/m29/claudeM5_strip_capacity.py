#!/usr/bin/env python3
"""Pull M29, M33's test 1: how many inverse layers does the converged edge band reset?

The band. In the kit's coordinates (bit 0 the edge) the top w cells of a row evolve by v -> 4v xor (2v or v) mod 2^w
(Rule30FourLeftSides). The limit cycle at width w is found from v = 1 (and checked unique over random odd starts).
Its words are read with the edge as the top bit, as `top` in research/r2/claudeM5_r8_replay.py.

The scan. S1's free-register scan (`closes`), run on sets of joint states instead of register paths. At cell i the
joint state is, for each layer d, the pair (P_d(i - 1), P_d(i)) of its parent's cells; layer 1 reads the band, layer
d reads P_(d-1)(i). The registers (P_d(-1), P_d(0)) are free, so at cell 1 each layer has exactly three states
(0, x), (0, not x), (1, not x), with x the cell it reads at 0: the scan starts there with 3^K joint states and merges
equal ones as it goes. Layer d fails if some state makes P_d(j) = 1 for a cell j >= w - d (the rule of `closes`).
K(w) = the largest K with no failing layer <= K, over every word of the cycle (capped at --kmax).
Also recorded: for each word, the cell (counted from the edge) by which layers 1 .. d have merged over all registers.

Controls: the first failing layer agrees with M31's path-by-path `fails_by_layer` on every cycle word at widths 20,
24 and 32 (four layers). Widths 32, 48, 64, 96 and 128 are the frozen test (M33); --all adds every width in between.
Prediction (M33): K(w) grows linearly, about one layer per 10-14 cells, with 7 <= K(96) <= 10. Kill: K(w) stops
growing between widths 64 and 128.
Usage: claudeM5_strip_capacity.py OUTFILE [--kmax 15] [--all]
"""
import argparse, json, os, random, sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from claudeM5_cover_layers import fails_by_layer  # noqa: E402

EXTRA = 8


def bandmap(v, M):
    return ((v << 2) ^ ((v << 1) | v)) & M


def cycle(w, starts=40, seed=20261118):
    M = (1 << w) - 1
    v = 1
    for _ in range(40 * w + 400):
        v = bandmap(v, M)
    cyc = [v]
    while True:
        u = bandmap(cyc[-1], M)
        if u == cyc[0]:
            break
        cyc.append(u)
    rnd = random.Random(seed)
    others = 0
    for _ in range(starts):
        u = rnd.getrandbits(w) | 1
        for _ in range(40 * w + 400):
            u = bandmap(u, M)
        others += u not in set(cyc)
    rev = lambda x: int(format(x, '0%db' % w)[::-1], 2)
    return sorted(rev(c) for c in cyc), others


def scan(word, w, K):
    """First failing layer (K + 1 if none) and merge cells, by the joint-state subset scan."""
    n = w + EXTRA
    bit = lambda i: (word >> i) & 1 if i < w else 0
    # joint states at cell 1: layer bits (2d: P_d(i - 1), 2d + 1: P_d(i)), d = 0 .. K - 1
    states = np.zeros(1, dtype=np.int64)
    xs = np.array([bit(0)], dtype=np.int64)          # the cell each partial state's next layer reads at cell 0
    for d in range(K):
        opts = []
        for (a, b_flip) in ((0, 0), (0, 1), (1, 1)):  # (0, x), (0, not x), (1, not x)
            b = xs ^ b_flip
            opts.append((states | (a << (2 * d)) | (b << (2 * d + 1)), np.full_like(xs, a)))
        states = np.concatenate([o[0] for o in opts])
        xs = np.concatenate([o[1] for o in opts])      # layer d + 1 reads P_d(0) = a
    states = np.unique(states)
    first_fail = K + 1
    merged = [None] * K
    for i in range(1, n):
        for d in range(K):
            if merged[d] is None:
                mask = (1 << (2 * d + 2)) - 1
                if len(np.unique(states & mask)) == 1:
                    merged[d] = w - i
        x = bit(i)
        new = np.zeros_like(states)
        inp = np.full_like(states, x)
        for d in range(K):
            prev = (states >> (2 * d)) & 1
            cur = (states >> (2 * d + 1)) & 1
            nb = inp ^ (cur | prev)
            if i + 1 >= w - (d + 1) and d + 1 < first_fail and nb.any():
                first_fail = d + 1
            new |= (cur << (2 * d)) | (nb << (2 * d + 1))
            inp = cur
        states = np.unique(new)
    return first_fail, merged


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--kmax', type=int, default=15)
    ap.add_argument('--all', action='store_true')
    a = ap.parse_args()
    res = {'controls': {}, 'by_width': {}}
    ok = True
    for w in (20, 24, 32):
        words, _ = cycle(w)
        for p in words:
            f = fails_by_layer(p, w)
            ref = next((d for d in range(1, 5) if f[d]), 5)
            mine, _ = scan(p, w, 4)
            ok &= ref == mine
        res['controls'][w] = {'words': len(words)}
    res['controls_ok'] = ok
    print('controls', ok, flush=True)
    widths = list(range(20, 129)) if a.all else [32, 48, 64, 96, 128]
    prevK = 0
    for w in widths:
        words, others = cycle(w)
        kcap = min(a.kmax, prevK + 3) if a.all else a.kmax
        per = []
        for p in words:
            ff, merged = scan(p, w, kcap)
            per.append({'first_failing_layer': ff, 'merged_from_edge': merged})
        Kw = min(r['first_failing_layer'] for r in per) - 1
        res['by_width'][w] = {'cycle_words': len(words), 'random_starts_off_cycle': others, 'K': Kw,
                              'capped': Kw == kcap, 'cap': kcap, 'words': per}
        prevK = Kw
        print(json.dumps({'w': w, 'period': len(words), 'off_cycle': others, 'K': Kw, 'capped': Kw == kcap}),
              flush=True)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)


if __name__ == '__main__':
    main()
