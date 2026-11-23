"""claudeM5's independent checks for the M9 repair read (M114).

witnesses KIT_GATETRAP_LEAN
    Replays the two physical witnesses of Rule30Submission (four_one_sample, three_sixty_samples)
    by a direct Rule 30 simulation, without Lean and without gptIntel's code. Column 0 is the
    alternating column altCol t = (t % 2 == 0); the initial right half has column p = bit p-1 of
    the witness integer; the gate u R s is column 1 at tick 2s+1; the window is columns 1..16,
    code bit i = column i+1.

pairs
    Tests the successor and predecessor enumerations of gptIntel_refutation_core.py on pairs of
    real rows two ticks apart, at random widths 16..45 and targets within two of the width.
    Every real next prefix must be among the successors, and every real previous prefix among
    the predecessors.
"""
import os
import random
import re
import sys

BLOCK = [5, 5, 5, 5, 3]
FOUR = 17911952117231624625415841284791634824617432618773606279499
SIXTY = 88769951030016947892698456558596051073035529750717722303543758321481268415460012


def trap_codes(path):
    src = open(path, encoding="utf-8").read()
    m = re.search(r"def trapCodes : List Nat := \[(.*?)\]", src, re.S)
    return {int(x) for x in re.findall(r"\d+", m.group(1))}


def heads_of(gaps):
    out = [True]
    for k in gaps:
        out += [False] * (k - 1) + [True]
    return out


def closed(n):
    return heads_of([3] + BLOCK * n)


def run(a, ticks):
    """Rows as integers, bit p = column p, column 0 driven by altCol."""
    row = (a << 1) | 1
    rows = [row]
    for t in range(ticks):
        new = ((row << 1) ^ (row | (row >> 1))) & ~1
        if (t + 1) % 2 == 0:
            new |= 1
        row = new
        rows.append(row)
    return rows


def witnesses(kit_path):
    codes = trap_codes(kit_path)
    print("trap codes", len(codes))
    ok = True
    for name, a, code, s0, word in [("four_one_sample", FOUR, 44920, 1, closed(4)),
                                    ("three_sixty_samples", SIXTY, 40615, 60, closed(3))]:
        ticks = 2 * (s0 + len(word)) + 2
        rows = run(a, ticks)
        at1 = (rows[1] >> 1) & 0xFFFF
        gate = [bool((rows[2 * s + 1] >> 1) & 1) for s in range(s0, s0 + len(word))]
        trapped = all(((rows[t] >> 1) & 0xFFFF) in codes for t in range(1, ticks, 2))
        blacks = [s for s in range(s0 + len(word)) if (rows[2 * s + 1] >> 1) & 1]
        gaps = [y - x for x, y in zip(blacks, blacks[1:])]
        good = at1 == code and code in codes and gate == word and trapped
        ok &= good
        print(f"{name}: seed bits {a.bit_length()}, code {at1} at tick 1 in trap {code in codes}, "
              f"word {gate == word}, trap at every odd tick to {ticks - 1} {trapped}")
        print(f"  black samples from {blacks[0]}, gaps {gaps}")
    print("WITNESSES PASS" if ok else "WITNESSES FAIL")
    return ok


def pairs(trials=60, per=20, seed=2026):
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import gptIntel_refutation_core as core
    rng = random.Random(seed)
    tests = fails = 0
    for _ in range(trials):
        rows = run(rng.getrandbits(rng.choice([60, 120, 260])), 120)
        for _ in range(per):
            t = rng.randrange(1, 100, 2)
            x, y = rows[t] >> 1, rows[t + 2] >> 1
            w = rng.randint(16, 45)
            tg = rng.randint(max(16, w - 2), min(46, w + 2))
            nxt = core.following(w, tg, x & ((1 << w) - 1))
            prv = core.preceding(w, tg, y & ((1 << w) - 1))
            tests += 1
            fails += not ((y & ((1 << tg) - 1)) in nxt and (x & ((1 << tg) - 1)) in prv)
    print(f"real row pairs {tests}, failures {fails}")
    return fails == 0


if __name__ == "__main__":
    if sys.argv[1:2] == ["witnesses"]:
        sys.exit(0 if witnesses(sys.argv[2]) else 1)
    if sys.argv[1:2] == ["pairs"]:
        sys.exit(0 if pairs() else 1)
    sys.exit(__doc__)
