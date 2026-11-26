"""claudeIntel's independent checks for the I267 carrying read (N27).

No code is shared with replay_three_step_wall.py or the Lean. Rule 30 comes from its
Wolfram number. The only inputs taken from the record are S23's two good eight-cell
edge bands (EdgeGood8: 200 and 222, edge first) and I267's witness constants.

1. Lower witnesses: evolve the driven half beside each wall tape with the literal rule,
   compare the age-30/31 image, and check the three predecessors at every negative site,
   with wall bits equal to the prescribed wall and a black cell at -33.
2. Upper bound: from the two good bands, grow a cover one free eastern cell per tick
   (two ticks held at width 8, then 21 growing ticks, 23 ticks in all, ending at width 29),
   and require every band and every one of the 64 inverse starting states to give the
   exact edge f+3 for the third predecessor with an all-zero state at f-1.
3. Control: the same cover with only 22 ticks (age 30 for m >= 2) must fail.
"""
import json
import sys
from pathlib import Path


def rule(l, c, r):
    return (30 >> (4 * l + 2 * c + r)) & 1


# ---------- 1. the lower witnesses ----------

def driven(seed, wall, ticks, lo=-200):
    """Driven left half: row[p] for lo <= p <= 0; site 0 is wall(t) at age t."""
    row = {p: seed(p) for p in range(lo, 0)}
    row[0] = wall(0)
    for t in range(ticks):
        new = {p: rule(row.get(p - 1, 0), row[p], row[p + 1]) for p in range(lo + 1, 0)}
        new[lo] = 0
        new[0] = wall(t + 1)
        row = new
    return row


def at_depth(u):
    return lambda p: (u >> (-p)) & 1 if p <= 0 else 0


def witnesses():
    image = at_depth(6741236716)
    e1, e2 = at_depth(3732015686), at_depth(1402727289)
    e3 = lambda p: 1 if p <= -32 else at_depth(1557213517)(p)
    for adjacent in (False, True):
        depth, age = (1, 31) if adjacent else (2, 30)
        tape = 0x325fb326 if adjacent else 0x192fd993
        wall = lambda t: (tape >> t) & 1
        seed = lambda p: 1 if -depth <= p < 0 else 0
        row = driven(seed, wall, age)
        assert all(row[p] == image(p) for p in range(-150, 0)), adjacent
        edge = -depth - age
        assert row[edge] == 1 and all(row[p] == 0 for p in range(-150, edge))
        for p in range(-150, 0):
            assert rule(e1(p - 1), e1(p), e1(p + 1)) == image(p)
            assert rule(e2(p - 1), e2(p), e2(p + 1)) == e1(p)
            assert rule(e3(p - 1), e3(p), e3(p + 1)) == e2(p)
        assert (e1(0), e2(0), e3(0)) == (wall(age - 1), wall(age - 2), wall(age - 3))
        assert e3(-33) == 1 and -33 < edge + 3
        print(f"witness m={depth}, age {age}: image matches, edge {edge}; three predecessors exact at every "
              f"negative site checked to -150; wall bits {wall(age - 1)}{wall(age - 2)}{wall(age - 3)} prescribed; "
              f"third predecessor black at -33, left of f+3={edge + 3}")


# ---------- 2. the upper bound, exactly from the restart ----------
import numpy as np

ORIGIN = 60          # bit k of a row holds site k - ORIGIN; site 0 is the wall


def final_bands(D, ticks, late_wall=0):
    """All edge bands of width 29 at q+ticks, from a good 8-band at age q and depth D = m+q.

    For D <= 28 the 21 free bits are the cells at offsets 8..D-1 and the wall bits at ages
    q..q+28-D, which together fix everything the final band can depend on. D = None means the
    wall is out of reach (D >= 29): the free bits are offsets 8..28 of the band.
    """
    free = np.arange(1 << 21, dtype=np.int64)
    out = set()
    reach = 29 if D is None else D
    for u in (200, 222):
        row = np.zeros_like(free)
        edge = -(reach if D is not None else 30)            # interior: the wall 30 sites out cannot reach
        for i in range(8):
            if (u >> (7 - i)) & 1:
                row |= np.int64(1) << np.int64(ORIGIN + edge + i)
        ncells = (D - 8) if D is not None else 21
        for i in range(ncells):
            row |= ((free >> i) & 1) << np.int64(ORIGIN + edge + 8 + i)
        walls = [((free >> (ncells + k)) & 1) for k in range(29 - D)] if D is not None else []
        wall_at = lambda k: walls[k] if k < len(walls) else np.full_like(free, late_wall)
        if D is not None:
            row |= wall_at(0) << np.int64(ORIGIN)
        neg = (np.int64(1) << np.int64(ORIGIN)) - 1
        for k in range(ticks):
            row = ((row << 1) ^ (row | (row >> 1))) & neg
            if D is not None:
                row |= wall_at(k + 1) << np.int64(ORIGIN)
        f = edge - ticks
        val = np.zeros_like(free)
        for i in range(29):
            val |= ((row >> np.int64(ORIGIN + f + i)) & 1) << np.int64(28 - i)
        assert np.all((val >> 28) & 1 == 1)
        out |= set(np.unique(val).tolist())
    return out


def reads_edge(word, state):
    """word: width-29 band, edge first (bit 28 = cell f). Scan west from cells f+27, f+28."""
    cell = lambda i: (word >> (28 - i)) & 1
    a, ar, b, br, c, cr = state
    cvals = {}
    for p in range(27, -1, -1):
        y = cell(p)
        a, ar, b, br, c, cr = y ^ (a | ar), a, a ^ (b | br), b, b ^ (c | cr), c
        cvals[p - 1] = c
    west = (a, ar, b, br, c, cr)
    return cvals[3] == 1 and cvals[2] == 0 and cvals[1] == 0 and cvals[0] == 0 and west == (0,) * 6


def upper(ticks):
    union, per = set(), {}
    for D in list(range(10, 29)) + [None]:
        bands = final_bands(D, ticks)
        if D is not None and ticks == 23:
            assert bands == final_bands(D, ticks, late_wall=1), D     # later wall bits cannot reach
        per[D] = len(bands)
        union |= bands
    states = [tuple((s >> i) & 1 for i in range(6)) for s in range(64)]
    bad = [(w, s) for w in union for s in states if not reads_edge(w, s)]
    return union, per, bad


if __name__ == "__main__":
    witnesses()
    union, per, bad = upper(23)
    print(f"upper: {len(union)} distinct width-29 bands at age q+23 over depths 10..28 and the interior "
          f"(per depth {per}); failing (band, state) pairs: {len(bad)}")
    assert not bad
    out = Path(__file__).resolve().parent / "data" / "claudeIntel-band29-exact.json"
    out.write_text(json.dumps(sorted(union)))
    import re
    lean = (Path(__file__).resolve().parent / "three-step-extension.lean").read_text(encoding="utf-8")
    theirs = {int(v) for v in re.search(r"def cover29 : List Nat := \[([0-9,\s]+)\]", lean).group(1).replace(",", " ").split()}
    if theirs:
        print(f"   contained in I267's cover29 ({len(theirs)} words): {union <= theirs}")
    union22, _, bad22 = upper(22)
    print(f"control: after 22 ticks (age 30 for m >= 2): {len(union22)} bands, failing pairs {len(bad22)}")
    assert bad22
    print("all checks pass")
