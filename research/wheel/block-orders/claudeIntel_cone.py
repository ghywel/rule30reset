# claudeIntel, N19: CNF of "some right half beside the alternating wall (white first) reads this gate word", on the whole light cone or on its first W columns.
# With W columns, column W+1 is free at every tick, so UNSAT there implies UNSAT on the cone.   usage: cone.py ORDER NAME [W]
# ORDER is a word in A, B (A = 3555, B = 355555), e.g. B*16 ; the word ends with the closing kick and 1001 of the next block is not asked.
import sys
def order(s):
    out = ''; i = 0
    while i < len(s):
        c = s[i]; i += 1; k = 1
        if i < len(s) and s[i] == '*':
            j = i+1
            while j < len(s) and s[j].isdigit(): j += 1
            k = int(s[i+1:j]); i = j
        out += c*k
    return out
o = order(sys.argv[1]); w = []
for c in o:
    for g in [3]+[5]*(3 if c == 'A' else 5): w += [1]+[0]*(g-1)
w += [1]; n = len(w); T = 2*(n-1); W = int(sys.argv[3]) if len(sys.argv) > 3 else 10**9
ids = {}; nv = 0
def v(p, t):
    global nv
    if (p, t) not in ids: nv += 1; ids[p, t] = nv
    return ids[p, t]
cl = []
for t in range(T):
    for p in range(1, min(W, T-t)+1):
        N, C, R = v(p, t+1), v(p, t), v(p+1, t)
        if p == 1:
            if t % 2 == 0: cl += [[N, -C], [N, -R], [-N, C, R]]
            else: cl += [[-N, -C], [-N, -R], [N, C, R]]
        else:
            L = v(p-1, t); cl += [[L, N, -C], [L, N, -R], [L, -N, C, R], [-L, -N, -C], [-L, -N, -R], [-L, N, C, R]]
for s, b in enumerate(w): cl.append([v(1, 2*s) if b else -v(1, 2*s)])
with open(sys.argv[2], 'w', newline='\n') as f:
    f.write('p cnf %d %d\n' % (nv, len(cl)))
    for c in cl: f.write(' '.join(map(str, c))+' 0\n')
print(o, 'readings', n, 'ticks', T, 'vars', nv, 'clauses', len(cl))
