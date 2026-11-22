#!/usr/bin/env python3
"""claudeCloud_m9_sieve.py: pull M9 (ledger K60). The sieve of K56, run to the end: every word of two, three or four
runs that real trapped rows never start late although the shorter words inside it do, with what chance would give.

Input: the word tables written by claudeCloud_m9_real_rows.cpp, any number of cohorts, pooled. "Late" is a delay of
100 samples or more since entry (the tables' late100 column).

A word is a CANDIDATE when its late count is zero and
    2 runs (a, b):        E = N(a .) N(. b) / N                      is at least THRESHOLD;
    3 runs (a, b, c):     (a, b) and (b, c) occur late, and
                          E = N(a, b) N(b, c) / N(b .)               is at least THRESHOLD;
    4 runs (a, b, c, d):  (a, b, c) and (b, c, d) occur late, and
                          E = N(a, b, c) N(b, c, d) / N(b, c)        is at least THRESHOLD.
N(a .) and N(. b) are the first and second marginals of the pair table, N its total. So a candidate's absence is
not explained by a shorter absent word: each is minimal among the absent words of the tables.

    python3 claudeCloud_m9_sieve.py THRESHOLD OUT.json PREFIX [PREFIX ...]
Writes OUT.json: a list of {word, runs, gaps, samples, expected, seen_total, last_delay}, sorted by length and
then by expected count; prints a summary.
"""
import json, sys
from collections import defaultdict


def load(prefixes, n):
    T = defaultdict(lambda: [0, 0, None, None])          # total, late, first delay, last delay
    for p in prefixes:
        with open('%s.words%d.tsv' % (p, n)) as f:
            next(f)
            for line in f:
                q = line.split('\t'); w = tuple(int(x) for x in q[0].split(','))
                t = T[w]; t[0] += int(q[1]); t[1] += int(q[2])
                a, b = int(q[3]), int(q[4])
                t[2] = a if t[2] is None else min(t[2], a); t[3] = b if t[3] is None else max(t[3], b)
    return T


def main():
    threshold = float(sys.argv[1]); out = sys.argv[2]; prefixes = sys.argv[3:]
    P2, P3, P4 = load(prefixes, 2), load(prefixes, 3), load(prefixes, 4)
    first, second = defaultdict(int), defaultdict(int)
    for (a, b), t in P2.items():
        first[a] += t[1]; second[b] += t[1]
    N = sum(first.values())
    runs = sorted(r for r in first if first[r])
    cands = []

    def add(w, e, T):
        t = T.get(w, [0, 0, None, None])
        cands.append(dict(word=','.join(map(str, w)), runs=len(w), gaps=len(w) + 1 + sum(w),
                          samples=3 * (len(w) + 1) + 5 * sum(w), expected=round(e, 1), seen_total=t[0], last_delay=t[3]))

    for a in runs:
        for b in runs:
            if P2.get((a, b), [0, 0])[1] == 0:
                e = first[a] * second[b] / N
                if e >= threshold:
                    add((a, b), e, P2)
    late2 = {w: t[1] for w, t in P2.items() if t[1]}
    late3 = {w: t[1] for w, t in P3.items() if t[1]}
    succ2 = defaultdict(list)
    for (b, c), n in late2.items():
        succ2[b].append((c, n))
    for (a, b), n1 in late2.items():
        for c, n2 in succ2[b]:
            if P3.get((a, b, c), [0, 0])[1] == 0:
                e = n1 * n2 / first[b]
                if e >= threshold:
                    add((a, b, c), e, P3)
    succ3 = defaultdict(list)
    for (b, c, d), n in late3.items():
        succ3[(b, c)].append((d, n))
    for (a, b, c), n1 in late3.items():
        for d, n2 in succ3[(b, c)]:
            if P4.get((a, b, c, d), [0, 0])[1] == 0:
                e = n1 * n2 / late2[(b, c)]
                if e >= threshold:
                    add((a, b, c, d), e, P4)
    cands.sort(key=lambda c: (c['runs'], -c['expected']))
    json.dump(cands, open(out, 'w'), indent=0)
    print('pooled: %d late pairs, %d distinct late pairs, %d triples, %d quadruples' % (N, len(late2), len(late3), sum(1 for t in P4.values() if t[1])))
    for k in (2, 3, 4):
        cs = [c for c in cands if c['runs'] == k]
        print('candidates of %d runs with %g or more expected: %d; by duration in samples: up to 100: %d, 101 to 140: %d, 141 to 180: %d, longer: %d'
              % (k, threshold, len(cs), sum(c['samples'] <= 100 for c in cs), sum(100 < c['samples'] <= 140 for c in cs),
                 sum(140 < c['samples'] <= 180 for c in cs), sum(c['samples'] > 180 for c in cs)))
    print('with a run of 1: %d of %d' % (sum('1' in c['word'].split(',') for c in cands), len(cands)))


if __name__ == '__main__':
    main()
