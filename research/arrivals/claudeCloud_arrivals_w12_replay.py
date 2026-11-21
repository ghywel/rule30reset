#!/usr/bin/env python3
"""claudeCloud_arrivals_w12_replay.py: carrying read of gptIntel's I67 (ledger K56, addendum). An independent replay
of its finite certificate, written from the post and from the definition of `net` in the kit's Rule30SourceArrivals
as restated in research/arrivals/Rule30ArrivalParity.lean (`net_atSite`). Nothing of gptIntel's code or packet is used.

Setting. The centre alternates. At a WHITE tick t (centre white at t, black at t + 1) a vertex is sites 1..W, coded
with bit i = site i + 1. Two ticks later the window is fixed by the vertex and the two exterior cells, sites W + 1 and
W + 2 at tick t (four choices). The vertex reads the pair of net parities at t and t + 1:
    net t     = atSite(c = 0, n = 1, r = s1, u = s2)            (worked out below from the general formula)
    net (t+1) = atSite(c = 1, n = 0, r = s1', u = s2')          with s1', s2' the sites 1, 2 at tick t + 1.
The claim: inside one cyclic component, two paths of equal length with the same first vertex and the same last
vertex, which read equal pairs at every step, have the same site 1 at every step.

Checked here as a statement about pairs of vertices (x, y) of one component:
    F: pairs reachable from a pair (v, v) by steps (x, y) -> (x', y') taken only when x and y read equal pairs;
    B: pairs that read equal pairs and from which some pair (v, v) is reachable by such steps.
Every pair in F and B must agree at site 1. The counts are printed for comparison with I67 (777 and 47 vertices;
5,616 and 72 unordered pairs; at W = 11 the test fails).

    python3 claudeCloud_arrivals_w12_replay.py [W ...]        default 12 11
"""
import sys


def rule(l, c, r):
    return l ^ (c | r)


def at_site(c, n, r, u):
    """The kit's net parity in gptIntel's form: xor (!c && xor r n) (xor (r && !u) (n && !rule c r u))."""
    return ((1 - c) & (r ^ n)) ^ ((r & (1 - u)) ^ (n & (1 - rule(c, r, u))))


def tick(cells, centre):
    """cells[0..k-1] are sites 1..k; returns sites 1..k-1 one tick later."""
    left = [centre] + cells[:-1]
    return [rule(left[j], cells[j], cells[j + 1]) for j in range(len(cells) - 1)]


def build(W):
    succ, label, site1 = [], [], []
    for w in range(1 << W):
        base = [(w >> i) & 1 for i in range(W)]
        outs = set()
        for e in range(4):
            cells = base + [e & 1, (e >> 1) & 1]
            mid = tick(cells, 0)                      # the centre is white at t
            end = tick(mid, 1)                        # and black at t + 1
            outs.add(sum(b << i for i, b in enumerate(end)))
            if e == 0:
                nw = at_site(0, 1, base[0], base[1])
                nb = at_site(1, 0, mid[0], mid[1])
                # two hand identities used by I67's argument, checked on every vertex
                assert nw == base[0] ^ base[1]
                assert mid[0] == (nw | nb), 'the black-tick right bit is not the OR of the two readings'
                lab = (nw, nb)
            else:
                assert (at_site(0, 1, base[0], base[1]), at_site(1, 0, mid[0], mid[1])) == lab
        succ.append(sorted(outs)); label.append(lab); site1.append(base[0])
    return succ, label, site1


def components(succ):
    """Strongly connected components (iterative Tarjan); returns the cyclic ones."""
    n = len(succ); index = [-1] * n; low = [0] * n; on = [False] * n; stack = []; out = []; counter = 0
    for root in range(n):
        if index[root] != -1:
            continue
        work = [(root, 0)]
        while work:
            v, i = work[-1]
            if i == 0:
                index[v] = low[v] = counter; counter += 1; stack.append(v); on[v] = True
            if i < len(succ[v]):
                work[-1] = (v, i + 1); w = succ[v][i]
                if index[w] == -1:
                    work.append((w, 0))
                elif on[w]:
                    low[v] = min(low[v], index[w])
            else:
                work.pop()
                if work:
                    low[work[-1][0]] = min(low[work[-1][0]], low[v])
                if low[v] == index[v]:
                    comp = []
                    while True:
                        w = stack.pop(); on[w] = False; comp.append(w)
                        if w == v:
                            break
                    if len(comp) > 1 or v in succ[v]:
                        out.append(sorted(comp))
    return sorted(out, key=len, reverse=True)


def check(W):
    succ, label, site1 = build(W)
    comps = components(succ)
    print('W = %d: %d vertices, %d edges (distinct successors), %d cyclic components of sizes %s'
          % (W, 1 << W, sum(map(len, succ)), len(comps), [len(c) for c in comps]))
    ok = True
    for comp in comps:
        inside = set(comp)
        nxt = {v: [w for w in succ[v] if w in inside] for v in comp}
        # forward from the diagonal
        F = set((v, v) for v in comp); todo = list(F)
        while todo:
            x, y = todo.pop()
            if label[x] != label[y]:
                continue
            for a in nxt[x]:
                for b in nxt[y]:
                    if (a, b) not in F:
                        F.add((a, b)); todo.append((a, b))
        # backward to the diagonal: predecessors inside the component
        pred = {v: [] for v in comp}
        for v in comp:
            for w in nxt[v]:
                pred[w].append(v)
        B = set((v, v) for v in comp); todo = list(B)
        while todo:
            a, b = todo.pop()
            for x in pred[a]:
                for y in pred[b]:
                    if label[x] == label[y] and (x, y) not in B:
                        B.add((x, y)); todo.append((x, y))
        both = [(x, y) for (x, y) in F if (x, y) in B and label[x] == label[y]]
        off = [(x, y) for (x, y) in both if x != y]
        bad = [(x, y) for (x, y) in off if site1[x] != site1[y]]
        print('   component of %d: pairs on some pair of matched paths with common ends: %d ordered, of which %d off the '
              'diagonal (%d unordered; %d unordered with the diagonal); disagreeing at site 1: %d ordered'
              % (len(comp), len(both), len(off), len(off) // 2, len(off) // 2 + len(comp), len(bad)))
        ok &= not bad
    print('   W = %d: %s' % (W, 'CERTIFICATE HOLDS' if ok else 'the test FAILS at this width'))
    return ok


if __name__ == '__main__':
    for W in [int(a) for a in sys.argv[1:]] or [12, 11]:
        check(W)
