#!/usr/bin/env python3
"""claudeCloud_search.py: which simple languages of gaps does a strip of K cells exclude outright? (K93, addendum 3)

For every set of at most TWO forbidden factors of length at most MAXF over LETTERS, run the test of
claudeCloud_language.py and print the languages that come out settled, with the growth rate of the language (the
number of allowed gap words of length n grows like rate^n; rate 1 means only finitely many cyclic words or one
family of powers).  An enumeration: the cases are counted in the first line of output.

    python3 claudeCloud_search.py KIT K MAXF [LETTERS]
"""
import os
import sys
from itertools import combinations, product

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ARGV, sys.argv = sys.argv, ['x', 'none']
exec(open(os.path.join(HERE, 'claudeCloud_review.py')).read().split('\ndef main():')[0])
SRC = open(os.path.join(HERE, 'claudeCloud_ranked.py')).read()
exec('def components(' + SRC.split('\ndef components(')[1].split('\ndef unsettled(')[0])
exec('def start_set(' + SRC.split('\ndef start_set(')[1].split('\ndef unsettled(')[0])
sys.argv = ARGV


def language(letters, factors):
    depth = max([len(f) for f in factors] + [1]) - 1
    clean = lambda w: not any(w[i:i + len(f)] == f for f in factors for i in range(len(w) - len(f) + 1))
    memories = [m for m in product(letters, repeat=depth) if clean(m)]
    idx = {m: i for i, m in enumerate(memories)}
    moves = [[(q, idx[(m + (q,))[1:] if depth else ()]) for q in letters
              if clean(m + (q,)) and ((m + (q,))[1:] if depth else ()) in idx] for m in memories]
    # keep only memories on a cycle of the memory graph: the others carry no cyclic word
    M = len(memories)
    comp, _ = components(M, [[m2 for _, m2 in mv] for mv in moves])
    size = {}
    for c in comp:
        size[c] = size.get(c, 0) + 1
    keep = [m for m in range(M) if size[comp[m]] > 1 or any(m2 == m for _, m2 in moves[m])]
    adj = np.zeros((M, M))
    for m in keep:
        for q, m2 in moves[m]:
            if m2 in keep:
                adj[m, m2] += 1
    rate = max(abs(np.linalg.eigvals(adj))) if M else 0
    return memories, moves, float(rate)


def settled(n, succ, read, letters, factors):
    memories, moves, rate = language(letters, factors)
    M = len(memories)
    if M == 0 or rate < 0.5:
        return None, rate
    node = lambda s, m: s * M + m
    edges = [[node(t, m2) for q, m2 in moves[m] for t in succ[q][s]] for s in range(n) for m in range(M)]
    comp, ncomp = components(n * M, edges)
    members = {}
    for v, c in enumerate(comp):
        members.setdefault(c, []).append(v)
    for c, nodes in members.items():
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
        if any(b.diagonal().any() for b in bad):
            return False, rate
    return True, rate


def main():
    kit, cells, maxf = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    letters = tuple(int(x) for x in sys.argv[4].split(',')) if len(sys.argv) > 4 else (7, 9)
    tab = make_tables(cells)
    states = start_set(kit, cells, letters, tab)
    index = {s: i for i, s in enumerate(states)}
    succ, read = {}, {}
    for q in letters:
        succ[q], read[q] = [], []
        for s in states:
            r = block(s, q, tab)
            succ[q].append(sorted({index[e] for e, _ in r}))
            read[q].append(next(iter({x for _, x in r})))
    factors = [w for k in range(1, maxf + 1) for w in product(letters, repeat=k)]
    cases = [()] + [(f,) for f in factors] + list(combinations(factors, 2))
    print('%d cells, %d states; %d factors of length at most %d; %d sets of at most two factors'
          % (cells, len(states), len(factors), maxf, len(cases)))
    found = []
    for fs in cases:
        ok, rate = settled(len(states), succ, read, letters, fs)
        if ok:
            found.append((rate, fs))
    found.sort(key=lambda x: (-x[0], len(x[1]), x[1]))
    # drop a language if a larger settled one (a subset of its forbidden factors) is already listed
    shown = []
    for rate, fs in found:
        if not any(set(gs) < set(fs) for _, gs in found):
            shown.append((rate, fs))
    print('settled languages, largest growth rate first (those implied by a listed one with fewer factors are left out):')
    for rate, fs in shown[:40]:
        print('   rate %.4f  avoid: %s' % (rate, ' ; '.join(' '.join(map(str, f)) for f in fs)))
    print('settled in all:', len(found), '; shown:', len(shown))


main()
