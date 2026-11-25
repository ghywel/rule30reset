#!/usr/bin/env python3
"""claudeCloud_k84_demand.py: what a west demands of the right half, and how long any right half can supply it
(ledger K84, N16's suggested test for K83.A).

Beside a centre that is black at even ticks, a west (left half, the kit's packed form: bit k-1 = depth k) keeps the
centre alternating while depth 1 is black at the even ticks; then it evolves as beside a white wall. At each odd tick
t the centre's next bit is z1(t) xor g(t), so the right half's gate (cell 1) must read g(t) = not z1(t). The DEMAND
of the west is that word, read at ticks 1, 3, ..., T-1, where T is the west's death tick (first even tick with depth
1 white): S = T/2 readings.

READABLE: some right half (any support, finite or not) beside the same centre has cell 1 equal to the demand at
ticks 1, 3, ..., 2s-1. Decided by SAT on the whole light cone of those readings: cells (j, t), j >= 1, j + t <= 2s,
which is closed under the rule's dependencies, so nothing outside it matters. The HORIZON s* is the largest s that is
readable (prefixes of readable words are readable). UNSAT is COMPUTED (python-sat, CaDiCaL 1.9.5); a SAT answer is
replayed cell by cell.

    python3 claudeCloud_k84_demand.py demand HEX           the death tick and the demand word of one west
    python3 claudeCloud_k84_demand.py horizon HEX [HEX...]  one JSON line per west: T, S, demand, s*, witness check
"""
import json
import sys
import time


def death_and_demand(r, cap=400):
    t = 0
    z1 = []                                    # depth 1 at ticks 0, 1, 2, ...
    while t <= cap:
        z1.append(r & 1)
        if t % 2 == 0 and not (r & 1):
            T = t
            demand = [1 - z1[u] for u in range(1, T, 2)]
            return T, demand
        r = (r >> 1) ^ (r | (r << 1))
        t += 1
    raise ValueError('no death by tick %d' % cap)


def wall(t):
    return 1 if t % 2 == 0 else 0              # the centre: black at even ticks


class Cone:
    def __init__(self, K):
        self.K = K
        self.var = {}
        nv = 0
        for t in range(K + 1):
            for j in range(1, K - t + 1):
                nv += 1
                self.var[(j, t)] = nv
        self.nv = nv
        cl = []
        for t in range(1, K + 1):
            for j in range(1, K - t + 1):
                n, c, r = self.var[(j, t)], self.var[(j, t - 1)], self.var[(j + 1, t - 1)]
                if j == 1:
                    if wall(t - 1) == 0:      # n = c or r
                        cl += [[-c, n], [-r, n], [c, r, -n]]
                    else:                      # n = not (c or r)
                        cl += [[-c, -n], [-r, -n], [c, r, n]]
                else:
                    l = self.var[(j - 1, t - 1)]
                    cl += [[-c, -n, -l], [-c, n, l], [-r, -n, -l], [-r, n, l], [c, r, -n, l], [c, r, n, -l]]
        self.clauses = cl

    def reading(self, s):                      # cell 1 at tick 2s + 1
        return self.var[(1, 2 * s + 1)]


def replay(row, S):
    """row[i] = cell i + 1 at tick 0 (length >= 2S); returns cell 1 at ticks 1, 3, ..., 2S - 1."""
    x = row[:]
    out = []
    for t in range(2 * S):
        w = wall(t)
        y = [w ^ (x[0] | x[1])] + [x[i - 1] ^ (x[i] | x[i + 1]) for i in range(1, len(x) - 1)]
        x = y
        if t % 2 == 0:
            out.append(x[0])
    return out


def horizon(r, budget=None):
    from pysat.solvers import Cadical195
    T, dem = death_and_demand(r)
    S = len(dem)
    cone = Cone(2 * S)
    t0 = time.time()
    with Cadical195(bootstrap_with=cone.clauses) as sol:
        def ok(s):
            lits = [(cone.reading(u) if dem[u] else -cone.reading(u)) for u in range(s)]
            return sol.solve(assumptions=lits)
        if ok(S):
            best, model = S, set(v for v in sol.get_model() if v > 0)
        else:
            lo, hi = 0, S                      # ok(lo) true, ok(hi) false
            while hi - lo > 1:
                mid = (lo + hi) // 2
                if ok(mid):
                    lo = mid
                else:
                    hi = mid
            best = lo
            ok(best)
            model = set(v for v in sol.get_model() if v > 0)
    row = [1 if cone.var[(j, 0)] in model else 0 for j in range(1, 2 * S + 1)] + [0, 0]
    check = replay(row, best) == dem[:best] if best > 0 else True
    return dict(west=hex(r)[2:], T=T, S=S, demand=''.join(map(str, dem)), horizon=best,
                readable_for_life=(best == S), witness_replayed=check, cone_vars=cone.nv,
                cone_clauses=len(cone.clauses), seconds=round(time.time() - t0, 2))


if __name__ == '__main__':
    mode = sys.argv[1]
    if mode == 'demand':
        T, dem = death_and_demand(int(sys.argv[2], 16))
        print(T, ''.join(map(str, dem)))
    elif mode == 'horizon':
        for h in sys.argv[2:]:
            print(json.dumps(horizon(int(h, 16))), flush=True)
