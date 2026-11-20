#!/usr/bin/env python3
"""claudeCloud_quiet_sources.py: sources whose black ticks are far apart (ledger K18; the owner's question whether
period 5 is the only excursion of its kind). Exact data from claudeCloud_excursions.py beside it.

Between two black ticks of the source the first wheel keeps its colour, and the wheels after it then evolve as an
ordinary left side: from wheel 2 on while the first wheel is white, from wheel 1 on while it is black.

  python3 claudeCloud_quiet_sources.py settle W         from ANY state, how long the first W wheels of a left side take
                                                         to reach their cycle, and the cycles' lengths
  python3 claudeCloud_quiet_sources.py family PMAX      one black tick per period, periods 7..PMAX: the last wheel at
                                                         which a row is caught; returns within 200 wheels; and whether
                                                         the first 22 wheels at period P and P + 4 agree tick for tick
  python3 claudeCloud_quiet_sources.py sparse N SEED    N random sources of odd weight whose black ticks are at least
                                                         33 apart: the same two questions
  python3 claudeCloud_quiet_sources.py flips            the exact finite core: from each of the 8 settled states (4 phases
                                                         of the cycle, first wheel white or black) flip the first wheel
                                                         and follow wheels 0..22 for 33 ticks; where each row is caught
"""
import importlib.util
import pathlib
import random
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('ex', HERE / 'claudeCloud_excursions.py')
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)


def settle(w):
    mask, n = (1 << w) - 1, 1 << (w - 1)
    nxt = lambda v: ((v << 2) ^ ((v << 1) | v)) & mask   # noqa: E731
    state, tlen, cycles = bytearray(n), [-1] * n, []
    for s in range(n):
        if state[s]:
            continue
        path, pos, i = [], {}, s
        while state[i] == 0:
            state[i] = 1
            pos[i] = len(path)
            path.append(i)
            i = (nxt(2 * i + 1) - 1) >> 1
        if state[i] == 1:
            k = pos[i]
            cycles.append(len(path) - k)
            for j in path[k:]:
                tlen[j], state[j] = 0, 2
            base, rest = 0, path[:k]
        else:
            base, rest = tlen[i], path
        for d, j in enumerate(reversed(rest), 1):
            tlen[j], state[j] = base + d, 2
    print('first %d wheels: %d states; cycles by length: %s; longest wait before the cycle: %d ticks'
          % (w, n, sorted(cycles), max(tlen)))


def family(pmax):
    cap, prev, worst, agree, bad = 200, {}, {}, 0, []
    for p in range(7, pmax + 1):
        wheels, gap = ex.excursion('0' * (p - 1) + '1', cap)
        fr = ex.first_resets(wheels)
        worst[p] = (None if None in fr else max(fr), gap)
        rows = [tuple(wheels[j][t] for j in range(23)) for t in range(2 * p)]
        if p - 4 in prev and p - 4 >= 33:
            old = prev[p - 4]
            q = p - 4
            same = all(old[t] == rows[t] for t in range(q)) and all(old[q + n] == rows[p + n] for n in range(q))
            agree += same
            if not same:
                bad.append(p)
        prev[p] = rows
    print('periods 7 to %d, one black tick: a row not caught in %d wheels: %s; white returning within %d wheels: %s'
          % (pmax, cap, [p for p in worst if worst[p][0] is None] or 'none', cap,
             [(p, worst[p][1]) for p in worst if worst[p][1] is not None] or 'none'))
    print('latest catch: %s' % ', '.join('wheel %d at %d periods' % (w, sum(1 for p in worst if worst[p][0] == w))
                                         for w in sorted({worst[p][0] for p in worst})))
    print('latest catch at periods 33 and up: wheel %d' % max(worst[p][0] for p in worst if p >= 33))
    print('first 22 wheels at period P and P + 4 agree tick for tick, P = 33..%d: %d of %d%s'
          % (pmax - 4, agree, pmax - 4 - 33 + 1, '' if not bad else '; not at %s' % bad))


def sparse(n, seed):
    rng = random.Random(seed)
    worst, returned, total = 0, [], 0
    for _ in range(n):
        k = rng.choice([1, 3, 5, 7])
        gaps = [rng.randint(33, 70) for _ in range(k)]
        word = ''.join('0' * (g - 1) + '1' for g in gaps)
        wheels, gap = ex.excursion(word, 200)
        fr = ex.first_resets(wheels)
        total += 1
        if gap is not None:
            returned.append((len(word), gap))
        worst = max(worst, max(f if f is not None else 10 ** 6 for f in fr))
    print('%d random sources of odd weight, black ticks 33 to 70 apart, periods 33 to 490: latest catch at wheel %d; '
          'white returning within 200 wheels: %s' % (total, worst, returned or 'none'))


def flips():
    w = 22
    mask, v = (1 << w) - 1, 1
    for _ in range(200):
        v = ((v << 2) ^ ((v << 1) | v)) & mask
    cyc = []
    for _ in range(4):
        cyc.append([(v >> i) & 1 for i in range(w)])
        v = ((v << 2) ^ ((v << 1) | v)) & mask
    assert [(v >> i) & 1 for i in range(w)] == cyc[0]
    print("always-white wheels among the left side's first %d: %s" % (w, [i for i in range(w) if not any(c[i] for c in cyc)]))

    def first_reset(row):
        run = 0
        for j in range(1, len(row)):
            if row[j]:
                run += 1
            else:
                if run % 3 == 1:
                    return j
                run = 0
        return None
    worst, late, settled = 0, 0, True
    for colour in (0, 1):
        for ph in range(4):
            row = ([0, 0] + cyc[ph][:21]) if colour == 0 else ([0] + cyc[ph][:22])
            f = first_reset(row)
            settled &= f is not None and f <= 20
            caught = []
            for _ in range(33):
                row = [0, 1 - colour] + [row[j - 2] ^ (row[j - 1] | row[j]) for j in range(2, len(row))]
                f = first_reset(row)
                caught.append(f)
                if f is None or f > 20:
                    late += 1
                else:
                    worst = max(worst, f)
            tail = row[1:22] if colour == 0 else row[2:22]
            print('first wheel %s to %s, phase %d: rows caught at wheels %s; on the cycle again after 33 ticks: %s'
                  % ('white' if colour == 0 else 'black', 'black' if colour == 0 else 'white', ph, caught,
                     any(tail == c[:len(tail)] for c in cyc)))
    print('settled rows all caught by wheel 20: %s; rows after a flip not caught by wheel 20: %d of 264; latest catch: wheel %d'
          % (settled, late, worst))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['settle']:
        settle(int(a[1]))
    elif a[:1] == ['family']:
        family(int(a[1]))
    elif a[:1] == ['sparse']:
        sparse(int(a[1]), int(a[2]))
    elif a[:1] == ['flips']:
        flips()
    else:
        sys.exit(__doc__)
