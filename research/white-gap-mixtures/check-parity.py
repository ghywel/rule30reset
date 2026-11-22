"""Verify the three-mode certificate and the relaxed strip's sharp fault slope.

Run with Python 3, without external packages. A state holds the first twelve
cells right of the prescribed target column. Both exterior bits are checked.
"""
import gzip
import json
from pathlib import Path

WIDTH = 12
ROWS = 1 << WIDTH


def unpack(planes):
    values = [int(text, 16) for text in planes]
    return [sum(((plane >> row) & 1) << bit for bit, plane in enumerate(values))
            for row in range(ROWS)]


def step(row, driver, exterior):
    result = 0
    for site in range(WIDTH):
        left = driver if site == 0 else (row >> (site - 1)) & 1
        middle = (row >> site) & 1
        right = exterior if site == WIDTH - 1 else (row >> (site + 1)) & 1
        result |= (left ^ (middle | right)) << site
    return result


def phase(z):
    return z if z < 17 else z - 17


def successors(z):
    """States 17 through 26 remember that the preceding gap had length ten."""
    if z < 16 or 17 <= z < 26:
        yield z + 1
    if z == 26:
        yield 10
        yield 0  # this closes a nine immediately after a ten
    if 9 <= z <= 16:
        yield 17 if z == 10 else 0


def advance(mode, before, after):
    if mode == 0:
        return 0
    if after == 0:
        return 3 - mode if before == 9 else 1
    return 1 if after >= 10 else mode


def main():
    path = Path(__file__).with_name("parity-certificate.json.gz")
    with gzip.open(path, "rt", encoding="utf-8") as stream:
        data = json.load(stream)
    rank = [unpack(row) for row in data["charge_planes"]]
    modes = [unpack(row) for row in data["mode_planes"]]
    assert len(rank) == len(modes) == 27
    assert max(map(max, rank)) == 20 and max(map(max, modes)) == 2
    updates = [[[step(row, driver, exterior) for exterior in (0, 1)]
                for row in range(ROWS)] for driver in (0, 1)]

    def costs(z, row, y, new):
        before, after = phase(z), phase(y)
        mode = modes[z][row]
        observed = before == 0 or bool(row & 1)
        expected = before == 0 or before >= 3 or (before == 2 and mode == 2)
        fault = observed != expected or modes[y][new] != advance(mode, before, after)
        return int(fault), int(z == 26 and y == 0)

    edges = 0
    for z in range(27):
        for row in range(ROWS):
            for y in successors(z):
                for new in updates[int(phase(z) == 0)][row]:
                    fault, join = costs(z, row, y, new)
                    assert fault + rank[y][new] <= rank[z][row] + 2 * join
                    edges += 1
    cycle = data["tight_cycle"]
    assert cycle[0] == cycle[-1]
    faults = joins = 0
    for v, w in zip(cycle, cycle[1:]):
        z, row = divmod(v, ROWS)
        y, new = divmod(w, ROWS)
        assert y in successors(z) and new in updates[int(phase(z) == 0)][row]
        fault, join = costs(z, row, y, new)
        faults += fault
        joins += join
    assert (edges, len(cycle) - 1, faults, joins) == (286720, 35, 2, 1)
    print(f"Verified {edges:,} edges. The 35-tick free-exterior cycle has two faults and one 10-to-9 join.")


if __name__ == "__main__":
    main()
