"""Test unaligned gate factors against the R69 kick-gap automata at widths 40–43."""
import argparse
import json
from functools import cache
from pathlib import Path


def gap_tables(directory, width):
    x = []
    for line in (directory / f"X{width}-dfa.txt").read_text().splitlines():
        if not line or line.startswith("#"):
            continue
        index, count, *targets = map(int, line.split())
        assert index == len(x) and count > 0
        x.append({gap: target for gap, target in zip((2, 3, 4, 5), targets, strict=True)
                  if target >= 0})

    machine = json.loads((directory / f"Y{width}.json").read_bytes())
    y = [
        {int(gap): target for gap, target in zip(machine["gap_alphabet"], row, strict=True)
         if target != machine["gap_dead"]}
        for row in machine["gap_rows"]
    ]
    return x, y


def binary_factor_test(table):
    @cache
    def admits(word):
        pulses = [index for index, bit in enumerate(word) if bit == "1"]
        if not pulses:
            return any(gap > len(word) for gap in table[0])

        # Row zero starts at any pulse. Prepend an incoming gap and choose
        # an outgoing gap long enough to cover each observed partial endpoint.
        states = {state for gap, state in table[0].items() if gap > pulses[0]}
        for first, second in zip(pulses, pulses[1:]):
            gap = second - first
            states = {table[state][gap] for state in states if gap in table[state]}
            if not states:
                return False
        trailing = len(word) - pulses[-1] - 1
        return any(gap > trailing for state in states for gap in table[state])
    return admits


def longest_words(accepts):
    # Prefix closure lets the first empty layer certify all longer lengths.
    layer = [""]
    while layer:
        previous = layer
        layer = [word + bit for word in previous for bit in "01" if accepts(word + bit)]
    return {"maximum": len(previous[0]), "words": previous}


def run(directory, width):
    x, y = map(binary_factor_test, gap_tables(directory, width))
    common = longest_words(lambda word: x(word) and y(word))
    waits = {}
    for component, admits, markers in [("X", x, ("101",)), ("Y", y, ("101", "10001"))]:
        for marker in markers:
            waits[f"{component}/{marker}"] = longest_words(
                lambda word: marker not in word and admits(word)
            )
    y_marks = ("10001", "10101")
    assert all(not x(marker) for marker in y_marks)
    assert longest_words(lambda word: y(word) and all(m not in word for m in y_marks)) == common
    defects = ("00000", "11", "101", "10001", "1001001")
    available = {
        name: [marker for marker in defects if admits(marker)]
        for name, admits in (("X", x), ("Y", y))
    }
    return {"width": width, "common": common, "without": waits, "defects": available}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive_directory", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    results = [run(args.archive_directory, width) for width in range(40, 44)]
    args.output.write_bytes((json.dumps(results, indent=2) + "\n").encode())
    for case in results:
        print(case["width"], case["common"], {k: v["maximum"] for k, v in case["without"].items()})
