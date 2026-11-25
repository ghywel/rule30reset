# claudeIntel, comb: is age 24 sharp on the line for two inverse ticks (K50.3's leftover)?
# Finite seeds x0 with leftmost black cell 0 and support in [0, W-1].  R = F^T x0.  Run the inverse rule z(p-1) = R(p) xor (z(p) or z(p+1)) leftward from a right tail:
# z = 1 for ever on the right (the only tail other than the truth's white tail over a white image); then y over z from the three period-3 tails.
# A failure: y black for ever on the left.   Bit-sliced, 64 seeds a word.      usage: age23.py AGE WMAX [K]
import sys, numpy as np
T, WM = int(sys.argv[1]), int(sys.argv[2]); K = int(sys.argv[3]) if len(sys.argv) > 3 else 2
U = np.uint64
BASE = [0xAAAAAAAAAAAAAAAA, 0xCCCCCCCCCCCCCCCC, 0xF0F0F0F0F0F0F0F0, 0xFF00FF00FF00FF00, 0xFFFF0000FFFF0000, 0xFFFFFFFF00000000]
def seeds(W, chunk, bits):                      # cells 1..W-1 run over all 2^(W-1) words; chunk fixes the high ones
    n = 1 << max(0, min(W - 1, bits) - 6); out = [np.full(n, ~U(0))]
    for i in range(W - 1):
        if i < 6: out.append(np.full(n, U(BASE[i])))
        elif i < bits: out.append(np.where((np.arange(n) >> (i - 6)) & 1, ~U(0), U(0)).astype(np.uint64))
        else: out.append(np.full(n, ~U(0) if (chunk >> (i - bits)) & 1 else U(0)))
    return out
bits = 20
for W in range(1, WM + 1):
    found = 0; ex = None
    for chunk in range(1 << max(0, W - 1 - bits)):
        s = seeds(W, chunk, bits); n = len(s[0]); Z = np.zeros(n, np.uint64); O = np.full(n, ~U(0))
        row = s; lo = 0
        for t in range(T):
            r = [Z, Z] + row + [Z, Z]; row = [r[i] ^ (r[i + 1] | r[i + 2]) for i in range(len(r) - 2)]; lo -= 1      # cell lo..
        # row[j] is the cell lo + j, lo = -T, length W + 2T
        PAD = 24; Lp = 12
        R = [Z] * Lp + row + [Z] * PAD                        # positions lo-Lp ...
        m = len(R)
        def inv(im, tail):                                    # tail: (value at position m-1, m) ; returns z on 0..m-1 ; z(p-1) = im(p) ^ (z(p) | z(p+1))
            z = [None] * (m + 1); z[m] = tail[1]; z[m - 1] = tail[0]
            for p in range(m - 1, 0, -1): z[p - 1] = im[p] ^ (z[p] | z[p + 1])
            return z
        layers = [(R, [])]
        fails = np.zeros(n, np.uint64)
        z = inv(R, (O, O))
        if K == 1:
            bad = z[0] & z[1] & z[2]                          # black on the far left
        else:
            bad = np.zeros(n, np.uint64)
            for tail in ((O, Z), (Z, O), (Z, Z)):
                y = inv(z, tail); bad |= y[0] & y[1] & y[2]
        mask = ~U(0) if W - 1 >= 6 else U((1 << (1 << (W - 1))) - 1)
        bad = bad & mask
        if bad.any():
            c = int(sum(bin(int(v)).count('1') for v in bad)); found += c
            if ex is None:
                k = int(np.flatnonzero(bad)[0]); b = int(bad[k]); j = (b & -b).bit_length() - 1
                ex = ''.join(str((int(s[i][k]) >> j) & 1) for i in range(W))
    print('age %d k=%d width %d: %d failing seeds%s' % (T, K, W, found, '  first ' + ex if ex else ''), flush=True)
