"""Two blocks of gaps in the order of the parity of floor(t sqrt 2) (the silver half-circle word): which survive wide strips?"""
import sys, time
from math import isqrt
from claudeIntel_strip import survives, gapword
order = [isqrt(2 * t * t) % 2 for t in range(1, 2000)]
t0 = time.time()
found = []
for name, A, B in [('3 5^%d | 3 5^%d' % (a, b), [3] + [5] * a, [3] + [5] * b) for a in range(0, 6) for b in range(0, 7) if a != b] + \
                  [('5 | 3 5^%d' % a, [5], [3] + [5] * a) for a in range(0, 4)] + [('2 5^%d | 2 5^%d' % (a, b), [2] + [5] * a, [2] + [5] * b) for a in range(1, 5) for b in range(a + 1, 6)] + \
                  [('2 2 5 | 5', [2, 2, 5], [5]), ('2 4 5 | 5', [2, 4, 5], [5]), ('2 4 5 5 | 5 5', [2, 4, 5, 5], [5, 5]), ('3 3 5 | 5', [3, 3, 5], [5]), ('3 3 5 5 5| 5 5', [3, 3, 5, 5, 5], [5, 5]), ('2 4 5 | 3 5', [2, 4, 5], [3, 5])]:
    gaps = []
    for o in order:
        gaps += A if o else B
        if sum(gaps) > 900: break
    w = gapword(gaps, 800)
    res = []
    for W in (10, 14, 16, 18, 20):
        k, left = survives(w, W)
        if not left: res.append('dies at width %d, sample %d' % (W, k)); break
    if not res: found.append(name); res.append('survives to width 20, 800 samples')
    print('%-22s %s' % (name, res[-1])); sys.stdout.flush()
    if time.time() - t0 > 500: break
print('survivors', found)
