#!/usr/bin/env python3
"""claudeCloud_mixture_control.py: an independent control of Rule30DensityMixtures (ledger K69, addendum 1).

The theorem `mixtures_from_any_right_half` is kernel-checked. This control tests that it says what the essay says,
by running its schedule outside Lean.

It reads the five controller tables as text from Rule30DensityVertices.lean and follows the schedule on explicit
right halves: in round e = 0, 1, 2, ..., for each corner i in turn, the controller's `width` steering ticks and then
`w_i * e` controlled ticks. The observed site is site 0. Each tick it places the chosen bit at site 0 and applies
Rule 30 to the sites j >= 1 of the half line, exactly (the simulated half line is long enough for every tick).

Checked at every tick, with integers only:
  1. steering: the `width` chosen bits install the start window of the controller (the left-permutive inversion);
  2. the controller stays inside its table, and its window equals the first `width` cells of the row;
  3. inside each controlled stretch, |D*C - c*t| <= cap and |D*A - a*t| <= cap for every t;
  4. from tick 0, (60*K*C - P*T)^2 <= 2*(K*(60*K+4317))^2*(T+1) for C with P = 20 w1 + 45 w2 + 54 w3 + 60 w4 and for
     A with P = 15 w2 + 24 w3 + 60 w4: the statement of the theorem.
It prints, for each weight vector and right half, the largest |60*K*C - P*T| / sqrt(2T+2) seen against the theorem's
K*(60*K+4317), and the densities at T = N/100, N/10 and N against the target.

    python3 claudeCloud_mixture_control.py [N]      N ticks per history, default 60000
"""
import math
import pathlib
import random
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
ORDER = ['zero', 'oneThird', 'threeQuarters', 'nineTenths', 'one']
RATE_C = [0, 20, 45, 54, 60]
RATE_A = [0, 0, 15, 24, 60]


def tables():
    text = (HERE / 'Rule30DensityVertices.lean').read_text()
    out = []
    for name in ORDER:
        m = re.search(r'def %s : Mode :=\s*⟨(\d+),(\d+),(\d+),(\d+),(\d+),(\d+), #\[(.*?)\]⟩' % name, text, re.S)
        width, den, black, source, cap, start = (int(m.group(i)) for i in range(1, 7))
        nodes = [(int(a), b == 'true', int(c), int(d)) for a, b, c, d, _, _ in
                 re.findall(r'⟨(\d+),(true|false),(\d+),(\d+),(\d+),(\d+)⟩', m.group(7))]
        assert nodes and start < len(nodes), name
        out.append(dict(name=name, width=width, den=den, black=black, source=source, cap=cap, start=start, nodes=nodes))
    return out


def step(row, bit, size):
    """One tick of the half line: site 0 takes `bit`; site j+1 takes rule(r_j, r_{j+1}, r_{j+2}). `size` cells stay valid."""
    return (((row ^ ((row >> 1) | (row >> 2))) << 1) | bit) & ((1 << size) - 1)


def steer(row, width, target):
    """The `width` bits that install `target` on the cells 0..width-1 after `width` ticks, found one at a time:
    the bit placed at tick s decides cell width-s at tick `width`, and later bits do not reach that cell."""
    window = row & ((1 << (2 * width + 3)) - 1)
    chosen = []
    for s in range(1, width + 1):
        trial = window
        for b in chosen + [0] * (width - len(chosen)):
            trial = step(trial, b, 2 * width + 3)
        chosen.append(0 if (trial >> (width - s)) & 1 == (target >> (width - s)) & 1 else 1)
    return chosen


def history(modes, weights, half, ticks):
    """Follow the schedule for `ticks` ticks. Returns the worst scaled errors and the final counts."""
    K = sum(weights)
    Pc = sum(r * w for r, w in zip(RATE_C, weights))
    Pa = sum(r * w for r, w in zip(RATE_A, weights))
    bound = K * (60 * K + 4317)
    size = ticks + 80
    row = half & ((1 << size) - 1)
    T = C = A = 0
    worst_c = worst_a = 0.0
    stretches = 0
    marks = {}

    def count():
        nonlocal T, C, A, worst_c, worst_a
        c0, c1 = row & 1, (row >> 1) & 1
        C += c0
        A += c0 & (1 - c1)
        T += 1
        ec, ea = 60 * K * C - Pc * T, 60 * K * A - Pa * T
        assert ec * ec <= 2 * bound * bound * (T + 1) and ea * ea <= 2 * bound * bound * (T + 1), ('theorem bound', T)
        worst_c = max(worst_c, abs(ec) / math.sqrt(2 * T + 2))
        worst_a = max(worst_a, abs(ea) / math.sqrt(2 * T + 2))
        if T in (ticks // 100, ticks // 10, ticks):
            marks[T] = (C / T, A / T)

    e = 0
    while T < ticks:
        for i, m in enumerate(modes):
            W = m['width']
            target = m['nodes'][m['start']][0]
            for b in steer(row, W, target):
                if T >= ticks:
                    return worst_c, worst_a, marks, bound, stretches
                count()
                size -= 1
                row = step(row, b, size)
            assert row & ((1 << W) - 1) == target & ((1 << W) - 1), ('steering', m['name'], T)
            node, c, a = m['start'], 0, 0
            for t in range(weights[i] * e):
                if T >= ticks:
                    return worst_c, worst_a, marks, bound, stretches
                word, ctrl, z, o = m['nodes'][node]
                assert row & ((1 << W) - 1) == word & ((1 << W) - 1), ('window', m['name'], T)
                c += row & 1
                a += (row & 1) & (1 - ((row >> 1) & 1))
                count()
                node = o if (row >> W) & 1 else z
                assert node < len(m['nodes']), ('table', m['name'], T)
                size -= 1
                row = step(row, 1 if ctrl else 0, size)
                assert abs(m['den'] * c - m['black'] * (t + 1)) <= m['cap'], ('black cap', m['name'], T)
                assert abs(m['den'] * a - m['source'] * (t + 1)) <= m['cap'], ('source cap', m['name'], T)
            stretches += 1
        e += 1
    return worst_c, worst_a, marks, bound, stretches


def main():
    ticks = int(sys.argv[1]) if len(sys.argv) > 1 else 60000
    modes = tables()
    print('controllers:', ', '.join('%s width %d, %d states, corner (%d/%d, %d/%d), cap %d' % (
        m['name'], m['width'], len(m['nodes']), m['black'], m['den'], m['source'], m['den'], m['cap']) for m in modes))
    rng = random.Random(30)
    random_half = rng.getrandbits(ticks + 80)
    extra = [('white', 0), ('black', (1 << (ticks + 80)) - 1)]
    weight_sets = [(1, 1, 1, 1, 1), (0, 0, 1, 1, 0), (1, 0, 0, 0, 1), (0, 2, 0, 3, 0), (5, 1, 1, 1, 1), (0, 0, 0, 1, 0),
                   (1, 0, 0, 0, 0), (0, 1, 0, 0, 0), (2, 0, 3, 0, 4)]
    print('%d ticks per history; the theorem allows |60KC - PT| / sqrt(2T+2) up to K(60K+4317)' % ticks)
    print('%-7s %-11s %7s %8s %8s  %-16s %-16s %-16s %s' % ('weights', 'right half', 'allowed', 'worst C', 'worst A',
                                                            '(C/T, A/T) N/100', 'at N/10', 'at N', 'target'))
    worst_ratio, worst_gap = 0.0, 0.0
    for w in weight_sets:
        K = sum(w)
        Pc = sum(r * x for r, x in zip(RATE_C, w))
        Pa = sum(r * x for r, x in zip(RATE_A, w))
        halves = [('random', random_half), ('single seed', 1)] + (extra if w == (1, 1, 1, 1, 1) else [])
        for name, half in halves:
            wc, wa, marks, bound, stretches = history(modes, w, half, ticks)
            worst_ratio = max(worst_ratio, wc / bound, wa / bound)
            end = marks[ticks]
            worst_gap = max(worst_gap, abs(end[0] - Pc / (60 * K)), abs(end[1] - Pa / (60 * K)))
            print('%-7s %-11s %7d %8.1f %8.1f  %-16s %-16s %-16s (%.4f, %.4f)' % (
                ''.join(map(str, w)), name, bound, wc, wa,
                *('(%.4f, %.4f)' % marks[t] for t in (ticks // 100, ticks // 10, ticks)), Pc / (60 * K), Pa / (60 * K)))
    print('every assertion held; the largest scaled error was %.4f of the allowed constant; '
          'the largest distance from a target at N was %.4f' % (worst_ratio, worst_gap))


if __name__ == '__main__':
    main()
