"""Forecast the next gate pulse from a white-wall reading, optionally two inside the trap."""
import argparse
from itertools import product
import json


TILES = {3: "1101001", 5: "11010001001"}


def common_gate_prefix(words):
    prefix = []
    for column in zip(*words):
        if len(set(column)) > 1:
            break
        prefix.append(column[0])
    return "".join(prefix)


COMMON_TILE_START = common_gate_prefix(TILES.values())


def possible(bit):
    return (0, 1) if bit == "?" else (int(bit),)


def pulse_schedule(prefix, warmed=True, trapped=False):
    """Read positive sites near to far. '?' denotes a site that was not measured."""
    if not prefix or prefix[0] != "1" or set(prefix) - set("01?"):
        raise ValueError("Start with a black pulse at site 1 and use 0, 1, or ? for the remaining sites.")
    row = list(prefix.ljust(9, "?"))
    if trapped:
        if any(observed not in ("?", expected) for observed, expected in zip(row[:4], "1110")):
            raise ValueError("The measured sites contradict the trapped black-pulse prefix 1110.")
        row[:4] = "1110"
    gaps = set()
    for b2,b3,b4,b5 in product(*(possible(x) for x in row[1:5])):
        if warmed or trapped:
            gap = b2 + (2 if b5 else 4)
        elif b2:
            gap = (3 if b4 or b5 else 5) if b3 else (5 if b4 else 4)
        else:
            gap = 4 if b3 or not (b4 or b5) else 2
        gaps.add(gap)
    result = {"next_pulse_intervals": sorted(gaps),
              "next_pulse_tick_offsets": sorted(2*g for g in gaps)}
    if trapped:
        pairs = set()
        second_gaps = {
            3 if b9 and (b7 or not b8) else 5
            for b7, b8, b9 in product(*(possible(bit) for bit in row[6:9]))
        }
        for g in gaps:
            if g == 3:
                pairs.update((g, 3 if b7 else 5) for b7 in possible(row[6]))
            else:
                pairs.update((g, 3 if (b8,b9)==(0,1) else 5)
                             for b8,b9 in product(possible(row[7]), possible(row[8])))
        pairs = {(g,h) for g,h in pairs if h in second_gaps}
        if not pairs:
            raise ValueError("These site readings contradict the trapped pulse return laws.")
        result["next_pulse_intervals"] = sorted({g for g,h in pairs})
        result["next_pulse_tick_offsets"] = [2*g for g in result["next_pulse_intervals"]]
        result["second_gap_intervals"] = sorted({h for g,h in pairs})
        # Both tiles include the pulse at their join.
        result["gap_pairs"] = sorted(pairs)
        result["second_pulse_tick_offsets"] = sorted({2*(g+h) for g,h in pairs})
        result["known_gate"] = common_gate_prefix(
            TILES[g] + TILES[h][1:] + COMMON_TILE_START[1:] for g,h in pairs)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("prefix", help="Sites 1, 2, ... at the pulse, e.g. 11??0 or 11100??01.")
    parser.add_argument("--white-sample", type=int, required=True,
                        help="Current white sample, with index zero at the first white reading of the alternating run.")
    parser.add_argument("--trapped", action="store_true", help="A prior observation has certified trap entry.")
    args = parser.parse_args()
    if args.white_sample < 0:
        parser.error("--white-sample must be nonnegative")
    try:
        print(json.dumps(pulse_schedule(args.prefix, args.white_sample >= 1, args.trapped), indent=2))
    except ValueError as error:
        parser.error(str(error))
