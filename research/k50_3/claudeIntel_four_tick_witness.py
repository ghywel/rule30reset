"""Physical search for four-tick failures beside a prescribed wall (claudeIntel, N27).

A sample is a seed with its leftmost black at -m and a wall tape. The driven half is evolved
to age t with the literal rule. Every k-th predecessor is then exactly determined, site by
site westward from the wall, by its 2k free bits at sites -1 and 0 (the predecessor's own
wall bits are free, as in S6, S23 and I267). All 4^k such registers are tried. A failure is
a register whose k-th predecessor is not white west of f+k or not black at f+k, where f is
the image's left edge. Nothing here is relaxed: a failure is a physical witness.

Usage: python -I claudeIntel_four_tick_witness.py AGE M SAMPLES [SEED] [LAYERS]
       python -I claudeIntel_four_tick_witness.py verify data/claudeIntel-four-tick-witnesses.json
"""
import json
import sys
import time

import numpy as np


def evolve(seeds, walls, m, age):
    """seeds: (n, m) uint8, column j = site -m+j; walls: (n, age+1). Rows over sites -(m+age)..0."""
    n = len(seeds)
    width = m + age + 1
    row = np.zeros((n, width), dtype=np.uint8)          # column c = site c - (m+age)
    row[:, age:age + m] = seeds
    row[:, -1] = walls[:, 0]
    for t in range(age):
        left = np.zeros_like(row)
        left[:, 1:] = row[:, :-1]
        right = np.zeros_like(row)
        right[:, :-1] = row[:, 1:]
        new = left ^ (row | right)
        new[:, -1] = walls[:, t + 1]
        row = new
    return row


def failures(row, m, age, layers):
    """For each sample, the registers (int) whose layers-th predecessor misses the exact edge."""
    n, width = row.shape
    regs = np.arange(1 << (2 * layers), dtype=np.int64)
    R = len(regs)
    # cur[k]: layer k at site p; nxt[k]: layer k at site p+1. Start at p = -1 (column width-2).
    cur = [np.broadcast_to(((regs >> (2 * k)) & 1).astype(np.uint8), (n, R)).copy() for k in range(layers)]
    nxt = [np.broadcast_to(((regs >> (2 * k + 1)) & 1).astype(np.uint8), (n, R)).copy() for k in range(layers)]
    edge_col = 0                                          # site f = -(m+age) is column 0
    deep = {}
    for col in range(width - 2, edge_col - 1, -1):        # image at site p (column col) -> cells at p-1
        y = np.broadcast_to(row[:, col][:, None], (n, R))
        above = [y] + cur[:-1]
        new = [above[k] ^ (cur[k] | nxt[k]) for k in range(layers)]
        nxt, cur = cur, new
        if col - 1 <= layers:
            deep[col - 1] = cur[layers - 1]
    ok = deep[layers] == 1
    for c in range(0, layers):
        ok &= deep[c] == 0
    for k in range(layers):
        ok &= (cur[k] == 0) & (nxt[k] == 0)               # state at f-1 all zero, so white beyond
    return ~ok


def search(age, m, samples, seed=0, layers=4, chunk=2048):
    rng = np.random.default_rng(seed)
    found, done, start = [], 0, time.time()
    while done < samples:
        n = min(chunk, samples - done)
        seeds = rng.integers(0, 2, (n, m), dtype=np.uint8)
        seeds[:, 0] = 1
        walls = rng.integers(0, 2, (n, age + 1), dtype=np.uint8)
        row = evolve(seeds, walls, m, age)
        bad = failures(row, m, age, layers)
        for i in np.flatnonzero(bad.any(axis=1)):
            regs = np.flatnonzero(bad[i]).tolist()
            found.append({"m": m, "age": age, "seed": "".join(map(str, seeds[i])),
                          "wall": "".join(map(str, walls[i])), "registers": regs[:8], "count": len(regs)})
        done += n
    return found, time.time() - start


def verify(witness, layers=4, far=400):
    """Scalar re-check of one witness with dictionaries and the literal rule (no numpy)."""
    rule = lambda l, c, r: (30 >> (4 * l + 2 * c + r)) & 1
    m, age = witness["m"], witness["age"]
    seed = [int(ch) for ch in witness["seed"]]
    wall = [int(ch) for ch in witness["wall"]]
    row = {p: 0 for p in range(-far, 0)}
    for j, b in enumerate(seed):
        row[-m + j] = b
    for t in range(age):
        row = {p: rule(row.get(p - 1, 0), row[p], wall[t] if p + 1 == 0 else row[p + 1]) for p in range(-far, 0)}
    f = -m - age
    assert row[f] == 1 and all(row[p] == 0 for p in range(-far, f))
    results = []
    for reg in witness["registers"]:
        preds, above = [], row
        for k in range(layers):
            z = {-1: (reg >> (2 * k)) & 1, 0: (reg >> (2 * k + 1)) & 1}
            for p in range(-1, -far, -1):        # z(p-1) from the equation at p
                z[p - 1] = above[p] ^ (z[p] | z[p + 1])
            for p in range(-far + 1, 0):          # forward check at every negative site
                assert rule(z[p - 1], z[p], z[p + 1]) == above[p]
            preds.append(z)
            above = z
        last = preds[-1]
        blacks_west = [p for p in range(-far, f + layers) if last[p] == 1]
        results.append({"register": reg, "edgeBlack": last[f + layers],
                        "blackWestOfEdge": len(blacks_west), "westmostBlack": min(blacks_west) if blacks_west else None,
                        "farTail": "".join(str(last[p]) for p in range(-far, -far + 24))})
    return f, results



if __name__ == "__main__":
    if sys.argv[1] == "verify":
        for label, w in json.load(open(sys.argv[2])).items():
            wit = {"m": w["m"], "age": w["age"], "seed": w["seed"], "wall": w["wallTapeBitT"], "registers": [w["register"]]}
            f, res = verify(wit)
            print(label, json.dumps({"edge": f, "checked": res}))
        sys.exit()
    age, m, samples = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])
    seed = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    layers = int(sys.argv[5]) if len(sys.argv) > 5 else 4
    found, secs = search(age, m, samples, seed, layers)
    print(json.dumps({"age": age, "m": m, "layers": layers, "samples": samples, "seconds": round(secs, 1),
                      "failingSamples": len(found), "first": found[:3]}))
