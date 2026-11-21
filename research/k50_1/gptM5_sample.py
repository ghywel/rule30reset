"""Replay placego L1612's sampler and settle the outstanding rows when kit certificates apply.

Usage: python3 research/k50_1/gptM5_sample.py [--horizon 1000000] [--kit Rule30PrizeKit]
The historical sample has 1,500 draws, Random(2), bit 29 black, horizon 6,001.
Cell i+1 is bit i. All positive columns are evolved, with white initial exterior.
An entry permits stopping at once: membership invokes a kit invariant. A finite
periodic-looking gate suffix is recorded as an observation if no certificate is found.
"""
import argparse
import ast
from collections import Counter, deque
import hashlib
import json
from pathlib import Path
import random
import re


def step(row, tick):
    """One full tick of the half-line driven by a column black at even times."""
    left = (row << 1) | (1 - (tick % 2))
    return left ^ (row | (row >> 1))


def lean_list(source, name):
    """Read a literal Lean list of numbers, booleans, pairs or lists."""
    match = re.search(rf"^def {name}\s*:[^=]+:=\s*\[", source, re.M)
    if match is None:
        raise ValueError(f"Missing literal list {name}")
    start = match.end() - 1
    depth = 0
    for end in range(start, len(source)):
        ch = source[end]
        if ch == "[":
            depth += 1
        elif ch == "]":
            depth -= 1
            if not depth:
                return ast.literal_eval(source[start:end + 1].replace("false", "False")
                                        .replace("true", "True"))
    raise ValueError(f"Unterminated literal list {name}")


def encode(bits):
    return sum(int(bit) << i for i, bit in enumerate(bits))


class Destinations:
    """Literal witnesses in the kit's GateTrap, SidewaysLocks and Ether modules."""

    def __init__(self, kit_root):
        sources = Path(kit_root) / "lean/Ruliology/CellularAutomata"
        trap = (sources / "Rule30Certificates/GateTrap.lean").read_text()
        locks = (sources / "Rule30SidewaysLocks.lean").read_text()
        ether = (sources / "Rule30Ether.lean").read_text()
        self.trap = set(lean_list(trap, "trapCodes"))
        self.locks = []
        for name, width, word in (("lock7", 30, "0101000"), ("lock7b", 45, "0010100")):
            classes = lean_list(locks, name + "Codes")
            lookup = {code: phase for phase, codes in enumerate(classes) for code in codes}
            if len(classes) != 7 or len(lookup) != sum(map(len, classes)):
                raise ValueError(f"Wrong or overlapping {name} phases")
            self.locks.append((name, width, word, lookup))
        self.ether = lean_list(ether, "etherTable")
        states = lean_list(ether, "wallStates")
        self.walls = {(phase, encode(strip)) for phase, strip in states}
        if len(self.trap) != 829 or len(self.walls) != 109:
            raise ValueError("Kit certificate sizes differ from the recorded versions")
        self.first_six = []
        self.next_seven = []
        for phase in range(4):
            # The alternating centre is ether column 3, in phase (t+1) or (t+3).
            self.first_six.append(encode(self.ether[(3 + p) % 7][phase] for p in range(1, 7)))
            self.next_seven.append(encode(self.ether[(3 + p) % 7][phase] for p in range(7, 14)))

    def classify(self, row, tick):
        """Return a finite membership witness that proves one of the two RD alternatives."""
        if tick % 2:
            win = row & 65535
            if win in self.trap:
                return {"class": "trap", "width": 16, "window": win}
            for name, width, word, lookup in self.locks:
                win = row & ((1 << width) - 1)
                if win in lookup:
                    return {"class": name, "period": len(word), "phase": lookup[win],
                            "width": width, "window": win}
        for offset in (1, 3):
            phase = (tick + offset) % 4
            if (row & 63) != self.first_six[phase]:
                continue
            # The kit allows every k with (3+k)%7=2. Every further seven ether
            # cells contain a black bit, so this loop terminates on a finite row.
            k = 6
            tail = row >> k
            while True:
                wall = tail & 8191
                if (phase, wall) in self.walls:
                    return {"class": "ether", "period": 2, "k": k, "phase": phase,
                            "offset": offset, "wall": wall, "width": k + 13,
                            "window": row & ((1 << (k + 13)) - 1)}
                if (tail & 127) != self.next_seven[phase]:
                    break
                tail >>= 7
                k += 7
        return None


def controls(dest):
    """Check orientation and both certified seven-lock input transitions."""
    for row in range(256):
        for tick in range(2):
            scalar = []
            for i in range(9):
                left = (row >> (i - 1)) & 1 if i else int(tick == 0)
                centre = (row >> i) & 1
                right = (row >> (i + 1)) & 1
                scalar.append(left ^ (centre | right))
            assert step(row, tick) == encode(scalar)
    for name, width, word, lookup in dest.locks:
        mask = (1 << width) - 1
        for code, phase in lookup.items():
            assert code & 1 == int(word[phase]), name
            for high in range(4):
                ext = code | (high << width)
                nxt = step(step(ext, 1), 2) & mask
                assert lookup[nxt] == (phase + 1) % 7, name
    for phase in range(4):
        assert dest.next_seven[phase] != 0
        assert dest.ether[3][phase] == bool(phase % 2)
    # The kit gives these two lock entries at specific odd ticks and phases.
    for seed, tick, name, phase in [(1891, 27, "lock7", 4), (3793493, 29, "lock7b", 6)]:
        row = seed
        for t in range(tick):
            row = step(row, t)
        witness = dest.classify(row, tick)
        assert witness and (witness["class"], witness["phase"]) == (name, phase)


def replay(dest):
    rng = random.Random(2)
    outstanding = []
    entry = []
    for draw in range(1, 1501):
        seed = rng.getrandbits(29) | (1 << 29)
        row = seed
        for t in range(6002):
            if t % 2 and (row & 65535) in dest.trap:
                entry.append(t)
                break
            row = step(row, t)
        else:
            outstanding.append((draw, seed))
    median = sorted(entry)[len(entry) // 2]
    if (len(entry), median) != (1442, 29):
        raise ValueError("L1612 count or upper median failed to replay")
    return outstanding, median


def classify_seed(dest, seed, horizon):
    row = seed
    suffix = deque(maxlen=4096)
    for t in range(horizon + 1):
        witness = dest.classify(row, t)
        if witness is not None:
            return {"tick": t, **witness}
        if t % 2:
            suffix.append(row & 1)
        if t < horizon:
            row = step(row, t)
    tail = bytes(suffix)
    period = next((p for p in range(1, min(256, len(tail) // 2) + 1)
                   if tail[p:] == tail[:-p]), None)
    return {"class": "unresolved", "through": horizon, "suffix_bits": len(tail),
            "observed_suffix_period": period}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kit", type=Path, default=Path(__file__).resolve().parents[2] / "Rule30PrizeKit")
    parser.add_argument("--horizon", type=int, default=1_000_000)
    args = parser.parse_args()
    if args.horizon < 6001:
        parser.error("the follow-up horizon must reach the historical cutoff of 6,001")
    dest = Destinations(args.kit)
    controls(dest)
    remaining, median = replay(dest)
    digest = hashlib.sha256("".join(f"{i} {seed}\n" for i, seed in remaining).encode()).hexdigest()
    print(json.dumps({"drawn": 1500, "trap_by_6001": 1500 - len(remaining), "upper_median": median,
                      "remaining": len(remaining), "draw_seed_sha256": digest}), flush=True)
    counts = Counter()
    for i, seed in remaining:
        result = classify_seed(dest, seed, args.horizon)
        print(json.dumps({"draw": i, "seed": seed, **result}), flush=True)
        counts[result["class"]] += 1
    print(json.dumps({"horizon": args.horizon, "class_counts": counts}, sort_keys=True))


if __name__ == "__main__":
    main()
