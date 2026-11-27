#!/usr/bin/env python3
"""claudeCloud_review.py: an independent replay of I299's finite claim, and how far the method reaches (ledger K93).

Galindo's module Rule30MixedGapClocks works on the twelve cells east of the centre.  A state is a 12-bit number, bit k
the cell at site k + 1.  One tick uses the centre's colour on the left and a free bit on the right.  A *block* for a
gap q is one black centre tick and then q white ones.  F and E are his two sets of states at block boundaries.

    replay KIT        I299's claim, from the rule's eight-entry table and nothing of the kit's but F and E:
                      the block word 9,9,7,9,9,7,9,9,7,9 carries all of F into E; the sizes on the way; which of the
                      2,046 words of at most ten gaps over {7, 9} do so.
    domain KIT [LETTERS] [MAXLEN]
                      the block-research question.  Call a state *settled* if, whatever gaps follow and whatever the
                      free bits do, every continuation shows the same readings of site 1.  E is settled.  Is the set
                      D of settled states larger, and which cyclic words of gaps keep some path outside D for ever?
    wide K [LETTERS] [MAXLEN]
                      the same on K cells, from the states reachable after one block from every state.

KIT is the kit's checkout (for the two constants in Rule30Certificates/MixedGapClocks.lean).  LETTERS defaults to 7,9.
"""
import re
import sys
from itertools import product

RULE = {(0, 0, 0): 0, (0, 0, 1): 1, (0, 1, 0): 1, (0, 1, 1): 1, (1, 0, 0): 1, (1, 0, 1): 0, (1, 1, 0): 0, (1, 1, 1): 0}


def step(state, centre, free, cells):
    """One tick of the strip, cell by cell from the rule's table."""
    out = 0
    for k in range(cells):
        left = centre if k == 0 else (state >> (k - 1)) & 1
        right = free if k == cells - 1 else (state >> (k + 1)) & 1
        out |= RULE[(left, (state >> k) & 1, right)] << k
    return out


def make_tables(cells):
    return [[[step(s, c, z, cells) for s in range(1 << cells)] for z in (0, 1)] for c in (0, 1)]


def block(state, gap, tab):
    """Every (readings of site 1 at the gap's white ticks, end state) a block can give from one state."""
    front = {(state, ())}
    for i in range(gap + 1):
        centre = 1 if i == 0 else 0
        nxt = set()
        for s, seen in front:
            reading = seen if i == 0 else seen + (s & 1,)          # site 1 at this tick, a white centre tick
            for z in (0, 1):
                nxt.add((tab[centre][z][s], reading))
        front = nxt
    return front


def constants(kit):
    text = open(kit + '/lean/Ruliology/CellularAutomata/Rule30Certificates/MixedGapClocks.lean').read()
    get = lambda name: int(re.search(r'^def %s : Nat := (0x[0-9a-f]+)' % name, text, re.M).group(1), 16)
    members = lambda mask: {s for s in range(4096) if (mask >> s) & 1}
    return members(get('F')), members(get('E'))


def image(states, gap, tab):
    """All end states of one block from a set of states (free bits both ways at every tick)."""
    cur = set(states)
    for i in range(gap + 1):
        centre = 1 if i == 0 else 0
        cur = {tab[centre][z][s] for s in cur for z in (0, 1)}
    return cur


def replay(kit):
    tab = make_tables(12)
    F, E = constants(kit)
    print('F has', len(F), 'states and E has', len(E), '; E inside F:', E <= F)
    for q in (7, 9):
        print('gap', q, ': F stays in F', image(F, q, tab) <= F, '; E stays in E', image(E, q, tab) <= E)
    motif = (9, 9, 7, 9, 9, 7, 9, 9, 7, 9)
    cur, outside = set(F), []
    for q in motif:
        cur = image(cur, q, tab)
        outside.append(len(cur - E))
    print('motif', motif, ': states outside E after each gap', outside, '; final image', len(cur), 'states, inside E:', cur <= E)
    print('ticks in the motif:', sum(q + 1 for q in motif))
    resets = []
    cache = {(): frozenset(F)}
    for n in range(1, 11):
        for word in product((7, 9), repeat=n):
            cache[word] = frozenset(image(cache[word[:-1]], word[-1], tab))
            if cache[word] <= E:
                resets.append(word)
    print('words of at most ten gaps over {7, 9}:', sum(2 ** n for n in range(1, 11)), '; those carrying F into E:', resets)


def necklaces(letters, n):
    """Primitive cyclic words of length n, each by its least rotation."""
    for word in product(letters, repeat=n):
        rots = [word[i:] + word[:i] for i in range(n)]
        if word == min(rots) and len(set(rots)) == n:
            yield word


def analyse(cells, start, letters, maxlen, tab, E=None, label=''):
    import numpy as np
    states = sorted(start)
    index = {s: i for i, s in enumerate(states)}
    n = len(states)
    res = {q: [block(s, q, tab) for s in states] for q in letters}
    for q in letters:
        assert all(e in index for r in res[q] for e, _ in r), 'the start set is not closed under gap %d' % q
    # a pair of states is bad when some common future shows two different sets of readings
    bad = np.zeros((n, n), dtype=bool)
    succ = {}
    for q in letters:
        reads = [frozenset(seen for _, seen in r) for r in res[q]]
        single = np.array([len(r) == 1 for r in reads])
        key = {}
        ident = np.array([key.setdefault(r, len(key)) for r in reads])
        bad |= ~(single[:, None] & single[None, :] & (ident[:, None] == ident[None, :]))
        m = np.zeros((n, n), dtype=np.float32)
        for i, r in enumerate(res[q]):
            for e, _ in r:
                m[i, index[e]] = 1
        succ[q] = m
    rounds = 0
    while True:
        new = bad.copy()
        for q in letters:
            new |= (succ[q] @ bad.astype(np.float32) @ succ[q].T) > 0
        rounds += 1
        if (new == bad).all():
            break
        bad = new
    settled = [i for i in range(n) if not bad[i, i]]
    D = {states[i] for i in settled}
    classes = {}
    for i in settled:
        classes.setdefault(tuple(np.flatnonzero(~bad[i, settled])), []).append(i)
    print('%s%d cells, gaps %s: %d states at block boundaries; settled %d, in %d classes; fixed point in %d rounds'
          % (label, cells, list(letters), n, len(D), len(classes), rounds))
    if E is not None:
        print('   E inside the settled set:', E <= D, '; settled states outside E:', len(D - E))
    A = [i for i in range(n) if bad[i, i]]
    aidx = {i: k for k, i in enumerate(A)}
    stay = {q: [[aidx[index[e]] for e in {e for e, _ in res[q][i]} if index[e] in aidx] for i in A] for q in letters}
    forced = {q: sum(1 for k in range(len(A)) if not stay[q][k]) for q in letters}
    print('   unsettled states:', len(A), '; of them, those that every gap q carries into the settled set:', forced)
    # the unsettled states that can stay unsettled for ever under some sequence of gaps
    live = set(range(len(A)))
    while True:
        keep = {k for k in live if any(any(j in live for j in stay[q][k]) for q in letters)}
        if keep == live:
            break
        live = keep
    print('   unsettled states with an unsettled path for ever under some gaps:', len(live))
    survivors, total = [], 0
    for length in range(1, maxlen + 1):
        for word in necklaces(letters, length):
            total += 1
            cur = set(live)
            while True:
                nxt = cur
                for q in word:
                    nxt = {j for k in nxt for j in stay[q][k] if j in live}
                nxt &= cur
                if nxt == cur:
                    break
                cur = nxt
            if cur:
                survivors.append((word, len(cur)))
    print('   primitive cyclic words of at most %d gaps: %d; those with a path outside the settled set for ever: %d'
          % (maxlen, total, len(survivors)))
    for word, size in survivors[:40]:
        print('      ', ' '.join(map(str, word)), '(%d states)' % size)
    if E is not None:
        entering = 0
        for length in range(1, maxlen + 1):
            for word in necklaces(letters, length):
                cur, seen = set(states), set()
                while frozenset(cur) not in seen and not cur <= E:
                    seen.add(frozenset(cur))
                    for q in word:
                        cur = image(cur, q, tab)
                entering += cur <= E
        print('   of the %d words, those whose repetition carries the whole start set into E: %d' % (total, entering))
    return D, survivors


def main():
    mode = sys.argv[1]
    if mode == 'replay':
        return replay(sys.argv[2])
    letters = tuple(int(x) for x in sys.argv[3].split(',')) if len(sys.argv) > 3 else (7, 9)
    maxlen = int(sys.argv[4]) if len(sys.argv) > 4 else 12
    if mode == 'domain':
        tab = make_tables(12)
        F, E = constants(sys.argv[2])
        analyse(12, F, letters, maxlen, tab, E, 'the kit\'s F: ')
        own = set()
        for q in letters:
            own |= image(range(4096), q, tab)
        while True:
            more = set(own)
            for q in letters:
                more |= image(own, q, tab)
            if more == own:
                break
            own = more
        print('states reachable after at least one block of these gaps from anywhere:', len(own), '; inside F:', own <= F)
        analyse(12, own, letters, maxlen, tab, E & own, 'reachable states: ')
    elif mode == 'wide':
        cells = int(sys.argv[2])
        tab = make_tables(cells)
        own = set()
        for q in letters:
            own |= image(range(1 << cells), q, tab)
        while True:
            more = set(own)
            for q in letters:
                more |= image(own, q, tab)
            if more == own:
                break
            own = more
        analyse(cells, own, letters, maxlen, tab, None, 'reachable states: ')


main()
