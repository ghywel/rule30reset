"""Prospective nine-site wheel forecasts on fresh finite and long random-tail rows."""
import argparse
from bisect import bisect_right
from collections import Counter, defaultdict
import json
from pathlib import Path
from random import Random
import subprocess
from types import ModuleType

from kick_predictor import forecast
from pulse_predictor import pulse_schedule
from wheel_bridge import U, table


HERE = Path(__file__).resolve().parent
OLD = "3a5728b"
ROTATIONS = {U[i:] + U[:i]: i for i in range(56)}
DEFECTS = ("00000", "11", "101", "10001", "1001001")


def baseline():
    old = ModuleType("old_nine_site_forecast")
    old.__file__ = str(HERE / "kick_predictor.py")
    source = subprocess.check_output(["git", "show", f"{OLD}:research/wheel/kick_predictor.py"], cwd=HERE)
    exec(compile(source, old.__file__, "exec"), old.__dict__)
    return old.forecast


def phase(word, t):
    position = ROTATIONS.get(word)
    if position is not None and (t - position) % 2 == 0:
        return (t - position) % 56
    return None


def physical_tick(row, wall):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def issue(seed, far, ticks, trap, old):
    # Tick 0 is white. Generate its whole finite row from a black-wall predecessor.
    # The random far field extends beyond the observation and verification cones.
    length = ticks + 216
    source_width = length + 32 if far else 24
    row = physical_tick(Random(seed).getrandbits(source_width), 1)
    trace, whites = "", ""
    committed = entered = confirmed = None
    starts, analyses = [], []
    for t in range(length):
        bit = str(row & 1)
        trace += bit
        if t % 2 == 0:
            whites = (whites + bit)[-48:]
            resident = row & 65535 in trap
            if resident and entered is None:
                entered = t
            assert resident == (entered is not None)
            if confirmed is None and len(whites) == 48 and all(d not in whites for d in DEFECTS):
                confirmed = t
                assert resident
        d = None
        if t >= 55:
            j = t - 55
            candidate = phase(trace[-56:], j)
            # The display decision at j is observable now. A matching full window
            # must additionally continue the display state captured at that time.
            if committed is not None and trace[j] != U[(j - committed) % 56]:
                committed = None
            if committed is None:
                committed = candidate
            if committed == candidate:
                d = candidate
        if t < ticks:
            prefix = format(row & 511, "09b")[::-1]
            pulse = t % 2 == 0 and bit == "1"
            direct = None
            if pulse and entered is not None:
                direct = pulse_schedule(prefix, t >= 2, True)
                starts.append((t, row & 511, direct))
            if d is not None:
                j = t
                while j >= 0 and trace[j] == U[(j - d) % 56]:
                    j -= 1
                matched = t - j
                args = (row & 511, 9, t, d, 160, matched)
                a = old(*args)
                b = forecast(*args)
                c = forecast(*args, known_trap=True) if confirmed is not None else b
                forecasts = {"old": a, "auto": b, "history": c}
                analyses.append((t, d, matched, pulse, direct, forecasts))
        row = physical_tick(row, t % 2)
    return trace, entered, confirmed, starts, analyses


def reference(trace):
    # Hindsight reconstruction uses maximal matching runs per offset, independently
    # of the online rotation matcher and the application's display implementation.
    entries = [None] * len(trace)
    for d in range(0, 56, 2):
        match = 0
        for i in reversed(range(len(trace))):
            match = match + 1 if trace[i] == U[(i - d) % 56] else 0
            if match >= 56:
                assert entries[i] is None
                entries[i] = d
    current = previous = None
    departures, relocks = [], []
    for i, entry in enumerate(entries[:-55]):
        if current is not None and trace[i] != U[(i - current) % 56]:
            departures.append((i, current))
            current = None
        if current is None and entry is not None:
            if previous is not None and previous != entry:
                amount = (-17 * ((entry - previous) // 2) + 14) % 28 - 14
                relocks.append((i, entry, amount))
            current = previous = entry
    return departures, relocks


def measure(seeds, far, ticks, trap, old):
    counts = Counter()
    gaps, span = Counter(), Counter()
    hits = defaultdict(dict)
    all_modes = ("old", "auto", "history", "direct")
    signed = Counter()
    extensions = defaultdict(Counter)
    for seed in seeds:
        trace, enter, confirm, schedules, calls = issue(seed, far, ticks, trap, old)
        counts["rows"] += 1
        counts["entered_by_score_end"] += enter is not None and enter < ticks
        counts["history_confirmed_by_score_end"] += confirm is not None and confirm < ticks
        events, relocks = reference(trace)
        times = [t for t, _ in events]
        counts["display_departures"] += sum(t < ticks for t in times)
        counts["signed_display_relocks"] += sum(t < ticks for t, _, _ in relocks)
        for t, prefix, p in schedules:
            observed = p["known_gate"]
            assert trace[t:t+len(observed)] == observed
            old_word = old.__globals__["common_trace"](prefix, 9, t, 160)
            assert observed.startswith(old_word)
            extensions["all_trap_pulses"][len(observed) - len(old_word)] += 1
            if len(observed) > len(old_word):
                assert t == enter
            arrivals = [k for k in range(1, 11) if trace[t + 2*k] == "1"]
            g, h = arrivals[0], arrivals[1] - arrivals[0]
            assert p["gap_pairs"] == [(g, h)] and len(observed) == 2*(g+h) + 6
            gaps[f"{g},{h}"] += 1
            span[str(len(observed))] += 1
        for t, d, matched, pulse, direct, forecasts in calls:
            i = bisect_right(times, t)
            next_depart = events[i] if i < len(events) else None
            expected = next_depart[0] if next_depart is not None else len(trace)
            # Even when the next departure is beyond the verification suffix, all
            # actually asserted gate readings and earlier bounds still lie inside it.
            if next_depart is not None:
                assert next_depart[1] == d
            counts["eligible_locked_ticks"] += 1
            counts["eligible_locked_pulses"] += pulse
            candidates = {}
            for mode, answer in forecasts.items():
                if answer["departure"] is not None:
                    assert answer["departure"] == expected
                    candidates[mode] = answer["departure"]
                assert answer["old_phase_matches_through"] < expected
                schedule = answer.get("pulse_returns")
                if schedule is not None and "known_gate" in schedule:
                    assert direct == schedule and enter is not None and enter <= t
                    word = schedule["known_gate"]
                    assert trace[t:t+len(word)] == word
                    extensions[mode][answer["common_gate_through"] - forecasts["old"]["common_gate_through"]] += 1
                call = answer["next_kick"]
                if call:
                    next_relock = next(event for event in relocks if event[0] > t)
                    assert (call["tick"], call["phase"], call["notches"]) == next_relock
                    signed[mode] += 1
            if direct is not None:
                extensions["direct"][t + len(direct["known_gate"]) - 1 -
                                     forecasts["old"]["common_gate_through"]] += 1
                predicted = next((t + k for k, b in enumerate(direct["known_gate"])
                                  if b != U[(t+k-d) % 56]), None)
                if predicted is not None:
                    assert predicted == expected
                    candidates["direct"] = predicted
                    g, h = direct["gap_pairs"][0]
                    if predicted > t + 2*(g+h):
                        counts["direct_calls_in_third_tile_prefix"] += 1
            for mode, target in candidates.items():
                if target >= ticks:
                    continue
                key = (seed, target)
                cohorts = ["all_issues"] if mode != "direct" else []
                if pulse:
                    cohorts.append("pulse_issues")
                if direct is not None and matched < 95:
                    cohorts.append("locked_trap_pulses_below_95")
                for cohort in cohorts:
                    measures = hits[cohort, mode]
                    measures[key] = max(measures.get(key, 0), target-t)
    summary = {}
    for cohort in ("all_issues", "pulse_issues", "locked_trap_pulses_below_95"):
        values = {}
        base = hits[cohort, "old"]
        for name in all_modes:
            if name == "direct" and cohort == "all_issues":
                continue
            found = hits[cohort, name]
            values[name] = {"distinct": len(found), "extra_over_old": len(found.keys()-base.keys()),
                            "old_only": len(base.keys()-found.keys()),
                            "earlier_than_old_on_shared": sum(found[e] > base[e] for e in found.keys()&base.keys()),
                            "largest_lead": max(found.values(), default=0),
                            "earliest_lead_histogram": dict(sorted(Counter(found.values()).items()))}
        summary[cohort] = values
    return {"seeds": [seeds.start, seeds.stop-1], "counts": counts, "gap_pairs": gaps,
            "verified_trace_lengths": span, "coverage": summary,
            "known_gate_extra_ticks_over_old": dict(extensions),
            "signed_calls": {mode: signed[mode] for mode in ("old", "auto", "history")}}


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("kit", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("--rows", type=int, default=32)
    p.add_argument("--ticks", type=int, default=3072)
    a = p.parse_args()
    trap = set(table(a.kit, "trapCodes", "Rule30Certificates/GateTrap"))
    assert len(trap) == 829
    old = baseline()
    all_prefixes = {}
    for code in sorted({row & 511 for row in trap if row & 1}):
        prefix = format(code, "09b")[::-1]
        direct = pulse_schedule(prefix, False, True)
        raw = old.__globals__["common_trace"](code, 9, 0, 160)
        assert direct["known_gate"].startswith(raw)
        all_prefixes[prefix] = {"trap_windows": sum(x & 511 == code for x in trap),
                                "old_gate_length": len(raw), "two_tile_length": len(direct["known_gate"])}
    longer = {int(prefix[::-1], 2) for prefix, stats in all_prefixes.items()
              if stats["old_gate_length"] < stats["two_tile_length"]}
    exceptional = {row for row in trap if row & 511 in longer}
    successors = {physical_tick(physical_tick(row + (east << 16), 0), 1) & 65535
                  for row in trap for east in range(4)}
    assert exceptional == {49415} and successors <= trap and not exceptional & successors
    result = {"old_revision": OLD, "issue_ticks": a.ticks, "width": 9,
              "unique_extended_window": 49415, "in_trap_predecessor_count": 0,
              "all_trapped_pulse_prefixes": all_prefixes}
    for label, start, far in (("finite24", 31000, False), ("random_far_field", 41000, True)):
        v = measure(range(start, start+a.rows), far, a.ticks, trap, old)
        result[label] = v
        print(label, v["coverage"]["pulse_issues"], flush=True)
    a.output.write_bytes((json.dumps(result, indent=2)+"\n").encode())
