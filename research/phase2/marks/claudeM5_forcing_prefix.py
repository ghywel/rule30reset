"""K92.4, claudeM5: how much of an edge word must the right context share before the arrival is forced?

A gap of width l at age s is white on [-l, -1]. The centre at age s + l is a function of the context, sites 0..l.
Let the first r cells of the context be the first r cells of the seed's left-edge word of age k, (D 0 k, ..., D (r-1) k),
and leave the other l + 1 - r cells free. The arrival is forced when it is the same for every choice of the free
cells; then it is D l (k + l). rmin(l, k) is the least such r. Exact: each cell is a truth table over the free cells.
Usage: python3 -I claudeM5_forcing_prefix.py LMAX UMAX OUT.json
"""
import json, sys

M64 = (1 << 64) - 1

def edge(T):
    A, h = 1, []
    for _ in range(T + 1):
        h.append(A); A = ((A << 2) ^ ((A << 1) | A)) & M64
    return h

def arrival(l, word, r):
    """Truth table of the centre after l ticks; cells r..l of the context are free. Returns (table, ONE)."""
    u = l + 1 - r
    size = 1 << u
    ONE = (1 << size) - 1
    def var(i):
        block = (1 << (1 << i)) - 1                       # 2^i ones
        period = 1 << (i + 1)
        pat = 0
        for start in range(0, size, period): pat |= block << (start + (1 << i))
        return pat
    row = [0] * l + [ONE if (word >> x) & 1 else 0 for x in range(r)] + [var(i) for i in range(u)]
    for _ in range(l):
        row = [row[i - 1] ^ (row[i] | row[i + 1]) for i in range(1, len(row) - 1)]
    assert len(row) == 1
    return row[0], ONE

def forced(l, word, r):
    v, ONE = arrival(l, word, r)
    return v == 0 or v == ONE

def main():
    LMAX, UMAX, out = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
    T = 1024; h = edge(T)
    F = [0] * 64; left = M64
    for t in range(T - 16, -1, -1):
        new = (h[t] ^ h[t + 16]) & left
        while new:
            b = new & -new; F[b.bit_length() - 1] = t + 1; new ^= b; left ^= b
    P = [max(F[:j + 1]) for j in range(64)]
    res = {}
    for l in range(1, LMAX + 1):
        mask = (1 << (l + 1)) - 1; row = {}
        for k in range(P[l] + 16):
            w = h[k] & mask
            lo_r = max(0, l + 1 - UMAX)                   # cannot test fewer known cells than this
            # forced at r = l + 1 trivially; forcing is monotone in r, so bisect for the least r
            a, b = lo_r, l + 1
            if forced(l, w, lo_r): b = lo_r
            else:
                while b - a > 1:
                    m = (a + b) // 2
                    if forced(l, w, m): b = m
                    else: a = m
            arr = (h[k + l] >> l) & 1
            if b <= l:
                v, ONE = arrival(l, w, b); assert (v == ONE) == bool(arr), 'forced arrival is not the diagonal'
            row[k] = dict(rmin=b, exact=b > lo_r or lo_r == 0, clock=k + l >= F[l], settled=k >= P[l], arrival=arr)
        res[l] = row
        rs = [v['rmin'] for v in row.values()]; cs = [v['rmin'] for v in row.values() if v['clock']]
        print(f'l {l:2d}: ages k < {P[l] + 16}, rmin least {min(rs)} greatest {max(rs)}; clock-decided: least {min(cs) if cs else None}, mean {sum(cs)/len(cs):.2f}', flush=True)
    json.dump({'F': F, 'P': P, 'UMAX': UMAX, 'rmin': res}, open(out, 'w'))

if __name__ == '__main__':
    main()
