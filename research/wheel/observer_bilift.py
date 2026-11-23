"""Bidirectional finite-horizon lift for the 48-sample clean-gate observer."""

import argparse
from itertools import count
from pathlib import Path

import numpy as np
from trap_observer import FACTORS
from wheel_bridge import table, tick


def candidate_layers(kit, length):
    # Six future samples require 13 cells and are known from the initial 16.
    rows = np.arange(65536, dtype=np.int64)
    outside = np.ones(65536, dtype=bool)
    outside[table(kit, "trapCodes", "Rule30Certificates/GateTrap")] = False
    trace = np.zeros(65536, dtype=np.int64)
    u = rows.copy()
    for i in range(7):
        trace |= (u & 1) << i
        u = tick(tick(u, 0), 1) & 65535
    active = []
    for t in range(length):
        ok = outside.copy()
        for w in FACTORS:
            if t + len(w) <= length:
                ok &= (trace & ((1 << len(w)) - 1)) != int(w[::-1], 2)
        active.append(rows[ok])
    return active


def successors(rows, width):
    if width >= 60:
        rows = rows.astype(object)
    for e in range(4):
        r = rows + (e << width)
        yield tick(tick(r, 0), 1) & ((1 << width) - 1)


def in_sorted(values, universe):
    if not len(universe):
        return np.zeros(len(values), dtype=bool)
    return universe[np.minimum(np.searchsorted(universe, values), len(universe) - 1)] == values


def strip_layers(kit, length, last_width=None):
    """Return the forward and bidirectional layers at successive spatial widths."""
    if length < 1:
        raise ValueError("The sample length must be positive")
    layers = candidate_layers(kit, length)
    for width in count(16):
        front = layers.copy()
        for t in range(length - 1):
            here, following = front[t : t + 2]
            found = np.zeros(len(following), dtype=bool)
            if len(following):
                for dest in successors(here, width):
                    ids = np.minimum(np.searchsorted(following, dest), len(following) - 1)
                    valid = following[ids] == dest
                    found[ids[valid]] = True
            front[t + 1] = following[found]
        both = front.copy()
        for t in reversed(range(length - 1)):
            here, following = both[t : t + 2]
            keep = np.zeros(len(here), dtype=bool)
            for dest in successors(here, width):
                keep |= in_sorted(dest, following)
            both[t] = here[keep]
        yield width, front, both
        if not len(both[0]) or width == last_width:
            return
        if width >= 60:
            both = [rows.astype(object) for rows in both]
        layers = [np.concatenate((rows, rows + (1 << width))) for rows in both]


def run(args):
    if args.width is not None and args.width < 16:
        raise ValueError("The starting spatial width is 16")
    for width, front, both in strip_layers(args.kit, args.length, args.width):
        print(width, [len(rows) for rows in front], [len(rows) for rows in both], flush=True)
        if args.save:
            np.savez_compressed(args.save, width=width, **{f"t{i}": a for i, a in enumerate(both)})


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("kit", type=Path)
    p.add_argument("--width", type=int, help="Stop at this spatial width even if survivors remain.")
    p.add_argument("--length", type=int, default=48)
    p.add_argument("--save", type=Path)
    run(p.parse_args())
