"""K92.3, claudeIntel N32: do physical right halves leave X at the rate of a fair drive?

Replays physical Rule 30 on finite right halves beside the black-first alternating centre, for a uniform
random sample of seeds below 2^24 and separately for the two record seeds. At every white sample whose
24-cell window lies in X (component 519 of R65's width-24 graph) and has a leaving exterior pair, it
records the number k of leaving pairs and whether the physical pair (sites 25-26) is one of them. A fair
drive would leave with probability k/4.

Each seed runs to its census endpoint: the first trap sample for clean seeds, else the lock or ether
certificate sample. The replay checks its own first trap sample against the census.

Usage: python -I claudeIntel_x_physical.py W24.scc 24-aligned.bin tables.txt N out.json
Rows are 2-D arrays of 64-bit words; bit j of word 0 is site j+1.
"""
import json
import struct
import sys

import numpy as np

W = 24
MASK = np.uint64((1 << W) - 1)
ONE = np.uint64(1)
S63 = np.uint64(63)
RECORDS = (7693847, 11888151)


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


def leave_masks(members):
    inside = np.zeros(1 << W, dtype=bool)
    inside[members.astype(np.int64)] = True
    lm = np.zeros(len(members), dtype=np.uint8)
    for e in range(4):
        d = tick1(tick1(members | (np.uint64(e) << np.uint64(W)), 0), 1) & MASK
        lm |= (~inside[d.astype(np.int64)]).astype(np.uint8) << np.uint8(e)
    table = np.zeros(1 << W, dtype=np.uint8)
    table[members.astype(np.int64)] = lm
    return inside, table


def tick(R, wall):
    left = R << ONE
    left[:, 1:] |= R[:, :-1] >> S63
    left[:, 0] |= np.uint64(wall)
    right = R >> ONE
    right[:, :-1] |= R[:, 1:] << S63
    return left ^ (R | right)


POP = np.array([bin(i).count("1") for i in range(16)], dtype=np.int64)


def replay(seeds, stop, trap, comp, detail=False):
    n = len(seeds)
    stats = {name: np.zeros(n, dtype=np.int64) for name in
             ("inX", "inY", "depX", "quarterX", "exitX", "depY", "quarterY", "exitY", "entryX", "exitXat")}
    stats["entryX"][:] = -1
    stats["exitXat"][:] = -1
    by_k = {c: np.zeros((5, 2), dtype=np.int64) for c in ("X", "Y")}
    mytrap = np.full(n, -1, dtype=np.int64)
    events = [[] for _ in range(n)] if detail else None
    idx = np.arange(n)
    R = np.zeros((n, 2), dtype=np.uint64)
    R[:, 0] = seeds.astype(np.uint64)
    R = tick(R, 1)
    s = 0
    while len(idx):
        if 64 * R.shape[1] < W + 2 * s + 8:
            R = np.hstack([R, np.zeros((len(idx), 1), dtype=np.uint64)])
        w0 = R[:, 0]
        win = (w0 & MASK).astype(np.int64)
        east = ((w0 >> np.uint64(W)) & np.uint64(3)).astype(np.int64)
        hit = trap[(w0 & np.uint64(0xFFFF)).astype(np.int64)]
        first = hit & (mytrap[idx] < 0)
        mytrap[idx[first]] = s
        for c, inside, table in comp:
            isin = inside[win]
            stats["in" + c][idx[isin]] += 1
            lm = table[win].astype(np.int64)
            dep = isin & (lm > 0)
            k = POP[lm[dep]]
            took = (lm[dep] >> east[dep]) & 1
            stats["dep" + c][idx[dep]] += 1
            stats["quarter" + c][idx[dep]] += k
            stats["exit" + c][idx[dep]] += took
            np.add.at(by_k[c], (k, took), 1)
            if c == "X":
                newx = isin & (stats["entryX"][idx] < 0)
                stats["entryX"][idx[newx]] = s
                gone = dep.copy()
                gone[dep] = took.astype(bool)
                stats["exitXat"][idx[gone]] = s
            if detail:
                for j, kk, tt, ee in zip(idx[dep], k, took, east[dep]):
                    events[j].append([c, s, int(kk), int(ee), int(tt)])
        done = stop[idx] <= s
        if done.any():
            keep = ~done
            idx, R = idx[keep], R[keep]
        if not len(idx):
            break
        R = tick(tick(R, 0), 1)
        s += 1
    return stats, by_k, mytrap, events


def summarise(stats, by_k, mask):
    out = {}
    for c in ("X", "Y"):
        dep = int(stats["dep" + c][mask].sum())
        exp = stats["quarter" + c][mask].sum() / 4
        ext = int(stats["exit" + c][mask].sum())
        samples = int(stats["in" + c][mask].sum())
        out[c] = {"seeds_visiting": int((stats["in" + c][mask] > 0).sum()), "samples_in": samples,
                  "departure_visits": dep, "fair_expected_exits": float(exp), "observed_exits": ext,
                  "observed_over_fair": (ext / exp) if exp else None,
                  "departure_visits_per_sample_in": (dep / samples) if samples else None,
                  "mean_leaving_fraction_at_departure": (exp / dep) if dep else None}
    return out


def main():
    scc, census, tables, nsample, outp = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5]
    comps = load_scc(scc)
    comp = []
    for c, least in (("X", 519), ("Y", 1799)):
        inside, table = leave_masks(comps[least])
        comp.append((c, inside, table))
    trap = np.zeros(1 << 16, dtype=bool)
    for line in open(tables, encoding="ascii"):
        tag, width, phase, code = map(int, line.split())
        if tag == 0:
            trap[code] = True
    assert trap.sum() == 829
    cen = np.fromfile(census, dtype="<u2").reshape(-1, 4).astype(np.int64)
    fate_all, end_all, trap_all = cen[:, 0], cen[:, 1], cen[:, 2]
    stop_all = np.where(fate_all == 1, trap_all, end_all)
    rng = np.random.default_rng(20261127)
    seeds = np.sort(rng.choice(1 << 24, size=nsample, replace=False))
    res = {"sample": nsample, "rng": "numpy default_rng(20261127).choice(2^24, N, replace=False)"}
    stats, by_k, mytrap, _ = replay(seeds, stop_all[seeds], trap, comp)
    fate = fate_all[seeds]
    clean = fate == 1
    assert np.array_equal(mytrap[clean], trap_all[seeds][clean]), "first trap sample disagrees with census"
    res["trap_check"] = "first trap sample equals the census field for all %d clean seeds" % int(clean.sum())
    res["by_fate"] = {}
    for name, m in (("clean", clean), ("two-lock", fate == 2), ("five-lock", fate == 5),
                    ("seven-lock", (fate == 7) | (fate == 8)), ("ether", fate == 9), ("all", fate >= 0)):
        res["by_fate"][name] = {"seeds": int(m.sum()), **summarise(stats, by_k, m)}
    res["by_k_all"] = {c: {int(k): {"declined": int(v[k, 0]), "taken": int(v[k, 1])} for k in range(1, 5)}
                       for c, v in by_k.items()}
    # X stays of clean seeds that visited X: survival of (exit - entry)
    m = clean & (stats["entryX"] >= 0) & (stats["exitXat"] >= 0)
    stay = stats["exitXat"][m] - stats["entryX"][m]
    res["x_stay_clean"] = {"seeds": int(m.sum()), "survival": {int(t): int((stay > t).sum())
                           for t in (0, 50, 100, 200, 300, 400, 600, 800, 1000, 1200)}}
    nox = clean & (stats["entryX"] < 0)
    res["clean_never_in_X"] = int(nox.sum())
    res["clean_in_X_without_exit_seen"] = int((clean & (stats["entryX"] >= 0) & (stats["exitXat"] < 0)).sum())
    rec = np.array(RECORDS)
    rs, rk, rt, ev = replay(rec, stop_all[rec], trap, comp, detail=True)
    res["records"] = {int(sd): {"census_stop": int(stop_all[sd]), "my_first_trap": int(rt[i]),
                                "entryX": int(rs["entryX"][i]), "exitX": int(rs["exitXat"][i]),
                                "departure_events": ev[i]} for i, sd in enumerate(RECORDS)}
    open(outp, "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")
    print(json.dumps({k: v for k, v in res.items() if k != "records"}, indent=1))
    for sd, r in res["records"].items():
        print(sd, r["entryX"], r["exitX"], r["my_first_trap"], [e[1:] for e in r["departure_events"]])


if __name__ == "__main__":
    main()
