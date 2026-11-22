#!/usr/bin/env python3
"""claudeCloud_k50_4_read.py: pull K50.4 (ledger K61). Holds the seed's triangles against the uniform law.

Inputs: the tables written by claudeCloud_k50_4_cascade.cpp in mode uniform (RUN = MINRUN) and in mode seed.
For each number of rows up j:
    the share of each node of stage j + 1, uniform and seed, and the largest difference;
    the defect's distribution, uniform and seed: means and total-variation distance;
    from the full windows: the mean of (patch minus run), and the share of triangles whose patch is at least
    as long as the run itself;
    the share of triangles whose pattern continues at all to the left of the window (the argument in the post
    says none can).
The frozen rule: AGREES at j when the total-variation distance and the largest share difference are both at
most 0.02.

With a third argument (left, middle or right) the node shares and defects are those of that zone alone; the
columns from the full windows stay those of the whole diagram.

    python3 claudeCloud_k50_4_read.py UNIFORM_PREFIX SEED_PREFIX [ZONE]
"""
import sys
from collections import defaultdict


def load(path):
    T = defaultdict(dict)
    with open(path) as f:
        next(f)
        for line in f:
            j, k, c = line.split('\t')
            T[int(j)][int(k)] = int(c)
    return T


def norm(d):
    s = sum(d.values())
    return {k: v / s for k, v in d.items()}, s


def main():
    uni, seed = sys.argv[1], sys.argv[2]
    Un, Ud = load(uni + '.node.tsv'), load(uni + '.defect.tsv')
    zone = ('.' + sys.argv[3]) if len(sys.argv) > 3 else ''
    print('zone: %s' % (sys.argv[3] if zone else 'the whole diagram'))
    Sn, Sd = load(seed + zone + '.node.tsv'), load(seed + zone + '.defect.tsv')
    Sf, Se = load(seed + '.full.tsv'), load(seed + '.ext.tsv')
    print('rows up | stage | triangles | nodes | largest share difference | mean defect uniform, seed | TV distance | verdict | '
          'mean patch minus run | share with patch >= run | share continued left')
    allok = True
    for j in sorted(Sd):
        un, _ = norm(Un[j]); sn, N = norm(Sn[j])
        ud, _ = norm(Ud[j]); sd, _ = norm(Sd[j])
        share = max(abs(un.get(k, 0) - sn.get(k, 0)) for k in set(un) | set(sn))
        tv = 0.5 * sum(abs(ud.get(k, 0) - sd.get(k, 0)) for k in set(ud) | set(sd))
        mu = sum(k * v for k, v in ud.items()); ms = sum(k * v for k, v in sd.items())
        sf, _ = norm(Sf[j]); grow = sum(k * v for k, v in sf.items()); keep = sum(v for k, v in sf.items() if k >= 0)
        se, _ = norm(Se[j]); left = sum(v for k, v in se.items() if k > 0)
        ok = share <= 0.02 and tv <= 0.02; allok &= ok
        print('%2d | %2d | %d | %d | %.4f | %.3f, %.3f | %.4f | %s | %+.3f | %.4f | %.4f'
              % (j, j + 1, N, len(un), share, mu, ms, tv, 'AGREES' if ok else 'DIFFERS', grow, keep, left))
    print('seed against the uniform law at every row: %s' % ('AGREES' if allok else 'DIFFERS at some row'))
    print('node shares at the last row, uniform then seed:')
    j = max(Sd); un, _ = norm(Un[j]); sn, _ = norm(Sn[j])
    for k in sorted(set(un) | set(sn)):
        print('   node %d: %.4f  %.4f' % (k, un.get(k, 0), sn.get(k, 0)))


if __name__ == '__main__':
    main()
