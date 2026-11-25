# independent check, plain dictionaries and the truth table 00011110 (rule 30): no shared code with age23.py
RULE = {(1,1,1):0,(1,1,0):0,(1,0,1):0,(1,0,0):1,(0,1,1):1,(0,1,0):1,(0,0,1):1,(0,0,0):0}
def check(seed, T):
    N = 200
    x = {p: 0 for p in range(-N-60, N+60)}
    for i, c in enumerate(seed): x[i] = int(c)
    lo, hi = -N-60, N+60-1
    for t in range(T):
        x = {p: RULE[(x[p-1], x[p], x[p+1])] for p in range(lo+1+t, hi-t)}
    R = x
    z = {}; z[N] = 1; z[N+1] = 1
    for p in range(N, -N, -1):                         # z(p-1) xor (z(p) or z(p+1)) = R(p)
        z[p-1] = R[p] ^ (z[p] | z[p+1])
    res = []
    for tail in ((1,0),(0,1),(0,0)):
        y = {N-1: tail[0], N: tail[1]}
        for p in range(N-1, -N+1, -1): y[p-1] = z[p] ^ (y[p] | y[p+1])
        # forward checks
        ok1 = all(RULE[(y[p-1], y[p], y[p+1])] == z[p] for p in range(-N+2, N-1))
        ok2 = all(RULE[(z[p-1], z[p], z[p+1])] == R[p] for p in range(-N+2, N-1))
        left = [y[p] for p in range(-N+1, -T-5)]
        ze = min(p for p in z if z[p]); 
        res.append((tail, ok1, ok2, 'left tail all black' if all(left) else 'left tail white' if not any(left) else 'mixed', ze))
        if all(left):
            lo2 = min(p for p in range(-N+1, N-1) if not y[p]); 
            # right period 3 from where
            q = N-4
            while y[q] == y[q+3]: q -= 1
            print('   y: first white cell (from the left)', lo2, '; period three to the right from', q+1, '; z leftmost black', ze, '; z black from', max(p for p in range(-N, N) if not z[p])+1)
            print('   y cells %d..%d: %s' % (lo2-2, q+6, ''.join(str(y[p]) for p in range(lo2-2, q+7))))
            print('   z cells %d..: %s' % (ze, ''.join(str(z[p]) for p in range(ze, max(p for p in range(-N, N) if not z[p])+3))))
    return res
print(check('1001', 7) and 'ok')
for s in ('100110110011101',):
    for T in (23, 24): print(T, s, check(s, T))
