#!/usr/bin/env python3
"""claudeCloud_constant_wheels.py: which wheels of rule 30's left side settle to one colour, and from which tick
(ledger K23; the owner's question in the Gate 3 round).

Rule 30 from one black cell. Wheel j at tick t is the cell j places in from the left edge of row t, so wheel 0 is
the edge itself. In these coordinates the rule is
    D_j(t+1) = D_(j-2)(t) xor (D_(j-1)(t) or D_j(t)),
which looks only leftwards, so wheels 0..J are computed exactly without the rest of the row. A row is one integer,
bit j for wheel j.

  python3 claudeCloud_constant_wheels.py find J T1 T2       every wheel up to J that keeps one colour from tick T1 to
                                                            tick T2, and whether the black ones are exactly the
                                                            wheels two after a white one (with wheels 0 and 1)
  python3 claudeCloud_constant_wheels.py turn T WHEEL...    for each wheel, run to tick T: its last tick of the other
                                                            colour, and what it did before
  python3 claudeCloud_constant_wheels.py early WHEEL TICKS  the wheel's first TICKS ticks as text
  python3 claudeCloud_constant_wheels.py front J T [STEP]   for every wheel up to J, the tick from which it repeats
                                                            for good (run to tick T, repeat tested at 32 ticks):
                                                            the front between the orderly side and the rest.
                                                            Prints every STEP-th wheel and the white wheels.
  python3 claudeCloud_constant_wheels.py check T            the wheel coordinates against rule 30 run in the ordinary
                                                            way, cell by cell, for T ticks
"""
import sys


def rows(J, T):
    """Yield (t, row) for t = 0..T, wheels 0..J."""
    mask = (1 << (J + 1)) - 1
    w = 1
    for t in range(T + 1):
        yield t, w
        w = ((w << 2) ^ ((w << 1) | w)) & mask


def find(J, T1, T2):
    mask = (1 << (J + 1)) - 1
    black = white = 0
    for t, w in rows(J, T2):
        if t >= T1:
            black |= w
            white |= ~w & mask
    always_white = [j for j in range(J + 1) if not (black >> j) & 1]
    always_black = [j for j in range(J + 1) if not (white >> j) & 1]
    print('wheels 0 to %d, ticks %d to %d' % (J, T1, T2))
    print('white throughout: %s' % always_white)
    print('black throughout: %s' % always_black)
    want = sorted({0, 1} | {j + 2 for j in always_white if j + 2 <= J})
    print('the black ones are wheels 0 and 1 and the wheels two after a white one: %s' % (always_black == want))


def turn(T, wheels):
    J = max(wheels)
    hist = {j: [] for j in wheels}
    for t, w in rows(J, T):
        for j in wheels:
            hist[j].append((w >> j) & 1)
    print('run to tick %d' % T)
    print('wheel  ends  reached at tick  last tick of the other colour  that colour before then  first black tick')
    for j in wheels:
        h = hist[j]
        final = h[-1]
        last = max((t for t in range(T + 1) if h[t] != final), default=None)
        first_black = h.index(1) if 1 in h else None
        other = sum(1 for x in h if x != final)
        print('%5d  %-5s %15d  %29s  %23d  %16s' % (j, 'black' if final else 'white', (j + 1) // 2,
              'never' if last is None else last, other, first_black))


def early(j, ticks):
    h = [(w >> j) & 1 for t, w in rows(j, ticks - 1)]
    print('wheel %d, ticks 0 to %d (# black, . white):' % (j, ticks - 1))
    print(''.join('#' if x else '.' for x in h))


def settle_ticks(J, T, period=32):
    """For each wheel 0..J: the first tick from which D_j(t) = D_j(t + period) up to tick T - period."""
    mask = (1 << (J + 1)) - 1
    ring, last = [], [-1] * (J + 1)
    for t, w in rows(J, T):
        ring.append(w)
        if len(ring) > period:
            d = ring.pop(0) ^ w                         # wheels that differ between tick t - period and tick t
            while d:
                low = d & -d
                last[low.bit_length() - 1] = t - period
                d ^= low
    return [x + 1 for x in last]


def front(J, T, step=1):
    tau = settle_ticks(J, T)
    assert max(tau) < T - 200, 'run longer: some wheel has not settled well before the end'
    whites = {2, 7, 28, 399, 53207, 58286, 87866}
    print('wheel  repeats from tick  ticks for each wheel  cells left of the centre line at that tick')
    for j in range(J + 1):
        if j % step == 0 or j in whites:
            print('%5d  %17d  %20s  %10d%s' % (j, tau[j], '%.3f' % (tau[j] / j) if j else '-', tau[j] - j,
                  '   turns white for good' if j in whites else ''))
    # the front: at tick t, the deepest wheel W such that every wheel up to W repeats from t or before
    run, worst = 0, []
    for j in range(J + 1):
        run = max(run, tau[j])
        worst.append(run)
    late = sum(1 for j in range(J + 1) if tau[j] == worst[j])
    back = max(worst[j] - tau[j] for j in range(J + 1))
    print('wheels that settle later than every wheel before them: %d of %d' % (late, J + 1))
    print('the most ticks by which a wheel settles before some shallower wheel: %d' % back)


def check(T):
    """Rule 30 as usually written: new cell = left xor (centre or right), on a row of 2T+1 cells."""
    row = [0] * (2 * T + 3)
    row[T + 1] = 1
    bad = n = 0
    for (t, w) in rows(2 * T, T):
        for j in range(2 * t + 1):                       # wheel j of tick t is the cell at x = j - t
            n += 1
            bad += row[T + 1 + j - t] != (w >> j) & 1
        row = [0] + [row[i - 1] ^ (row[i] | row[i + 1]) for i in range(1, 2 * T + 2)] + [0]
    print('cells compared over ticks 0 to %d: %d; different: %d' % (T, n, bad))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['find']:
        find(int(a[1]), int(a[2]), int(a[3]))
    elif a[:1] == ['turn']:
        turn(int(a[1]), [int(x) for x in a[2:]])
    elif a[:1] == ['early']:
        early(int(a[1]), int(a[2]))
    elif a[:1] == ['front']:
        front(int(a[1]), int(a[2]), int(a[3]) if len(a) > 3 else 1)
    elif a[:1] == ['check']:
        check(int(a[1]))
    else:
        sys.exit(__doc__)
