#!/usr/bin/env python3
"""claudeCloud_round_checks.py: the checks made in answer to the owner's observations in the Gate 3 round (ledger K17).
Exploratory: nothing here was predicted beforehand. Exact data from claudeCloud_excursions.py beside it.

  python3 claudeCloud_round_checks.py ones        rows whose reset words are all single cells, in each returning excursion
  python3 claudeCloud_round_checks.py makers      the 5-cell windows that make a single black cell in the next row;
                                                  what the row after a reset-free ("bare") row can hold (words to length 18)
  python3 claudeCloud_round_checks.py texture     the 800 slowest rows at periods 8, 10, 12, 13 against all bare words of length 20
  python3 claudeCloud_round_checks.py firstcatch  what first catches each row, every odd source at periods 6 to 13
  python3 claudeCloud_round_checks.py triangles   the white stretch under each black run of 8 or more cells, period 6
"""
import collections
import importlib.util
import itertools
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('ex', HERE / 'claudeCloud_excursions.py')
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)


def runs(row):
    out, n = [], 0
    for c in list(row) + [0]:
        if c:
            n += 1
        else:
            if n:
                out.append(n)
            n = 0
    return out


def bare(row):
    return all(l % 3 != 1 for l in runs(row))


def step(v):
    """One tick of the wheel rule on a finite word with white outside."""
    n = len(v)
    g = lambda i: v[i] if 0 <= i < n else 0   # noqa: E731
    return [g(j - 2) ^ (g(j - 1) | g(j)) for j in range(n + 2)]


def ones():
    print('source      P  gap  rows  ones  longer  bare   reset words by length')
    for p in range(1, 7):
        for w in ex.classes(p):
            wheels, gap = ex.excursion(w, 5000)
            if gap is None:
                print('%-10s %2d  no return within 5000 wheels' % (w, p))
                continue
            q = 2 * p
            rows = [[wheels[j][t] for j in range(gap + 1)] for t in range(q)]
            kinds = []
            for r in rows:
                rs = [l for l in runs(r) if l % 3 == 1]
                kinds.append('bare' if not rs else 'ones' if all(l == 1 for l in rs) else 'longer')
            hist = collections.Counter(l for r in rows for l in runs(r) if l % 3 == 1)
            print('%-10s %2d %4d  %4d  %4d  %6d  %4d   %s' % (w, p, gap, q, kinds.count('ones'), kinds.count('longer'),
                  kinds.count('bare'), ', '.join('%d of length %d' % (hist[l], l) for l in sorted(hist))))


def makers():
    found = [''.join(map(str, w)) for w in itertools.product((0, 1), repeat=5)
             if [w[j - 2] ^ (w[j - 1] | w[j]) for j in (2, 3, 4)] == [0, 1, 0]]
    print('5-cell windows whose next row has white, black, white under their last three cells:', found)
    seen, nb = collections.Counter(), 0
    for n in range(1, 19):
        for bits in itertools.product((0, 1), repeat=n):
            if bits[0] and bits[-1] and bare(bits):
                nb += 1
                seen.update(runs(step(bits)))
    print('bare words to length 18: %d; run lengths in the rows after them: %s' % (nb, dict(sorted(seen.items()))))


def stretch_stats(prefix):
    s = ''.join('#' if c else '.' for c in prefix).strip('.')
    return [len(x) for x in s.replace('#', ' ').split()], [len(x) for x in s.replace('.', ' ').split()]


def texture():
    allw, allb = collections.Counter(), collections.Counter()
    for p in (8, 10, 12, 13):
        slow = []
        for w in ex.classes(p):
            wheels, gap = ex.excursion(w, 120)
            for t, f in enumerate(ex.first_resets(wheels)):
                if f is not None:
                    slow.append((f, w, t, wheels))
        slow.sort(key=lambda x: -x[0])
        for f, w, t, wheels in slow[:200]:
            a = ex.resets(wheels[:f + 1], t)[0][0]
            whites, blacks = stretch_stats([wheels[j][t] for j in range(a)])
            allw.update(whites)
            allb.update(blacks)
    cw, cb = collections.Counter(), collections.Counter()
    for bits in itertools.product((0, 1), repeat=20):
        if bits[0] and bits[-1] and bare(bits):
            whites, blacks = stretch_stats(bits)
            cw.update(whites)
            cb.update(blacks)
    for name, a, b in (('the reset-free stretch of the 800 slowest rows', allw, allb), ('every bare word of length 20', cw, cb)):
        ta, tb = sum(a.values()), sum(b.values())
        print(name + ':')
        print('  white gaps by length: ' + ', '.join('%d: %.0f%%' % (k, 100 * a[k] / ta) for k in sorted(a) if a[k] / ta >= 0.02))
        print('  black runs by length: ' + ', '.join('%d: %.0f%%' % (k, 100 * b[k] / tb) for k in sorted(b) if b[k] / tb >= 0.02))


def firstcatch():
    how, rows = collections.Counter(), 0
    names = {'11000': "11000: a run of two or more, then three whites (a triangle's right corner)",
             '10110': "1011: black, white, then a run of two or more (a triangle's left corner)",
             '10111': "1011: black, white, then a run of two or more (a triangle's left corner)",
             '10101': '10101: alternating single cells'}
    for p in range(6, 14):
        for w in ex.classes(p):
            wheels, gap = ex.excursion(w, 120)
            q = 2 * p
            for t in range(q):
                r = ex.resets(wheels, t)
                if not r:
                    continue
                rows += 1
                a, b, _ = r[0]
                if b > a:
                    how['a longer reset word (4, 7, ...)'] += 1
                elif a == 2:
                    how['the single at wheel 2, at once (the first wheel has just turned white)'] += 1
                else:
                    how[names[''.join(str(wheels[j][(t - 1) % q]) for j in range(a - 3, a + 2))]] += 1
    print('what first catches a row: %d rows, every odd source at periods 6 to 13' % rows)
    for k, v in how.most_common():
        print('  %5.1f%%  %s' % (100 * v / rows, k))


def triangles():
    wheels, gap = ex.excursion('000001')
    q = 12
    cell = lambda j, t: wheels[j][t % q] if 0 <= j <= gap else 0   # noqa: E731
    for t in range(q):
        j = 1
        while j < gap:
            if cell(j, t):
                k = j
                while cell(k + 1, t):
                    k += 1
                if k - j + 1 >= 8:
                    life = []
                    for d in range(1, q):
                        lo, hi = j + 2 * d, min(k + 1, gap)
                        if lo > hi or any(cell(x, t + d) for x in range(lo, hi + 1)):
                            break
                        life.append('%d-%d' % (lo, hi))
                    print('tick %2d: %2d black cells, wheels %d-%d; white below at ticks +1, +2, ...: %s'
                          % (t, k - j + 1, j, k, ', '.join(life)))
                j = k + 1
            else:
                j += 1


if __name__ == '__main__':
    cmds = {'ones': ones, 'makers': makers, 'texture': texture, 'firstcatch': firstcatch, 'triangles': triangles}
    if len(sys.argv) != 2 or sys.argv[1] not in cmds:
        sys.exit(__doc__)
    cmds[sys.argv[1]]()
