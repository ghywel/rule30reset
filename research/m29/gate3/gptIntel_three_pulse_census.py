#!/usr/bin/env python3
"""Exact census of weight-three sources, one per rotation, with temporal bitsets.

Example: python gptIntel_three_pulse_census.py 4 8 16 32 64 128 256 512
The horizon is a stopping limit; unclosed phases or an early return are reported.
"""
import argparse
from collections import Counter
from itertools import combinations
from math import comb


def rotate(x, shift, length, mask):
    return ((x << shift) & mask) | (x >> (length - shift))


def child(a, b, q, mask):
    """Compose the Boolean affine single-tick maps in powers of two."""
    if b == 0:
        raise ValueError('periodic child is not forced after a white column')
    d = rotate(a ^ b, 1, q, mask)
    e = rotate(mask ^ b, 1, q, mask)
    shift = 1
    while e:
        assert shift < q
        d ^= e & rotate(d, shift, q, mask)
        e &= rotate(e, shift, q, mask)
        shift *= 2
    return d


def trace_word(word, cap):
    """Return latest strict catch, uncaught count, first white; stop after all catches."""
    p = len(word)
    assert word.count('1') % 2
    q = 2 * p
    half = (1 << p) - 1
    mask = (1 << q) - 1
    value, low = 0, 0
    for t, ch in enumerate(word):
        low |= value << t
        value ^= int(ch)
    first = low | ((half ^ low) << p)
    return trace_first(first, q, cap)


def trace_first(first, q, cap):
    mask = (1 << q) - 1
    a, b = 0, first
    residue1, residue2, pending = 0, 0, mask
    latest = 0
    for wheel in range(1, cap + 1):
        if b == 0:
            return latest, pending.bit_count(), wheel
        close = pending & residue1 & ~b
        if close:
            latest = wheel
            pending ^= close
        if not pending:
            return latest, 0, None
        residue1, residue2 = b & ~(residue1 | residue2), b & residue1
        a, b = b, (mask if wheel == 1 else child(a, b, q, mask))
    return latest, pending.bit_count(), None


def triples(p):
    """Choose the least cyclic rotation of the three clockwise gaps, retaining reflections."""
    for a in range(1, p // 3 + 1):
        for b in range(a, p - 2 * a + 1):
            c = p - a - b
            if (a, b, c) <= (b, c, a) and (a, b, c) <= (c, a, b):
                yield a, b, c


def first_column(p, a, b):
    half = (1 << p) - 1
    lo = (((1 << a) - 1) << 1) | (half ^ ((1 << (a + b + 1)) - 1))
    return lo | ((lo ^ half) << p)


def census(p, cap, maximum_gap=None):
    histogram = Counter()
    worst, witness, missing, first_miss = 0, None, 0, None
    threefold = False
    for a, b, c in triples(p):
        if maximum_gap is not None and max(a, b, c) > maximum_gap:
            continue
        threefold |= a == b == c
        first = first_column(p, a, b)
        last, bare, white = trace_first(first, 2 * p, cap)
        histogram[last] += 1
        if bare:
            missing += 1
            if first_miss is None:
                first_miss = (a, b, c, bare, white)
        if last > worst:
            worst, witness = last, (a, b, c)
    n = sum(histogram.values())
    if maximum_gap is None:
        # All labelled triples have orbit size p except the repeated equal-gap word.
        assert n * p - (2 * p // 3 if threefold else 0) == comb(p, 3)
    return n, worst, witness, missing, first_miss


def bounded_gaps(bound, first, last, cap):
    """Primitive three-pulse necklaces in the gap cube; split by least gap for parallel checks."""
    hist = Counter()
    earliest_witness = None
    peak, missing, total = 0, 0, 0
    for a in range(first, min(bound, last) + 1):
        for b in range(a, bound + 1):
            for c in range(a, bound + 1):
                gaps = (a, b, c)
                if a == b == c or gaps > (b, c, a) or gaps > (c, a, b):
                    continue
                p = a+b+c
                latest, bare, white = trace_first(first_column(p,a,b),2*p,cap)
                total += 1
                hist[latest] += 1
                if bare:
                    missing += 1
                    if missing == 1:
                        print('incomplete',gaps,latest,bare,white,flush=True)
                if latest > peak:
                    peak, earliest_witness = latest, gaps
    # Nonconstant gap triples have precisely three rotations.
    expected = ((bound-first+1)**3 - (bound-last)**3 - (last-first+1)) // 3
    assert total == expected
    print(f'gap cube={bound} minimum={first}..{last} classes={total} '
          f'peak={peak} gaps={earliest_witness} missing={missing} cap={cap}', flush=True)


def controls():
    from claudeCloud_excursions import excursion, first_resets
    for p in range(3, 14):
        gaps = set(triples(p))
        canonical = set()
        for i, j in combinations(range(1, p), 2):
            gs = (i, j-i, p-j)
            canonical.add(min(gs[t:]+gs[:t] for t in range(3)))
        assert canonical == gaps
        for a, b, c in gaps:
            word = '1' + '0'*(a-1) + '1' + '0'*(b-1) + '1' + '0'*(c-1)
            wheels, white = excursion(word, 96)
            fr = first_resets(wheels[:-1] if white else wheels)
            expected = (max((v for v in fr if v), default=0), fr.count(None))
            got = trace_word(word, 96)
            assert got[:2] == expected and got == trace_first(first_column(p,a,b), 2*p,96)
            for i in range(2,len(wheels)-1):
                def pack(bits): return sum(x << t for t,x in enumerate(bits))
                assert child(pack(wheels[i-1]),pack(wheels[i]),2*p,(1<<(2*p))-1) == pack(wheels[i+1])
    assert trace_word('00001',96)[1:] == (2,23)
    print('control: all triple classes P=3..13 match the scalar column simulator; period-5 obstruction recovered',flush=True)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('period', nargs='*', type=int)
    p.add_argument('--cap', type=int, default=100)
    p.add_argument('--controls', action='store_true')
    p.add_argument('--max-gap', type=int)
    p.add_argument('--box', type=int, help='maximum allowed cyclic gap for primitive triples')
    p.add_argument('--least', type=int, nargs=2, metavar=('FIRST','LAST'))
    args = p.parse_args()
    if args.box:
        lo, hi = args.least or (1, args.box)
        assert 1 <= lo <= hi <= args.box
        bounded_gaps(args.box, lo, hi, args.cap)
    if args.controls:
        controls()
    for period in args.period:
        print(period, census(period,args.cap,args.max_gap), flush=True)
