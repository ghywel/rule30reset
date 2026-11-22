#!/usr/bin/env python3
"""claudeCloud_ether_lock_diag.py: pull K50.1 (ledger K66, addendum 2). Unregistered diagnostics, run after
claudeCloud_ether_lock_exact.py to close what it reported open. No predictions were frozen for it.

The follow-up's refinement returned 'open' for three different reasons without saying which: a branch whose window
is forced into the gate trap, the depth limit, or the width limit. The first of these is not open at all: every
right half on that branch enters the trap, so the prefix does not force the lock. This script repeats the search and
keeps the reasons apart.

  1. The seed 31 on cells 1..23.
  2. Every prefix of 1 to 16 cells the follow-up left undecided: its length, and the reason.
Each is then tried two more ways: a refinement that also lets a branch close behind a deeper wall (refine_deep), and
3000 more random tails of 8 to 128 cells in search of one that enters the trap.

    python3 claudeCloud_ether_lock_diag.py KIT_LEAN_DIR
"""
import sys

import claudeCloud_ether_lock as P
import claudeCloud_ether_lock_exact as E

M = E.M


def refine(v, L, AE, AT, depth=E.DEPTH, width=E.WIDTH):
    """('lock', n) | ('trap branch', (prefix value, its length)) | ('depth', n) | ('width', n)."""
    level = ((v | (r << L), 20) for r in range(1 << (20 - L))) if L < 20 else [(v, L)]
    deepest = L
    while True:
        nxt = []
        for x, n in level:
            t = n - 19 if (n - 19) % 2 == 1 else n - 20
            w = P.row_at(x, t) & M
            if AE[w]:
                deepest = max(deepest, n); continue
            if AT[w]:
                return ('trap branch', (x, n))
            if n >= depth:
                return ('depth', n)
            if len(nxt) >= width:
                return ('width', n)
            nxt.append((x, n + 1)); nxt.append((x | (1 << n), n + 1))
        if not nxt:
            return ('lock', deepest)
        level = nxt


def refine_deep(v, L, AE, AT, ew, depth=60, width=1 << 16):
    """As refine, with one more way for a branch to close: at some odd tick t its exactly known columns 1..n - t
    hold one of the kit's ether-and-wall windows of k + 13 columns, k = 6, 13, 20, 27 or 34. The kit's invariant then
    keeps the gate alternating whatever the tail. (refine knows the lock at six ether columns only, so a branch that
    enters behind a deeper wall never closes there.)"""
    level = ((v | (r << L), 20) for r in range(1 << (20 - L))) if L < 20 else [(v, L)]
    deepest = L
    while True:
        nxt = []
        for x, n in level:
            X = x; closed = False; w = None
            for t in range(1, n - 19 + 1):
                X = P.tick(X, P.alt(t - 1))
                if t % 2 == 1:
                    w = X & M
                    if any(k + 13 + t <= n and (X & ((1 << (k + 13)) - 1)) in S for k, S in ew):
                        closed = True; break
            if closed or AE[w]:
                deepest = max(deepest, n); continue
            if AT[w]:
                return ('trap branch', (x, n))
            if n >= depth:
                return ('depth', n)
            if len(nxt) >= width:
                return ('width', n)
            nxt.append((x, n + 1)); nxt.append((x | (1 << n), n + 1))
        if not nxt:
            return ('lock', deepest)
        level = nxt


def trap_tail(v, L, trap, ew, tries=3000):
    import random
    rnd = random.Random(7)
    for i in range(tries):
        tl = rnd.getrandbits(rnd.choice((8, 16, 32, 64, 128)))
        f = E.fate2(v | (tl << L), trap, ew, T=6000)
        if f[0] == 'trap':
            return tl, f[1]
    return None


def main():
    trap, table, walls = P.kit_data(sys.argv[1])
    ew19 = P.ether_wall_windows(table, walls, 6)
    AE, AT = E.attractors(trap, ew19[0] | ew19[2])
    ew = []
    for k in (6, 13, 20, 27, 34):
        e = P.ether_wall_windows(table, walls, k); ew.append((k, e[0] | e[2]))

    print('1. The seed 31 on cells 1..23.')
    r = refine(31, 23, AE, AT)
    print('   refinement: %s' % (r,))
    print('   refinement that also closes behind deeper walls: %s' % (refine_deep(31, 23, AE, AT, ew),))
    print('   a trap tail among 3000 more random tails of 8 to 128 cells: %s' % (trap_tail(31, 23, trap, ew),))
    print('   refinement with the width limit raised to 2^21 and the depth to 50: %s' % (refine(31, 23, AE, AT, 50, 1 << 21),))
    if r[0] == 'trap branch':
        x, n = r[1]
        f = E.fate2(x, trap, ew, T=8000)
        print('   the branch: cells 1..%d = %s (cell 1 first); with a white tail it is followed exactly: %s at tick %d'
              % (n, format(x, '0%db' % n)[::-1], f[0], f[1]))
        print('   so 31 on 23 cells does not force the lock, and its least forcing length is 24')

    print('2. The prefixes of 1 to 16 cells left undecided.')
    status = {(0, 0): 'trap'}; left = []
    for L in range(1, 17):
        for v in range(1 << L):
            if status[(v & ((1 << (L - 1)) - 1), L - 1)] == 'lock':
                status[(v, L)] = 'lock'; continue
            d = E.decide(v, L, AE, AT, trap, ew)[0]
            status[(v, L)] = d
            if d == 'open':
                left.append((v, L))
    print('   undecided by the follow-up: %d, at lengths %s' % (len(left), sorted(set(L for _, L in left))))
    for v, L in left:
        r = refine(v, L, AE, AT)
        extra = ''
        if r[0] == 'trap branch':
            x, n = r[1]
            f = E.fate2(x, trap, ew, T=8000)
            extra = '; that branch with a white tail: %s at tick %d' % f
        print('   %s (%d cells): %s%s' % (format(v, '0%db' % L)[::-1], L, r, extra))
        print('      closing behind deeper walls too: %s; a trap tail among 3000 more: %s'
              % (refine_deep(v, L, AE, AT, ew), trap_tail(v, L, trap, ew)))


    print('3. The other alignment: the least right half of each, and how many cells force it.')
    for code, n in ((31, 5), (112, 7)):
        X = code; ent = None
        for t in range(400):
            X = P.tick(X, P.alt(t))
            if t % 2 == 0 and X & M in (ew19[0] | ew19[2]):
                ph = 0 if X & M in ew19[0] else 2
                ent = (t + 1, X & M, ph); break
        g = P.gate(code, 2000)
        first = next(q for q in range(2000) if all(g[r + 1] != g[r] for r in range(q, 1999)))
        print('   %d: enters the lock at tick %d, window %d, the kit\'s wall phase %d there, so the ether phase is t + %d; '
              'the gate toggles from step %d and is %s at even steps'
              % (code, ent[0], ent[1], ent[2], (ent[2] - ent[0]) % 4, first, 'black' if g[first + (first % 2)] else 'white'))
        res = {}
        for L in range(n, 34):
            d = E.decide(code, L, AE, AT, trap, ew)
            if d[0] == 'open':
                r = refine(code, L, AE, AT, 50, 1 << 21)
                d = ('lock', r[1]) if r[0] == 'lock' else ('open', r)
            res[L] = d
        least = min(L for L in res if res[L][0] == 'lock')
        print('      forces the lock from %d cells (branches close by %d cells); a trap tail at every shorter length: %s; open: %s'
              % (least, res[least][1], all(res[L][0] == 'trap' for L in res if L < least), [L for L in res if res[L][0] == 'open']))


if __name__ == '__main__':
    main()
