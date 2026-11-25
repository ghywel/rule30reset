# claudeIntel, comb: failing k-step predecessors on the line at age T, finite seeds of width W (cells 1..W-1 free), bit-sliced.   usage: agek.py K W T0 T1 [NRAND SEED]
import sys, itertools, numpy as np
K, W, T0, T1 = map(int, sys.argv[1:5]); NR = int(sys.argv[5]) if len(sys.argv) > 5 else 0; SD = int(sys.argv[6]) if len(sys.argv) > 6 else 1
U = np.uint64
BASE = [0xAAAAAAAAAAAAAAAA, 0xCCCCCCCCCCCCCCCC, 0xF0F0F0F0F0F0F0F0, 0xFF00FF00FF00FF00, 0xFFFF0000FFFF0000, 0xFFFFFFFF00000000]
if NR:
    rng = np.random.default_rng(SD); n = NR >> 6; s = [np.full(n, ~U(0))] + [rng.integers(0, 2**64, size=n, dtype=np.uint64) for _ in range(W - 1)]
else:
    n = 1 << max(0, W - 1 - 6); s = [np.full(n, ~U(0))]
    for i in range(W - 1): s.append(np.full(n, U(BASE[i])) if i < 6 else np.where((np.arange(n) >> (i - 6)) & 1, ~U(0), U(0)).astype(np.uint64))
Z = np.zeros(n, np.uint64); O = np.full(n, ~U(0)); row = s
for t in range(T1):
    r = [Z, Z] + row + [Z, Z]; row = [r[i] ^ (r[i + 1] | r[i + 2]) for i in range(len(r) - 2)]
    if t + 1 < T0: continue
    PAD = 60; R = [Z] * (K + 6) + row + [Z] * PAD; m = len(R)
    def inv(im, tail, top):                       # im on 0..top ; returns z on 0..top (z[top], z[top+1] given)
        z = [None] * (m + 1); z[top + 1] = tail[1]; z[top] = tail[0]
        for p in range(top, 0, -1): z[p - 1] = im[p] ^ (z[p] | z[p + 1])
        return z
    bad = np.zeros(n, np.uint64)
    z1 = inv(R, (O, O), m - 1)
    def rec(z, layer, top):
        global bad
        if layer == K: bad |= z[0] & z[1] & z[2]; return
        for tail in ((O, O), (O, Z), (Z, O), (Z, Z)): rec(inv(z, tail, top - 1), layer + 1, top - 1)
    rec(z1, 1, m - 1)
    c = int(np.bitwise_count(bad).sum()); ex = ''
    if c:
        k = int(np.flatnonzero(bad)[0]); b = int(bad[k]); j = (b & -b).bit_length() - 1; ex = ''.join(str((int(s[i][k]) >> j) & 1) for i in range(W))
    print('k=%d width %d age %d: %d failing of %d  %s' % (K, W, t + 1, c, 64 * n, ex), flush=True)
