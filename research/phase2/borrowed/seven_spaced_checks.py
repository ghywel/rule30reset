"""Exact first wall failures for cuts of the seven-spaced Rule 30 reference.

Use Galindo's moving strip from Rule30MassCounterexamples.Suffix until 16
ticks before the first omitted spike. Then evolve the wall prefix in the
physical frame. An independent packed simulation checks the finite quotient.
"""

import argparse
from collections import Counter
from math import lcm
from pathlib import Path
import re


MASKS = (278, 17333, 9765, 32125, 321, 17251, 9814, 32213, 277)
FEED = (0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 1, 2, 1, 3, 1, 3, 0, 0, 3, 1, 2, 2, 2, 3, 0, 1, 2, 3)
JOIN = 16
ROOT = Path(__file__).resolve().parents[3]


def cut(n):
    return 1 + 7 * n


def seed(n, suffix=0):
    return (20 | (2 * ((128**n - 1) // 127))) | (suffix << cut(n))


def ether(t, d):
    phase = 0 if t == 0 else 1 + (t - 1) % 8
    slot = d if d < 8 else 8 + (d - 8) % 7
    return (MASKS[phase] >> slot) & 1


def step(row):
    return (row >> 1) ^ (row | (row << 1))


def readings(row, length):
    result = []
    for _ in range(length):
        result.append(row & 1)
        row = step(row)
    return result


def failures(trace, origin, start):
    odd = pair = None
    for j in range(max(0, start - origin), len(trace)):
        t = origin + j
        if t % 2 and not trace[j] and odd is None:
            odd = t
        if t > 0 and t % 2 == 0 and j >= 2 and not (trace[j - 2] or trace[j]) and pair is None:
            pair = t
    candidates = [t for t in (odd, pair) if t is not None]
    return odd, pair, min(candidates, default=None)


def front_cycle(suffix, lookahead):
    internal = lookahead + 1
    take = (1 << (internal + 2)) - 4
    start = ((suffix << 2) & take) | FEED[0]
    state = start
    values = []
    while True:
        values.append(state)
        state = ((state ^ ((state << 1) | (state << 2))) & take) | FEED[len(values) % 28]
        if len(values) % 28 == 0 and state == start:
            return values
        assert len(values) < 28 * (1 << internal)


def post_cut(n, front, lookahead):
    join = cut(n) - JOIN
    prefix = sum(ether(join, d) << d for d in range(JOIN))
    row = prefix | ((front[join % len(front)] >> 2) << JOIN)
    trace = readings(row, JOIN + lookahead + 1)
    return failures(trace, join, cut(n))


def run_quotient(suffix, lookahead):
    front = front_cycle(suffix, lookahead)
    period = lcm(len(front), 8) // 7
    outcomes = [post_cut(n, front, lookahead) for n in range(3, 3 + period)]
    offsets = [tuple(None if t is None else t - cut(n) for t in ts)
               for n, ts in zip(range(3, 3 + period), outcomes)]
    effective = next(d for d in range(1, period + 1)
                     if period % d == 0 and all(v == offsets[i % d] for i, v in enumerate(offsets)))
    print('suffix:', suffix, 'lookahead:', lookahead, 'strip period:', len(front),
          'spike-count period:', period, 'effective period:', effective)
    for i, name in enumerate(('first white odd', 'first double-white even', 'first G failure')):
        print(name, dict(Counter(row[i] for row in offsets)))
    if effective <= 64:
        print('exact offsets in n mod effective period:',
              sorted(((3 + i) % effective, ts) for i, ts in enumerate(offsets[:effective])))
    print('exceptional small n:', [(n, failures(readings(seed(n, suffix), cut(n) + lookahead + 1), 0, 0))
                                   for n in (1, 2)])
    tested = sorted(set(range(3, 131)) | {3 + period, 3 + 2 * period, 2635})
    for n in tested:
        t = failures(readings(seed(n, suffix), cut(n) + lookahead + 1), 0, 0)
        assert t == post_cut(n, front, lookahead), (n, suffix, t, post_cut(n, front, lookahead))
    print('physical replay agreement:', len(tested))


def witnesses():
    path = ROOT / 'Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30PeriodTwoMass.lean'
    literals = re.findall(r'^def Y(86|198|310) : Nat := (\d+)$', path.read_text(encoding='utf-8'), re.M)
    assert [label for label, _ in literals] == ['86', '198', '310']
    for label, literal in literals:
        row = int(literal)
        width = row.bit_length()
        reference = seed((width + 13) // 7)
        delta = row ^ reference
        first = (delta & -delta).bit_length() - 1
        n = (first - 1) // 7
        q = row >> cut(n)
        assert seed(n, q) == row
        print('published H, actual width, spikes, suffix, losses:', label, width, n, q,
              failures(readings(row, int(label) + 65), 0, 0))
    for n, q, through in ((75, 0, 600), (2635, 1 << 17, 18530)):
        row = seed(n, q)
        print('Galindo n, suffix, actual width, losses:', n, q, row.bit_length(),
              failures(readings(row, through + 1), 0, 0))
    for row in (0, 2, 6):
        print('small ordinary seed, actual width, losses:', row, row.bit_length(), failures(readings(row, 25), 0, 0))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--slack', type=int, default=24)
    parser.add_argument('--suffix', type=int, action='append')
    args = parser.parse_args()
    if args.slack < 0 or any(q < 0 for q in (args.suffix or [])):
        parser.error('slack and suffix must be nonnegative')
    witnesses()
    for q in args.suffix or [0]:
        run_quotient(q, args.slack)


if __name__ == '__main__':
    main()
