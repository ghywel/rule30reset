#!/usr/bin/env python3
"""claudeM5_relaxed_window.py: how many consecutive white intervals a doubled excursion needs before every tick has
a reset word (the relaxed lemma, K25 pull 1; every-k-chain.md section 3.5).

From a source word (odd weight, least period P) the doubled excursion is built by claudeCloud_excursions.py, which
this script imports and does not change. At the white wheel B where it returns, the next interval's source is
wheel B - 1, read on the clock q = 2P.
  - Odd weight over q: the next interval doubles. Its first wheel is the running XOR of that source; the two
    choices differ by a shift of q, which fixes everything before B, so one choice is enough.
  - Even weight over q: the clock stays q. The first wheel x has x(t+1) = a(t) xor x(t), and both solutions,
    x and its complement, are q-periodic. They are different strips, so both branches are followed.
Every later wheel is the unique periodic child of the two before it, until a wheel is white at every tick.

A tick t is caught by the window when some interval of the window has a reset word (white, a black run of length
1, 4, 7, ..., white) at tick t mod its period, inside that interval. N(source) is the least N such that the first
N + 1 intervals catch every tick, on every branch. N = 0 is the strict lemma (DL-).

COMMANDS
  python3 claudeM5_relaxed_window.py window WORD [NMAX] [CAP]   N for one source, interval by interval
  python3 claudeM5_relaxed_window.py census PMAX [NMAX] [CAP]   every odd class of least period 1..PMAX
A reset found among the wheels built so far lies inside its interval, so an interval that has not returned within
CAP wheels still counts for the ticks it has caught; it cannot be followed further, and the result says so.
"""
import sys

from claudeCloud_excursions import child, classes, excursion, resets


def follow(src, q, cap, doubling):
    """The wheels of the interval after a white wheel whose source column is `src` (length q, global tick mod q).
    Returns a list of (wheels, gap) branches; gap is None when no white returns within `cap` wheels."""
    if doubling:
        word = ''.join(map(str, src))
        return [excursion(word, cap)]
    out = []
    for x0 in (0, 1):
        x, w = [0] * q, x0
        for t in range(q):
            x[t] = w
            w ^= src[t]
        assert w == x0, 'an even-weight source has a periodic first wheel'
        wheels = [[0] * q, x]
        gap = None
        while len(wheels) <= cap:
            c = child(wheels[-2], wheels[-1])
            wheels.append(c)
            if not any(c):
                gap = len(wheels) - 1
                break
        out.append((wheels, gap))
    return out


def caught_ticks(wheels):
    q = len(wheels[0])
    return [bool(resets(wheels, t)) for t in range(q)]


def window(word, nmax=3, cap=400):
    """N for the source `word`: the least N with every tick caught by the first N + 1 intervals, on every branch.
    Returns (N or None, notes); None when NMAX intervals or the cap ran out first."""
    notes = []

    def walk(wheels, gap, caught, n, label):
        """caught: a list of (period, list of booleans) for the intervals so far on this branch."""
        q = len(wheels[0])
        caught = caught + [(q, caught_ticks(wheels))]
        Q = max(c[0] for c in caught)
        miss = [t for t in range(Q) if not any(c[1][t % c[0]] for c in caught)]
        notes.append('%sinterval %d: period %d, %s, %d of %d ticks still uncaught' % (
            label, n, q, 'returns at wheel %d' % gap if gap is not None else 'no return within %d wheels' % cap,
            len(miss), Q))
        if not miss:
            return n
        if gap is None or n >= nmax:
            return None
        src = wheels[gap - 1]
        doubling = sum(src) % 2 == 1
        results = []
        for i, (w2, g2) in enumerate(follow(src, q, cap, doubling)):
            sub = label + ('' if doubling else 'branch %d / ' % i)
            results.append(walk(w2, g2, caught, n + 1, sub))
        if None in results:
            return None
        return max(results)

    wheels, gap = excursion(word, cap)
    return walk(wheels, gap, [], 0, ''), notes


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ''
    if cmd == 'window':
        word = sys.argv[2]
        nmax = int(sys.argv[3]) if len(sys.argv) > 3 else 3
        cap = int(sys.argv[4]) if len(sys.argv) > 4 else 400
        n, notes = window(word, nmax, cap)
        print('source %s (P = %d): N = %s' % (word, len(word), n))
        for line in notes:
            print('  ' + line)
    elif cmd == 'census':
        pmax = int(sys.argv[2])
        nmax = int(sys.argv[3]) if len(sys.argv) > 3 else 3
        cap = int(sys.argv[4]) if len(sys.argv) > 4 else 400
        print('P  classes  N=0  N=1  N=2+  unresolved   sources with N > 0')
        for p in range(1, pmax + 1):
            counts, odd = {}, []
            for w in classes(p):
                n, _ = window(w, nmax, cap)
                key = 'unresolved' if n is None else min(n, 2)
                counts[key] = counts.get(key, 0) + 1
                if n != 0:
                    odd.append('%s: N = %s' % (w, n))
            print('%2d %7d %4d %4d %5d %11d   %s' % (p, len(classes(p)), counts.get(0, 0), counts.get(1, 0),
                                                  counts.get(2, 0), counts.get('unresolved', 0),
                                                  '; '.join(odd) or '-'))
    else:
        sys.exit(__doc__)


if __name__ == '__main__':
    main()
