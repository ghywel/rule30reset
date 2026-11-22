#!/usr/bin/env python3
"""claudeCloud_ether_lock_exact.py: pull K50.1 (ledger K66, addendum 1). Follow-up to claudeCloud_ether_lock.py.

That probe left three things short of exact:
  - its part F certified the ether-and-wall lock only in one of its two time alignments (the alternating column is
    ether column B4, whose period is 2, so the ether's phase can be t + 1 or t + 3), and left 893 right halves below
    2^16 as "gate period 2, not certified";
  - its part E proved forcing only when one exact window lay in the forced set, and left lengths 23 to 25 (seed 31)
    and 20 to 21 (seed 495) open;
  - its part D is sound for forcing and not complete, so "no prefix of 13 cells forces the lock" was not shown.

Here forcing is decided from both sides.
  - NOT forcing: an explicit tail whose right half, followed exactly, enters the gate trap. The trap is closed, so
    that right half never has an alternating gate. Tried: the white tail, a few fixed tails and 60 fixed random ones.
  - Forcing: refinement. A prefix of n >= 20 cells fixes the window of 19 columns at every odd tick t <= n - 19. If
    that window is forced into the lock (every path of the window graph with free outer cells reaches the kit's
    ether-and-wall windows), every right half with the prefix ends in the lock. Otherwise the prefix is split by
    its next cell. The prefix forces the lock when every branch closes this way.
  - A prefix with no trap tail found and a branch still open at the limits is reported as open, never guessed.

Parts
  A  Control: the three seeds at the lengths the first probe settled (31 at 22 and 26, 495 at 19 and 22, 175 at 23
     and 24) must come out the same.
  B  The exact least forcing length of each seed padded with white.
  C  Every prefix of 1 to 16 cells, decided exactly: the minimal forcing prefixes by length.
  D  Every right half below 2^16 (white tail), certified in either alignment: its window of k + 13 columns is one
     of the kit's ether-and-wall windows, k = 6, 13, 20, 27, 34, at an odd tick, whatever the phase.

    python3 claudeCloud_ether_lock_exact.py KIT_LEAN_DIR
"""
import random
import sys
import time

import numpy as np

import claudeCloud_ether_lock as P

W = 19
M = (1 << W) - 1
DEPTH = 46            # prefixes are refined to at most this many cells
WIDTH = 1 << 15       # and to at most this many open branches
_r = random.Random(20261122)
TAILS = [0, 1, 3, (1 << 64) - 1] + [_r.getrandbits(64) for _ in range(60)]


def attractors(trap, K19):
    s = np.arange(1 << W, dtype=np.uint32)
    succ = []
    for x1 in (0, 1):
        for x2 in (0, 1):
            Y = s | np.uint32(x1 << W) | np.uint32(x2 << (W + 1))
            Y1 = ((Y << np.uint32(1)) ^ (Y | (Y >> np.uint32(1)))) & np.uint32((1 << (W + 1)) - 1)
            succ.append((((Y1 << np.uint32(1)) | np.uint32(1)) ^ (Y1 | (Y1 >> np.uint32(1)))) & np.uint32(M))

    def attractor(target):
        A = target.copy()
        while True:
            B = A | (A[succ[0]] & A[succ[1]] & A[succ[2]] & A[succ[3]])
            if (B == A).all():
                return A
            A = B
    inK = np.zeros(1 << W, dtype=bool); inK[list(K19)] = True
    inT = np.zeros(1 << 16, dtype=bool); inT[list(trap)] = True
    return attractor(inK), attractor(inT[s & np.uint32(0xFFFF)])


def fate2(code, trap, ew, T=4000):
    """'trap' | 'lock' | 'none' for the right half `code` with a white tail, followed exactly for T ticks. The lock is
    certified in either alignment: the window of k + 13 columns is one of the kit's ether-and-wall windows."""
    X = code
    for t in range(T):
        X = P.tick(X, P.alt(t))
        if t % 2 == 0:
            if X & 0xFFFF in trap:
                return 'trap', t + 1
            for k, S in ew:
                if X & ((1 << (k + 13)) - 1) in S:
                    return 'lock', t + 1
    return 'none', T


def decide(v, L, AE, AT, trap, ew):
    """('trap', (tail, tick)): the right half v with that tail from cell L + 1 on enters the gate trap, so the prefix
    does not force the lock. ('lock', n): every right half with the prefix ends in the lock, shown by refinement to
    at most n cells. ('open', None) otherwise."""
    for tl in TAILS:
        f = fate2(v | (tl << L), trap, ew)
        if f[0] == 'trap':
            return ('trap', (tl, f[1]))
    level = ((v | (r << L), 20) for r in range(1 << (20 - L))) if L < 20 else [(v, L)]
    deepest = L
    while True:
        nxt = []
        for x, n in level:
            t = n - 19 if (n - 19) % 2 == 1 else n - 20
            w = P.row_at(x, t) & M
            if AE[w]:
                deepest = max(deepest, n); continue
            if AT[w] or n >= DEPTH or len(nxt) >= WIDTH:
                return ('open', None)
            nxt.append((x, n + 1)); nxt.append((x | (1 << n), n + 1))
        if not nxt:
            return ('lock', deepest)
        level = nxt


def main():
    t0 = time.time()
    trap, table, walls = P.kit_data(sys.argv[1])
    ew19 = P.ether_wall_windows(table, walls, 6)
    K19 = ew19[0] | ew19[2]
    AE, AT = attractors(trap, K19)
    ew = []
    for k in (6, 13, 20, 27, 34):
        e = P.ether_wall_windows(table, walls, k)
        ew.append((k, e[0] | e[2]))
    print('forced windows at 19 columns: lock %d, trap %d (the first probe: 2581 and 239834)' % (AE.sum(), AT.sum()))

    print('A. Control: the lengths the first probe settled.')
    for code, L, want in ((31, 22, 'trap'), (31, 26, 'lock'), (495, 19, 'trap'), (495, 22, 'lock'), (175, 23, 'trap'),
                          (175, 24, 'lock')):
        r = decide(code, L, AE, AT, trap, ew)
        print('   %d on cells 1..%d: %s (expected %s)' % (code, L, r[0], want))

    print('B. The exact least forcing length of each seed.')
    for code, n in ((31, 5), (495, 9), (175, 8)):
        res = {L: decide(code, L, AE, AT, trap, ew) for L in range(n, 30)}
        least = min((L for L in res if res[L][0] == 'lock'), default=None)
        opens = [L for L in res if res[L][0] == 'open']
        print('   %d: forces the lock from %s cells; a trap tail at every shorter length: %s; open: %s'
              % (code, least, all(res[L][0] == 'trap' for L in res if least is None or L < least), opens))
        if least is not None and least > n and res[least - 1][0] == 'trap':
            tl, tk = res[least - 1][1]
            print('      at %d cells: the tail %d (cells from %d on) enters the trap at tick %d' % (least - 1, tl, least, tk))
        if least is not None:
            print('      at %d cells the last branch closes at %d cells' % (least, res[least][1]))

    print('C. Every prefix of 1 to 16 cells.')
    counts = []; opens = 0; listing = {}
    status = {(0, 0): decide(0, 0, AE, AT, trap, ew)[0]}
    for L in range(1, 17):
        mins = []
        for v in range(1 << L):
            parent = status[(v & ((1 << (L - 1)) - 1), L - 1)]
            if parent == 'lock':
                status[(v, L)] = 'lock'; continue
            r = decide(v, L, AE, AT, trap, ew)[0]
            status[(v, L)] = r
            if r == 'lock':
                mins.append(v)
            elif r == 'open':
                opens += 1
        counts.append(len(mins)); listing[L] = mins
        print('   length %2d: %d minimal forcing prefixes%s' % (L, len(mins), (': ' + ', '.join(
            format(v, '0%db' % L)[::-1] for v in mins[:16])) if 0 < len(mins) <= 16 else ''), flush=True)
    print('   minimal forcing prefixes by length 1..16: %s; undecided prefixes: %d' % (counts, opens))
    print('   the first probe\'s sound count for lengths 14, 15, 16 was 2, 12, 46')
    print('   their measure through 16 cells: %.6f%%' % (100 * sum(c / 2.0 ** (i + 1) for i, c in enumerate(counts))))

    print('D. Every right half below 2^16, either alignment.')
    kinds = {}; least = {}
    for code in range(1 << 16):
        f = fate2(code, trap, ew, T=8000)
        key = f[0]
        if key == 'none':
            g = P.gate(code, 4000)[-600:]
            per = next((p for p in range(1, 200) if all(g[i] == g[i + p] for i in range(len(g) - p))), None)
            key = 'neither by tick 8000, gate period %s' % per
        kinds[key] = kinds.get(key, 0) + 1; least.setdefault(key, code)
    for key in sorted(kinds):
        print('   %-40s %6d   least code %d' % (key, kinds[key], least[key]))
    print('time %.0f s' % (time.time() - t0))


if __name__ == '__main__':
    main()
