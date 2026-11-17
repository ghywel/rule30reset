"""How deep does one free bit's influence reach in the constrained start Theta(f)?

R_s(f) = the largest depth d <= 41 at which flipping free bit f_s changes Theta_d(f). f_s first enters at depth
2s + 2, linearly, so R_s >= 2s + 2. Truth tables come from theta_anf.json (Moebius transform is its own inverse).
Also: healing contexts, i.e. patterns of f1..fk after which f0 never reaches past a fixed depth for any later bits.
"""
import sys, json, base64
import numpy as np
d = json.load(open(sys.argv[1])); N = d['N']; M = 1 << N; D = 2 * N + 1
def mobius(a, nv):
    a = a.copy()
    for s in range(nv):
        a = a.reshape(-1, 2, 1 << s); a[:, 1, :] ^= a[:, 0, :]; a = a.reshape(-1)
    return a
idx = np.arange(M, dtype=np.int64)
T = []
for r in d['depths']:
    nv = r['nvars']
    a = np.unpackbits(np.frombuffer(base64.b64decode(r['bits']), np.uint8), bitorder='little')[: 1 << nv].astype(np.uint8)
    T.append(mobius(a, nv)[idx & ((1 << nv) - 1)])
# sanity: Theta_(2s+2) changes whenever f_s flips; Theta_(2s+1) never depends on f_s
for s in range(6):
    assert np.all(T[2 * s + 1] ^ T[2 * s + 1][idx ^ (1 << s)])
    assert not np.any(T[2 * s] ^ T[2 * s][idx ^ (1 << s)])
R = {}
for s in range(6):
    r = np.zeros(M, np.int16)
    for dd in range(1, D + 1):
        r[(T[dd - 1] ^ T[dd - 1][idx ^ (1 << s)]) == 1] = dd
    R[s] = r
print('P(R_s - 2s >= k): the tail of the reach beyond where f_s enters (censored at depth %d)' % D)
for s in range(6):
    x = R[s] - 2 * s; top = D - 2 * s
    print('  s=%d ' % s + ' '.join('%5.3f' % (x >= k).mean() for k in range(2, min(top, 34) + 1, 2)))
print('  k:  ' + ' '.join('%5d' % k for k in range(2, 35, 2)))
r0 = R[0]
print('\nhealing contexts for f0: patterns of f1..fk (f1 first) after which R_0 never exceeds a bound, minimal ones only')
found = []
for k in range(1, 9):
    for p in range(1 << k):
        if any((p & ((1 << j) - 1)) == q for j, q in found if j <= k):
            continue
        sel = ((idx >> 1) & ((1 << k) - 1)) == p
        mx = int(r0[sel].max())
        if mx < D:
            found.append((k, p))
            frac = sel.mean()
            print('  f1..f%d = %s : f0 reaches at most depth %2d   (share of words %.4f)' % (k, ''.join(str((p >> j) & 1) for j in range(k)), mx, frac))
cover = np.zeros(M, bool)
for k, p in found:
    cover |= ((idx >> 1) & ((1 << k) - 1)) == p
print('share of all free words in some healing context (k <= 8): %.4f' % cover.mean())
print('share of words where f0 still reaches depth 41: %.4f' % (r0 >= D).mean())
