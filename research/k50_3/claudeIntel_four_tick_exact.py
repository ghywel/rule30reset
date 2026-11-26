"""Exact k-tick inverse check beside a prescribed wall, over every reachable row (claudeIntel, N30).

Rule30DrivenLeftDepthTwo proves, for every k, that the uniform k-tick statement for starts at depth at
least two from age T, and for the adjacent start from age T + 1, are each equivalent to one statement:
every start at depth two passes at age T. That statement depends only on the row at age T, and a
start at depth two (black at -2, any bit at -1) under all walls reaches few rows: 10,582 at age 72.

This program
  * enumerates those rows exactly (a row is an int, bit j = site -(j+1); one tick with wall bit w is
    (r >> 1) ^ (r | r << 1 | w));
  * tries all 4^k choices of the k predecessors' bits at sites -1 and 0 on every row, with
    numpy, and reports the failing rows at each age; for k = 1, 2, 3, 4 the first passing ages are
    8, 24, 31 and 72 at depth two and 9, 25, 32 and 73 at depth one, and depths 3 and 4 agree with
    depth two;
  * tests I267's four surviving age-75 words against the physical width-73 edge bands;
  * runs I267's relaxed test (any register at the east end of a band) on the exact physical bands,
    and compares them with I267's cover.

The second program, claudeIntel_four_tick_exact_second.py, shares no code and repeats the counts.
Usage: python -I claudeIntel_four_tick_exact.py [OUT.json]
"""
import itertools
import json
import re
import sys
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent


def step(row, w):
    return (row >> 1) ^ (row | (row << 1) | w)


def rows_at(m, age):
    """Every row at age `age` of a start with its leftmost black at -m, under every wall."""
    starts = {(1 << (m - 1)) | rest for rest in range(1 << (m - 1))}   # bit m-1 is site -m
    R = starts
    for _ in range(age):
        R = {step(r, w) for r in R for w in (0, 1)}
    return R


def failing(rows, width, layers):
    """Boolean (rows, 4^layers): the register misses the exact edge f + layers, f = -width."""
    rows = sorted(rows)
    n, R = len(rows), 1 << (2 * layers)
    img = np.array([[(r >> j) & 1 for j in range(width)] for r in rows], dtype=np.uint8)
    assert (img[:, width - 1] == 1).all()
    regs = np.arange(R)
    cur = [np.broadcast_to(((regs >> (2 * k)) & 1).astype(np.uint8), (n, R)).copy() for k in range(layers)]
    nxt = [np.broadcast_to(((regs >> (2 * k + 1)) & 1).astype(np.uint8), (n, R)).copy() for k in range(layers)]
    deep = {}
    for col in range(width):                         # image site -(col+1) -> cells at -(col+2)
        y = np.broadcast_to(img[:, col][:, None], (n, R))
        above = [y] + cur[:-1]
        new = [above[k] ^ (cur[k] | nxt[k]) for k in range(layers)]
        nxt, cur = cur, new
        off = width - (col + 2)                      # offset from the edge f
        if off <= layers:
            deep[off] = cur[layers - 1]
    ok = deep[layers] == 1
    for c in range(layers):
        ok &= deep[c] == 0
    for k in range(layers):
        ok &= (cur[k] == 0) & (nxt[k] == 0)          # all layers white at f - 1 and f
    return rows, ~ok


def relaxed_fails(band, layers=4):
    """I267's relaxed test on an edge-first band: any register at its east end."""
    v = sum(b << (len(band) - 1 - i) for i, b in enumerate(band))   # as a row of width len(band)
    _, bad = failing([v], len(band), layers)
    return bool(bad.any())


def edge_first(row, width):
    return tuple((row >> (width - 1 - i)) & 1 for i in range(width))


def main(out):
    res = {"thresholds": {}, "depthCheck": {}, "words": {}, "relaxed": {}}
    for layers, ages in ((1, range(6, 11)), (2, range(22, 27)), (3, range(29, 34)), (4, range(68, 77))):
        for m in (1, 2):
            line = {}
            for age in ages:
                rows, bad = failing(rows_at(m, age), m + age, layers)
                line[age] = {"rows": len(rows), "failingRows": int(bad.any(axis=1).sum()), "failingPairs": int(bad.sum())}
            first = min(a for a in ages if line[a]["failingRows"] == 0 and all(line[b]["failingRows"] == 0 for b in ages if b > a))
            res["thresholds"][f"k{layers}m{m}"] = {"firstPassingAge": first, "byAge": line}
            print(f"k = {layers}, depth {m}: first passing age {first}; "
                  + ", ".join(f"{a}: {v['failingRows']}/{v['rows']}" for a, v in line.items()), flush=True)
    for m in (3, 4):
        for age in (71, 72):
            rows, bad = failing(rows_at(m, age), m + age, 4)
            res["depthCheck"][f"m{m}age{age}"] = {"rows": len(rows), "failingRows": int(bad.any(axis=1).sum())}
    print("depths 3 and 4, four ticks:", res["depthCheck"], flush=True)
    # failing rows at depth two, age 71 (edge-first bits), for the record
    rows, bad = failing(rows_at(2, 71), 73, 4)
    res["failingRowsDepth2Age71"] = ["".join(map(str, edge_first(r, 73))) for r, b in zip(rows, bad) if b.any()]

    words = [0x1bf6c706606c34737b, 0xdbf6c706606c34737b, 0x11bf6c706606c34737b, 0x19bf6c706606c34737b]
    W = 73
    bands = [tuple((v >> i) & 1 for i in range(W)) for v in words]        # I267: edge first, LSB first
    for m in (1, 2, 3, 4):
        R = rows_at(m, 75)
        pre = {edge_first(r, m + 75)[:W] for r in R}
        res["words"][f"m{m}"] = {"rows": len(R), "bands": len(pre), "present": [b in pre for b in bands]}
    pre2 = {edge_first(r, 77)[:W] for r in rows_at(2, 75)}
    res["words"]["longestAgreement"] = [max(next((i for i in range(W) if p[i] != b[i]), W) for p in pre2) for b in bands]
    res["words"]["relaxedFailingRegisters"] = [int(failing([sum(c << (W - 1 - i) for i, c in enumerate(b))], W, 4)[1].sum()) for b in bands]
    print("I267's four age-75 words:", res["words"], flush=True)

    sys.path.insert(0, str(HERE))
    import claudeIntel_four_tick as cft
    lean = (HERE / "three-step-extension.lean").read_text(encoding="utf-8")
    cover29 = [int(v) for v in re.search(r"def cover29 : List Nat := \[([0-9,\s]+)\]", lean).group(1).replace(",", " ").split()]
    cover = {tuple((v >> (28 - i)) & 1 for i in range(29)) for v in cover29}
    for age in range(31, 77):
        if age > 31:
            cover = cft.grow(cover)
        if age >= 60:
            w = age - 2
            phys = {edge_first(r, age + 2)[:w] for r in rows_at(2, age)}
            assert phys <= cover
            nb = sum(1 for b in phys if relaxed_fails(b))
            res["relaxed"][age] = {"width": w, "physicalBands": len(phys), "coverWords": len(cover), "relaxedFailures": nb}
            print(f"age {age}, width {w}: {len(phys)} physical bands (cover {len(cover)}), {nb} fail the relaxed test", flush=True)
    Path(out).write_text(json.dumps(res, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else str(HERE / "data" / "claudeIntel-four-tick-exact.json"))
