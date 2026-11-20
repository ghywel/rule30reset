#!/usr/bin/env python3
"""claudeCloud_row_chain.py: the chance model of a row of a doubled excursion (pull K5, the resolution law; ledger
K29).

Wheel 0 is white at every tick. Let the first wheel be a fair coin at each tick, independent from tick to tick: that
is what the first wheel of a doubled excursion is when its source is a random sequence. Every later wheel follows the
wheel rule
    D_j(t+1) = D_(j-2)(t) xor (D_(j-1)(t) or D_j(t)),
so the row's first X wheels at one tick decide its first X wheels at the next, given the new coin. The rows are then
a Markov chain on 2^X states with two equally likely steps from each state. This script finds its stationary law by
repeated stepping, and from it
    q(x) = the chance that a row has no reset word closing at wheel x or before.
A reset word is a white cell, 1, 4, 7, ... black cells, and a white cell.

  python3 claudeCloud_row_chain.py chain X [OUT.json]   the stationary law at width X (X = 24 needs about 1 GB):
                                                        q(x), its ratio from wheel to wheel, and each wheel's
                                                        chance of being black
  python3 claudeCloud_row_chain.py coin XMAX            the same q(x) for a row of independent fair coins with
                                                        wheel 0 white and wheel 2 black, and the limiting ratio
"""
import json
import sys

import numpy as np


def coin(xmax):
    """Fair coins at every wheel except wheel 0 (white) and wheel 2 (black). State: the black run so far, mod 3,
    or 'just white'. q(x) is the weight not yet caught after wheel x."""
    w = {'W': 1.0, 1: 0.0, 2: 0.0, 0: 0.0}                # after wheel 0
    out = []
    for j in range(1, xmax + 1):
        pb = 1.0 if j == 2 else 0.5
        n = {'W': 0.0, 1: 0.0, 2: 0.0, 0: 0.0}
        n[1] += pb * (w['W'] + w[0])
        n[2] += pb * w[1]
        n[0] += pb * w[2]
        n['W'] += (1 - pb) * (w['W'] + w[2] + w[0])       # a white cell after a run of 1 mod 3 is a catch: dropped
        w = n
        out.append(sum(w.values()))
    return out


def kappa():
    """The real root of 4k^3 - 2k^2 - 1 = 0."""
    lo, hi = 0.5, 1.0
    for _ in range(80):
        mid = (lo + hi) / 2
        if 4 * mid ** 3 - 2 * mid ** 2 - 1 > 0:
            hi = mid
        else:
            lo = mid
    return (lo + hi) / 2


def chain(X, out=None):
    n = 1 << X                                            # bit j-1 of a state is wheel j
    v = np.arange(n, dtype=np.uint64)
    full = v << np.uint64(1)                              # bit j is wheel j; wheel 0 is white
    mask = np.uint64((1 << (X + 1)) - 1)
    new = ((full << np.uint64(2)) ^ ((full << np.uint64(1)) | full)) & mask
    new = (new >> np.uint64(1)) & ~np.uint64(1)           # back to bit j-1 for wheel j, wheel 1 cleared
    s0 = new.astype(np.int64)
    s1 = (new | np.uint64(1)).astype(np.int64)
    del full, new
    mu = np.full(n, 1.0 / n)
    for it in range(1, 4000):
        nxt = 0.5 * (np.bincount(s0, weights=mu, minlength=n) + np.bincount(s1, weights=mu, minlength=n))
        diff = float(np.abs(nxt - mu).sum())
        mu = nxt
        if diff < 1e-14:
            break
    # the wheel at which each state's first reset word closes (0: none within X)
    first = np.zeros(n, dtype=np.uint8)
    W = np.ones(n, dtype=bool)
    R1 = np.zeros(n, dtype=bool)
    R2 = np.zeros(n, dtype=bool)
    R0 = np.zeros(n, dtype=bool)
    black = []
    for j in range(1, X + 1):
        c = ((v >> np.uint64(j - 1)) & np.uint64(1)).astype(bool)
        black.append(float(mu[c].sum()))
        hit = R1 & ~c & (first == 0)
        first[hit] = j
        W, R1, R2, R0 = ~c, c & (W | R0), c & R1, c & R2
    q = [float(mu[(first == 0) | (first > x)].sum()) for x in range(1, X + 1)]
    k = kappa()
    print('width %d: %d states; steps to settle: %d (last change %.1e)' % (X, n, it, diff))
    print('kappa, the real root of 4k^3 - 2k^2 - 1 = 0: %.9f; ln 2 / ln(1/kappa) = %.4f' % (k, np.log(2) / -np.log(k)))
    fair = coin(X)
    print('wheel  chance black   q(x): no reset word by wheel x   q(x)/q(x-1)   the same for fair coins   q(x)/kappa^x')
    for x in range(1, X + 1):
        print('%5d  %12.6f   %30.9f   %11.6f   %23.9f   %12.6f' % (x, black[x - 1], q[x - 1],
              q[x - 1] / q[x - 2] if x > 1 else q[0], fair[x - 1], q[x - 1] / k ** x))
    if out:
        json.dump({'X': X, 'q': q, 'black': black, 'kappa': k, 'steps': it}, open(out, 'w'))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['chain']:
        chain(int(a[1]), a[2] if len(a) > 2 else None)
    elif a[:1] == ['coin']:
        q = coin(int(a[1]))
        k = kappa()
        for x in (10, 20, 40, 80, int(a[1])):
            print('fair coins: q(%d) = %.6e, q(x)/q(x-1) = %.9f, q(x)/kappa^x = %.6f' % (x, q[x - 1], q[x - 1] / q[x - 2], q[x - 1] / k ** x))
        print('kappa = %.9f' % k)
    else:
        sys.exit(__doc__)
