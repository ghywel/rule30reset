"""Replay the archived isolated-wheel tours and count exact contexts on each row."""
import argparse
from itertools import product
from pathlib import Path

from check import gate, target


def tour(degree):
    if degree < 2:
        raise ValueError("tour degree must be at least two")
    word = "X" * degree
    seen = {word}
    while True:
        for letter in "YX":
            suffix = word[-(degree - 1):] + letter
            if suffix not in seen:
                break
        else:
            break
        word += letter
        seen.add(suffix)
    assert len(seen) == 2 ** degree and len(word) == len(seen) + degree - 1
    return word


def verify(path):
    expected = {tour(4): 4, tour(5): 5}
    seen = set()
    for line in path.read_text().splitlines():
        labels, _, row = line.split()
        assert set(labels) <= {"A", "B"} and set(row) <= {"0", "1"}
        macros = labels.translate(str.maketrans("AB", "XY"))
        assert macros not in seen
        seen.add(macros)
        blocks = "".join("A" if c == "X" else "AB" for c in macros)
        readings = target(blocks) + "1001"
        assert len(row) == 2 * len(readings) - 1
        assert gate(row, len(readings)) == readings
        if macros in expected:
            n = expected[macros]
            factors = [macros[i:i+n] for i in range(len(macros) - n + 1)]
            assert sorted(factors) == ["".join(w) for w in product("XY", repeat=n)]
            label = f"order-{n} tour, all {len(factors)} contexts"
        else:
            nleft, nright = macros.split("X")
            assert nleft and nright and set(nleft + nright) == {"Y"}
            label = f"interruption Y^{len(nleft)} X Y^{len(nright)}"
        print(f"{label}: {len(macros)} macros, {len(readings)} readings, {len(row)} initial sites")
    assert seen == {*expected, "Y" * 12 + "X" + "Y" * 12}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rows", type=Path)
    args = parser.parse_args()
    if not __debug__:
        parser.error("enable assertions to replay witnesses")
    verify(args.rows)
