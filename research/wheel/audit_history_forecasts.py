"""Replay exact boundary witnesses and count the extra prospective warnings on I169's cohorts."""
import argparse
from bisect import bisect_right
from collections import Counter
import json
from pathlib import Path
from random import Random

from audit_kick_predictor import display_seed, history_length, reference, step
from kick_predictor import forecast, phase_at, SENSOR_HISTORY, POSITION_HISTORY


def validate_controls(data):
    # Both sharpness witnesses begin at a white tick and can be supplied
    # directly to the command-line predictor with the indicated phase.
    for name, record in data.items():
        row = int(record["initial_row"], 16)
        phase = -record["initial_phase"] % 56
        for t in range(record["issue"]):
            row = step(row, t % 2)
        history = record["issue"] - record["history_start"] + 1
        short = forecast(row & 127, 7, record["issue"], phase, matched_ticks=history)
        if name == "sensor-79":
            assert history == SENSOR_HISTORY - 1 and short["mature_sensors"] is None
        elif name == "position-126":
            assert history == POSITION_HISTORY - 1
            assert short["first_departure_candidates_this_turn"] is None
            assert short["departure"] == record["first_departure"]
        else:
            raise ValueError(name)


def cohort(finite):
    totals = Counter()
    first = 1000 if finite else 2000
    for seed in range(first, first + 32):
        end = 3072
        # Same far-field bits as I169 across the full causal cone.
        row = display_seed(seed) if finite else Random(seed).getrandbits(end + 160 + 56 + 64)
        rows = []
        for t in range(end + 160 + 56):
            rows.append(row & 255)
            row = step(row, t % 2)
        trace = "".join(str(r & 1) for r in rows)
        phases, departures, _ = reference(trace)
        times = [t for t,_ in departures]
        called = set()
        old_called = set()
        for t in range(140, end - 14):
            phase = phases[t-55]
            if phase is None or phase_at(trace[t-55:t+1], t-55) != phase:
                continue
            history = history_length(trace, t, phase)
            if history < SENSOR_HISTORY:
                continue
            i = bisect_right(times, t)
            actual = times[i] if i < len(times) else None
            out = forecast(rows[t], 8, t, phase, matched_ticks=history)
            if out["departure"] is not None:
                assert out["departure"] == actual
            if actual is not None:
                assert actual > out["old_phase_matches_through"]
            slots = out["first_departure_candidates_this_turn"]
            if history < POSITION_HISTORY:
                assert slots is None
            elif actual is not None and actual <= t+56:
                assert actual in slots
            for test in out["mature_sensors"]:
                assert test["departs"] == (actual == test["target_tick"])
                totals["all_sensor_decisions"] += 1
                if history < 140:
                    totals["extra_sensor_decisions"] += 1
                if test["departs"]:
                    called.add(actual)
                    totals["positive_calls"] += 1
                    if history >= 140:
                        old_called.add(actual)
        totals["distinct_departures"] += len(called)
        totals["extra_distinct_departures"] += len(called - old_called)
    return totals


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("receipts",type=Path)
    p.add_argument("output",type=Path)
    args = p.parse_args()
    validate_controls(json.loads(args.receipts.read_bytes())["sharpness"])
    stats = {label:cohort(i == 0) for i,label in enumerate(("finite24","random_far_field"))}
    args.output.write_bytes((json.dumps(stats,indent=2)+"\n").encode())
    print(stats)
