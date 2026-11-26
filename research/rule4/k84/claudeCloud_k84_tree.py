#!/usr/bin/env python3
"""claudeCloud_k84_tree.py: white sections of the decoded west on the tree of gate words (ledger K88).

The centre is black at even ticks.  A gate word of m readings is cell 1 of a right half at ticks 1, 3, ..., 2m - 1
(first reading = highest bit).  By I246's Lean (K84FiniteSupport) the gate words of m readings correspond one to one
to the west prefixes of depth 2m + 1 that keep the centre alternating with some right half, and a west of support at
most B works through tick T exactly when the decoded prefix is white at depths B + 1 .. T.  So
    excess(T) = the longest white run ending at depth T over all decoded prefixes,   L(B) = max { T : T - excess(T) <= B }.

    census STRIP53 COUNTS         the complete census of I246 (strip candidates minus its refusals), m <= 43:
                                  counts, branching, white runs ending at each depth, step-by-step survival
    sample SAMPLE READINGS MMIN   distinct physical words of a sample file (word low high), prefixes m = MMIN..READINGS:
                                  the share white at depth 2m + 1, the runs, the longest
    rings                         the west rows of the four rings beside the alternating centre, their white runs, and
                                  truncated-ring wests replayed on the whole line
Input files are those of share-scratch/gptIntel/K84/k84-I246.zip (data/strip18-53.txt, data/counts18.jsonl,
data/sample-56.tsv, data/sample-60.tsv).  They are read as numbers only.
"""
import collections
import json
import math
import sys


def decode_west(word, ticks):
    """West depths 1..ticks (bit d - 1 = depth d) from the gate word: the sideways inverse, column by column."""
    parent = sum(1 << t for t in range(0, ticks, 2))                  # the centre, black at even ticks
    column = (1 << ticks) - 1                                         # depth 1: black at even ticks,
    for time in range(1, ticks, 2):                                   # the opposite of the reading at odd ticks
        column ^= (word >> (ticks // 2 - 1 - time // 2) & 1) << time
    west = 0
    for depth in range(ticks):
        west |= (column & 1) << depth
        parent, column = column, ((column >> 1) ^ (column | parent)) & ((1 << (ticks - depth - 1)) - 1)
    return west


def run_at(west, T):
    """Length of the white run ending at depth T."""
    r = 0
    while r < T and not (west >> (T - 1 - r)) & 1:
        r += 1
    return r


def replay_line(west_bits, right_bits, ticks):
    """Rule 30 on the whole line from a finite west (depth 1 first), a black centre and a right half (site 1 first).
    Returns the number of ticks 0..L for which the centre alternates, black at even ticks (L, or ticks if never wrong)."""
    pad = ticks + 2
    row = [0] * pad + list(reversed(west_bits)) + [1] + list(right_bits) + [0] * pad
    c = pad + len(west_bits)
    table = {(1, 1, 1): 0, (1, 1, 0): 0, (1, 0, 1): 0, (1, 0, 0): 1, (0, 1, 1): 1, (0, 1, 0): 1, (0, 0, 1): 1, (0, 0, 0): 0}
    for t in range(ticks + 1):
        if row[c] != (1 if t % 2 == 0 else 0):
            return t - 1
        row = [0] + [table[row[i - 1], row[i], row[i + 1]] for i in range(1, len(row) - 1)] + [0]
    return ticks


def load_census(strip_path, counts_path, R=53):
    upper = {int(line) for line in open(strip_path, encoding='utf-8-sig')}
    refused = {}
    for line in open(counts_path):
        rec = json.loads(line)
        if 'exact' in rec:
            refused[rec['m']] = set(int(x) for x in rec['new_refusals'])
    phys = {}
    rej = set()
    for m in range(1, 44):
        every = {w >> (R - m) for w in upper}
        ok = set(every)
        if m >= 15:
            ok = {w for w in ok if (w >> 1) not in rej} - refused.get(m, set())
            rej = every - ok
        phys[m] = ok
    return phys


def census(strip_path, counts_path):
    phys = load_census(strip_path, counts_path)
    west = {m: {w: decode_west(w, 2 * m + 1) for w in phys[m]} for m in phys}
    print('words G_m:', ' '.join('%d:%d' % (m, len(phys[m])) for m in (15, 20, 25, 30, 35, 40, 43)))
    bad = sum(1 for m in range(1, 43) for w in phys[m + 1] if west[m + 1][w] & ((1 << (2 * m + 1)) - 1) != west[m][w >> 1])
    sib = dif = 0
    for m in range(1, 43):
        for w in phys[m]:
            a, b = w << 1, (w << 1) | 1
            if a in phys[m + 1] and b in phys[m + 1]:
                sib += 1
                dif += ((west[m + 1][a] ^ west[m + 1][b]) >> (2 * m + 1)) & 1
    print('children that do not extend the parent prefix:', bad, '; sibling pairs', sib, 'of which differ at the even depth', dif)
    print('T  excess(T)  log2 G  difference')
    for m in range(15, 44):
        for T in (2 * m, 2 * m + 1):
            e = max(run_at(west[m][w] & ((1 << T) - 1), T) for w in phys[m])
            print(T, e, '%.2f' % math.log2(len(phys[m])), '%.2f' % (math.log2(len(phys[m])) - e))
    for m in (20, 30, 35, 40, 43):
        T = 2 * m + 1
        c = collections.Counter(run_at(west[m][w], T) for w in phys[m])
        n = len(phys[m])
        print('depth', T, 'words', n, 'with run >= e, e = 0..:', [sum(v for k, v in c.items() if k >= e) for e in range(max(c) + 1)])
    ev1 = collections.defaultdict(lambda: [0, 0]); ev2 = collections.defaultdict(lambda: [0, 0]); od = collections.defaultdict(lambda: [0, 0])
    for m in range(20, 43):
        T = 2 * m + 1
        for w in phys[m]:
            r = run_at(west[m][w], T)
            kids = [k for k in (w << 1, (w << 1) | 1) if k in phys[m + 1]]
            white = [k for k in kids if not (west[m + 1][k] >> T) & 1]
            tgt = ev2 if len(kids) == 2 else ev1
            tgt[r][0] += 1; tgt[r][1] += len(white)
            for k in white:
                od[r + 1][0] += 1; od[r + 1][1] += 1 - ((west[m + 1][k] >> (T + 1)) & 1)
    print('run r at an odd depth: words with one child, share whose next (even) depth is white; words with two children, the same')
    for r in sorted(set(ev1) | set(ev2)):
        a, b = ev1[r], ev2[r]
        print(r, a[0], ('%.3f' % (a[1] / a[0])) if a[0] else '-', b[0], ('%.3f' % (b[1] / b[0])) if b[0] else '-')
    print('run r at an even depth: cases, share whose next (odd, forced) depth is white')
    for r in sorted(od):
        print(r, od[r][0], '%.3f' % (od[r][1] / od[r][0]))


def sample(path, R, mmin):
    words = set()
    for line in open(path, encoding='utf-8-sig'):
        words.add(int(line.split()[0]))
    print('sampled words of', R, 'readings:', len(words))
    full = {w: decode_west(w, 2 * R + 1) for w in words}
    print('m  distinct  share white at depth 2m+1  with run >= e (e = 1..10)  expected n/2^e  longest  log2 n')
    for m in range(mmin, R + 1):
        T = 2 * m + 1
        seen = {}
        for w, west in full.items():
            seen[w >> (R - m)] = west & ((1 << T) - 1)
        n = len(seen)
        c = collections.Counter(run_at(west, T) for west in seen.values())
        cum = [sum(v for k, v in c.items() if k >= e) for e in range(1, 11)]
        print(m, n, '%.3f' % (cum[0] / n), cum, [round(n / 2 ** e, 1) for e in range(1, 11)], max(c), '%.2f' % math.log2(n))


def rings():
    for name, gaps, P in (('2', [2], 7), ('3', [3], 84), ('5', [5], 155), ('2,5', [2, 5], 728)):
        m = 2 * P + 60
        T = 2 * m + 1
        best = None
        for phase in range(sum(gaps)):
            bits = [0] * m
            s, i = phase, 0
            while s < m:
                bits[s] = 1; s += gaps[i % len(gaps)]; i += 1
            word = 0
            for b in bits:
                word = (word << 1) | b
            west = decode_west(word, T)
            row = [(west >> d) & 1 for d in range(T)]
            if not all(row[d] == row[d + P] for d in range(T - P)):
                continue                                                # this phase does not start on the ring
            starts = []
            for B in range(P):                                           # white run after depth B (depths B+1 ..)
                w = 0
                while row[B + w] == 0:
                    w += 1
                starts.append(w)
            top = max(starts)
            where = [B for B in range(P) if starts[B] == top]
            # the ring's right half: site x is the ring's column x, which is depth P - x; site P is a wall again
            right = [(1 if (x % P) == 0 else row[P - (x % P) - 1]) for x in range(1, 3 * P + 2 * top + 80)]
            checks = []
            for B in (where[0] + P, where[0] + 2 * P):
                life = replay_line(row[:B], right[:B + top + 40], B + top + 20)
                checks.append((B, life, life - B))
            if best is None or top > best[0]:
                best = (top, phase, where, checks)
            print('gate', name, 'ring of', P, 'columns, phase', phase, ': longest white run', top, 'after depths', where, '(mod %d)' % P, '; replayed (support, life, excess):', checks)


def main():
    mode = sys.argv[1]
    if mode == 'census':
        census(sys.argv[2], sys.argv[3])
    elif mode == 'sample':
        sample(sys.argv[2], int(sys.argv[3]), int(sys.argv[4]))
    elif mode == 'rings':
        rings()
    else:
        raise SystemExit(__doc__)


main()
