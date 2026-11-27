"""I295.1, claudeIntel: the shape and kernel cost of a 13-cell certificate (development).

Universe: the 13-cell states whose first 12 cells lie in Galindo's F (F lifted), closed under every block because F is
(Galindo's stableF), so the warm-up costs nothing new. Language: gaps 7 and 9 with no 7,7,7 and no 7,9,7,9, read by its
five-state suffix automaton
    s0 (no live suffix), s7, s77, s79, s797.
Nodes: (state, automaton state). For forward-closed regions R0 (the sink part) and the closures of the other parts,
the rank of a node is the least region holding it; it never rises along a path. Inside each level we look for a
class-closed partition: readings constant on a class (for the moves that stay in the level), and the in-level
successors of a class under a gap inside one class. With it, two paths from one node under the same gaps stay in one
class, so a path whose rank is constant has eventually periodic readings.

Reports the parts, the levels, the partition sizes, and the cost of the checks in state-ticks (the sum of the sizes
of the masks a tick-by-tick covers check walks through), which is what the kernel pays for.

Usage: python -I claudeIntel_design13.py MixedGapClocks.lean out.json
"""
import json
import re
import sys

import numpy as np

sys.setrecursionlimit(100000)
K = 13
N = 1 << K
s_ = np.arange(N, dtype=np.int64)
TAB = {(a, z): (((s_ << 1) | a) ^ (s_ | (s_ >> 1) | (z << (K - 1)))) % N for a in (0, 1) for z in (0, 1)}
DFA = {"s0": {7: "s7", 9: "s0"}, "s7": {7: "s77", 9: "s79"}, "s77": {9: "s79"}, "s79": {7: "s797", 9: "s0"},
       "s797": {7: "s77"}}
DS = list(DFA)


def tick_set(S, a):
    out = np.zeros(N, dtype=bool)
    for z in (0, 1):
        out[TAB[(a, z)][S]] = True
    return out


def block_masks(S, q):
    masks = [S]
    for i in range(q + 1):
        masks.append(tick_set(masks[-1], 1 if i == 0 else 0))
    return masks  # masks[0] = start, masks[q+1] = end


def block_one(s, q):
    cur = {s}
    rd = []
    for i in range(q + 1):
        if i > 0:
            v = {x & 1 for x in cur}
            assert len(v) == 1
            rd.append(v.pop())
        a = 1 if i == 0 else 0
        cur = {int(TAB[(a, z)][x]) for x in cur for z in (0, 1)}
    return sorted(cur), tuple(rd)


def tarjan(n, edges):
    index, low, onst, comp = [None] * n, [0] * n, [False] * n, [None] * n
    st, c, cnt = [], 0, 0
    for root in range(n):
        if index[root] is not None:
            continue
        work = [(root, 0)]
        index[root] = low[root] = cnt; cnt += 1; st.append(root); onst[root] = True
        while work:
            v, i = work[-1]
            if i < len(edges[v]):
                work[-1] = (v, i + 1); w = edges[v][i]
                if index[w] is None:
                    index[w] = low[w] = cnt; cnt += 1; st.append(w); onst[w] = True; work.append((w, 0))
                elif onst[w]:
                    low[v] = min(low[v], index[w])
            else:
                work.pop()
                if work:
                    low[work[-1][0]] = min(low[work[-1][0]], low[v])
                if low[v] == index[v]:
                    while True:
                        w = st.pop(); onst[w] = False; comp[w] = c
                        if w == v:
                            break
                    c += 1
    return comp, c


def main():
    src = open(sys.argv[1], encoding="utf-8").read()
    Fv = int(re.search(r"def F : Nat := 0x([0-9a-f]+)", src).group(1), 16)
    F12 = {x for x in range(4096) if (Fv >> x) & 1}
    U = sorted(x for x in range(N) if (x & 4095) in F12)
    Uset = set(U)
    succ, read = {}, {}
    for x in U:
        for q in (7, 9):
            e, r = block_one(x, q)
            assert set(e) <= Uset
            succ[(x, q)], read[(x, q)] = e, r
    ui = {x: i for i, x in enumerate(U)}
    D = len(DS)
    node = lambda x, d: ui[x] * D + DS.index(d)
    nn = len(U) * D
    out = [[] for _ in range(nn)]
    for x in U:
        for d in DS:
            for q, d2 in DFA[d].items():
                out[node(x, d)] += [(q, node(t, d2)) for t in succ[(x, q)]]
    edges = [[w for _, w in out[v]] for v in range(nn)]
    comp, nc = tarjan(nn, edges)
    mem = {}
    for v, c in enumerate(comp):
        mem.setdefault(c, []).append(v)
    rec = sorted([c for c, ns in mem.items() if len(ns) > 1 or ns[0] in edges[ns[0]]], key=lambda c: -len(mem[c]))
    res = {"universe_states": len(U), "nodes": nn, "recurrent_parts": [len(mem[c]) for c in rec]}
    # forward closures of the parts -> regions
    def closure(seed):
        seen, st = set(seed), list(seed)
        while st:
            v = st.pop()
            for w in edges[v]:
                if w not in seen:
                    seen.add(w); st.append(w)
        return seen
    regions = []
    acc = set()
    for c in rec:  # largest (the sink) first; check nesting
        cl = closure(mem[c]) | acc
        regions.append(cl)
        acc = cl
    regions.append(set(range(nn)))
    res["region_sizes"] = [len(r) for r in regions]
    level = [None] * nn
    for i in range(len(regions) - 1, -1, -1):
        for v in regions[i]:
            level[v] = i
    # forward-closed?
    res["regions_forward_closed"] = all(all(level[w] <= level[v] for w in edges[v]) for v in range(nn))
    # coarsest class-closed partition inside each level: start from one class per automaton state, refine
    parts_info = []
    for L in range(len(regions)):
        nodes = [v for v in range(nn) if level[v] == L]
        nset = set(nodes)
        cls = {v: v % D for v in nodes}  # class id
        while True:
            # signature: for each gap, (reading if it has an in-level move else None, set of classes of in-level succs)
            sig = {}
            bad = False
            for v in nodes:
                x = U[v // D]
                parts = [cls[v]]
                for q in (7, 9):
                    ins = sorted({cls[w] for qq, w in out[v] if qq == q and w in nset})
                    parts.append((q, read[(x, q)] if ins else None, tuple(ins)))
                sig[v] = tuple(parts)
            # a class is fine if all its members agree on readings (where they move in level) and every gap's
            # in-level successors of the whole class fall in one class; refine by the members' signatures
            new = {}
            ids = {}
            for v in nodes:
                key = sig[v]
                new[v] = ids.setdefault(key, len(ids))
            # merge readings: refining by full signature is a bisimulation-style refinement; stop when stable
            if len(set(new.values())) == len(set(cls.values())):
                cls = new
                break
            cls = new
        # check class-closure: for each class and gap, in-level successors in one class; readings constant
        members = {}
        for v in nodes:
            members.setdefault(cls[v], []).append(v)
        closed = True
        readings_ok = True
        for c, vs in members.items():
            for q in (7, 9):
                tgt = {cls[w] for v in vs for qq, w in out[v] if qq == q and w in nset}
                if len(tgt) > 1:
                    closed = False
                rds = {read[(U[v // D], q)] for v in vs if any(qq == q and w in nset for qq, w in out[v])}
                if len(rds) > 1:
                    readings_ok = False
        parts_info.append({"level": L, "nodes": len(nodes), "classes": len(members), "class_closed": closed,
                           "readings_constant": readings_ok})
    res["levels"] = parts_info
    # cost of the checks, in state-ticks
    def cost_of(stateset, q):
        S = np.zeros(N, dtype=bool)
        S[list(stateset)] = True
        return int(sum(m.sum() for m in block_masks(S, q)[:-1]))
    costs = {}
    # region closure for regions 0..len-2 (the last is everything = the universe, closed by Galindo)
    tot = 0
    for i in range(len(regions) - 1):
        c = 0
        for d in DS:
            xs = [U[v // D] for v in regions[i] if v % D == DS.index(d)]
            for q in DFA[d]:
                c += cost_of(xs, q)
        costs["region_%d" % i] = c
        tot += c
    # class checks per level (skip level 0 if one class per automaton state: same as region 0's closure)
    for L, info in enumerate(parts_info):
        nodes = [v for v in range(nn) if level[v] == L]
        # rebuild classes quickly by automaton state only if classes == automaton states
        c = 0
        if info["classes"] > D:
            # cost: each class's block images
            pass
        costs["level_%d_classes" % L] = info["classes"]
    res["costs_state_ticks"] = costs
    res["region_cost_total"] = tot
    print(json.dumps(res, indent=1))
    open(sys.argv[2], "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")


if __name__ == "__main__":
    main()
