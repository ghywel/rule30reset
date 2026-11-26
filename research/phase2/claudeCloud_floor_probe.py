#!/usr/bin/env python3
"""claudeCloud_floor_probe.py: the least number of black cells in a west that a right half can serve (ledger K92).

A development probe, run while choosing the phase-2 pulls: nothing was registered before it.

Beside a centre that is black at even ticks, a gate word of m readings decodes to the one west prefix of depth 2m + 1
that keeps the centre alternating (I246's Lean; the decoder is K88's).  The words come from
  - I246's complete census of the gate words some right half reads (to 43 readings): exact;
  - I246's lists of the words an 18- or 22-column strip with free outer cells reads: supersets;
  - the distinct words of I246's 60-reading sample of real right halves: a subset.
Where a superset and a subset agree, the least count over real right halves is exact.

Table 1 counts the black cells of the decoded west at its black tick, depth T = 2m + 1.

Table 2 moves one tick on, to the kit's convention for its mass conjecture (Rule30PeriodTwoMass): the row at a white
tick with cell -1 white, of weight A below H = 2m, whose wall trace under the zero-wall map is then a G word of
length H (checked on every row counted).  The kit's Conjecture S, 7A >= H + 4, is kernel-checked for every G word to
H = 90 and refuted at arbitrarily late H by Galindo's rows with H = 7A + 9 (Rule30MassCounterexamples).

Part 3 takes the infinite row those counterexamples are cut from (sites 2 and 4 and the spikes at 1 + 7i) and asks
how long some right half reads what it demands.

    python3 claudeCloud_floor_probe.py DIR      DIR holds strip18-53.txt, counts18.jsonl, strip22-60.txt and
                                                sample-60.tsv from share-scratch/gptIntel/K84/k84-I246.zip
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def zero_wall(y):
    """The kit's zero-wall map IntegerForm.F: bit i is the cell at depth i + 1."""
    return (y >> 1) ^ (y | (y << 1))


def g_length(x, n):
    """How many of the wall readings at times 0 .. n - 1 form a G word: white at 0, black at odd times, no two
    successive even times white."""
    last_even = None
    for t in range(n):
        b = x & 1
        if (t == 0 and b) or (t % 2 == 1 and not b) or (t % 2 == 0 and t and not b and not last_even):
            return t
        if t % 2 == 0:
            last_even = b
        x = zero_wall(x)
    return n


def main():
    d = sys.argv[1]
    argv, sys.argv = sys.argv, ['x', 'none']
    env = {}
    exec(open(os.path.join(HERE, '..', 'rule4', 'k84', 'claudeCloud_k84_tree.py')).read().split('def main():')[0], env)
    sys.argv = argv
    decode_west, load_census = env['decode_west'], env['load_census']
    census = load_census(os.path.join(d, 'strip18-53.txt'), os.path.join(d, 'counts18.jsonl'))
    strip18 = [int(l) for l in open(os.path.join(d, 'strip18-53.txt'), encoding='utf-8-sig')]
    strip22 = [int(l) for l in open(os.path.join(d, 'strip22-60.txt'), encoding='utf-8-sig')]
    sample = [int(l.split()[0]) for l in open(os.path.join(d, 'sample-60.tsv'), encoding='utf-8-sig')]

    def gaps(w, m):
        ks = [i for i in range(m) if (w >> (m - 1 - i)) & 1]
        return ''.join(str(b - a) for a, b in zip(ks, ks[1:]))

    def at_black(w, m):
        return bin(decode_west(w, 2 * m + 1)).count('1')

    def at_kick(w, m):
        x0 = decode_west(w, 2 * m + 1)
        x1 = ((x0 >> 1) ^ (x0 | (x0 << 1) | 1)) & ((1 << (2 * m)) - 1)      # one tick on, beside the black centre
        if x1 & 1:
            return None                                                    # cell -1 black: not at a kick
        assert g_length(x1, 2 * m) == 2 * m
        return bin(x1).count('1')

    def least(count, words, have, m):
        best = None
        for w in set(x >> (have - m) for x in words):
            c = count(w, m)
            if c is not None and (best is None or c < best[0]):
                best = (c, w)
        return best

    for title, count, depth in (('Table 1. The decoded west at its black tick: least black cells to depth T = 2m + 1', at_black, 1),
                                ('Table 2. One tick on, at a kick: least weight A below H = 2m', at_kick, 0)):
        print(title)
        print('m | %s | census, exact | 18-column strip | 22-column strip | sample of real halves | exact value | '
              'kit S: ceil((H + 4)/7) | gaps of a sparsest gate' % ('T' if depth else 'H'))
        for m in range(10, 61, 5):
            cen = least(count, census[m], m, m) if m <= 43 else None
            s18 = least(count, strip18, 53, m) if m <= 53 else None
            s22 = least(count, strip22, 60, m)
            sam = least(count, sample, 60, m)
            exact = cen[0] if cen else (sam[0] if sam and sam[0] == s22[0] else None)
            size = 2 * m + depth
            print(m, '|', size, '|', cen[0] if cen else '-', '|', s18[0] if s18 else '-', '|', s22[0], '|',
                  sam[0] if sam else '-', '|', exact if exact is not None else '%d to %d' % (s22[0], sam[0]), '|',
                  '-' if depth else -(-(size + 4) // 7), '|', gaps((cen or sam or s22)[1], m))
        print()

    print('Part 3. The row with black cells at sites 2 and 4 and at 1 + 7i (bit i is depth i + 1)')
    x = (1 << 2) | (1 << 4) | sum(1 << (1 + 7 * i) for i in range(400))
    trace, y = [], x
    for _ in range(400):
        trace.append(y & 1)
        y = zero_wall(y)
    print('G word for', g_length(x, 400), 'of 400 readings; weight below 280:', bin(x & ((1 << 280) - 1)).count('1'))
    demand = lambda m: sum((1 - trace[2 * j]) << (m - j) for j in range(1, m + 1))      # the right half must show the
    print('its demand, 40 readings:', format(demand(40), '040b'))                          # opposite of cell -1
    read = [m for m in range(1, 44) if demand(m) in census[m]]
    print('some right half reads it for', max(read), 'readings and none for', max(read) + 1, '(census to 43)')
    print('18-column strip:', max(m for m in range(1, 54) if demand(m) in set(w >> (53 - m) for w in strip18)),
          'readings; 22-column strip:', max(m for m in range(1, 61) if demand(m) in set(w >> (60 - m) for w in strip22)))


main()
