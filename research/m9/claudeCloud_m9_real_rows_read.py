#!/usr/bin/env python3
"""claudeCloud_m9_real_rows_read.py: reads the outputs of claudeCloud_m9_real_rows.cpp (pull M9, ledger K55).

    python3 claudeCloud_m9_real_rows_read.py OUT [OUT ...]      chunks of one cohort; they are added together

A: the share of runs that are even (length 4, 6, 8, ...). B: the share of windows of four consecutive runs with two
or more even runs. Both by delay since entry. The verdict rule, fixed before the run:
    early bin: delays 100 to 199. Late bin: the last bin that ends at or before S.
    "die out" if B_late / B_early < 0.5; "flat" if it is within 0.10 of 1; otherwise "drifting".
The spread is the standard error over the 20 groups of rows (row index mod 20).
"""
import math, sys
from collections import defaultdict

# K54: run words computed UNSAT, with the smallest delay P at which UNSAT was computed. UNSAT at P means the word
# never starts P or more samples after entry.
FORBIDDEN = {
    (1, 1, 1): 0, (4, 4, 4, 4): 2, (4, 4, 4, 6): 5, (4, 4, 4, 8): 6, (4, 4, 4, 10): 6, (4, 4, 4, 12): 6,
    (4, 5, 5, 6): 20, (4, 5, 6, 4): 20, (4, 5, 6, 6): 20, (4, 6, 4, 4): 20, (5, 4, 4, 6): 20, (5, 4, 6, 4): 20,
    (5, 4, 6, 6): 20, (5, 5, 4, 4): 20, (5, 5, 6, 4): 6, (5, 5, 6, 6): 6, (5, 6, 4, 4): 6, (5, 6, 4, 6): 6,
    (5, 6, 4, 8): 6, (6, 4, 4, 6): 20, (6, 4, 6, 4): 6, (6, 4, 6, 6): 6, (6, 5, 4, 4): 6, (6, 6, 4, 4): 6,
    (7, 6, 4, 4): 5,
}


def read(prefixes):
    head, bins, groups, hist = None, defaultdict(lambda: [0] * 15), defaultdict(lambda: [0] * 4), defaultdict(lambda: [0] * 64)
    tot = defaultdict(int); entry = []; maxrun = 0
    tables = {2: {}, 3: {}, 4: {}}; edges = {}
    for p in prefixes:
        lines = open(p + '.summary.txt').read().split('\n')
        h = lines[0].split(); d = dict(zip(h[0::2], h[1::2]))
        key = (d['mode'], d['N'], d['S'], d['base'])
        assert head in (None, key), 'chunks of different cohorts'
        head = key; tot['rows'] += int(d['rows']); tot['seconds'] += float(d['seconds'])
        e = lines[1].split(); tot['entered'] += int(e[1]); tot['not_entered'] += int(e[3])
        if len(e) > 4:
            entry.append((int(e[1]), int(e[5]), int(e[7]), int(e[9]), int(e[11])))
        k = lines[2].split(); kd = dict(zip(k[0::2], k[1::2]))
        for name in ('kicks', 'gaps3', 'gaps5', 'censored_windows', 'rows_without_3gap_in_margin'):
            tot[name] += int(kd[name])
        maxrun = max(maxrun, int(kd['max_run'])); tot['max_trailing'] = max(tot['max_trailing'], int(kd['max_trailing_5gaps']))
        for ln in lines[3:]:
            f = ln.split()
            if not f:
                continue
            if f[0] == 'BIN':
                lo = int(f[1]); edges[lo] = int(f[2])
                for i, x in enumerate(f[3:]):
                    bins[lo][i] += int(x)
            elif f[0] == 'GROUP':
                g = groups[(int(f[1]), int(f[2]))]
                for i, x in enumerate(f[3:]):
                    g[i] += int(x)
            elif f[0] == 'HIST' and f[1].lstrip('-').isdigit():
                for i, x in enumerate(f[2:]):
                    hist[int(f[1])][i] += int(x)
        for n in (2, 3, 4):
            with open('%s.words%d.tsv' % (p, n)) as fh:
                cols = next(fh).rstrip('\n').split('\t')
                for ln in fh:
                    q = ln.rstrip('\n').split('\t'); w = tuple(int(x) for x in q[0].split(','))
                    v = [int(x) for x in q[1:]]
                    t = tables[n].get(w)
                    if t is None:
                        tables[n][w] = v
                    else:
                        t[0] += v[0]; t[1] += v[1]; t[2] = min(t[2], v[2]); t[3] = max(t[3], v[3]); t[4] += v[4]
                        for i in range(5, len(v)):
                            t[i] += v[i]
                if n == 4:
                    bincols = [int(c[3:]) for c in cols[6:]]
    return head, tot, entry, maxrun, bins, edges, groups, hist, tables, bincols


def spread(groups, lo, num, den):
    xs = [groups[(g, lo)][num] / groups[(g, lo)][den] for g in range(20) if groups.get((g, lo)) and groups[(g, lo)][den]]
    if len(xs) < 2:
        return float('nan')
    m = sum(xs) / len(xs)
    return math.sqrt(sum((x - m) ** 2 for x in xs) / (len(xs) - 1) / len(xs))


def ratio_spread(groups, lo1, lo2, num, den):
    xs = []
    for g in range(20):
        a, b = groups.get((g, lo1)), groups.get((g, lo2))
        if a and b and a[den] and b[den] and a[num]:
            xs.append((b[num] / b[den]) / (a[num] / a[den]))
    if len(xs) < 2:
        return float('nan')
    m = sum(xs) / len(xs)
    return math.sqrt(sum((x - m) ** 2 for x in xs) / (len(xs) - 1) / len(xs))


def entropy(counts):
    n = sum(counts)
    return -sum(c / n * math.log2(c / n) for c in counts if c) if n else 0.0


def main():
    head, tot, entry, maxrun, bins, edges, groups, hist, tables, bincols = read(sys.argv[1:])
    mode, N, S, base = head; S = int(S)
    print('cohort: mode %s, support %s, base %s, S = %d samples after entry; %d rows, %d entered the trap, %d not by tick 8001; %.0f s'
          % (mode, N, base, S, tot['rows'], tot['entered'], tot['not_entered'], tot['seconds']))
    if entry:
        print('entry tick by chunk (rows, median, p90, p99, max):', entry)
    print('kicks %d; 3-gaps %d; 5-gaps %d; longest run %d; longest trailing stretch of 5-gaps %d; rows with no 3-gap in the margin %d; windows cut by the margin %d'
          % (tot['kicks'], tot['gaps3'], tot['gaps5'], maxrun, tot['max_trailing'], tot['rows_without_3gap_in_margin'], tot['censored_windows']))
    print()
    print('delay from..to | runs | A = even share (s.e.) | mean run | share of runs of 1 | windows | B = two or more even (s.e.) | B if runs were independent | B / independent | code windows: B')
    los = sorted(bins)
    A, B = {}, {}
    for lo in los:
        b = bins[lo]; runs, even, sumlen, win = b[0], b[1], b[2], b[3]
        w2 = b[6] + b[7] + b[8]; cw = b[9]; c2 = b[12] + b[13] + b[14]
        a = even / runs; A[lo] = a
        ind = 1 - (1 - a) ** 4 - 4 * a * (1 - a) ** 3
        Bv = w2 / win if win else float('nan'); B[lo] = Bv
        print('%8d..%-8s | %11d | %.5f (%.5f) | %.3f | %.5f | %11d | %.6f (%.6f) | %.6f | %.3f | %.6f'
              % (lo, edges[lo] if edges[lo] > 0 else 'end', runs, a, spread(groups, lo, 1, 0), sumlen / runs, hist[lo][1] / runs, win, Bv,
                 spread(groups, lo, 3, 2), ind, Bv / ind if ind else float('nan'), c2 / cw if cw else float('nan')))
    full = [lo for lo in los if 0 < edges[lo] <= S]
    early, late = 100, full[-1]
    if early in B and late != early and not B[early]:
        print()
        print('VERDICT: no window with two or more even runs in the early bin; the rule does not apply to this cohort')
    elif early in B and late != early:
        r = B[late] / B[early]; ra = A[late] / A[early]
        verdict = 'DIE OUT' if r < 0.5 else ('FLAT' if abs(r - 1) <= 0.10 else 'DRIFTING')
        print()
        print('VERDICT (rule fixed before the run): B late [%d, %d) / B early [100, 200) = %.4f (s.e. over groups %.4f): %s'
              % (late, edges[late], r, ratio_spread(groups, early, late, 3, 2), verdict))
        print('        A late / A early = %.4f (s.e. %.4f)' % (ra, ratio_spread(groups, early, late, 1, 0)))
        first = [lo for lo in los if lo < 20]
        w2 = sum(bins[lo][6] + bins[lo][7] + bins[lo][8] for lo in first); w = sum(bins[lo][3] for lo in first)
        if w:
            print('        B before delay 20 = %.6f on %d windows; over B late = %.3f' % (w2 / w, w, (w2 / w) / B[late] if B[late] else float('nan')))
    # the control against K54
    print()
    print('CONTROL against K54 (a forbidden word must never start at or after its delay P):')
    bad = 0
    for w, P in sorted(FORBIDDEN.items()):
        t = tables[len(w)].get(w)
        if t is None:
            print('  %-16s P = %2d: never seen' % (w, P))
        else:
            ok = t[3] < P; bad += not ok
            print('  %-16s P = %2d: seen %d times, delays %d to %d: %s' % (w, P, t[0], t[2], t[3], 'consistent' if ok else '*** VIOLATION ***'))
    print('  ' + ('CONTROL PASSES' if not bad else '*** %d VIOLATIONS ***' % bad))
    # the 81 quadruples over runs 4 to 6
    print()
    print('The 81 quadruples over runs 4, 5, 6 (count at delay 100 or more; latest delay seen; a dash is never):')
    never = []
    for a in (4, 5, 6):
        for b in (4, 5, 6):
            cells = []
            for c in (4, 5, 6):
                for d in (4, 5, 6):
                    w = (a, b, c, d); t = tables[4].get(w); forb = w in FORBIDDEN
                    if t is None:
                        cells.append('%d%d:%s' % (c, d, 'F -' if forb else '-'))
                    else:
                        cells.append('%d%d:%s%d@%d' % (c, d, 'F ' if forb else '', t[1], t[3]))
                    if not forb and (t is None or t[1] == 0):
                        never.append(w)
            print('  %d%d | %s' % (a, b, '  '.join(cells)))
    print('  of the 62 not forbidden at P = 20, never seen at delay 100 or more: %d: %s' % (len(never), never))
    # the late run process
    print()
    late_hist = [sum(hist[lo][i] for lo in los if lo >= 100) for i in range(64)]
    n1 = sum(late_hist); mean = sum(i * c for i, c in enumerate(late_hist)) / n1
    print('Runs at delay 100 or more: %d; mean length %.4f (63 stands for longer); mean duration %.3f samples' % (n1, mean, 3 + 5 * mean))
    print('  length: share  ' + '  '.join('%d: %.5f' % (i, c / n1) for i, c in enumerate(late_hist) if c / n1 >= 0.00005))
    dur = 3 + 5 * mean
    h = [entropy(late_hist)]
    for n in (2, 3, 4):
        full_ = [t[1] for t in tables[n].values()]
        pre = defaultdict(int)
        for w, t in tables[n].items():
            pre[w[:-1]] += t[1]
        h.append(entropy(full_) - entropy(list(pre.values())))
    print('  entropy of the next run given the previous 0, 1, 2, 3 runs (plug-in, bits per run): ' + ', '.join('%.4f' % x for x in h))
    print('  the same in bits per double step: ' + ', '.join('%.5f' % (x / dur) for x in h))
    print('  distinct words seen at delay 100 or more: pairs %d, triples %d, quadruples %d'
          % tuple(sum(1 for t in tables[n].values() if t[1]) for n in (2, 3, 4)))
    top = sorted(tables[4].items(), key=lambda kv: -kv[1][1])[:12]
    n4 = sum(t[1] for t in tables[4].values())
    print('  commonest quadruples late: ' + '; '.join('%s %.4f' % (w, t[1] / n4) for w, t in top))
    ev = defaultdict(lambda: [0, 0])
    for w, t in tables[2].items():
        ev[w[0] % 2 == 0 and w[0] >= 4][0] += t[1]
        if w[1] % 2 == 0 and w[1] >= 4:
            ev[w[0] % 2 == 0 and w[0] >= 4][1] += t[1]
    if ev[True][0] and ev[False][0]:
        print('  share of even runs after an even run %.5f, after another run %.5f' % (ev[True][1] / ev[True][0], ev[False][1] / ev[False][0]))


if __name__ == '__main__':
    main()
