"""Follow-up to claudeIntel_near_square_probe.py (claudeIntel, N6 addendum 1): every lag for the two-arc codes that
showed neither Jen violations nor near-squares at the golden convergents, and where the silver word's runs start.

It rebuilds the cases with the same seed and the same draws as the frozen probe, checks that two-arc #9 reproduces
the probe's convergent row, then scans every lag q <= Q_ALL on a prefix of N_ALL letters.

Usage: python claudeIntel_near_square_followup.py OUTFILE
"""
import importlib.util
import os
import sys
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('probe', os.path.join(HERE, 'claudeIntel_near_square_probe.py'))
p = importlib.util.module_from_spec(spec)
spec.loader.exec_module(p)

N_ALL = 400_000
Q_ALL = 40_000
TARGETS = (4, 9, 19)           # two-arc cases


def two_arc_cases():
    rng = np.random.default_rng(p.SEED)
    for _ in range(20):        # the one-arc draws, discarded
        rng.integers(0, p.MOD, size=3, dtype=np.uint64)
    out = []
    for _ in range(20):
        theta = int(rng.integers(0, p.MOD, dtype=np.uint64))
        e = sorted(int(v) for v in rng.integers(0, p.MOD, size=4, dtype=np.uint64))
        out.append((theta, [(e[0], e[1]), (e[2], e[3])]))
    return out


def runs_at(c, q):
    eq = c[q:] == c[:-q]
    padded = np.concatenate(([False], eq, [False]))
    d = np.diff(padded.astype(np.int8))
    starts = np.flatnonzero(d == 1)
    ends = np.flatnonzero(d == -1) - 1
    keep = ends < eq.size - 1
    return starts[keep], ends[keep]


def main(path):
    cases = two_arc_cases()
    lines = [f'N_ALL = {N_ALL}, Q_ALL = {Q_ALL}, targets two arcs {TARGETS}', '']
    # consistency with the frozen probe: two arcs #9 at the convergents, on the probe's prefix length
    theta, arcs = cases[9]
    c = p.code(p.orbit(theta, p.N), arcs)
    row = []
    for q in p.convergents(p.N // 6):
        e, open_end = p.excess_max(c, q)
        row.append('none' if e is None else f'{e}{"+" if open_end else ""}')
    lines.append('two arcs #9 convergent row, recomputed: ' + ' '.join(row))
    for k in TARGETS:
        theta, arcs = cases[k]
        c = p.code(p.orbit(theta, N_ALL), arcs)
        top, top_q, near, jen = None, None, [], []
        for q in range(1, Q_ALL + 1):
            e, _ = p.excess_max(c, q)
            if e is None:
                continue
            if top is None or e > top:
                top, top_q = e, q
            if e >= -3 and q >= 100:
                near.append(q)
            if e >= 50:
                jen.append(q)
        lines.append(f'two arcs #{k}: max E(q), q <= {Q_ALL}: {top} at q = {top_q}; '
                     f'lags q >= 100 with E >= -3: {len(near)} {near[:40]}; lags with E >= 50: {len(jen)} {jen[:40]}')
    # the silver word: where the best runs start at the Pell lags
    beta_half = (2 - 2 ** 0.5) / 2
    b = np.uint64(int(round(beta_half * p.MOD)) % p.MOD)
    with np.errstate(over='ignore'):
        silver = (np.arange(N_ALL, dtype=np.uint64) * b) >= np.uint64(1 << 63)
    lines.append('')
    for q in (3, 7, 17, 41, 99, 239, 577, 1393, 3363, 8119, 19601):
        a, e = runs_at(silver, q)
        ex = e - 2 * a - q
        best = ex.max()
        where = [(int(x), int(y)) for x, y, z in zip(a, e, ex) if z == best][:6]
        lines.append(f'silver q = {q}: E = {int(best)}, runs attaining it (a, b): {where}')
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main(sys.argv[1])
