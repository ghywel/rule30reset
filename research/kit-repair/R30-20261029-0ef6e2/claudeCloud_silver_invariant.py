#!/usr/bin/env python3
"""claudeCloud_silver_invariant.py: N9's invariant-set step, repeated on a map made without the torus function
(ledger K72, addendum 4).

Input: the silver map written by `claudeCloud_direct_excess.py map silver N G ... FILE`, one line per target:
the target (a, b) at a cell centre of the G x G grid, R at the phase whose scale-N torus point is nearest it, the
phase, the lag. A cell is *passing* at level c if R < c at its centre.

N9 says: no orbit of D = [[3,4],[2,3]] on the torus stays among the passing cells except the fixed point 0. The
test here is the same pruning, S <- S n succ(S) n pred(S), with the image of a cell enclosed by the bounding box of
its four corners (7 x 5 cells, a superset of the cells its image meets). Because a cell is judged by one sample at
its centre, this is an exploratory repeat, not a certificate.

    python3 claudeCloud_silver_invariant.py FILE G
"""
import sys


def main():
    path, G = sys.argv[1], int(sys.argv[2])
    R = {}
    for line in open(path):
        a, b, r = line.split()[:3]
        R[(int(float(a) * G), int(float(b) * G))] = float(r)
    assert len(R) == G * G, len(R)

    def image(cell):
        i, j = cell
        return [((3 * i + 4 * j + dx) % G, (2 * i + 3 * j + dy) % G) for dx in range(7) for dy in range(5)]

    for level in (0.0099, 0.02, 0.05, 0.10):
        S = {c for c, r in R.items() if r < level}
        start = len(S)
        sweeps = 0
        while True:
            succ = set()
            for c in S:
                succ.update(image(c))
            keep = {c for c in S if c in succ and any(d in S for d in image(c))}
            sweeps += 1
            if keep == S:
                break
            S = keep

        def dist(c):
            return max(min(c[0], G - 1 - c[0]), min(c[1], G - 1 - c[1]))
        far = max((dist(c) for c in S), default=-1)
        print('level %.4f: %d passing cells (%.2f%%), %d left after %d sweeps, farthest from 0: %s cells; left: %s' % (
            level, start, 100.0 * start / (G * G), len(S), sweeps, far if far >= 0 else 'none',
            sorted(S)[:12] if len(S) <= 12 else '%d cells' % len(S)))


if __name__ == '__main__':
    main()
