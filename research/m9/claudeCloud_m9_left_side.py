#!/usr/bin/env python3
"""claudeCloud_m9_left_side.py: pull M9, third block (ledger K51, addendum 2). The LEFT side of the gate languages
outside the trap. Placego L1569 read the two exterior components exactly: X is the loop A = 25 with the excursion
E = 33535555 (4 or at least 6 copies of A between excursions), Y is the loop 2 with excursions 45 and 4525. Its own
pull, the left statement for these languages, was not done. This is M8's reach test on them.

A gate word is a word of kick gaps. The free word of the left row has a white bit at each kick and black elsewhere
(kit: Psi R = Theta (not u R)). Theta is computed as in research/m8/claudeCloud_m8_reach.py.

  python3 claudeCloud_m9_left_side.py run
"""
import os
import random
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm8'))
import claudeCloud_m8_reach as m8      # noqa: E402

A, E = '25', '33535555'


def free_word(gaps):
    """Kick-gap word -> (f as int, length): bit s = 0 at a kick, 1 elsewhere; a kick at index 0."""
    pos, kicks = 0, [0]
    for g in gaps:
        pos += int(g)
        kicks.append(pos)
    L = pos + 1
    f = (1 << L) - 1
    for k in kicks:
        f &= ~(1 << k)
    return f, L


def row_bits(f, L):
    r = m8.theta(f, L)
    return [(r >> d) & 1 for d in range(1, 2 * L + 2)]


def longest_white(bits, lo, hi):
    best = run = 0
    for b in bits[lo:hi]:
        run = 0 if b else run + 1
        best = max(best, run)
    return best


def spatial_period(bits, lo, hi):
    for p in range(1, 200):
        if all(bits[i] == bits[i + p] for i in range(lo, hi - p)):
            return p
    return None


def run():
    rng = random.Random(51)
    print('1. pure loops and periodic words: the row of Theta')
    for name, unit in (('A = 25', A), ('2', '2'), ('2245', '2245'), ('A^6 E', A * 6 + E), ('A^4 E', A * 4 + E), ('35 (trap)', '35')):
        gaps = unit * (700 // sum(int(c) for c in unit))
        f, L = free_word(gaps)
        bits = row_bits(f, L)
        lo, hi = 200, L          # depths safely inside what the word determines
        print('   %-10s black share %.3f, longest white run %d, spatial period of the row %s' % (
            name, sum(bits[lo:hi]) / (hi - lo), longest_white(bits, lo, hi), spatial_period(bits, lo, hi)))
    print('2. reach of one flipped free bit inside a loop word (beyond its entry depth; limit = room)')
    for name, unit in (('A = 25', A), ('2', '2'), ('A^6 E', A * 6 + E)):
        gaps = unit * (420 // sum(int(c) for c in unit))
        f, L = free_word(gaps)
        base = m8.theta(f, L)
        out = []
        for s in (10, 20, 40, 60, 80, 100):
            x = m8.reach(f, L, s, base=base) - (2 * s + 2)
            out.append('%d:%d/%d' % (s, x, 2 * L + 1 - (2 * s + 2)))
        print('   %-8s bit:reach/room  %s' % (name, '  '.join(out)))
    print('3. memory inside X: two X-words that differ before a common tail beginning A^k')
    for k in (4, 6, 8, 12, 20):
        worst, vals = 0, []
        for _ in range(40):
            n1, n2 = rng.sample([6, 7, 8, 9, 10, 11], 2)
            p1 = E + A * n1 + E + A * n2 + E
            p2 = E + A * n2 + E + A * n1 + E
            tail = A * k + ''.join(E + A * rng.choice([6, 7, 8, 9]) for _ in range(6))
            f1, L1 = free_word(p1 + tail)
            f2, L2 = free_word(p2 + tail)
            assert L1 == L2
            cut = sum(int(c) for c in p1)                       # free-bit index where the tail begins
            d = (m8.theta(f1, L1) ^ m8.theta(f2, L1)).bit_length() - 1
            vals.append(d - 2 * cut)
        vals.sort()
        print('   k = %2d: deepest difference beyond the tail start: least %d, median %d, greatest %d (room %d)' % (
            k, vals[0], vals[len(vals) // 2], vals[-1], 2 * L1 + 1 - 2 * cut))
    print('4. black cells in the rows of random X-words (spacings 6 to 11) and of the Y-word (2245)^n')
    worst = 0
    for _ in range(60):
        gaps = ''.join(A * rng.choice([6, 7, 8, 9, 10, 11]) + E for _ in range(6))
        f, L = free_word(gaps)
        bits = row_bits(f, L)
        worst = max(worst, longest_white(bits, 100, L))
    print('   X: the longest white run over 60 random words: %d' % worst)


if __name__ == '__main__':
    run()
