"""K92.3, claudeIntel N32: physical stays in X and Y against a fair drive started where they start.

Physical part: the same replay as claudeIntel_x_physical.py (same seed sample, same census endpoints),
recording every maximal stay of the 24-cell window in X (component 519) and in Y (component 1799): the
window at which it starts, its length, and whether it ended by leaving or was cut off at the endpoint.
Departure visits are also binned by the age of the stay.

Fair part: from the physical distribution of starting windows, the chain that feeds the four exterior
pairs at equal weight gives the exact survival S(t) = probability that the stay lasts beyond age t.
The physical survival is the Kaplan-Meier estimate over all stays, cut-off stays counted as censored.

Usage: python -I claudeIntel_x_stays.py W24.scc 24-aligned.bin tables.txt N out.json
"""
import json
import math
import struct
import sys

import numpy as np

W = 24
MASK = np.uint64((1 << W) - 1)
ONE = np.uint64(1)
S63 = np.uint64(63)
AGES = (0, 25, 100, 200, 400, 800)


def load_scc(path):
    raw = open(path, "rb").read()
    assert raw[:8] == b"K50SCC1\n" and struct.unpack_from("<I", raw, 8)[0] == W
    comps, off = {}, 12
    while off < len(raw):
        least, count = struct.unpack_from("<II", raw, off)
        comps[least] = np.frombuffer(raw, dtype="<u4", count=count, offset=off + 8).astype(np.uint64)
        off += 8 + 4 * count
    return comps


def tick1(x, wall):
    return ((x << ONE) | np.uint64(wall)) ^ (x | (x >> ONE))


def tick(R, wall):
    left = R << ONE
    left[:, 1:] |= R[:, :-1] >> S63
    left[:, 0] |= np.uint64(wall)
    right = R >> ONE
    right[:, :-1] |= R[:, 1:] << S63
    return left ^ (R | right)


POP = np.array([bin(i).count("1") for i in range(16)], dtype=np.int64)


class Component:
    def __init__(self, name, members):
        self.name = name
        self.members = members
        self.inside = np.zeros(1 << W, dtype=bool)
        self.inside[members.astype(np.int64)] = True
        self.lm = np.zeros(1 << W, dtype=np.uint8)
        self.succ = []
        for e in range(4):
            d = tick1(tick1(members | (np.uint64(e) << np.uint64(W)), 0), 1) & MASK
            out = ~self.inside[d.astype(np.int64)]
            self.lm[members.astype(np.int64)] |= out.astype(np.uint8) << np.uint8(e)
            self.succ.append(d)
        self.age = np.zeros((len(AGES), 4))  # samples, departure visits, fair exits, observed exits
        self.stays = []  # (start window, length, exited)

    def fair_survival(self, starts, horizon):
        order = np.argsort(self.members)
        sm = self.members[order]
        n = len(sm)
        pos = lambda words: np.searchsorted(sm, words)
        src, tgt = [], []
        for e in range(4):
            d = self.succ[e][order]
            ok = self.inside[d.astype(np.int64)]
            src.append(np.arange(n)[ok])
            tgt.append(pos(d[ok]))
        src, tgt = np.concatenate(src), np.concatenate(tgt)
        v = np.bincount(pos(starts), minlength=n).astype(float)
        v /= v.sum()
        surv = [1.0]
        for _ in range(horizon):
            v = np.bincount(tgt, weights=v[src] / 4, minlength=n)
            surv.append(float(v.sum()))
        return surv  # surv[t] = P(stay lasts beyond age t-1) = P(length >= t+1)


def replay(seeds, stop, comps):
    n = len(seeds)
    start = {c.name: np.full(n, -1, dtype=np.int64) for c in comps}
    startw = {c.name: np.zeros(n, dtype=np.uint64) for c in comps}
    idx = np.arange(n)
    R = np.zeros((n, 2), dtype=np.uint64)
    R[:, 0] = seeds.astype(np.uint64)
    R = tick(R, 1)
    s = 0
    while len(idx):
        if 64 * R.shape[1] < W + 2 * s + 8:
            R = np.hstack([R, np.zeros((len(idx), 1), dtype=np.uint64)])
        w0 = R[:, 0]
        win = w0 & MASK
        east = ((w0 >> np.uint64(W)) & np.uint64(3)).astype(np.int64)
        last = stop[idx] <= s
        for c in comps:
            st, sw = start[c.name], startw[c.name]
            isin = c.inside[win.astype(np.int64)]
            fresh = isin & (st[idx] < 0)
            st[idx[fresh]] = s
            sw[idx[fresh]] = win[fresh]
            lm = c.lm[win.astype(np.int64)].astype(np.int64)
            dep = isin & (lm > 0)
            took = np.zeros(len(idx), dtype=bool)
            took[dep] = ((lm[dep] >> east[dep]) & 1).astype(bool)
            age = s - st[idx]
            b = np.searchsorted(AGES, age, side="right") - 1
            for j in range(len(AGES)):
                m = isin & (b == j)
                md = dep & (b == j)
                c.age[j] += [m.sum(), md.sum(), POP[lm[md]].sum() / 4, took[md].sum()]
            # a stay ends by leaving (took) or is cut off at the endpoint while inside
            end = isin & (took | last)
            for k in np.flatnonzero(end):
                c.stays.append((int(win[k]), int(age[k]) + 1, bool(took[k])))
            st[idx[end]] = -1
        keep = ~last
        idx, R = idx[keep], R[keep]
        if not len(idx):
            break
        R = tick(tick(R, 0), 1)
        s += 1
    return comps


def kaplan_meier(stays, horizon):
    lengths = np.array([L for _, L, _ in stays])
    exited = np.array([x for _, _, x in stays])
    surv, S = [1.0], 1.0
    for t in range(1, horizon + 1):
        at_risk = (lengths >= t).sum()
        events = ((lengths == t) & exited).sum()
        if at_risk:
            S *= 1 - events / at_risk
        surv.append(S)
    return surv  # surv[t] = P(length > t)


def main():
    scc, census, tables, nsample, outp = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5]
    raw = load_scc(scc)
    comps = [Component("X", raw[519]), Component("Y", raw[1799])]
    cen = np.fromfile(census, dtype="<u2").reshape(-1, 4).astype(np.int64)
    stop_all = np.where(cen[:, 0] == 1, cen[:, 2], cen[:, 1])
    rng = np.random.default_rng(20261127)
    seeds = np.sort(rng.choice(1 << 24, size=nsample, replace=False))
    replay(seeds, stop_all[seeds], comps)
    res = {"sample": nsample}
    grid = (1, 25, 50, 100, 200, 300, 400, 600, 800, 1000, 1200)
    for c in comps:
        H = 1300
        starts = np.array([w for w, _, _ in c.stays], dtype=np.uint64)
        fair = c.fair_survival(starts, H)
        km = kaplan_meier(c.stays, H)
        # fair[t] = P(length >= t+1) = P(length > t)
        hz = lambda S, a, b: (math.log(S[a] / S[b]) / (b - a)) if S[b] > 0 else None
        res[c.name] = {
            "stays": len(c.stays), "ended_by_leaving": int(sum(x for _, _, x in c.stays)),
            "longest": max(L for _, L, _ in c.stays), "distinct_start_windows": int(len(np.unique(starts))),
            "survival_physical_km": {t: km[t] for t in grid},
            "survival_fair_from_physical_starts": {t: fair[t] for t in grid},
            "hazard_200_800": {"physical": hz(km, 200, 800), "fair": hz(fair, 200, 800)},
            "hazard_25_200": {"physical": hz(km, 25, 200), "fair": hz(fair, 25, 200)},
            "by_age": [{"age_from": AGES[j], "samples": int(c.age[j][0]), "departure_visits": int(c.age[j][1]),
                        "fair_exits": float(c.age[j][2]), "observed_exits": int(c.age[j][3])}
                       for j in range(len(AGES))],
        }
        print(c.name, json.dumps(res[c.name]), flush=True)
    open(outp, "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")


if __name__ == "__main__":
    main()
