"""Check the phase-slip predictor against physical rows and a separate display detector."""

import argparse
from bisect import bisect_right
from collections import Counter, defaultdict
import itertools
import json
from pathlib import Path
from random import Random

from kick_predictor import WHEEL, common_trace, forecast, phase_at, pulse_warning, read_display
from wheel_bridge import table


def step(row, wall):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def display_seed(seed):
    # Same 24 positive cells and mulberry32 generator as the public visual.
    row = 1 << 23
    state = seed
    mask = (1 << 32) - 1
    for j in range(24):
        state = (state + 0x6D2B79F5) & mask
        n = ((state ^ (state >> 15)) * (state | 1)) & mask
        n ^= (n + ((n ^ (n >> 7)) * (n | 61))) & mask
        if (n ^ (n >> 14)) < 1 << 31:
            row |= 1 << j
    return row


def reference(trace):
    """Independently form consecutive matched runs and the public display's state."""
    starts = [None] * len(trace)
    for offset in range(0, 56, 2):
        count = 0
        for t in range(len(trace)-1, -1, -1):
            count = count + 1 if trace[t] == WHEEL[(t-offset) % 56] else 0
            if count >= 56:
                assert starts[t] is None
                starts[t] = offset
    phases, departures, changes = [], [], []
    last = current = None
    for t, new in enumerate(starts[:len(trace)-55]):
        if current is not None and trace[t] != WHEEL[(t-current) % 56]:
            departures.append((t, current))
            current = None
        if current is None and new is not None:
            if last is not None and new != last:
                n = (-17 * ((new-last) // 2)) % 28
                changes.append((t, new, n if n < 14 else n-28))
            current = last = new
        phases.append(current)
    assert (phases, departures, changes) == read_display(trace)
    return phases, departures, changes


def relay_controls(trap):
    pulse = [w for w in trap if w & 1]
    labels = {}
    for w in range(128):
        cells = [(w >> j) & 1 for j in range(7)]
        gate = []
        for t in range(7):
            gate.append(cells[0])
            before = [t % 2] + cells
            cells = [before[j] ^ (cells[j] | cells[j+1]) for j in range(len(cells)-1)]
        labels[w] = gate[-1]
        if w & 15 == 7:
            assert gate == [1, 1, 0, 1, 0, 0, (w >> 4) & 1]
    assert all(w & 15 == 7 and labels[w & 127] != labels[(w ^ 16) & 127] for w in pulse)
    possible = [j for j in range(7) if all(labels[u & 127] == labels[v & 127]
                for u in pulse for v in pulse if (u ^ v) & (1 << j) == 0)]
    assert possible == [4]
    return {"trap_pulses": len(pulse), "returns_at_six": sum(labels[w & 127] for w in pulse),
            "one_site_selectors": [j+1 for j in possible], "prefixes7": sorted({w & 127 for w in pulse})}


def history_length(trace, t, d):
    i = t
    while i >= 0 and trace[i] == WHEEL[(i-d) % 56]:
        i -= 1
    return t-i


def older_signals(stats, trace, raw, t, d, next_depart):
    for lead in (4, 10):
        pos = (t + lead - d) % 56
        if lead == 4:
            shapes = {2:6, 12:6, 22:6, 32:6, 42:6, 19:0, 39:0, 49:0, 52:3}
            if pos not in shapes:
                continue
            passes = ((raw >> 2) & 7) == shapes[pos]
        else:
            if pos != 52 or t < 139 or history_length(trace, t, d) < 140:
                continue
            # Spatial words are printed from near to far. Their first bit is bit zero.
            passes = (raw >> 5) & 7 == 3 and (raw >> 8) & 7 in (0, 4, 1, 5, 7)
        actual = next_depart == t + lead
        record = stats[str(lead)]
        record["candidate_ticks"] += 1
        record["departures"] += actual
        record["pattern_alerts"] += passes
        record["correct_alerts"] += passes and actual


def cohort(kind, seeds, ticks, trap, widths, examples, pairs):
    horizon, warm = 160, 140
    totals = Counter()
    older = defaultdict(Counter)
    by_width = {str(w): Counter() for w in widths}
    phase_counts = Counter()
    for seed in seeds:
        length = ticks + horizon + 56
        raw = display_seed(seed) if kind == "finite24" else Random(seed).getrandbits(length + max(widths))
        rows = []
        for t in range(length):
            rows.append(raw & ((1 << max(widths)) - 1))
            raw = step(raw, t % 2)
        trace = "".join(str(w & 1) for w in rows)
        phases, departures, kicks = reference(trace)
        dtimes, ktimes = [x[0] for x in departures], [x[0] for x in kicks]
        totals["display_departures"] += sum(warm <= t < ticks for t in dtimes)
        totals["display_kicks"] += sum(warm <= t < ticks for t in ktimes)
        hits = {w:{} for w in widths}
        pulse_hits = set()
        for t in range(warm, ticks):
            d = phases[t-55]  # This old state needs observations no later than t.
            if d is None or phase_at(trace[t-55:t+1], t-55) != d:
                continue
            assert phases[t] == d
            raw = rows[t]
            i = bisect_right(dtimes, t)
            next_depart = dtimes[i] if i < len(dtimes) else None
            if t + 10 < ticks:
                older_signals(older, trace, raw, t, d, next_depart)
            if t % 2 or raw & 1 == 0:
                continue
            pulse = pulse_warning(raw, t, d)
            if pulse is None:
                totals["pulses_without_1110"] += 1
                continue
            if (raw & 65535) in trap:
                totals["trap_pulses"] += 1
            pos = (t-d) % 56
            if t + 6 < ticks:
                totals["pulse_decisions"] += 1
                assert (next_depart == t+6) == pulse["departs"]
                assert next_depart is None or next_depart >= t+6
                if pulse["departs"]:
                    pulse_hits.add(t+6)
                    phase_counts[str((pos+6) % 56)] += 1
                key = (pos, pulse["site_5"])
                run = history_length(trace, t, d)
                if key not in pairs or pairs[key]["history"] < run:
                    pairs[key] = {"history": run, "kind": kind, "seed": seed, "tick": t,
                                  "phase": d, "prefix16": raw & 65535}
            j = bisect_right(ktimes, t)
            next_kick = kicks[j] if j < len(kicks) else None
            for w in widths:
                prefix = raw & ((1 << w)-1)
                f = forecast(prefix, w, t, d, horizon)
                common = common_trace(prefix, w, t, horizon)
                assert common == trace[t:t+len(common)]
                if f["departure"] is not None:
                    assert f["departure"] == next_depart
                event = f["next_kick"]
                if event is None or event["tick"] >= ticks:
                    continue
                assert (event["tick"], event["phase"], event["notches"]) == next_kick
                lead = event["tick"] - t
                measure = by_width[str(w)]
                measure["issued_exact_kick_calls"] += 1
                hits[w][event["tick"]] = max(lead, hits[w].get(event["tick"], 0))
                if (kind == "finite24" and len(examples) < 6 and pulse["departs"] and
                    event["tick"] == t+6 and w in (16,32) and
                    (pos, event["notches"]) not in examples):
                    examples[pos,event["notches"]] = {
                        "seed": seed, "t": t, "phase": d, "pos": pos, "width": w,
                        "prefix": format(prefix, f"0{w}b")[::-1], "forecast": f,
                        "actual_bits": trace[t:t+62], "rows": [format(a & 65535,"016b")[::-1] for a in rows[t:t+7]]}
        totals["six_tick_departures_called"] += len(pulse_hits)
        for w in widths:
            leads = list(hits[w].values())
            stats = by_width[str(w)]
            stats["distinct_kicks_called"] += len(leads)
            stats["largest_lead"] = max(stats["largest_lead"], max(leads, default=0))
            for lead in leads:
                stats.setdefault("lead_histogram", Counter())[str(lead)] += 1
    return {"seeds": [seeds.start, seeds.stop-1], "score_ticks": [warm,ticks-1],
            "counts": totals, "departure_phase_counts": phase_counts,
            "older_pattern_controls": older, "prefix_forecasts": by_width}


def main(args):
    trap = set(table(args.kit, "trapCodes", "Rule30Certificates/GateTrap"))
    examples, pairs = {}, {}
    result = {"relay": relay_controls(trap), "cohorts": {}}
    for kind, first in (("finite24", 1000), ("random_far_field", 2000)):
        result["cohorts"][kind] = cohort(kind, range(first, first+args.seeds), args.ticks,
                                        trap, (8,16,32,64), examples, pairs)
    best = max((min(pairs[p,0]["history"],pairs[p,1]["history"]),p)
               for p in range(56) if (p,0) in pairs and (p,1) in pairs)
    length, p = best
    result["matched_gate_histories"] = {"same_physical_ticks":length,"pulse_phase":p,
                                         "white_selector":pairs[p,0],"black_selector":pairs[p,1]}
    result["examples"] = list(examples.values())
    args.output.write_bytes((json.dumps(result, indent=2) + "\n").encode())
    print(json.dumps({"relay":result["relay"],"paired":best,"examples":len(examples),
                      "cohorts":{k:v["counts"] for k,v in result["cohorts"].items()}}, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--seeds", type=int, default=32)
    parser.add_argument("--ticks", type=int, default=3072)
    main(parser.parse_args())
