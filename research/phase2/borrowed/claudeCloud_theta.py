#!/usr/bin/env python3
"""claudeCloud_theta.py: the sideways decoding of a surviving white-wall row, for time (150, 180) and for rule 30
(ledger K102, pull K92.5.B).

A row that passes every even check has wall readings 1 at even ticks and free bits U_0, U_1, ... at the odd ticks
2j + 1.  Both systems are permutive in the western input, so the wall column decodes the row: with column -1 white,
    col_{k+1}(t) = col_k(t+1) xor g_t(col_k(t), col_{k-1}(t)),
g_t = xor at even t and (c and not r) at odd t for the hybrid (rules 150 then 180), and g = or for rule 30 (the kit's
zero-wall frame, depth 1 as column 0).  The initial row is x_k = col_k(0), a Boolean function of the U's.

    python3 claudeCloud_theta.py N [hybrid|rule30]

For N free bits: the algebraic normal form of x_k for small k, the degree of every x_k, and the number of U words
whose decoded row is white at indices K, ..., 2N for each K (rows of width at most K that pass every check through
tick 2N).
"""
import sys
import numpy as np


def anf(tt):
    a = tt.copy()
    n = a.size.bit_length() - 1
    for i in range(n):
        s = 1 << i
        a = a.reshape(-1, 2 * s)
        a[:, s:] ^= a[:, :s]
        a = a.reshape(-1)
    return a


def monomials(tt, n):
    a = anf(tt)
    out = []
    for m in np.nonzero(a)[0]:
        out.append('1' if m == 0 else '*'.join('U%d' % i for i in range(n) if (m >> i) & 1))
    return out


def decode(n, system):
    idx = np.arange(1 << n, dtype=np.uint32)
    U = [((idx >> j) & 1).astype(np.uint8) for j in range(n)]
    one = np.ones(1 << n, np.uint8)
    zero = np.zeros(1 << n, np.uint8)
    T = 2 * n
    col0 = [one if t % 2 == 0 else U[(t - 1) // 2] for t in range(T + 1)]
    prev, cur = [zero] * (T + 1), col0
    xs = [col0[0]]
    for k in range(T):
        nxt = []
        for t in range(T - k):
            c, r = cur[t], prev[t]
            if system == 'rule30':
                g = c | r
            else:
                g = (c ^ r) if t % 2 == 0 else (c & (1 - r))
            nxt.append(cur[t + 1] ^ g)
        prev, cur = cur, nxt + [zero] * (k + 1)
        xs.append(cur[0])
    return xs


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    system = sys.argv[2] if len(sys.argv) > 2 else 'hybrid'
    xs = decode(n, system)
    print('%s, %d free odd readings: x_k = col_k(0)' % (system, n))
    for k in range(min(len(xs), 13)):
        ms = monomials(xs[k], n)
        print('  x_%d = %s' % (k, ' + '.join(ms[:12]) + (' + ... (%d terms)' % len(ms) if len(ms) > 12 else '')))
    degs = []
    for k in range(len(xs)):
        a = anf(xs[k])
        nz = np.nonzero(a)[0]
        degs.append(max((bin(int(m)).count('1') for m in nz), default=-1))
    print('degree of x_k, k = 0..%d: %s' % (len(xs) - 1, degs))
    print('rows of width at most K passing every even check through tick %d (U words whose x is white beyond K):' % (2 * n))
    alive = np.ones(1 << n, bool)
    counts = {}
    for K in range(2 * n, -1, -1):
        alive &= (xs[K] == 0) if K < len(xs) else alive
        counts[K] = int(alive.sum())
    print('  ' + ', '.join('K=%d: %d' % (K, counts[K]) for K in range(2 * n, n - 1, -1)))


if __name__ == '__main__':
    main()
