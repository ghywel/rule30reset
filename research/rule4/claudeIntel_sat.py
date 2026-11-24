"""S12's fork, by my own CNF (claudeIntel).  Wall black at even ticks; gate sample s = site 1 at tick 2s+1; site i of the prefix = bit i-1."""
import subprocess, sys, os, json
CAD = sys.argv[1]

class CNF:
    def __init__(s): s.n = 0; s.c = []
    def new(s): s.n += 1; return s.n
    def add(s, *l): s.c.append(l)

def cone(prefix, width, S):
    """variables for all rows needed to read sample S; returns cnf, list of gate literals for samples 0..S"""
    f = CNF(); T = 2 * S + 1; W = T + 1
    one = f.new(); f.add(one)
    row = []
    for i in range(W):
        if i < width: row.append(one if (prefix >> i) & 1 else -one)
        else: row.append(f.new())
    gates = []
    cache = {}
    for t in range(T + 1):
        wall = 1 - (t & 1)
        if not wall: gates.append(row[0])
        if t == T: break
        new = []
        for i in range(len(row) - 1):
            l = (one if wall else -one) if i == 0 else row[i - 1]; c, r = row[i], row[i + 1]
            # o = c or r
            if c == one or r == one: o = one
            elif c == -one: o = r
            elif r == -one: o = c
            else:
                o = f.new(); f.add(-c, o); f.add(-r, o); f.add(c, r, -o)
            # x = l xor o
            if l == one: x = -o
            elif l == -one: x = o
            elif o == one: x = -l
            elif o == -one: x = l
            else:
                x = f.new(); f.add(-l, -o, -x); f.add(l, o, -x); f.add(l, -o, x); f.add(-l, o, x)
            new.append(x)
        row = new
    return f, gates

def solve(f, extra, name):
    with open(name, 'w') as h:
        h.write('p cnf %d %d\n' % (f.n, len(f.c) + len(extra)))
        for cl in f.c + extra: h.write(' '.join(map(str, cl)) + ' 0\n')
    p = subprocess.run([CAD, '-q', name], capture_output=True, text=True)
    return {10: 'SAT', 20: 'UNSAT'}.get(p.returncode, 'code %d' % p.returncode)

def gate_word(row_int, N, extra=0):
    W = 2 * N + 4
    row = [(row_int >> i) & 1 for i in range(W)]; out = []
    for t in range(2 * N):
        wall = 1 - (t & 1)
        if not wall: out.append(row[0])
        row = [(wall if i == 0 else row[i - 1]) ^ (row[i] | row[i + 1]) for i in range(len(row) - 1)]
    return out

p28 = 157190921
seven, twin = gate_word(p28, 400), gate_word(150212610825, 400)
print('twin low 28 bits equal:', 150212610825 & (2 ** 28 - 1) == p28, 'site 29 of twin:', (150212610825 >> 28) & 1)
print('first difference of the two words at sample', next(i for i in range(400) if seven[i] != twin[i]), 'seven', seven[48], 'twin', twin[48])
print('seven word is 0000101 repeated from sample 0 (400 samples):', seven == [int(c) for c in ('0000101' * 60)[:400]])
f, g = cone(p28, 28, 47)
print('28-bit prefix, some reading 0..47 differs from the seven word:', solve(f, [[-g[s] if seven[s] else g[s] for s in range(48)]], 'a.cnf'), 'vars', f.n)
f, g = cone(p28, 28, 48)
print('sample 48 black possible:', solve(f, [[g[48]]], 'b.cnf'), ' white possible:', solve(f, [[-g[48]]], 'c.cnf'))
p35 = p28 | (87 << 28)
print('35-bit prefix integer matches:', p35 == 23511075593)
f, g = cone(p35, 35, 48)
print('35-bit prefix, sample 48 black:', solve(f, [[g[48]]], 'd.cnf'))
# minimality: every six-cell extension keeps the seven word; witnesses from the packet, checked by direct evolution
w = json.load(open('pk/escape/lock-certified.json'))
ok = 0; codes = set()
for k, v in w.items():
    row = int(v[0], 16) if isinstance(v[0], str) else v[0]
    e = (row >> 28) & 63
    assert row & (2 ** 28 - 1) == p28
    codes.add(e)
    gw = gate_word(row, 700)
    ok += gw == [int(c) for c in ('0000101' * 101)[:700]]
print('witnesses', len(w), 'distinct six-cell extensions', len(codes), 'spell 0000101 for 700 samples:', ok, 'latest entry listed', max(v[1] for v in w.values()))
# the fork's 5/8
c = 0
for e in range(8):
    f, g = cone(p28 | (e << 28), 31, 120)
    r = solve(f, [[-g[s] if seven[s % 7 + 0] else g[s] for s in range(121)]], 'e.cnf')
    print('three-cell extension', e, 'some reading 0..120 off the seven word:', r); c += r == 'UNSAT'
print('forced by three cells up to sample 120:', c, 'of 8')
