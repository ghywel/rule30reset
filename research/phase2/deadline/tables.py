"""Export the four kit lock families and the 829-window trap. One row per code."""
import argparse
import ast
import re
from pathlib import Path


def literal(path, name):
    text = path.read_text(encoding="utf-8")
    block = text.split("def " + name + " :", 1)[1].split(":=", 1)[1].lstrip()
    depth = 0
    for i, char in enumerate(block):
        if char == "[":
            depth += 1
        if char == "]":
            depth -= 1
            if depth == 0:
                return ast.literal_eval(block[:i + 1])
    raise ValueError(name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    src = args.kit / "lean/Ruliology/CellularAutomata"
    table = [(0, 16, 0, code) for code in literal(src / "Rule30Certificates/GateTrap.lean", "trapCodes")]
    assert len(table) == len(set(table)) == 829
    locks = src / "Rule30SidewaysLocks.lean"
    for tag, suffix, width in [(2, "2", 19), (5, "5", 34), (7, "7", 30), (8, "7b", 45)]:
        phases = literal(locks, "lock" + suffix + "Codes")
        check = re.search(r"lock" + suffix + r"_ok : lockCheck (\d+) (\d+)", locks.read_text(encoding="utf-8"))
        assert (width, len(phases)) == tuple(map(int, check.groups()))
        for phase, codes in enumerate(phases):
            for code in codes:
                for high in range(4):
                    x = code | high << width
                    x = (x << 1) ^ (x | (x >> 1))
                    x = ((x << 1) | 1) ^ (x | (x >> 1))
                    assert (x & ((1 << width) - 1)) in phases[(phase + 1) % len(phases)]
                table.append((tag, width, phase, code))
    args.out.write_text("".join("%d %d %d %d\n" % row for row in table), encoding="ascii")


if __name__ == "__main__":
    main()
