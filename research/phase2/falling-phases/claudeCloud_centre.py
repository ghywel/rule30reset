#!/usr/bin/env python3
"""claudeCloud_centre.py: can the strip method reach the centre alone? (K97; development)

1. strip W K: the test of claudeCloud_phases.py on W cells with only cell K constrained to one fall residue modulo 3
   (the other cells may fall at any tick).  Does some recurrent part escape (no neighbouring pair fixed by its cycle,
   and no column fixed by it either)?
2. realized T: I307's control row (centre reads 011 for ever, right half white at tick 0), built tick by tick from
   the centre column and the right half, as the kit's realization does: cell t+1 (-1) is fixed by the rule from the
   centre and its right neighbour.  Report the fall residues of columns -1 .. -5 and whether any of columns -6 .. 5
   other than the centre repeats with period 3, 6 or 12 over the last T/2 ticks.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ARGV, sys.argv = sys.argv, ['x', 'none']
exec(open(os.path.join(HERE, 'claudeCloud_phases.py')).read().split('\ndef main():')[0])
sys.argv = ARGV
from math import gcd


def escapes_strict(width, allowed, steps):
    """True when some recurrent part has neither a neighbouring pair nor a single column fixed by its cycle."""
    size = 1 << width
    edges, _ = graph(width, 3, allowed, steps)
    n = 3 * size
    comp, ncomp = components(n, edges)
    members = [[] for _ in range(ncomp)]
    for v in range(n):
        members[comp[v]].append(v)
    for c in range(ncomp):
        nodes = members[c]
        if len(nodes) == 1 and nodes[0] not in edges[nodes[0]]:
            continue
        inside = set(nodes)
        level, queue, period = {nodes[0]: 0}, [nodes[0]], 0
        for v in queue:
            for w in edges[v]:
                if w in inside:
                    if w not in level:
                        level[w] = level[v] + 1
                        queue.append(w)
                    period = gcd(period, level[v] + 1 - level[w])
        differ, first = 0, {}
        for v in nodes:
            key = level[v] % period
            s = v % size
            if key in first:
                differ |= s ^ first[key]
            else:
                first[key] = s
        if all((differ >> k) & 1 for k in range(width)):      # no single column fixed, so no pair either
            return True
    return False


def realized(T):
    # right half: columns 0..T+2 (column 0 the centre), white beyond; the centre is prescribed as 011 011 ...
    word = [0, 1, 1]
    W = T + 4
    right = [0] * W                      # right[p] = cell (t, p) for p >= 0
    right[0] = word[0]
    left = {}                            # left[(t, p)] for p < 0, built from the centre column backwards in space
    cols = {}
    rows = [right[:]]
    for t in range(T + 2):
        nxt = [0] * W
        for p in range(1, W - 1):
            nxt[p] = right[p - 1] ^ (right[p] | right[p + 1])
        nxt[0] = word[(t + 1) % 3]
        right = nxt
        rows.append(right[:])
    # cell t (-1) from the rule at column 0: c(t+1) = cell t (-1) xor (c(t) or cell t (1))
    col = {0: [rows[t][0] for t in range(T + 2)], 1: [rows[t][1] for t in range(T + 2)]}
    for p in range(-1, -7, -1):
        col[p] = [col[p + 1][t + 1] ^ (col[p + 1][t] | col[p + 2][t]) for t in range(len(col[p + 1]) - 1)]
    for p in range(2, 6):
        col[p] = [rows[t][p] for t in range(T + 2)]
    out = []
    for p in sorted(col):
        c = col[p]
        n = len(c)
        falls = sorted({t % 3 for t in range(n // 2, n - 1) if c[t] and not c[t + 1]})
        per = [P for P in (1, 2, 3, 6, 12) if all(c[t] == c[t + P] for t in range(n // 2, n - P))]
        out.append((p, falls, per))
    return out


def main():
    if sys.argv[1] == 'strip':
        for width in range(3, int(sys.argv[2]) + 1):
            steps = make_steps(width)
            res = []
            for k in range(width):
                res.append(escapes_strict(width, [{0} if j == k else {0, 1, 2} for j in range(width)], steps))
            print('width', width, ': centre at position 0 ..', width - 1, '-> escapes:', ''.join('y' if r else 'n' for r in res), flush=True)
    else:
        for p, falls, per in realized(int(sys.argv[2])):
            print('column %3d: fall residues in the second half %s; periods among 1, 2, 3, 6, 12: %s' % (p, falls, per or 'none'))


main()
