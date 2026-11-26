"""Four inverse ticks beside a prescribed wall: regrow I267's cover (claudeIntel, N27).

I267 starts from its 29-word age-31 cover and appends one free eastern cell per tick,
reaching width 74 at age 76 (m >= 2), where every band and every one of the 256 four-layer
registers gives the exact edge f+4. This program
  * regrows that cover with its own code and compares it with I267's band74.txt;
  * regrows from the exact age-31 set of 23 bands (claudeIntel_three_tick_read.py), which
    is a subset of I267's 29;
  * reports, for each start, the first age at which the relaxed four-layer test passes, and
    the failing words at the age before.

Usage: python -I claudeIntel_four_tick.py [band74.txt]
"""
import json
import re
import sys
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent


def rule(l, c, r):
    return (30 >> (4 * l + 2 * c + r)) & 1


def grow(cover):
    """Width-w bands (tuples, edge first) at one age -> width-(w+1) bands at the next."""
    out = set()
    for band in cover:
        for x in (0, 1):
            cells = (0, 0) + band + (x,)
            out.add(tuple(rule(cells[i], cells[i + 1], cells[i + 2]) for i in range(len(band) + 1)))
    return out


def four_layer_failures(cover, layers=4):
    """Bands for which some starting register at the east end misses the exact edge f+layers."""
    bands = sorted(cover)
    W = len(bands[0])
    img = np.array(bands, dtype=np.uint8)                       # (n, W), column i = cell f+i
    n = len(bands)
    regs = np.arange(1 << (2 * layers), dtype=np.int64)
    # state: for each layer k, cells at p and p+1; start at p = W-2
    cur = [np.repeat(((regs >> (2 * k)) & 1)[None, :], n, 0).astype(np.uint8) for k in range(layers)]
    nxt = [np.repeat(((regs >> (2 * k + 1)) & 1)[None, :], n, 0).astype(np.uint8) for k in range(layers)]
    last = {}
    for p in range(W - 2, -1, -1):
        y = np.repeat(img[:, p][:, None], len(regs), 1)
        above = [y] + cur[:-1]                                     # layer k reads layer k-1 at p
        new = [above[k] ^ (cur[k] | nxt[k]) for k in range(layers)]  # cells at p-1
        nxt, cur = cur, new
        last[p - 1] = cur[layers - 1]
    deep = last
    ok = deep[layers] == 1
    for p in range(0, layers):
        ok &= deep[p] == 0
    for k in range(layers):
        ok &= (cur[k] == 0) & (nxt[k] == 0)                        # state at f-1 all zero
    bad_band = ~ok.all(axis=1)
    return [bands[i] for i in np.flatnonzero(bad_band)]


def to_hex(band):
    """Edge-first, least-significant-bit order, as I267 writes its words."""
    return hex(sum(b << i for i, b in enumerate(band)))


def run(start, label, ages=range(31, 77)):
    cover = set(start)
    results = {}
    for age in ages:
        if age > 31:
            cover = grow(cover)
        if age >= 60:
            bad = four_layer_failures(cover)
            results[age] = {"width": len(next(iter(cover))), "words": len(cover), "failing": len(bad),
                            "failingWords": [to_hex(b) for b in bad][:12]}
            print(f"{label}: age {age}, width {results[age]['width']}, {len(cover)} words, "
                  f"{len(bad)} with a failing register", flush=True)
            if not bad:
                return cover, results
    return cover, results


if __name__ == "__main__":
    lean = (HERE / "three-step-extension.lean").read_text(encoding="utf-8")
    cover29 = [int(v) for v in re.search(r"def cover29 : List Nat := \[([0-9,\s]+)\]", lean).group(1).replace(",", " ").split()]
    as_band = lambda v: tuple((v >> (28 - i)) & 1 for i in range(29))     # Lean words: edge = bit 28
    exact = json.loads((HERE / "data" / "claudeIntel-band29-exact.json").read_text())
    assert set(exact) <= set(cover29)
    theirs, res_t = run([as_band(v) for v in cover29], "I267's 29-word start")
    if len(sys.argv) > 1:
        lines = {tuple(int(ch) for ch in line.strip()) for line in open(sys.argv[1]) if line.strip()}
        print(f"regrown width-74 cover equals I267's band74.txt: {theirs == lines} ({len(theirs)} and {len(lines)} words)")
    mine, res_m = run([as_band(v) for v in exact], "exact 23-word start")
    (HERE / "data" / "claudeIntel-four-tick.json").write_text(json.dumps({"I267start": res_t, "exactStart": res_m}, indent=1))
