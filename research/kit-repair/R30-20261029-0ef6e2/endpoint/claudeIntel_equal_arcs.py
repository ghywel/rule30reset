"""Phase-zero word floor(t*beta) mod m, exact floors. For each lag q the largest excess b - 2a - q of an agreement run [a, b].
Near-squares of slack K at unbounded lags need excess >= -K-1 for infinitely many q."""
import sys, numpy as np
from fractions import Fraction as F

def cf(digits):
    x = F(digits[-1])
    for a in reversed(digits[:-1]):
        x = a + 1 / x
    return x

def word(beta, m, n):
    p, q = beta.numerator, beta.denominator
    return np.array([(t * p // q) % m for t in range(n)], dtype=np.int8)

def best(w, q, amin):
    n = len(w) - q
    neq = np.flatnonzero(w[amin:n] != w[amin + q:n + q]) + amin
    starts = np.concatenate(([amin], neq + 1))
    ends = np.concatenate((neq - 1, [n - 1]))
    ok = ends >= starts
    s, e = starts[ok], ends[ok]
    ex = e - 2 * s - q
    # the last run is cut by the window: drop it
    if len(ex) == 0:
        return -10**9, 0, 0
    if len(ex) > 1:
        ex, s, e = ex[:-1], s[:-1], e[:-1]
    i = int(np.argmax(ex))
    return int(ex[i]), int(s[i]), int(e[i])

def scan(name, digits, m, qmax=1500, amin=1):
    beta = cf(digits + [10 ** 12])
    w = word(beta, m, 8 * qmax)
    res = []
    for q in range(1, qmax):
        ex, a, b = best(w, q, amin)
        res.append((q, ex, a, b))
    # best ratio per dyadic block
    out = []
    lo = 32
    while lo < qmax:
        blk = [r for r in res if lo <= r[0] < 2 * lo]
        r = max(blk, key=lambda r: r[1] / r[0])
        out.append('%d:%+d' % (r[0], r[1]))
        lo *= 2
    print('m=%d %-34s %s' % (m, name, ' '.join(out)))
    sys.stdout.flush()

if __name__ == '__main__':
    P = 40
    for m in (3, 4, 5, 6):
        for name, d in [('golden [1;1..]', [1] * P), ('silver [1;2..]', [1] + [2] * P), ('[2;3,3,..]', [2] + [3] * P), ('[0;3,3..]', [0] + [3] * P),
                        ('[2;6,6,..]', [2] + [6] * P), ('[1;4,4..]', [1] + [4] * P), ('[0;1,2,1,2..]', [0] + [1, 2] * 20), ('[1;2,1,2,1]', [1] + [2, 1] * 20)]:
            scan(name, d, m, qmax=1100)
