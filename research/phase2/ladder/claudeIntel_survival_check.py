"""Checks for claudeIntel_survival.cpp (K92.2, ledger N38).

1. Brute force: every y < 4^n run forward under the kit's F(y) = (y >> 1) ^ (y | (y << 1)); those black at every
   pinned tick below 2n are counted by the number of pinned ticks from 2n on that read black before the first white.
2. I283's free-cube counts (n = 20..24, both pin phases at width 2n) and K84's exhaustive latest deaths D(W),
   W = 26..64 (even pins), against the table.

usage: python -I claudeIntel_survival_check.py TABLE PIN [BRUTE_N]
"""
import sys

def F(y):
    return (y >> 1) ^ (y | (y << 1))

def brute(n, pin, cap=200):
    L = {}
    for y in range(1 << (2 * n)):
        x, t, ok = y, 0, True
        while t < 2 * n:
            if t % 2 == pin and not (x & 1):
                ok = False
                break
            x, t = F(x), t + 1
        if not ok:
            continue
        k = 0
        while k < cap:
            if t % 2 == pin:
                if not (x & 1):
                    break
                k += 1
            x, t = F(x), t + 1
        L[k] = L.get(k, 0) + 1
    return L

def read(path):
    rows = {}
    for line in open(path, encoding='utf-8'):
        if line.startswith('#'):
            continue
        f = line.split()
        rows[int(f[0])] = (int(f[1]), [int(x) for x in f[3:]])
    return rows

def A(row, k):
    return sum(row[1][k:])

I283 = {0: {20: (524338, 263368, 242), 21: (1047587, 523727, 530), 22: (2096556, 1047631, 1401),
            23: (4182361, 2101409, 1968), 24: (8392278, 4198552, 3517)},
        1: {24: (8413212, 4206564, 4007)}}
K84_D = dict(zip(range(26, 66, 2), [44, 48, 52, 66, 66, 66, 72, 76, 78, 78, 86, 86, 92, 96, 96, 100, 110, 114, 114, 116]))

def main():
    rows = read(sys.argv[1])
    pin = int(sys.argv[2])
    bn = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    for n, row in rows.items():
        assert sum(row[1]) == 2 ** n, ('free cube size', n)
        assert row[0] == len(row[1]) - 1, ('k_max', n)
    print('sizes and k_max consistent at every n')
    for n in range(1, bn + 1):
        L = brute(n, pin)
        got = {k: c for k, c in enumerate(rows[n][1]) if c}
        assert got == L, ('brute', n, got, L)
    if bn:
        print('brute force agrees for n = 1 ..', bn)
    for n, (a1, a2, a12) in I283[pin].items():
        if n in rows:
            assert (A(rows[n], 1), A(rows[n], 2), A(rows[n], 12)) == (a1, a2, a12), ('I283', n)
            print('I283 n=%d pass one, two, twelve: %d %d %d agree' % (n, a1, a2, a12))
    if pin == 0:
        for W, D in K84_D.items():
            n = W // 2
            if n in rows:
                # the latest first white pinned tick over y < 4^n: tick 2n + 2 k_max
                dmax = max(2 * m + 2 * rows[m][0] for m in rows if m <= n)
                assert dmax == D, ('K84', W, dmax, D)
        print('K84 latest deaths D(W) agree for W =', ', '.join(str(W) for W in K84_D if W // 2 in rows))

if __name__ == '__main__':
    main()
