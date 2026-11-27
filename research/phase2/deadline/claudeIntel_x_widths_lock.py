"""K92.3, claudeIntel N32: the fair-drive escape rate from X through wider windows, lock entry counted as an exit.

At width V >= 24 the states are all V-cell windows whose first 24 cells lie in X (component 519 of R65's
width-24 graph). Each white sample evolves window | east << V two ticks (wall bits 0 then 1) with the
exterior pair `east` uniform on four values, and the walk is killed when the first 24 cells leave X.
The leading eigenvalue of this substochastic chain gives the escape rate. V = 24 is the rate of
claudeIntel_x_hazard.py; larger V lets the inner cells carry more of the eastern history.

At V >= 30 a successor whose first 30 cells are a phase of the kit's width-30 seven-lock (tables.txt tag 7)
is also killed: the census counts lock entry as a certificate, and at V >= 30 the lock is closed under every
exterior pair, so without this the rate would be zero.

Usage: python -I claudeIntel_x_widths_lock.py W24.scc tables.txt VMIN VMAX out.json
"""
import json
import math
import struct
import sys

import numpy as np

W = 24
MASK24 = (1 << W) - 1


def load_component(path, least):
    raw = open(path, "rb").read()
    assert raw[:8] == b"K50SCC1\n" and struct.unpack_from("<I", raw, 8)[0] == W
    off = 12
    while off < len(raw):
        lo, count = struct.unpack_from("<II", raw, off)
        if lo == least:
            return np.sort(np.frombuffer(raw, dtype="<u4", count=count, offset=off + 8).astype(np.uint64))
        off += 8 + 4 * count
    raise KeyError(least)


def tick(row, wall):
    return ((row << np.uint64(1)) | np.uint64(wall)) ^ (row | (row >> np.uint64(1)))


def rate(xs, v, iters, tail, lock):
    j = v - W
    n = len(xs) * (1 << j)
    i = np.arange(n, dtype=np.uint64)
    words = xs[i >> np.uint64(j)] | ((i & np.uint64((1 << j) - 1)) << np.uint64(W))
    succ = np.empty((4, n), dtype=np.int64)
    for e in range(4):
        d = tick(tick(words | (np.uint64(e) << np.uint64(v)), 0), 1) & np.uint64((1 << v) - 1)
        low = d & np.uint64(MASK24)
        pos = np.searchsorted(xs, low)
        pos = np.minimum(pos, len(xs) - 1)
        ok = xs[pos] == low
        if v >= 30:
            ok &= ~np.isin(d & np.uint64((1 << 30) - 1), lock)
        idx = (pos.astype(np.uint64) << np.uint64(j)) | (d >> np.uint64(W))
        succ[e] = np.where(ok, idx.astype(np.int64), -1)
    flat = succ.ravel()
    ok = flat >= 0
    targets = flat[ok]
    src = np.tile(np.arange(n), 4)[ok]
    vec = np.full(n, 1.0 / n)
    logs = []
    for _ in range(iters):
        nv = np.bincount(targets, weights=vec[src] / 4, minlength=n)
        r = nv.sum()
        logs.append(math.log(r))
        vec = nv / r
    lam = -sum(logs[-tail:]) / tail
    spread = max(logs[-tail:]) - min(logs[-tail:])
    return {"width": v, "states": int(n), "escape_rate_per_sample": lam, "log2_over_rate": math.log(2) / lam,
            "per_step_log_spread_in_tail": spread}


def main():
    scc, tables, vmin, vmax, outp = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
    lock = np.array(sorted(int(r.split()[3]) for r in open(tables, encoding="ascii") if r.split()[:2] == ["7", "30"]),
                    dtype=np.uint64)
    assert len(lock) == 66
    xs = load_component(scc, 519)
    assert len(xs) == 15826
    rows = []
    for v in range(vmin, vmax + 1):
        iters = 30000 if v <= 27 else 12000
        res = rate(xs, v, iters, iters // 2, lock)
        rows.append(res)
        print(json.dumps(res), flush=True)
        open(outp, "w", encoding="ascii", newline="\n").write(json.dumps(rows, indent=1) + "\n")


if __name__ == "__main__":
    main()
