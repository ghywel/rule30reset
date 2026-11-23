"""Independently replay R97's finite delays against I173's full stabilized strip graph."""
import argparse
from collections import defaultdict
from hashlib import sha256
import json
from pathlib import Path
import runpy

import numpy as np


HERE = Path(__file__).resolve().parent
I173 = runpy.run_path(str(HERE / "gptIntel-limit-read.py"))
DRIVE = I173["DRIVE"]
BASE = 1 << 22
LOW = BASE - 1


def timings(width, ether, initial_phase, giant):
    # A layer carries the first visible disagreement tick, or zero while site 1
    # still agrees. Every surviving window projects outside the giant.
    layers = {0: {ether[initial_phase] + BASE * n for n in range(1 << (width - 22))}}
    counts = {}
    last = {}
    t = 0
    seen = set()
    while layers:
        phase = (initial_phase + t) % 3
        next_phase = (phase + 1) % 3
        following = defaultdict(set)
        for first, words in layers.items():
            for word in words:
                for dest in I173["successors"](width, word, DRIVE[phase]):
                    low = dest & LOW
                    if low + next_phase * BASE in giant:
                        continue
                    if t == 0 and low == ether[next_phase]:
                        continue
                    off = (low ^ ether[next_phase]) & 1
                    key = first if first or not off else t + 1
                    following[key].add(dest)
        t += 1
        layers = following
        for first, words in layers.items():
            if first:
                if first == t:
                    counts[first] = len(words)
                last[first] = t
        # Recurrence of a phase and its labelled outside layer would violate a finite bound.
        snapshot = ((phase + 1) % 3, frozenset((first, frozenset(words)) for first, words in layers.items()))
        assert snapshot not in seen
        seen.add(snapshot)
    return [{"exit_phase": initial_phase, "departure_tick": t0, "possible_words": count,
             "max_ticks_to_giant": last[t0] + 1 - t0} for t0, count in sorted(counts.items())]


def replay_finite(row, ether, phase, giant, final_tick):
    # Unbounded nonnegative integers encode a scalar finite half with an exact
    # zero tail. No padding or right boundary is needed.
    first_exit = mismatch = entry = None
    records = []
    for tick in range(final_tick + 1):
        p = (phase + tick) % 3
        word = row & LOW
        inside = p * BASE + word in giant
        if first_exit is None and word != ether[p]:
            first_exit = tick
        if mismatch is None and (word ^ ether[p]) & 1:
            mismatch = tick
        if entry is None and inside:
            entry = tick
        if mismatch is not None:
            records.append({"t": tick, "phase": p, "word": word, "in_giant": inside})
        row = ((row << 1) | DRIVE[p]) ^ (row | (row >> 1))
    return first_exit, mismatch, entry, records


def main(output):
    receipt = json.loads((HERE / "data/gptM5-departure-transit.json").read_bytes())
    _, stabilized, ids, _, _, labels, sizes = I173["limit_graph"](22)
    ordered = np.asarray(ids[labels == np.argmax(sizes)], dtype="<u4")
    digest = sha256(ordered.tobytes()).hexdigest()
    assert len(ordered) == receipt["closed_size"] == 123382
    assert digest == receipt["closed_sha256_u32le"]
    giant = set(map(int, ordered))
    ether_cycles = sorted(I173["rings"](22))
    assert [list(ether) for ether in ether_cycles] == [a["ether"] for a in receipt["alignments"]]
    results = []
    for ether, source in zip(ether_cycles, receipt["alignments"], strict=True):
        by_width = {}
        for width in range(22, 27):
            result = [r for p in range(3) for r in timings(width, ether, p, giant)]
            assert result == source["lifts"][str(width)]
            by_width[str(width)] = result
        witness = source["finite_witness"]
        exit_tick, first, entry, trail = replay_finite(
            int(witness["row_hex"], 16), ether, witness["initial_phase"], giant,
            witness["first_giant_entry"])
        assert exit_tick == 1 and (first, entry) == (witness["departure"], witness["first_giant_entry"])
        assert trail == witness["history"]
        assert entry - first == max(q["max_ticks_to_giant"] for q in by_width["26"])
        results.append({"ether_phase_zero": ether[0], "lifts": by_width, "finite_row": witness["row_hex"],
                        "phase": witness["initial_phase"], "first_window_exit": exit_tick,
                        "first_mismatch": first, "first_giant_entry": entry, "history": trail})
    payload = {"width22_stabilized": stabilized, "width22_giant_size": len(giant),
               "width22_giant_sha256_u32le": digest, "alignments": results}
    output.write_bytes((json.dumps(payload, indent=2) + "\n").encode())
    for result in results:
        print(result["ether_phase_zero"], result["finite_row"], result["first_mismatch"], result["first_giant_entry"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    main(parser.parse_args().output)
