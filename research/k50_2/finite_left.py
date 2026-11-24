"""Count anchored GE2 words and recover their unique canonical zero-wall seeds.

Run with Python 3 from any directory. Time m is measured in white samples,
so one canonical seed occupies 2*m bits. Only completed gaps trigger R67.
"""

from collections import Counter
from functools import cache
import re

from ge2_events import KIT, kit_pairs


PAIRS = kit_pairs()


def forward(seed, ticks):
    word = 0
    for t in range(ticks):
        word |= (seed & 1) << t
        seed = (seed >> 1) ^ (seed | (seed << 1))
    return word


def invert(word, ticks):
    east = seed = 0
    for depth in range(ticks):
        seed |= (word & 1) << depth
        east, word = word, (word >> 1) ^ (word | east)
    return seed


@cache
def choices(previous, twos, wait):
    """twos=-1 before a 5 or after another gap, otherwise its capped 2-run."""
    edges = []
    if wait < 4:
        edges.append((False, previous, twos, wait + 1, False))
    gap = wait + 1
    if gap in (2, 3, 4, 5) and (previous == 0 or (previous, gap) in PAIRS):
        forbidden = gap == 5 and twos == 2
        tail = 0 if gap == 5 else min(2, twos + 1) if gap == 2 and twos >= 0 else -1
        edges.append((True, gap, tail, 0, forbidden))
    return edges


def counts(horizons):
    frontier = Counter({(0, -1, 0, True): 1})
    totals = {}
    for m in range(1, max(horizons) + 1):
        if m in horizons:
            clean_count = sum(n for (*_, clean), n in frontier.items() if clean)
            live_count = sum(n for (prev, tail, age, clean), n in frontier.items()
                             if clean and extendible(prev, tail, age))
            totals[m] = sum(frontier.values()), clean_count, live_count
        following = Counter()
        for (previous, twos, wait, clean), n in frontier.items():
            for _, gap, tail, age, forbidden in choices(previous, twos, wait):
                following[gap, tail, age, clean and not forbidden] += n
        frontier = following
    return totals


def kit_finite_seeds(m):
    source = KIT.parent.parent / 'Rule30PeriodTwoWidth13.lean'
    listing = re.search(rf'def seeds{m} : List Nat :=\s*\[([^\]]+)\]', source.read_text(encoding='utf-8'))
    return {int(n) for n in listing[1].split(',')}


def scan_literal(seed, m):
    """Independently read the physical ticks using delta at state 10 in the kit."""
    trace = forward(seed, 2 * m)
    if trace & 1:
        return False, False
    q = 10
    kicks = [0]
    for t in range(1, 2 * m):
        black = (trace >> t) & 1
        if t % 2 and not black:
            return False, False
        if black:
            if (q - 10) % 10 == 9:
                return False, False
            q += 1
        else:
            p, elapsed = divmod(q - 10, 10)
            gap = (elapsed + 1) // 2
            if elapsed % 2 == 0 or gap not in (2, 3, 4, 5) or (p and (p + 1, gap) not in PAIRS):
                return False, False
            q = 10 + 10 * (gap - 1)
            kicks.append(t // 2)
    gaps = ''.join(str(b - a) for a, b in zip(kicks, kicks[1:]))
    return True, re.search('522+5', gaps) is None


@cache
def extendible(previous, twos, wait):
    # Every completed-gap state has an infinite continuation: from a 2 use
    # 4,5, then 3 forever; from a 4 use 5; from 3 or 5 use 3 forever.
    # When the last gap is unfinished it must first be possible to close it.
    if wait == 0:
        return True
    return any((kick or extendible(gap, tail, age)) and not forbidden
               for kick, gap, tail, age, forbidden in choices(previous, twos, wait))


def check_live_states():
    pending = [(0, -1, 0)]
    visited = set(pending)
    while pending:
        state = pending.pop()
        children = [(gap, tail, age) for _, gap, tail, age, forbidden in choices(*state)
                    if not forbidden]
        assert bool(children) == extendible(*state) == (state != (2, 2, 4))
        for child in children:
            if child not in visited:
                visited.add(child)
                pending.append(child)
    print('reachable clean states:', len(visited), 'dead: previous gap 2, at least two 2s after 5, age 4')


def census(limit=48, independent_limit=18):
    totals = counts(set(range(1, limit + 1)) | {64, 100, 250, 500})
    # A pair has packed value 2 (white then black) or 3 (black then black).
    frontier = [(2, 0, -1, 0, True)]
    brute = {2}
    print('m GE2 filtered live min_weight_GE2 min_weight_filtered min_weight_live')
    raised = []
    for m in range(1, limit + 1):
        all_min = clean_min = live_min = 2 * m
        clean_count = live_count = 0
        clean_seeds = set()
        removed = []
        extendible_seeds = set()
        for word, previous, twos, wait, clean in frontier:
            seed = invert(word, 2 * m)
            weight = seed.bit_count()
            all_min = min(all_min, weight)
            if clean:
                clean_count += 1
                clean_min = min(clean_min, weight)
                if extendible(previous, twos, wait):
                    live_count += 1
                    live_min = min(live_min, weight)
            if m <= independent_limit:
                assert forward(seed, 2 * m) == word
                if clean:
                    clean_seeds.add(seed)
                    if extendible(previous, twos, wait):
                        extendible_seeds.add(seed)
                else:
                    removed.append(seed)
        assert totals[m] == (len(frontier), clean_count, live_count)
        if m <= independent_limit:
            if m > 1:
                brute = {child for parent in brute for high in range(4)
                         if scan_literal(child := parent | high << (2 * m - 2), m)[0]}
            assert brute == clean_seeds.union(removed)
            assert clean_seeds == {x for x in brute if scan_literal(x, m)[1]}
            assert extendible_seeds == {x for x in clean_seeds if
                                        any(scan_literal(x | high << (2*m), m+1)[1] for high in range(4))}
            if m in (6, 9, 12):
                assert clean_seeds == kit_finite_seeds(m)
            if m == 12:
                print('24-bit classes with an infinite symbolic continuation:', len(extendible_seeds),
                      'dead:', sorted(clean_seeds - extendible_seeds))
            if m == 15:
                print('first removed:', sorted(removed), 'trace, earliest tick first:',
                      [format(forward(x, 30), '030b')[::-1] for x in sorted(removed)])
            if m == 14:
                print('first dead (no extension):', sorted(clean_seeds - extendible_seeds))
        print(m, len(frontier), clean_count, live_count, all_min, clean_min, live_min)
        if clean_min > all_min:
            raised.append(m)
        if m < limit:
            frontier = [(word | (2 if kick else 3) << (2 * m), gap, tail, age, clean and not forbidden)
                        for word, previous, twos, wait, clean in frontier
                        for kick, gap, tail, age, forbidden in choices(previous, twos, wait)]
    print('horizons with higher minimum weight:', raised)
    for m in (64, 100, 250, 500):
        print('count only', m, *totals[m])


def renewal_radius(filtered):
    # First return to gap 5, measured in white intervals, using the kit's pairs.
    def mass(z):
        twos = z**2 if filtered else z**2 / (1-z**2)
        return z**5 * (1/(1-z**3) + twos + z**6/(1-z**2))
    lo, hi = 0., 1.
    for _ in range(53):
        z = (lo + hi) / 2
        if mass(z) < 1:
            lo = z
        else:
            hi = z
    return 1 / ((lo + hi) / 2)


if __name__ == '__main__':
    check_live_states()
    census()
    print('growth per white sample (GE2, filtered):', renewal_radius(False), renewal_radius(True))
    seed75 = 20 + 2 * ((128**75 - 1) // 127)
    m = next(n for n in range(1, 271) if not scan_literal(seed75, n)[0])
    print('Galindo seed75 first GE2 failure:', m, 'low seed:', seed75 % 2**(2*m),
          'trace:', format(forward(seed75, 2*m), f'0{2*m}b')[::-1])
