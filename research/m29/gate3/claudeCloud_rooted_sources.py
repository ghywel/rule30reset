#!/usr/bin/env python3
"""claudeCloud_rooted_sources.py: every first clock loss on every rooted strip through clock 16, and the source at
each (ledger K27; the census's stage 3, K26 section 4).

A rooted strip is a left side that reaches the edge: wheel 0 and wheel 1 black, white outside. In the settled
pattern each wheel is a periodic column, and the wheel rule
    D_j(t+1) = D_(j-2)(t) xor (D_(j-1)(t) or D_j(t))
gives the next column from the two before it:
  - if the column before is black at some tick, the next column is forced;
  - if it is white at every tick (a white wheel), the next column is the running XOR of the column before that,
    its SOURCE. Count the source's black ticks over the clock q of everything so far.
      odd:  the clock doubles. The two choices differ by a shift of q, so they are one strip. This white wheel is
            a FIRST CLOCK LOSS of clock q, and the source is the kind of source the doubling lemma is about.
      even: the clock stays, and the two choices are two different strips: a fork.
Columns are held as 16-bit integers, bit t for tick t. A source of odd weight at clock 16 has no 16-periodic
continuation: the line ends there, a first clock loss of clock 16. This is the Stage I tree of period 16 of Gravner
and Griffeath (2012), section 8, who report 2,159,030 vertices in 894,234 generations and 16 lines that end by
doubling.

  python3 claudeCloud_rooted_sources.py tree        walk the whole tree; list every first clock loss with its source
                                                    and the last wheel at which a row of its doubled excursion is
                                                    first caught
"""
import importlib.util
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('ex', HERE / 'claudeCloud_excursions.py')
ex = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ex)

P = 16
FULL = (1 << P) - 1


def period(v):
    for d in (1, 2, 4, 8):
        if ((v >> d) | (v << (P - d))) & FULL == v:
            return d
    return 16


def forced_child(a, b):
    """The one P-periodic column c with c(t+1) = a(t) xor (b(t) or c(t)), b black at some tick."""
    t = (b & -b).bit_length() - 1
    bit = 1 - ((a >> t) & 1)
    c = 0
    for _ in range(P):
        t = (t + 1) % P
        c |= bit << t
        bit = ((a >> t) & 1) ^ (((b >> t) & 1) | bit)
    return c


def xor_child(a):
    """A running XOR of a: c(t+1) = a(t) xor c(t), c(0) = 0. P-periodic when a has even weight over P."""
    c, bit = 0, 0
    for t in range(P):
        c |= bit << t
        bit ^= (a >> t) & 1
    return c


def word(v, q):
    return ''.join(str((v >> t) & 1) for t in range(q))


def tree():
    losses, forks, vertices, deepest = [], [], 0, 0
    # (column two back, column before, wheel index of the column before, clock so far)
    stack = [(FULL, FULL, 1, 1)]                       # wheels 0 and 1 are black
    while stack:
        a, b, j, q = stack.pop()
        while True:
            vertices += 1
            deepest = max(deepest, j)
            if b:
                c = forced_child(a, b)
                q = max(q, period(c))
                a, b, j = b, c, j + 1
                continue
            # wheel j is white; its source is wheel j - 1, the column a
            weight_q = bin(a & ((1 << q) - 1)).count('1')
            if weight_q % 2:
                losses.append((q, j, word(a, q)))
                if q == P:
                    break                              # no 16-periodic continuation: the line ends
                q *= 2
                a, b, j = b, xor_child(a), j + 1       # the other choice is this one shifted by the old clock
                continue
            c = xor_child(a)
            forks.append((q, j))
            stack.append((b, c ^ FULL, j + 1, q))
            a, b, j = b, c, j + 1
    print('vertices: %d; deepest wheel: %d; forks: %d; first clock losses: %d' % (vertices, deepest, len(forks), len(losses)))
    print('forks (clock, white wheel): %s' % ', '.join('%d at %d' % f for f in sorted(forks, key=lambda f: f[1])))
    print('clock  white wheel  source (one period)   black ticks  last row caught at wheel  rows never caught')
    for q, j, w in sorted(losses, key=lambda x: (x[0], x[1])):
        wheels, gap = ex.excursion(w, 600)
        firsts = ex.first_resets(wheels)
        bare = sum(1 for f in firsts if f is None)
        print('%5d  %11d  %-20s  %11d  %24d  %17d' % (q, j, w, w.count('1'), max(f for f in firsts if f is not None), bare))


if __name__ == '__main__':
    if sys.argv[1:2] == ['tree']:
        tree()
    else:
        sys.exit(__doc__)
