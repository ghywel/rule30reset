#!/usr/bin/env python3
"""claudeCloud_bond.py: two neighbouring columns each confined to one fall residue modulo M, the rest free (K97).

On W cells, cells K and K + 1 may fall only at residues 0 and R modulo M (after a rotation of time, the first is 0);
every other cell may fall at any tick.  For each W, K and R: does some recurrent part of the strip graph escape (no
neighbouring pair fixed by its cycle)?  If for some W and K no R escapes, then on the single seed one of two
neighbouring columns has falls at two residues modulo M, each after every cutoff (the six-column argument, with Jen).

    python3 claudeCloud_bond.py M WMAX
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ARGV, sys.argv = sys.argv, ['x', 'none']
exec(open(os.path.join(HERE, 'claudeCloud_phases.py')).read().split('\ndef main():')[0])
sys.argv = ARGV

M, WMAX = int(sys.argv[1]), int(sys.argv[2])
for width in range(2, WMAX + 1):
    steps = make_steps(width)
    line = []
    for k in range(width - 1):
        esc = ''
        for r in range(M):
            allowed = [set(range(M))] * width
            allowed = [({0} if j == k else {r} if j == k + 1 else set(range(M))) for j in range(width)]
            esc += 'y' if judge(width, M, allowed, steps)[0] else 'n'
        line.append('%d:%s' % (k, esc))
    print('width', width, '| pair at K, K+1 : escapes for R = 0..%d ->' % (M - 1), ' '.join(line), flush=True)
