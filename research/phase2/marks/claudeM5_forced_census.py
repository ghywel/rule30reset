"""K92.4, claudeM5: the seed's gaps whose arrival is forced by a prefix of an edge word.

Class P: at age s the gap has width l, and the right context shares its first rmin(l, k) cells with the seed's
left-edge word of some age k (the table of claudeM5_forcing_prefix.py). Then the centre at age s + l is D l (k + l)
whatever the rest of the context is. Class PC: and k + l >= F(l), so that value is a function of l and k mod 16.
The program checks the forced arrival against the centre actually seen at every such age.
Usage: python3 -I claudeM5_forced_census.py WINDOWS N FORCE.json [OUT.json]
"""
import json, sys
import numpy as np

M64 = (1 << 64) - 1

def main():
    path, N, fj = sys.argv[1], int(sys.argv[2]), json.load(open(sys.argv[3]))
    d = np.fromfile(path, dtype='<u8').reshape(-1, 2)
    wl, el = d[:, 0].tolist(), d[:, 1].tolist()
    A, h = 1, []
    for _ in range(1100):
        h.append(A); A = ((A << 2) ^ ((A << 1) | A)) & M64
    F = fj['F']
    tabs = {}
    for l, row in fj['rmin'].items():
        l = int(l); byr = {}
        for k, v in row.items():
            k = int(k); r = v['rmin']
            if r > l + 1: continue
            key = h[k] & ((1 << r) - 1)
            t = byr.setdefault(r, {})
            old = t.get(key)
            if old: assert old[0] == v['arrival'], 'one forcing prefix, two arrivals'
            t[key] = (v['arrival'], (old[1] if old else False) or v['clock'], min(old[2], k) if old else k)
        tabs[l] = sorted(byr.items())
    LT = max(tabs)
    rows = {}; bad = 0; wide = []; best = {'P': (0, 0), 'PC': (0, 0)}
    for s in range(1, N + 1):
        l = 64 - wl[s].bit_length()
        m = el[s + l] & 1
        r_ = rows.setdefault(l, dict(ages=0, marks=0, P=0, Pm=0, PC=0, PCm=0)); r_['ages'] += 1; r_['marks'] += m
        hit = None
        if 1 <= l <= LT:
            e = el[s]
            for r, t in tabs[l]:
                x = t.get(e & ((1 << r) - 1))
                if x:
                    if hit is None or (x[1] and not hit[1]): hit = (x[0], x[1], x[2], r)
        elif l == 0:
            hit = (el[s] & 1, True, 0, 1) if el[s] & 1 else None      # width zero: the arrival is the centre itself
        if hit:
            if hit[0] != m: bad += 1
            r_['P'] += 1; r_['Pm'] += m
            if m and l > best['P'][0]: best['P'] = (l, s)
            if hit[1]:
                r_['PC'] += 1; r_['PCm'] += m
                if m and l > best['PC'][0]: best['PC'] = (l, s)
        if m and l >= 14: wide.append((s, l, bool(hit), bool(hit and hit[1]), hit[3] if hit else None, hit[2] if hit else None))
    print('forced arrivals that differ from the centre seen:', bad)
    print(' l    ages    marks |  P ages  P marks | PC ages PC marks | share of gaps forced')
    for l in sorted(rows):
        r = rows[l]
        print(f"{l:2d} {r['ages']:8d} {r['marks']:8d} | {r['P']:8d} {r['Pm']:7d} | {r['PC']:8d} {r['PCm']:7d} | {r['P']/r['ages']:.4f}")
    w14 = [w for w in wide]
    print('marks of width >= 14:', len(w14), '; forced by an edge prefix:', sum(w[2] for w in w14), '; with a settled clock:', sum(w[3] for w in w14))
    print('widest forced marks (age, width, prefix cells, edge age):', sorted([(w[1], w[0], w[4], w[5]) for w in w14 if w[2]], reverse=True)[:8])
    print('widest mark in each class (width, age):', best)
    for s in (34429, 2125919):
        print('record at age', s, [w for w in wide if w[0] == s])
    if len(sys.argv) > 4:
        json.dump({'N': N, 'control': bad, 'rows': {str(l): r for l, r in sorted(rows.items())}, 'wide': wide, 'best': best},
                  open(sys.argv[4], 'w'), indent=1)

if __name__ == '__main__':
    main()
