#!/usr/bin/env python3
"""M6, the surprise of M20: the tail density of the eternal gap rows built from runs of 3-gaps.

The seed of an infinite accepted trace is computed to depth D by the antidiagonal recurrence of m6_floors.py
(seed bit T from trace bits 0..T). The tail density is the share of black seed bits in [D/4, D), also reported on
four equal windows to show its spread (MEASURED). Control: the all-5 row, whose density is exactly 68/155 (M15).

Rows (gap words, double steps; the trace of gap g is 0 1 then g - 1 pairs 1 1):
  all-3: 3 3 3 ...            the run that fills R20's minimisers
  5555 then all-3:            the minimisers' opening, then the run
  all-5: 5 5 5 ... (control)  exact density 68/155 ~ 0.43871
  35 repeated, 335 repeated, 3335 repeated: mixtures
Usage: m6_three.py OUTFILE [--depth 24000]
"""
import argparse, json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6_floors import extend


def trace_of(prefix, cycle, n):
    out = []
    def block(g):
        return [0, 1] + [1, 1] * (g - 1)
    for g in prefix:
        out += block(g)
    while len(out) < n:
        for g in cycle:
            out += block(g)
    return out[:n]


def seed_bits(tr):
    A1 = A2 = 0
    bits = []
    for T, b in enumerate(tr):
        A = extend(A1, A2, T, b)
        bits.append((A >> T) & 1)
        A1, A2 = A, A1
    return bits


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--depth', type=int, default=24000)
    a = ap.parse_args()
    D = a.depth
    rows = {'all-3': ([], [3]), '5555 then all-3': ([5, 5, 5, 5], [3]), 'all-5 (control)': ([], [5]),
            '35': ([], [3, 5]), '335': ([], [3, 3, 5]), '3335': ([], [3, 3, 3, 5])}
    res = {'depth': D}
    for name, (p, c) in rows.items():
        bits = seed_bits(trace_of(p, c, D))
        lo = D // 4
        tail = bits[lo:]
        q = (D - lo) // 4
        res[name] = {'tail_density': round(sum(tail) / len(tail), 5),
                     'windows': [round(sum(tail[i * q:(i + 1) * q]) / q, 4) for i in range(4)]}
    res['control_exact_all5'] = round(68 / 155, 5)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
