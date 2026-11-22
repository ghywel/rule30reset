#!/usr/bin/env python3
"""claudeCloud_three_gap_upper.py: companion to claudeCloud_three_gap_replay.py (ledger K64, path 2). I85 says its ten
upper bounds hold "with a fresh exterior bit each tick", on a strip wider than the kit's eight cells. For each of the
ten words, and for every other three-gap word as a control, this finds the least strip width W (8..26) at which a
free exterior bit at every tick still puts the nearest eight cells into the kit's set G.

A state of the W-cell strip: bit k = the cell k + 1 places right of the driven site. One tick with driver a and
exterior z: left = (s << 1) | a, right = (s >> 1) | (z << (W - 1)), new = left xor (s or right), all on W bits.

    python3 claudeCloud_three_gap_upper.py
"""
import itertools
import numpy as np

G = 0x2020000000202000202000000020202020200000002000000020000000202020
GSET = np.array([(G >> s) & 1 for s in range(256)], dtype=bool)


def reach(word, W):
    mask = np.uint32((1 << W) - 1)
    S = np.ones(1 << W, dtype=bool)
    drive = [b for q in word for b in [1] + [0] * q]
    idx = np.arange(1 << W, dtype=np.uint32)
    for a in drive:
        s = idx[S]
        left = ((s << np.uint32(1)) | np.uint32(a)) & mask
        out = np.zeros(1 << W, dtype=bool)
        for z in (0, 1):
            right = (s >> np.uint32(1)) | np.uint32(z << (W - 1))
            out[(left ^ (s | right)) & mask] = True
        S = out
    return idx[S]


def least_width(word, top=26):
    for W in range(8, top + 1):
        if GSET[(reach(word, W) & np.uint32(255))].all():
            return W
    return None


def main():
    ten = [(q, 16, 16) for q in range(9, 17)] + [(16, 10, 15), (16, 10, 16)]
    for w in ten:
        print('%s: least width with a free exterior: %s' % (w, least_width(w)), flush=True)
    others = [w for w in itertools.product(range(9, 17), repeat=3) if w not in ten]
    import random
    rnd = random.Random(20261122)
    sample = rnd.sample(others, 12)
    for w in sample:
        print('control %s: at width 22 the free strip %s' % (w, 'puts every state into G (unexpected)' if GSET[(reach(w, 22) & np.uint32(255))].all() else 'leaves states outside G'), flush=True)


if __name__ == '__main__':
    main()
