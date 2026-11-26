"""claudeIntel's independent checks for the I262 carrying read (N25).

Shares no code with check_nine_tenths_ring.py. Rule 30 comes from its Wolfram number.
The only data taken from the kit is S9's six-cell potential at the upper corner
(highPot in Rule30DensityEscape.lean), read from the kit source itself.

1. All 256 eight-cell rows give a nonnegative loss; collect the zero-loss edges.
2. Prune vertices without a predecessor and a successor, round by round (as `survive`).
3. The survivors carry a phase mod 10 that every edge advances; read the two
   observed bits by phase.
4. Rebuild columns leftwards from the two ten-tick columns and find the first return,
   exactly and up to a time shift.
5. Check the 155 x 10 film on the ring, cell by cell, with its counts at sites 0 and 1,
   and compare it with S9's published film up to a time shift.
6. Control: every cycle of every ring of width 1..W has deficit D(p) = 6p+3A-8C >= 0
   at site 0, and none has D(p) = 0 (155 divides no width below 155).
7. The five faces are the hull of S9's corners; I262's fan weights reproduce every
   rational point inside with denominator at most 60.

Usage: python -I claudeIntel_ring_read.py [max_width]   (default 20)
"""
import re
import sys
from fractions import Fraction
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
KIT = HERE.parents[1] / "Rule30PrizeKit" / "lean" / "Ruliology" / "CellularAutomata"


def rule30(l, c, r):
    return (30 >> (4 * l + 2 * c + r)) & 1


def kit_high_potential():
    text = (KIT / "Rule30DensityEscape.lean").read_text(encoding="utf-8")
    body = re.search(r"def highPot : Array Nat := #\[([0-9,]+)\]", text).group(1)
    pot = [int(v) for v in body.split(",")]
    assert len(pot) == 64
    return pot


def bits6(x):
    return [(x >> i) & 1 for i in range(6)]


def pack(cells):
    return sum(b << i for i, b in enumerate(cells))


def zero_loss_graph(pot):
    """Edges x -> y over all 256 eight-cell rows, with S9's loss at the upper corner."""
    zero = set()
    least = None
    for row in range(256):
        cells = [(row >> i) & 1 for i in range(8)]          # cells j-1 .. j+6
        x = pack(cells[1:7])
        y = pack([rule30(cells[i - 1], cells[i], cells[i + 1]) for i in range(1, 7)])
        a, b = cells[1], cells[2]
        loss = pot[x] - pot[y] + 6 + 3 * (a & (1 - b)) - 8 * a
        least = loss if least is None else min(least, loss)
        if loss == 0:
            zero.add((x, y))
    return zero, least


def prune(edges, rounds):
    live = set(range(64))
    sizes = [len(live)]
    for _ in range(rounds):
        live = {v for v in live
                if any((p, v) in edges for p in live) and any((v, q) in edges for q in live)}
        sizes.append(len(live))
    return live, sizes


def phases(live, edges):
    """A phase mod 10 advanced by every surviving edge, or None."""
    sub = [(x, y) for (x, y) in edges if x in live and y in live]
    phase = {}
    for start in sorted(live):
        if start in phase:
            continue
        phase[start] = 0
        stack = [start]
        while stack:
            v = stack.pop()
            for x, y in sub:
                if x == v and y not in phase:
                    phase[y] = (phase[v] + 1) % 10
                    stack.append(y)
                if y == v and x not in phase:
                    phase[x] = (phase[v] - 1) % 10
                    stack.append(x)
    ok = all(phase[y] == (phase[x] + 1) % 10 for x, y in sub)
    return phase if ok else None


def left_column(c, r):
    return tuple(c[(t + 1) % 10] ^ (c[t] | r[t]) for t in range(10))


def main(max_width):
    pot = kit_high_potential()
    edges, least = zero_loss_graph(pot)
    print(f"1. least loss over 256 rows: {least}; zero-loss edges: {len(edges)}")
    assert least >= 0

    live, sizes = prune(edges, 6)
    print(f"2. pruning rounds: {sizes}")
    assert sizes[4] == 14 and sizes[4:] == [14] * (len(sizes) - 4)

    phase = phases(live, edges)
    assert phase is not None
    by_phase = {}
    for v in live:
        by_phase.setdefault(phase[v], []).append(v)
    # Normalize so that phase 9 is the one tick at which the observed site is white.
    white = [p for p in by_phase if all(bits6(v)[0] == 0 for v in by_phase[p])]
    assert len(white) == 1
    shift = (9 - white[0]) % 10
    norm = {(p + shift) % 10: sorted(vs) for p, vs in by_phase.items()}
    col = tuple(bits6(norm[t][0])[0] for t in range(10))
    right = tuple(bits6(norm[t][0])[1] for t in range(10))
    assert all(bits6(v)[0] == col[t] and bits6(v)[1] == right[t] for t in norm for v in norm[t])
    print(f"3. {len(norm)} phases, words per phase {[len(norm[t]) for t in range(10)]}")
    print(f"   observed site {''.join(map(str, col))}, right neighbour {''.join(map(str, right))}")
    assert col == (1,) * 9 + (0,) and right == (1, 0) * 5

    pairs = [(col, right)]
    while True:
        c, r = pairs[-1]
        nxt = (left_column(c, r), c)
        if nxt == pairs[0]:
            break
        pairs.append(nxt)
        assert len(pairs) < 10000
    width = len(pairs)
    rot = lambda p, s: (p[0][s:] + p[0][:s], p[1][s:] + p[1][:s])
    twisted = min(d for d in range(1, width + 1)
                  if any(pairs[d % width] == rot(pairs[0], s) for s in range(10)))
    glides = [(d, s) for d in range(1, width + 1) for s in range(10) if pairs[d % width] == rot(pairs[0], s)]
    print(f"4. first exact return of the ordered pair: {width}; first return up to a time shift: {twisted}")
    print(f"   returns with a time shift (columns, ticks): {glides}")
    assert width == 155 and glides[0] == (31, 2)

    # Site -d carries column d of the reconstruction; on the ring, site i is i mod 155.
    film = [[pairs[(-i) % width][0][t] for i in range(width)] for t in range(10)]
    bad = sum(film[(t + 1) % 10][i] != rule30(film[t][(i - 1) % width], film[t][i], film[t][(i + 1) % width])
              for t in range(10) for i in range(width))
    C = sum(film[t][0] for t in range(10))
    A = sum(film[t][0] & (1 - film[t][1]) for t in range(10))
    print(f"5. film: {10 * width} cells, {bad} update failures; C={C}, A={A}, D={6 * 10 + 3 * A - 8 * C}")
    assert bad == 0 and (C, A) == (9, 4)

    essay = (HERE / "s9-essay-draft.md").read_text(encoding="utf-8")
    codes = [int(v) for v in re.search(r'"\(9/10, 2/5\)", \{([0-9, ]+)\}, 155', essay).group(1).split(",")]
    s9 = [[(code >> i) & 1 for i in range(155)] for code in codes]
    matches = [s for s in range(10) if all(film[(t + s) % 10] == s9[t] for t in range(10))]
    print(f"   S9's published film equals this one after a time shift of {matches} ticks")
    assert matches

    print(f"6. rings of width 1..{max_width}, every cycle, deficit at site 0:")
    for w in range(1, max_width + 1):
        n = 1 << w
        s = np.arange(n, dtype=np.int64)
        mask = n - 1
        left = ((s << 1) | (s >> (w - 1))) & mask        # bit i holds cell i-1
        right_ = ((s >> 1) | (s << (w - 1))) & mask      # bit i holds cell i+1
        f = (left ^ (s | right_)) & mask
        cyc = np.ones(n, dtype=bool)
        while True:
            img = np.zeros(n, dtype=bool)
            img[f[cyc]] = True
            img &= cyc
            if img.sum() == cyc.sum():
                break
            cyc = img
        seen = np.zeros(n, dtype=bool)
        cycles = 0
        least = None
        fl = f.tolist()
        for start in np.flatnonzero(cyc).tolist():
            if seen[start]:
                continue
            p = D = 0
            v = start
            while not seen[v]:
                seen[v] = True
                a, b = v & 1, (v >> 1) & 1 if w > 1 else v & 1
                D += 6 + 3 * (a & (1 - b)) - 8 * a
                p += 1
                v = fl[v]
            cycles += 1
            rate = Fraction(D, p)
            least = rate if least is None else min(least, rate)
            assert D >= 0, (w, start)
            assert D > 0, (w, start)
        print(f"   width {w:2d}: {cycles:6d} cycles, least D(p)/p = {least}")

    fan_check()
    print("all checks pass")


def fan_check():
    """The five faces are exactly the hull of S9's five corners, and I262's three
    weight formulas reproduce the point with nonnegative weights wherever they are used."""
    F = Fraction
    corners = [(F(0), F(0)), (F(1, 3), F(0)), (F(3, 4), F(1, 4)), (F(9, 10), F(2, 5)), (F(1), F(1))]
    facets = []
    for i in range(5):
        for j in range(i + 1, 5):
            (c1, a1), (c2, a2) = corners[i], corners[j]
            side = [(c2 - c1) * (a - a1) - (a2 - a1) * (c - c1) for c, a in corners]
            if all(v >= 0 for v in side) or all(v <= 0 for v in side):
                facets.append((i, j))
    faces = [lambda c, a: a, lambda c, a: c - a, lambda c, a: 1 + 5 * a - 3 * c,
             lambda c, a: 1 + 2 * a - 2 * c, lambda c, a: 5 + a - 6 * c]
    tight = [[k for k, f in enumerate(faces) if f(c, a) == 0] for c, a in corners]
    print(f"7. hull edges {facets}; faces tight at each corner {tight}")
    assert facets == [(0, 1), (0, 4), (1, 2), (2, 3), (3, 4)]
    assert all(len(t) == 2 for t in tight)

    def weights(c, a):
        if 3 * a <= c:
            return [1 - 3 * c + 5 * a, 3 * c - 9 * a, 4 * a, F(0), F(0)]
        if 9 * a <= 4 * c:
            return [1 - 2 * c + 2 * a, F(0), 16 * c / 3 - 12 * a, 10 * a - 10 * c / 3, F(0)]
        return [(5 - 6 * c + a) / 5, F(0), F(0), 2 * (c - a), (9 * a - 4 * c) / 5]

    inside = outside = 0
    for q in range(1, 61):
        for cn in range(q + 1):
            for an in range(q + 1):
                c, a = F(cn, q), F(an, q)
                if all(f(c, a) >= 0 for f in faces):
                    w = weights(c, a)
                    assert min(w) >= 0 and sum(w) == 1
                    assert sum(wi * ci for wi, (ci, _) in zip(w, corners)) == c
                    assert sum(wi * ai for wi, (_, ai) in zip(w, corners)) == a
                    inside += 1
                else:
                    outside += 1
    print(f"   weights checked at {inside} rational points inside (denominators to 60); {outside} outside")


if __name__ == "__main__":
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 20)
