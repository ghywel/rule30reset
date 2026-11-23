"""claudeM5's independent test of S11's per-scale claim on the words themselves (M125).

No lattice, no strip and none of gptM5's code: the word is evaluated directly, its mismatches with each lagged copy are
listed, and the best agreement interval is measured.

Word: bit t = floor(theta + t*(sqrt5 - 1)) mod 2. Lags at scale n: A*b - B*a over the six base pairs, (9+4*sqrt5)^n =
A + B*sqrt5. Claim (golden_repeats_at_scale): for every real theta and n >= 3 some lag has an agreement interval
[a, b], a >= 0, with 10000*(b - 2a - q) >= 999*q - 30000.

Generic phases: theta/2 is a 64-bit fixed-point fraction of a turn; t steps accumulate an error below 1e-12 of a turn.
Cut-orbit phases theta = m + k*(sqrt5 - 1) are evaluated exactly with integer square roots.
"""
import sys
from math import isqrt

import numpy as np

BASE = [(-3, 1), (-4, 2), (-7, 3), (-11, 5), (-18, 8), (-29, 13)]
# the turn alpha = (sqrt5 - 1)/2 as a 64-bit fraction, rounded
ALPHA = (isqrt(5 << 128) - (1 << 64) + 1) >> 1


def lags(n):
    a, b = 1, 0
    for _ in range(n):
        a, b = 9 * a + 20 * b, 4 * a + 9 * b
    return [a * y - b * x for x, y in BASE]


def generic_word(x0, length):
    t = np.arange(length, dtype=np.uint64)
    return ((np.uint64(x0) + t * np.uint64(ALPHA)) >> np.uint64(63)).astype(np.int8)


def cut_word(m, k, length):
    """Exact bits of floor(m + (t+k)(sqrt5-1)) mod 2."""
    out = np.empty(length, dtype=np.int8)
    for t in range(length):
        s = t + k
        fl = isqrt(5 * s * s) if s >= 0 else -isqrt(5 * s * s) - 1
        out[t] = (m - s + fl) & 1
    return out


def best(word, q, span):
    """Best excess b - 2a - q over agreement intervals that end before span."""
    w = word[:span + q]
    mism = np.flatnonzero(w[:span] != w[q:span + q])
    top = None
    prev = -1
    for r in mism[:64]:
        ex = (int(r) - 1) - 2 * (prev + 1) - q
        if int(r) - 1 >= prev + 1 and (top is None or ex > top):
            top = ex
        prev = int(r)
        if prev > 3 * q:
            break
    return top


def check(word, ls):
    """Largest (excess, lag) ratio and whether the claim holds."""
    ratio, ok = -9.0, False
    for q in ls:
        ex = best(word, q, 5 * q)
        if ex is None:
            continue
        ratio = max(ratio, ex / q)
        ok |= 10000 * ex >= 999 * q - 30000
    return ratio, ok


def main(samples, seed):
    for n in (3,):
        ls = lags(n)
        print('scale', n, 'lags', ls)
        need = 6 * max(ls)
        rng = np.random.default_rng(seed)
        worst = (9.0, None)
        bad = 0
        phases = [int(v) for v in rng.integers(0, 2**63, samples, dtype=np.uint64) * 2 + 1]
        for x0 in phases:
            r, ok = check(generic_word(x0, need), ls)
            bad += not ok
            if r < worst[0]:
                worst = (r, x0)
        print(f'generic phases {samples}: failures {bad}, least best ratio {worst[0]:.5f}')
        # refine round the worst phases: step down through shrinking neighbourhoods
        x0, width = worst[1], 2**50
        for _ in range(40):
            cand = [(x0 + int(d)) % 2**64 for d in rng.integers(-width, width, 8)]
            for c in cand:
                r, ok = check(generic_word(c, need), ls)
                bad += not ok
                if r < worst[0]:
                    worst = (r, c); x0 = c
            width = max(width // 2, 2**36)
        print(f'after local search: failures {bad}, least best ratio {worst[0]:.5f}')
        cut_bad, cut_worst = 0, 9.0
        for m in (0, 1):
            for k in (-40, -13, -5, -1, 0, 1, 2, 7, 21, 34):
                r, ok = check(cut_word(m, k, need), ls)
                cut_bad += not ok
                cut_worst = min(cut_worst, r)
        print(f'exact cut-orbit phases 20: failures {cut_bad}, least best ratio {cut_worst:.5f}')
    ls = lags(3)
    w = cut_word(0, 0, 60000)
    q = ls[1]
    first = int(np.flatnonzero(w[:40000] != w[q:40000 + q])[0])
    print('phase zero, second lag:', (q, first, first - 1 - q))


if __name__ == '__main__':
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 400, 2026)
