#!/usr/bin/env python3
"""Pull M29 (M39): where do the long coalescence windows sit against the left side's nested structure?

The strips. Rule30FourLeftSides puts every configuration with a leftmost black cell on one of four strips A0, A1, B0, B1
through wheel 87,866 (period 16, rows given in the Lean source); Rule30SeedLeftSide puts the single seed on A0. Phase t
of a strip is rowAt 87867 v t (bit j = wheel j = left diagonal D j), so D j (t + 1) = D (j - 2) t xor (D (j - 1) t or
D j t). Through wheel 87,866 these four strips are every reachable edge cycle.

The reset rule (checked here against the automaton). One inverse layer reads a phase word from the deep end with all
four registers free. They coalesce exactly one cell after the shallow 0 of the first closed black run 0 1^n 0 with
n = 1 (mod 3) whose deep 0 has been read. So from a start s the window length is delta(s) = s - e + 1, where the run
(lo .. hi) is the one with the largest deep 0 a = hi + 1 <= s and e = lo - 2. Consecutive reset runs i, i + 1 bound a
window of length a(i + 1) - e(i), covering wheels e(i) .. a(i + 1) - 1, keyed by its shallow end e(i).

Computed, for each strip and phase, to wheel 87,866:
  A. every reset run and window; the largest window by block of 4,096 wheels and overall, and above each fork;
  B. the i.i.d. comparison: the number of starts with delta >= n on A0 against the exact expectation for fair coin
     flips (the subset automaton), n = 10 .. 100, and the i.i.d. median of the largest window;
  C. the nested structure: each wheel's least period over the 16 phases and the white diagonals; at each white
     diagonal j0 >= 4 and each phase, the distance to the nearest reset word (its cells lo - 1 .. a); the long windows
     (length >= 40) against depth residues mod 2, 4, 8, 16 (chi-square), the fraction of period-16 wheels inside
     them, and the nearest white diagonal;
  D. phase specificity: for each long window in phase tau, delta at its deepest start in every other phase, and the
     phase offsets at which that delta is also >= 30.
Controls: each strip returns after 16 ticks and not after 8; the seed reaches A0 at tick 177,560 with no shift
(seed_on_A0); A0's white diagonals are 2, 7, 28, 399, 53207, 58286 and 87866 (seed_white_black); A0's least periods
begin 1, 1, 1, 2, 1, 2, 2, 1, 4, 1, 4 (Rowland 2006, section 5); the automaton agrees with the run rule at every start
below wheel 4,096 on A0; M38's long windows (65 at 2030, 58 at 3080, 56 at 1305 and 3804, 55 at 3986, 51 at 3385, by
shallow end) appear on A0; and at each white diagonal j0 >= 4, with b = D (j0 - 1) and x = D (j0 + 1), the recurrence
gives D (j0 - 2) = b, D (j0 + 2) = all black, D (j0 + 3) t = not x (t - 1), and so phase t reads 010 on wheels j0 + 1
.. j0 + 3 exactly when x t = 0 and x (t - 1) = 1.
Predictions (written before the run):
  1. Random-like windows (60%): on A0 the counts of starts with delta >= n are within a factor 2 of the i.i.d.
     expectation at n = 20, 30 and 40; the largest window on A0 exceeds 65 and lies within 15 of the i.i.d. median
     maximum. Kill: a deficit by a factor 3 at n = 40, or a largest window <= 65 against an i.i.d. median >= 85.
  2. White diagonals do not force a reset in every phase (55%): some phase at some white diagonal j0 >= 4 has no reset
     word within 12 wheels.
  3. No depth-residue bias (chi-square below the 1% point for mod 2, 4, 8, 16) and no period association (the fraction
     of period-16 wheels in long windows within 0.1 of the fraction over wheels 400 .. 53,207) (60%).
  4. Long windows are phase-specific: the median over long windows of the best other-phase delta at the same start is
     below 25 (60%); offset 8 is the commonest offset with delta >= 30 (50%).
Usage: claudeM5_window_map.py LEANFILE OUTFILE
"""
import argparse, json, re, statistics

K = 87867
M = (1 << K) - 1
CHI1 = {1: 6.635, 3: 11.345, 7: 18.475, 15: 30.578}   # chi-square 1% points by degrees of freedom


def R(v):
    return ((v << 2) ^ ((v << 1) | v)) & M


def load_strips(path):
    src = open(path).read()
    out = {}
    for name in ('A0', 'A1', 'B0', 'B1'):
        m = re.search(r'def %s : Nat := (?:(\w+) \^\^\^ \()?0x([0-9a-fA-F]+)(?: <<< (\d+)\))?' % name, src)
        base, h, sh = m.group(1), int(m.group(2), 16), int(m.group(3) or 0)
        out[name] = h if base is None else out[base] ^ (h << sh)      # A1, B0, B1: a mask shifted to the fork
    return out


def phases(v):
    rows = [v]
    for _ in range(16):
        rows.append(R(rows[-1]))
    return rows


def word(r):
    return bin(r)[2:].zfill(K)[::-1]                    # word[j] = wheel j


def resets(s):
    """Reset runs of the phase word s: (lo, a, e) with ones on lo .. a - 1, zeros at lo - 1 and a, e = lo - 2 >= 0."""
    out = []
    for m in re.finditer('1+', s):
        lo, a = m.start(), m.end()
        if lo >= 2 and a < len(s) and (a - lo) % 3 == 1:
            out.append((lo, a, lo - 2))
    return out


def windows(rs):
    return [(rs[i][2], rs[i + 1][1] - rs[i][2], i) for i in range(len(rs) - 1)]   # (shallow end e, length, index)


def sync_point_array(rs, n):
    """sp[s] = the sync point e of the reset with the largest deep 0 a <= s, or -1."""
    sp = [-1] * n
    k, cur = 0, -1
    for s in range(n):
        while k < len(rs) and rs[k][1] <= s:
            cur = rs[k][2]
            k += 1
        sp[s] = cur
    return sp


def step(st, x):
    p, c = st >> 1, st & 1
    return (c << 1) | (x ^ (c | p))


def automaton_delta(s, start):
    S, j = {0, 1, 2, 3}, start
    while len(S) > 1 and j >= 0:
        S = {step(q, int(s[j])) for q in S}
        j -= 1
    return start - j if len(S) == 1 else None


def iid_tail(nmax):
    """P(delta >= n) for fair coin flips, n = 1 .. nmax, from the subset automaton."""
    dist, out = {frozenset((0, 1, 2, 3)): 1.0}, {}
    for n in range(1, nmax + 2):
        out[n] = sum(dist.values())                     # not yet synced after n - 1 cells
        nd = {}
        for S, p in dist.items():
            for x in (0, 1):
                T = frozenset(step(q, x) for q in S)
                if len(T) > 1:
                    nd[T] = nd.get(T, 0.0) + p / 2
        dist = nd
    return out


def least_period(c):
    for p in (1, 2, 4, 8, 16):
        if ((c >> p) | (c << (16 - p))) & 0xFFFF == c:
            return p
    return 16


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('leanfile')
    ap.add_argument('outfile')
    a = ap.parse_args()
    strips = load_strips(a.leanfile)
    res, controls = {}, {}
    rows = {n: phases(v) for n, v in strips.items()}
    controls['return_16_not_8'] = {n: r[16] == r[0] and r[8] != r[0] for n, r in rows.items()}
    # the seed reaches A0 with no shift (seed_on_A0)
    v = 1
    for _ in range(177560):
        v = R(v)
    controls['seed_tick_177560_is_A0_phase'] = next((t for t in range(16) if rows['A0'][t] == v), None)
    controls['expected_seed_phase'] = 177560 % 16
    words = {n: [word(r[t]) for t in range(16)] for n, r in rows.items()}
    # columns, least periods, white diagonals
    cols = {}
    for n, ws in words.items():
        col = [0] * K
        for t, s in enumerate(ws):
            for m in re.finditer('1', s):
                col[m.start()] |= 1 << t
        cols[n] = col
    per = {n: [least_period(c) for c in col] for n, col in cols.items()}
    whites = {n: [j for j, c in enumerate(col) if c == 0] for n, col in cols.items()}
    controls['A0_whites'] = whites['A0']
    controls['A0_whites_ok'] = whites['A0'] == [2, 7, 28, 399, 53207, 58286, 87866]
    controls['A0_periods_first_11'] = per['A0'][:11]
    controls['A0_periods_ok'] = per['A0'][:11] == [1, 1, 1, 2, 1, 2, 2, 1, 4, 1, 4]
    res['whites'] = whites
    res['first_wheel_of_period'] = {n: {p: next((j for j, q in enumerate(pp) if q == p), None) for p in (2, 4, 8, 16)}
                                    for n, pp in per.items()}
    # resets and windows
    R_ = {n: [resets(s) for s in ws] for n, ws in words.items()}
    W_ = {n: [windows(rs) for rs in rr] for n, rr in R_.items()}
    # control: automaton against the run rule below wheel 4096 on A0
    mism, checked = 0, 0
    for t, s in enumerate(words['A0']):
        sp = sync_point_array(R_['A0'][t], 4096)
        for st in range(4096):
            d_rule = st - sp[st] + 1 if sp[st] >= 0 else None
            d_aut = automaton_delta(s, st)
            checked += 1
            mism += d_rule != d_aut
    controls['automaton_vs_rule_below_4096'] = {'starts': checked, 'mismatches': mism}
    want = [(2030, 65), (3080, 58), (1305, 56), (3804, 56), (3986, 55), (3385, 51)]
    have = {(e, L) for ww in W_['A0'] for e, L, _ in ww}
    controls['M38_long_windows_found'] = {f'{e}:{L}': (e, L) in have for e, L in want}
    controls['A0_max_window_below_4096'] = max(L for ww in W_['A0'] for e, L, _ in ww if e + L <= 4096)
    # white-diagonal identities and the 010 law
    law = {'cases': 0, 'violations': 0, 'identities_ok': True}
    for n in strips:
        col = cols[n]
        for j0 in whites[n]:
            if j0 < 4 or j0 + 3 >= K:
                continue
            b, x = col[j0 - 1], col[j0 + 1]
            ok = col[j0 - 2] == b and col[j0 + 2] == 0xFFFF and \
                all(((col[j0 + 3] >> t) & 1) == 1 - ((x >> ((t - 1) % 16)) & 1) for t in range(16))
            law['identities_ok'] &= ok
            for t in range(16):
                obs = words[n][t][j0 + 1:j0 + 4] == '010'
                pred = ((x >> t) & 1) == 0 and ((x >> ((t - 1) % 16)) & 1) == 1
                law['cases'] += 1
                law['violations'] += obs != pred
    controls['white_diagonal_law'] = law
    res['controls'] = controls
    # A. largest windows
    A = {}
    forks = {'A0': 0, 'A1': 58287, 'B0': 53208, 'B1': 72576}
    for n in strips:
        blocks = {}
        for ww in W_[n]:
            for e, L, _ in ww:
                b = (e // 4096) * 4096
                blocks[b] = max(blocks.get(b, 0), L)
        above = max(L for ww in W_[n] for e, L, _ in ww if e + L > forks[n])
        top = max((L, e, t) for t, ww in enumerate(W_[n]) for e, L, _ in ww)
        A[n] = {'max_by_block_4096': dict(sorted(blocks.items())), 'max_window': top[0], 'at_shallow_end': top[1],
                'phase': top[2], 'max_window_reaching_past_fork': above, 'fork': forks[n],
                'windows': sum(len(ww) for ww in W_[n])}
    res['A_largest'] = A
    # B. the i.i.d. comparison on A0
    tail = iid_tail(160)
    starts, obs = 0, {n: 0 for n in range(10, 101, 5)}
    for t, ww in enumerate(W_['A0']):
        rs = R_['A0'][t]
        for e, L, i in ww:
            lo_d = rs[i][1] - e + 1                     # the least delta in this window (start at its deep 0)
            starts += L - lo_d + 1
            for n in obs:
                obs[n] += max(0, L - max(n, lo_d) + 1)
    exp = {n: starts * tail[n] for n in obs}
    exp_windows = {n: starts * (tail[n] - tail[n + 1]) for n in range(40, 161)}
    med = next(n for n in range(40, 161) if exp_windows[n] < 0.6931)     # P(no window >= n) = exp(-E) > 1/2
    nwin = {n: sum(1 for ww in W_['A0'] for e, L, _ in ww if L >= n) for n in (40, 50, 60, 65, 70, 80, 90)}
    res['B_iid'] = {'starts': starts, 'observed_starts_delta_ge_n': obs, 'iid_expected': {n: round(exp[n], 1) for n in obs},
                    'ratio_obs_over_iid': {n: round(obs[n] / exp[n], 3) if exp[n] else None for n in obs},
                    'tail_rate_per_cell': round(tail[101] / tail[100], 5),
                    'observed_windows_ge_n': nwin,
                    'iid_expected_windows_ge_n': {n: round(exp_windows[n], 2) for n in nwin},
                    'iid_median_max_window': med - 1}
    # C. nested structure
    C = {}
    for n in strips:
        near = {}
        for j0 in whites[n]:
            if j0 < 4:
                continue
            ds = []
            for t in range(16):
                d = min((0 if lo - 1 <= j0 <= a_ else min(abs(j0 - (lo - 1)), abs(j0 - a_))) for lo, a_, _ in R_[n][t])
                ds.append(d)
            near[j0] = ds
        C[n] = {'nearest_reset_by_phase': near, 'max_over_phases': {j0: max(d) for j0, d in near.items()}}
    long_ = [(e, L, t) for t, ww in enumerate(W_['A0']) for e, L, _ in ww if L >= 40]
    chi = {}
    for m in (2, 4, 8, 16):
        cnt = [0] * m
        for e, L, t in long_:
            cnt[e % m] += 1
        ex = len(long_) / m
        x2 = sum((c - ex) ** 2 / ex for c in cnt)
        chi[m] = {'counts': cnt, 'chi2': round(x2, 2), 'one_percent_point': CHI1[m - 1], 'below': x2 < CHI1[m - 1]}
    pA = per['A0']
    base = sum(1 for j in range(400, 53208) if pA[j] == 16) / (53208 - 400)
    inside = [sum(1 for j in range(e, e + L) if pA[j] == 16) / L for e, L, t in long_ if 400 <= e and e + L <= 53208]
    wh = whites['A0']
    C['A0_long_windows'] = {'count': len(long_), 'depth_residues': chi,
                            'period16_fraction_400_53207': round(base, 4),
                            'period16_fraction_in_long_windows': round(statistics.mean(inside), 4) if inside else None,
                            'period_counts_A0': {p: pA.count(p) for p in (1, 2, 4, 8, 16)},
                            'nearest_white_distance_median': statistics.median(
                                min(abs(e - w) for w in wh) for e, L, t in long_)}
    res['C_nested'] = C
    # D. phase specificity on A0
    sps = [sync_point_array(R_['A0'][t], K) for t in range(16)]
    best_other, offs = [], [0] * 16
    for e, L, t in long_:
        s = e + L - 1
        ds = []
        for u in range(16):
            if u == t:
                continue
            d = s - sps[u][s] + 1 if sps[u][s] >= 0 else None
            ds.append(d or 0)
            if d and d >= 30:
                offs[(u - t) % 16] += 1
        best_other.append(max(ds))
    res['D_phase'] = {'long_windows': len(long_), 'median_best_other_phase_delta': statistics.median(best_other),
                      'max_best_other_phase_delta': max(best_other), 'offsets_with_delta_ge_30': offs}
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(controls))
    print(json.dumps(A))
    print(json.dumps(res['B_iid']))
    print(json.dumps({n: C[n]['max_over_phases'] for n in strips}))
    print(json.dumps(C['A0_long_windows']))
    print(json.dumps(res['D_phase']))


if __name__ == '__main__':
    main()
