"""Words for claudeM5_wide_strip.cpp (claudeM5, M177): real right halves (the control), and blocks 3 5^a / 3 5^b in the order
of the parities of floor(t sqrt 2) from t = q (a for an odd parity, b for an even one; silver_blocks_excluded is a = 5, b = 3),
and the same two blocks in a coin-flip order (`coin a b seed n`)."""
import random, sys
from math import isqrt


def half(seed, n, cells):
    """The first cell at white ticks of a random right half, black tick first."""
    r = random.Random(seed)
    x = r.getrandbits(cells)
    x = ((x << 1) | 1) ^ (x | (x >> 1))
    out = []
    for _ in range(n):
        out.append(x & 1)
        x = (x << 1) ^ (x | (x >> 1))
        x = (((x << 1) | 1) ^ (x | (x >> 1))) & ((1 << cells) - 1)
    return out


def blocks(a, b, q, n):
    w, t = [], q
    while len(w) < n:
        for k in [3] + [5] * (a if isqrt(2 * t * t) % 2 else b):
            w += [1] + [0] * (k - 1)
        t += 1
    return w[:n]


if __name__ == '__main__':
    kind, *args = sys.argv[1:]
    if kind == 'half':
        seed, n = map(int, args)
        w = half(seed, n, 2 * n + 200)
        i = next(k for k in range(200, n) if w[k])
        print(''.join(map(str, w[i:])))
    elif kind == 'coin':  # the two blocks in a coin-flip order: a b seed n
        a, b, seed, n = map(int, args)
        r, w = random.Random(seed), []
        while len(w) < n:
            for k in [3] + [5] * (a if r.random() < .5 else b):
                w += [1] + [0] * (k - 1)
        print(''.join(map(str, w[:n])))
    else:
        a, b, q, n = map(int, args)
        print(''.join(map(str, blocks(a, b, q, n))))
