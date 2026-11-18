"""Replay M38 and M40 and count drops at the white columns, with kit wheel 0 at the edge."""
import json
import re
from bisect import bisect_left
from itertools import accumulate
from pathlib import Path

WIDTH = 87867
SOURCE = Path("Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30FourLeftSides.lean")
RESET = re.compile(r"(?=(01(?:111)*0[01]))")


def references():
    strips = {}
    for line in SOURCE.read_text().splitlines():
        match = re.fullmatch(r"def (A0|A1|B0|B1) : Nat := (.*)", line)
        if match:
            name, expr = match.groups()
            if "^^^" in expr:
                base, mask = expr.split(" ^^^ ")
                digits, shift = mask.strip("()").split(" <<< ")
                strips[name] = strips[base] ^ (int(digits, 16) << int(shift))
            else:
                strips[name] = int(expr, 16)
    assert list(strips) == ["A0", "A1", "B0", "B1"]
    return strips


def phase_words(start):
    rows = []
    v = start
    for _ in range(16):
        rows.append(format(v, f"0{WIDTH}b"))   # inside to edge, for the inverse scan
        v = ((v << 2) ^ ((v << 1) | v)) % (1 << WIDTH)
    assert v == start and len(set(rows)) == 16
    return rows


def inspect(rows):
    tables = []
    for row in rows:
        pairs = [(m.start(1), m.end(1)-1) for m in RESET.finditer(row)]
        tables.append(tuple(zip(*pairs)))
    def capacity(p):
        # The driver's first cell moves one deeper in the global string after undoing a tick.
        cursor = 0
        for d in range(WIDTH):
            starts, ends = tables[(p-d) % 16]
            n = bisect_left(starts, cursor)
            if n == len(starts):
                return d
            cursor = ends[n] + 1
        return WIDTH
    white = [i for i in range(WIDTH) if all(row[i] == "0" for row in rows)]
    anchors = [i for i in white if 4 <= WIDTH-1-i and i >= 3]
    drop_counts = []
    for t, row in enumerate(rows):
        drops = 0
        for i in anchors:
            fall = rows[t-1][i-1] == "1" and row[i-1] == "0"
            assert fall == (row[i-3:i] == "010")
            drops += fall
        drop_counts.append(drops)
    gaps = [max(b-a for a,b in zip(ends, ends[1:])) for starts, ends in tables]
    return dict(capacity=[capacity(t) for t in range(16)],
                eligible_white=sorted(WIDTH-1-i for i in anchors),
                drops=drop_counts, reset_factors=[len(starts) for starts,_ in tables],
                max_end_spacing=max(gaps))


def heal(rows, w):
    # Enumerate the two actual parent bits, with the first discrepancy fixed at e.
    words = [list(map(int,row[-w:][::-1])) for row in rows]
    prefix, maxima = [], [0]*((w+255)//256)
    for p, y in enumerate(words):
        target = words[(p+1)%16]
        ends = [0]
        for e in range(1,w):
            states = {(y[e-2] if e>=2 else 0,y[e-1])}
            j = e
            while j<w and states:
                choices = (1-y[e],) if j==e else (0,1)
                states = {(b,c) for a,b in states for c in choices if a^(b|c)==target[j]}
                if states:
                    j += 1
            ends.append(j)
            maxima[e//256] = max(maxima[e//256],j-e)
        prefix.append(list(accumulate(ends,max)))
    times = []
    for p in range(16):
        s,u = 0,19
        while u<w and s<4*w:
            u = prefix[(p+s)%16][u]
            s += 1
        assert u==w
        times.append(s)
    return dict(block_maxima=maxima, first_reach=min(times))


if __name__ == "__main__":
    result = {}
    for name, v in references().items():
        rows = phase_words(v)
        result[name] = inspect(rows)
        if name=="A0":
            result["heal4096"] = heal(rows,4096)
    print(json.dumps(result,indent=2))
