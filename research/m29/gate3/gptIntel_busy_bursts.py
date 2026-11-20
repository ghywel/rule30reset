#!/usr/bin/env python3
"""A 60-transition certificate for busy bursts (Gate 3).

The source consists cyclically of an odd number of copies of 11111101.
Between successive copies allow any even number of zeros, at least four.
For every such source the doubled excursion has no all-white wheel at
1..11 and every phase has a closed black run of length 1 modulo 3 by
wheel 11. This includes one or many bursts and arbitrary unequal gaps.
If a described period P is a power of two then it is automatically the
least period, since the source weight (seven times an odd number) is odd.

Rows are 12-bit integers with wheel 0 the low bit. Bit 1 is driven by
running XOR of the source; other bits use the ordinary Rule 30 wheel
update. Each of two short blocks switches the same two row states. A
four-tick all-zero loop fixes each. All 60 state transitions can be
checked without the spatial solver. The final spot checks compare with
claudeCloud_excursions.py, which should be beside this script or on
PYTHONPATH.
"""
import claudeCloud_excursions as ex

A, B = 0xDEC, 0xE26
WIDTH = 11
MASK = (1 << (WIDTH + 1)) - 1
BURST = "11111101"
assert (A & 3, B & 3) == (0, 2)


def step(row, pulse):
    next_band = ((row << 2) ^ ((row << 1) | row)) & (MASK ^ 3)
    return next_band | ((row & 2) ^ (int(pulse) << 1))


def first_catch(row):
    run = 0
    for j in range(1, WIDTH + 1):
        if row & (1 << j):
            run += 1
        else:
            if run % 3 == 1:
                return j
            run = 0
    return None


def trace(start, word):
    rows = []
    for pulse in word:
        rows.append(start)
        start = step(start, pulse)
    return rows, start


def certify(word, swap, needs_all_wheels):
    output_rows = []
    for start in (A, B):
        rows, end = trace(start, word)
        assert end == ((A ^ B ^ start) if swap else start)
        output_rows.extend(rows)
    catches = [first_catch(row) for row in output_rows]
    assert None not in catches
    union = 0
    for row in output_rows:
        union |= row
    if needs_all_wheels:
        assert union == MASK - 1
    print(word, len(output_rows), "rows; last catch", max(catches),
          "; occupied-wheel mask", hex(union))


def direct(gaps):
    # Moving three separator zeros after the preceding burst puts the
    # common state at the beginning of each block.
    word = "".join("0" * (g-3) + BURST + "000" for g in gaps)
    assert len(gaps) % 2 == 1 and all(g >= 4 and g % 2 == 0 for g in gaps)
    rows, end = trace(A, word * 2)
    assert end == A and None not in map(first_catch, rows)
    wheels, first_white = ex.excursion(word, WIDTH)
    assert first_white is None
    solved = [sum(bit << j for j, bit in enumerate(bits)) for bits in zip(*wheels)]
    assert rows == solved and ex.first_resets(wheels) == [first_catch(r) for r in rows]
    print("control P",len(word),";",len(gaps),"burst(s); last catch",max(map(first_catch,rows)))


def main():
    # Any odd number g-3 of initial zeros is 1 or 3 modulo 4. The first
    # trace handles all extra batches of four; the other two handle the
    # burst. Since a block exchanges A,B, both orientations of every
    # block occur over the two periods. The occupied-wheel check gives a
    # black witness for each wheel so that the cyclic child is unique.
    certify("0000", False, False)
    certify("0" + BURST + "000", True, True)
    certify("000" + BURST + "000", True, True)
    for gaps in ([4], [6], [8], [24], [4, 6, 30], [4, 6, 8, 10, 60]):
        direct(gaps)


if __name__ == "__main__":
    main()
