# claudeIntel, N19: can a strip of W columns beside the alternating wall read a block word and return to itself after Q copies (cylinder), or just read K copies (open)?
# Column 0 alternates (white at even ticks), column 1 at white ticks is the gate word, column W+1 is free at every tick.
# usage: cyl.py GAPS W Q [open] [seconds]
import sys, subprocess, os, time
gaps = [int(c) for c in sys.argv[1]]; W = int(sys.argv[2]); Q = int(sys.argv[3]); opn = 'open' in sys.argv[4:]; sec = next((a for a in sys.argv[4:] if a.isdigit()), '300')
P = 2*sum(gaps); T = P*Q; word = []
for _ in range(Q):
    for g in gaps: word += [1]+[0]*(g-1)
cad = os.environ.get('CADICAL', 'cadical')
rows = T+1 if opn else T
var = lambda p, t: ((t if opn else t % T))*(W+1)+p          # p = 1..W+1
cl = []
def rule(n, l, c, r):                                        # n = l xor (c or r); literals, l may be a constant
    for L in ((l, True),) if l in (True, False) else (None,): pass
    if l is True or l is False:
        s = -1 if l else 1                                   # n = l xor o : if l true then n = not o
        cl.append([s*n, -c] if not l else [-n, -c]); cl.append([s*n, -r] if not l else [-n, -r])
        cl.append([-n, c, r] if not l else [n, c, r])
    else:
        for lv in (1, -1):                                   # lv = 1: case l true -> n = not o ; clause literal -l
            a = -l if lv == 1 else l; nn = -n if lv == 1 else n
            cl.append([a, nn, -c]); cl.append([a, nn, -r]); cl.append([a, -nn, c, r])
for t in range(T):
    for p in range(1, W+1):
        l = (t % 2 == 1) if p == 1 else var(p-1, t)
        rule(var(p, t+1), l, var(p, t), var(p+1, t))
for s, b in enumerate(word): cl.append([var(1, 2*s) if b else -var(1, 2*s)])
if opn: cl.append([var(1, T)])
nv = rows*(W+1)+W+1
name = 'c_%s_%d_%d_%s.cnf' % (sys.argv[1], W, Q, 'o' if opn else 'c')
with open(name, 'w', newline='\n') as f:
    f.write('p cnf %d %d\n' % (nv, len(cl))); f.write(''.join(' '.join(map(str, c))+' 0\n' for c in cl))
t0 = time.time()
try: r = subprocess.run([cad, '-q', name], capture_output=True, text=True, timeout=float(sec))
except subprocess.TimeoutExpired:
    print(sys.argv[1], 'W', W, 'copies', Q, 'open' if opn else 'cylinder', 'TIMEOUT', sec, flush=True); sys.exit()
st = {10: 'SAT', 20: 'UNSAT'}.get(r.returncode, 'UNKNOWN')
if st == 'SAT':
    m = set(int(x) for l in r.stdout.splitlines() if l.startswith('v') for x in l.split()[1:])
    val = lambda p, t: 1 if var(p, t) in m else 0
    for t in range(T):
        for p in range(1, W+1):
            l = (t % 2) if p == 1 else val(p-1, t)
            assert val(p, t+1) == l ^ (val(p, t) | val(p+1, t))
    assert all(val(1, 2*s) == b for s, b in enumerate(word)); st += ' (replayed)'
if st == 'UNKNOWN': print(r.returncode, r.stderr[:300], r.stdout[:200])
print(sys.argv[1], 'W', W, 'copies', Q, 'open' if opn else 'cylinder', st, '%.1f s' % (time.time()-t0), flush=True); os.remove(name)
