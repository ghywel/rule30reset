"""Replay the R10 singleton backwards, using Wolfram's eight-entry truth table."""
import json

SEED = 0x19da5dcb
END = 0x6473c7a3f43df01e967
AGE = 46


def cell(outer, centre, inner):
    return (30 >> (4 * outer + 2 * centre + inner)) & 1


def parents(row):
    """Try both wall colours. Solve each following bit and check the white exterior."""
    width = row.bit_length() - 1
    if width == 0:
        return
    for head in (0, 1):
        inner, centre, candidate = 0, head, head
        for i in range(width - 1):
            want = (row >> i) & 1
            outer, = [b for b in (0, 1) if cell(b, centre, inner) == want]
            candidate |= outer << (i + 1)
            inner, centre = centre, outer
        if centre and cell(0, centre, inner) == (row >> (width - 1)) & 1:
            # The next image cell is cell(0, 0, centre) = 1. Both tails then vanish.
            yield candidate


def previous_even(rows):
    return {p for z in rows for m in parents(z) for p in parents(m) if p & 1}


def main():
    root = SEED
    for t in range(AGE + 1):
        if t % 2 == 0:
            assert root & 1
        if t < AGE:
            cells = [0] + [(root >> i) & 1 for i in range(root.bit_length())] + [0, 0]
            root = sum(cell(cells[i + 2], cells[i + 1], cells[i]) << i
                       for i in range(len(cells) - 2))
    assert root == END
    result = []
    starts = set()
    for parent in sorted(previous_even({root})):
        layer = {parent}
        counts = [1]
        for _ in range(AGE // 2 - 1):
            layer = previous_even(layer)
            counts.append(len(layer))
        starts.update(layer)
        result.append({"row_at_44": hex(parent), "counts_at_44_down_to_0": counts,
                       "seeds_at_0": sorted(map(hex, layer))})
    assert len(result) == 2 and starts == {SEED}
    print(json.dumps(result, indent=1))


if __name__ == "__main__":
    main()
