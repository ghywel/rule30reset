#!/usr/bin/env python3
"""M6 first test: the least seed density of eternal rows with periodic traces, and the window law.

Frame (the kit's integer form, Rule30ZeroBoundary.IntegerForm): F Y = (Y >> 1) ^ (Y | (Y << 1)); bit i of Y is
depth i + 1 beside the white wall; the trace at time t is bit 0 of F^t Y.
- G words (Rule30PeriodTwoMass.gstep): white at t = 0, black at odd t, and at even t >= 2 not white twice running.
- The gap language (Rule30ZeroCoastBridge.accept): white at t = 0, black at odd t, and the white even times 6 or 10
  ticks apart (3 or 5 double steps), so a periodic gap word is a cyclic sequence of blocks 011111 and 0111111111.

Eternal rows. Every infinite trace has exactly one 2-adic seed (seedOfTrace, ZeroCoastBridge section 10). For a trace
that is a prefix of L ticks and then a cycle of period Q, read sideways: z(t, k + 1) = z(t + 1, k) xor (z(t, k) or
z(t, k - 1)), z(t, 0) = 0. Every column is then periodic after time L with period Q, the pair of columns (k - 1, k)
ranges over a finite set and is eventually periodic in k, and so is the seed: bit k - 1 of the seed is z(0, k). Its
density is exact (ones over one cycle of depths). The prefix matters: seed density is not invariant under F.

Window law (test 3). For every G word of length H, every zero run of seed bits lying inside [c1, H - 1 - m] is at
most 6 long. Enumerated exactly by depth-first search over all G words, the seed built bit by bit from the trace by
the antidiagonal recurrence A_T[k + 1] = A_T[k] xor (A_(T-1)[k] or A_(T-2)[k - 1]), where A_T[k] = z(T - k + 1, k).

Usage: m6_floors.py OUTDIR [--g-max-a 10] [--g-max-q 12] [--gap-max-pre 20] [--gap-max-n 40] [--window-H 64]
       [--cap 400000]
"""
import argparse, json, multiprocessing, os, sys, time
from fractions import Fraction


def F(Y):
    return (Y >> 1) ^ (Y | (Y << 1))


def trace(Y, H):
    out = []
    for _ in range(H):
        out.append(Y & 1)
        Y = F(Y)
    return out


def eternal_density(word, cap, L=0):
    """Seed of the trace word[:L] (word[L:])^infinity: a prefix of L ticks, then a cycle. Columns are stored on the
    times 0 .. len(word) - 1, the last L.. part repeating. Returns dict with exact density, depth preperiod and
    period, and the seed's first 64 bits, or None if no cycle of depth states is found within cap steps (UNKNOWN,
    never a negative). Seed density is not invariant under F, so prefixes matter (smoke test, ledger M14)."""
    Q = len(word)
    col1 = sum(1 << t for t, b in enumerate(word) if b)

    def rot(c):  # bit t of rot(c) is c at time t + 1; time len(word) is time L again
        return (c >> 1) | (((c >> L) & 1) << (Q - 1))

    def f(s):
        a, b = s
        return (b, rot(b) ^ (b | a))

    x0 = (0, col1)
    power = lam = 1
    tort, hare = x0, f(x0)
    steps = 1
    while tort != hare:
        if power == lam:
            tort, power, lam = hare, power * 2, 0
        hare = f(hare)
        lam += 1
        steps += 1
        if steps > cap:
            return None
    tort = hare = x0
    for _ in range(lam):
        hare = f(hare)
    mu = 0
    while tort != hare:
        tort, hare = f(tort), f(hare)
        mu += 1
    ones, s = 0, tort
    for _ in range(lam):
        ones += s[1] & 1
        s = f(s)
    seed, s = 0, x0
    for k in range(64):  # state k holds column k + 1 in its second slot: seed bit k
        seed |= (s[1] & 1) << k
        s = f(s)
    return {'density': Fraction(ones, lam), 'pre': mu, 'per': lam, 'seed64': seed}


def g_words(a_max, q_max):
    """All eventually periodic G traces: even bits = a prefix of a bits (a <= a_max, first bit 0) then a cycle of q
    bits (1 <= q <= q_max), with no two consecutive zeros anywhere, the junction and the wrap included. Odd bits are
    black. Yields (word, L) with L = 2a ticks of prefix."""
    pre = [[]]
    for a in range(1, a_max + 1):
        for m in range(1 << (a - 1)):
            p = [0] + [(m >> j) & 1 for j in range(a - 1)]
            if not any(p[j] == 0 and p[j + 1] == 0 for j in range(a - 1)):
                pre.append(p)
    cyc = []
    for q in range(1, q_max + 1):
        for m in range(1 << q):
            c = [(m >> j) & 1 for j in range(q)]
            if not any(c[j] == 0 and c[(j + 1) % q] == 0 for j in range(q)):
                cyc.append(c)
    for p in pre:
        for c in cyc:
            e = p + c
            if not p and c[0] != 0:
                continue              # time 0 must be white
            if p and p[-1] == 0 and c[0] == 0:
                continue
            w = []
            for x in e:
                w += [x, 1]
            yield w, 2 * len(p)


def _dens(job):
    w, L, cap = job
    return eternal_density(w, cap, L)


def densities(jobs, procs):
    with multiprocessing.Pool(procs) as pool:
        return pool.map(_dens, jobs, chunksize=64)


def gap_words(n_max):
    """All periodic gap words: sequences of gaps 3 and 5 (double steps) with total n <= n_max."""
    out = []

    def rec(seq, n):
        if seq:
            out.append(list(seq))
        for g in (3, 5):
            if n + g <= n_max:
                seq.append(g)
                rec(seq, n + g)
                seq.pop()
    rec([], 0)
    return out


def gap_to_trace(gaps):
    w = []
    for g in gaps:
        w += [0, 1] + [1, 1] * (g - 1)
    return w


def self_test():
    import random
    rnd = random.Random(1)
    # 1. the antidiagonal recurrence rebuilds the seed from its trace
    for _ in range(200):
        H = rnd.randint(1, 80)
        y = rnd.getrandbits(H)
        tr = trace(y, H)
        A1 = A2 = 0
        rebuilt = 0
        for T in range(H):
            A = extend(A1, A2, T, tr[T])
            rebuilt |= ((A >> T) & 1) << T
            A1, A2 = A, A1
        assert rebuilt == y, (H, y)
    # 2. eternal_density's seed has the prescribed trace (prefix, then cycle)
    for _ in range(100):
        L = rnd.randint(0, 10)
        q = rnd.randint(1, 8)
        w = [rnd.getrandbits(1) for _ in range(L + q)]
        r = eternal_density(w, 10 ** 6, L)
        if r is None:
            continue
        want = (w[:L] + w[L:] * 64)[:60]
        assert trace(r['seed64'], 60) == want, (w, L)
    # 3. control: the ether row 2538/127 (one black in seven; R30-20261109-4dce4d) is G-valid for 300 ticks
    y = (2538 * pow(127, -1, 1 << 400)) % (1 << 400)
    assert g_ok(trace(y, 390)) == 390
    return True


def g_ok(b):
    if b[0] != 0:
        return 0
    for t in range(1, len(b)):
        if t % 2 == 1 and b[t] != 1:
            return t
        if t % 2 == 0 and b[t] == 0 and b[t - 2] == 0:
            return t
    return len(b)


def extend(A1, A2, T, b):
    """Antidiagonal T from antidiagonals T - 1 (A1) and T - 2 (A2) and the new trace bit b. Bit k - 1 of the result
    is z(T - k + 1, k) for k = 1 .. T + 1; bit T is seed bit T."""
    if T == 0:
        return b
    C = (A1 | (A2 << 1)) & ((1 << T) - 1)
    P, sh = C, 1
    while sh < T:
        P ^= P << sh
        sh <<= 1
    P &= (1 << T) - 1
    return ((((1 << (T + 1)) - 1) if b else 0) ^ (P << 1))


def window_search(H, c1, margins):
    """Every G word of length H: the longest zero run of seed bits inside [c1, H - 1 - m], for each margin m."""
    best = {m: (-1, None) for m in margins}
    upto = [0] * H     # longest bulk zero run within [c1, i] on the current path
    bits = [0] * H
    leaves = 0

    def rec(T, A1, A2, cur, prev_even_white, trace_bits):
        nonlocal leaves
        if T == H:
            leaves += 1
            for m in margins:
                i = H - 1 - m
                if i >= c1 and upto[i] > best[m][0]:
                    best[m] = (upto[i], sum(bits[j] << j for j in range(H)), list(trace_bits))
            return
        if T == 0:
            choices = (0,)
        elif T % 2 == 1:
            choices = (1,)
        else:
            choices = (1,) if prev_even_white else (0, 1)
        for b in choices:
            A = extend(A1, A2, T, b)
            sb = (A >> T) & 1
            bits[T] = sb
            c = (cur + 1) if (sb == 0 and T >= c1) else 0
            upto[T] = max(upto[T - 1] if T else 0, c)
            trace_bits.append(b)
            rec(T + 1, A, A1, c, (b == 0) if T % 2 == 0 else prev_even_white, trace_bits)
            trace_bits.pop()
    rec(0, 0, 0, 0, False, [])
    return leaves, best


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outdir')
    ap.add_argument('--g-max-q', type=int, default=12)
    ap.add_argument('--g-max-a', type=int, default=10)
    ap.add_argument('--gap-max-n', type=int, default=40)
    ap.add_argument('--gap-max-pre', type=int, default=20)
    ap.add_argument('--window-H', type=int, default=64)
    ap.add_argument('--cap', type=int, default=400000)
    ap.add_argument('--procs', type=int, default=max(1, (os.cpu_count() or 2) - 2))
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    t0 = time.time()
    assert self_test()
    print('self-test passed')
    res = {}

    ether = (2538 * pow(127, -1, 1 << 64)) % (1 << 64)   # the kit's sharp ether row, density 1/7

    # Test 1: eventually periodic G traces, prefix <= 2 * g_max_a ticks, cycle <= 2 * g_max_q ticks
    rows = []
    gj = list(g_words(a.g_max_a, a.g_max_q))
    for (w, L), r in zip(gj, densities([(w, L, a.cap) for w, L in gj], a.procs)):
        rows.append({'q': (len(w) - L) // 2, 'L': L, 'word': ''.join(map(str, w)),
                     'density': None if r is None else str(r['density']),
                     'd': None if r is None else float(r['density']),
                     'pre': None if r is None else r['pre'], 'per': None if r is None else r['per'],
                     'is_ether': None if r is None else r['seed64'] == ether})
    known = [r for r in rows if r['d'] is not None]
    for lim in (12, a.g_max_q):
        sub = [r for r in known if r['q'] <= lim]
        m = min(sub, key=lambda r: r['d'])
        res[f'test1_G_q<={lim}'] = {'traces': sum(1 for r in rows if r['q'] <= lim),
                                    'unknown': sum(1 for r in rows if r['q'] <= lim and r['d'] is None),
                                    'min_density': m['density'], 'argmin': m,
                                    'at_min': sum(1 for r in sub if r['d'] == m['d']),
                                    'ether_among_min': any(r['is_ether'] for r in sub if r['d'] == m['d'])}
    res['test1_lowest10'] = sorted(known, key=lambda r: r['d'])[:10]

    # Test 2: eventually periodic gap traces: a prefix of gaps (total <= gap_max_pre) then a cycle (total <= gap_max_n)
    rows2 = []
    prefixes = [[]] + gap_words(a.gap_max_pre)
    pj = [(p, cyc) for cyc in gap_words(a.gap_max_n) for p in prefixes]
    dj = densities([(gap_to_trace(p) + gap_to_trace(cyc), 2 * sum(p), a.cap) for p, cyc in pj], a.procs)
    for (p, cyc), r in zip(pj, dj):
        rows2.append({'gaps': ''.join(map(str, p)) + '|' + ''.join(map(str, cyc)), 'n': sum(cyc),
                      'density': None if r is None else str(r['density']),
                      'd': None if r is None else float(r['density']),
                      'pre': None if r is None else r['pre'], 'per': None if r is None else r['per']})
    known2 = [r for r in rows2 if r['d'] is not None]
    m2 = min(known2, key=lambda r: r['d'])
    res['test2_gap'] = {'words': len(rows2), 'unknown': sum(1 for r in rows2 if r['d'] is None),
                        'min_density': m2['density'], 'min_float': m2['d'], 'argmin': m2,
                        'lowest10': sorted(known2, key=lambda r: r['d'])[:10]}

    # Test 3: the window law over all G words of length H
    margins = [0, 2, 4, 6, 8, 10, 12, 16]
    leaves, best = window_search(a.window_H, 8, margins)
    res['test3_window'] = {'H': a.window_H, 'c1': 8, 'G_words': leaves,
                           'longest_bulk_zero_run_by_margin': {m: best[m][0] for m in margins},
                           'witness_by_margin': {m: {'seed': best[m][1], 'trace': ''.join(map(str, best[m][2]))}
                                                 for m in margins if best[m][1] is not None}}
    res['seconds'] = round(time.time() - t0, 1)
    with open(os.path.join(a.outdir, 'm6_results.json'), 'w') as fh:
        json.dump(res, fh, indent=1, default=str)
    with open(os.path.join(a.outdir, 'm6_rows.json'), 'w') as fh:
        json.dump({'G': rows, 'gap': rows2}, fh)
    print(json.dumps({k: v for k, v in res.items() if k not in ('test1_lowest10',)}, indent=1, default=str)[:6000])


if __name__ == '__main__':
    main()
