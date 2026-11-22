"""Replay the ordinary per-gap suffixes and both continuous tick-91 examples."""
import json
from pathlib import Path
import sys


def step(cells, drive):
    updated = []
    for i, center in enumerate(cells):
        left = drive if i == 0 else cells[i - 1]
        right = cells[i + 1] if i + 1 < len(cells) else 0
        updated.append(left ^ (center | right))
    return updated


def unpack(value, width):
    return [(value >> i) & 1 for i in range(width)]


def check(path):
    data = json.loads(path.read_text())
    width, gaps, anchor = data["width"], data["gaps"], data["anchor"]
    assert all(9 <= q <= 16 for q in gaps)
    for branch in data["paths"]:
        rows = branch["rows"]
        assert rows[0] == rows[-1] == anchor
        assert len(rows) == 1 + len(gaps) and len(branch["suffix"]) == len(gaps)
        for j, (x, q, target, suffix) in enumerate(
            zip(rows, gaps, rows[1:], branch["suffix"])
        ):
            assert 0 <= suffix < 1 << (q + 1)
            cells = unpack(x, width) + unpack(suffix, q + 1)
            for t in range(q + 1):
                if t == 2:
                    assert cells[0] == branch["bits"][j]
                cells = step(cells, int(t == 0))
            assert cells[:width] == unpack(target, width)
    clock = [bit for q in gaps for bit in [1] + [0] * q]
    a, b = (p["bits"] for p in data["paths"])
    diffs = [2 + sum(q + 1 for q in gaps[:i]) for i in range(len(gaps)) if a[i] != b[i]]
    assert diffs == data["different_ticks"] == [91] and len(clock) == 258
    for bit, seed in enumerate((0xffffffffffffffff917d825, 0xffffffffc7f9e484917d825)):
        assert seed % (1 << width) == anchor
        cells = unpack(seed, width + 91)
        for drive in clock[:91]:
            cells = step(cells, drive)
        assert cells[0] == bit


if __name__ == "__main__":
    default = Path(__file__).with_name("ordinary-diamond.json")
    check(Path(sys.argv[1]) if len(sys.argv) > 1 else default)
    print("Replayed 42 ordinary gap transitions and both continuous tick-91 histories.")
