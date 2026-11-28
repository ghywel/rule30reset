"""Replay the kit's forced waits on the four 16-phase rows, in kit wheel numbering."""

from argparse import ArgumentParser
from pathlib import Path
import re

WIDTH = 87867


def kit_rows(kit):
    source = kit / "lean/Ruliology/CellularAutomata/Rule30FourLeftSides.lean"
    rows = {}
    for name, expr in re.findall(r"^def (A0|A1|B0|B1) : Nat := (.*)$", source.read_text(), re.M):
        if name == "A0":
            rows[name] = int(expr, 16)
        else:
            pattern = r"(A0|B0) \^\^\^ \((0x[a-f0-9]+) <<< (\d+)\)"
            parent, bits, shift = re.fullmatch(pattern, expr).groups()
            rows[name] = rows[parent] ^ (int(bits, 16) << int(shift))
    assert set(rows) == {"A0", "A1", "B0", "B1"}
    return rows


def forced_clock(initial):
    row = initial
    mask = (1 << WIDTH) - 1
    phases = []
    for _ in range(16):
        phases.append(row.to_bytes((WIDTH + 7) // 8, "little"))
        row = ((row << 2) ^ ((row << 1) | row)) & mask
    assert row == initial
    ticks = [0, 1]
    for j in range(1, WIDTH - 1):
        byte, bit = divmod(j, 8)
        word = sum(((phase[byte] >> bit) & 1) << r for r, phase in enumerate(phases))
        rotated = (word | (word << 16)) >> (ticks[-1] % 16)
        # The least set bit supplies the wait plus one. A white wheel costs zero.
        ticks.append(ticks[-1] + (rotated & -rotated).bit_length())
    return ticks


if __name__ == "__main__":
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path, nargs="?", default=Path("Rule30PrizeKit"))
    for name, row in kit_rows(parser.parse_args().kit).items():
        ticks = forced_clock(row)
        waits = [b - a for a, b in zip(ticks, ticks[1:])]
        peak = max(waits)
        j = waits.index(peak)
        print(name, "F(53207), F(87866)", ticks[53207], ticks[-1],
              "max increment", peak, "first at", j, "ticks", ticks[j:j+2],
              "max(10F-21j)", max(10*t - 21*i for i, t in enumerate(ticks)))
