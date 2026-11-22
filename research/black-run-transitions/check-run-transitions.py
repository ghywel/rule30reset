"""Reproduce the two-run classification and the PR 381 finite-reader comparison."""
from functools import cache

AGES = (0, 8, 8, 8, 15, 8, 16, 4, 14)
SEEDS = [(681, 627), (499, 59), (1925, 2995), (670067, 216443),
         (5689, 4467), (6183621, 469425), (1766, 659), (4505173, 2721349)]
def age(q):
    return AGES[q] if q < 9 else 0

def rule_step(row, left):
    return ((row << 1) | left) ^ (row | (row >> 1))

def two_runs():
    for r, (white, black) in enumerate(SEEDS, 1):
        a = age(r) - 1
        word = [1] * a + [0] + [1] * r
        for want, seed in enumerate((white, black)):
            # Fit a genuine finite left half, then run the whole finite row freely.
            shift = len(word)
            row = (seed << (shift + 1)) | (word[0] << shift)
            for t in range(1, shift):
                z = row
                for _ in range(t):
                    z = rule_step(z, 0)
                row |= (((z >> shift) & 1) ^ word[t]) << (shift - t)
            for bit in word:
                assert (row >> shift) & 1 == bit
                row = rule_step(row, 0)
            assert (row >> (shift + 1)) & 1 == want
    print("All 16 ordinary witnesses replayed")

def pr381(a, b, r):
    return (r >= 9 or (r == 7 and b >= 4) or (r == 2 and b >= 8)
            or (r % 2 == 1 and (b >= 8 or (b in (2, 6) and a >= 4)
                                  or (b == 4 and a >= 8)))
            or (r % 2 == 0 and b == 1 and a >= 8))

def audit(width):
    mask = (1 << width) - 1
    full = frozenset(range(mask + 1))
    @cache
    def image(rows, bit):
        return frozenset((((x << 1) | bit) ^ (x | (x >> 1) | (z << (width-1)))) & mask
                         for x in rows for z in (0, 1))
    if width == 7:
        for r in range(1, 10):
            rows = full
            if r < 9:
                for _ in range(age(r)):
                    rows = image(rows, 1)
                rows = image(rows, 0)
            for _ in range(r):
                rows = image(rows, 1)
            assert {x & 1 for x in rows} == {int(r in (2, 4, 6))}
        print("All width-seven upper bounds replayed")
        return
    # Check the raw sets directly. The product remembers the two previous
    # lengths, capped at nine, as well as the full reader state.
    start = (full, 0, 0)
    ids = {start: 0}
    states = [start]
    edges = []
    for pool, a, b in states:
        z = pool
        row = []
        for r in range(1, 65):
            previous, z = z, image(z, 1)
            target = (image(z, 0), b, min(9, r))
            if target not in ids:
                ids[target] = len(states)
                states.append(target)
            row.append((ids[target], len({x & 1 for x in z}) == 1, pr381(a, b, r)))
            if r >= 9 and z == previous:
                break
        else:
            raise AssertionError("black-run saturation cutoff not reached")
        edges.append(row)
    # A decreasing integer rank bounds exceptions along a path containing
    # only definite reader outputs. The reverse direction holds edge by edge.
    assert all(not pr or determined for row in edges for _, determined, pr in row)
    rank = [0] * len(edges)
    for _ in range(len(states) + 1):
        changed = [max([0] + [rank[j] + int(not pr) for j, det, pr in row if det]) for row in edges]
        if changed == rank:
            break
        rank = changed
    else:
        raise AssertionError("positive-weight cycle")
    assert max(rank) == 2
    print(f"Width {width}, {len(states)} unminimized product states, maximum exceptions {max(rank)}")

if __name__ == "__main__":
    two_runs()
    for w in (5, 6, 7):
        audit(w)
