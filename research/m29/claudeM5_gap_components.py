#!/usr/bin/env python3
"""Pull M29 (M42, exploratory, after the frozen run): read claudeM5_gap_dump's components and classify them.

For each cyclic component of G_n: its period g (gcd of cycle lengths), whether it is whole (no interior wheel white
on every row), its reset-free rows, and whether a doubling lives in it: some pair (x, y) with complementary bit 1
reaching (y, x) in the pair graph, at any length (BFS), with the half-periods up to 64 that occur. A physical
excursion has a power-of-two period, so it needs g to be a power of two. Then the gap-23 swap witness of the frozen
run is rebuilt as an explicit orbit and checked from the row dynamics.
Usage: claudeM5_gap_components.py DUMPFILE OUTFILE
"""
import json, re, sys
from collections import deque
from math import gcd


def analyse(dumpfile):
    comps = []
    for line in open(dumpfile):
        m = re.match(r'gap (\d+) comp size (\d+): (.*)', line.strip())
        n = int(m.group(1))
        rows = m.group(3).split()
        W = [sum(int(c) << i for i, c in enumerate(r.rstrip('*'))) for r in rows]
        bad = {W[i] for i, r in enumerate(rows) if r.endswith('*')}
        mask, S = (1 << (n + 1)) - 1, set(W)

        def succ(w):
            R = (((w << 2) ^ ((w << 1) | w)) & mask) & ~3
            return [x for x in (R, R | 2) if x in S]
        lev, q, g = {W[0]: 0}, deque([W[0]]), 0
        while q:
            u = q.popleft()
            for v in succ(u):
                if v not in lev:
                    lev[v] = lev[u] + 1
                    q.append(v)
                else:
                    g = gcd(g, abs(lev[u] + 1 - lev[v]))
        orr = 0
        for w in W:
            orr |= w
        whole = all((orr >> i) & 1 for i in range(1, n))
        swap_any, swap_bad, halfs = False, False, set()
        for x in W:
            for y in W:
                if not (x ^ y) & 2:
                    continue
                seen, q = {(x, y)}, deque([(x, y)])
                while q:
                    a, b = q.popleft()
                    for a2 in succ(a):
                        for b2 in succ(b):
                            if (a2 ^ b2) & 2 and (a2, b2) not in seen:
                                seen.add((a2, b2))
                                q.append((a2, b2))
                if (y, x) in seen:
                    swap_any = True
                    swap_bad |= x in bad
                    cur = {(x, y)}
                    for L in range(1, 65):
                        cur = {(a2, b2) for a, b in cur for a2 in succ(a) for b2 in succ(b) if (a2 ^ b2) & 2}
                        if (y, x) in cur:
                            halfs.add(L)
        comps.append({'gap': n, 'size': len(W), 'period': g, 'dyadic': g > 0 and g & (g - 1) == 0, 'whole': whole,
                      'reset_free_rows': len(bad), 'doubling': swap_any, 'doubling_with_reset_free_row': swap_bad,
                      'half_periods_to_64': sorted(halfs),
                      'dyadic_half_periods_to_64': sorted(h for h in halfs if h & (h - 1) == 0)})
    return comps


def witness_23():
    n, mask = 23, (1 << 24) - 1

    def legal(w):
        return ((w >> (n - 2)) ^ (w >> (n - 1))) & 1 == 0

    def succ(w):
        R = (((w << 2) ^ ((w << 1) | w)) & mask) & ~3
        return [x for x in (R, R | 2) if legal(x)]

    def reset_free(w):
        return not re.search(r'01(?:111)*0', format(w, '024b')[::-1])
    x, y = 0x7fbb76, 0x64ccc
    prev, q, found = {(x, y): None}, deque([(x, y)]), None
    while q and not found:
        a, b = q.popleft()
        for a2 in succ(a):
            for b2 in succ(b):
                if (a2 ^ b2) & 2 and (a2, b2) not in prev:
                    prev[(a2, b2)] = (a, b)
                    q.append((a2, b2))
                    if (a2, b2) == (y, x):
                        found = (a2, b2)
    path, s = [], found
    while s:
        path.append(s)
        s = prev[s]
    path = path[::-1]
    P = len(path) - 1
    orbit = [p[0] for p in path][:-1] + [p[1] for p in path][:-1]
    T = len(orbit)
    cols = [[(orbit[t] >> j) & 1 for t in range(T)] for j in range(n + 1)]
    e = [cols[1][(t + 1) % T] ^ cols[1][t] for t in range(T)]
    lp = next(p for p in range(1, T + 1) if T % p == 0 and all(e[i] == e[(i + p) % T] for i in range(T)))
    return {'half_period': P, 'orbit_period': T,
            'closed_walk': all(orbit[(t + 1) % T] in succ(orbit[t]) for t in range(T)),
            'source_least_period': lp, 'source_parity': sum(e[:lp]) % 2,
            'child_antiperiodic': all(cols[1][(t + P) % T] == 1 - cols[1][t] for t in range(T)),
            'ends_white': not any(cols[0]) and not any(cols[n]), 'A_plus_2_black': all(cols[2]),
            'whole': all(any(c) for c in cols[1:n]),
            'reset_free_ticks': [t for t in range(T) if reset_free(orbit[t])],
            'rows_wheel_order': [format(w, '024b')[::-1] for w in orbit]}


def main():
    comps = analyse(sys.argv[1])
    res = {'components': comps, 'gap23_witness': witness_23()}
    res['dyadic_components'] = [c for c in comps if c['dyadic']]
    res['dyadic_with_doubling'] = [(c['gap'], c['dyadic_half_periods_to_64']) for c in comps
                                   if c['dyadic'] and c['doubling']]
    res['dyadic_whole_with_reset_free_rows'] = [(c['gap'], c['period']) for c in comps
                                                if c['dyadic'] and c['whole'] and c['reset_free_rows']]
    with open(sys.argv[2], 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: res[k] for k in ('dyadic_with_doubling', 'dyadic_whole_with_reset_free_rows')}))
    print(json.dumps({k: v for k, v in res['gap23_witness'].items() if k != 'rows_wheel_order'}))


if __name__ == '__main__':
    main()
