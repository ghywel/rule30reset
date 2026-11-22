"""Replay the sharp second-white rule on finite strips and actual finite rows."""

def step(row, width, left, right):
    mask = (1 << width) - 1
    return (((row << 1) | left) ^ (row | (row >> 1) | (right << (width - 1)))) & mask

def image(rows, width, left):
    return {step(x, width, left, right) for x in rows for right in (0, 1)}

def minimum_gap(rows, width, minimum):
    rows = image(rows, width, 1)
    for _ in range(minimum):
        rows = image(rows, width, 0)
    # Union over all further white ticks. Stop only at a post-fixed set.
    while True:
        others = image(rows, width, 0) - rows
        if not others:
            return rows
        rows |= others

def second_white(row):
    # Directly evaluate the two Rule 30 ticks. Width three determines the low bit.
    return step(step(row, 3, 1, 0), 3, 0, 0) & 1

def finite_example(gaps, right_seed):
    requested = [bit for q in gaps for bit in [1] + [0] * q] + [1, 0]
    tick = len(requested)
    # Site 0 is at bit tick of a finite initial row. Fit one more prescribed
    # center tick by determining the next unknown left cell, using permutivity.
    row = (right_seed << (tick + 1)) | (requested[0] << tick)
    def update(x):
        return (x << 1) ^ (x | (x >> 1))
    for t in range(1, tick):
        z = row
        for _ in range(t):
            z = update(z)
        if (z >> tick) & 1 != requested[t]:
            row |= 1 << (tick - t)
    z = row
    for target in requested:
        assert (z >> tick) & 1 == target
        z = update(z)
    assert (z >> (tick + 1)) & 1
    print(f"finite row for {gaps}, low bit at site {-tick}: {row:#x}, black at tick {tick}")

if __name__ == "__main__":
    for size in (8, 9):
        for x in range(1 << size):
            assert bool(second_white(x)) == (not x & 1 or not x & 6)
    for width, minimums in [(8, (9, 9, 10)), (8, (10, 10)), (9, (9, 12))]:
        rows = set(range(1 << width))
        counts = []
        for gap in minimums:
            rows = minimum_gap(rows, width, gap)
            counts.append(len(rows))
        assert all(not second_white(x) for x in rows)
        print(f"width {width}, minimum gaps {minimums}, closed-set sizes {counts}")
    finite_example((9, 10), 0xA1FFDF9487)
    finite_example((9, 11), 0x6946A62487)
