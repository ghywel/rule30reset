"""K92.3, claudeIntel N32: how fast does a fair drive leave X and Y, and does the census decay at that rate?

Part 1 (graph). On R65's width-24 window graph, drive each window of a component with the four exterior
pairs at equal weight. The surviving mass decays at the component's escape rate: the leading eigenvalue
of the substochastic matrix restricted to the component. Computed by power iteration.

Part 2 (census). From gptIntel's final census binary (four uint16 per seed: fate, endpoint sample, first
trap sample, phase), the survival of first trap entry, overall and by support.

Usage: python -I claudeIntel_x_hazard.py W24.scc 24-aligned.bin out.json
Window bit j is site j+1; the white-sample transition evolves window | east << 24 two ticks, with wall bits
0 then 1, and keeps 24 bits. This loader and transition are written afresh (no code shared with I286-I293).
"""
import json
import math
import struct
import sys

import numpy as np

W = 24
MASK = (1 << W) - 1


def load_scc(path):
    raw = open(path, "rb").read()
    assert raw[:8] == b"K50SCC1\n" and struct.unpack_from("<I", raw, 8)[0] == W
    comps, off = {}, 12
    while off < len(raw):
        least, count = struct.unpack_from("<II", raw, off)
        comps[least] = np.frombuffer(raw, dtype="<u4", count=count, offset=off + 8).astype(np.int64)
        off += 8 + 4 * count
    return comps


def tick(row, wall):
    # new site i = site(i-1) XOR (site i OR site(i+1)); bit j of row is site j+1, wall is site 0
    return ((row << 1) | wall) ^ (row | (row >> 1))


def dest(words, east):
    x = words | (east << W)
    return tick(tick(x, 0), 1) & MASK


def escape(members, iters=40000, tail=20000):
    index = {int(w): i for i, w in enumerate(members)}
    succ = np.full((len(members), 4), -1, dtype=np.int64)
    for e in range(4):
        d = dest(members, e)
        succ[:, e] = [index.get(int(v), -1) for v in d]
    leave = (succ < 0).sum(axis=1)
    v = np.full(len(members), 1.0 / len(members))
    logs = []
    for k in range(iters):
        nv = np.zeros_like(v)
        for e in range(4):
            ok = succ[:, e] >= 0
            np.add.at(nv, succ[ok, e], v[ok] / 4)
        r = nv.sum()
        logs.append(math.log(r))
        v = nv / r
    lam = -sum(logs[-tail:]) / tail
    # quasi-stationary mass averaged over the last 840 steps (period-safe for 2..8 and 7)
    q = np.zeros_like(v)
    for k in range(840):
        nv = np.zeros_like(v)
        for e in range(4):
            ok = succ[:, e] >= 0
            np.add.at(nv, succ[ok, e], v[ok] / 4)
        v = nv / nv.sum()
        q += v
    q /= q.sum()
    dep = leave > 0
    return {
        "windows": int(len(members)),
        "departure_windows": int(dep.sum()),
        "leaving_assignments": int(leave.sum()),
        "escape_rate_per_sample": lam,
        "mean_stay_samples": 1.0 / lam,
        "qsd_mass_on_departure_windows": float(q[dep].sum()),
        "qsd_mean_leaving_fraction_at_departure": float((q[dep] * leave[dep] / 4).sum() / q[dep].sum()),
        "log2_over_rate": math.log(2) / lam,
    }, succ, leave, index


def census(path):
    a = np.fromfile(path, dtype="<u2").reshape(-1, 4)
    n = len(a)
    seeds = np.arange(n, dtype=np.int64)
    support = np.zeros(n, dtype=np.int64)
    nz = seeds > 0
    support[nz] = np.floor(np.log2(seeds[nz])).astype(np.int64) + 1
    fate, end, trap = a[:, 0].astype(np.int64), a[:, 1].astype(np.int64), a[:, 2].astype(np.int64)
    out = {"rows": int(n), "fates": {int(k): int(v) for k, v in zip(*np.unique(fate, return_counts=True))}}
    clean = fate == 1
    t = trap[clean]
    grid = [0, 50, 100, 200, 300, 400, 500, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000, 2200, 2400, 2600, 2716]
    out["trap_entry_survival_all_clean"] = {s: int((t > s).sum()) for s in grid}
    # tail fit: log N(>s) on s in [400, 1800] where counts stay above ~20
    ss = np.arange(400, 1801, 50)
    ns = np.array([(t > s).sum() for s in ss], dtype=float)
    keep = ns >= 20
    slope, icpt = np.polyfit(ss[keep], np.log(ns[keep]), 1)
    out["tail_fit"] = {"s_range": [int(ss[keep][0]), int(ss[keep][-1])], "rate_per_sample": float(-slope),
                       "log_intercept": float(icpt), "log2_over_rate": float(math.log(2) / -slope)}
    # by exact support, fraction of clean seeds with trap entry beyond s
    by = {}
    for d in range(1, 25):
        m = clean & (support == d)
        td = trap[m]
        by[d] = {"clean_seeds": int(m.sum()), "max_trap_entry": int(td.max()),
                 **{f"beyond_{s}": int((td > s).sum()) for s in (200, 400, 600, 800, 1000)}}
    out["by_support"] = by
    return out


def main():
    scc, binary, outp = sys.argv[1:4]
    comps = load_scc(scc)
    res = {"components": {}}
    for least in (519, 1799):
        info, *_ = escape(comps[least])
        res["components"][least] = info
        print(least, json.dumps(info), flush=True)
    res["census"] = census(binary)
    print(json.dumps(res["census"]["tail_fit"]), flush=True)
    open(outp, "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")


if __name__ == "__main__":
    main()
