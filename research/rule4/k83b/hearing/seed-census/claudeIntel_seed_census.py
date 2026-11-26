"""The largest Galindo terminal census on the actual single seed (claudeIntel, N26).

Galindo's census (kit Rule30TerminalCensus) at terminal width s over N ages has, at each
depth r < s, a list of pairs of ages (t, u) with
  * disjoint endpoints at that depth, and t + r < N, u + r < N;
  * Fork s t u: the singleton rows at ages t and u agree on sites 0, -1, ..., -(s-1)
    and differ at site -s;
  * centre agreement: cell(t+i, 0) = cell(u+i, 0) for 0 < i <= r.
Its total M is the number of pairs over all depths, and the density is M / (s N).

At one depth, the pairable ages fall into classes keyed by the s west cells and the r
later centre cells, and a pair joins the two values of cell -s inside one class. So the
largest number of disjoint pairs at depth r is exactly the sum over classes of
min(n0, n1). This script computes that maximum, hence the largest census density
D(s, N) at every prefix N, for the true seed.

Usage:
  python -I claudeIntel_seed_census.py simulate LOG2N OUTDIR   # rows and centre to 2^LOG2N
  python -I claudeIntel_seed_census.py census OUTDIR SMAX      # densities for s <= SMAX
  python -I claudeIntel_seed_census.py control                 # matching cross-check (networkx)
  python -I claudeIntel_seed_census.py balance OUTDIR          # imbalance of cell -s by class
  python -I claudeIntel_seed_census.py classes                 # exact class counts m_r
"""
import json
import sys
import time
from pathlib import Path

import numpy as np

WEST = 24          # west cells kept per age: sites 0, -1, ..., -WEST


def simulate(log2n, outdir):
    """Singleton Rule 30, bit-packed in 64-bit words; keep west cells 0..-WEST each tick."""
    N = 1 << log2n
    L = 2 * N + 64                       # index k = site + N + 32
    off = N + 32
    words = (L + 63) // 64
    x = np.zeros(words, dtype=np.uint64)
    x[off >> 6] |= np.uint64(1) << np.uint64(off & 63)
    west = np.zeros(N, dtype=np.uint32)
    one, s63 = np.uint64(1), np.uint64(63)
    start = time.time()
    for t in range(N):
        # read sites 0, -1, ..., -WEST: indices off, off-1, ..., off-WEST
        lo = off - WEST
        w0, b0 = lo >> 6, lo & 63
        chunk = int(x[w0]) | (int(x[w0 + 1]) << 64)
        bits = (chunk >> b0) & ((1 << (WEST + 1)) - 1)      # bit i = index lo + i
        # reverse so that bit j = site -j
        v = 0
        for j in range(WEST + 1):
            v |= ((bits >> (WEST - j)) & 1) << j
        west[t] = v
        if t == N - 1:
            break
        # active cells at age t that still matter for ages <= N-1 at sites 0..-WEST
        a = max(off - t, off - WEST - (N - 1 - t)) - 1
        b = min(off + t, off + (N - 1 - t)) + 1
        wa, wb = max(a >> 6, 1), min((b >> 6) + 1, words - 1)
        seg = x[wa - 1:wb + 1]
        cur = seg[1:-1]
        left = (cur << one) | (seg[:-2] >> s63)       # cell k-1
        right = (cur >> one) | (seg[2:] << s63)       # cell k+1
        x[wa:wb] = left ^ (cur | right)
        if t % 65536 == 0 and t:
            print(f"  tick {t}, {time.time() - start:.0f} s", flush=True)
    outdir.mkdir(parents=True, exist_ok=True)
    np.save(outdir / f"west-{log2n}.npy", west)
    print(f"saved {N} ages in {time.time() - start:.0f} s")


def control(T=3000):
    """Independent big-integer simulation of the same cells for T ticks."""
    row = 1 << T                          # bit T + i = site i
    out = []
    for t in range(T):
        out.append(sum(((row >> (T - j)) & 1) << j for j in range(WEST + 1)))
        row = (row << 1) ^ (row | (row >> 1))   # new(i) = old(i-1) xor (old(i) or old(i+1))
    return np.array(out, dtype=np.uint32)


def max_pairs(west, s, r, N):
    """Largest number of disjoint fork pairs at width s and depth r among ages < N."""
    n = N - r
    if n <= 1:
        return 0
    w = west[:N].astype(np.int64)
    c = w & 1
    key = w[:n] & ((1 << s) - 1)
    for i in range(1, r + 1):
        key |= c[i:i + n] << (s + i - 1)
    fork = (w[:n] >> s) & 1
    u, cnt = np.unique(key * 2 + fork, return_counts=True)
    both = (u[:-1] % 2 == 0) & (u[1:] == u[:-1] + 1)
    return int(np.minimum(cnt[:-1][both], cnt[1:][both]).sum())


def census(outdir, smax):
    files = sorted(outdir.glob("west-*.npy"), key=lambda p: int(p.stem.split("-")[1]))
    west = np.load(files[-1])
    top = int(np.log2(len(west)))
    ref = control(3000)
    assert np.array_equal(ref, west[:3000]), "simulation disagrees with the big-integer control"
    centre = "".join(str(int(v & 1)) for v in west[:40])
    assert centre.startswith("1101110011000101100100111"), centre    # OEIS A051023
    result = {"ages": len(west), "control": "first 3000 ages, all 25 west cells, agree", "rows": []}
    for k in range(8, top + 1):
        N = 1 << k
        for s in range(1, smax + 1):
            per = [max_pairs(west, s, r, N) for r in range(s)]
            H = len(np.unique(west[:N] & ((1 << s) - 1)))
            M = sum(per)
            result["rows"].append({"log2N": k, "s": s, "M": M, "density": M / (s * N),
                                   "perDepth": per, "H": H})
        print(f"N=2^{k}: " + " ".join(f"{row['density']:.3f}" for row in result["rows"][-smax:]), flush=True)
    (outdir / f"census-{top}-{smax}.json").write_text(json.dumps(result))
    return result


def matching_control(T=400):
    """Build the census graph from the definitions on an independent big-integer history and
    compare a general maximum matching with max_pairs (needs networkx)."""
    import networkx as nx
    rows, row = [], 1 << T
    for _ in range(T):
        rows.append(row)
        row = (row << 1) ^ (row | (row >> 1))
    cell = lambda t, i: (rows[t] >> (T + i)) & 1
    west = control(T)
    cases = 0
    for N in (40, 90, 160, 300):
        for s in (2, 3, 5, 7):
            for r in range(s):
                G = nx.Graph()
                G.add_nodes_from(range(N - r))
                for t in range(N - r):
                    for u in range(t + 1, N - r):
                        if (all(cell(t, -j) == cell(u, -j) for j in range(s)) and cell(t, -s) != cell(u, -s)
                                and all(cell(t + i, 0) == cell(u + i, 0) for i in range(1, r + 1))):
                            G.add_edge(t, u)
                assert len(nx.max_weight_matching(G, maxcardinality=True)) == max_pairs(west, s, r, N)
                cases += 1
    print(f"max_pairs equals a general maximum matching in all {cases} cases")


def balance(outdir, widths=(6, 8, 10, 12)):
    """Observed sum |n0 - n1| of cell -s over the classes, divided by its fair-coin expectation."""
    from math import comb, pi, sqrt
    west = np.load(sorted(outdir.glob("west-*.npy"), key=lambda p: int(p.stem.split("-")[1]))[-1])
    w = west.astype(np.int64)
    N, c = len(w), w & 1
    cache = {}

    def expect(m):
        if m not in cache:
            cache[m] = sqrt(2 * m / pi) if m > 2000 else sum(comb(m, k) * abs(m - 2 * k) for k in range(m + 1)) / 2**m
        return cache[m]

    out = {}
    for s in widths:
        for r in range(0, s, max(1, s // 4)):
            n = N - r
            key = w[:n] & ((1 << s) - 1)
            for i in range(1, r + 1):
                key |= c[i:i + n] << (s + i - 1)
            bit = (w[:n] >> s) & 1
            _, inv = np.unique(key, return_inverse=True)
            tot = np.bincount(inv)
            n1 = np.bincount(inv, weights=bit).astype(np.int64)
            ratio = np.abs(tot - 2 * n1).sum() / sum(expect(int(m)) for m in tot)
            out[f"{s},{r}"] = {"classes": int(len(tot)), "ratio": round(float(ratio), 3)}
            print(f"s={s} r={r}: {len(tot)} classes, observed/fair-coin imbalance {ratio:.3f}", flush=True)
    (outdir / "balance.json").write_text(json.dumps(out))


def classes(rmax=12):
    """Exact number of (west cells 0..-r, next r centre cells) over all 2^(2r+1) windows."""
    out = []
    for r in range(rmax + 1):
        n = 2 * r + 1
        x = np.arange(1 << n, dtype=np.int64)        # bit k = site -r + k
        key = np.zeros_like(x)
        for j in range(r + 1):
            key |= ((x >> (r - j)) & 1) << j          # west cell -j
        y, mask = x.copy(), (1 << n) - 1
        for i in range(1, r + 1):
            y = ((y << 1) ^ (y | (y >> 1))) & mask   # the centre stays exact for i <= r
            key |= ((y >> r) & 1) << (r + i)
        k = len(np.unique(key))
        out.append(k / 2 ** (r + 1))
        print(f"r={r}: {k} classes over west words of length r+1, m_r = {out[-1]:.4f}", flush=True)
    return out


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "classes":
        classes()
    if cmd == "simulate":
        simulate(int(sys.argv[2]), Path(sys.argv[3]))
    elif cmd == "census":
        census(Path(sys.argv[2]), int(sys.argv[3]))
    elif cmd == "control":
        assert np.array_equal(control(3000)[:2000], control(2000))
        matching_control()
    elif cmd == "balance":
        balance(Path(sys.argv[2]))
