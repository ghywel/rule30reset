"""Summarize the binary census and independently replay small rows and each width's slowest row.

Usage: python replay.py tables.txt output.bin
The binary must start with seed zero and contain all rows up to a power of two.
"""
import argparse
import hashlib
import struct
from pathlib import Path

import numpy as np


FORBIDDEN = ("00000", "11", "101", "10001", "1001001")
UNSEEN = 65535


def read_tables(path):
    marks = {}
    for line in path.read_text(encoding="ascii").splitlines():
        tag, width, phase, code = map(int, line.split())
        marks.setdefault((tag, width), {})[code] = phase
    return marks


def step(row, wall):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def white_rows(seed):
    row = step(seed, 1)
    while True:
        yield row
        row = step(step(row, 0), 1)


def at_sample(seed, sample):
    for i, row in enumerate(white_rows(seed)):
        if i == sample:
            return row


def oracle(seed, last, marks):
    trap = marks[0, 16]
    first_trap = UNSEEN
    gate = ""
    for s, row in enumerate(white_rows(seed)):
        if first_trap == UNSEEN and row % 65536 in trap:
            first_trap = s
        for (tag, width), phases in marks.items():
            key = row % (1 << width)
            if tag and key in phases:
                return tag, s, first_trap, phases[key]
        gate = (gate + str(row % 2))[-48:]
        if len(gate) == 48 and not any(pattern in gate for pattern in FORBIDDEN):
            assert row % 65536 in trap
            return 1, s, first_trap, UNSEEN
        if s == last:
            return 0, s, first_trap, UNSEEN


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tables", type=Path)
    parser.add_argument("binary", type=Path)
    args = parser.parse_args()
    marks = read_tables(args.tables)
    for seed, tick, name, width, phase in (
        (112, 5, 2, 19, 0), (31, 7, 2, 19, 0), (28998, 15, 5, 34, 0),
        (1891, 27, 7, 30, 4), (3793493, 29, 8, 45, 6),
    ):
        value = at_sample(seed, (tick-1)//2) % (1 << width)
        assert marks[name, width][value] == phase
    assert at_sample(0, 146) % 65536 in marks[0, 16]
    rows = np.memmap(args.binary, mode="r", dtype="<u2").reshape(-1, 4)
    size = len(rows)
    assert size & (size-1) == 0
    checks = set(range(min(size, 1024)))
    print("D exact_rows clean lock2 lock5 lock7 lock7b unknown max_resolved_sample least_max_seed first_trap_at_max cum_max_resolved exact_max_multiplicity")
    cumulative = -1
    for d in range(size.bit_length()):
        start = (1 << (d-1)) if d else 0
        end = 1 << d
        group = rows[start:end]
        counts = np.bincount(group[:, 0], minlength=9)
        resolved = group[:, 0] != 0
        assert sum(counts[i] for i in (0,1,2,5,7,8)) == len(group)
        if resolved.any():
            maximum = int(group[resolved, 1].max())
            idx = np.flatnonzero(resolved & (group[:, 1] == maximum))
            seed = int(idx[0]) + start
            first = int(rows[seed, 2])
            cumulative = max(maximum, cumulative)
            checks.update(int(idx[j])+start for j in {0, len(idx)//2, len(idx)-1})
        else:
            maximum, seed, first, idx = -1, -1, UNSEEN, []
        unknowns = np.flatnonzero(~resolved)
        if len(unknowns):
            checks.update(int(unknowns[j])+start for j in {0, len(unknowns)//2, len(unknowns)-1})
        print(d, len(group), *[counts[i] for i in (1,2,5,7,8,0)], maximum, seed,
              first if first != UNSEEN else "-", cumulative, len(idx))
    for seed in sorted(checks):
        expected = tuple(map(int, rows[seed]))
        assert oracle(seed, expected[1], marks) == expected, (seed, expected)
    print("Oracle replays:",len(checks),"+ five positive lock controls and the empty-row trap at sample 146")
    with args.binary.open("rb") as stream:
        print("Binary SHA256:", hashlib.file_digest(stream, "sha256").hexdigest())


if __name__ == "__main__":
    main()
