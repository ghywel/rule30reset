#!/usr/bin/env python3
"""Pull M29 (M35): do one-layer resets keep recurring deep in the edge band's limit cycle?

The cycle. The top W cells of a row evolve by v -> 4v xor (2v or v) mod 2^W (bit 0 the edge). From v = 1 (the single
seed) the iteration reaches a cycle; by the kit's Rule30UniversalLeftSide every row with a leftmost black cell shares
the single seed's left-side words through wheel 53,207 up to a time shift, so for W <= 53,207 this one cycle is the
converged band of every row. A layer reads the band from its inner end (deepest cell) to the edge.

One layer. Its register (P(i - 1), P(i)) reads input x as (p, c) -> (c, x xor (c or p)). The four registers coalesce
on known reset words (0, then 3m + 1 ones, then 0, then one bit; G13, P6).
  A. Coalescence length: for every phase word at width W and every start cell i, the number of cells the four
     registers, started free at i, need to coalesce. Reported: the maximum by depth block (cells counted from the edge)
     and overall. Bounded lengths at every depth are what an induction on one-layer resets needs.
  B. The one-layer schedule (R28-R29): layer 1 reads the band from cell 0 with four free registers until they
     coalesce; its common parent from that cell on is the next layer's input, again with four free registers; and so
     on. K1(w) = the number of layers that close, worst phase, for the top w cells. Controls: R29's single-layer
     capacities 2, 3, 4, 6, 6, 9 at widths 25, 62, 81, 91, 96, 128.
Prediction (written before the run): A stays at or below 64 cells at every depth to 4096, with no growth with depth;
K1(4096) >= 200. Kill: the largest coalescence length grows with depth (above 100 somewhere below depth 1000), so
one-layer resets cannot carry an induction and the joint register is essential.
Usage: claudeM5_deep_resets.py OUTFILE [--W 4096]
"""
import argparse, json


def step(s, x):
    p, c = s >> 1, s & 1
    return (c << 1) | (x ^ (c | p))


def limit_cycle(W):
    M = (1 << W) - 1
    v, n = 1, 0
    while True:
        for _ in range(4 * W + 1000):
            v = ((v << 2) ^ ((v << 1) | v)) & M
        n += 4 * W + 1000
        c = [v]
        for _ in range(64):
            c.append(((c[-1] << 2) ^ ((c[-1] << 1) | c[-1])) & M)
        if v in c[1:]:
            per = c[1:].index(v) + 1
            return c[:per], n
        if n > 60 * W + 10000:
            raise RuntimeError('no cycle found')


def bits_from_bottom(v, W, w):
    """The top w cells of the width-W word v (bit 0 the edge), read from the inner end (cell 0) to the edge."""
    return [(v >> (w - 1 - i)) & 1 for i in range(w)]


def coalescence(xs):
    out = []
    n = len(xs)
    for i in range(n):
        S = {0, 1, 2, 3}
        j = i
        while len(S) > 1 and j < n:
            S = {step(s, xs[j]) for s in S}
            j += 1
        out.append(j - i if len(S) == 1 else None)
    return out


def one_layer_schedule(xs, w):
    """Layers closed by the one-layer schedule on the band xs (cell 0 the inner end, cell w - 1 the edge)."""
    inp = xs + [0] * 12
    start, layers = 0, 0
    while True:
        d = layers + 1
        traj = {}
        for s0 in range(4):
            s, P = s0, {}
            for i in range(start, len(inp)):
                s = step(s, inp[i])
                P[i + 1] = s & 1                  # P(i + 1), the parent cell this register emits
            traj[s0] = (s, P)
        ends = {t[0] for t in traj.values()}
        bad = any(P[j] for _, P in traj.values() for j in P if j >= w - d)
        if len(ends) != 1 or 0 not in ends or bad:
            return layers
        # first cell from which all four parents agree
        cells = sorted(traj[0][1])
        agree = None
        for j in cells:
            if all(traj[s0][1][j] == traj[0][1][j] for s0 in range(4)):
                if agree is None:
                    agree = j
            else:
                agree = None
        layers += 1
        # next layer reads this layer's common parent from the coalescence cell on
        nxt = [0] * len(inp)
        for j in cells:
            if j < len(nxt):
                nxt[j] = traj[0][1][j]
        inp, start = nxt, agree
        if start is None or start >= w - d:
            return layers


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--W', type=int, default=4096)
    a = ap.parse_args()
    W = a.W
    cyc, iters = limit_cycle(W)
    res = {'W': W, 'period': len(cyc), 'iterations_to_cycle': iters}
    blocks = {}
    overall = 0
    for v in cyc:
        xs = bits_from_bottom(v, W, W)
        co = coalescence(xs)
        for i, c in enumerate(co):
            if c is None:
                continue
            depth = W - 1 - i                    # cells from the edge
            b = (depth // 256) * 256
            blocks[b] = max(blocks.get(b, 0), c)
            if depth >= 32:
                overall = max(overall, c)
    res['max_coalescence_by_depth_block'] = dict(sorted(blocks.items()))
    res['max_coalescence_below_depth_32'] = overall
    K1 = {}
    for w in (25, 62, 81, 91, 96, 128, 256, 512, 1024, 2048, W):
        if w > W:
            continue
        K1[w] = min(one_layer_schedule(bits_from_bottom(v, W, w), w) for v in cyc)
        print(json.dumps({'w': w, 'K1': K1[w]}), flush=True)
    res['K1_worst_phase'] = K1
    res['controls_R29'] = {25: 2, 62: 3, 81: 4, 91: 6, 96: 6, 128: 9}
    res['controls_ok'] = all(K1[w] == v for w, v in res['controls_R29'].items())
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: res[k] for k in res if k != 'K1_worst_phase'}))


if __name__ == '__main__':
    main()
