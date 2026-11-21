#!/usr/bin/env python3
"""The exceptional word in physical coordinates: psi_L(x) agrees with trunc(2L-1) at depths 1..2n
exactly when every free bit is black (x = the Rule 30 start with that main-phase trace).

  python3 research/m10/claudeM5_r63_physical.py
"""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r63_check as m

def psi(L, r, D):
    out = 0
    for k in range(1, D + 1):
        v = (r >> k) & 1
        if k % 2 == 1 and k >= 2 * L + 1 and all(((r >> j) & 1) == (j % 2) for j in range(1, k)):
            v ^= 1
        out |= v << k
    return out

bad = tested = 0
for n in range(1, 10):
    R, fb = m.traces(n, 'main')
    for L in range(1, n + 2):
        trunc = sum(1 << k for k in range(1, 2 * n + 1) if k % 2 == 1 and k <= 2 * L - 1)
        mask = sum(1 << k for k in range(1, 2 * n + 1))
        for i, r in enumerate(R.tolist()):
            allblack = all(b[i] for b in fb)
            agrees = (psi(L, r, 2 * n) & mask) == trunc
            bad += agrees != allblack
            tested += 1
print('tested', tested, 'mismatches', bad)
sys.exit(1 if bad else 0)
