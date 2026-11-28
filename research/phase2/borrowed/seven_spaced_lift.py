"""Find exact residue formulas by adding one observation diagonal at a time.

Periods are dyadic multiples of the 28-tick two-column feed. An internal
lane is its initial bit XOR the running parity of the OR of its drivers.
Represent one full time period as bits of an integer. Only unresolved
width residues are split when a new lane doubles the period.
"""

import argparse
from collections import Counter
import json
from math import lcm
from pathlib import Path

from seven_spaced_checks import FEED, JOIN, cut, ether, readings


def repeat_word(word, size, target):
    while size < target:
        word |= word << size
        size *= 2
    return word


def time_parity(driver, period, first):
    mask = (1 << period) - 1
    partial = driver
    shift = 1
    while shift < period:
        partial ^= (partial << shift) & mask
        shift *= 2
    values = (partial << 1) & mask
    if first:
        values ^= mask
    if driver.bit_count() % 2:
        return values | ((values ^ mask) << period), 2 * period
    return values, period


def lane(q, d, lower):
    a, p = lower[-1]
    b, r = lower[-2]
    common = max(p, r)
    forcing = repeat_word(a, p, common) | repeat_word(b, r, common)
    return time_parity(forcing, common, (q >> d) & 1)


def unpack_time(word, length):
    return word.to_bytes((length + 7) // 8, byteorder='little'), length


def at_time(packed, t):
    word, period = packed
    t %= period
    return (word[t // 8] >> (t % 8)) & 1


def refine(pending, small, large):
    return {r + shift for r in pending for shift in range(0, large, small)}


def minimize(entries):
    pairs = {(p, r): lag for p, r, lag in entries}
    for period in sorted({p for p, _, _ in entries}, reverse=True):
        while period > 1 and any(p == period for p, _ in pairs):
            half = period // 2
            matches = [(r, lag) for (p, r), lag in pairs.items()
                       if p == period and r < half and pairs.get((p, r + half)) == lag]
            if not matches:
                break
            for r, lag in matches:
                del pairs[period, r]
                del pairs[period, r + half]
                pairs[half, r] = lag
            period = half
    return sorted((p, r, lag) for (p, r), lag in pairs.items())


def solve(q, through):
    feed = [(sum(((bits >> k) & 1) << t for t, bits in enumerate(FEED)), 28) for k in range(2)]
    packed = [unpack_time(*x) for x in feed]
    last_two = feed[:]
    period = 8
    waits = {name: set(range(period)) for name in ('pin', 'G')}
    found = {name: [] for name in waits}
    lifts = []
    for d in range(through + 1):
        word = lane(q, d, last_two)
        last_two = [last_two[-1], word]
        packed.append(unpack_time(*word))
        new = lcm(period * 7, word[1]) // 7
        if new != period:
            waits = {name: refine(x, period, new) for name, x in waits.items()}
            period = new
        for residue in sorted(waits['pin'] | waits['G']):
            n = 3 + (residue - 3) % period
            join = cut(n) - JOIN
            row = sum(ether(join, i) << i for i in range(JOIN))
            row |= sum(at_time(x, join) << (i + JOIN) for i, x in enumerate(packed[2:]))
            history = readings(row, JOIN + d + 1)
            bad_pin = (cut(n) + d) % 2 == 1 and history[-1] == 0
            bad_pair = (cut(n) + d) % 2 == 0 and history[-1] == history[-3] == 0
            if bad_pin and residue in waits['pin']:
                waits['pin'].remove(residue)
                found['pin'].append((period, residue, d))
            if (bad_pin or bad_pair) and residue in waits['G']:
                waits['G'].remove(residue)
                found['G'].append((period, residue, d))
        lifts.append((d, word[1], period, len(waits['pin']), len(waits['G'])))
        print('suffix, offset, lane period, spike-count period, unresolved pin and G:', q, *lifts[-1], flush=True)
        if not any(waits.values()):
            break
    compact = {name: minimize(values) for name, values in found.items()}
    for name, values in compact.items():
        print(name, 'congruence rules:', len(values), 'largest modulus:', max(p for p, _, _ in values))
        counts = Counter()
        for p, _, lag in values:
            counts[lag] += period // p
        assert sum(counts.values()) + len(waits[name]) == period
        print(name, 'lag histogram at modulus', period, ':', sorted(counts.items()))
    return {'suffix': q, 'lifts': lifts, 'rules': compact,
            'unresolved': {name: sorted(x) for name, x in waits.items()}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--through', type=int, required=True)
    parser.add_argument('--suffix', type=int, action='append', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.through < 0 or any(q < 0 for q in args.suffix):
        parser.error('lookahead and suffix must be nonnegative')
    rows = []
    for q in args.suffix:
        rows.append(solve(q, args.through))
        args.output.write_text(json.dumps(rows, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
