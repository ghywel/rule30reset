#!/usr/bin/env python3
"""make_tour.py T001.json T011.json: for each trap a closed walk through all its windows, as the letters (three cells beyond the
window, 0 to 7) of successive periods. A proposal; the Lean checks it. Nearest new window first, then the way home."""
import json
import sys
from collections import deque


def tour(d):
    K, DR = set(d['K']), d['DR']

    def per(x):
        for b in DR:
            x = ((x << 1) | b) ^ (x | (x >> 1))
        return x
    nx = {x: {per(x | (e << 14)) & 16383: e for e in range(7, -1, -1)} for x in K}

    def path(a, goal):
        seen, q = {a: None}, deque([a])
        while q:
            u = q.popleft()
            if u != a and goal(u):
                w = []
                while seen[u] is not None:
                    u, e = seen[u]
                    w.append(e)
                return w[::-1]
            for v, e in sorted(nx[u].items()):
                if v not in seen:
                    seen[v] = (u, e)
                    q.append(v)
    r = min(K)
    cur, done, w = r, {r}, []
    while len(done) < len(K):
        for e in path(cur, lambda u: u not in done):
            cur = per(cur | (e << 14)) & 16383
            done.add(cur)
            w.append(e)
    for e in path(cur, lambda u: u == r) if cur != r else []:
        cur = per(cur | (e << 14)) & 16383
        w.append(e)
    assert cur == r and done == K
    return r, w


if __name__ == '__main__':
    for f in sys.argv[1:]:
        d = json.load(open(f))
        r, w = tour(d)
        print(d['word'], 'start', r, 'letters', len(w))
