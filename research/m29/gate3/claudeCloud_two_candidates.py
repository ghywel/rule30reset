#!/usr/bin/env python3
"""claudeCloud_two_candidates.py: how closely the wrong guesses of the row above match the true one (ledger K21;
the owner's question in the Gate 3 round). Exact data from claudeCloud_excursions.py beside it.

Reading row t backwards from wheel js: the row above has cells p with r[j] = p[j-2] xor (p[j-1] or p[j]). Guess
p[js] and p[js-1] in all four ways (guess 1: white, white; 2: white at js, black at js-1; 3: black, white;
4: black, black) and work leftwards.

  python3 claudeCloud_two_candidates.py rows WORD        every row of one excursion: which guess is true, how many
                                                         cells each guess gets right, and the cells all four agree on
  python3 claudeCloud_two_candidates.py cases            the local law by exhaustion: every pair of different guesses
                                                         at two neighbouring cells, and both colours of the row's cell
  python3 claudeCloud_two_candidates.py laws PMAX        the same laws counted on every odd source to period PMAX
                                                         (100 wheels), for every pair of guesses; and how long three
                                                         different guesses last
  python3 claudeCloud_two_candidates.py third PMAX       the one-in-three count: in a stretch with no reset word, two
                                                         guesses agree exactly on the cells two to the left of every
                                                         third black cell of the row
  python3 claudeCloud_two_candidates.py compare CAP WORD...   the measure across sources: for each row, the share of
                                                         the row above on which all four guesses agree, read from the
                                                         return (or from wheel CAP if white has not returned)
"""
import importlib.util
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('ex', HERE / 'claudeCloud_excursions.py')
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)


def read_back(wheels, t, js):
    """The four guesses, as lists over wheels 0..js."""
    out = []
    for s in range(4):
        p = [0] * (js + 1)
        p[js], p[js - 1] = s >> 1, s & 1
        for j in range(js, 1, -1):
            p[j - 2] = wheels[j][t] ^ (p[j - 1] | p[j])
        out.append(p)
    return out


def rows(word):
    wheels, gap = ex.excursion(word, 400)
    q, js = len(wheels[0]), len(wheels) - 1
    print('source %s: read from wheel %d%s' % (word, js, '' if gap else ' (white has not returned)'))
    print('tick  true guess  cells right, guesses 1-4 (of %d)   all four agree on   first reset word' % (js + 1))
    for t in range(q):
        g = read_back(wheels, t, js)
        truth = [wheels[j][(t - 1) % q] for j in range(js + 1)]
        right = [sum(a == b for a, b in zip(p, truth)) for p in g]
        sure = sum(1 for j in range(js + 1) if g[0][j] == g[1][j] == g[2][j] == g[3][j])
        rs = ex.resets(wheels, t)
        print('%4d  %10d  %s   %4d (%3.0f%%)          %s' % (t, right.index(js + 1) + 1, ' '.join('%4d' % x for x in right), sure,
              100 * sure / (js + 1), 'none' if not rs else 'closes at wheel %d' % rs[0][2]))


def cases():
    """Two guesses a, b known at cells j+1 and j+2, and the row's cell r at j+2: what happens at cell j."""
    names = {0: 'white', 1: 'black'}
    print("the row's cell   guess a (j+1, j+2)   guess b (j+1, j+2)   at cell j")
    bad = 0
    for r in (0, 1):
        for sa in range(4):
            for sb in range(sa + 1, 4):
                a1, a2, b1, b2 = sa >> 1, sa & 1, sb >> 1, sb & 1
                a0, b0 = r ^ (a1 | a2), r ^ (b1 | b2)
                if a0 != b0:
                    what = 'differ'
                elif a1 == b1:
                    what = 'agree, and at j+1: one guess from here leftwards'
                elif a0 == 1:
                    what = 'agree on black: one guess from the next cell leftwards'
                else:
                    what = 'agree on white, differ at j+1: differ again at j-1 whatever the row holds'
                # the claims, checked for both colours of the row's next cell
                for r2 in (0, 1):
                    an, bn = r2 ^ (a0 | a1), r2 ^ (b0 | b1)
                    if a0 == b0 and a0 == 1 and an != bn:
                        bad += 1                       # agreed on black and did not merge
                    if a0 == b0 and a0 == 0 and a1 != b1 and an == bn:
                        bad += 1                       # agreed on white with different neighbours, and merged
                    if a0 == b0 and a1 == b1 and an != bn:
                        bad += 1                       # two neighbouring agreements and did not stay merged
                print('%-16s %-20s %-20s %s' % (names[r], names[a1] + ', ' + names[a2], names[b1] + ', ' + names[b2], what))
    print('cases against the three claims: %d' % bad)
    # What a run of the row does to one guess. The state is (cell j+1, cell j+2); a step gives (cell j, cell j+1).
    step = lambda r, st: (r ^ (st[0] | st[1]), st[0])
    states = [(x, y) for x in (0, 1) for y in (0, 1)]
    white2 = {step(0, step(0, st)) for st in states}
    print('after two white cells of the row, a guess is in one of: %s (then all white, or all black)'
          % sorted(white2))
    cycle = [(0, 0), (1, 0), (0, 1)]
    ok = all(step(1, st) in cycle for st in states) and all(step(1, cycle[i]) == cycle[(i + 1) % 3] for i in range(3))
    print('under black cells of the row, every guess enters the cycle of three (white, white, black) at once: %s' % ok)
    # two guesses entering a black run of length L as all white and all black: do they leave it as one guess?
    for L in range(1, 10):
        a, b = (0, 0), (1, 1)
        for _ in range(L):
            a, b = step(1, a), step(1, b)
        a, b = step(0, a), step(0, b)
        a2, b2 = step(0, a), step(0, b)
        print('  black run of %d, then white: %s' % (L, 'one guess' if a == b or a2 == b2 else 'still two'))


def laws(pmax):
    n = pairs = runs_of_two = black_no_merge = merges = merge_not_black = 0
    first3, last3 = {}, {}
    for p in range(1, pmax + 1):
        for w in ex.classes(p):
            wheels, gap = ex.excursion(w, 100)
            q, js = len(wheels[0]), len(wheels) - 1
            for t in range(q):
                g = read_back(wheels, t, js)
                n += 1
                # the last cell, counted from the start, at which three different guesses still show
                k = 1
                while js - 1 - k >= 1 and len({(x[js - 1 - k], x[js - k]) for x in g}) > 2:
                    k += 1
                d = first3 if wheels[js][t] == 0 else last3
                d[k] = d.get(k, 0) + 1
                for x in range(4):
                    for y in range(x + 1, 4):
                        a, b = g[x], g[y]
                        j = js - 2
                        while j >= 0:
                            if a[j] == b[j]:
                                pairs += 1
                                if j >= 1 and a[j - 1] == b[j - 1]:   # two cells running: merged for good?
                                    merges += 1
                                    if any(a[i] != b[i] for i in range(j)):
                                        runs_of_two += 1
                                    if a[j] != 1 and a[j + 1] != b[j + 1]:
                                        merge_not_black += 1
                                    break
                                if a[j] == 1 and j >= 1:
                                    black_no_merge += 1
                            j -= 1
    print('rows read: %d (every odd source at periods 1 to %d, 100 wheels), every pair of guesses' % (n, pmax))
    print('cells on which two guesses agree before they merge, or as they merge: %d' % pairs)
    print('  agreeing on two neighbouring cells without having merged for good: %d' % runs_of_two)
    print('  agreeing on a black cell without merging at once: %d' % black_no_merge)
    print('merges: %d; merges that did not begin on a black cell: %d' % (merges, merge_not_black))
    for name, d in (('white', first3), ('black', last3)):
        print("the row's cell at the start is %s: %d rows; three different guesses last: %s"
              % (name, sum(d.values()), ', '.join('%d cells in %d rows' % kv for kv in sorted(d.items()))))


def third(pmax):
    """Stretches with no reset word: the part of each row to the left of its first reset word (or the whole row, if
    it has none), read from the white cell at its right end. Guess 1 against guess 2."""
    n = exact = on_black = cells = agree = 0
    for p in range(1, pmax + 1):
        for w in ex.classes(p):
            wheels, gap = ex.excursion(w, 100)
            q, width = len(wheels[0]), len(wheels) - 1
            for t in range(q):
                rs = ex.resets(wheels, t)
                js = rs[0][0] - 1 if rs else width
                if js < 4 or wheels[js][t]:
                    continue
                g = read_back(wheels, t, js)
                a, b = g[0], g[1]
                got = [j for j in range(js - 1) if a[j] == b[j]]
                want, k = [], 0
                for j in range(js - 1, 1, -1):           # number black cells 1, 2, ... from the right of each run
                    k = k + 1 if wheels[j][t] else 0
                    if k % 3 == 2:
                        want.append(j - 2)
                n += 1
                exact += sorted(want) == got
                on_black += sum(a[j] for j in got)
                cells += js - 1
                agree += len(got)
    print('stretches with no reset word: %d (every odd source at periods 1 to %d, 100 wheels)' % (n, pmax))
    print('the two guesses agree exactly on the cells two to the left of black cells 2, 5, 8, ... in each run from its right: %d of %d' % (exact, n))
    print('cells in those stretches: %d; cells agreed on: %d (%.1f%%); agreed cells that are black: %d'
          % (cells, agree, 100 * agree / cells, on_black))


def compare(cap, words):
    print('source                             read from  rows  pinned down: least  median  most   rows under a third   of them with no reset word')
    for w in words:
        wheels, gap = ex.excursion(w, cap)
        q, js = len(wheels[0]), len(wheels) - 1
        share, bare = [], 0
        for t in range(q):
            g = read_back(wheels, t, js)
            sure = sum(1 for j in range(js + 1) if g[0][j] == g[1][j] == g[2][j] == g[3][j])
            share.append(sure / (js + 1))
            if sure / (js + 1) < 1 / 3 and not ex.resets(wheels, t):
                bare += 1
        s = sorted(share)
        low = sum(1 for x in s if x < 1 / 3)
        print('%-34s wheel %-4d %4d  %17.0f%%  %5.0f%%  %3.0f%%   %18d   %d' % (
            (w if len(w) <= 32 else 'period %d, %d black' % (len(w), w.count('1'))) + ('' if gap else ' (no return)'),
            js, q, 100 * s[0], 100 * s[len(s) // 2], 100 * s[-1], low, bare))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['rows']:
        rows(a[1])
    elif a[:1] == ['cases']:
        cases()
    elif a[:1] == ['laws']:
        laws(int(a[1]))
    elif a[:1] == ['third']:
        third(int(a[1]))
    elif a[:1] == ['compare']:
        compare(int(a[1]), a[2:])
    else:
        sys.exit(__doc__)
