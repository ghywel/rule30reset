"""I295.1, claudeIntel: does a longer gap memory make every recurrent part of the 13-cell graph prescribed?

Written afresh from the kit's strip step (no code shared with claudeCloud_*.py). The K cells east of the centre are a
state below 2^K, bit k the cell k+1 sites east. One tick with centre letter a and free cell z beyond the strip:
    s -> ((s << 1) | a) ^ (s | (s >> 1) | (z << (K - 1)))  mod 2^K.
A block of gap q is one black tick then q white ticks; its readings are bit 0 at the q white ticks (they cannot depend
on the free cells while q + 1 < K). States: the closure of all block images of all 2^K states.

Nodes are (state, memory), the memory being the last d gaps, avoiding the forbidden factors. Lasting nodes are those
with arbitrarily long histories. For each recurrent part, is the block's reading a function of (memory, next gap) on
the edges that stay in the part? Then Galindo's ranked argument, with a different set at each end of a block,
excludes every cyclic word of the language.

Usage: python -I claudeIntel_memory.py K FACTOR[,FACTOR...] DEPTH[,DEPTH...] out.json   e.g. 13 777,7979 3,4,5,6
"""
import json
import sys
from itertools import product

import numpy as np

sys.setrecursionlimit(100000)


def tables(K):
    s = np.arange(1 << K, dtype=np.int64)
    return {(a, z): (((s << 1) | a) ^ (s | (s >> 1) | (z << (K - 1)))) % (1 << K) for a in (0, 1) for z in (0, 1)}


def block_all(states, q, T):
    cur = np.zeros(len(T[(0, 0)]), dtype=bool)
    cur[list(states)] = True
    for i in range(q + 1):
        a = 1 if i == 0 else 0
        nxt = np.zeros_like(cur)
        for z in (0, 1):
            nxt[T[(a, z)][cur]] = True
        cur = nxt
    return set(np.flatnonzero(cur).tolist())


def block_one(s, q, T):
    cur = {s}
    reading = []
    for i in range(q + 1):
        a = 1 if i == 0 else 0
        if i > 0:
            vals = {x & 1 for x in cur}
            assert len(vals) == 1
            reading.append(vals.pop())
        cur = {int(T[(a, z)][x]) for x in cur for z in (0, 1)}
    if True:
        pass
    return frozenset(cur), tuple(reading)


def tarjan(n, edges):
    index, low, onstack, comp = [None] * n, [0] * n, [False] * n, [None] * n
    stack, c, counter = [], 0, 0
    for root in range(n):
        if index[root] is not None:
            continue
        work = [(root, 0)]
        index[root] = low[root] = counter; counter += 1
        stack.append(root); onstack[root] = True
        while work:
            v, i = work[-1]
            if i < len(edges[v]):
                work[-1] = (v, i + 1)
                w = edges[v][i]
                if index[w] is None:
                    index[w] = low[w] = counter; counter += 1
                    stack.append(w); onstack[w] = True
                    work.append((w, 0))
                elif onstack[w]:
                    low[v] = min(low[v], index[w])
            else:
                work.pop()
                if work:
                    low[work[-1][0]] = min(low[work[-1][0]], low[v])
                if low[v] == index[v]:
                    while True:
                        w = stack.pop(); onstack[w] = False; comp[w] = c
                        if w == v:
                            break
                    c += 1
    return comp, c


def analyse(K, factors, d, T, states, succ, read):
    letters = (7, 9)
    clean = lambda w: not any(tuple(w[i:i + len(f)]) == f for f in factors for i in range(len(w) - len(f) + 1))
    mems = [m for m in product(letters, repeat=d) if clean(m)]
    mi = {m: i for i, m in enumerate(mems)}
    moves = {m: [(q, (m + (q,))[1:]) for q in letters if clean(m + (q,)) and (m + (q,))[1:] in mi] for m in mems}
    sidx = {s: i for i, s in enumerate(states)}
    n, M = len(states), len(mems)
    node = lambda s, m: sidx[s] * M + mi[m]
    out = [[] for _ in range(n * M)]
    for s in states:
        for m in mems:
            for q, m2 in moves[m]:
                out[node(s, m)] += [(q, node(t, m2)) for t in succ[(s, q)]]
    cur = set(range(n * M))
    rounds = 0
    while True:
        nxt = {w for v in cur for _, w in out[v]} & cur
        if nxt == cur:
            break
        cur, rounds = nxt, rounds + 1
    live = sorted(cur)
    li = {v: i for i, v in enumerate(live)}
    edges = [[li[w] for _, w in out[v] if w in li] for v in live]
    comp, nc = tarjan(len(live), edges)
    members = {}
    for i, c in enumerate(comp):
        members.setdefault(c, []).append(i)
    rec = [c for c, ns in members.items() if len(ns) > 1 or ns[0] in edges[ns[0]]]
    parts = []
    for c in sorted(rec, key=lambda c: -len(members[c])):
        ns = set(members[c])
        kinds = {}
        for i in ns:
            v = live[i]
            s, m = states[v // M], mems[v % M]
            for q, w in out[v]:
                if w in li and li[w] in ns:
                    kinds.setdefault((m, q), set()).add(read[(s, q)])
        worst = max(len(x) for x in kinds.values())
        parts.append({"nodes": len(ns), "states": len({live[i] // M for i in ns}), "max_readings_per_memory_gap": worst})
    # longest chain outside recurrent parts, and the number of rank levels a Galindo-style rank would need
    recset = set(rec)
    order = sorted(range(len(live)), key=lambda i: comp[i])
    height = [0] * len(live)
    for i in order:
        if comp[i] in recset:
            continue
        height[i] = 1 + max([height[j] for j in edges[i] if comp[j] not in recset] + [0])
    return {"cells": K, "factors": [list(f) for f in factors], "depth": d, "memories": M, "lasting_nodes": len(live),
            "rounds_to_settle": rounds, "recurrent_parts": parts,
            "all_prescribed": all(p["max_readings_per_memory_gap"] == 1 for p in parts),
            "longest_transient_chain": max(height) if height else 0}


def main():
    K = int(sys.argv[1])
    factors = [tuple(int(ch) for ch in f) for f in sys.argv[2].split(",")]
    depths = [int(x) for x in sys.argv[3].split(",")]
    outp = sys.argv[4]
    T = tables(K)
    own = set()
    for q in (7, 9):
        own |= block_all(range(1 << K), q, T)
    while True:
        more = set(own)
        for q in (7, 9):
            more |= block_all(own, q, T)
        if more == own:
            break
        own = more
    states = sorted(own)
    succ, read = {}, {}
    for s in states:
        for q in (7, 9):
            ends, rd = block_one(s, q, T)
            succ[(s, q)], read[(s, q)] = sorted(ends), rd
            assert ends <= own
    print(K, "cells:", len(states), "states", flush=True)
    rows = []
    for d in depths:
        r = analyse(K, factors, d, T, states, succ, read)
        rows.append(r)
        print(json.dumps(r), flush=True)
        open(outp, "w", encoding="ascii", newline="\n").write(json.dumps({"states": len(states), "rows": rows}, indent=1) + "\n")


if __name__ == "__main__":
    main()
