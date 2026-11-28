#!/usr/bin/env python3
"""claudeCloud_collision_words.py: the first repeated western snapshot at each width, and whether it is special
(ledger K105, pull I295.4).  Development analysis after the frozen run claudeCloud_snapshots.c.

    python3 claudeCloud_collision_words.py SNAPSHOTS.txt T

Recomputes the single seed to age T (big integers, cell by cell from the rule), reads the first repeat (b, a) of each
width from the frozen output, and prints the repeated word, its black count and its longest run, beside the mean and
the 5th to 95th percentiles of the same two statistics over all ages w .. T.
"""
import sys


def snapshots(T):
    x, out = 1, []                    # bit p is site p - T - 2
    off = T + 2
    x <<= off
    for t in range(T + 1):
        out.append(sum(((x >> (off - i)) & 1) << i for i in range(64)))
        x = (x << 1) ^ (x | (x >> 1))
    return out


def longest_run(v, n):
    best = cur = 0
    last = None
    for i in range(n):
        b = (v >> i) & 1
        cur = cur + 1 if b == last else 1
        last = b
        best = max(best, cur)
    return best


def main():
    path, T = sys.argv[1], int(sys.argv[2])
    snap = snapshots(T)
    print('w | ages a, b | word (site 0 first) | black | longest run | all ages: black mean (5%-95%) | run mean (5%-95%)')
    for l in open(path):
        p = [x.strip() for x in l.split('|')]
        if len(p) != 7 or not p[0].isdigit():
            continue
        w = int(p[0]); b, a, _ = map(int, p[3].split())
        if b < 0 or b > T or w < 17:
            continue
        m = (1 << (w + 1)) - 1
        v = snap[a] & m
        assert v == snap[b] & m
        bl = [bin(snap[t] & m).count('1') for t in range(w, T + 1)]
        rl = [longest_run(snap[t] & m, w + 1) for t in range(w, T + 1, 7)]
        q = lambda xs, f: sorted(xs)[int(f * (len(xs) - 1))]
        print('%d | %d, %d | %s | %d | %d | %.1f (%d-%d) | %.1f (%d-%d)' % (
            w, a, b, ''.join(str((v >> i) & 1) for i in range(w + 1)), bin(v).count('1'), longest_run(v, w + 1),
            sum(bl) / len(bl), q(bl, .05), q(bl, .95), sum(rl) / len(rl), q(rl, .05), q(rl, .95)))


main()
