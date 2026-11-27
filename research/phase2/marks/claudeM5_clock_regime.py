"""K92.4, claudeM5: which of the seed's marks does the left edge's clock decide?

A gap at age s has l white cells at sites -l..-1 and a black cell at -l-1. It is a mark when the centre is black at
age s + l. That centre is a function of the row at age s on [-l, l], and the west half is white, so it is a function
of the right context: sites 0..l.

The kit's arrival_eq_diagonal (Lowry), read at the gap's own age: if the context is the seed's left-edge word of some
age k, that is (D 0 k, ..., D l k) with D j t = cell t (j - t), then the centre at age s + l is D l (k + l). Classes:
  E  the context is an edge word of some age k;
  C  and D l is settled (period 16) by tick k + l, so the arrival is a function of l and k mod 16;
  S  and the whole word is settled: it is one of the 16 periodic edge words of length l + 1.
For every E age the program also checks the theorem: the arrival seen is D l (k + l).

Input: the windows file of claudeM5_seed_windows.c (two little-endian words per age: west, east).
Usage: python3 -I claudeM5_clock_regime.py WINDOWS N [OUT.json]
"""
import json, sys
import numpy as np

J = 64
M64 = (1 << 64) - 1

def edge(T):
    A, h = 1, []
    for _ in range(T + 1):
        h.append(A)
        A = ((A << 2) ^ ((A << 1) | A)) & M64
    return h

def main():
    path, N = sys.argv[1], int(sys.argv[2])
    d = np.fromfile(path, dtype='<u8').reshape(-1, 2)
    assert len(d) >= N + 65
    west, east = d[:, 0], d[:, 1]
    centre = (east & np.uint64(1)).astype(np.uint8)
    T = 1024
    h = edge(T)
    assert h[T - 16] == h[T]
    F = [0] * J; left = M64
    for t in range(T - 16, -1, -1):
        new = (h[t] ^ h[t + 16]) & left
        while new:
            b = new & -new; F[b.bit_length() - 1] = t + 1; new ^= b; left ^= b
    P = [max(F[:j + 1]) for j in range(J)]
    LMAX = 40
    # for each l: context word -> (least k, some k with k + l >= F(l), some k >= P(l), arrival)
    table = []
    for l in range(LMAX + 1):
        mask = (1 << (l + 1)) - 1; tb = {}
        for k in range(P[l] + 16):
            w = h[k] & mask; arr = (h[k + l] >> l) & 1
            if w in tb:
                assert tb[w][3] == arr, 'one context, two arrivals'
                tb[w] = (tb[w][0], tb[w][1] or k + l >= F[l], tb[w][2] or k >= P[l], arr)
            else:
                tb[w] = (k, k + l >= F[l], k >= P[l], arr)
        table.append(tb)
    words = [len(tb) for tb in table]
    rows = {l: dict(ages=0, marks=0, E=0, Em=0, C=0, Cm=0, S=0, Sm=0) for l in range(65)}
    bad = 0; wide = []; best = dict(E=(0, 0), C=(0, 0), S=(0, 0)); recs = []; rec = -1; widest_gap = (0, 0)
    wl, el = west.tolist(), east.tolist(); cl = centre.tolist()
    for s in range(1, N + 1):
        l = 64 - wl[s].bit_length()
        assert l < 64
        r = rows[l]; r['ages'] += 1
        if l > widest_gap[0]: widest_gap = (l, s)
        m = cl[s + l]
        if m:
            r['marks'] += 1
            if l > rec: rec = l; recs.append((s, l))
        if l <= LMAX:
            hit = table[l].get(el[s] & ((1 << (l + 1)) - 1))
            if hit:
                k, c, st, arr = hit
                if arr != m: bad += 1
                r['E'] += 1; r['Em'] += m
                if m and l > best['E'][0]: best['E'] = (l, s)
                if c:
                    r['C'] += 1; r['Cm'] += m
                    if m and l > best['C'][0]: best['C'] = (l, s)
                if st:
                    r['S'] += 1; r['Sm'] += m
                    if m and l > best['S'][0]: best['S'] = (l, s)
        if m and l >= 14:
            # how far the context follows any edge word: the longest agreement from site 0
            e = el[s]; agree = 0
            for k in range(P[min(l, J - 1)] + 16):
                x = (e ^ h[k]) & ((1 << (l + 1)) - 1)
                a = l + 1 if x == 0 else (x & -x).bit_length() - 1
                agree = max(agree, a)
            first = (e & -e).bit_length() - 1 if e else -1
            wide.append((s, l, agree, first))
    total = sum(r['marks'] for r in rows.values())
    print(f'ages 1..{N}: marked {total}; strict mark records {recs}')
    print('widest gap', widest_gap, '; widest marks', sorted(wide, key=lambda t: -t[1])[:4])
    print('theorem control: arrivals that differ from D l (k + l):', bad)
    print('F(l) for l = 0..40:', F[:41])
    print(' l  ages     marks    | edge words | E ages   E marks | C ages   C marks | S ages  S marks')
    for l in range(0, 33):
        r = rows[l]
        if r['ages']:
            print(f"{l:2d} {r['ages']:8d} {r['marks']:8d} | {words[l]:6d}     | {r['E']:8d} {r['Em']:7d} | {r['C']:8d} {r['Cm']:7d} | {r['S']:7d} {r['Sm']:6d}")
    print('widest mark in each class (width, age):', best)
    print('marks of width >= 14:', len(wide), '; their agreement with an edge word (cells from the centre):',
          sorted(set(a for _, _, a, _ in wide)), '; largest', max((a, l, s) for s, l, a, _ in wide) if wide else None)
    if len(sys.argv) > 3:
        json.dump({'N': N, 'marked': total, 'records': recs, 'widestGap': widest_gap, 'control': bad, 'F': F,
                   'rows': {str(l): r for l, r in rows.items() if r['ages']}, 'edgeWords': words, 'best': best,
                   'wide': wide}, open(sys.argv[3], 'w'), indent=1)

if __name__ == '__main__':
    main()
