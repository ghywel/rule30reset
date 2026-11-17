"""Theta_d(f) as a Boolean polynomial in the free bits (kit Rule30ZeroBoundary: Theta f = lam (alt f)).

Column -1 (depth 1) of the constrained history reads alt f: black at even ticks, f_s at tick 2s+1.
The wall (depth 0) is white. Sideways reconstruction, from zrow's rule
    cell(k, t+1) = cell(k+1, t) xor (cell(k, t) or cell(k-1, t)):
    d_(k+1)(t) = d_k(t+1) xor (d_k(t) or d_(k-1)(t)),  Theta_d = d_d(0).
Every truth table runs over all 2^N free words at once (index bit s = f_s).
Checks: the start is replayed forward with F(Y) = (Y>>1) xor (Y or (Y<<1)) on 4096 words.
"""
import sys, json, hashlib, base64
import numpy as np

N = int(sys.argv[2]) if len(sys.argv) > 2 else 20
D = 2 * N + 1                     # depths 1..D are determined by f_0..f_(N-1)
M = 1 << N
idx = np.arange(M, dtype=np.uint32)
fbit = [((idx >> s) & 1).astype(bool) for s in range(N)]
T = D                             # depth-1 ticks 0..D-1 determine depths 1..D
col1 = [np.ones(M, bool) if t % 2 == 0 else fbit[t // 2] for t in range(T)]   # ticks 0..D-1
prev = [np.zeros(M, bool) for _ in range(T)]       # depth 0, the wall
cur = col1                                          # depth 1
theta = [cur[0].copy()]
for k in range(1, D):
    nxt = [cur[t + 1] ^ (cur[t] | prev[t]) for t in range(len(cur) - 1)]
    prev, cur = cur, nxt
    theta.append(cur[0].copy())
assert len(theta) == D

# forward replay check on a sample of free words
F = lambda y: (y >> 1) ^ (y | (y << 1))
rng = np.random.default_rng(30)
for f in rng.integers(0, M, 4096).tolist():
    y = sum(int(theta[d][f]) << d for d in range(D))
    z = y
    for t in range(D):
        want = 1 if t % 2 == 0 else (f >> (t // 2)) & 1
        assert z & 1 == want, (f, t)
        z = F(z)

pc = np.array([bin(i).count('1') for i in range(1 << 10)], dtype=np.int8)
popc = pc[idx & 1023] + pc[(idx >> 10) & 1023] + (pc[(idx >> 20) & 1023] if N > 20 else 0)

def anf(tt):
    a = tt.astype(np.uint8).copy()
    for s in range(N):
        a = a.reshape(-1, 2, 1 << s)
        a[:, 1, :] ^= a[:, 0, :]
        a = a.reshape(-1)
    return a

out = []
for d in range(1, D + 1):
    a = anf(theta[d - 1])
    mons = np.nonzero(a)[0]
    nv = d // 2                                    # variables f_0..f_(nv-1) can occur
    deg = int(popc[mons].max()) if len(mons) else -1
    assert len(mons) == 0 or int(mons.max()) < (1 << nv), d
    bydeg = np.bincount(popc[mons], minlength=nv + 1).tolist() if len(mons) else []
    occ = [int(((mons >> s) & 1).sum()) for s in range(nv)]
    rec = {'d': d, 'nvars': nv, 'deg': deg, 'nmon': int(len(mons)), 'bydeg': bydeg, 'occ': occ,
           'weight': int(theta[d - 1].sum())}
    rec['bits'] = base64.b64encode(np.packbits(a[: 1 << nv], bitorder='little').tobytes()).decode()
    out.append(rec)
    print('depth %2d vars %2d degree %2d monomials %7d of %7d  ones %d/%d' % (d, nv, deg, len(mons), 1 << nv,
          rec['weight'], M))
txt = json.dumps({'N': N, 'depths': out}, separators=(',', ':'))
open(sys.argv[1], 'w').write(txt)
print('wrote', sys.argv[1], len(txt), 'sha256', hashlib.sha256(txt.encode()).hexdigest())
