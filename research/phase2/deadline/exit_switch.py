"""Audit the switch at sample 2705 by evolving site arrays with the Rule 30 table."""
import argparse
import itertools
import json
from pathlib import Path

import numpy as np

from entry_cells import MASK, SAMPLE, SEEDS, physical_rows, records, sites
from replay import step
from tables import literal


LAST_X = 2705
TABLE = np.array([0, 1, 1, 1, 1, 0, 0, 0], dtype=np.uint8)


def columns(words, width):
    return np.array([(words >> i) & 1 for i in range(width)], dtype=np.uint8)


def advance(cells, wall):
    left = np.empty_like(cells[:-1])
    left[0] = wall
    left[1:] = cells[:-2]
    return TABLE[4 * left + 2 * cells[:-1] + cells[1:]]


def pack(cells, width):
    return sum(cells[i].astype(np.uint32) << i for i in range(width))


def extension_profile(prefix, trapped):
    # Eleven double steps use exactly 38 initial sites for the endpoint.
    east = np.arange(1 << 14, dtype=np.uint64)
    cells = columns((east << 24) | (prefix & (2**24-1)), 38)
    first = np.full(len(east), -1, dtype=int)
    for elapsed in range(12):
        hits = trapped[pack(cells, 16)]
        first[(first < 0) & hits] = elapsed
        if elapsed < 11:
            cells = advance(advance(cells, 0), 1)
    ok = first == 11
    known = (prefix >> 24) & ((1 << 14) - 1)
    bad = ~ok[east ^ known]
    for i in range(14):
        n = 1 << i
        parts = bad.reshape(-1, 2*n)
        parts[:, n:] |= parts[:, :n]
    free = np.flatnonzero(~bad).tolist()
    size = max(x.bit_count() for x in free)
    minimum = [(2**14 - 1) ^ x for x in free if x.bit_count() == size]
    k = next(k for k in range(15) if not bad[(2**14 - 1) ^ (2**k - 1)])
    return {"actual_east": known, "minimum_extra_sites": [[24+i for i in sites(x)] for x in minimum],
            "least_prefix_given24": 24 + k, "entry_offsets_by_east_pair": [
                dict(zip(*[a.tolist() for a in np.unique(first[j::4], return_counts=True)]))
                for j in range(4)],
            "shorter_prefix_counterexample_east": next((int(v) for v in east[~ok]
                if k and (int(v) ^ known) % (2**(k-1)) == 0), None)}


def tip_orbit(a, b, width):
    # The rightmost site is numbered 24+t in both coordinates; it can be white.
    shift = 24 - width
    state = (a >> shift, b >> shift)
    seen = []
    while state not in seen:
        seen.append(state)
        if (state[0] ^ state[1]) & 3:
            return None
        state = tuple(step(x, 0) >> 1 for x in state)
    return {"width": width, "pairs": seen, "cycle_start": seen.index(state)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("scc", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    gate = args.kit / "lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean"
    trap = set(literal(gate, "trapCodes"))
    table = np.zeros(2**16, dtype=bool)
    table[list(trap)] = True
    words = np.arange(2**18, dtype=np.uint32)
    cells = advance(advance(columns(words, 18), 0), 1)
    dest = pack(cells, 16)
    enters = ~table[words & MASK] & table[dest]
    assert int(enters.sum()) == 7640
    by_code, _ = records(args.scc)
    out = {}
    for seed in SEEDS:
        rows = physical_rows(seed)[1::2]
        end = rows[SAMPLE - 1] & (2**18 - 1)
        assert enters[end] and enters[end ^ (1 << 17)]
        assert all(not enters[end ^ (1 << i)] for i in range(17))
        mask24 = 2**24 - 1
        chances = []
        for s, row in enumerate(itertools.islice(rows, LAST_X + 1)):
            x = row & mask24
            if by_code.get(x) != 519:
                continue
            exits = tuple(j for j in range(4)
                         if by_code.get(step(step(x | j << 24, 0), 1) & mask24) != 519)
            if exits:
                chances.append([s, x, list(exits), (row >> 24) & 3])
        last = rows[LAST_X]
        earlier_same = [s for s in range(LAST_X) if (rows[s] ^ last) & mask24 == 0]
        out[str(seed)] = {
            "window_at_2705": last & mask24, "extension": extension_profile(last, table),
            "crossing_after_flip": [int(dest[end ^ (1 << i)]) for i in range(18)],
            "already_inside_after_flip": [i + 1 for i in range(18)
                                         if table[(end ^ (1 << i)) & MASK]],
            "opportunities": chances, "prior_same_window": earlier_same,
            "low24_after_exit": [row & mask24 for row in rows[LAST_X:SAMPLE+1]],
        }
    out["tip_orbit"] = next(o for width in range(2, 25)
                            if (o := tip_orbit(*SEEDS, width)) is not None)
    args.out.write_text(json.dumps(out, separators=(",", ":")) + "\n", encoding="ascii")


if __name__ == "__main__":
    main()
