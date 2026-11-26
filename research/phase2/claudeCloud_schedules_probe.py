#!/usr/bin/env python3
"""claudeCloud_schedules_probe.py: which periodic kick schedules real right halves read, and what their wests weigh (K92).

A development probe.  For each schedule and phase: how many of the 43 census readings some right half reads, and the
number of black cells of the decoded west to depth 87 at its black tick and to depth 86 one tick on.

    python3 claudeCloud_schedules_probe.py DIR      DIR as for claudeCloud_floor_probe.py
"""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
d = sys.argv[1]
argv, sys.argv = sys.argv, ['x', 'none']
env = {}
exec(open(os.path.join(HERE, '..', 'rule4', 'k84', 'claudeCloud_k84_tree.py')).read().split('def main():')[0], env)
sys.argv = argv
decode_west, load_census = env['decode_west'], env['load_census']
census = load_census(os.path.join(d, 'strip18-53.txt'), os.path.join(d, 'counts18.jsonl'))
m = 43
for name, gaps in (('2', [2]), ('3', [3]), ('5', [5]), ('2,5', [2, 5]), ('4', [4]), ('3,5', [3, 5])):
    P = sum(gaps)
    res = []
    for phase in range(P):
        k, g, pos = phase, 0, set()
        while k < 400:
            pos.add(k); k += gaps[g % len(gaps)]; g += 1
        word = lambda n: sum((1 << (n - 1 - i)) for i in range(n) if i in pos)
        longest = max([n for n in range(1, m + 1) if word(n) in census[n]] or [0])
        T = 2 * m + 1
        x0 = decode_west(word(m), T)
        x1 = ((x0 >> 1) ^ (x0 | (x0 << 1) | 1)) & ((1 << (2 * m)) - 1)
        res.append('phase %d: read for %s readings, weight %d at the black tick, %d one tick on%s' % (phase, '43+' if longest == m else longest, bin(x0).count('1'), bin(x1).count('1'), '' if x1 & 1 else ' (a kick)'))
    print('kick gaps', name); print('   ' + '\n   '.join(res))
