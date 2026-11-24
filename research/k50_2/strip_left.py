"""Intersect the actual width-six projection and the named onset words with GE2."""

from collections import Counter, deque
from functools import cache
import re

from bracket_width import after, graph, tick
from finite_left import KIT, choices, forward, invert, kit_finite_seeds


EDGES = graph(6)
IMAGE = frozenset(y for children in EDGES for y in children)
FIRST = frozenset(x for x in IMAGE if x & 1)
source = (KIT.parent.parent / 'Rule30PeriodTwoOnset.lean').read_text(encoding='utf-8')


def named_words():
    rhs = source.split('def forbidden6 : List (List Bool) := ', 1)[1].split('/--', 1)[0]
    short = source.split('def short6 : List Bool := ', 1)[1].splitlines()[0]
    return {''.join('1' if v == 'true' else '0' for v in re.findall('true|false', row))
            for row in re.findall(r'\[([a-z, ]+)\]', rhs + short)}


WORDS = named_words()
REDUCED = {'101010000', '10010000101'}


def suffix_machine(words):
    prefixes = {w[:i] for w in words for i in range(len(w))}

    @cache
    def read(history, pulse):
        if history is None:
            return None
        new = history + str(int(pulse))
        if any(new.endswith(w) for w in words):
            return None
        return max((p for p in prefixes if new.endswith(p)), key=len)

    return read


read_named = suffix_machine(WORDS)
read_reduced = suffix_machine(REDUCED)


@cache
def read_strip(states, pulse):
    return frozenset(y for x in states for y in EDGES[x] if (y & 1) == pulse)


def advance(state):
    prev, wait, named, strip = state
    for pulse, gap, _, age, _ in choices(prev, -1, wait):
        yield pulse, (gap, age, read_named(named, pulse), read_strip(strip, pulse))


START = (0, 0, '1', FIRST)


def product():
    # All continuations of every reachable state. The queue gives shortest witnesses.
    pending = deque([(START, '1')])
    seen = {START}
    first_named = first_strip = first_difference = None
    while pending:
        state, word = pending.popleft()
        named, strip = state[2] is not None, bool(state[3])
        assert not strip or named
        if not strip and first_strip is None:
            first_strip = word
        if not named and first_named is None:
            first_named = word
        if named and not strip and first_difference is None:
            first_difference = word
        for pulse, child in advance(state):
            if child not in seen:
                seen.add(child)
                pending.append((child, word + str(int(pulse))))
    print('product states', len(seen), 'shortest failure (named, full strip), shortest distinguishing word',
          first_named, first_strip, first_difference)
    return first_difference


def reduced_equivalence():
    start = (START, '1')
    pending, seen = [start], {start}
    while pending:
        state, reduced = pending.pop()
        assert (state[2] is not None) == (reduced is not None) == bool(state[3])
        for pulse, child in advance(state):
            pair = child, read_reduced(reduced, pulse)
            if pair not in seen:
                pending.append(pair)
                seen.add(pair)
    print('product with the two retained factors:', len(seen), 'states, all answers agree')


def gate_word(seed, m):
    bits = forward(seed, 2*m)
    return ''.join('0' if (bits >> (2*i)) & 1 else '1' for i in range(m))


def seed_of_gate(word):
    packed = sum((2 if v == '1' else 3) << (2*i) for i, v in enumerate(word))
    return invert(packed, 2*len(word))


def classify(word):
    state = START
    assert word[0] == '1'
    for bit in word[1:]:
        state = next(child for pulse, child in advance(state) if pulse == (bit == '1'))
    return state[2] is not None, bool(state[3])


def census():
    frontier = Counter({START: 1})
    for m in range(1, 101):
        if m in (6, 9, 10, 11, 12, 13, 14, 15, 24, 48, 100):
            print(m, 'GE2, named, width-six:', sum(frontier.values()),
                  sum(n for state, n in frontier.items() if state[2] is not None),
                  sum(n for state, n in frontier.items() if state[3]))
        if m in (6, 9, 12):
            rejected = {k: [] for k in ('named', 'additional strip')}
            for seed in sorted(kit_finite_seeds(m)):
                word = gate_word(seed, m)
                assert seed_of_gate(word) == seed
                named, strip = classify(word)
                if not strip:
                    rejected['additional strip' if named else 'named'].append((seed, word))
            print('exact excluded kit residues', m, rejected)
        following = Counter()
        for state, n in frontier.items():
            for _, child in advance(state):
                following[child] += n
        frontier = following


def pure35():
    pending, seen = [FIRST], {FIRST}
    while pending:
        state = pending.pop()
        for gap in (3, 5):
            child = after(EDGES, state, gap)
            assert child
            if child not in seen:
                pending.append(child)
                seen.add(child)
    print('all 3/5 sequences survive the width-six projection:', len(seen), 'nonempty subsets at kicks')


def seed_weights(horizons):
    frontier = [(START, 2, True)]
    for m in range(1, max(horizons) + 1):
        if m in horizons:
            best = {}
            minimum_rows = {True: [], False: []}
            for _, packed, only35 in frontier:
                seed = invert(packed, 2*m)
                score = seed.bit_count(), seed
                if only35 not in best or score[0] < best[only35][0]:
                    minimum_rows[only35] = [seed]
                    best[only35] = score
                elif score[0] == best[only35][0]:
                    minimum_rows[only35].append(seed)
                    best[only35] = min(best[only35], score)
            print('minimum (weight, least seed attaining it) at', m,
                  '3/5:', best.get(True), 'contains a completed 2 or 4:', best.get(False))
            if m == 48:
                for only35, seeds in minimum_rows.items():
                    last = Counter(last_valid_prefix(seed, only35) for seed in seeds)
                    assert min(last) >= m
                    print('fixed minimum rows at', m, '3/5 only', only35, 'count', len(seeds),
                          'last valid horizon and multiplicity:', sorted(last.items()))
        if m < max(horizons):
            frontier = [(child, packed | (2 if pulse else 3) << (2*m),
                         only35 and (not pulse or child[0] in (3, 5)))
                        for state, packed, only35 in frontier for pulse, child in advance(state)
                        if child[3]]


def last_valid_prefix(seed, only35):
    # Any extension with the same total weight has zero bits above the canonical row.
    # Follow that finite row until its first invalid reading.
    state, m = START, 1
    row = seed
    while True:
        odd = (row >> 1) ^ (row | (row << 1))
        assert odd & 1
        row = (odd >> 1) ^ (odd | (odd << 1))
        pulse = row & 1 == 0
        following = [child for bit, child in advance(state) if bit == pulse and child[3]
                     and (not only35 or not pulse or child[0] in (3, 5))]
        if not following or (((row >> 1) ^ (row | (row << 1))) & 1) == 0:
            return m
        state = following[0]
        m += 1


if __name__ == '__main__':
    print('kit onset words:', sorted(WORDS))
    separating = product()
    if separating:
        print('separating canonical seed:', seed_of_gate(separating))
    reduced_equivalence()
    census()
    pure35()
    seed_weights({9, 12, 21, 27, 48, 49})
    black_image = {tick(x, 6, 1, a) for x in range(64) for a in (0, 1)}
    for label, image in [('free white', range(64)), ('preceding black', black_image)]:
        states = after(EDGES, after(EDGES, [x for x in image if x & 1], 2), 2)
        print(label, 'after 2,2:', sorted(states), '5-gap endpoints:', sorted(after(EDGES, states, 5)))
    # A fully specified finite right half with a free white first tick.
    x = 137
    observed = [x & 1]
    for _ in range(9):
        x = (x << 1) ^ (x | (x >> 1))
        x = ((x << 1) | 1) ^ (x | (x >> 1))
        observed.append(x & 1)
    assert ''.join(map(str, observed)) == '1010100001'
    print('free-white finite right half 137:', ''.join(map(str, observed)))
