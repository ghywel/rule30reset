"""Recheck S15 from the eight Rule 30 truth-table entries and the kit's 829 codes.

Run with a directory argument to also write the four independent DIMACS cones.
Each cone asks whether a clean observed block can end outside the trap.
"""
import argparse
import itertools
import re
from pathlib import Path


WHEEL = Path(__file__).resolve().parents[1]
KIT = WHEEL.parents[1] / "Rule30PrizeKit/lean/Ruliology/CellularAutomata"
FORBIDDEN = ("00000", "11", "101", "10001", "1001001")
CASES = (("reset48", 48, 0), ("prior47", 47, 1),
         ("reset47", 47, 0), ("prior46", 46, 1))


def trap_codes():
    source = (KIT / "Rule30Certificates/GateTrap.lean").read_text()
    table = re.search(r"def trapCodes : List Nat := \[([^\]]+)\]", source, re.S)
    codes = tuple(map(int, table[1].split(",")))
    assert len(codes) == len(set(codes)) == 829
    return codes


def rule(a, b, c):
    return (30 >> (4*a + 2*b + c)) & 1


def trace(seed, last_sample, black_first):
    # The final 16-cell segment has its entire past cone inside the initial row.
    last_tick = 2*last_sample + int(black_first)
    row = [(seed >> j) & 1 for j in range(16 + last_tick)]
    readings, codes = [], []
    for tick in range(last_tick + 1):
        wall = (tick + int(black_first)) % 2
        if wall == 0:
            readings.append(str(row[0]))
            codes.append(sum(bit << j for j, bit in enumerate(row[:16])))
        row = [rule(a, b, c) for a, b, c in zip([wall] + row, row, row[1:])]
    return "".join(readings), codes


def clean(word):
    return all(bad not in word for bad in FORBIDDEN)


def verify_examples(codes):
    outside, outside_codes = trace(0xa224d3200017fb5ccd115f23a59, 46, True)
    inside, inside_codes = trace(0x4319fc9fcd612848b70077729985e4b9, 56, True)
    assert clean(outside) and outside == inside[10:]
    assert outside_codes[-1] == 362 and 362 not in codes
    assert inside_codes[-1] == 29034 and set(inside_codes) <= set(codes)
    for length in range(1, 48):
        assert outside[47-length:] == inside[57-length:]

    delayed, states = trace(0x7fffff80fc, 60, True)
    assert states[0] in codes and delayed[5:12] == "1001001"
    for length, expected in ((47, 52), (48, 53)):
        first = next(i for i in range(length-1, len(delayed))
                     if clean(delayed[i+1-length:i+1]))
        assert first == expected
    # The five-read gate has radius eight to the east, so these 512 rows suffice.
    assert all("1" in trace(seed, 4, False)[0] for seed in range(512))
    print("Finite pair: 362 outside, 29034 inside. First clean endpoints: 52 and 53.")


def verify_language():
    source = (WHEEL / "word_cover_language.lean").read_text()
    table = source.split("def markers :", 1)[1].split("def extra", 1)[0]
    markers = [format(int(value, 16), f"0{size}b")[::-1]
               for size, value in re.findall(r"word (\d+) (0x[0-9a-f]+)", table)]
    assert len(markers) == 9 and max(map(len, markers)) == 38
    words = [""]
    for length in range(1, 49):
        words = [new for old in words for bit in "01"
                 if not (new := old + bit).endswith(FORBIDDEN)]
        if length < 47:
            continue
        unmarked = [w for w in words if all(m not in w for m in markers)]
        if length == 47:
            assert len(words) == 674
            assert {int(w[::-1], 2) for w in unmarked} == {0x84842109090, 0x210842109090}
            assert all(w.startswith("0000") and clean("1" + w) for w in unmarked)
        else:
            assert len(words) == 755 and not unmarked
        print(f"{length} readings: {len(words)} clean, {len(unmarked)} without a marker.")


def write_cone(path, length, prior, codes):
    # Arbitrary first white-time row. Only the endpoint must be outside.
    elapsed = 2 * (length + prior - 1)
    next_var, rows = 1, []
    for tick in range(elapsed + 1):
        width = 16 + elapsed - tick
        rows.append(list(range(next_var, next_var + width)))
        next_var += width
    clauses = []
    for tick, (before, after) in enumerate(zip(rows, rows[1:])):
        for j, output in enumerate(after):
            for a, b, c in itertools.product((0, 1), repeat=3):
                if j == 0 and a != tick % 2:
                    continue
                clause = [] if j == 0 else [-before[j-1] if a else before[j-1]]
                clause.extend([-before[j] if b else before[j], -before[j+1] if c else before[j+1]])
                clauses.append(clause + [output if rule(a, b, c) else -output])
    gate = [row[0] for row in rows[2*prior::2]]
    for bad in FORBIDDEN:
        for start in range(length - len(bad) + 1):
            clauses.append([-gate[start+i] if bit == "1" else gate[start+i]
                            for i, bit in enumerate(bad)])
    for code in codes:
        clauses.append([-x if (code >> i) & 1 else x for i, x in enumerate(rows[-1])])
    with path.open("w") as dest:
        print("p cnf", next_var-1, len(clauses), file=dest)
        for clause in clauses:
            print(*clause, 0, file=dest)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, nargs="?")
    args = parser.parse_args()
    codes = trap_codes()
    verify_examples(codes)
    verify_language()
    if args.output:
        args.output.mkdir(parents=True, exist_ok=True)
        for name, length, prior in CASES:
            write_cone(args.output / (name + ".cnf"), length, prior, codes)
