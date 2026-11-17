#!/usr/bin/env python3
"""M7 first test: the empty right half's word u, its factor complexity, and the row Psi of the empty right half.

Definitions (kit): Rule30Ether.drv c x is rule 30 on the columns p >= 1 with column 0 prescribed by c and right half x;
Rule30PeriodTwoCoupled.altCol t = (t even); Rule30PeriodTwoSideways.u R s = drv altCol R (2s + 1) 1, and
Psi R = Theta (fun s => !u R s), CQ01Empty = not FinSupp (Psi empty). Rule30ZeroWallDiagonals proves that if some K
has factorCount f n <= n + K for infinitely many n, then Theta f is not finitely supported. Complementing f does not
change factorCount, so a u with that bounded excess would give CQ01Empty.

Here u = u empty is computed exactly to S steps (big-integer rows: bit p - 1 is column p). Its gaps are checked against
the kit's u_empty_gaps (gaps 3 or 5 from s = 146 on), as a control. The factor complexity of u (binary) and of its gap
word (alphabet {3, 5}) comes from a suffix automaton: the number of distinct factors of length n of the computed
prefix, a lower bound for the infinite word's. Psi = Theta(not u) is built to depth D from its column -1 trace
(black at even t, not u(s) at t = 2s + 1) by the antidiagonal recurrence of m6_floors.py.

Usage: m7_uempty.py OUTDIR [--S 450000] [--nmax 2000] [--depth 4000] [--svg-s 600]
"""
import argparse, json, os, sys, time


def u_empty(S):
    X, u = 0, []
    for t in range(2 * S + 1):
        if t % 2 == 1:
            u.append(X & 1)
        c = 1 if t % 2 == 0 else 0
        X = ((X << 1) | c) ^ (X | (X >> 1))
    return u


def complexity(word, nmax):
    """p(n) for n = 1..nmax: distinct factors of length n of word (a list over {0, 1}), via a suffix automaton."""
    N = len(word)
    size = 2 * N + 2
    link = [-1] * size
    length = [0] * size
    nx0 = [-1] * size
    nx1 = [-1] * size
    last, cnt = 0, 1
    for ch in word:
        cur = cnt
        cnt += 1
        length[cur] = length[last] + 1
        p = last
        nx = nx1 if ch else nx0
        while p != -1 and nx[p] == -1:
            nx[p] = cur
            p = link[p]
        if p == -1:
            link[cur] = 0
        else:
            q = nx[p]
            if length[p] + 1 == length[q]:
                link[cur] = q
            else:
                cl = cnt
                cnt += 1
                length[cl] = length[p] + 1
                nx0[cl], nx1[cl], link[cl] = nx0[q], nx1[q], link[q]
                while p != -1 and nx[p] == q:
                    nx[p] = cl
                    p = link[p]
                link[q] = link[cur] = cl
        last = cur
    diff = [0] * (nmax + 2)
    for v in range(1, cnt):
        lo, hi = length[link[v]] + 1, min(length[v], nmax)
        if lo <= hi:
            diff[lo] += 1
            diff[hi + 1] -= 1
    p, run = [0] * (nmax + 1), 0
    for n in range(1, nmax + 1):
        run += diff[n]
        p[n] = run
    return p


def extend(A1, A2, T, b):
    if T == 0:
        return b
    C = (A1 | (A2 << 1)) & ((1 << T) - 1)
    P, sh = C, 1
    while sh < T:
        P ^= P << sh
        sh <<= 1
    P &= (1 << T) - 1
    return ((((1 << (T + 1)) - 1) if b else 0) ^ (P << 1))


def theta_row(f, D):
    """Theta f to depth D: the zero-wall row whose column -1 reads black at even t and f(s) at t = 2s + 1.
    Returns the list of cells at depths 1..D."""
    A1 = A2 = 0
    row = []
    for T in range(D):
        b = 1 if T % 2 == 0 else f[(T - 1) // 2]
        A = extend(A1, A2, T, b)
        row.append((A >> T) & 1)
        A1, A2 = A, A1
    return row


def zrow_trace(row, H):
    """Column -1 of the zero-wall evolution of a finite row (depths 1..len), for checking theta_row."""
    Y = sum(b << i for i, b in enumerate(row))
    out = []
    for _ in range(H):
        out.append(Y & 1)
        Y = (Y >> 1) ^ (Y | (Y << 1))
    return out


def svg(u, psi, s_max, path):
    W, x0, sc = 1200, 60, (1200 - 80) / s_max
    ones = [s for s in range(min(len(u), s_max)) if u[s]]
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="230" font-family="sans-serif" '
             f'font-size="12"><rect width="100%" height="100%" fill="white"/>']
    parts.append(f'<text x="{x0}" y="18">u of the empty right half (black cells, by white step s) and Psi of the '
                 f'empty right half (black cells, by depth k, drawn at s = (k - 2)/2)</text>')
    for a, b in zip(ones, ones[1:]):
        col = '#c0392b' if b - a == 3 else ('#2c7fb8' if b - a == 5 else '#999999')
        parts.append(f'<rect x="{x0 + a * sc:.2f}" y="40" width="{max((b - a) * sc - 0.6, 0.4):.2f}" height="40" '
                     f'fill="{col}"/>')
    for k, v in enumerate(psi, start=1):
        s = (k - 2) / 2
        if v and 0 <= s < s_max:
            parts.append(f'<rect x="{x0 + s * sc:.2f}" y="110" width="0.9" height="40" fill="black"/>')
    for s in range(0, s_max + 1, 50):
        parts.append(f'<text x="{x0 + s * sc - 6:.1f}" y="170">{s}</text>')
    parts.append(f'<text x="{x0}" y="195">Top: one bar per gap of u between consecutive black cells, red = 3, blue '
                 f'= 5, grey = other (the ether gaps 2 and 5 before s = 146).</text>')
    parts.append(f'<text x="{x0}" y="212">Bottom: black cells of Psi = Theta(not u). Free bit s enters at depth '
                 f'2s + 2. First {s_max} white steps shown.</text>')
    parts.append('</svg>')
    with open(path, 'w') as fh:
        fh.write('\n'.join(parts))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outdir')
    ap.add_argument('--S', type=int, default=450000)
    ap.add_argument('--nmax', type=int, default=2000)
    ap.add_argument('--depth', type=int, default=4000)
    ap.add_argument('--svg-s', type=int, default=600)
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    t0 = time.time()
    u = u_empty(a.S)
    ones = [s for s, b in enumerate(u) if b]
    gaps = [b - a_ for a_, b in zip(ones, ones[1:])]
    late = [(s, g) for s, g in zip(ones, gaps) if s >= 146]
    control_ok = all(g in (3, 5) for _, g in late)
    early = sorted(set(g for s, g in zip(ones, gaps) if s < 146))
    res = {'S': a.S, 'black_cells': len(ones), 'gaps': len(gaps), 'control_gaps_3_or_5_from_146': control_ok,
           'early_gap_values': early, 'u_seconds': round(time.time() - t0, 1)}
    g_late = [g for s, g in late]
    res['freq3'] = g_late.count(3) / len(g_late)
    # distances, in gaps, between consecutive 3-gaps (Sturmian would need two consecutive values)
    pos3 = [i for i, g in enumerate(g_late) if g == 3]
    d3 = [b - a_ for a_, b in zip(pos3, pos3[1:])]
    res['dist_between_3s_values'] = sorted(set(d3))
    res['dist_between_3s_hist'] = {str(v): d3.count(v) for v in sorted(set(d3))}
    # eventual periodicity of the late gap word, checked on its second half
    half = len(g_late) // 2
    per = None
    for p in range(1, 10001):
        if all(g_late[i] == g_late[i + p] for i in range(half, len(g_late) - p)):
            per = p
            break
    res['gap_word_period_le_10000_on_second_half'] = per
    # factor complexity
    t1 = time.time()
    pu = complexity(u, a.nmax)
    pg = complexity([1 if g == 3 else 0 for g in g_late], min(a.nmax, 1000))
    sample = [1, 2, 3, 5, 10, 20, 30, 50, 75, 100, 150, 200, 300, 500, 750, 1000, 1500, 2000]
    res['p_u_excess'] = {n: pu[n] - n for n in sample if n <= a.nmax}
    res['p_u_min_excess_over_n>=100'] = min((pu[n] - n for n in range(100, a.nmax + 1)), default=None)
    res['p_gap_excess'] = {n: pg[n] - n for n in sample if n <= min(a.nmax, 1000)}
    res['complexity_seconds'] = round(time.time() - t1, 1)
    # Psi of the empty right half
    f = [1 - b for b in u]
    psi = theta_row(f, a.depth)
    assert zrow_trace(psi, a.depth - 2)[:a.depth - 2] == [1 if t % 2 == 0 else f[(t - 1) // 2]
                                                          for t in range(a.depth - 2)], 'Theta check failed'
    blacks = [k for k, v in enumerate(psi, start=1) if v]
    res['psi_depth'] = a.depth
    res['psi_black_cells'] = len(blacks)
    res['psi_density'] = len(blacks) / a.depth
    res['psi_max_white_run'] = max(b - a_ - 1 for a_, b in zip(blacks, blacks[1:]))
    res['psi_first_black_depths'] = blacks[:40]
    svg(u, psi, a.svg_s, os.path.join(a.outdir, 'm7_uempty.svg'))
    with open(os.path.join(a.outdir, 'm7_u.txt'), 'w') as fh:
        fh.write(''.join(map(str, u)))
    res['seconds'] = round(time.time() - t0, 1)
    with open(os.path.join(a.outdir, 'm7_results.json'), 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
