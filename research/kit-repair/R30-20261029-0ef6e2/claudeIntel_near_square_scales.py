"""Third follow-up (claudeIntel, N7): near-square events across scales for the 20 two-arc golden codings.

The window scan (N6 addendum 3) showed that the best excess in each lag window is attained at a golden convergent.
This scans only the convergents q_n, now up to 832,040 on 6,000,000 letters, for the same 20 two-arc codes as the
frozen probe (same seed, same draws). For each (code, convergent) it records E(q_n), and it reports the rate of the
event E(q_n) >= -10 (corollary F's hypothesis with K = 9) in the scales q_n >= 100, by halves of the scale range.

Usage: python claudeIntel_near_square_scales.py OUTFILE
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('followup', os.path.join(HERE, 'claudeIntel_near_square_followup.py'))
f = importlib.util.module_from_spec(spec)
spec.loader.exec_module(f)
p = f.p

N_S = 6_000_000
Q_MAX = 832_040
EVENT = -10


def main(path):
    qs = [q for q in p.convergents(10 ** 7) if 100 <= q <= Q_MAX]
    half = len(qs) // 2
    lines = [f'N_S = {N_S}, convergents {qs}, event E >= {EVENT}', '']
    first = second = 0
    for k, (theta, arcs) in enumerate(f.two_arc_cases()):
        c = p.code(p.orbit(theta, N_S), arcs)
        row, hits = [], []
        for j, q in enumerate(qs):
            e, open_end = p.excess_max(c, q)
            row.append('none' if e is None else f'{e}{"+" if open_end else ""}')
            if e is not None and e >= EVENT:
                hits.append(q)
                if j < half:
                    first += 1
                else:
                    second += 1
        lines.append(f'two arcs #{k}: events at {hits}; E(q_n): {" ".join(row)}')
    n1, n2 = 20 * half, 20 * (len(qs) - half)
    lines.append('')
    lines.append(f'event rate, first {half} scales: {first}/{n1} = {first / n1:.3f}; '
                 f'last {len(qs) - half} scales: {second}/{n2} = {second / n2:.3f}')
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main(sys.argv[1])
