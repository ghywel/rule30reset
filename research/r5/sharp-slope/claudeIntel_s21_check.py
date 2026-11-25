# claudeIntel, N18: independent check of S21, R5 sharp slope. Written from the kit's definitions; shares no code with gptIntel_ether_bad.py.
# usage: claudeIntel_s21_check.py LEANFILE [NMAX]      LEANFILE holds trap001 and trap011
import re, sys
src = open(sys.argv[1], encoding='utf-8').read(); NMAX = int(sys.argv[2]) if len(sys.argv) > 2 else 60
def trap(name):
    m = re.search(r'def %s : List Nat := \[(.*?)\]' % name, src, re.S); return set(int(x) for x in re.findall(r'\d+', m.group(1)))
TAB = ["001","001","011","110","010","010","110","101","100","100","101","011"]   # kit's ether3Table
eth3 = lambda j, f: int(TAB[j % 12][f % 3])
for j in range(12):                                                                  # ether3_rule_small
    for f in range(3): assert eth3(j, f+1) == eth3(j+11, f) ^ (eth3(j, f) | eth3(j+1, f))
W = {'001': [0,0,1], '011': [0,1,1]}
T = {k: trap('trap'+k) for k in W}
print({k: len(v) for k, v in T.items()})
def step(row, wall_now):           # row[p], p >= 1 black cells as int with bit p-1 = cell p; returns the next row
    left = (row << 1) | wall_now; right = row >> 1
    return left ^ (row | right)
def inv(row):                       # finite predecessor by the sweep x(p) = y(p+1) xor (x(p+1) or x(p+2)), for p >= 1
    B = row.bit_length(); x = [0]*(B+4)
    for p in range(B-1, 0, -1): x[p] = ((row >> p) & 1) ^ (x[p+1] | x[p+2])
    return sum(b << (p-1) for p, b in enumerate(x) if p >= 1 and b)
def front(row, j, s, t, lim):
    for p in range(1, lim):
        if ((row >> (p-1)) & 1) != eth3(j+p, t+s): return p
CASES = {'001': dict(j=0, s=0, d=22, gate=1, code=9278, off=26, margin=95), '011': dict(j=11, s=2, d=27, gate=0, code=1992, off=31, margin=110)}
for w, c in CASES.items():
    j, s, d = c['j'], c['s'], c['d']
    assert all(eth3(j, t) == W[w][t % 3] for t in range(6))                          # the wall is ether column j
    worst = 10**9
    for n in range(NMAX+1):
        row = sum(eth3(j+p, n+s) << (p-1) for p in range(1, d+8*n)) | (1 << (d+8*n)) | (1 << (d+8*n+3))      # ether to d+8n-1, then 01001
        for k in range(n): row = inv(row)
        assert row.bit_length() <= 7*n + c['off'], (w, n, row.bit_length())
        sup = row.bit_length(); last = None
        for t in range(21*n+2+3*sup+400):
            f = front(row, j, s, t, row.bit_length()+40)
            if t <= n: assert f == d+8*t and ((row >> f) & 1) != eth3(j+f+1, t+s) and (j+f+4*(t+s)) % 12 == 10, (w, n, t, f)
            if t >= n+1 and (t-n-1) % 10 == 0 and t <= 21*n+1: assert f == d+8*n+2-4*((t-n-1)//10), (w, n, t, f)
            if (t+s) % 3 == c['gate']:
                inside = (row & 0x3fff) in T[w]
                if not inside: last = t
                if t == 21*n+1: assert not inside and (row & 0x3fff) == c['code'], (w, n, row & 0x3fff)
            elif t == 21*n+1: raise AssertionError('not a gate tick')
            row = step(row, W[w][(t+s) % 3])
            if t > 21*n+200 and last is not None and t > last+60: break
        worst = min(worst, 3*(7*n+c['off'])-last)
        if n in (0, 1, 10, 40, NMAX): print(w, 'n', n, 'support', sup, 'outside at', 21*n+1, 'last outside', last, '3D - last =', 3*sup-last)
    print(w, 'all n to', NMAX, 'pass')
# the local inverse, all four eastern pairs
word = [0,0,1,0,0,1,1,1,1,0,1]
for a in (0,1):
    for b in (0,1):
        x = [a, b]                                  # x[d+9], x[d+10] -> sweep west over output cells d+9 .. d-1
        v = (a, b); hist = []
        for o in reversed(word): v = (o ^ (v[0] | v[1]), v[0]); hist.append(v)
        assert v == (1,1) and hist[8] == (0,1), (a, b, v, hist)
print('inverse word: 11 at d-2,d-1 and 01 at d,d+1 for all four pairs')
