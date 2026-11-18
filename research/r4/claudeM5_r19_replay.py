#!/usr/bin/env python3
"""claudeM5's replay of R19's COMPUTED claims, written without reusing research/r4/check.py.

The seed's rows are kept as dicts of black positions' bit sets in absolute coordinates (bit p + OFF is cell p),
evolved by rule 30 on the full line. For every white centre t in 2..T: the gap by definition, the least j with
x(t - j, j - 2) black; the source u = t - g. Checked against R19:
  - each source row's gaps are exactly 1..min(m(u), T - u), with m(u) = min(L, R - 1 + b) read off the run at -1;
  - successive sources with m >= 2 satisfy v >= u + m(u) + 1;
  - for each K, the white ticks with gap > K equal the rows s in [max(0, 2 - K), T - K] white on [-K, K];
  - the tail counts at K = 1..6, the number of white ticks and of source rows.
Also every word of radius 1..7 (43,688 words): no hit and a white terminal holds exactly for the white word.
Usage: claudeM5_r19_replay.py [T]
"""
import json, sys


def rows_upto(T):
    OFF = T + 2
    rows = [1 << OFF]
    for _ in range(T):
        x = rows[-1]
        rows.append((x << 1) ^ (x | (x >> 1)))  # new(p) = x(p - 1) xor (x(p) or x(p + 1))
    return rows, OFF


def main():
    T = int(sys.argv[1]) if len(sys.argv) > 1 else 4096
    rows, OFF = rows_upto(T)
    cell = lambda t, p: (rows[t] >> (p + OFF)) & 1
    white, gaps = [], {}
    for t in range(2, T + 1):
        if cell(t, 0):
            continue
        g = next(j for j in range(1, t + 1) if cell(t - j, j - 2))
        white.append(t)
        gaps.setdefault(t - g, []).append(g)

    def m_of(u):
        if not cell(u, -1):
            return 0
        L = 1
        while cell(u, -1 - L):
            L += 1
        R = 1
        while cell(u, -1 + R):
            R += 1
        return min(L, R - 1 + cell(u, R))

    ok_intervals = all(sorted(gs) == list(range(1, min(m_of(u), T - u) + 1)) for u, gs in gaps.items())
    no_missing = all(u in gaps for u in range(0, T - 1) if min(m_of(u), T - u) >= 1)
    srcs = sorted(u for u in range(T + 1) if m_of(u) >= 2)
    spacing_ok = all(v >= u + m_of(u) + 1 for u, v in zip(srcs, srcs[1:]))
    tails, vac = {}, {}
    for K in range(1, 8):
        tails[K] = sum(1 for u, gs in gaps.items() for g in gs if g > K)
        mask = ((1 << (2 * K + 1)) - 1) << (OFF - K)
        vac[K] = sum(1 for s in range(max(0, 2 - K), T - K + 1) if rows[s] & mask == 0)
    cones = 0
    cones_ok = True
    for r in range(1, 8):
        n = 2 * r + 1
        for w in range(1 << n):
            x, hit = w, False   # bit i is position i - r
            width = n
            for j in range(r, 0, -1):          # j ticks before the terminal: test position j - 2
                if (x >> (j - 2 + (width - 1) // 2)) & 1:
                    hit = True
                x = (x ^ ((x >> 1) | (x >> 2))) & ((1 << (width - 2)) - 1)
                width -= 2
            terminal_white = (x & 1) == 0
            cones_ok &= ((not hit and terminal_white) == (w == 0))
            cones += 1
    res = {'T': T, 'white_ticks': len(white), 'source_rows': len(gaps), 'intervals_exact': ok_intervals,
           'every_source_row_used': no_missing, 'spacing_holds': spacing_ok,
           'tails_by_gap': tails, 'vacuum_rows': vac, 'tails_equal_vacuum': tails == vac,
           'cone_words': cones, 'cone_identity': cones_ok}
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
