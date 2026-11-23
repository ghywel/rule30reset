"""Find short prefix trees for the age-364 example at tick 95, phase 6."""

import argparse
import ast
from functools import cache
from pathlib import Path
import re


PREFIX = 248139127718118986536413
TICK = 95
WIDTH = 30


def phase_six(kit):
    path = kit / "lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean"
    source = path.read_text(encoding="utf-8")
    match = re.search(r"def lock7Codes : List \(List Nat\) := (\[.*?\n\])", source, re.S)
    return set(ast.literal_eval(match.group(1))[6])


def possible_words(length, code):
    """Two disjoint masks hold the bits already known to be zero or one."""
    known = (1 << length) - 1
    ones = code & known
    zeros = known ^ ones
    for tick in range(TICK):
        mask = (1 << (WIDTH + TICK - tick - 1)) - 1
        left_one = (ones << 1) | (tick % 2 == 0)
        left_zero = (zeros << 1) | (tick % 2 == 1)
        or_one = ones | (ones >> 1)
        or_zero = zeros & (zeros >> 1)
        ones = ((left_one & or_zero) | (left_zero & or_one)) & mask
        zeros = ((left_one & or_one) | (left_zero & or_zero)) & mask
    return ones, zeros


def search(kit):
    target = phase_six(kit)

    @cache
    def leaf(length, code):
        ones, zeros = possible_words(length, code)
        fillings = 1 << (WIDTH - (ones | zeros).bit_count())
        return sum(word & (ones | zeros) == ones for word in target) == fillings

    @cache
    def leaves(length, code, depth):
        if leaf(length, code):
            return 1
        if depth == 0:
            return 0
        zero = leaves(length + 1, code, depth - 1)
        if zero == 0:
            return 0
        one = leaves(length + 1, code + (1 << length), depth - 1)
        return zero + one if one else 0

    print("length depth leaves")
    for length in range(64, 81):
        code = PREFIX % (1 << length)
        for depth in range(9):
            count = leaves(length, code, depth)
            if count:
                print(length, depth, count)
                break
        else:
            print(length, ">8", "-")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    search(parser.parse_args().kit)
