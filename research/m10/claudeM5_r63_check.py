#!/usr/bin/env python3
"""claudeM5's independent read of R63's planted first check, by forward simulation.

No reconstruction recursion: every start of depths 1..2n+1 (the wall at depth 0 white) is run forward
2n ticks under rule 30 (new(k) = x(k+1) XOR (x(k) OR x(k-1))). A start whose depth-1 cell is black at
every even tick 0..2n defines the free word f_s = depth 1 at tick 2s+1 (s < n), and its cell at depth
2n+1 is the check. The opposite phase fixes the odd ticks black, takes f_s at tick 2s and reads depth 2n.
Planting: psi_L flips odd depth k >= 2L+1 exactly when depths 1..k-1 agree with the stripe (black at odd
depths). The ANF comes from the Moebius transform.

  python3 research/m10/claudeM5_r63_check.py [N]   (default N = 8; M77 ran N = 11)
"""
import sys
import numpy as np


def traces(n, phase):
    width = 2 * n + 1 if phase == 'main' else 2 * n  # the depths the read cell depends on
    R = (np.arange(1 << width, dtype=np.uint64) << np.uint64(1))  # bit k = depth k; bit 0 = wall
    x = R.copy()
    bits = []
    for t in range(width):
        bits.append(((x >> np.uint64(1)) & np.uint64(1)).astype(bool))
        x = ((x >> np.uint64(1)) ^ (x | (x << np.uint64(1)))) & ~np.uint64(1)
    fixed = [t for t in range(width) if t % 2 == (0 if phase == 'main' else 1)]
    free = [2 * s + (1 if phase == 'main' else 0) for s in range(n)]
    ok = np.ones(R.shape, bool)
    for t in fixed:
        ok &= bits[t]
    return R[ok], [bits[t][ok] for t in free]


def check_table(n, phase, L=None):
    """Truth table indexed by sum f_s 2^s, read at depth 2n+1 (main) or 2n (other), planted if L."""
    R, fb = traces(n, phase)
    idx = np.zeros(R.shape, np.int64)
    for s, b in enumerate(fb):
        idx |= b.astype(np.int64) << s
    assert len(idx) == 1 << n and len(set(idx.tolist())) == 1 << n, 'not a bijection on traces'
    depth = 2 * n + 1 if phase == 'main' else 2 * n
    out = np.zeros(1 << n, np.uint8)
    for r, i in zip(R.tolist(), idx.tolist()):
        v = (r >> depth) & 1
        if L is not None and depth % 2 == 1 and depth >= 2 * L + 1:
            agree = all(((r >> j) & 1) == (j % 2) for j in range(1, depth))
            v ^= int(agree)
        out[i] = v
    return out


def anf(tab):
    a = tab.copy()
    n = int(len(a)).bit_length() - 1
    for s in range(n):
        step = 1 << s
        for m in range(len(a)):
            if m & step:
                a[m] ^= a[m ^ step]
    return a


def degree(a):
    nz = [bin(m).count('1') for m in range(len(a)) if a[m]]
    return max(nz) if nz else None  # None: the zero function


def main(N):
    bad = 0
    for n in range(1, N + 1):
        full = (1 << n) - 1
        C = check_table(n, 'main')
        A = anf(C)
        dC = degree(A)
        want = n if n % 2 else n - 1
        line = ['n=%2d' % n, 'deg C=%s (kit %d)' % (dC, want)]
        bad += dC != want
        if n >= 2:
            om1 = int(A[full ^ 0b10])
            line.append('omit f1=%d (want %d)' % (om1, n % 2 == 0)); bad += om1 != (n % 2 == 0)
        if n >= 3:
            om3 = int(A[full ^ 0b100])
            line.append('omit f2=%d (want 1)' % om3); bad += om3 != 1
        for L in range(1, n + 2):
            P = check_table(n, 'main', L)
            diff = np.nonzero(P ^ C)[0].tolist()
            want_diff = [full] if L <= n else []
            bad += diff != want_diff
            dP = degree(anf(P))
            if n == 1 and L == 1:
                wantP = None
            elif L > n:
                wantP = want
            else:
                wantP = n if n % 2 == 0 else n - 1
            bad += dP != wantP
            line.append('L=%d:deg %s%s' % (L, dP, '' if dP == wantP else '!'))
        O = check_table(n, 'other')
        dO = degree(anf(O))
        bad += dO != n
        for L in range(1, n + 2):
            bad += not np.array_equal(check_table(n, 'other', L), O)
        line.append('other deg=%s' % dO)
        print('  '.join(line))
    print('MISMATCHES', bad)
    return bad


if __name__ == '__main__':
    sys.exit(1 if main(int(sys.argv[1]) if len(sys.argv) > 1 else 8) else 0)
