#!/usr/bin/env python3
"""claudeCloud_r6_duhamel.py: pull R6, first block (ledger K37). The centre column at powers of two, split by the
Duhamel identity.

Rule 30 over GF(2): new cell = left + centre + right + centre*right. So rule 30 is rule 150 (left + centre + right)
plus a SOURCE at each adjacent black pair: q(t, p) = a(t, p) a(t, p+1) feeds cell (t+1, p). Rule 150 run for m ticks
is multiplication by (1 + x + x^2)^m, and for m = h = 2^k that is 1 + x^h + x^(2h): it reads sites -h, 0, h only. On
row h the two edge cells are black and cancel, so

    c(2h) = c(h) + S(h),   S(h) = sum over h <= t < 2h and p of q(t, p) * [x^(p + m)] (1 + x + x^2)^m,  m = 2h - 1 - t

(the weight is the rule-150 propagator from (t+1, p) to (2h, 0)). c(2h) differs from c(h) exactly when S(h) is odd.

  python3 claudeCloud_r6_duhamel.py check K        literal rule 30 to 2^K: the identity at every h = 2^k < 2^K, and
                                                   the parities of the two half-slabs S1 (h <= t < 3h/2), S2 (the rest)
  python3 claudeCloud_r6_duhamel.py compare FILE K the C program's dump of the centre column against literal rule 30
"""
import sys


def rows(T):
    """Yield (t, row, offset): row is an int, bit offset + x is the cell at x; offset = T + 2."""
    off = T + 2
    a = 1 << off
    for t in range(T + 1):
        yield t, a, off
        a = (a << 1) ^ (a | (a >> 1))             # bit b: left neighbour is b - 1, so shift left to align it


def center(T):
    return [(a >> off) & 1 for t, a, off in rows(T)]


def check(K):
    T = 1 << K
    hist = []
    for t, a, off in rows(T):
        hist.append(a)
    off = T + 2
    c = [(a >> off) & 1 for a in hist]
    print('  k        h  c(h) c(2h)  S(h)  S1  S2  sources in the slab (weighted)   identity')
    ok = True
    for k in range(0, K):
        h = 1 << k
        # weights W_m as ints: bit (m + p) for p in [-m, m]; W_0 = 1
        W = 1
        S1 = S2 = n = 0
        for t in range(2 * h - 1, h - 1, -1):     # m = 2h - 1 - t = 0, 1, ...
            m = 2 * h - 1 - t
            a = hist[t]
            q = a & (a >> 1)                      # bit (off + p): a(p) a(p+1)
            # align: weight bit (m + p) with source bit (off + p)
            w = W << (off - m)
            cnt = bin(q & w).count('1')
            n += cnt
            if t < h + h // 2:
                S1 ^= cnt & 1
            else:
                S2 ^= cnt & 1
            W = W ^ (W << 1) ^ (W << 2)
        S = S1 ^ S2
        good = c[2 * h] == c[h] ^ S
        ok = ok and good
        print('%3d %8d   %d     %d     %d    %d   %d   %10d                      %s' % (k, h, c[h], c[2 * h], S, S1, S2, n, 'holds' if good else 'FAILS'))
    print('CONTROL identity c(2h) = c(h) + S(h): %s' % ('PASS' if ok else 'FAIL'))


def compare(path, K):
    mine = ''.join(map(str, center(1 << K)))
    theirs = open(path).read().strip()
    print('centre cells compared: %d; equal: %s' % (len(mine), mine == theirs[:len(mine)]))
    print('CONTROL dump against literal rule 30 to 2^%d: %s' % (K, 'PASS' if mine == theirs[:len(mine)] and len(theirs) >= len(mine) else 'FAIL'))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['check']:
        check(int(a[1]))
    elif a[:1] == ['compare']:
        compare(a[1], int(a[2]))
    else:
        sys.exit(__doc__)
