"""I295.1, claudeIntel: write the 13-cell certificate as Lean data (the module Rule30Certificates.SevenNineLanguage).

Everything is recomputed from the rule (no input files). A state is a number below 2^13 (bit k is the cell k + 1 sites
east of the centre); one tick with centre letter a and free cell z sends s to ((s << 1) | a) ^ (s | (s >> 1) | z << 12)
modulo 2^13, the kit's stripStep 13. A memory is the list of the last three gaps, with no 7,7,7; a gap q may follow a
memory m when m ++ [q] has no 7,7,7 and no 7,9,7,9.

  warm j m   checkpoints of the nodes possible after j blocks (j even, 2 .. J), from every state
  bS t0 p1 t1 p2   the sink part, the transients of level 0, the part of 126, the transients of level 1, the part of 29
  z0 j, z1 j   the transients of each level still reachable by j steps inside the level
  c1 m q   the nodes of the part of 126 with a successor in that part under q (for P2 every node has one)
  g1 g2   partner lists: for each node of a part, the states paired with it from the diagonal by moves with one gap

Usage: python -I claudeIntel_cert13.py lean/Rule30Certificates/SevenNineLanguage.lean [summary.json]
"""
import json
import sys
from itertools import product

import numpy as np

K = 13
N = 1 << K
s_ = np.arange(N, dtype=np.int64)
TAB = {(a, z): (((s_ << 1) | a) ^ (s_ | (s_ >> 1) | (z << (K - 1)))) % N for a in (0, 1) for z in (0, 1)}
MEMS = [m for m in product((7, 9), repeat=3) if m != (7, 7, 7)]


def allowed(m, q):
    w = m + (q,)
    return w[1:] != (7, 7, 7) and w != (7, 9, 7, 9)


def nxt(m, q):
    return m[1:] + (q,)


MOVES = [(m, q) for m in MEMS for q in (7, 9) if allowed(m, q)]


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


def main():
    outp = sys.argv[1]
    # warm-up
    W = {m: np.ones(N, dtype=bool) for m in MEMS}
    rounds = [W]
    while True:
        nx = {m: np.zeros(N, dtype=bool) for m in MEMS}
        for m, q in MOVES:
            nx[nxt(m, q)] |= block(W[m], q)
        if all((nx[m] == W[m]).all() for m in MEMS):
            break
        W = nx
        rounds.append(W)
    J = len(rounds) - 1
    if J % 2:
        rounds.append(W)  # one more (unchanged) round, so the last checkpoint is even
        J += 1
    lasting = W
    nodes = [(int(x), m) for m in MEMS for x in np.flatnonzero(lasting[m])]
    nset = set(nodes)
    succ, read = {}, {}
    for x in {x for x, _ in nodes}:
        for q in (7, 9):
            succ[(x, q)], read[(x, q)] = block_one(x, q)
    out = {u: [(q, (t, nxt(u[1], q))) for q in (7, 9) if allowed(u[1], q) for t in succ[(u[0], q)]] for u in nodes}
    assert all(w in nset for u in nodes for _, w in out[u])
    rev = {u: [] for u in nodes}
    for u in nodes:
        for _, w in out[u]:
            rev[w].append(u)

    def fwd(seed):
        seen, st = set(seed), list(seed)
        while st:
            u = st.pop()
            for _, w in out[u]:
                if w not in seen:
                    seen.add(w); st.append(w)
        return seen

    def bwd(seed):
        seen, st = set(seed), list(seed)
        while st:
            u = st.pop()
            for w in rev[u]:
                if w not in seen:
                    seen.add(w); st.append(w)
        return seen
    left, parts = set(nodes), []
    for u in nodes:
        if u in left:
            c = fwd({u}) & bwd({u})
            left -= c
            if len(c) > 1 or any(w == u for _, w in out[u]):
                parts.append(c)
    parts.sort(key=len, reverse=True)
    Bp, P1, P2 = parts
    R2, R1 = bwd(P2), bwd(P1) - bwd(P2)
    lev = {u: 2 if u in R2 else 1 if u in R1 else 0 for u in nodes}
    assert {u for u in nodes if lev[u] == 2} == P2
    T0 = {u for u in nodes if lev[u] == 0} - Bp
    T1 = {u for u in nodes if lev[u] == 1} - P1
    assert all(w in Bp for u in Bp for _, w in out[u])

    def zseq(T):
        Z, seq = set(T), []
        while Z:
            seq.append(Z)
            Z = {w for u in Z for _, w in out[u] if w in T}
        return seq
    Z0, Z1 = zseq(T0), zseq(T1)

    def partners(P):
        ins = {(u, q): [w for qq, w in out[u] if qq == q and w in P] for u in P for q in (7, 9)}
        G = {(u, u) for u in P}
        st = list(G)
        while st:
            u, u2 = st.pop()
            for q in (7, 9):
                for w in ins[(u, q)]:
                    for w2 in ins[(u2, q)]:
                        if (w, w2) not in G:
                            G.add((w, w2)); st.append((w, w2))
        rows = {}
        for u, u2 in G:
            assert u[1] == u2[1]
            rows.setdefault(u, set()).add(u2[0])
        cont = {(m, q): {u[0] for u in P if u[1] == m and ins[(u, q)]} for m, q in MOVES}
        for u, r in rows.items():
            for q in (7, 9):
                if ins[(u, q)]:
                    assert len({read[(x, q)] for x in r if x in cont[(u[1], q)]}) == 1
        return rows, cont
    G1, C1 = partners(P1)
    G2, C2 = partners(P2)
    assert all(C2[(m, q)] == {u[0] for u in P2 if u[1] == m} or True for m, q in MOVES)

    def bym(S):
        return {m: sorted(x for x, mm in S if mm == m) for m in MEMS}

    def lst(xs):
        return "[" + ", ".join(map(str, xs)) + "]"

    def memfun(name, doc, S, typ="List Nat"):
        rows = ["/-- %s -/" % doc, "def %s : List Nat → Nat" % name]
        d = bym(S)
        for m in MEMS:
            rows.append("  | %s => ofList %s" % (lst(m), lst(d[m])))
        rows.append("  | _ => 0")
        return "\n".join(rows)

    def tohex(mask):
        return hex(sum(1 << int(i) for i in np.flatnonzero(mask)))

    L = []
    L.append("module\n\npublic import Ruliology.CellularAutomata.Rule30StripCertificates\n")
    L.append("/-!\n# Certificate data for `Rule30SevenNineLanguage`\n\n"
             "Sets of 13-cell strip states, one per memory of the last three gaps, computed from the rule. A list of\n"
             "states becomes a bit mask by `ofList`. -/\n")
    L.append("@[expose] public section\n\nnamespace Ruliology.CellularAutomata.Rule30SevenNineLanguage.Data\n")
    L.append("/-- The bit mask of a list of states. -/\ndef ofList (l : List Nat) : Nat := l.foldl (fun acc s => acc ||| (1 <<< s)) 0\n")
    L.append("/-- Warm-up checkpoints: the nodes possible after `2 i` blocks, `i = 1, …, %d`. -/" % (J // 2))
    L.append("def warm : Nat → List Nat → Nat")
    for i in range(1, J // 2 + 1):
        for m in MEMS:
            L.append("  | %d, %s => %s" % (i, lst(m), tohex(rounds[2 * i][m])))
    L.append("  | _, _ => 0\n")
    L.append(memfun("bS", "The sink part: 1,274 nodes; its readings depend only on the memory and the gap.", Bp) + "\n")
    L.append(memfun("t0", "The transients of level 0 (nodes that can reach neither small part).", T0) + "\n")
    L.append(memfun("p1", "The part of 126 nodes.", P1) + "\n")
    L.append(memfun("t1", "The transients of level 1 (nodes that can reach the part of 126 but not the part of 29).", T1) + "\n")
    L.append(memfun("p2", "The part of 29 nodes: all of level 2.", P2) + "\n")
    for name, seq in (("z0", Z0), ("z1", Z1)):
        L.append("/-- `%s j`: transients of the level reached by `j` steps inside it; empty from `j = %d`. -/" % (name, len(seq)))
        L.append("def %s : Nat → List Nat → Nat" % name)
        for j, Z in enumerate(seq):
            d = bym(Z)
            for m in MEMS:
                if d[m]:
                    L.append("  | %d, %s => ofList %s" % (j, lst(m), lst(d[m])))
        L.append("  | _, _ => 0\n")
    L.append("/-- The nodes of the part of 126 with a successor in that part under the gap. -/")
    L.append("def c1 : List Nat → Nat → Nat")
    for m, q in MOVES:
        L.append("  | %s, %d => ofList %s" % (lst(m), q, lst(sorted(C1[(m, q)]))))
    L.append("  | _, _ => 0\n")
    for name, rows in (("g1", G1), ("g2", G2)):
        L.append("/-- Partner lists of the part (memory, state, partners). -/")
        L.append("def %s : List (List Nat × Nat × List Nat) := [" % name)
        ent = sorted(rows.items(), key=lambda kv: (MEMS.index(kv[0][1]), kv[0][0]))
        L.append(",\n".join("  (%s, %d, %s)" % (lst(u[1]), u[0], lst(sorted(r))) for u, r in ent) + "]\n")
    L.append("def warmRounds : Nat := %d\ndef z0Len : Nat := %d\ndef z1Len : Nat := %d\n" % (J // 2, len(Z0), len(Z1)))
    L.append("end Ruliology.CellularAutomata.Rule30SevenNineLanguage.Data\n")
    text = "\n".join(L)
    assert '"' not in text and "\\" not in text
    open(outp, "w", encoding="utf-8", newline="\n").write(text)
    summ = {"warm_rounds": J, "lasting": len(nodes), "parts": [len(Bp), len(P1), len(P2)], "T0": len(T0), "T1": len(T1),
            "z0_len": len(Z0), "z1_len": len(Z1), "g1_pairs": sum(len(r) for r in G1.values()),
            "g2_pairs": sum(len(r) for r in G2.values()), "bytes": len(text.encode())}
    print(json.dumps(summ))
    if len(sys.argv) > 2:
        open(sys.argv[2], "w", encoding="ascii", newline="\n").write(json.dumps(summ, indent=1) + "\n")


if __name__ == "__main__":
    main()
