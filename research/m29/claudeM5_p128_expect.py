#!/usr/bin/env python3
"""Pull M29 (M44), the cross-check expectations. From M42's dump of every cyclic component of G_n (n <= 30),
decide exactly whether a closed walk of length 2h exists with bit 1 antiperiodic at half-period h, covering the
interior bits 1..n-1, with (odd) or without (oddr) a reset-free row at tick 0. Sets the expectations of the gap
5-30 cross-check in claudeM5_sat_p128.py.
Usage: claudeM5_p128_expect.py GAP_COMPONENTS_DUMP HALF_PERIOD (prints every family and gap, SAT or UNSAT)"""
import re, sys
BAD = re.compile(r'01(?:111)*0')

def succs(w, n):
    # w: tuple of bits, index i = wheel A + i
    out = []
    for b in (0, 1):
        x = [0] * (n + 1)
        x[1] = b
        for j in range(2, n + 1):
            x[j] = w[j - 2] ^ (w[j - 1] | w[j])
        x[0] = 0
        if x[n] == 0 and x[2] == 1 and x[n - 2] == x[n - 1]:
            out.append(tuple(x))
    return out

def main(dump, h):
    comps = []
    for line in open(dump):
        m = re.match(r'gap (\d+) comp size (\d+): (.*)', line.strip())
        if not m:
            continue
        n = int(m.group(1))
        rows = [tuple(int(c) for c in tok.rstrip('*')) for tok in m.group(3).split()]
        comps.append((n, rows))
    res = {}
    for n, rows in comps:
        S = set(rows)
        E = {w: [x for x in succs(w, n) if x in S] for w in rows}
        full = (1 << n) - 2          # bits 1..n-1
        def mask(w):
            return sum(w[i] << i for i in range(1, n))
        for fam in ('odd', 'oddr'):
            found = False
            for x0 in rows:
                if fam == 'odd' and BAD.search(''.join(map(str, x0))):
                    continue
                for y0 in rows:
                    if x0[1] == y0[1]:
                        continue
                    cur = {(x0, y0, mask(x0) | mask(y0))}
                    for k in range(h):
                        nxt = set()
                        for x, y, mk in cur:
                            for x2 in E[x]:
                                for y2 in E[y]:
                                    if k < h - 1 and x2[1] == y2[1]:
                                        continue
                                    nxt.add((x2, y2, mk | mask(x2) | mask(y2)))
                        cur = nxt
                        if not cur:
                            break
                    if any(x == y0 and y == x0 and mk == full for x, y, mk in cur):
                        found = True
                        break
                if found:
                    break
            res.setdefault((fam, n), False)
            res[(fam, n)] |= found
    for k in sorted(res, key=lambda k: (k[0], k[1])):
        print(k, 'SAT' if res[k] else 'UNSAT')

if __name__ == '__main__':
    main(sys.argv[1], int(sys.argv[2]))
