"""Verify the 44-tick shield on an open strip and its ordinary 43-tick counterexample."""
from array import array


def step(row, width, exterior):
    # Bit zero is the right neighbor of the black driver. The exterior is beyond the strip.
    mask = (1 << width) - 1
    left = (row << 1) | 1
    right = (row >> 1) | (exterior << (width - 1))
    return (left ^ (row | right)) & mask


def open_strip():
    width = 18
    count = 1 << width
    white_edge = array("I", (step(row, width, 0) for row in range(count)))
    black_edge = array("I", (step(row, width, 1) for row in range(count)))
    good = bytearray((row & 0x3ff) == 0x2aa for row in range(count))
    for ticks in range(1, 45):
        good = bytearray(good[a] & good[b] for a, b in zip(white_edge, black_edge))
        if ticks == 43:
            assert not all(good)
    assert all(good)
    return count


def lower_witness():
    row, width = 0x11d0b0c3bb07a5, 53
    for _ in range(43):
        row = step(row, width, 0)
        width -= 1
        row &= (1 << width) - 1
    assert width == 10 and row == 0x1aa
    return row


if __name__ == "__main__":
    print(f"All {open_strip():,} width-18 rows force the first ten cells after 44 ticks.")
    print(f"The 43-tick ordinary cone ends in {lower_witness():#05x}, against required 0x2aa.")
