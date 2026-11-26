# claudeIntel, carrying read of I259: the two-run table by exhausting every right half in the light cone (no strips).
# Column 0 is driven by the word w (any column-0 word is realizable by the left side); column 1 at tick len(w) depends on
# initial cells 1..len(w)+1 only.  Forced iff that reading is constant over all 2^(len(w)+1) right halves.
import numpy as np, sys
U = np.uint64
def readings(w):
    L = len(w); n = L + 1                     # cells 1..n
    N = 1 << n; nw = max(1, N >> 6)
    lane = np.arange(N, dtype=np.uint64)
    cells = []
    for c in range(n):                        # bit-slice: cell c+1 of combination k is bit c of k
        bits = ((lane >> U(c)) & U(1)).astype(bool)
        packed = np.packbits(bits.reshape(-1, 8)[:, ::-1], axis=1).reshape(-1).view('>u8') if N >= 64 else None
        cells.append(bits)
    row = [np.zeros(N, bool)] + cells + [np.zeros(N, bool)]   # index 0 = column 0 (driven), last = column n+1 (beyond cone)
    for t in range(L):
        row[0] = np.full(N, bool(w[t]))
        new = [None] * len(row)
        for i in range(1, len(row) - 1):
            new[i] = row[i - 1] ^ (row[i] | row[i + 1])
        new[0] = row[0]; new[-1] = row[-1]
        row = new
    r1 = row[1]
    return bool(r1.all()), bool((~r1).all())
def piece(a, r): return [1] * a + [0] + [1] * r
AGE = {1: 8, 2: 8, 3: 8, 4: 15, 5: 8, 6: 16, 7: 4, 8: 14}
TONE = {1: 0, 2: 1, 3: 0, 4: 1, 5: 0, 6: 1, 7: 0, 8: 0}
for r in range(1, 9):
    a = AGE[r]
    allb, allw = readings(piece(a, r))
    forced = 1 if allb else 0 if allw else None
    lb, lw = readings(piece(a - 1, r))
    print('r=%d a=%d forced=%s (table %d) | a=%d: %s' % (r, a, forced, TONE[r], a - 1, 'both colours' if not (lb or lw) else 'forced'), flush=True)
for r in (9, 10, 11):
    allb, allw = readings(piece(0, r)); print('r=%d a=0 forced white: %s' % (r, allw))
