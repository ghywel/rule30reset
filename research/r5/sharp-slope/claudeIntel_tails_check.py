# claudeIntel, N18: the extension's families, checked cell by cell from the kit's ether table.  White tail: constant_gate_011.
# Ether tail: erosion_slope, and the best family found, two defects in the ether (departure at tick 3w exactly for w = 7n + 2).
TAB = ["001","001","011","110","010","010","110","101","100","100","101","011"]
e = lambda j, f: int(TAB[j % 12][f % 3])
W011 = (0, 1, 1)
def back(y, B, tail):                      # one inverse step: x = tail from B on, then the sweep west to site 0
    x = [tail(p) for p in range(len(y))]
    for p in range(B-1, -1, -1): x[p] = y[p+1] ^ (x[p+1] | x[p+2])
    return x
def family(j, s, d, n, N, bg):             # bg(s, p): the tail's rows, one per phase
    y = [e(j+p, n+s) if p < d+8*n else (1 if p in (d+8*n+1, d+8*n+4) else (0 if p <= d+8*n+4 else bg(n, p))) for p in range(N)]
    B = d+8*n+4
    for k in range(n-1, -1, -1):
        y = back(y, B, lambda p, k=k: bg(k, p)); B -= 1
    return y, B
def step(x, wall, east): return [wall] + [x[p-1] ^ (x[p] | x[p+1]) for p in range(1, len(x)-1)] + [east]

for b, j in ((0, 11), (1, 2)):
    for phi in range(3):
        d = 2+(8+11*(j+4*phi)) % 12
        for n in (0, 1, 2, 3, 7, 15, 30):
            N = 60*n+200
            y, B = family(j, phi, d, n, N, lambda k, p: 0)
            assert y[0] == W011[phi % 3] and max(p for p in range(1, N) if y[p]) <= 7*n+17 and all(y[p] == e(j+p, phi) for p in range(d)) and y[d] != e(j+d, phi)
            x = y
            for t in range(21*n+6):
                assert all(x[p] == e(j+p, t+phi) for p in range(d)), (b, phi, n, t)
                if (t+phi) % 3 == 0: assert x[1] == b
                x = step(x, W011[(t+1+phi) % 3], 0)
print('constant_gate_011: both colours, three phases, n to 30: pass')
for j in range(12):
    for s in range(3):
        d = 2+(8+11*(j+4*s)) % 12
        for n in (0, 1, 4, 10):
            N = 60*n+200
            eth = lambda k, p: e(j+p, k+s)
            y, B = family(j, s, d, n, N, eth)
            k, w = d-1, 7*n+5
            assert all(y[p] == e(j+p, s) for p in range(d)) and y[d] != e(j+d, s) and all(y[p] == e(j+p, s) for p in range(k+w+1, N))
            x, dep = y, None
            for t in range(3*w+8):
                if any(x[p] != e(j+p, t+s) for p in range(1, k+1)): dep = t; break
                x = step(x, e(j, t+1+s), e(j+N-1, t+1+s))
            assert dep is not None and 21*n+6 <= dep <= 3*w+6, (j, s, n, dep)
print('erosion_slope: all 36 walls, n = 0, 1, 4, 10: columns 1..k ether through 21n+5, departure by 3w+6: pass')
j, s, d = 0, 0, 10
for n in (0, 1, 5, 20, 40):
    N = 60*n+200
    y = [e(j+p, n+s) ^ (1 if p in (d+8*n, d+8*n+1) else 0) for p in range(N)]; B = d+8*n+1
    for k in range(n-1, -1, -1): y = back(y, B, lambda p, k=k: e(j+p, k+s)); B -= 1
    k, w = d-1, B-(d-1); x, dep = y, None
    for t in range(3*w+8):
        if any(x[p] != e(j+p, t+s) for p in range(1, k+1)): dep = t; break
        x = step(x, e(j, t+1+s), e(j+N-1, t+1+s))
    print('two defects: n', n, 'w', w, 'departure', dep, '3w+6 =', 3*w+6); assert dep == 3*w and w == 7*n+2
