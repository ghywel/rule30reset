"""Scan: which rotation orders of the gaps 3 and 5 (3 when the point is in an arc of length g) survive wide strips for long words?"""
import sys, random, time
from claudeIntel_strip import survives, gapword, arc_order

def returns(al, ga):
    c = arc_order(al, ga, 3000, 0.1234)
    ones = [i for i, x in enumerate(c) if x]
    return sorted(set(b - a for a, b in zip(ones, ones[1:])))

if __name__ == '__main__':
    rng = random.Random(8)
    t0 = time.time()
    stats = {}
    surv = []
    for trial in range(420):
        al = rng.random(); ga = rng.choice([rng.uniform(.02, .2), rng.uniform(.2, .5)])
        c = arc_order(al, ga, 400, rng.random())
        w = gapword([3 if x else 5 for x in c], 500)
        dead = None
        for W in (10, 12, 14, 16, 18):
            k, left = survives(w, W)
            if not left: dead = W; break
        stats[dead] = stats.get(dead, 0) + 1
        if dead is None: surv.append((al, ga, returns(al, ga)))
        if time.time() - t0 > 420: break
    print('trials', sum(stats.values()), 'killed at width', stats)
    from collections import Counter
    print('return times of the survivors (runs of 5 are one less):', Counter(str(r[2]) for r in surv).most_common(25))
    for al, ga, r in surv[:12]: print('%.5f %.4f %s' % (al, ga, r))
