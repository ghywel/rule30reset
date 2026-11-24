#!/usr/bin/env python3
"""check.py: random finite right halves beside the alternating column, against the closed set of make_table.py (ledger M156).

Prints, for halves of up to 40 cells: how many enter the set, the latest first entry, and that they stay. A check on the definitions
only: it is not evidence for the dichotomy, which is the Lean's.
"""
import json
import pathlib
import random
import subprocess
import sys
import tempfile
HERE = pathlib.Path(__file__).resolve().parent
with tempfile.TemporaryDirectory() as d:
    subprocess.run([sys.executable, str(HERE / 'make_table.py'), d + '/t.json'], check=True, stdout=subprocess.DEVNULL)
    K = set(json.load(open(d + '/t.json'))['K'])
random.seed(5)
W, latest, entered, N = 700, 0, 0, 300
for _ in range(N):
    row = [True] + [random.random() < 0.5 for _ in range(random.randint(1, 40))]
    row += [False] * (W - len(row))
    rows = []
    for t in range(520):
        rows.append(row)
        row = [(t + 1) % 2 == 0] + [row[p - 1] ^ (row[p] | row[p + 1]) for p in range(1, W - 1)] + [False]
    code = [sum(rows[2 * k + 1][j + 1] << j for j in range(12)) for k in range(250)]
    first = next(k for k in range(250) if code[k] in K)
    assert all(c in K for c in code[first:])
    g = [rows[2 * k + 1][1] for k in range(250)]
    a = [rows[2 * k + 1][1] ^ rows[2 * k + 1][2] for k in range(250)]
    for k in range(249):
        assert a[k + 1] == (not a[k]) if not g[k + 1] else a[k] is False
    entered, latest = entered + 1, max(latest, first)
print('halves', N, 'entered and stayed', entered, 'latest first entry', latest)
