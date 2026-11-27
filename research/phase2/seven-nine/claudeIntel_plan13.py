"""I295.1, claudeIntel: the certificate for the 13-cell theorem, computed and written out (development, then data).

Universe: all 2^13 states. Memory: the last three gaps, avoiding 7,7,7 (a memory is clean if it has no 7,7,7; a move
from memory m by gap q is allowed if m followed by q has no 7,7,7 and no 7,9,7,9). Nodes are (state, memory).

  1. Warm-up: W_0 = all states for every memory; W_{j+1}(m') = union of block images of W_j(m) over allowed moves
     m -> m'. Stops when W_j is inside the lasting nodes (those with arbitrarily long histories).
  2. Levels of lasting nodes by what they can still reach: 2 if the part of 29 can be reached, 1 if the part of 126
     but not that one, 0 otherwise. Each union of levels below a bound is forward closed.
  3. Level 0: one reading per (memory, gap) for every node, on every allowed move (prescribed).
  4. Level 1 and 2: the parts with their transients; partner sets G[u] (pairs reachable from the diagonal by moves
     with the same gap inside the level), checked to give equal readings.

Writes the sets as hexadecimal masks for the Lean module. Usage:
    python -I claudeIntel_plan13.py out.json [masks.json]
"""
import json
import sys
from itertools import product

import numpy as np

K = 13
N = 1 << K
FACTORS = [(7, 7, 7), (7, 9, 7, 9)]
s_ = np.arange(N, dtype=np.int64)
TAB = {(a, z): (((s_ << 1) | a) ^ (s_ | (s_ >> 1) | (z << (K - 1)))) % N for a in (0, 1) for z in (0, 1)}


def clean(w):
    return not any(tuple(w[i:i + len(f)]) == f for f in FACTORS for i in range(len(w) - len(f) + 1))


MEMS = [m for m in product((7, 9), repeat=3) if clean(m)]
MI = {m: i for i, m in enumerate(MEMS)}
MOVES = {m: [(q, (m + (q,))[1:]) for q in (7, 9) if clean(m + (q,))] for m in MEMS}


def tick(S, a):
    out = np.zeros(N, dtype=bool)
    for z in (0, 1):
        out[TAB[(a, z)][S]] = True
    return out


def block(S, q):
    for i in range(q + 1):
        S = tick(S, 1 if i == 0 else 0)
    return S


def block_one(x, q):
    cur, rd = {x}, []
    for i in range(q + 1):
        if i > 0:
            v = {y & 1 for y in cur}
            assert len(v) == 1
            rd.append(v.pop())
        cur = {int(TAB[(1 if i == 0 else 0, z)][y]) for y in cur for z in (0, 1)}
    return sorted(cur), tuple(rd)


def tohex(mask):
    return hex(sum(1 << int(i) for i in np.flatnonzero(mask)))


def main():
    outp = sys.argv[1]
    # 1. warm-up on sets
    W = {m: np.ones(N, dtype=bool) for m in MEMS}
    hist = [{m: int(W[m].sum()) for m in MEMS}]
    while True:
        nxt = {m: np.zeros(N, dtype=bool) for m in MEMS}
        for m in MEMS:
            for q, m2 in MOVES[m]:
                nxt[m2] |= block(W[m], q)
        if all((nxt[m] == W[m]).all() for m in MEMS):
            break
        W = nxt
        hist.append({m: int(W[m].sum()) for m in MEMS})
    rounds = len(hist) - 1
    lasting = W  # fixed point: nodes with arbitrarily long histories (W is decreasing from the full set)
    states = sorted({int(x) for m in MEMS for x in np.flatnonzero(lasting[m])})
    succ, read = {}, {}
    for x in states:
        for q in (7, 9):
            succ[(x, q)], read[(x, q)] = block_one(x, q)
    nodes = [(x, m) for m in MEMS for x in np.flatnonzero(lasting[m]).tolist()]
    nset = set(nodes)
    out = {v: [(q, (t, m2)) for q, m2 in MOVES[v[1]] for t in succ[(v[0], q)] if (t, m2) in nset] for v in nodes}
    full_out = {v: [(q, (t, m2)) for q, m2 in MOVES[v[1]] for t in succ[(v[0], q)]] for v in nodes}
    assert all(w in nset for v in nodes for _, w in full_out[v]), "lasting nodes are forward closed"
    # SCCs by Tarjan (iterative)
    idx = {v: i for i, v in enumerate(nodes)}
    edges = [[idx[w] for _, w in out[v]] for v in nodes]
    n = len(nodes)
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
    members = {}
    for i, cc in enumerate(comp):
        members.setdefault(cc, []).append(i)
    rec = sorted([cc for cc, ms in members.items() if len(ms) > 1 or ms[0] in edges[ms[0]]], key=lambda cc: -len(members[cc]))
    B, P1, P2 = [set(members[cc]) for cc in rec]
    # backward reachability
    redges = [[] for _ in range(n)]
    for v in range(n):
        for w in edges[v]:
            redges[w].append(v)

    def can_reach(target):
        seen, stk = set(target), list(target)
        while stk:
            v = stk.pop()
            for u in redges[v]:
                if u not in seen:
                    seen.add(u); stk.append(u)
        return seen
    R2 = can_reach(P2)
    R1 = can_reach(P1) - R2
    level = [2 if v in R2 else 1 if v in R1 else 0 for v in range(n)]
    assert all(level[w] <= level[v] for v in range(n) for w in edges[v])
    res = {"warm_up_rounds": rounds, "warm_up_sizes": [sum(h.values()) for h in hist], "lasting_nodes": n,
           "parts": [len(B), len(P1), len(P2)],
           "level_sizes": [level.count(0), level.count(1), level.count(2)],
           "level2_is_part": set(v for v in range(n) if level[v] == 2) == P2}
    # 3. level 0 prescribed?
    presc, ok0 = {}, True
    for v in range(n):
        if level[v] != 0:
            continue
        x, m = nodes[v]
        for q, m2 in MOVES[m]:
            r = read[(x, q)]
            if presc.setdefault((m, q), r) != r:
                ok0 = False
    res["level0_prescribed"] = ok0
    res["level0_prescription"] = {"%s+%d" % ("".join(map(str, m)), q): "".join(map(str, r)) for (m, q), r in sorted(presc.items())}
    # 4. levels 1, 2: partner relation from the diagonal under same-gap in-level moves
    for L in (1, 2):
        lv = [v for v in range(n) if level[v] == L]
        ls = set(lv)
        insucc = {(v, q): [idx[w] for qq, w in out[nodes[v]] if qq == q and level[idx[w]] == L] for v in lv for q in (7, 9)}
        G = {(v, v) for v in lv}
        stk = list(G)
        while stk:
            u, u2 = stk.pop()
            for q in (7, 9):
                for w in insucc[(u, q)]:
                    for w2 in insucc[(u2, q)]:
                        if (w, w2) not in G:
                            G.add((w, w2)); stk.append((w, w2))
        bad_cont = sum(1 for u, u2 in G for q in (7, 9) if insucc[(u, q)] and insucc[(u2, q)]
                       and read[(nodes[u][0], q)] != read[(nodes[u2][0], q)])
        bad_any = sum(1 for u, u2 in G for q, _ in MOVES[nodes[u][1]] if read[(nodes[u][0], q)] != read[(nodes[u2][0], q)])
        trans = [v for v in lv if v not in (P1 if L == 1 else P2)]
        res["level%d" % L] = {"nodes": len(lv), "transients": len(trans), "partner_pairs": len(G),
                              "unequal_readings_where_both_continue": bad_cont, "unequal_readings_on_any_move": bad_any}
    print(json.dumps(res, indent=1))
    open(outp, "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")


if __name__ == "__main__":
    main()

