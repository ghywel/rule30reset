"""Near-square excess of rotation codings, against Jen's bound and corollary F (claudeIntel, N6).

For a binary word c, a lag q and a maximal agreement run [a, b] (c(t + q) = c(t) for a <= t <= b, failing at a - 1
or a = 0, and at b + 1), the excess is b - 2a - q.

* Jen's bound, the input of R30-20261029-0ef6e2 (`RepeatBound c q L`), says excess <= L for every q > 0.
* Corollary F (kit PR #395, `Rule30ClockNearSquares.corollary_F`) forbids, for the visible bits of a clocked row
  with a leftmost black cell, any K with excess >= -K - 1 at unbounded lags q (runs starting at a >= T0 / 2).

So for a candidate word, E(q) = max over complete runs of the excess decides which tool can exclude it:
* E(q) unbounded above: Jen alone excludes it;
* E(q) >= -K at unbounded q: corollary F excludes it;
* E(q) -> -infinity: neither does, and only a counting argument like 0ef6e2's can.

The words are codings of the golden rotation alpha = (sqrt 5 - 1) / 2, whose continued-fraction digits are all 1, so
0ef6e2 excludes none of them with any endpoint. The orbit is computed exactly in Z / 2^64 with alpha rounded to
2^-64, so each word is exactly the coding of a dyadic rotation that agrees with alpha's to within N * 2^-64.

One more word, scanned at every lag up to Q_ALL: placego G143's c(s) = floor(s beta) mod 2, beta = 2 - sqrt 2, which
is 1 exactly when {s beta / 2} lies in [1/2, 1). placego GC2179 records that it passes Jen's bound with C = 0
(every excess <= -1). The question here is whether its excess stays >= -K at unbounded lags (corollary F excludes it)
or falls to -infinity (neither tool does).

Usage: python claudeIntel_near_square_probe.py OUTFILE
"""
import sys
import numpy as np

MOD = 1 << 64
ALPHA = (5 ** 0.5 - 1) / 2
A = np.uint64(int(round(ALPHA * MOD)) % MOD)
N = 1_000_000                  # prefix length
SMALL_Q = 1500                 # every lag up to here, for the Jen side
SEED = 20261122
N_SILVER = 400_000             # prefix for the silver word
Q_ALL = 40_000                 # its lags


def orbit(theta: int, n: int) -> np.ndarray:
    s = np.arange(n, dtype=np.uint64)
    with np.errstate(over='ignore'):
        return np.uint64(theta) + s * A        # wraps mod 2^64: exact


def code(x: np.ndarray, intervals) -> np.ndarray:
    """1 on the union of half-open arcs [lo, hi) of Z / 2^64 (lo > hi wraps)."""
    out = np.zeros(x.shape, dtype=bool)
    for lo, hi in intervals:
        lo, hi = np.uint64(lo), np.uint64(hi)
        out |= ((x >= lo) & (x < hi)) if lo <= hi else ((x >= lo) | (x < hi))
    return out


def excess_max(c: np.ndarray, q: int):
    """E(q) over complete runs, and whether a run reaches the end of the prefix."""
    eq = c[q:] == c[:-q]                       # eq[t] = (c(t + q) == c(t)), t < N - q
    n = eq.size
    padded = np.concatenate(([False], eq, [False]))
    d = np.diff(padded.astype(np.int8))
    starts = np.flatnonzero(d == 1)            # run [a, b]: a = start, b = end - 1
    ends = np.flatnonzero(d == -1) - 1
    complete = ends < n - 1
    if not complete.any():
        return None, True
    ex = ends[complete] - 2 * starts[complete] - q
    return int(ex.max()), bool((~complete).any())


def convergents(limit: int):
    q = [1, 2]
    while q[-1] * 1.7 < limit:
        q.append(q[-1] + q[-2])
    return [v for v in q if v >= 3]


def main(path: str) -> None:
    rng = np.random.default_rng(SEED)
    one_minus_alpha = (MOD - int(A)) % MOD
    cases = [('control: characteristic Sturmian (theta = alpha, arc [1 - alpha, 1))',
              int(A), [(one_minus_alpha, 0)])]
    for i in range(20):
        theta, lo, length = (int(v) for v in rng.integers(0, MOD, size=3, dtype=np.uint64))
        cases.append((f'one arc #{i}', theta, [(lo, (lo + length) % MOD)]))
    for i in range(20):
        theta = int(rng.integers(0, MOD, dtype=np.uint64))
        e = sorted(int(v) for v in rng.integers(0, MOD, size=4, dtype=np.uint64))
        cases.append((f'two arcs #{i}', theta, [(e[0], e[1]), (e[2], e[3])]))
    qs = convergents(N // 6)
    lines = [f'alpha = {ALPHA!r}, A = {int(A)}, N = {N}, SMALL_Q = {SMALL_Q}, seed = {SEED}',
             f'convergent lags: {qs}', '']
    for name, theta, arcs in cases:
        c = code(orbit(theta, N), arcs)
        conv = []
        for q in qs:
            e, open_end = excess_max(c, q)
            conv.append('none' if e is None else f'{e}{"+" if open_end else ""}')
        jen = max((excess_max(c, q)[0] for q in range(1, SMALL_Q + 1)), key=lambda v: -10**18 if v is None else v)
        vals = [int(v.rstrip('+')) for v in conv if v != 'none']
        big = [q for q, v in zip(qs, conv) if v != 'none' and q >= 100]
        ge3 = sum(1 for q, v in zip(qs, conv) if v != 'none' and q >= 100 and int(v.rstrip('+')) >= -3)
        lines.append(f'{name}: max E(q), q <= {SMALL_Q}: {jen}; E(q_n) at convergents: {" ".join(conv)}; '
                     f'convergents q_n >= 100 with E >= -3: {ge3} of {len(big)}')
    # placego G143's silver half-circle word, at every lag
    beta_half = (2 - 2 ** 0.5) / 2
    b = np.uint64(int(round(beta_half * MOD)) % MOD)
    s = np.arange(N_SILVER, dtype=np.uint64)
    with np.errstate(over='ignore'):
        xs = s * b
    silver = xs >= np.uint64(1 << 63)
    lines.append('')
    lines.append(f'silver G143 word, first 24 letters: {"".join(str(int(v)) for v in silver[:24])}; '
                 f'N = {N_SILVER}, every lag q <= {Q_ALL}')
    near, top, top_q, counted = [], None, None, 0
    for q in range(1, Q_ALL + 1):
        e, _ = excess_max(silver, q)
        if e is None:
            continue
        counted += 1
        if top is None or e > top:
            top, top_q = e, q
        if e >= -5:
            near.append(f'{q}:{e}')
    lines.append(f'silver: lags with a complete run: {counted}; max E(q) = {top} at q = {top_q}')
    lines.append(f'silver: lags with E(q) >= -5 ({len(near)}): {" ".join(near)}')
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')


if __name__ == '__main__':
    main(sys.argv[1])
