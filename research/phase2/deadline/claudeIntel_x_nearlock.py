"""K92.3, claudeIntel N32: are the long stays in X partial seven-locks?

Replays the selected clean seeds (census fate 1) to their first trap sample. For each seed it finds the stay
of the 24-cell window in X (component 519) and reports, over that stay:
  rhythm   the fraction of samples s whose last seven gate bits (s-6..s) are a rotation of 0101000, the gate
           word of the kit's width-30 seven-lock (Rule30SidewaysLocks, lock7Codes);
  breaks   the number of maximal runs of samples outside that rhythm, after the first rhythmic sample;
  out      the number of stay samples outside that rhythm, and of all samples before the first trap sample
           (from sample 0, so the first six always count);
  agree    the number of initial cells on which the row agrees with some lock7 code (0..30), as min and median.

Selection: every clean seed below 2^24 whose first trap sample exceeds LOW (and at most HIGH), or a uniform
sample of SAMPLE of them (numpy default_rng(20261127)).

Usage: python -I claudeIntel_x_nearlock.py W24.scc 24-aligned.bin tables.txt LOW HIGH SAMPLE out.json
"""
import json
import struct
import sys

import numpy as np

W = 24
MASK = np.uint64((1 << W) - 1)
M30 = np.uint64((1 << 30) - 1)
ONE = np.uint64(1)
S63 = np.uint64(63)


def load_component(path, least):
    raw = open(path, "rb").read()
    assert raw[:8] == b"K50SCC1\n" and struct.unpack_from("<I", raw, 8)[0] == W
    off = 12
    while off < len(raw):
        lo, count = struct.unpack_from("<II", raw, off)
        if lo == least:
            return np.frombuffer(raw, dtype="<u4", count=count, offset=off + 8).astype(np.int64)
        off += 8 + 4 * count
    raise KeyError(least)


def tick(R, wall):
    left = R << ONE
    left[:, 1:] |= R[:, :-1] >> S63
    left[:, 0] |= np.uint64(wall)
    right = R >> ONE
    right[:, :-1] |= R[:, 1:] << S63
    return left ^ (R | right)


def agreement(row30, codes):
    x = row30[:, None] ^ codes[None, :]
    low = x & (~x + ONE)
    L = np.where(x == 0, 30, np.log2(np.maximum(low, ONE).astype(np.float64)).astype(np.int64))
    return np.minimum(L, 30).max(axis=1)


def main():
    scc, census, tables = sys.argv[1:4]
    low, high, nsample, outp = int(sys.argv[4]), int(sys.argv[5]), int(sys.argv[6]), sys.argv[7]
    inside = np.zeros(1 << W, dtype=bool)
    inside[load_component(scc, 519)] = True
    codes = np.array([int(r.split()[3]) for r in open(tables, encoding="ascii") if r.split()[:2] == ["7", "30"]],
                     dtype=np.uint64)
    assert len(codes) == 66
    rhythm_words = set()
    base = [0, 1, 0, 1, 0, 0, 0]
    for r in range(7):
        w = base[r:] + base[:r]
        rhythm_words.add(sum(b << i for i, b in enumerate(w)))  # bit i = gate at s-6+i
    is_rhythm = np.zeros(128, dtype=bool)
    is_rhythm[list(rhythm_words)] = True
    cen = np.fromfile(census, dtype="<u2").reshape(-1, 4).astype(np.int64)
    pick = np.flatnonzero((cen[:, 0] == 1) & (cen[:, 2] > low) & (cen[:, 2] <= high))
    if nsample and len(pick) > nsample:
        pick = np.sort(np.random.default_rng(20261127).choice(pick, size=nsample, replace=False))
    stop = cen[pick, 2]
    n = len(pick)
    entry = np.full(n, -1, dtype=np.int64)
    last = np.full(n, -1, dtype=np.int64)
    inX = np.zeros(n, dtype=np.int64)
    rhythmic = np.zeros(n, dtype=np.int64)
    pre_out = np.zeros(n, dtype=np.int64)
    breaks = np.zeros(n, dtype=np.int64)
    started = np.zeros(n, dtype=bool)
    prev_r = np.zeros(n, dtype=bool)
    gate7 = np.zeros(n, dtype=np.int64)
    agree_hist = np.zeros((n, 31), dtype=np.int64)
    idx = np.arange(n)
    R = np.zeros((n, 2), dtype=np.uint64)
    R[:, 0] = pick.astype(np.uint64)
    R = tick(R, 1)
    s = 0
    while len(idx):
        if 64 * R.shape[1] < W + 2 * s + 8:
            R = np.hstack([R, np.zeros((len(idx), 1), dtype=np.uint64)])
        w0 = R[:, 0]
        g = (w0 & ONE).astype(np.int64)
        gate7[idx] = (gate7[idx] >> 1) | (g << 6)
        isx = inside[(w0 & MASK).astype(np.int64)]
        fresh = isx & (entry[idx] < 0)
        entry[idx[fresh]] = s
        last[idx[isx]] = s
        inX[idx[isx]] += 1
        r = is_rhythm[gate7[idx]] & (s >= 6)
        pre_out[idx] += (~r) & (s < stop[idx])
        j = idx[isx]
        rhythmic[j] += r[isx]
        brk = isx & started[idx] & ~r & prev_r[idx]
        breaks[idx[brk]] += 1
        started[idx[isx & r]] = True
        prev_r[idx] = r
        if isx.any():
            L = agreement(w0[isx] & M30, codes)
            np.add.at(agree_hist, (j, L), 1)
        done = stop[idx] <= s
        keep = ~done
        idx, R = idx[keep], R[keep]
        if not len(idx):
            break
        R = tick(tick(R, 0), 1)
        s += 1
    stay = last - entry + 1
    has = entry >= 0
    frac = np.where(inX > 0, rhythmic / np.maximum(inX, 1), 0.0)
    cum = np.cumsum(agree_hist, axis=1)
    amin = np.argmax(agree_hist > 0, axis=1)
    amed = np.argmax(cum >= (inX[:, None] + 1) // 2, axis=1)
    out = {"low": low, "high": high, "seeds": int(n), "seeds_with_X_stay": int(has.sum()),
           "stay_length_quartiles": [int(q) for q in np.percentile(stay[has], [0, 25, 50, 75, 100])],
           "rhythm_fraction_quartiles": [float(q) for q in np.percentile(frac[has], [0, 5, 25, 50, 75, 100])],
           "seeds_with_rhythm_fraction_at_least_0.99": int((frac[has] >= 0.99).sum()),
           "breaks_histogram": {int(k): int(v) for k, v in zip(*np.unique(breaks[has], return_counts=True))},
           "agree_min_histogram": {int(k): int(v) for k, v in zip(*np.unique(amin[has], return_counts=True))},
           "agree_median_histogram": {int(k): int(v) for k, v in zip(*np.unique(amed[has], return_counts=True))},
           "trap_entry_minus_X_exit": {int(k): int(v) for k, v in zip(*np.unique((stop - last)[has], return_counts=True))},
           "out_of_rhythm_samples_in_X_quartiles": [int(q) for q in np.percentile((inX - rhythmic)[has], [0, 25, 50, 75, 100])],
           "out_of_rhythm_samples_before_trap_quartiles": [int(q) for q in np.percentile(pre_out, [0, 25, 50, 75, 100])],
           "out_of_rhythm_samples_before_trap_max_seed": int(pick[np.argmax(pre_out)]),
           "out_of_rhythm_samples_in_X_max_seed": int(pick[has][np.argmax((inX - rhythmic)[has])]),
           "least_rhythm_fraction_seed": int(pick[has][np.argmin(frac[has])]),
           "least_rhythm_fraction": float(frac[has].min())}
    open(outp, "w", encoding="ascii", newline="\n").write(json.dumps(out, indent=1) + "\n")
    print(json.dumps(out))


if __name__ == "__main__":
    main()
