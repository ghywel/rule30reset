#!/usr/bin/env python3
"""claudeCloud_guess_gates.py: the pattern made by the four guesses at every wheel of a row (ledger K22; the owner's
question in the Gate 3 round). Exact data from claudeCloud_excursions.py beside it.

Reading row t backwards from wheel js: the row above has cells p with r[j] = p[j-2] xor (p[j-1] or p[j]). The two
cells guessed are the LEFT cell, at wheel js-1, and the RIGHT cell, at wheel js:
    guess 1: both white      guess 2: left black      guess 3: right black      guess 4: both black
The reading runs past wheel 0 through the source (wheel -1) to wheel -3, as the explorer's does. Two guesses END
THE SAME when they agree at wheels -3 and -2: they are then one guess from there leftwards. The SPLIT at js is the
way the four guesses fall into groups that end the same.

  python3 claudeCloud_guess_gates.py row WORD [TICK]   one row, every starting wheel from its capture back to wheel 2:
                                                       the split, the true guess, and how many cells each guess
                                                       gets right. TICK defaults to the last row caught.
  python3 claudeCloud_guess_gates.py law PMAX          the law, on every row and every starting wheel of every odd
                                                       source to period PMAX (100 wheels): the split is decided by
                                                       the number of black cells of the row from the starting wheel
                                                       leftwards, counted in threes
  python3 claudeCloud_guess_gates.py table             the same law from the reader's four states alone: no data
"""
import importlib.util
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('ex', HERE / 'claudeCloud_excursions.py')
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)

OFF = 3
NAMES = {'1|234': 'guess 1 alone (OR)', '124|3': 'guess 3 alone (right and not left)',
         '13|24': 'the left cell decides', '1234': 'all one', '1|24|3': 'three groups'}


def read_back(wheels, src, t, js):
    """The four guesses over wheels -3..js; cell j is at index j + OFF."""
    out = []
    for s in range(4):
        p = [0] * (js + 1 + OFF)
        p[js + OFF], p[js - 1 + OFF] = s >> 1, s & 1
        for j in range(js, -2, -1):
            r = wheels[j][t] if j >= 0 else src[t]
            p[j - 2 + OFF] = r ^ (p[j - 1 + OFF] | p[j + OFF])
        out.append(p)
    return out


def split(g):
    """The groups of guesses that end the same, as a string such as '1|234'."""
    groups = {}
    for s in range(4):
        groups.setdefault((g[s][0], g[s][1]), []).append(str(s + 1))
    return '|'.join(sorted(''.join(v) for v in groups.values()))


def black_from(wheels, t, js):
    """The number of black cells of row t at wheels js, js-1, ... up to the first white one."""
    n = 0
    while js - n >= 0 and wheels[js - n][t]:
        n += 1
    return n


def predicted(wheels, t, js, rs):
    if any(close <= js for _, _, close in rs):
        return '1234'
    return ('1|234', '124|3', '13|24')[black_from(wheels, t, js) % 3]


def setup(word, cap):
    wheels, gap = ex.excursion(word, cap)
    q = len(wheels[0])
    src = [int(word[t % len(word)]) for t in range(q)]
    return wheels, gap, q, src


def row(word, tick=None):
    wheels, gap, q, src = setup(word, 400)
    width = len(wheels) - 1
    firsts = [(ex.resets(wheels, t) or [(None, None, None)])[0][2] for t in range(q)]
    if tick is None:
        caught = [(c, t) for t, c in enumerate(firsts) if c is not None]
        tick = max(caught)[1]
    tp = (tick - 1) % q
    rs = ex.resets(wheels, tick)
    top = (firsts[tick] - 1) if firsts[tick] is not None else width
    print('source %s, tick %d: %s' % (word if len(word) <= 40 else 'of period %d' % len(word), tick,
          'no reset word' if firsts[tick] is None else 'first reset word closes at wheel %d' % firsts[tick]))
    print('T the true guess; r ends the same as the true guess; x ends as the other version')
    print('wheel  row  black from here  split                                 guesses 1-4   cells right of all')
    tally = {}
    for js in range(top, 1, -1):
        g = read_back(wheels, src, tick, js)
        truth = [wheels[j][tp] for j in range(js + 1)]
        right = [sum(g[s][j + OFF] == truth[j] for j in range(js + 1)) for s in range(4)]
        true = right.index(js + 1)
        marks = ['T' if s == true else 'r' if (g[s][0], g[s][1]) == (g[true][0], g[true][1]) else 'x' for s in range(4)]
        sp = split(g)
        assert sp == predicted(wheels, tick, js, rs), (js, sp)
        tally[sp, ''.join(marks)] = tally.get((sp, ''.join(marks)), 0) + 1
        print('%5d  %3s  %15d  %-36s  %s   %s of %d' % (js, '#' if wheels[js][tick] else '.', black_from(wheels, tick, js),
              NAMES[sp], ' '.join(marks), ' '.join('%3d' % x for x in right), js + 1))
    print('patterns along the stretch:')
    for (sp, m), n in sorted(tally.items()):
        print('  %-36s %s   %d wheels' % (NAMES[sp], ' '.join(m), n))


def law(pmax):
    n = ok = 0
    kinds, lone, examples = {}, {}, []
    for p in range(1, pmax + 1):
        for w in ex.classes(p):
            wheels, gap, q, src = setup(w, 100)
            width = len(wheels) - 1
            for t in range(q):
                rs = ex.resets(wheels, t)
                tp = (t - 1) % q
                for js in range(2, width + 1):
                    g = read_back(wheels, src, t, js)
                    sp, want = split(g), predicted(wheels, t, js, rs)
                    n += 1
                    ok += sp == want
                    if sp != want and len(examples) < 5:
                        examples.append((w, t, js, sp, want))
                    kinds[sp] = kinds.get(sp, 0) + 1
                    if sp in ('1|234', '124|3'):
                        true = wheels[js][tp] * 2 + wheels[js - 1][tp] + 1
                        d = lone.setdefault(sp, [0, 0])
                        d[str(true) == ('1' if sp == '1|234' else '3')] += 1
    print('rows and starting wheels read: %d (every odd source at periods 1 to %d, 100 wheels, wheels 2 up)' % (n, pmax))
    print('the split is the one the count of black cells predicts: %d of %d' % (ok, n))
    for e in examples:
        print('  exception: source %s tick %d wheel %d: split %s, predicted %s' % e)
    for k, v in sorted(kinds.items(), key=lambda kv: -kv[1]):
        print('  %-36s %d' % (NAMES.get(k, k), v))
    for k, (rest, alone) in sorted(lone.items()):
        print('  %s: the true guess is the one alone in %d, one of the three in %d' % (NAMES[k], alone, rest))


def table():
    """The reader's state is (left cell, right cell). A white cell of the row sends (x, y) to (x or y, x); a black
    cell sends it to (not (x or y), x). Follow the four guesses through k black cells and then white cells."""
    step = lambda r, st: (r ^ (st[0] | st[1]), st[0])
    start = [(s & 1, s >> 1) for s in range(4)]          # (left, right) for guesses 1 to 4
    print('black cells from the start   then white cells, until the groups stop changing')
    for k in range(0, 10):
        st = list(start)
        for _ in range(k):
            st = [step(1, x) for x in st]
        for _ in range(4):
            st = [step(0, x) for x in st]
        groups = {}
        for s in range(4):
            groups.setdefault(st[s], []).append(str(s + 1))
        sp = '|'.join(sorted(''.join(v) for v in groups.values()))
        print('%26d   %s' % (k, NAMES[sp]))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['row']:
        row(a[1], int(a[2]) if len(a) > 2 else None)
    elif a[:1] == ['law']:
        law(int(a[1]))
    elif a[:1] == ['table']:
        table()
    else:
        sys.exit(__doc__)
