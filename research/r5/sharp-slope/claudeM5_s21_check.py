# S21, a third replay (claudeM5, M186): the two families, both constant gates beside 011 in every phase, and the ether-tail family.
# Written from the local rule and the kit's 12x3 table only. Rows are Python integers, bit p = cell p.
ETH = [[0,0,1],[0,0,1],[0,1,1],[1,1,0],[0,1,0],[0,1,0],[1,1,0],[1,0,1],[1,0,0],[1,0,0],[1,0,1],[0,1,1]]
eth = lambda j, s, p, t: ETH[(j + p) % 12][(t + s) % 3]
def invert(y, B, tail):            # x(p) = y(p+1) xor (x(p+1) or x(p+2)) below B, x = tail from B on
    x = {B: tail(B), B + 1: tail(B + 1)}
    for p in range(B - 1, 0, -1): x[p] = y(p + 1) ^ (x[p + 1] | x[p + 2])
    return x
def seed(j, s, d, n, tail):        # tail(k, p): the tail's row k ticks after the start
    E = d + 8 * n
    word = [0, 1, 0, 0, 1]
    row = {p: eth(j, s, p, n) for p in range(1, E)}
    row.update({E + i: w for i, w in enumerate(word)}); B = E + 4
    get = lambda p, row=row, B=B, k=n: row[p] if p <= B else tail(k, p)
    for k in range(n, 0, -1):
        x = invert(get, B, lambda p, k=k: tail(k - 1, p)); B -= 1
        get = lambda p, x=x, B=B, k=k: x[p] if p <= B else tail(k - 1, p)
    return get, B
def evolve(get, width, wall, T):
    row = sum(get(p) << p for p in range(1, width + 1))
    for t in range(T + 1):
        row = (row & ~1) | wall(t)
        yield t, row
        row = (row << 1) ^ (row | (row >> 1))
white = lambda k, p: 0
bad = 0
for (w, j, s, d, code, g) in (((0,0,1), 0, 0, 22, 9278, 1), ((0,1,1), 11, 2, 27, 1992, 0)):
    assert all(eth(j, s, 0, t) == w[(t + s) % 3] for t in range(3))
    for n in range(0, 31):
        get, B = seed(j, s, d, n, white)
        assert B == d + 7 * n + 4, (B, d, n)
        for t, row in evolve(get, B, lambda t: eth(j, s, 0, t), 21 * n + 1):
            front = next(p for p in range(1, 10**6) if (row >> p & 1) != eth(j, s, p, t))
            if t <= n and front != d + 8 * t: bad += 1
            if t == n + 1 and front != d + 8 * n + 2: bad += 1
        if (row >> 1) & 16383 != code: bad += 1
print('families 001 and 011, n to 30: failures', bad)
bad = 0; last = []
for b, j in ((1, 2), (0, 11)):
    for phi in range(3):
        d = next(x for x in range(2, 15) if (j + x + 4 * phi) % 12 == 10)
        for n in range(0, 21):
            get, B = seed(j, phi, d, n, white)
            if B > 7 * n + 17: bad += 1
            for t, row in evolve(get, B, lambda t: (0, 1, 1)[(t + phi) % 3], 21 * n + 5 + 120):
                if (t + phi) % 3 == 0 and (row >> 1 & 1) != b:
                    if t <= 21 * n + 5: bad += 1
                    last.append(t - 21 * n); break
            else: last.append(None)
print('constant gates beside 011, six cases, n to 20: failures', bad, '; first other colour after 21n by', min(last), 'to', max(last), 'ticks')
bad = 0
for j in range(12):
    for s in range(3):
        d = next(x for x in range(2, 15) if (j + x + 4 * s) % 12 == 10)
        for n in (0, 1, 2, 5, 9):
            get, B = seed(j, s, d, n, lambda k, p: eth(j, s, p, k))
            T = 21 * n + 5; W = B + 2 * T + 8              # the far edge cannot reach the checked prefix: use a wide window
            row = sum(get(p) << p for p in range(1, W + 1))
            for t in range(T + 1):
                row = (row & ~1) | eth(j, s, 0, t)
                if any((row >> p & 1) != eth(j, s, p, t) for p in range(1, d)): bad += 1
                row = ((row << 1) ^ (row | (row >> 1))) & ((1 << W) - 1)
print('ether tails, 12 columns, 3 phases, n in 0,1,2,5,9: failures', bad)
