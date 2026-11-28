#!/usr/bin/env python3
"""claudeCloud_wall_degree.py: the algebraic degree of the wall readings in time hybrids beside a white wall
(ledger K101, pull K92.5.B).

The initial row is x_0, x_1, ... (index 0 beside the wall).  Each tick applies new(k) = old(k+1) xor f(old(k), old(k-1))
with old(-1) = 0, the rule chosen by the tick's parity.  The wall cell at tick t depends on x_0 .. x_t only, so it is a
Boolean function of t + 1 variables.  Its truth table is computed for all 2^(t+1) inputs at once (one bit-array per
cell), and its algebraic normal form by the Moebius transform; the degree is the largest monomial.

    python3 claudeCloud_wall_degree.py TMAX [A/B ...]     default systems: 30, 150/180, 180/150, 30/180, 150

Prints, per system, the degree of the wall reading at ticks 0 .. TMAX.  For a single rule A write A.
"""
import sys
import numpy as np


def f(rule, c, r):
    if rule == 30:
        return c | r
    if rule == 150:
        return c ^ r
    if rule == 90:
        return r
    if rule == 180:
        return c & ~r
    if rule == 210:
        return ~c & r
    if rule == 120:
        return c & r
    if rule == 60:
        return c
    raise ValueError(rule)


def wall_function(rules, t):
    """Truth table (uint8 array of length 2^(t+1)) of the wall cell at tick t."""
    n = t + 1
    idx = np.arange(1 << n, dtype=np.uint32)
    width = n + t + 2
    row = [((idx >> k) & 1).astype(np.uint8) if k < n else np.zeros(1 << n, np.uint8) for k in range(width)]
    zero = np.zeros(1 << n, np.uint8)
    for s in range(t):
        rule = rules[s % len(rules)]
        row = [row[k + 1] ^ (f(rule, row[k], row[k - 1] if k else zero) & 1) for k in range(len(row) - 1)]
    return row[0] & 1


def degree(tt):
    a = tt.copy()
    n = a.size.bit_length() - 1
    for i in range(n):
        step = 1 << i
        a = a.reshape(-1, 2 * step)
        a[:, step:] ^= a[:, :step]
        a = a.reshape(-1)
    nz = np.nonzero(a)[0]
    if nz.size == 0:
        return -1
    pop = np.zeros(nz.size, np.int64)
    v = nz.astype(np.int64)
    while v.any():
        pop += v & 1
        v >>= 1
    return int(pop.max())


def main():
    tmax = int(sys.argv[1]) if len(sys.argv) > 1 else 16
    systems = [list(map(int, a.split('/'))) for a in sys.argv[2:]] or [[30], [150, 180], [180, 150], [30, 180], [150]]
    for rules in systems:
        degs = [degree(wall_function(rules, t)) for t in range(tmax + 1)]
        print('%-8s wall degree, ticks 0..%d: %s' % ('/'.join(map(str, rules)), tmax, degs))
        sys.stdout.flush()


if __name__ == '__main__':
    main()
