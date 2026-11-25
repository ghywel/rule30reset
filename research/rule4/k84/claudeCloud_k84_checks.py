#!/usr/bin/env python3
"""claudeCloud_k84_checks.py: two exact identities of ledger K84, checked on small cases.

Both are derived by hand in research/rule4/k84/README.md. Expected outcome, written before the run: every line OK.

(1) Column shift. A right half R (cells 1, 2, ...) beside a wall word d (column 0 at ticks 0..T-1). For a word g on
    ticks 0..T,
        P(column 1 = g | wall d) = 1/2 * [g(t) = 1 implies g(t+1) = not d(t)] *
                                   P(a right half beside the wall g reads d(t) xor g(t+1) at every tick t < T with g(t) = 0),
    both probabilities over fair right halves. Checked for every d and g at T = 5 (2^5 * 2^6 pairs), by enumeration.

(2) Label locality. With R(t+1) = K(W_t . R(t)), K(x)_p = x_p xor (x_{p+1} or x_{p+2}): the wall bit n ticks ago is a
    function of the present cells n, n+1, ..., and no cell before n matters. Checked by sampling: the wall bit as a
    function of the present cells n .. n+M (no conflict expected, up to the rare case that M cells do not screen), and
    as a control the same without cell n (conflicts expected for about half of the keys seen twice).
"""
import itertools, random, sys
from collections import defaultdict
from fractions import Fraction

def drive(wall, row):
    """Right half `row` (list, cell 1 first) beside `wall`; returns the list of rows, row[t] after t ticks (shrinking)."""
    rows = [row]
    for c in wall:
        x = rows[-1]
        y = [c ^ (x[0] | x[1])] + [x[i - 1] ^ (x[i] | x[i + 1]) for i in range(1, len(x) - 1)]
        rows.append(y)
    return rows

def column1(wall, row):
    return tuple(r[0] for r in drive(wall, row))

def check_shift(T=5):
    bad = 0; n = 0
    cells = T + 2                                    # column 1 at tick t reads cells 1..t+1; one spare
    dist = {}
    for d in itertools.product((0, 1), repeat=T):
        cnt = defaultdict(int)
        for R in itertools.product((0, 1), repeat=cells):
            cnt[column1(d, list(R))] += 1
        dist[d] = cnt
    for d in itertools.product((0, 1), repeat=T):
        for g in itertools.product((0, 1), repeat=T + 1):
            lhs = Fraction(dist[d].get(g, 0), 2 ** cells)
            ok = all(not g[t] or g[t + 1] == 1 - d[t] for t in range(T))
            if not ok:
                rhs = Fraction(0)
            else:
                # readings of column 1 of a fresh right half beside the wall g[0..T-1], at ticks t < T with g(t) = 0
                want = {t: d[t] ^ g[t + 1] for t in range(T) if g[t] == 0}
                hit = 0
                for R in itertools.product((0, 1), repeat=cells):
                    col = column1(g[:T], list(R))
                    if all(col[t] == v for t, v in want.items()):
                        hit += 1
                rhs = Fraction(hit, 2 ** cells) / 2
            n += 1
            if lhs != rhs:
                bad += 1
    print('column shift, T = %d: %d pairs (d, g), %d disagree: %s' % (T, n, bad, 'OK' if bad == 0 else 'FAILED'))
    return bad == 0

def check_locality(n=6, M=40, samples=200000, seed=84):
    rng = random.Random(seed)
    width = n + M + n + 4
    with_n = {}; without_n = {}
    conflicts = conflicts_ctl = repeats_ctl = 0
    for _ in range(samples):
        wall = [rng.getrandbits(1) for _ in range(n)]
        bits = rng.getrandbits(width)
        row = [(bits >> i) & 1 for i in range(width)]
        now = drive(wall, row)[-1]                    # the present right half, cell 1 first
        key = tuple(now[n - 1: n - 1 + M + 1])        # cells n .. n+M
        if with_n.setdefault(key, wall[0]) != wall[0]:
            conflicts += 1
        k2 = key[1:13]                                # control: cells n+1 .. n+12 only (short, so keys repeat)
        if k2 in without_n:
            repeats_ctl += 1
            if without_n[k2] != wall[0]:
                conflicts_ctl += 1
        else:
            without_n[k2] = wall[0]
    # a sharper form of the same statement: flip any present cell before n and redo the decoding from the present
    print('label locality, n = %d: %d samples, %d conflicts with cells n..n+%d: %s' %
          (n, samples, conflicts, M, 'OK' if conflicts == 0 else 'FAILED'))
    share = conflicts_ctl / max(1, repeats_ctl)
    print('   control without cell n (12 cells): %d repeated keys, %d conflicts (share %.3f, about 0.5 expected): %s' %
          (repeats_ctl, conflicts_ctl, share, 'OK' if 0.4 < share < 0.6 else 'FAILED'))
    return conflicts == 0 and 0.4 < share < 0.6

def check_two_to_one(T=4, cells=10, samples=50000, seed=85):
    """The backward right-half map: K(0.R') and K(1.R') are the two present rows above R', and they differ at cell 1
    only in the sense that the decoded wall bit differs: checks that from the present row the previous row and wall
    bit are recovered (decoding from the right) whenever a screen is in range."""
    rng = random.Random(seed); bad = tried = 0
    for _ in range(samples):
        w = rng.getrandbits(1); width = 60
        bits = rng.getrandbits(width); prev = [(bits >> i) & 1 for i in range(width)]
        now = drive([w], prev)[-1]                    # cells 1..width-2 of the present row
        # decode x = (w, prev) from y = now: x_p = y_{p+1}... in driven form: now[i] = x[i] ^ (x[i+1] | x[i+2]), x = [w] + prev
        m = len(now)
        # find a screen: positions where the preimage is forced whatever lies to the right; try both seeds at the far end
        sols = set()
        for a, b in itertools.product((0, 1), repeat=2):
            x = [0] * (m + 2); x[m] = a; x[m + 1] = b
            for i in range(m - 1, -1, -1):
                x[i] = now[i] ^ (x[i + 1] | x[i + 2])
            sols.add(tuple(x[:cells]))
        tried += 1
        if len(sols) != 1 or list(sols)[0] != tuple(([w] + prev)[:cells]):
            bad += 1
    print('decoding from the right: %d rows, %d not unique or wrong in the first %d cells (the far end is %d cells away): %s'
          % (tried, bad, cells, 58, 'OK' if bad == 0 else 'FAILED'))
    return bad == 0

if __name__ == '__main__':
    ok = check_shift() & check_locality() & check_two_to_one()
    print('ALL OK' if ok else 'SOME FAILED'); sys.exit(0 if ok else 1)
