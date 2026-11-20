#!/usr/bin/env python3
"""claudeCloud_row_chain_exact.py: the stationary law of the row chain of claudeCloud_row_chain.py in exact
fractions, at a small width (pull K5; ledger K29 addendum 1, K30). The larger widths there are computed in floating
point; this confirms in exact arithmetic the fractions K29 read off those decimals.

The chain: wheel 0 white; wheel 1 a fair coin at each tick; wheel j at the next tick is
wheel j-2 xor (wheel j-1 or wheel j) now. The stationary law solves mu = mu P with total 1, by exact elimination.

  python3 claudeCloud_row_chain_exact.py X      (X up to about 9)
"""
import sys
from fractions import Fraction


def main(X):
    n = 1 << X                                           # bit j-1 of a state is wheel j
    def step(v, b):
        full = v << 1
        new = ((full << 2) ^ ((full << 1) | full)) & ((1 << (X + 1)) - 1)
        return ((new >> 1) & ~1) | b
    states = [v for v in range(n) if (v >> 1) & 1]       # wheel 2 is black in the stationary law
    idx = {v: i for i, v in enumerate(states)}
    m = len(states)
    # unknown mu; equations: for each state s, sum over predecessors mu(p)/2 - mu(s) = 0; replace one by sum = 1
    A = [[Fraction(0)] * (m + 1) for _ in range(m)]
    for v in states:
        for b in (0, 1):
            w = step(v, b)
            A[idx[w]][idx[v]] += Fraction(1, 2)
    for i in range(m):
        A[i][i] -= 1
    A[m - 1] = [Fraction(1)] * m + [Fraction(1)]
    for c in range(m):                                   # exact Gauss-Jordan
        p = next(r for r in range(c, m) if A[r][c] != 0)
        A[c], A[p] = A[p], A[c]
        inv = 1 / A[c][c]
        A[c] = [x * inv for x in A[c]]
        for r in range(m):
            if r != c and A[r][c] != 0:
                f = A[r][c]
                A[r] = [x - f * y for x, y in zip(A[r], A[c])]
    mu = {v: A[idx[v]][m] for v in states}
    assert sum(mu.values()) == 1 and all(x >= 0 for x in mu.values())
    def first_reset(v):
        run = 0                                          # wheel 0 is white
        for j in range(1, X + 1):
            if (v >> (j - 1)) & 1:
                run += 1
            else:
                if run % 3 == 1:
                    return j
                run = 0
        return None
    print('width %d, %d states, exact fractions' % (X, m))
    print('wheel   chance black   q(x): no reset word by wheel x')
    for x in range(1, X + 1):
        black = sum(p for v, p in mu.items() if (v >> (x - 1)) & 1)
        q = sum(p for v, p in mu.items() if first_reset(v) is None or first_reset(v) > x)
        print('%5d   %-12s   %s  (%.9f)' % (x, black, q, float(q)))


if __name__ == '__main__':
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 8)
