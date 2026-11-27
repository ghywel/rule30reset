"""K92.3, claudeIntel N32: the fair-drive walk on X and Y conditioned never to leave (the Q-process).

For a substochastic chain P on a component with leading eigenvalue rho, left eigenvector l (the
quasi-stationary law) and right eigenvector r, a path conditioned to survive a long time occupies window w
with frequency l_w r_w / sum(l r). A long-lived physical stay that behaves like a fair drive should visit
departure windows at that frequency and decline every exit.

Usage: python -I claudeIntel_x_qprocess.py W24.scc out.json
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
    return ((row << 1) | wall) ^ (row | (row >> 1))


def analyse(members, iters=60000, avg=8400):
    n = len(members)
    pos = {int(w): i for i, w in enumerate(members)}
    succ = np.full((4, n), -1, dtype=np.int64)
    for e in range(4):
        d = tick(tick(members | (e << W), 0), 1) & MASK
        succ[e] = [pos.get(int(v), -1) for v in d]
    leave = (succ < 0).sum(axis=0)
    ok = succ.ravel() >= 0
    tgt = succ.ravel()[ok]
    src = np.tile(np.arange(n), 4)[ok]

    def left(v):  # v P
        return np.bincount(tgt, weights=v[src] / 4, minlength=n)

    def right(u):  # P u
        return np.bincount(src, weights=u[tgt] / 4, minlength=n)

    l = np.full(n, 1.0 / n)
    r = np.ones(n)
    logs = []
    for _ in range(iters):
        l = left(l)
        s = l.sum()
        logs.append(math.log(s))
        l /= s
        r = right(r)
        r /= r.max()
    # average over a window that is a multiple of every small period, to remove any cyclic oscillation
    la = np.zeros(n)
    ra = np.zeros(n)
    for _ in range(avg):
        l = left(l)
        l /= l.sum()
        r = right(r)
        r /= r.max()
        la += l
        ra += r
    la /= la.sum()
    ra /= ra.max()
    lam = -sum(logs[-20000:]) / 20000
    pi = la * ra
    pi /= pi.sum()
    dep = leave > 0
    gate = (members & 1).astype(bool)
    return {
        "windows": int(n),
        "escape_rate_per_sample": lam,
        "qsd_departure_visit_rate": float(la[dep].sum()),
        "qprocess_departure_visit_rate": float(pi[dep].sum()),
        "qprocess_mean_leaving_pairs_at_departure": float((pi[dep] * leave[dep]).sum() / pi[dep].sum()),
        "qsd_black_gate_fraction": float(la[gate].sum()),
        "qprocess_black_gate_fraction": float(pi[gate].sum()),
    }


def main():
    comps = load_scc(sys.argv[1])
    res = {}
    for least in (519, 1799):
        res[least] = analyse(comps[least])
        print(least, json.dumps(res[least]), flush=True)
    open(sys.argv[2], "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")


if __name__ == "__main__":
    main()
