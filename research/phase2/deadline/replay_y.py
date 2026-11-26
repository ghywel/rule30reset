"""Track first 48-clean observation and four certified locks for truncations of N21's white-sample east."""
import ast
from pathlib import Path
import re
import sys
from zipfile import ZipFile


def lock_tables(kit):
    base = kit / "lean/Ruliology/CellularAutomata"
    source = (base / "Rule30SidewaysLocks.lean").read_text(encoding="utf-8")
    tables = []
    for name, width in (("2",19), ("5",34), ("7",30), ("7b",45)):
        literal = re.search(r"def lock" + name + r"Codes : List \(List Nat\) := (\[.*?\n\])", source, re.S)[1]
        tables.append((name, (1 << width) - 1, {x for group in ast.literal_eval(literal) for x in group}))
    return tables


def first_event(row, locks, samples):
    """Row at the first white sample, followed by a white then a black wall step."""
    last = ""
    dirty_words = ("00000", "11", "101", "10001", "1001001")
    first_allowed_start = 0
    for s in range(samples):
        last = (last + str(row & 1))[-48:]
        for w in dirty_words:
            if last.endswith(w):
                first_allowed_start = max(first_allowed_start, s - len(w) + 2)
        clean = s - first_allowed_start >= 47
        assert clean == (len(last) == 48 and all(w not in last for w in dirty_words))
        hits = [name for name, mask, codes in locks if row & mask in codes]
        if clean or hits:
            return s, ",".join((["clean48"] if clean else []) + hits)
        for wall in (0,1):
            row = ((row << 1) | wall) ^ (row | (row >> 1))
    return None, "UNKNOWN"


if __name__ == "__main__":
    with ZipFile(sys.argv[1]) as archive:
        full = int(archive.read("k50_1/row470.txt").strip(),16)
    locks = lock_tables(Path(sys.argv[2]))
    for width in (16,24,32,64,128,256,512,814,full.bit_length()):
        row = full & ((1 << width)-1)
        print(width, row.bit_length(), *first_event(row, locks, 8192))
