#!/usr/bin/env python3
"""Pull M29, first test (frozen in ledger M29): the last age at which some k-tick wall history is unclosed.

Setting: rows beside the fixed white wall, F Y = (Y >> 1) ^ (Y | (Y << 1)), bit i of Y is depth i + 1 (as in
research/r2/claudeM5_r8_replay.py). A k-tick wall history of a row is a choice of head (the depth-1 bit) at each of k
inverse ticks; it is closed when every one of its k ancestors is finite. F adds exactly one cell per tick, so a
finite ancestor's edge is automatically one cell further in per tick.

For every seed 1 <= y < 2^B and every age 0 <= t <= T, the row F^t(y) gets kmin = the least k <= K at which some
k-tick history is unclosed (K + 1 if all K-tick histories are closed). Unclosed at k - 1 implies unclosed at k, so
"some k-tick history of the row is unclosed" is exactly kmin <= k. Reported, for k = 1 .. K:
  - last[k]: the last age with an unclosed k-tick history, overall and for seeds below 2^b, b = 9 .. B;
  - the ages with an unclosed k-tick history, and the narrowest witnesses at last[k].
Prediction (M29): last = 7, 23, 39, 55 for k = 1 .. 4 (f(k) = 16k - 8, so last = 16k - 9).

Engine: all seeds at one age at once, as numpy bit arrays padded past every edge. The parent with head h solves
P(k + 1) = row(k) xor (P(k) or P(k - 1)) outward from P(-1) = 0 (the wall), P(0) = h. Beyond the row's edge the
recursion is P(k + 1) = P(k) or P(k - 1), so one black cell there stays black for ever; with at least two padding
cells the parent is finite exactly when the last padded cell is white.

Controls:
  C1. kmin for random (seed, age) pairs equals the pure-Python value from claudeM5_r8_replay.parents (applies F).
  C2. The width-one seed's least ages with every d-tick history closed: 3, 8, 20, 26, 37, 45 for d = 1 .. 6 (M17).
  C3. Seeds below 2^9, k = 4, ages 26 .. 95: unclosed exactly at 26-49 and 53-55 (M17).
Usage: claudeM5_thresholds.py OUTFILE [--B 12] [--T 100] [--K 6] [--samples 3000]
"""
import argparse, json, os, random, sys
import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r2'))
from claudeM5_r8_replay import F, parents  # noqa: E402  (pure-Python reference, used only by C1)


def to_bits(rows, W):
    nb = (W + 7) // 8
    buf = b''.join(r.to_bytes(nb, 'little') for r in rows)
    return np.unpackbits(np.frombuffer(buf, dtype=np.uint8).reshape(len(rows), nb), axis=1,
                         bitorder='little')[:, :W].copy()


def parents_np(R):
    """Both parents of every row of R (M x W bits, row edges at most W - 3). Returns (P, finite), 2M rows,
    first the h = 0 parents, then the h = 1 parents."""
    M, W = R.shape
    RR = np.concatenate([R, R])
    P = np.zeros((2 * M, W), dtype=np.uint8)
    P[M:, 0] = 1
    prev = np.zeros(2 * M, dtype=np.uint8)
    cur = P[:, 0].copy()
    for k in range(W - 1):
        nxt = RR[:, k] ^ (cur | prev)
        P[:, k + 1] = nxt
        prev, cur = cur, nxt
    return P, P[:, W - 1] == 0


def kmin_np(rows, W, K):
    R = to_bits(rows, W)
    n = len(rows)
    kmin = np.full(n, K + 1, dtype=np.int16)
    org = np.arange(n)
    for d in range(1, K + 1):
        if len(org) == 0:
            break
        P, fin = parents_np(R)
        org2 = np.concatenate([org, org])
        bad = np.unique(org2[~fin])
        kmin[bad[kmin[bad] > K]] = d
        keep = fin & (kmin[org2] > K)
        R, org = P[keep], org2[keep]
    return kmin


def kmin_py(row, K):
    layer = [row]
    for d in range(1, K + 1):
        nxt = []
        for r in layer:
            for _, p in parents(r):
                if p is None:
                    return d
                nxt.append(p)
        layer = nxt
    return K + 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--B', type=int, default=12)
    ap.add_argument('--T', type=int, default=100)
    ap.add_argument('--K', type=int, default=6)
    ap.add_argument('--samples', type=int, default=3000)
    a = ap.parse_args()
    B, T, K = a.B, a.T, a.K
    W = B + T + 4
    seeds = list(range(1, 1 << B))
    rows = list(seeds)
    KM = np.zeros((T + 1, len(seeds)), dtype=np.int16)      # KM[t, y - 1]
    for t in range(T + 1):
        KM[t] = kmin_np(rows, W, K)
        rows = [F(r) for r in rows]

    res = {'B': B, 'T': T, 'K': K, 'W': W, 'seeds': len(seeds)}
    seed_arr = np.array(seeds)
    last, ages, witnesses, by_width = {}, {}, {}, {}
    for k in range(1, K + 1):
        un = KM <= k                                          # un[t, i]: some k-tick history unclosed
        ts = [t for t in range(T + 1) if un[t].any()]
        last[k] = max(ts) if ts else None
        runs, s = [], None
        for t in ts:                                          # compress ages into runs
            if s is None or t != runs[-1][1] + 1:
                runs.append([t, t])
            else:
                runs[-1][1] = t
            s = t
        ages[k] = ['%d-%d' % (u, v) if u != v else str(u) for u, v in runs]
        if last[k] is not None:
            w = sorted((int(x) for x in seed_arr[un[last[k]]]), key=lambda y: (y.bit_length(), y))
            witnesses[k] = {'count': len(w), 'narrowest': w[:8]}
        by_width[k] = {}
        for b in range(9, B + 1):
            m = seed_arr < (1 << b)
            tb = [t for t in range(T + 1) if un[t][m].any()]
            by_width[k][b] = max(tb) if tb else None
    res['last_unclosed_age'] = last
    res['last_unclosed_age_by_seed_bits'] = by_width
    res['unclosed_ages'] = ages
    res['witnesses_at_last_age'] = witnesses
    res['prediction_16k_minus_9'] = {k: 16 * k - 9 for k in range(1, K + 1)}

    rnd = random.Random(20261118)
    bad = 0
    for _ in range(a.samples):
        y, t = rnd.randrange(1, 1 << B), rnd.randrange(0, T + 1)
        r = y
        for _ in range(t):
            r = F(r)
        bad += int(kmin_py(r, K) != int(KM[t, y - 1]))
    res['C1_samples'], res['C1_mismatches'] = a.samples, bad
    res['C2_width_one_least_closed_age'] = {d: next((t for t in range(T + 1) if KM[t, 0] > d), None)
                                            for d in range(1, K + 1)}
    res['C2_expected'] = {1: 3, 2: 8, 3: 20, 4: 26, 5: 37, 6: 45}
    m9 = seed_arr < (1 << 9)
    c3 = [t for t in range(26, min(T, 95) + 1) if (KM[t][m9] <= 4).any()]
    res['C3_ages_k4_seeds_below_2_9'] = c3
    res['C3_ok'] = c3 == list(range(26, 50)) + [53, 54, 55]
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
