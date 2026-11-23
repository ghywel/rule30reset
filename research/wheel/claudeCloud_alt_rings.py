#!/usr/bin/env python3
"""claudeCloud_alt_rings.py: rebuild and check the patterns listed by claudeCloud_alt_periodic.cpp (ledger K79).

Each input line `N .. column B gate .. space Q time ..` names a column B (N ticks, tick 0 first) standing beside the
alternating column (black at odd ticks). The pattern is rebuilt leftwards column by column, checked to close up
after Q columns, checked against Rule 30 on the whole Q x N torus, and read as a right half: columns 1..16 at the
white ticks, against the kit's gate trap.

    python3 claudeCloud_alt_rings.py KITFILE CENSUS.txt [CENSUS.txt ...]
One line per pattern up to time shift: its gap word, size, the share of black cells, and where it sits.
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L      # noqa: E402


def rebuild(N, B, Q):
    alt = [t % 2 for t in range(N)]
    a, b = alt, [int(ch) for ch in B]
    cols = {0: a, 1: b}
    j = 0
    for _ in range(Q):
        left = [a[(t + 1) % N] ^ (a[t] | b[t]) for t in range(N)]
        j -= 1
        cols[j] = left
        a, b = left, a
    assert cols[-Q] == alt and cols[1 - Q] == [int(ch) for ch in B], 'does not close up'
    grid = [cols[j - Q] for j in range(1, Q + 1)]        # columns 1..Q of one period (column Q is the wall again)
    return grid


def check_rule(grid, N):
    Q = len(grid)
    for x in range(Q):
        for t in range(N):
            l, c, r = grid[(x - 1) % Q][t], grid[x][t], grid[(x + 1) % Q][t]
            assert grid[x][(t + 1) % N] == l ^ (c | r), 'rule broken'


def gaps_of(gate):
    ks = [i for i, g in enumerate(gate) if g]
    n = len(gate)
    return ''.join(str((ks[(i + 1) % len(ks)] - ks[i] - 1) % n + 1) for i in range(len(ks)))


def necklace(s):
    return min(s[i:] + s[:i] for i in range(len(s)))


def main():
    trap = set(int(c) for c in L.trap_codes(sys.argv[1]))
    seen = {}
    for path in sys.argv[2:]:
        for line in open(path):
            f = line.split()
            if len(f) < 9 or f[2] != 'column':
                continue
            N, B, Q, least = int(f[1]), f[3], int(f[7]), int(f[9])
            grid = rebuild(N, B, Q)
            check_rule(grid, N)
            gate = [grid[0][t] for t in range(0, N, 2)]
            word = necklace(gaps_of(gate[:least // 2]))
            # the right half: column j (1-based) at tick t is grid[(j - 1) % Q][t]; windows of 16 at the samples
            inside = [sum(grid[i % Q][t] << i for i in range(16)) in trap for t in range(0, N, 2)]
            # every alternating column of the pattern (each is a wall for the half to its right)
            walls = [x for x in range(Q) if all(grid[x][t] == t % 2 for t in range(N))]
            walls_shifted = [x for x in range(Q) if all(grid[x][t] == (t + 1) % 2 for t in range(N))]
            black = sum(map(sum, grid)) / (Q * N)
            key = (word, Q, least)
            seen.setdefault(key, dict(count=0, black=black, inside=set(), walls=len(walls) + len(walls_shifted)))
            seen[key]['count'] += 1
            seen[key]['inside'].add('all' if all(inside) else ('none' if not any(inside) else 'some'))
    for (word, Q, least), d in sorted(seen.items(), key=lambda kv: kv[0][2]):
        print('gaps (%s) repeated: %d columns by %d ticks; black share %.5f; alternating columns in one period %d;'
              ' sixteen-column windows in the trap: %s; time shifts and multiples listed %d'
              % (','.join(word), Q, least, d['black'], d['walls'], '/'.join(sorted(d['inside'])), d['count']))


if __name__ == '__main__':
    main()
