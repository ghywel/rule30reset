#!/usr/bin/env python3
"""claudeCloud_local_laws.py: local laws of reset-free ("bare") rows under the wheel rule, by exhaustive enumeration
on rings (ledger K17; the owner's observation on rows whose reset words are single cells).

The wheel rule on a ring of n cells: new[j] = v[j-2] xor (v[j-1] or v[j]). A row is bare when no closed black run has
length 1, 4, 7, ... (the all-black and all-white rings count as bare and are listed apart).

COMMAND:  python3 claudeCloud_local_laws.py [NMAX]
"""
import sys


def step(v, n):
    return tuple(v[(j - 2) % n] ^ (v[(j - 1) % n] | v[j]) for j in range(n))


def runs(v, n, colour):
    """Lengths of the maximal cyclic runs of `colour`; [] for a constant ring."""
    if all(c == v[0] for c in v):
        return []
    k = next(i for i in range(n) if v[i] != colour and v[(i + 1) % n] == colour)
    out, m = [], 0
    for i in range(1, n + 1):
        c = v[(k + i) % n]
        if c == colour:
            m += 1
        elif m:
            out.append(m)
            m = 0
    return out


def bare(v, n):
    return all(l % 3 != 1 for l in runs(v, n, 1))


def main():
    nmax = int(sys.argv[1]) if len(sys.argv) > 1 else 20
    print(' n   bare   bare,bare  (first: white gaps all 2?)   bare,bare,bare  (all 11100?)   bare,any,bare   next row of bare: runs')
    prev = {}
    for n in range(5, nmax + 1):
        c1 = c2 = c3 = c13 = 0
        gaps2 = True
        only5 = True
        nextruns = set()
        for x in range(1, (1 << n) - 1):
            v = tuple((x >> i) & 1 for i in range(n))
            if not bare(v, n):
                continue
            c1 += 1
            f = step(v, n)
            nextruns.update(runs(f, n, 1))
            b2 = bare(f, n) and 0 < sum(f) < n
            g = step(f, n)
            b3 = bare(g, n) and 0 < sum(g) < n
            if b2:
                c2 += 1
                gaps2 &= all(l == 2 for l in runs(v, n, 0))
                if b3:
                    c3 += 1
                    only5 &= (n % 5 == 0 and set(runs(v, n, 1)) == {3} and set(runs(v, n, 0)) == {2})
            if b3:
                c13 += 1
        rate = lambda k, c: ('%.3f' % (c / prev[k]) if prev.get(k) else '  -  ')
        print('%2d %6d (x%s) %6d (x%s) %-5s %8d %-5s %12d (x%s)   %s'
              % (n, c1, rate('1', c1), c2, rate('2', c2), 'yes' if gaps2 else 'NO', c3, 'yes' if only5 else 'NO',
                 c13, rate('13', c13), sorted(nextruns)))
        prev = {'1': c1, '2': c2, '13': c13}


if __name__ == '__main__':
    main()
