#!/usr/bin/env python3
"""Pull M29 (M36): is the edge band's capacity the convergence time of post-cut bands?

The reduction (PROOF-SKETCH, M36). A row r has an unclosed k-tick history exactly when r = F^j(B) for some j <= k and
some row B with an infinite black tail (the first infinite ancestor on the history); F(B) is finite, since F turns a
black tail white. Write P_w for the post-cut words: band words u of width w (edge black) that have a black-tailed
band preimage, i.e. some incoming register makes the one-layer inverse recursion over u end in a state other than
00. If r has age a >= g(w), its top w cells are on the cycle C_w; they equal R^(j-1)(u) with u = top_w(F(B)) in P_w,
R the band map at fixed width. So if phi(w) = min over u in P_w of T_w(u) (the number of R-steps to reach C_w) is at
least k, every row of age >= max(g(w), w + k) closes k ticks. The layers drop out: only the band map, C_w and P_w
remain.

Test, exhaustive over all 2^(w-1) words of width w = 20 .. 26 (kit coordinates, bit 0 the edge):
  - C_w from v = 1, and every word's transient T_w (checked finite, so C_w is the only cycle);
  - P_w by the one-layer recursion read from the deepest cell to the edge, with all four registers;
  - phi(w), compared with the strip capacity K(w) of M34 (2 at 20-24, 3 at 25-26);
  - for the minimising words, the error edge e(s): the shallowest wheel at which R^s(u) differs from the cycle orbit
    it joins, s = 0 .. T. The largest one-tick advance of e measures the healing speed the uniform step must bound.
Prediction (written before the run): phi(w) = K(w) at every tested width (60%); e(0) <= 19 for every minimiser (this
follows from K(20) >= 1); some minimiser's error edge advances by at least 5 wheels in one tick.
Usage: claudeM5_postcut.py OUTFILE [--w0 20] [--w1 26]
"""
import argparse, json
import numpy as np


def cycle_of(w):
    M = (1 << w) - 1
    v = 1
    for _ in range(40 * w + 400):
        v = ((v << 2) ^ ((v << 1) | v)) & M
    cyc = [v]
    while True:
        u = ((cyc[-1] << 2) ^ ((cyc[-1] << 1) | cyc[-1])) & M
        if u == cyc[0]:
            return cyc
        cyc.append(u)


def run(w):
    M = np.uint64((1 << w) - 1)
    V = (np.arange(1 << (w - 1), dtype=np.uint64) << np.uint64(1)) | np.uint64(1)   # odd: the edge cell is black
    cyc = cycle_of(w)
    C = np.array(sorted(cyc), dtype=np.uint64)
    # transients
    T = np.full(V.shape, -1, dtype=np.int32)
    X = V.copy()
    for s in range(0, 8 * w + 200):
        hit = (T < 0) & np.isin(X, C)
        T[hit] = s
        if (T >= 0).all():
            break
        X = ((X << np.uint64(2)) ^ ((X << np.uint64(1)) | X)) & M
    all_reach = bool((T >= 0).all())
    # post-cut words: some register leaves the one-layer recursion off 00 after the edge cell
    post = np.zeros(V.shape, dtype=bool)
    for pm1 in (0, 1):
        for p0 in (0, 1):
            p = np.full(V.shape, pm1, dtype=np.uint8)
            c = np.full(V.shape, p0, dtype=np.uint8)
            for j in range(w - 1, -1, -1):            # deepest cell first, the edge (bit 0) last
                x = ((V >> np.uint64(j)) & np.uint64(1)).astype(np.uint8)
                p, c = c, x ^ (c | p)
            post |= (p | c) != 0
    Tp = T[post]
    phi = int(Tp.min())
    mins = V[post][Tp == phi]
    # error-edge trajectories of the minimisers
    Ml = (1 << w) - 1
    nxt = lambda v: ((v << 2) ^ ((v << 1) | v)) & Ml
    order = {cyc[i]: i for i in range(len(cyc))}
    traj, max_jump = [], 0
    for u in [int(x) for x in mins[:2000]]:
        xs = [u]
        for _ in range(phi):
            xs.append(nxt(xs[-1]))
        land = order[xs[-1]]
        ys = [cyc[(land - phi + s) % len(cyc)] for s in range(phi + 1)]
        e = []
        for xv, yv in zip(xs, ys):
            d = xv ^ yv
            e.append((d & -d).bit_length() - 1 if d else w)
        traj.append(e)
        max_jump = max([max_jump] + [b - a for a, b in zip(e, e[1:])])
    return {'w': w, 'cycle_period': len(cyc), 'all_words_reach_cycle': all_reach, 'max_transient': int(T.max()),
            'post_cut_words': int(post.sum()), 'phi': phi, 'minimisers': int(len(mins)),
            'max_e0': max(t[0] for t in traj), 'max_one_tick_advance': max_jump,
            'example_minimiser': int(mins[0]), 'example_error_edges': traj[0]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--w0', type=int, default=20)
    ap.add_argument('--w1', type=int, default=26)
    a = ap.parse_args()
    K = {20: 2, 21: 2, 22: 2, 23: 2, 24: 2, 25: 3, 26: 3, 27: 3, 28: 3}
    rows = []
    for w in range(a.w0, a.w1 + 1):
        r = run(w)
        r['K_M34'] = K.get(w)
        r['phi_equals_K'] = r['phi'] == K.get(w)
        rows.append(r)
        print(json.dumps(r), flush=True)
    with open(a.outfile, 'w') as fh:
        json.dump(rows, fh, indent=1)


if __name__ == '__main__':
    main()
