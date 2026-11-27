#!/usr/bin/env python3
"""claudeCloud_grow.py: the assignments that escape the test, grown one cell at a time (K95, addendum 1).

An assignment of fall residues to W cells can escape the test of claudeCloud_phases.py only if both of its
restrictions to W - 1 neighbouring cells escape: a recurrent part of the wider graph lies over a recurrent part of
the narrower one, and a pair fixed there is fixed here.  So the escaping assignments of width W are found among
the one-cell extensions of those of width W - 1, which keeps wide strips and large moduli within reach.

    one M WMAX       one residue for each cell modulo M: the escaping assignments at each width, listed while few
    two WMAX         modulo 3, each cell forbidden one residue: their number at each width
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ARGV, sys.argv = sys.argv, ['x', 'none']
exec(open(os.path.join(HERE, 'claudeCloud_phases.py')).read().split('\ndef main():')[0])
sys.argv = ARGV


def grow(modulus, wmax, sets_of, show):
    """sets_of(r) = the allowed residues of a cell labelled r.  Escapers are stored as tuples of labels, every rotation."""
    rotate = lambda a, d: tuple((r + d) % modulus for r in a)
    escapers = None
    print('width | candidates tested | escaping assignments (west label 0) | all rotations')
    for width in range(2, wmax + 1):
        steps = make_steps(width)
        if escapers is None:
            cands = [(0, r) for r in range(modulus)]
        else:
            cands = sorted({a + (r,) for a in escapers if a[0] == 0 for r in range(modulus) if a[1:] + (r,) in escapers})
        found = [a for a in cands if judge(width, modulus, [sets_of(r) for r in a], steps)[0]]
        escapers = {rotate(a, d) for a in found for d in range(modulus)}
        print(width, '|', len(cands), '|', len(found), '|', len(escapers), flush=True)
        if show and len(found) <= 24:
            for a in found:
                print('      ', ' '.join(map(str, a)))
        if not found:
            break


def main():
    mode = sys.argv[1]
    if mode == 'one':
        modulus = int(sys.argv[2])
        print('modulo %d, one residue for each cell' % modulus)
        grow(modulus, int(sys.argv[3]), lambda r: {r}, True)
    else:
        print('modulo 3, each cell forbidden one residue (the label)')
        grow(3, int(sys.argv[2]), lambda r: {0, 1, 2} - {r}, False)


main()
