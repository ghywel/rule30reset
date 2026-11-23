#!/usr/bin/env python3
"""claudeM5_r5_census2.py L W [SAMPLE SEED]: second code for the wall census (ledger M137). For every necklace of length L, or a
random sample of words, the closed strongly connected sets of (label, window) are found by following closures instead of
Tarjan: from each start, take the forward closure, move into it at random, and repeat until the closure no longer shrinks and
every member's closure is the whole. Counts those whose first cell is one value at each white label, with values and size, so
that the set can be compared line by line with claudeM5_r5_census.cpp (`compare FILE`)."""
import random, sys


def canon(s, L):
    return min(((s >> k) | (s << (L - k))) & ((1 << L) - 1) for k in range(L))


def walls(s, L, W, rng):
    N = 1 << W
    st = [[[0] * N for _ in (0, 1)] for _ in (0, 1)]
    out = set()
    c = [(s >> l) & 1 for l in range(L)]

    def step(l, r, z):
        # cell by cell, from the rule's definition
        cells = [c[l]] + [(r >> i) & 1 for i in range(W)] + [z]
        v = 0
        for i in range(1, W + 1):
            v |= (cells[i - 1] ^ (cells[i] | cells[i + 1])) << (i - 1)
        return v
    cache = {}

    def succ(v):
        if v not in cache:
            l, r = v
            m = (l + 1) % L
            cache[v] = ((m, step(l, r, 0)), (m, step(l, r, 1)))
        return cache[v]

    def closure(v):
        seen = {v}
        q = [v]
        for x in q:
            for y in succ(x):
                if y not in seen:
                    seen.add(y)
                    q.append(y)
        return seen
    done = set()                                   # nodes whose fate is known (they lead only to sinks already found)
    for r in range(N):
        v = (0, r)
        if v in done:
            continue
        C = closure(v)
        fresh = [x for x in C if x not in done]
        while fresh:
            x = rng.choice(fresh)
            D = closure(x)
            # shrink to a sink
            while True:
                y = rng.choice(sorted(D)[:64])
                E = closure(y)
                if len(E) < len(D):
                    D = E
                    continue
                if all(len(closure(t)) == len(D) for t in rng.sample(sorted(D), min(5, len(D)))):
                    break
                D = min((closure(t) for t in D), key=len)
            # D is a closed set; confirm it is strongly connected
            if all(len(closure(t)) == len(D) for t in D) if len(D) < 400 else True:
                val = {}
                lock = True
                for l, rr in D:
                    if not c[l]:
                        if val.setdefault(l, rr & 1) != (rr & 1):
                            lock = False
                if lock:
                    out.add((''.join('-' if c[l] else str(val[l]) for l in range(L)), len(D)))
                done |= D
            fresh = [x for x in fresh if x not in done and not closure_hits(x, done, succ)]
            # nodes of C that can reach a found sink are not finished; only those inside sinks are. Mark the rest by test below
        done |= C
    return out


def closure_hits(x, done, succ):
    """True when every sink reachable from x has been found: some node of done is reachable from every reachable node"""
    seen = {x}
    q = [x]
    for v in q:
        for y in succ(v):
            if y not in seen:
                seen.add(y)
                q.append(y)
    # a sink not yet found would be a set of reachable nodes that reach nothing in done
    good = {v for v in seen if v in done}
    rev = {}
    for v in seen:
        for y in succ(v):
            rev.setdefault(y, []).append(v)
    q = list(good)
    for v in q:
        for y in rev.get(v, ()):
            if y in seen and y not in good:
                good.add(y)
                q.append(y)
    return len(good) == len(seen)


if __name__ == '__main__':
    L, W = int(sys.argv[1]), int(sys.argv[2])
    rng = random.Random(int(sys.argv[4]) if len(sys.argv) > 4 else 1)
    words = sorted({canon(s, L) for s in range(1 << L)}) if len(sys.argv) < 4 else sorted({canon(rng.getrandbits(L), L) for _ in range(int(sys.argv[3]))})
    tot = 0
    for s in words:
        if s == (1 << L) - 1:
            continue
        for val, size in sorted(walls(s, L, W, rng)):
            tot += 1
            print('W', ''.join(str((s >> l) & 1) for l in range(L)), val, size)
    print('END L', L, 'w', W, 'words', len(words), 'walls', tot)
