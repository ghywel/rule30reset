#!/usr/bin/env python3
"""uniform_entry.py (ledger M165): how long can a right half beside the alternating column stay outside the closed set?

A window is the first W cells at a white tick; it has four images one period (a white tick and a black one) later. A window is
outside when its first twelve cells are not in the closed set of make_table.py. Prints, by width, the size of the two-way core of the
outside windows (a cycle needs it nonempty), the longest run of consecutive outside windows, and the size of the line that a Lean
table would need: the windows left when the times 0..n are all outside, swept as in make_table.py.
"""
import json
import pathlib
import subprocess
import sys
import tempfile
import numpy as np
U = np.uint64
W0 = 12
with tempfile.TemporaryDirectory() as d:
    subprocess.run([sys.executable, str(pathlib.Path(__file__).parent / 'make_table.py'), d + '/t.json'], check=True,
                   stdout=subprocess.DEVNULL)
    K = np.array(sorted(json.load(open(d + '/t.json'))['K']), dtype=U)
inset = np.zeros(1 << W0, bool)
inset[K.astype(np.int64)] = True
out = lambda x: ~inset[(x & U((1 << W0) - 1)).astype(np.int64)]


def step(x, W):
    r = []
    for e in range(4):
        y = x | U(e << W)
        for d in (0, 1):
            y = ((y << U(1)) | U(d)) ^ (y | (y >> U(1)))
        r.append(y & U((1 << W) - 1))
    return r


def among(a, x):
    p = np.searchsorted(a, x)
    p[p == len(a)] = 0
    return a[p] == x if len(a) else np.zeros(len(x), bool)


def core(W):
    """outside windows with an endless path both ways, through widths 12..W"""
    O = np.arange(1 << W0, dtype=U)
    O = O[out(O)]
    for w in range(W0, W + 1):
        if w > W0:
            O = np.sort(np.concatenate([O, O | U(1 << (w - 1))]))
        while True:
            c, ok = len(O), np.zeros(len(O), bool)
            for y in step(O, w):
                ok |= among(O, y)
            O = O[ok]
            if len(O):
                O = O[among(np.unique(np.concatenate(step(O, w))), O)]
            if len(O) == c:
                break
    return len(O)


def longest(W):
    cur, n = np.arange(1 << W, dtype=U), 0
    cur = cur[out(cur)]
    while len(cur):
        n += 1
        nx = np.unique(np.concatenate(step(cur, W)))
        cur = nx[out(nx)]
    return n


def line(n):
    L, tot = [np.array([0, 1], dtype=U) for _ in range(n + 1)], 0
    for W in range(1, 40):
        if W > 1:
            L = [np.concatenate([z, z + U(1 << (W - 1))]) for z in L]
        if W == W0:
            L = [z[out(z)] for z in L]
        for t in range(len(L) - 2, -1, -1):
            ok = np.zeros(len(L[t]), bool)
            for y in step(L[t], W):
                ok |= among(L[t + 1], y)
            L[t] = L[t][ok]
        for t in range(1, len(L)):
            r = np.unique(np.concatenate(step(L[t - 1], W))) if len(L[t - 1]) else L[t - 1]
            L[t] = L[t][among(r, L[t])]
        tot += sum(map(len, L))
        if sum(map(len, L)) == 0:
            return W, tot
    return None, tot


print('core of outside windows by width', [(W, core(W)) for W in range(12, 25)])
for W in range(21, 25):
    print('cells', W, 'longest run of outside windows', longest(W))
for n in (34, 35, 36, 50):
    print('n', n, '(', n + 1, 'windows in a row ): dies at width, windows over all widths', line(n))
