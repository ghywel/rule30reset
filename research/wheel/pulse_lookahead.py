"""Sharp spatial radii for the second return of a sampled black pulse."""
import argparse
import json
from pathlib import Path

import numpy as np


def step(row, wall):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def white_step(row):
    return step(step(row, 0), 1)


def next_gap(row):
    return 4 + ((row >> 1) & 1) - 2 * ((row >> 4) & 1)


def check_witness(seed, radius):
    row = seed
    for wall in (1, 0, 1):
        row = step(row, wall)
    assert row & 1
    initial = row
    arrivals = []
    for interval in range(1, 11):
        row = white_step(row)
        if row & 1:
            arrivals.append(interval)
            if len(arrivals) == 2:
                break
    assert len(arrivals) == 2
    return {"finite_black_seed": hex(seed), "pulse_prefix": hex(initial & ((1 << radius)-1)),
            "gaps": [arrivals[0], arrivals[1] - arrivals[0]]}


def analyze():
    # A 15-site observation at any white sample after the first is the image of
    # 18 sites three ticks earlier. The four-tick and six-tick pulses use less.
    originals = np.arange(1 << 18, dtype=np.int64)
    current = white_step(step(originals, 1))
    pulse = (current & 1) != 0
    seeds, rows = originals[pulse], current[pulse] & ((1 << 15)-1)
    result = []
    for g in range(2, 6):
        selected = next_gap(rows) == g
        start, source = rows[selected], seeds[selected]
        following = start.copy()
        for _ in range(g):
            following = white_step(following)
        assert np.all(following & 1)
        second = next_gap(following)
        for radius in range(16):
            p = start & ((1 << radius)-1)
            lo = np.full(1 << radius, 6)
            hi = np.zeros(1 << radius, dtype=np.int64)
            np.minimum.at(lo, p, second)
            np.maximum.at(hi, p, second)
            differing = np.flatnonzero(hi > lo)
            if not differing.size:
                break
            index = differing[0]
            last = [int(source[np.flatnonzero((p == index) & (second == value))[0]])
                    for value in (lo[index], hi[index])]
        assert 0 < radius <= 5+2*g
        witnesses = [check_witness(s, radius) for s in last]
        assert all(w["gaps"][0] == g for w in witnesses)
        assert witnesses[0]["gaps"][1] != witnesses[1]["gaps"][1]
        assert int(witnesses[0]["pulse_prefix"],16) ^ int(witnesses[1]["pulse_prefix"],16) == 1 << (radius-1)
        result.append({"first_gap":g, "second_gap_radius":radius, "causal_upper":5+2*g,
                       "possible_second_gaps":np.unique(second).tolist(), "witnesses":witnesses})
    return {"kit_black_first":True,"physical_pulse_tick":3,"initial_cone_bits":18,"classes":result}


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("output", type=Path)
    result = analyze()
    output = (json.dumps(result, indent=2)+"\n").encode()
    p.parse_args().output.write_bytes(output)
    for row in result["classes"]:
        print(row["first_gap"], row["second_gap_radius"], row["possible_second_gaps"])
