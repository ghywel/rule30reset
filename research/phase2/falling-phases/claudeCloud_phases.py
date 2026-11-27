#!/usr/bin/env python3
"""claudeCloud_phases.py: an independent replay of I303-I307's finite check, and how far the method reaches (K95).

W cells in a row, with a free bit at each end at every tick.  A cell *falls* at a tick when it is black then and
white at the next.  Give each cell a set of residues modulo M at which it may fall, and keep only the updates in
which every falling cell is inside its set.  A node is (tick modulo M, the W cells); there are four updates from each.
A path of the real pattern in which every one of these W columns falls only inside its set, from some age on, is a
path of this graph.  It ends up inside one strongly connected part.  If every such part has two neighbouring cells
whose colours are fixed by the position in the part's cycle, those two columns would be eventually periodic, which
Jen's theorem forbids.  So an assignment that leaves no part without such a pair cannot hold for ever.

    replay           M = 3, W = 6, one residue for each cell: every one of the 729 assignments, as I303-I307 say.
    reach M WMAX     one residue for each cell, widths 2 to WMAX: how many assignments escape the test.
    sets WMAX        M = 3, each cell forbidden one residue (two allowed): the same count.

Assignments are counted up to rotation of time: the westernmost cell's residue (or forbidden residue) is 0.
"""
import sys
from itertools import product
from math import gcd

RULE = {(0, 0, 0): 0, (0, 0, 1): 1, (0, 1, 0): 1, (0, 1, 1): 1, (1, 0, 0): 1, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 0}


def make_steps(width):
    """steps[s] = the four next rows of s, for the west and east free bits, cell by cell from the rule's table."""
    steps = []
    for s in range(1 << width):
        row = []
        for west in (0, 1):
            for east in (0, 1):
                d = 0
                for k in range(width):
                    left = west if k == 0 else (s >> (k - 1)) & 1
                    right = east if k == width - 1 else (s >> (k + 1)) & 1
                    d |= RULE[(left, (s >> k) & 1, right)] << k
                row.append(d)
        steps.append(row)
    return steps


def components(n, edges):
    """Strongly connected components (Tarjan, without recursion): a number for each node, in reverse topological order."""
    index, low, comp, stack, on = [-1] * n, [0] * n, [-1] * n, [], [False] * n
    counter = ncomp = 0
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
            descended = False
            for j in range(i, len(edges[v])):
                w = edges[v][j]
                if index[w] == -1:
                    work.append((v, j + 1))
                    work.append((w, 0))
                    descended = True
                    break
                if on[w]:
                    low[v] = min(low[v], index[w])
            if descended:
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


def graph(width, modulus, allowed, steps):
    """allowed[k] = the set of residues at which cell k may fall.  Returns edges and the count of admitted updates."""
    size = 1 << width
    edges, admitted = [], 0
    for t in range(modulus):
        nxt = (t + 1) % modulus
        ok_mask = sum(1 << k for k in range(width) if t in allowed[k])       # cells that may fall now
        for s in range(size):
            out = []
            for d in steps[s]:
                if (s & ~d) & ~ok_mask & (size - 1) == 0:
                    admitted += 1
                    out.append(nxt * size + d)
            edges.append(sorted(set(out)))
    return edges, admitted


def judge(width, modulus, allowed, steps):
    """Returns (escapes, strict, depth): escapes = some recurrent part has no neighbouring pair fixed by its cycle;
    strict = every part has a pair fixed by the tick modulo M alone; depth = most recurrent parts on one path."""
    size = 1 << width
    edges, admitted = graph(width, modulus, allowed, steps)
    n = modulus * size
    comp, ncomp = components(n, edges)
    members = [[] for _ in range(ncomp)]
    for v in range(n):
        members[comp[v]].append(v)
    recurrent = [len(m) > 1 or m[0] in edges[m[0]] for m in members]
    escapes, strict = False, True
    for c in range(ncomp):
        if not recurrent[c]:
            continue
        nodes = members[c]
        inside = set(nodes)
        level = {nodes[0]: 0}
        queue = [nodes[0]]
        period = 0
        for v in queue:
            for w in edges[v]:
                if w in inside:
                    if w not in level:
                        level[w] = level[v] + 1
                        queue.append(w)
                    period = gcd(period, level[v] + 1 - level[w])
        fixed_by_cycle = fixed_by_tick = False
        for k in range(width - 1):
            seen, good = {}, True
            for v in nodes:
                key = level[v] % period
                bits = (v % size >> k) & 3
                if seen.setdefault(key, bits) != bits:
                    good = False
                    break
            if good:
                fixed_by_cycle = True
                seen2, good2 = {}, True
                for v in nodes:
                    bits = (v % size >> k) & 3
                    if seen2.setdefault(v // size, bits) != bits:
                        good2 = False
                        break
                fixed_by_tick |= good2
        escapes |= not fixed_by_cycle
        strict &= fixed_by_tick
    # most recurrent parts on one path: components come in reverse topological order
    best = [0] * ncomp
    for c in range(ncomp):
        below = 0
        for v in members[c]:
            for w in edges[v]:
                if comp[w] != c:
                    below = max(below, best[comp[w]])
        best[c] = below + (1 if recurrent[c] else 0)
    return escapes, strict, max(best), admitted


def main():
    mode = sys.argv[1]
    if mode == 'replay':
        steps = make_steps(6)
        tally, depth = {'escape': 0, 'not by tick': 0}, {}
        admitted_norm = 0
        for a in product(range(3), repeat=6):
            esc, strict, d, adm = judge(6, 3, [{r} for r in a], steps)
            tally['escape'] += esc
            tally['not by tick'] += not strict
            if a[0] == 0:
                depth[d] = depth.get(d, 0) + 1
                admitted_norm += adm
        print('six cells, modulo 3, one residue each: 729 assignments')
        print('   with a recurrent part that has no neighbouring pair fixed by its cycle:', tally['escape'])
        print('   with a part whose pairs are not fixed by the tick modulo 3 alone:', tally['not by tick'])
        print('   the 243 with the west cell at residue 0: nodes', 243 * 3 * 64, '; admitted updates', admitted_norm)
        print('   most recurrent parts on one path, by number of assignments (of 243):', sorted(depth.items()))
    elif mode == 'reach':
        modulus, wmax = int(sys.argv[2]), int(sys.argv[3])
        print('modulo %d, one residue for each cell; assignments with the west cell at residue 0' % modulus)
        print('width | assignments | escape the test')
        for width in range(2, wmax + 1):
            steps = make_steps(width)
            total = esc = 0
            for a in product(range(modulus), repeat=width - 1):
                total += 1
                esc += judge(width, modulus, [{0}] + [{r} for r in a], steps)[0]
            print(width, '|', total, '|', esc, flush=True)
    elif mode == 'sets':
        wmax = int(sys.argv[2])
        print('modulo 3, each cell forbidden one residue; assignments with the west cell forbidden residue 0')
        print('width | assignments | escape the test')
        for width in range(2, wmax + 1):
            steps = make_steps(width)
            total = esc = 0
            for a in product(range(3), repeat=width - 1):
                total += 1
                esc += judge(width, 3, [{1, 2}] + [{0, 1, 2} - {r} for r in a], steps)[0]
            print(width, '|', total, '|', esc, flush=True)


main()
