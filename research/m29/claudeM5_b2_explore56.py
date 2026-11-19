"""Exploratory, not frozen (M47): gap 56 of B2, whose cubes all completed but whose certificate ran out of time.

Runs the frozen B2 script's own functions (claudeM5_b2_cyclic.py, SHA-256 0272dc06...) unchanged on gap 56's
solver-complete, uncertified listing, and prints its cyclic part and doublings. It is not a verdict: without the
checked certificate, gap 56 stays UNKNOWN (I2's rule).

    python3 research/m29/claudeM5_b2_explore56.py RUNDIR
"""
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import claudeM5_b2_cyclic as b2  # noqa: E402

run, n = sys.argv[1], 56
rows, complete = [], True
for c in range(1 << b2.NCUBE_BITS):
    r, ok = b2.read_cube(os.path.join(run, f'gap{n}-cube{c}.rows'))
    rows += r
    complete &= ok
rows = sorted(set(rows))
t0 = time.time()
comps, E = b2.cyclic_components([b2.tup(r) for r in rows], n)
swaps = [s for c in b2.analyze(n, comps, E) for s in c['swaps']]
keys = ('h', 'source_least_period', 'single_cycle', 'walk_whole', 'walk_reset_free_rows', 'walk_ok', 'pairs',
        'swappable')
print(json.dumps({'gap': n, 'status': 'EXPLORATORY, uncertified', 'cubes_complete': complete, 'R_k': len(rows),
                  'cyclic_rows': sum(len(C) for C in comps), 'components': len(comps),
                  'doublings': [{k: s.get(k) for k in keys} for s in swaps], 'seconds': round(time.time() - t0, 1)}))
