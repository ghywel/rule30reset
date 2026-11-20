#!/usr/bin/env python3
"""claudeCloud_excursions.py: doubled white excursions of rule 30's left side, exactly, for the inquisition round
of Gate 3 (pull M29; ledger K16).

A doubled excursion starts at a permanently white wheel whose source, the wheel before it, has period P and an odd
number of black ticks per period. Wheel 1 after the white is then the running XOR of the source, of period 2P; wheel 2
is black at every tick; every later wheel is the unique 2P-periodic child of the two before it,
    C(t+1) = A(t) xor (B(t) or C(t)),
until a wheel is white at every tick: the return, at wheel `gap`. This is the construction of
claudeCloud_doubling_returns.c (K7), rewritten here independently in Python.

A tick's word is its row of cells across wheels 0..gap. A reset word in it is a closed black run of length 1, 4, 7, ...
(one more than a multiple of three) with a white cell on each side. `first[t]` is the wheel of the white cell that
closes tick t's first reset word, or None if the tick has none before the return.

COMMANDS
  python3 claudeCloud_excursions.py table PMAX [CAP]    one line per source period 2..PMAX: every odd class
  python3 claudeCloud_excursions.py text WORD           one excursion as text ('#' black, '.' white, 'R' reset word)
  python3 claudeCloud_excursions.py json WORD...        the excursions as JSON, for the picture
"""
import json
import sys


def child(a, b):
    """The unique periodic child of a (two wheels back) and b (the wheel before), b black at some tick."""
    q = len(a)
    t = b.index(1)
    c = [0] * q
    c[(t + 1) % q] = 1 - a[t]
    for _ in range(q - 1):
        t = (t + 1) % q
        c[(t + 1) % q] = a[t] ^ (b[t] | c[t])
    return c


def excursion(word, cap=100000):
    """The wheels 0..gap of the doubled excursion of the source `word` (a string of 0s and 1s, odd weight).
    Returns (wheels, gap); gap is None if no wheel is white at every tick within `cap` wheels."""
    p = len(word)
    src = [int(ch) for ch in word]
    assert sum(src) % 2 == 1, 'the source needs an odd number of black ticks per period'
    q = 2 * p
    first, x = [], 0
    for t in range(q):
        first.append(x)
        x ^= src[t % p]
    wheels = [[0] * q, first, [1] * q]
    while len(wheels) <= cap:
        c = child(wheels[-2], wheels[-1])
        wheels.append(c)
        if not any(c):
            return wheels, len(wheels) - 1
    return wheels, None


def resets(wheels, t):
    """The reset words of tick t: a list of (first black wheel, last black wheel, closing white wheel)."""
    out, run = [], 0
    for j in range(1, len(wheels)):
        if wheels[j][t]:
            run += 1
        else:
            if run % 3 == 1:
                out.append((j - run, j - 1, j))
            run = 0
    return out


def first_resets(wheels):
    return [(r[0][2] if r else None) for r in (resets(wheels, t) for t in range(len(wheels[0])))]


def classes(p):
    """One word for each rotation class of the odd-weight words of least period p."""
    seen, out = set(), []
    for n in range(1 << p):
        w = format(n, '0%db' % p)
        if w.count('1') % 2 == 0 or w in seen:
            continue
        rots = {w[i:] + w[:i] for i in range(p)}
        seen |= rots
        if len(rots) == p:
            out.append(min(rots))
    return out


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'text':
        word = sys.argv[2]
        wheels, gap = excursion(word)
        fr = first_resets(wheels)
        print('source %s, period %d: returns to white at wheel %d' % (word, len(word), gap))
        for t in range(len(wheels[0])):
            row = ['#' if wheels[j][t] else '.' for j in range(gap + 1)]
            for a, b, _ in resets(wheels, t):
                for j in range(a, b + 1):
                    row[j] = 'R'
            print('tick %2d  %s  %s' % (t, ''.join(row), 'first reset closes at wheel %d' % fr[t] if fr[t] else 'NO RESET WORD'))
    elif cmd == 'json':
        out = []
        for word in sys.argv[2:]:
            wheels, gap = excursion(word)
            q = len(wheels[0])
            out.append({'word': word, 'P': len(word), 'gap': gap,
                        'rows': [''.join(str(wheels[j][t]) for j in range(gap + 1)) for t in range(q)],
                        'resets': [resets(wheels, t) for t in range(q)], 'first': first_resets(wheels)})
        json.dump(out, sys.stdout)
    elif cmd == 'table':
        pmax = int(sys.argv[2])
        cap = int(sys.argv[3]) if len(sys.argv) > 3 else 400
        print('P  classes  last-first-reset: least..greatest (in units of P)  earliest return  unreset at return')
        for p in range(1, pmax + 1):
            cl = classes(p)
            lasts, gaps, bad = [], [], []
            for w in cl:
                wheels, gap = excursion(w, cap)
                fr = first_resets(wheels)
                if gap is not None:
                    gaps.append((gap, w))
                if None in fr:
                    if gap is not None:
                        bad.append((w, gap, fr.count(None)))
                    else:
                        lasts.append(None)
                else:
                    lasts.append(max(fr))
            done = [x for x in lasts if x is not None]
            print('%2d %7d   %s   %s   %s' % (
                p, len(cl),
                ('%d..%d (%.1fP..%.1fP)' % (min(done), max(done), min(done) / p, max(done) / p)) if done else '-',
                ('%d (%s)' % min(gaps)) if gaps else 'none within %d wheels' % cap,
                '; '.join('%s: gap %d, %d of %d ticks' % (w, g, n, 2 * p) for w, g, n in bad) or 'none'
                + ('' if None not in lasts else '  [%d class(es) unresolved at the cap]' % lasts.count(None))))
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
