"""Prospective small-site tests under a completed wheel history and arbitrary eastern inputs."""

import argparse
from functools import lru_cache
from itertools import combinations
import json
from pathlib import Path

import numpy as np

from kick_predictor import WHEEL


WIDTH = 16
STATES = np.arange(1 << WIDTH, dtype=np.uint32)
EDGES = {wall: tuple((((STATES << 1) | wall) ^
                       (STATES | (STATES >> 1) | (east << (WIDTH-1)))) & ((1 << WIDTH)-1)
                      for east in (0, 1)) for wall in (0, 1)}


@lru_cache(maxsize=None)
def after_history(phase, ticks):
    """All current projected windows after matching U through this tick, inclusive."""
    start = phase - ticks + 1
    current = STATES[(STATES & 1) == int(WHEEL[start % 56])]
    for previous in range(start, phase):
        a, b = EDGES[previous % 2]
        current = np.union1d(a[current], b[current])
        current = current[(current & 1) == int(WHEEL[(previous+1) % 56])]
    return current


def departure_bits(states, phase, lead):
    # Through 15 ticks the eastern input cannot reach the gate of a width-16 window.
    current = states
    matches = np.ones(len(states), dtype=bool)
    for offset in range(1, lead+1):
        current = EDGES[(phase+offset-1) % 2][0][current]
        same = (current & 1) == int(WHEEL[(phase+offset) % 56])
        if offset < lead:
            matches &= same
    return matches & ~same


def small_sensors(present, labels, lead):
    low = (1 << (lead+1)) - 1
    yes = {int(w) & low for w in present[labels]}
    no = {int(w) & low for w in present[~labels]}
    assert not yes.intersection(no)
    for size in range(lead+2):
        for sites in combinations(range(lead+1), size):
            mask = sum(1 << s for s in sites)
            positive = {w & mask for w in yes}
            negative = {w & mask for w in no}
            if positive.isdisjoint(negative):
                def words(values):
                    return sorted("".join(str((v >> s) & 1) for s in sites) for v in values)
                return {"sites": [s+1 for s in sites], "depart_if":words(positive),
                        "stay_or_other_departure_if":words(negative)}
    raise AssertionError("The complete finite cone must decide the event.")


def run():
    records, old = [], []
    shapes = {2:6, 12:6, 22:6, 32:6, 42:6, 19:0, 39:0, 49:0, 52:3}
    for history, lead, classes in [(56,4,shapes), (140,10,[52])]:
        for target in classes:
            phase = (target-lead) % 56
            states = after_history(phase, history)
            actual = departure_bits(states, phase, lead)
            if lead == 4:
                marked = (states >> 2) & 7 == shapes[target]
            else:
                marked = ((states >> 5) & 7 == 3) & np.isin((states >> 8) & 7,[0,1,4,5,7])
            old.append({"history":history,"lead":lead,"target_phase":target,"windows":len(states),
                        "departures":int(actual.sum()), "marked":int(marked.sum()),
                        "false_positive":int((marked & ~actual).sum()), "false_negative":int((actual & ~marked).sum())})
    for target in (32,42,52):
        for lead in (4,6,8,10,12,14):
            phase = (target-lead) % 56
            states = after_history(phase, 140)
            actual = departure_bits(states, phase, lead)
            assert np.any(actual) and np.any(~actual)
            records.append({"history":140,"target_phase":target,"lead":lead,
                            "windows":len(states),"departure_windows":int(actual.sum()),
                            **small_sensors(states, actual, lead)})
    return {"width":WIDTH,"earlier_signatures":old,"sensors":records}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    result = run()
    args.output.write_bytes((json.dumps(result, indent=2) + "\n").encode())
    for row in result["sensors"]:
        print(row["target_phase"],row["lead"],row["sites"],row["depart_if"])
