"""Second follow-up (claudeIntel, N6 addendum 2): does the best excess of two-arc #9 and #19 fall without bound?

Corollary F excludes a word when, for one fixed K, some lag-q run has excess b - 2a - q >= -K - 1 at unbounded q.
For each dyadic window of lags [2^k, 2^(k+1)), this prints the maximum excess M_k, and how many lags in the window
reach -10, -30 and -100. The silver word is the control: M_k should be -3 in every window that holds a Pell number.

Usage: python claudeIntel_near_square_windows.py OUTFILE
"""
import importlib.util
import os
import sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('followup', os.path.join(HERE, 'claudeIntel_near_square_followup.py'))
f = importlib.util.module_from_spec(spec)
spec.loader.exec_module(f)
p = f.p

N_W = 400_000
K_MAX = 15                     # windows [2^k, 2^(k+1)) for k = 4 .. 15, all lags below 65536


def windows(c):
    rows = []
    for k in range(4, K_MAX + 1):
        lo, hi = 1 << k, 1 << (k + 1)
        es = []
        for q in range(lo, hi):
            e, _ = p.excess_max(c, q)
            if e is not None:
                es.append(e)
        es = np.array(es)
        rows.append(f'  [{lo}, {hi}): lags {es.size}, M = {int(es.max())}, '
                    f'>= -10: {int((es >= -10).sum())}, >= -30: {int((es >= -30).sum())}, >= -100: {int((es >= -100).sum())}')
    return rows


def main(path):
    cases = f.two_arc_cases()
    lines = [f'N_W = {N_W}, windows [2^k, 2^(k+1)) for k = 4..{K_MAX}', '']
    for k in (9, 19):
        theta, arcs = cases[k]
        c = p.code(p.orbit(theta, N_W), arcs)
        lines.append(f'two arcs #{k}:')
        lines += windows(c)
    beta_half = (2 - 2 ** 0.5) / 2
    b = np.uint64(int(round(beta_half * p.MOD)) % p.MOD)
    with np.errstate(over='ignore'):
        silver = (np.arange(N_W, dtype=np.uint64) * b) >= np.uint64(1 << 63)
    lines.append('silver (control):')
    lines += windows(silver)
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main(sys.argv[1])
