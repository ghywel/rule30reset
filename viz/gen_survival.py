"""Exact data for the survival pictures of the zero-boundary left half.

Kit objects (lean/Ruliology/CellularAutomata/Rule30ZeroBoundary.lean, IntegerForm):
  F(Y) = (Y >> 1) xor (Y or (Y << 1))   one rule 30 step beside a white wall; bit i of Y = cell at depth i+1
  G = F o F                              Q01 <=> every natural Y reaches an even number under some G^s (Q01_iff_integer)
sigma(Y) = least s >= 0 with G^s(Y) even: the number of double steps a finite row keeps depth 1 black.

Outputs one JSON file (path given as argv[1]) with:
  carpet   : sigma(Y) for Y < 2^20, uint8, base64 (row-major, Y = 1024*row + col)
  hist     : counts of sigma over Y < 2^NB
  surv     : surv[w][k] = #{Y < 2^w : sigma(Y) >= k}
  champ    : per width w (bit length), max sigma and up to 8 Y attaining it
  rows     : full space-time rows F^t(Y), t = 0..2*sigma+2, as hex, for selected starts
Exact: 128-bit two-word arithmetic; G^s(Y) is exact while its width <= 128 and bit 0 stays exact
for 63 further double steps after that (each truncated step corrupts the top 2 bits only).
"""
import sys, json, base64, hashlib
import numpy as np

NB = 24          # all Y < 2^NB
CHUNK = 1 << 21
CAP = 116        # sigma is exact below this (see docstring); larger values are reported as CAP
U = np.uint64

def F2(lo, hi):
    srl = (lo >> U(1)) | (hi << U(63)); srh = hi >> U(1)
    sll = lo << U(1);                   slh = (hi << U(1)) | (lo >> U(63))
    return srl ^ (lo | sll), srh ^ (hi | slh)

def sigma_chunk(start, n):
    Y = np.arange(start, start + n, dtype=np.uint64)
    sig = np.zeros(n, dtype=np.int32)
    idx = np.nonzero(Y & U(1))[0]
    lo = Y[idx].copy(); hi = np.zeros(len(idx), dtype=np.uint64)
    s = 0
    while len(idx) and s < CAP:
        lo, hi = F2(*F2(lo, hi)); s += 1
        alive = (lo & U(1)) == U(1)
        dead = idx[~alive]; sig[dead] = s
        idx, lo, hi = idx[alive], lo[alive], hi[alive]
    sig[idx] = CAP
    return sig

def F(y): return (y >> 1) ^ (y | (y << 1))
def sigma_int(y, cap=10000):
    s = 0
    while y & 1 and s < cap:
        y = F(F(y)); s += 1
    return s

def rows_of(y, extra=2):
    s = sigma_int(y); T = 2 * s + extra; out = []; z = y
    for t in range(T + 1):
        out.append(format(z, 'x')); z = F(z)
    return {'y': format(y, 'x'), 'w': y.bit_length(), 'pop': bin(y).count('1'), 'sigma': s, 'rows': out}

def main(path):
    hist = np.zeros(CAP + 1, dtype=np.int64)
    widths = NB
    surv = np.zeros((widths + 1, CAP + 2), dtype=np.int64)
    champ = {}
    carpet = None
    for start in range(0, 1 << NB, CHUNK):
        sig = sigma_chunk(start, CHUNK)
        if start == 0:
            carpet = np.minimum(sig[: 1 << 20], 255).astype(np.uint8)
        hist += np.bincount(sig, minlength=CAP + 1)[: CAP + 1]
        Y = np.arange(start, start + CHUNK, dtype=np.int64)
        bl = np.zeros(CHUNK, dtype=np.int64); bl[Y > 0] = np.floor(np.log2(Y[Y > 0])).astype(np.int64) + 1
        for w in range(widths + 1):
            m = bl == w
            if not m.any(): continue
            sw = sig[m]
            c = np.bincount(sw, minlength=CAP + 2)
            surv[w] += c[::-1].cumsum()[::-1][: CAP + 2] if len(c) <= CAP + 2 else c[: CAP + 2]
            mx = int(sw.max()); ys = Y[m][sw == mx][:8].tolist()
            old = champ.get(w)
            if old is None or mx > old['sigma']: champ[w] = {'sigma': mx, 'ys': ys}
            elif mx == old['sigma']: old['ys'] = (old['ys'] + ys)[:8]
    # surv[w][k] counted per exact width; make it cumulative over widths (Y < 2^w)
    survc = surv.cumsum(axis=0)
    # sanity: integer recomputation of every champion
    for w, c in champ.items():
        for y in c['ys']:
            assert sigma_int(y) == c['sigma'], (w, y)
    # spot-check 2000 random Y against the integer map
    rng = np.random.default_rng(30)
    for y in rng.integers(0, 1 << 20, 2000).tolist():
        assert sigma_int(y) == int(carpet[y]), y
    sel = []
    for w in range(4, NB + 1):
        sel.append(rows_of(champ[w]['ys'][0]))
    sys.path.insert(0, sys.argv[2]) if len(sys.argv) > 2 else None
    # The mass-table constants use the kit's Rule30ZeroCoastBridge encoding (depth-1 white at tick 0, Q01Gap
    # language), not this file's; sigma is 0 for them here. They are kept only so the cited data hash reproduces.
    extra = {}
    try:
        import local_q01gap_mass_table as MT
        extra = {'YSTAR': MT.YSTAR, 'C37ROOT0': MT.C37ROOTS[0]}
    except Exception as e:
        print('no mass-table constants:', e)
    for name, y in extra.items():
        r = rows_of(y); r['name'] = name; sel.append(r)
    data = {
        'NB': NB, 'CAP': CAP,
        'carpet': base64.b64encode(carpet.tobytes()).decode(),
        'hist': hist.tolist(),
        'surv': {w: survc[w][: 40].tolist() for w in range(4, NB + 1)},
        'champ': {w: champ[w] for w in sorted(champ)},
        'rows': sel,
    }
    txt = json.dumps(data, separators=(',', ':'))
    open(path, 'w').write(txt)
    print('wrote', path, len(txt), 'bytes sha256', hashlib.sha256(txt.encode()).hexdigest())
    print('hist (sigma: count) first 30:', [(k, int(v)) for k, v in enumerate(hist[:30]) if v])
    print('max sigma below 2^%d:' % NB, max(c['sigma'] for c in champ.values()))
    print('champions w: sigma, first y')
    for w in sorted(champ):
        print(' ', w, champ[w]['sigma'], champ[w]['ys'][:3])
    for r in sel[-len(extra):] if extra else []:
        print(' ', r.get('name'), 'width', r['w'], 'pop', r['pop'], 'sigma', r['sigma'])

if __name__ == '__main__':
    main(sys.argv[1])
