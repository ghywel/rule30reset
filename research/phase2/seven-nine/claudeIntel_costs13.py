"""I295.1, claudeIntel: kernel costs, in state-ticks, of the candidate pieces of a 13-cell certificate (development).

Same universe, language automaton and graph as claudeIntel_design13.py, whose functions it loads.
  - the cost of a block image from one state (the free cell doubles a small set at every tick);
  - inside each small part, the coarsest partition whose classes map into one class under each gap (inside moves),
    and the cost of one block image per class;
  - for the transient nodes of each level, the cost of showing no path stays among them for ever: the sets Z_j of
    nodes reached by j in-level steps, until empty;
  - the warm-up: the possible nodes after j blocks from the whole universe, until they lie in the union of the regions.

Usage: python -I claudeIntel_costs13.py claudeIntel_design13.py MixedGapClocks.lean out.json
"""
import importlib.util
import json
import re
import sys

import numpy as np

spec = importlib.util.spec_from_file_location("design13", sys.argv[1])
D13 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(D13)
N, DFA, DS, K = D13.N, D13.DFA, D13.DS, D13.K


def mask(states):
    m = np.zeros(N, dtype=bool)
    m[list(states)] = True
    return m


def block_cost(states, q):
    return int(sum(x.sum() for x in D13.block_masks(mask(states), q)[:-1]))


def main():
    src = open(sys.argv[2], encoding="utf-8").read()
    Fv = int(re.search(r"def F : Nat := 0x([0-9a-f]+)", src).group(1), 16)
    F12 = {x for x in range(4096) if (Fv >> x) & 1}
    U = sorted(x for x in range(N) if (x & 4095) in F12)
    succ, read = {}, {}
    for x in U:
        for q in (7, 9):
            succ[(x, q)], read[(x, q)] = D13.block_one(x, q)
    ui = {x: i for i, x in enumerate(U)}
    nd = len(DS)
    node = lambda x, dd: ui[x] * nd + DS.index(dd)
    nn = len(U) * nd
    out = [[] for _ in range(nn)]
    for x in U:
        for dd in DS:
            for q, d2 in DFA[dd].items():
                out[node(x, dd)] += [(q, node(t, d2)) for t in succ[(x, q)]]
    edges = [[w for _, w in out[v]] for v in range(nn)]
    comp, nc = D13.tarjan(nn, edges)
    mem = {}
    for v, c in enumerate(comp):
        mem.setdefault(c, []).append(v)
    rec = sorted([c for c, ns in mem.items() if len(ns) > 1 or ns[0] in edges[ns[0]]], key=lambda c: -len(mem[c]))
    recset = set(rec)

    def closure(seed):
        seen, st = set(seed), list(seed)
        while st:
            v = st.pop()
            for w in edges[v]:
                if w not in seen:
                    seen.add(w); st.append(w)
        return seen
    regions, acc = [], set()
    for c in rec:
        acc = closure(mem[c]) | acc
        regions.append(set(acc))
    level = [len(regions)] * nn
    for i in range(len(regions) - 1, -1, -1):
        for v in regions[i]:
            level[v] = i
    res = {}
    # 1. singleton block costs
    sc = [block_cost([U[v // nd]], q) for c in rec[1:] for v in mem[c] for q in DFA[DS[v % nd]]]
    res["singleton_block_cost"] = {"min": min(sc), "mean": sum(sc) / len(sc), "max": max(sc), "total_small_parts": sum(sc)}
    # 2. class-closed partitions of each small part (inside moves)
    for c in rec[1:]:
        P = set(mem[c])
        cls = {v: v % nd for v in P}
        while True:
            sig = {v: (cls[v],) + tuple((q, read[(U[v // nd], q)], tuple(sorted({cls[w] for qq, w in out[v] if qq == q and w in P})))
                                         for q in (7, 9) if any(qq == q and w in P for qq, w in out[v])) for v in P}
            ids, new = {}, {}
            for v in P:
                new[v] = ids.setdefault(sig[v], len(ids))
            stable = len(ids) == len(set(cls.values()))
            cls = new
            if stable:
                break
        members = {}
        for v in P:
            members.setdefault(cls[v], []).append(v)
        closed = all(len({cls[w] for v in vs for qq, w in out[v] if qq == q and w in P}) <= 1
                     for vs in members.values() for q in (7, 9))
        same_read = all(len({read[(U[v // nd], q)] for v in vs if any(qq == q and w in P for qq, w in out[v])}) <= 1
                        for vs in members.values() for q in (7, 9))
        cost = sum(block_cost([U[v // nd] for v in vs], q) for vs in members.values()
                   for q in DFA[DS[vs[0] % nd]] if any(qq == q and w in P for v in vs for qq, w in out[v]))
        res["part_%d" % len(P)] = {"classes": len(members), "class_closed": closed, "readings_constant": same_read,
                                   "class_block_cost": cost}
    # 3. transients of each level: Z_j
    for L in range(len(regions) + 1):
        T = {v for v in range(nn) if level[v] == L and comp[v] not in recset}
        Z, j, cost = set(T), 0, 0
        while Z:
            byd = {}
            for v in Z:
                byd.setdefault(DS[v % nd], []).append(U[v // nd])
            for dd, xs in byd.items():
                for q in DFA[dd]:
                    cost += block_cost(xs, q)
            Z = {w for v in Z for w in edges[v] if w in T}
            j += 1
        res["transients_level_%d" % L] = {"nodes": len(T), "longest_stay": j, "cost": cost}
    # 4. warm-up: possible nodes after j blocks from the whole universe until inside the regions
    allreg = regions[-1]
    Pj, j, cost = set(range(nn)), 0, 0
    while not Pj <= allreg:
        byd = {}
        for v in Pj:
            byd.setdefault(DS[v % nd], []).append(U[v // nd])
        for dd, xs in byd.items():
            for q in DFA[dd]:
                cost += block_cost(xs, q)
        Pj = {w for v in Pj for w in edges[v]}
        j += 1
    res["warm_up"] = {"blocks": j, "cost": cost}
    print(json.dumps(res, indent=1))
    open(sys.argv[3], "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")


if __name__ == "__main__":
    main()

