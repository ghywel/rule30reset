#!/usr/bin/env python3
"""claudeCloud_r5_cycle_id.py: pull R5 (ledger K38). AFTER THE FACT, not frozen before the run: which limit cycle does
each cut reach?
For one cut, run to T ticks and print the set of (tick mod 3, columns 1..W) over the last 21 ticks, hashed."""
import sys, json, hashlib
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
import claudeCloud_r5_cuts as c
j0, s, N, T = map(int, sys.argv[1:5])
row = c.ether_row(j0, s, 0, N)
out = {}
for t in range(T + 1):
    if t > T - 21:
        for W in (1, 12, 24, 30, 36, 40, 44, 47):
            out.setdefault(W, set()).add(((t + s) % 3, (row >> 1) & ((1 << W) - 1)))
    row = c.step(row, c.ether3(j0, t + s))
res = {'j0': j0, 's': s, 'N': N, 'T': T}
for W, st in out.items():
    res['h%d' % W] = hashlib.sha256(repr(sorted(st)).encode()).hexdigest()[:12]
    res['n%d' % W] = len(st)
print(json.dumps(res))
