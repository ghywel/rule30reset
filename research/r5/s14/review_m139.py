"""Replay the S14 carrying controls with the extracted packet/Rule30Submission.lean as the argument."""
import argparse
import ast
from collections import Counter
from pathlib import Path
import re
import sys

import numpy as np


ETHER = ("001", "001", "011", "110", "010", "010", "110", "101", "100", "100", "101", "011")
KIT = Path(__file__).resolve().parents[3] / "Rule30PrizeKit/lean/Ruliology/CellularAutomata"


def constant(source, name):
    match = re.search(r"^def " + name + r" : Nat := (\d+)$", source, re.MULTILINE)
    return int(match[1])


def trap_rows(source, name, width, label_bits, count):
    words = constant(source, name + "_R")
    labels = constant(source, name + "_L")
    return [((labels >> (label_bits * i)) % (1 << label_bits),
             (words >> (width * i)) % (1 << width)) for i in range(count)]


def wait(rows, n, g, u):
    if (g, u) == (6, 1):
        distance, slot, extra = n - 2, 7, 3
    elif (g, u) == (9, 1):
        distance, slot, extra = n - 1, 7, 2
    else:
        distance, extra = n - 1, 1
        slot = 9 if (g, u) == (8, 1) else (0, 7, 4, 1, 8, 5, 2, 0, 6, 3)[g]
    if distance < 2:
        return rows[distance][slot] + extra
    blocks, remainder = divmod(distance - 2, 4)
    return 10 * blocks + rows[2 + remainder][slot] + extra


def tick(word, next_wall):
    # Bits p are physical sites p. Rule 30 has output 1 on neighborhoods 001, 010, 011, 100.
    left, center, east = word << 1, word, word >> 1
    white_left = ~left & (~center & east | center & ~east | center & east)
    return ((white_left | left & ~center & ~east) & ~1) | next_wall


def check_exits(source):
    table = source.split("def smallWait", 1)[1].split("def ticksToOne", 1)[0]
    rows = [ast.literal_eval(row) for row in re.findall(r"=> (\[[\d,]*\])", table)]
    assert len(rows) == 6
    states, drives, witness = Counter(), set(), {}
    for n in range(3, 53):
        for j, wall in enumerate(ETHER):
            for phase in range(3):
                def ether(p, t):
                    return int(ETHER[(j + p) % 12][(t + phase) % 3])

                aligned = sum(ether(p, 0) << p for p in range(n + 1))
                for tail in range(16):
                    word = tick(aligned | (tail << (n + 1)), ether(0, 1))
                    if (word >> n) & 1 == ether(n, 1):
                        continue
                    g = (j + n + 4 * (phase + 1)) % 12
                    u = ((word >> (n + 1)) & 1) ^ ether(n + 1, 1)
                    expected = wait(rows, n, g, u)
                    for t in range(1, expected + 1):
                        if (word >> 1) & 1 != ether(1, t):
                            break
                        word = tick(word, ether(0, t + 1))
                    else:
                        raise AssertionError(("no departure by predicted tick", n, j, phase, tail, expected))
                    assert t == expected, (n, j, phase, tail, t, expected)
                    states[g, u] += 1
                    drives.add(wall[phase:] + wall[:phase])
                    if j == 11 and phase == 0 and tail == 0 and n in (3, 15):
                        witness[n] = (g, u, t)
    assert witness == {3: (6, 1, 4), 15: (6, 1, 32)}
    print(f"{sum(states.values())} physical exits, {len(states)} states, {len(drives)} drives. Boundary cases {witness}")


def check_windows(source, states):
    # Bit zero is site 1 in a strip word. A distinct eastern input is allowed at each tick.
    width = 20
    count = 1 << width
    words = np.arange(count, dtype=np.int32)
    reach = np.zeros((3, count), dtype=bool)
    for label, word in states:
        reach[label % 3, word % count] = True
    moves = []
    for wall in (0, 0, 1):
        left = (words << 1) | wall
        moves.append([(left ^ (words | (words >> 1) | (east << 19))) % count for east in (0, 1)])
    while True:
        previous = reach.copy()
        for p, (a, b) in enumerate(moves):
            reach[p] |= previous[(p + 1) % 3, a] | previous[(p + 1) % 3, b]
        if np.array_equal(previous, reach):
            break

    for p in range(3):
        table = constant(source, f"tab{p}")
        edges = np.array([(table >> (13 * i)) & 8191 for i in range(16384)], dtype=np.int32)
        node = np.full(count, constant(source, f"root{p}"), dtype=np.int32)
        for i in reversed(range(width)):
            node = edges[2 * node + ((words >> i) & 1)]
        assert np.array_equal(node != 0, reach[p])
    assert not reach[:, ::1 << 16].any()
    aligned = set()
    for j, wall in enumerate(ETHER):
        for phase in range(3):
            if wall[phase:] + wall[:phase] == "001":
                for t in range(3):
                    word = sum(int(ETHER[(j + i + 1) % 12][(phase + t) % 3]) << i for i in range(width))
                    aligned.add((t, word))
    assert len(aligned) == 6 and all(not reach[p, word] for p, word in aligned)
    print(f"All {3 * count} DFA answers match. Reaching by phase {reach.sum(axis=1).tolist()}, total {reach.sum()}.")
    print("All six distinct aligned phase/windows and all 48 white-prefix completions lie outside.")


def check_gate(states, period, start, expected):
    bits = [{word & 1 for label, word in states if label == (start + 3*k) % period}
            for k in range(period // 3)]
    assert bits == [{int(letter)} for letter in expected]
    print(f"Gate on all {len(states)} labelled states, starting at label {start}: {expected}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    args = parser.parse_args()
    if hasattr(sys, "set_int_max_str_digits"):
        sys.set_int_max_str_digits(0)
    source = args.source.read_text()
    fifteen = trap_rows(source, "trap001fifteen", 52, 4, 153)
    twenty_one = trap_rows((KIT / "Rule30EtherThreeTrap.lean").read_text(), "t001", 47, 5, 815)
    check_exits(source)
    check_windows(source, fifteen)
    check_gate(twenty_one, 21, 19, "1100000")
    check_gate(fifteen, 15, 4, "11000")
