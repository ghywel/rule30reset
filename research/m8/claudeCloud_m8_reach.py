#!/usr/bin/env python3
"""claudeCloud_m8_reach.py: pull M8, first block (ledger K40). Does Theta's reach stay bounded inside the gap language?

Frame (kit Rule30LinearCharts, Rule30PrefixMerger). Depth d >= 1 counts cells away from a white wall at depth 0.
Rule 30 beside the wall: z(t+1, d) = z(t, d+1) xor (z(t, d) or z(t, d-1)). A constrained row has depth 1 black at
every even tick; its free bits are f_s = z(2s+1, 1). Theta(f) is the row at tick 0. Solving the rule for the deeper
cell, z(t, d+1) = z(t+1, d) xor (z(t, d) or z(t, d-1)), the row to depth D = 2L + 1 follows from f_0 .. f_(L-1).

REACH of free bit s in the word f: the deepest depth <= D at which Theta(f) and Theta(f with bit s flipped) differ.
Bit s enters at depth 2s + 2, always. "Beyond entry" is reach - (2s + 2).

GAP LANGUAGE: white free bits (zeros of f) 3 or 5 apart. A gap word of length L is a factor: its first zero is at
index <= 4 and its last at index >= L - 5.

MEMORY inside the language: for two gap words that agree from index m on, the deepest depth at which their rows
differ, less 2m (the deepest entry of the bits that differ is 2m).

  python3 claudeCloud_m8_reach.py check                 controls (see the function)
  python3 claudeCloud_m8_reach.py gap L SMAX            every gap word of length L: reach of bits 0..SMAX
  python3 claudeCloud_m8_reach.py random L SMAX N P     N random words, each bit black with chance P (seeded)
  python3 claudeCloud_m8_reach.py memory L M...         memory inside the language for each m
  python3 claudeCloud_m8_reach.py hybrid L SMAX         the 90/150 hybrid wall (kit Rule30HybridWall): reach of a flip
"""
import json
import random
import statistics
import sys
from collections import Counter, defaultdict


def column(f, L):
    """Depth-1 column as an int: bit 2s = 1 (black at even ticks), bit 2s+1 = f_s. Ticks 0 .. 2L."""
    c = 0
    for s in range(L):
        c |= 1 << (2 * s)
        if (f >> s) & 1:
            c |= 1 << (2 * s + 1)
    return c | (1 << (2 * L))


def theta(f, L, hybrid=False):
    """The row at tick 0 as an int: bit d = depth d, for d = 1 .. 2L + 1."""
    D = 2 * L + 1
    prev, cur = 0, column(f, L)
    row = (cur & 1) << 1
    for d in range(1, D):
        if hybrid:      # H x k = x(k+1) xor x(k-1) [k >= 2] xor (x k if k odd)
            nxt = (cur >> 1) ^ prev ^ (cur if d % 2 == 1 else 0)
        else:
            nxt = (cur >> 1) ^ (cur | prev)
        prev, cur = cur, nxt
        row |= (cur & 1) << (d + 1)
    return row


def forward_column(row, D, hybrid=False):
    """Run the row forward beside the white wall; return the depth-1 cell at ticks 0 .. D - 1 as an int."""
    col = 0
    x = row            # bit d = depth d; bit 0 = the wall, white
    for t in range(D):
        col |= ((x >> 1) & 1) << t
        if hybrid:
            odd = sum(1 << d for d in range(1, D + 2, 2))
            x = ((x >> 1) ^ (x << 1) ^ (x & odd)) & ~1
        else:
            x = ((x >> 1) ^ (x | (x << 1))) & ~1
        x &= (1 << (D + 1 - t)) - 1      # cells the unknown deeper part could have touched are dropped
    return col


def gap_words(L):
    """Every factor of length L of the gap language, as ints (bit s = f_s; 0 = white)."""
    out = []
    full = (1 << L) - 1

    def rec(pos, w):            # pos = index of the last zero placed
        if pos >= L - 5:
            out.append(w)
        for g in (3, 5):
            if pos + g < L:
                rec(pos + g, w & ~(1 << (pos + g)))
    for first in range(min(5, L)):
        rec(first, full & ~(1 << first))
    if L <= 4:
        out.append(full)
    return sorted(set(out))


def reach(f, L, s, hybrid=False, base=None):
    if base is None:
        base = theta(f, L, hybrid)
    return (base ^ theta(f ^ (1 << s), L, hybrid)).bit_length() - 1


def summary(xs, D_room):
    """xs: reach beyond entry. D_room: the room beyond entry up to the depth limit."""
    xs = sorted(xs)
    n = len(xs)
    return {'n': n, 'min': xs[0], 'q25': xs[n // 4], 'median': statistics.median(xs), 'q75': xs[(3 * n) // 4],
            'max': xs[-1], 'room': D_room, 'at_limit': sum(1 for x in xs if x >= D_room - 9) / n,
            'le6': sum(1 for x in xs if x <= 6) / n, 'le30': sum(1 for x in xs if x <= 30) / n}


def run_words(words, L, smax, label):
    D = 2 * L + 1
    per = {(s, v): [] for s in range(smax + 1) for v in (0, 1)}
    worst = {}
    for f in words:
        base = theta(f, L)
        for s in range(smax + 1):
            x = reach(f, L, s, base=base) - (2 * s + 2)
            v = (f >> s) & 1
            per[(s, v)].append(x)
            if (s, v) not in worst or x > worst[(s, v)][0]:
                worst[(s, v)] = (x, f)
    print('%s: %d words of length %d, depth limit %d' % (label, len(words), L, D))
    print('  s bit        n   min   q25 median   q75   max  room  share<=6 share<=30 share at limit')
    res = []
    for s in range(smax + 1):
        for v in (0, 1, 2):
            xs = per[(s, 0)] + per[(s, 1)] if v == 2 else per[(s, v)]
            if not xs:
                continue
            m = summary(xs, D - (2 * s + 2))
            m.update({'s': s, 'bit': 'white' if v == 0 else 'black' if v == 1 else 'all', 'label': label, 'L': L})
            if v < 2:
                m['worst_word'] = ''.join(str((worst[(s, v)][1] >> i) & 1) for i in range(L))
            res.append(m)
            print(' %2d %-5s %8d %5d %5d %6.1f %5d %5d %5d   %6.4f    %6.4f    %6.4f' % (
                s, m['bit'], m['n'], m['min'], m['q25'], m['median'], m['q75'], m['max'], m['room'], m['le6'],
                m['le30'], m['at_limit']))
    return res


def memory(L, ms):
    D = 2 * L + 1
    words = gap_words(L)
    rows = {f: theta(f, L) for f in words}
    res = []
    print('memory inside the gap language: %d words of length %d, depth limit %d' % (len(words), L, D))
    print('   m   groups    pairs   min median   max  room  share<=6 share<=30 share at limit')
    for m in ms:
        groups = defaultdict(list)
        for f in words:
            groups[f >> m].append(f)
        xs = []
        for g in groups.values():
            for i in range(len(g)):
                for j in range(i + 1, len(g)):
                    xs.append((rows[g[i]] ^ rows[g[j]]).bit_length() - 1 - 2 * m)
        sm = summary(xs, D - 2 * m)
        sm.update({'m': m, 'groups': len(groups), 'L': L, 'label': 'memory'})
        res.append(sm)
        print(' %3d %8d %8d %5d %6.1f %5d %5d   %6.4f    %6.4f    %6.4f' % (
            m, len(groups), sm['n'], sm['min'], sm['median'], sm['max'], sm['room'], sm['le6'], sm['le30'],
            sm['at_limit']))
    return res


def check():
    ok = True
    rng = random.Random(8)
    # 1. Theta's row, run forward beside the wall, gives back the column: black at even ticks, f at odd ticks.
    for hybrid in (False, True):
        for _ in range(300):
            L = rng.randrange(1, 30)
            f = rng.getrandbits(L)
            D = 2 * L + 1
            good = forward_column(theta(f, L, hybrid), D, hybrid) == column(f, L) & ((1 << D) - 1)
            ok &= good
        print('1. forward run returns the column (%s): %s' % ('hybrid' if hybrid else 'rule 30', ok))
    # 2. The kit's merger: with free bits 1 and 2 black, free bit 0 changes only depths 1..6; depth 2 always.
    L = 16
    worst = 0
    for f in range(1 << L):
        if (f >> 1) & 3 == 3:
            worst = max(worst, reach(f, L, 0))
    print('2. f1 = f2 = black: free bit 0 reaches at most depth %d (kit: 6): %s' % (worst, worst == 6))
    ok &= worst == 6
    # 3. viz/reach.py over all 2^20 words to depth 41: P(R_0 >= 8, 16, 24, 32) = 0.625, 0.234, 0.098, 0.038, and
    #    f0 still reaches depth 41 in 0.9% of words. Here over all 2^16 words extended by 4 random bits 16 times.
    L = 20
    cnt = Counter()
    n = 0
    for lo in range(1 << 14):
        for _ in range(4):
            f = lo | (rng.getrandbits(6) << 14)
            r = reach(f, L, 0)
            n += 1
            for k in (8, 16, 24, 32, 41):
                cnt[k] += r >= k
    got = [round(cnt[k] / n, 3) for k in (8, 16, 24, 32, 41)]
    print('3. P(R_0 >= 8, 16, 24, 32, 41) =', got, ' recorded: 0.625, 0.234, 0.098, 0.038, 0.009')
    ok &= all(abs(a - b) < 0.012 for a, b in zip(got, (0.625, 0.234, 0.098, 0.038, 0.009)))
    # 4. gap words: every zero has gaps 3 or 5 to the next, and the count follows a(L) = a(L-3) + a(L-5).
    counts = [len(gap_words(L)) for L in range(6, 40)]
    rec = all(counts[i] == counts[i - 3] + counts[i - 5] for i in range(5, len(counts)))
    w = gap_words(24)
    legal = all(all(b - a in (3, 5) for a, b in zip(z, z[1:])) and z[0] <= 4 and z[-1] >= 19
                for z in ([i for i in range(24) if not (f >> i) & 1] for f in w))
    print('4. gap words: %d of length 24, legal: %s; counts obey a(L) = a(L-3) + a(L-5): %s' % (len(w), legal, rec))
    ok &= legal and rec
    print('CONTROLS:', 'PASS' if ok else 'FAIL')
    return ok


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[0] == 'check':
        sys.exit(0 if check() else 1)
    if a[0] == 'gap':
        L, smax = int(a[1]), int(a[2])
        res = run_words(gap_words(L), L, smax, 'gap language')
    elif a[0] == 'random':
        L, smax, n, p = int(a[1]), int(a[2]), int(a[3]), float(a[4])
        rng = random.Random(30)
        words = [sum((rng.random() < p) << i for i in range(L)) for _ in range(n)]
        res = run_words(words, L, smax, 'random, black with chance %g' % p)
    elif a[0] == 'memory':
        res = memory(int(a[1]), [int(x) for x in a[2:]])
    elif a[0] == 'hybrid':
        L, smax = int(a[1]), int(a[2])
        D = 2 * L + 1
        rng = random.Random(150)
        res = []
        for s in range(smax + 1):
            rs = {reach(rng.getrandbits(L), L, s, hybrid=True) for _ in range(50)}
            print('hybrid: bit %2d enters at depth %d; over 50 random words its reach is %s (limit %d)' % (
                s, 2 * s + 2, sorted(rs), D))
            res.append({'label': 'hybrid', 's': s, 'reach': sorted(rs), 'limit': D})
    print('JSON ' + json.dumps(res))
