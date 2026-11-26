"""Exact k-tick check at depth two for any k (claudeIntel, N30): 4^k registers packed in uint64 words.

Rule30DrivenLeftDepthTwo reduces the uniform k-tick statements of both classes to depth two at one
age T, and from age 2 the depth-two start with -1 white reaches only rows of the one with -1 black
(age_two_start2), so the rows of the start 1 1 at sites -2, -1 suffice. Exactness is monotone in age,
so the first passing age is the least age. Usage: python -I claudeIntel_k_tick_exact.py K AGE [AGE ...]
"""
import sys, time
import numpy as np

def step(row, w):
    return (row >> 1) ^ (row | (row << 1) | w)

def masks(layers):
    R = 1 << (2 * layers); words = max(1, R // 64)
    regs = np.arange(R, dtype=np.uint64)
    out = []
    for k in range(layers):
        for bit in (2 * k, 2 * k + 1):
            b = ((regs >> np.uint64(bit)) & np.uint64(1)).reshape(words, -1) if R >= 64 else None
            m = np.zeros(words, dtype=np.uint64)
            for r in range(R):
                if (r >> bit) & 1:
                    m[r // 64] |= np.uint64(1) << np.uint64(r % 64)
            out.append(m)
    return out, words, R

def check(rows, width, layers, M, words, R, chunk=40000):
    full = np.uint64(0xFFFFFFFFFFFFFFFF) if R >= 64 else np.uint64((1 << R) - 1)
    bad = 0
    for c0 in range(0, len(rows), chunk):
        part = rows[c0:c0 + chunk]; n = len(part)
        img = np.zeros((n, width), dtype=np.uint64)
        arr = np.array([[ (r >> j) & 1 for j in range(width)] for r in part], dtype=np.uint64)
        img[:] = arr
        cur = [np.broadcast_to(M[2 * k], (n, words)).copy() for k in range(layers)]
        nxt = [np.broadcast_to(M[2 * k + 1], (n, words)).copy() for k in range(layers)]
        deep = {}
        for col in range(width):
            y = (img[:, col] * full)[:, None]
            above = [np.broadcast_to(y, (n, words))] + cur[:-1]
            new = [above[k] ^ (cur[k] | nxt[k]) for k in range(layers)]
            nxt, cur = cur, new
            off = width - (col + 2)
            if off <= layers:
                deep[off] = cur[layers - 1]
        ok = np.all(deep[layers] == full, axis=1)
        for c in range(layers):
            ok &= np.all(deep[c] == 0, axis=1)
        for k in range(layers):
            ok &= np.all(cur[k] == 0, axis=1) & np.all(nxt[k] == 0, axis=1)
        bad += int((~ok).sum())
    return bad

if __name__ == "__main__":
    layers = int(sys.argv[1]); ages = sorted(int(a) for a in sys.argv[2:])
    M, words, R = masks(layers)
    S = {3}; q = 0; t0 = time.time()
    for age in ages:
        while q < age:
            S = {step(r, w) for r in S for w in (0, 1)}; q += 1
        bad = check(sorted(S), age + 2, layers, M, words, R)
        print(f"k={layers} age {age}: {len(S)} rows, {bad} failing rows ({time.time()-t0:.0f}s)", flush=True)
