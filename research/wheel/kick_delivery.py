"""Replay a one-cell intervention and naturally occurring pairs of wheel departures."""

import argparse
from collections import defaultdict
import json
from pathlib import Path

from audit_kick_predictor import display_seed, history_length, reference, step
from kick_predictor import WHEEL, forecast, phase_at, read_display


def film(row, start, length):
    rows = []
    for t in range(start, start+length):
        rows.append(row)
        row = step(row, t % 2)
    bits = "".join(str(w & 1) for w in rows)
    return rows, bits


def intervention():
    seed, tick = 1000, 274
    rows, bits = film(display_seed(seed), 0, tick+320)
    phase = phase_at(bits[tick-55:tick+1], tick-55)
    active, _, _ = reference(bits)
    assert active[tick-55] == phase == 24
    actual = read_display(bits[tick:], tick, phase, phase)
    old_departure = actual[1][0][0]
    old_kick = actual[2][0]
    changed = []
    for site in range(11,65):
        _, alternate = film(rows[tick] ^ (1 << (site-1)), tick, 320)
        _, departures, kicks = read_display(alternate, tick, phase, phase)
        assert departures[0][0] == old_departure == tick+6
        if kicks and kicks[0][0] == old_kick[0] and kicks[0][2] != old_kick[2]:
            changed.append((site, kicks[0], alternate[:62]))
    assert changed
    site, new_kick, new_trace = changed[-1]
    return {"seed":seed,"tick":tick,"phase":phase,"site_flipped":site,
            "original_row_hex":hex(rows[tick]),"original_site5":rows[tick] >> 4 & 1,
            "common_departure":old_departure,"original_kick":old_kick,"changed_kick":new_kick,
            "original_trace":bits[tick:tick+62],"changed_trace":new_trace,
            "all_tested_sites_switching_the_immediate_size":[s for s,_,_ in changed]}


def natural_pair():
    # At a clean immediate phase change compare launches with the same relative
    # wheel position and selector. Prefix length is low-bit agreement of their rows.
    groups = defaultdict(list)
    best = None
    for seed in range(1000,1032):
        rows, trace = film(display_seed(seed), 0, 3072+56)
        active, departures, changes = reference(trace)
        event_at = {t:(d,k) for t,d,k in changes}
        for r, old in departures:
            t = r-6
            if t < 140 or r >= 3072 or r not in event_at or t % 2:
                continue
            if active[t-55] != old or phase_at(trace[t-55:t+1],t-55) != old or rows[t] & 15 != 7:
                continue
            _, k = event_at[r]
            key = ((t-old) % 56, rows[t] >> 4 & 1)
            evidence = {"seed":seed,"tick":t,"old_offset":old,"notches":k,
                        "prefix32":hex(rows[t] & 0xffffffff),"matched_before":history_length(trace,t,old)}
            for other_row, other in groups[key]:
                if k == other["notches"] or other["seed"] == seed:
                    continue
                diff = other_row ^ rows[t]
                assert diff
                length = (diff & -diff).bit_length()-1
                if best is None or length > best[0]:
                    best=(length,key,evidence,other)
            groups[key].append((rows[t],evidence))
    n, key, a, b = best
    return {"shared_positive_sites":n,"first_different_site":n+1,"pulse_phase":key[0],
            "selector":key[1],"first":a,"second":b}


def example(seed, tick, phase):
    rows, bits = film(display_seed(seed),0,tick+256)
    assert phase_at(bits[tick-55:tick+1],tick-55) == phase
    change = read_display(bits[tick:],tick,phase,phase)[2]
    target = tick+6
    return {"seed":seed,"issue":tick,"phase":phase,"target":target,
            "physical_old_index":(target-phase) % 56,"old_expected":int(WHEEL[(target-phase) % 56]),
            "observed":int(bits[target]),"old_history_at_early_read":history_length(bits,tick-8,phase),
            "prefix32":format(rows[tick]&0xffffffff,"032b")[::-1],
            "forecast32":forecast(rows[tick]&0xffffffff,32,tick,phase,160,history_length(bits,tick,phase)),
            "next_display_kick":list(change[0]) if change else None,
            "rows_positive": [w & 255 for w in rows[tick-8:target+1]]}


def rare_class_control():
    # A physical triangular SAT model. Direct evolution suffices to verify it.
    row = 0xd53fffeffff7ffffc009eb4b069bdfdf1df664
    rows, trace = film(row, 0, 155)
    assert trace[:154] == (WHEEL*3)[:154] and trace[154] != WHEEL[42]
    assert rows[140] >> 6 & 1
    tiny = forecast(rows[140] & 127, 7, 140, 0, matched_ticks=141)
    assert tiny["departure"] == 154


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output",type=Path)
    args=parser.parse_args()
    rare_class_control()
    result = {"intervention":intervention(),"natural_pair":natural_pair(),
              "marked_examples":[example(1018,1030,32),example(1011,2810,20),example(1000,274,24)]}
    args.output.write_bytes((json.dumps(result,indent=2)+"\n").encode())
    print(result["intervention"]["site_flipped"],result["intervention"]["original_kick"],
          result["intervention"]["changed_kick"],result["natural_pair"])
