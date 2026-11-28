"""Count falls at -2 by their five-cell pattern and check distinct equal-pair witnesses."""
from pathlib import Path
from sys import argv

from birth_census import OBS_SHA, STOP
from unmarked_launch import load


def main(archive):
    obs = load(archive / "observations.u32le", OBS_SHA)
    center = bytearray(word & 1 for word in obs)
    west = bytearray(((word >> 1) & 1023) == 1 for word in obs)
    active = bytearray(a | b for a, b in zip(center, west))
    minus_two = bytearray(a ^ b for a, b in zip(active, west[1:]))
    last = -1
    total = exempt = adjacent = 0
    for t in range(STOP):
        if not minus_two[t] or minus_two[t+1]:
            continue
        total += 1
        if active[t]:
            q = t+1 if center[t+1] == center[t+2] else t+2
        elif center[t+1]:
            # With -1 and 0 white, the next centre equals the old +1.
            exempt += 1
            continue
        else:
            q = t
            adjacent += 1
        assert last < q and center[q] == center[q+1], (t, q, last)
        last = q
    print("falls 11001 other_forcing_falls silent_11000 active_births")
    print(total, exempt, total-exempt, adjacent, total-exempt-adjacent)


if __name__ == "__main__":
    main(Path(argv[1]))
