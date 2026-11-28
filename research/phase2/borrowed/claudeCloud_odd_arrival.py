#!/usr/bin/env python3
"""claudeCloud_odd_arrival.py: truncations of I330's periodic reference row in time (150, 180), at every width
(ledger K101, pull K92.5.B; the test I330 proposed).

The reference is the infinite white-wall row whose wall column repeats the twelve readings 111110111011 (every even
reading black); its cells come from gptIntel's reconstruction in edge150_periodic.py and are checked here in an
independent cell-by-cell simulator.  A truncation keeps indices 0 .. W-1.  Its first difference from the reference is
at d, the first index >= W where the reference is black, and is first heard at the wall at tick d.  When d is even
the truncation fails at tick d (I330).  When d is odd the first check that can fail is d + 1.

    python3 claudeCloud_odd_arrival.py WMAX

For every width W from 14 to WMAX: d, the first failed even tick F (searched to d + 400), and the delay F - d, then
the delays grouped by the parity of d and by W modulo 18.  COMPUTED.
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def reference_bits(n):
    spec = importlib.util.spec_from_file_location('ep', os.path.join(HERE, 'edge150_periodic.py'))
    sys.path.insert(0, HERE)
    ep = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ep)
    period = 12
    mask = (1 << period) - 1
    even = sum(1 << t for t in range(0, period, 2))
    y, boundary = 125, 0
    for t in range(0, period, 2):
        mid = (y >> 1) ^ y ^ (y << 1)
        boundary |= ((y & 1) << t) | ((mid & 1) << (t + 1))
        y = ep.forward(y)

    def advance(state):
        east, here = state
        shifted = (here >> 1) | ((here & 1) << (period - 1))
        side = ((here ^ east) & even) | (here & ~east & (mask ^ even))
        return here, shifted ^ side

    state, bits = (0, boundary), []
    for _ in range(n):
        bits.append(state[1] & 1)
        state = advance(state)
    return bits, boundary


def first_failure(row, horizon):
    """row: list of bits, index 0 beside the wall.  Tick 2r applies rule 150, tick 2r+1 rule 180."""
    x = row[:] + [0, 0]
    for t in range(horizon + 1):
        if t % 2 == 0 and not x[0]:
            return t
        new = []
        for k in range(len(x) + 1):
            west = x[k + 1] if k + 1 < len(x) else 0
            c = x[k] if k < len(x) else 0
            r = x[k - 1] if k >= 1 else 0
            new.append(west ^ ((c ^ r) if t % 2 == 0 else (c & (1 - r))))
        while new and not new[-1]:
            new.pop()
        x = new + [0]
        if not any(x):
            return t + 1 if (t + 1) % 2 == 0 else t + 2
    return None


def main():
    wmax = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    bits, boundary = reference_bits(wmax + 600)
    print('wall column, low bit first:', format(boundary, '012b')[::-1])
    # the reference itself: a wide truncation must pass every even check until its own cut is heard
    wide = bits[:wmax + 500]
    ref_fail = first_failure(wide, wmax + 400)
    print('a truncation of the reference at width %d first fails at tick %s (it must not fail before %d)'
          % (len(wide), ref_fail, wmax + 400))
    rows = []
    for W in range(14, wmax + 1):
        d = next(i for i in range(W, len(bits)) if bits[i])
        F = first_failure(bits[:W], d + 400)
        rows.append((W, d, F))
    print('W | d (first omitted black) | first failed even tick | delay')
    for W, d, F in rows:
        print('%d | %d | %s | %s' % (W, d, F, F - d if F is not None else 'none'))
    print()
    for par in (0, 1):
        ds = sorted({F - d for W, d, F in rows if d % 2 == par and F is not None})
        none = sum(1 for W, d, F in rows if d % 2 == par and F is None)
        print('d %s: delays %s; no failure found within d + 400: %d' % ('even' if par == 0 else 'odd', ds, none))
    print('by W mod 18 (W >= 90), delays:')
    for res in range(18):
        ds = sorted({F - d for W, d, F in rows if W >= 90 and W % 18 == res and F is not None})
        print('  %2d: %s' % (res, ds))


if __name__ == '__main__':
    main()
