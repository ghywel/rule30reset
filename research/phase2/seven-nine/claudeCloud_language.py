#!/usr/bin/env python3
"""claudeCloud_language.py: is every cyclic word of gaps in a given language excluded on K cells? (K93, addendum 2)

The language is every sequence of gaps over LETTERS that avoids the listed factors.  The graph has a node for each
(state of the K cells at a block boundary, the last few gaps), and an edge for each block that the language allows.
If every strongly connected part of it is settled, in the sense of claudeCloud_ranked.py (two paths that stay inside
it, from one node and under the same gaps, never show different readings of site 1), then under any periodic
sequence of gaps of the language every path of the strip shows eventually periodic readings.  That is what a rank
certificate needs, for every such word at once.

    python3 claudeCloud_language.py KIT K LETTERS [FACTOR ...]      e.g.  KIT 16 7,9 7-7-7
"""
import os
import sys
from itertools import product

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ARGV, sys.argv = sys.argv, ['x', 'none']
exec(open(os.path.join(HERE, 'claudeCloud_review.py')).read().split('\ndef main():')[0])
exec(open(os.path.join(HERE, 'claudeCloud_ranked.py')).read().split('\ndef unsettled(')[0].split('\ndef components(')[1].join(['', '']) if False else '')
SRC = open(os.path.join(HERE, 'claudeCloud_ranked.py')).read()
exec('def components(' + SRC.split('\ndef components(')[1].split('\ndef unsettled(')[0])
sys.argv = ARGV


def main():
    kit, cells = sys.argv[1], int(sys.argv[2])
    letters = tuple(int(x) for x in sys.argv[3].split(','))
    factors = [tuple(int(x) for x in f.split('-')) for f in sys.argv[4:]]
    depth = max([len(f) for f in factors] + [1]) - 1
    tab = make_tables(cells)
    states = start_set(kit, cells, letters, tab)
    succ, read = blocks_of(states, letters, tab)
    n = len(states)
    clean = lambda w: not any(w[i:i + len(f)] == f for f in factors for i in range(len(w) - len(f) + 1))
    memories = [m for m in product(letters, repeat=depth) if clean(m)]
    mem_index = {m: i for i, m in enumerate(memories)}
    moves = [[(q, mem_index[(m + (q,))[1:] if depth else ()]) for q in letters
              if clean(m + (q,)) and ((m + (q,))[1:] if depth else ()) in mem_index] for m in memories]
    M = len(memories)
    node = lambda s, m: s * M + m
    edges = [[node(t, m2) for q, m2 in moves[m] for t in succ[q][s]] for s in range(n) for m in range(M)]
    comp, ncomp = components(n * M, edges)
    members = {}
    for v, c in enumerate(comp):
        members.setdefault(c, []).append(v)
    print('%d cells, gaps %s, avoiding %s: %d states at block boundaries, %d memories, %d components'
          % (cells, list(letters), [' '.join(map(str, f)) for f in factors] or 'nothing', n, M, ncomp))
    verdict = True
    for c, nodes in sorted(members.items(), key=lambda kv: -len(kv[1])):
        if len(nodes) == 1 and nodes[0] not in edges[nodes[0]]:
            continue
        inside = set(nodes)
        by_mem = [[] for _ in range(M)]
        for v in nodes:
            by_mem[v % M].append(v // M)
        pos = [{s: i for i, s in enumerate(lst)} for lst in by_mem]
        mats, bad = {}, [np.zeros((len(l), len(l)), dtype=bool) for l in by_mem]
        for m in range(M):
            for q, m2 in moves[m]:
                mat = np.zeros((len(by_mem[m]), len(by_mem[m2])), dtype=np.float32)
                stays = np.zeros(len(by_mem[m]), dtype=bool)
                for i, s in enumerate(by_mem[m]):
                    for t in succ[q][s]:
                        if node(t, m2) in inside:
                            mat[i, pos[m2][t]] = 1
                            stays[i] = True
                mats[(m, q)] = (mat, m2)
                keys = {}
                ident = np.array([keys.setdefault(read[q][s], len(keys)) for s in by_mem[m]], dtype=np.int64)
                if len(ident):
                    bad[m] |= (ident[:, None] != ident[None, :]) & stays[:, None] & stays[None, :]
        while True:
            changed = False
            for (m, q), (mat, m2) in mats.items():
                if not mat.size:
                    continue
                new = bad[m] | ((mat @ bad[m2].astype(np.float32) @ mat.T) > 0)
                if (new != bad[m]).any():
                    bad[m], changed = new, True
            if not changed:
                break
        open_count = sum(int(b.diagonal().sum()) for b in bad)
        verdict &= open_count == 0
        print('   part of %d nodes (%d states): %s' % (len(nodes), len({v // M for v in nodes}),
              'settled' if open_count == 0 else 'NOT settled: %d nodes have two inside paths that differ' % open_count))
    print('every part settled: every cyclic word of the language is excluded on %d cells' % cells if verdict
          else 'some part is not settled: the language is not excluded as a whole on %d cells' % cells)


main()
