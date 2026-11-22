#!/usr/bin/env python3
"""claudeCloud_k50_4_ring_control.py: pull K50.4 (ledger K62). An independent count of the cascade's M(k).

Every row of spatial period dividing 24 is a ring of 24 cells: 2^24 rings. Each is stepped forward by rule 30
(new = left xor (centre or right)); at each tick the rings that have just become all black are counted. A ring
is all black at most once (the next row is all white), so the count at tick k - 1 is the number of rows of
period dividing 24 that reach all black in exactly k - 1 ticks. The cascade program says every node through
stage 65 has period dividing 24, so this count must equal its M(k) for k = 1 .. 65, and at stage 66, where one
of its two nodes takes period 48, the count must be 24 against M = 72. Nothing of the cascade program is used.

    python3 claudeCloud_k50_4_ring_control.py [TICKS]
"""
import sys
import numpy as np

N = 24
MASK = np.uint32((1 << N) - 1)
x = np.arange(1 << N, dtype=np.uint32)
ticks = int(sys.argv[1]) if len(sys.argv) > 1 else 70
out = []
for t in range(ticks + 1):
    out.append(int(np.count_nonzero(x == MASK)))
    left = ((x << np.uint32(1)) | (x >> np.uint32(N - 1))) & MASK       # cell i - 1 moved to place i
    right = ((x >> np.uint32(1)) | (x << np.uint32(N - 1))) & MASK      # cell i + 1 moved to place i
    x = left ^ (x | right)
print('stage k: rings of 24 cells that are all black after exactly k - 1 ticks')
print(' '.join('%d:%d' % (t + 1, c) for t, c in enumerate(out)))
