"""Scan K81's forced west pair for a spatial cycle on a periodic gate."""
import argparse
import json
from pathlib import Path


def pack(bits):
    return sum(int(bit) << t for t, bit in enumerate(bits))


def forced_pair(gate):
    period = 2 * len(gate)
    wall = pack(t % 2 for t in range(period))
    west = pack(t % 2 or gate[t // 2] == "0" for t in range(period))
    return west, wall


def west_step(pair, period):
    centre, east = pair
    tomorrow = (centre >> 1) | ((centre & 1) << (period - 1))
    return tomorrow ^ (centre | east), centre


def orbit(gate, budget):
    period = 2 * len(gate)
    start = forced_pair(gate)
    pair = anchor = start
    span, distance = 1, 0
    for i in range(1, budget + 1):
        pair = west_step(pair, period)
        distance += 1
        if pair == start:
            return {"steps": i, "preperiod": 0, "cycle": i}
        if pair == anchor:
            fast = slow = start
            for _ in range(distance):
                fast = west_step(fast, period)
            transient = 0
            while fast != slow:
                fast = west_step(fast, period)
                slow = west_step(slow, period)
                transient += 1
            return {"steps": i, "preperiod": transient, "cycle": distance}
        if distance == span:
            anchor, span, distance = pair, 2 * span, 0
    return {"steps": budget, "cycle": None}


def check_strip(data):
    rows = data["cyclic_rows"]
    width = data["largest_checked_model"]
    period = data["ticks"]
    gate = "".join("1" + "0" * (int(g) - 1) for g in data["gaps"])
    assert len(rows) == period == 2 * len(gate)
    assert all(len(row) == width + 2 and set(row) <= {"0", "1"} for row in rows)
    assert all(row[0] == str(t % 2) for t, row in enumerate(rows))
    assert "".join(row[1] for row in rows[::2]) == gate
    columns = [pack(col) for col in zip(*rows)]
    west, wall = forced_pair(gate)
    assert columns[0] == wall
    columns = [west] + columns
    pairs = list(zip(columns, columns[1:]))
    assert all(west_step(east, period) == prev for prev, east in zip(pairs, pairs[1:]))
    seen = {}
    for j, pair in enumerate(pairs, start=-1):
        if pair in seen:
            return [seen[pair], j]
        seen[pair] = j
    return None


def controls():
    # Check the spatial step against all pairs of columns up to period four.
    for p in range(1, 5):
        for b in range(1 << p):
            for c in range(1 << p):
                a, _ = west_step((b, c), p)
                for t in range(p):
                    triple = 4 * ((a >> t) & 1) + 2 * ((b >> t) & 1) + ((c >> t) & 1)
                    assert ((30 >> triple) & 1) == ((b >> ((t + 1) % p)) & 1)
    # Compare constant-memory cycle finding with a stored orbit on all short gates.
    for n in range(1, 5):
        for code in range(1 << n):
            gate = format(code, f"0{n}b")
            pair = forced_pair(gate)
            seen = {}
            while pair not in seen:
                seen[pair] = len(seen)
                pair = west_step(pair, 2 * n)
            found = orbit(gate, 3 * len(seen) + 1)
            assert (found["preperiod"], found["cycle"]) == (seen[pair], len(seen) - seen[pair])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("gaps", nargs="+")
    parser.add_argument("--budget", type=int, default=25_000_000)
    parser.add_argument("--strip", type=Path)
    args = parser.parse_args()
    if not __debug__ or args.budget < 1:
        parser.error("enable assertions and use a positive budget")
    controls()
    for gaps in args.gaps:
        if set(gaps) - set("123456789"):
            parser.error("supply a word of positive single-digit gaps")
        gate = "".join("1" + "0" * (int(g) - 1) for g in gaps)
        print(gaps, orbit(gate, args.budget), flush=True)
    if args.strip:
        print("repeated column pair in checked strip:", check_strip(json.loads(args.strip.read_text())))
