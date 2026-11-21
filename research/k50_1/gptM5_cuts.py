"""Exact finite right halves under the black-even alternating driver (K50.1).

Cut the kit's 7-by-4 ether at columns 0..max-cut at each of the two
alignments of its B4 column. Record first mismatch and both certified
terminals. A cut is white to infinity beyond its last copied column.
Bit j of an integer is physical column j+1. All times count single ticks.
"""
import argparse
import json
from pathlib import Path

from gptM5_sample import Destinations, controls as shared_controls, encode, step


def ether_rows(table, width):
    rows = []
    for phase in range(4):
        motif = encode(table[(3 + p) % 7][phase] for p in range(1, 8))
        rows.append(motif * (((1 << (7 * ((width + 6) // 7))) - 1) // 127))
    return rows


def controls(dest):
    shared_controls(dest)
    table = dest.ether
    for t in range(4):
        assert table[3][(t + 1) % 4] == (t % 2 == 0)
        for j in range(7):
            assert table[j][(t + 1) % 4] == (
                table[(j - 1) % 7][t] ^ (table[j][t] or table[(j + 1) % 7][t]))
    empty = 0
    for t in range(293):
        empty = step(empty, t)
    assert empty & 65535 == 49415 and 49415 in dest.trap
    # Rule30EtherWallWitness.wsA, with an ether prefix ending in B3 at k=6.
    refs = ether_rows(table, 100)
    ws_a = encode([0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0])
    row = (refs[1] & 63) | (ws_a << 6)
    for t in range(65):
        phase = (t + 1) % 4
        witness = dest.classify(row, t)
        assert witness is not None and (witness["class"], witness["k"]) == ("ether", 6)
        assert row & 1 == refs[phase] & 1
        row = step(row, t)


def follow(seed, initial_phase, horizon, refs, dest):
    row = seed
    result = dict(seed=str(seed), first_col1_difference=None, first_odd_gate_difference=None,
                  terminal=None, terminal_tick=None)
    for t in range(horizon + 1):
        phase = (t + initial_phase) % 4
        if (row ^ refs[phase]) & 1:
            if result['first_col1_difference'] is None:
                result['first_col1_difference'] = t
            if t % 2 and result['first_odd_gate_difference'] is None:
                result['first_odd_gate_difference'] = t
        if result['terminal'] is None:
            witness = dest.classify(row, t)
            if witness is not None:
                result.update(terminal=witness, terminal_tick=t)
        if result['first_odd_gate_difference'] is not None and result['terminal'] is not None:
            break
        if result['terminal'] is not None and result['terminal'].get('offset') == initial_phase:
            break  # The reference and the certified future agree forever at column one.
        row = step(row, t)
    result['observed_through'] = t
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kit", type=Path, default=Path(__file__).resolve().parents[2] / "Rule30PrizeKit")
    parser.add_argument("--max-cut", type=int, default=140)
    parser.add_argument("--horizon", type=int, default=20000)
    args = parser.parse_args()
    if args.max_cut < 0 or args.horizon < 0:
        parser.error("cut and horizon must be nonnegative")
    dest = Destinations(args.kit)
    controls(dest)
    refs = ether_rows(dest.ether, max(args.max_cut, 1))
    out = []
    for offset in (1, 3):
        cache = {}
        for n in range(args.max_cut + 1):
            seed = refs[offset] & ((1 << n) - 1)
            if seed not in cache:
                cache[seed] = follow(seed, offset, args.horizon, refs, dest)
            result = cache[seed]
            dep = result["first_col1_difference"]
            assert dep is None or dep >= n
            out.append(dict(phase=offset, cut=n, **result))
    print(json.dumps(dict(kit_controls="passed", horizon=args.horizon, cuts=out), separators=(",", ":")))


if __name__ == "__main__":
    main()
