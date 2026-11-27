#!/usr/bin/env python3
"""claudeCloud_ranked.py: which cyclic words of gaps the strip can exclude at all, and whether it excludes all (K93).

The strip graph: a node is a state of the K cells east of the centre at a block boundary, an edge is one block (a
black centre tick and q white ones) with the free bit taken both ways at every tick.  The readings of site 1 through
a block are fixed by the block's first state while q < K.

A path can leave a strongly connected component only once, which is what a rank allows for.  So call a component
*settled* if two paths that stay inside it, from one state and under the same gaps, never show different readings.

    words KIT K MAXLEN [LETTERS]
        For each primitive cyclic word of gaps: the graph of (state, position in the word), its components, and
        whether each is settled.  If all are, every path under the repeated word shows eventually periodic readings,
        and the word is excluded on K cells; if one is not, some path shows readings that never repeat, and no
        certificate on K cells excludes the word.  K = 12 uses the kit's set F; other K use the states reachable
        after one block from anywhere.
    all KIT K [LETTERS]
        The same question for every word at once: the components of the graph over all the gaps together.  If each
        is settled, every cyclic word over LETTERS is excluded on K cells.
"""
import sys
from itertools import product

import numpy as np

sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
sys.argv, ARGV = ['x', 'none'], sys.argv
SRC = open(__import__('os').path.join(sys.path[0], 'claudeCloud_review.py')).read().split('\ndef main():')[0]
exec(SRC)
sys.argv = ARGV


def components(n, edges):
    """Strongly connected components (Tarjan, without recursion); returns a component number for each node."""
    index, low, comp, stack, on = [-1] * n, [0] * n, [-1] * n, [], [False] * n
    counter, ncomp = 0, 0
    for root in range(n):
        if index[root] != -1:
            continue
        work = [(root, 0)]
        while work:
            v, i = work.pop()
            if i == 0:
                index[v] = low[v] = counter
                counter += 1
                stack.append(v)
                on[v] = True
            recurse = False
            for j in range(i, len(edges[v])):
                w = edges[v][j]
                if index[w] == -1:
                    work.append((v, j + 1))
                    work.append((w, 0))
                    recurse = True
                    break
                if on[w]:
                    low[v] = min(low[v], index[w])
            if recurse:
                continue
            if low[v] == index[v]:
                while True:
                    w = stack.pop()
                    on[w] = False
                    comp[w] = ncomp
                    if w == v:
                        break
                ncomp += 1
            if work:
                u = work[-1][0]
                low[u] = min(low[u], low[v])
    return comp, ncomp


def start_set(kit, cells, letters, tab):
    if cells == 12:
        return sorted(constants(kit)[0])
    own = set()
    for q in letters:
        own |= image(range(1 << cells), q, tab)
    while True:
        more = set(own)
        for q in letters:
            more |= image(own, q, tab)
        if more == own:
            return sorted(own)
        own = more


def blocks_of(states, letters, tab):
    index = {s: i for i, s in enumerate(states)}
    succ, read = {}, {}
    for q in letters:
        succ[q], read[q] = [], []
        for s in states:
            r = block(s, q, tab)
            seen = {x for _, x in r}
            assert len(seen) == 1, 'a reading depends on the free bits: the gap is too long for this strip'
            succ[q].append(sorted({index[e] for e, _ in r}))
            read[q].append(next(iter(seen)))
    return succ, read


def unsettled(nodes, step_of, read_of, phases):
    """nodes: the members of one component, as (state, phase).  True if two paths inside it, from one node, differ."""
    by_phase = [[] for _ in range(phases)]
    for s, p in nodes:
        by_phase[p].append(s)
    pos = [{s: i for i, s in enumerate(lst)} for lst in by_phase]
    inside = set(nodes)
    mats, bad = [], []
    for p in range(phases):
        nxt = (p + 1) % phases
        m = np.zeros((len(by_phase[p]), len(by_phase[nxt])), dtype=np.float32)
        for i, s in enumerate(by_phase[p]):
            for t in step_of(s, p):
                if (t, nxt) in inside:
                    m[i, pos[nxt][t]] = 1
        mats.append(m)
        keys = {}
        ident = np.array([keys.setdefault(read_of(s, p), len(keys)) for s in by_phase[p]])
        bad.append(ident[:, None] != ident[None, :])
    while True:
        changed = False
        for p in range(phases - 1, -1, -1):
            nxt = (p + 1) % phases
            new = bad[p] | ((mats[p] @ bad[nxt].astype(np.float32) @ mats[p].T) > 0)
            if (new != bad[p]).any():
                bad[p], changed = new, True
        if not changed:
            break
    return any(bad[p].diagonal().any() for p in range(phases))


def judge(word, n, succ, read):
    """Is the repeated word excluded on this strip?  Returns (excluded, components that are not settled)."""
    L = len(word)
    node = lambda s, p: s * L + p
    edges = [[node(t, (p + 1) % L) for t in succ[word[p]][s]] for s in range(n) for p in range(L)]
    comp, ncomp = components(n * L, edges)
    members = {}
    for v, c in enumerate(comp):
        members.setdefault(c, []).append((v // L, v % L))
    open_ones = []
    for c, nodes in members.items():
        if len(nodes) == 1 and node(*nodes[0]) not in edges[node(*nodes[0])]:
            continue                                                    # a single node with no loop: passed once
        if unsettled(nodes, lambda s, p: succ[word[p]][s], lambda s, p: read[word[p]][s], L):
            open_ones.append(len(nodes))
    return not open_ones, open_ones


def main():
    mode, kit, cells = sys.argv[1], sys.argv[2], int(sys.argv[3])
    tab = make_tables(cells)
    if mode == 'words':
        maxlen = int(sys.argv[4])
        letters = tuple(int(x) for x in sys.argv[5].split(',')) if len(sys.argv) > 5 else (7, 9)
        states = start_set(kit, cells, letters, tab)
        succ, read = blocks_of(states, letters, tab)
        print('%d cells, gaps %s, %d states at block boundaries' % (cells, list(letters), len(states)))
        tally = {}
        for length in range(1, maxlen + 1):
            for word in necklaces(letters, length):
                ok, open_ones = judge(word, len(states), succ, read)
                tally.setdefault(length, [0, 0])[0 if ok else 1] += 1
                print(' '.join(map(str, word)), '| excluded' if ok else '| not excluded; unsettled components of sizes %s' % sorted(open_ones))
        print('length | words | excluded on %d cells | not excluded' % cells)
        for length in sorted(tally):
            print(length, '|', sum(tally[length]), '|', tally[length][0], '|', tally[length][1])
        print('all |', sum(sum(v) for v in tally.values()), '|', sum(v[0] for v in tally.values()), '|', sum(v[1] for v in tally.values()))
    else:
        letters = tuple(int(x) for x in sys.argv[4].split(',')) if len(sys.argv) > 4 else (7, 9)
        states = start_set(kit, cells, letters, tab)
        succ, read = blocks_of(states, letters, tab)
        n = len(states)
        edges = [sorted({t for q in letters for t in succ[q][s]}) for s in range(n)]
        comp, ncomp = components(n, edges)
        members = {}
        for v, c in enumerate(comp):
            members.setdefault(c, []).append(v)
        print('%d cells, gaps %s, %d states at block boundaries, %d components' % (cells, list(letters), n, ncomp))
        E = constants(kit)[1] if cells == 12 else set()
        for c, nodes in sorted(members.items(), key=lambda kv: -len(kv[1])):
            if len(nodes) == 1 and nodes[0] not in edges[nodes[0]]:
                continue
            inside = set(nodes)
            # two paths under the same gaps, both inside: a pair graph over the letters
            pos = {s: i for i, s in enumerate(nodes)}
            m = len(nodes)
            bad = np.zeros((m, m), dtype=bool)
            mats = {}
            for q in letters:
                mat = np.zeros((m, m), dtype=np.float32)
                stays = np.zeros(m, dtype=bool)
                for i, s in enumerate(nodes):
                    for t in succ[q][s]:
                        if t in inside:
                            mat[i, pos[t]] = 1
                            stays[i] = True
                mats[q] = mat
                keys = {}
                ident = np.array([keys.setdefault(read[q][s], len(keys)) for s in nodes])
                bad |= (ident[:, None] != ident[None, :]) & stays[:, None] & stays[None, :]
            while True:
                new = bad.copy()
                for q in letters:
                    new |= (mats[q] @ bad.astype(np.float32) @ mats[q].T) > 0
                if (new == bad).all():
                    break
                bad = new
            print('   component of %d states (least state %d; %d of them in E): %s'
                  % (m, min(states[s] for s in nodes), sum(states[s] in E for s in nodes),
                     'settled' if not bad.diagonal().any() else 'NOT settled: %d states have two inside paths that differ' % int(bad.diagonal().sum())))


main()
