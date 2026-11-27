#!/usr/bin/env python3
"""claudeCloud_shape.py: what a rank certificate for a settled language would have to hold (K93; development).

For the language of claudeCloud_language.py on K cells: how many blocks it takes for the possible nodes to shrink to
those with arbitrarily long histories; the recurrent parts among them; whether the readings inside each part depend
on the node or only on the remembered gaps and the next gap; and how long a chain of non-recurrent nodes can be.

    python3 claudeCloud_shape.py KIT K LETTERS [FACTOR ...]
"""
import os
import sys
from itertools import product

HERE = os.path.dirname(os.path.abspath(__file__))
ARGV, sys.argv = sys.argv, ['x', 'none']
exec(open(os.path.join(HERE, 'claudeCloud_review.py')).read().split('\ndef main():')[0])
SRC = open(os.path.join(HERE, 'claudeCloud_ranked.py')).read()
exec('def components(' + SRC.split('\ndef components(')[1].split('\ndef unsettled(')[0])
exec('def start_set(' + SRC.split('\ndef start_set(')[1].split('\ndef unsettled(')[0])
sys.argv = ARGV


def main():
    kit, cells = sys.argv[1], int(sys.argv[2])
    letters = tuple(int(x) for x in sys.argv[3].split(','))
    factors = [tuple(int(x) for x in f.split('-')) for f in sys.argv[4:]]
    depth = max([len(f) for f in factors] + [1]) - 1
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
    n = len(states)
    clean = lambda w: not any(w[i:i + len(f)] == f for f in factors for i in range(len(w) - len(f) + 1))
    memories = [m for m in product(letters, repeat=depth) if clean(m)]
    idx = {m: i for i, m in enumerate(memories)}
    moves = [[(q, idx[(m + (q,))[1:] if depth else ()]) for q in letters
              if clean(m + (q,)) and ((m + (q,))[1:] if depth else ()) in idx] for m in memories]
    M = len(memories)
    node = lambda s, m: s * M + m
    out = [[(q, node(t, m2)) for q, m2 in moves[v % M] for t in succ[q][v // M]] for v in range(n * M)]
    # nodes possible after at least j blocks
    cur = set(range(n * M))
    sizes = [len(cur)]
    while True:
        nxt = {w for v in cur for _, w in out[v]}
        nxt &= cur
        sizes.append(len(nxt))
        if nxt == cur:
            break
        cur = nxt
    print('%d cells, avoiding %s: %d states, %d memories' % (cells, [' '.join(map(str, f)) for f in factors], n, M))
    print('nodes possible after 0, 1, 2, ... blocks:', sizes[:-1], '(stable after %d)' % (len(sizes) - 2))
    live = sorted(cur)
    lidx = {v: i for i, v in enumerate(live)}
    edges = [[lidx[w] for _, w in out[v] if w in lidx] for v in live]
    comp, ncomp = components(len(live), edges)
    members = {}
    for i, c in enumerate(comp):
        members.setdefault(c, []).append(i)
    recurrent = {c for c, ns in members.items() if len(ns) > 1 or ns[0] in edges[ns[0]]}
    print('of the %d lasting nodes, %d lie in %d recurrent parts; %d do not' % (len(live),
          sum(len(members[c]) for c in recurrent), len(recurrent), sum(len(ns) for c, ns in members.items() if c not in recurrent)))
    for c in sorted(recurrent, key=lambda c: -len(members[c])):
        ns = set(members[c])
        kinds = {}
        for i in ns:
            v = live[i]
            for q, w in out[v]:
                if w in lidx and lidx[w] in ns:
                    kinds.setdefault((v % M, q), set()).add(read[q][v // M])
        worst = max(len(x) for x in kinds.values())
        print('   part of %d nodes: at most %d different readings for one (memory, next gap)%s' % (len(ns), worst,
              '' if worst > 1 else ': the readings do not depend on the node'))
        if worst == 1 and len(ns) < 6000:
            for (m, q), x in sorted(kinds.items()):
                print('      after gaps %s, next gap %d: site 1 reads %s' % (memories[m], q, ''.join(map(str, next(iter(x))))))
    # longest chain of non-recurrent lasting nodes (they form a graph without cycles)
    order = sorted(range(len(live)), key=lambda i: comp[i])          # Tarjan numbers components in reverse topological order
    longest = [0] * len(live)
    for i in order:
        if comp[i] in recurrent:
            continue
        longest[i] = 1 + max([longest[j] for j in edges[i] if comp[j] not in recurrent] + [0])
    print('longest chain of lasting nodes outside the recurrent parts:', max(longest))


main()
