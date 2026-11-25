"""Check the physical strip horizon and the integer potential on small complete cases."""
from functools import cache
from itertools import product


def bitstrings(n):
    return product((0, 1), repeat=n)


def cone_outputs(wall):
    """Evolve the shrinking physical triangle to column one."""
    outputs = set()
    for row in bitstrings(len(wall)):
        mask = []
        for b in wall:
            mask.append(b | row[0])
            row = tuple(l ^ (c | r) for l, c, r in zip((b,) + row, row, row[1:]))
        outputs.add(tuple(mask))
    return outputs


@cache
def children(width, states, b):
    dest = [set(), set()]
    for x in states:
        for east in (0, 1):
            left = (x << 1) | b
            right = (x >> 1) | (east << (width - 1))
            y = (left ^ (x | right)) % (1 << width)
            dest[b | (x & 1)].add(y)
    return tuple(frozenset(t) for t in dest)


def strip_words(w, state, wall):
    if not wall:
        return {()} if state else set()
    return {(o,) + tail for o, s in enumerate(children(w, state, wall[0]))
            for tail in strip_words(w, s, wall[1:])}


def horizon_checks():
    ghosts = []
    for n in range(1, 7):
        counts = []
        for wall in bitstrings(n):
            phys = cone_outputs(wall)
            counts.append(len(phys))
            for w in range(1, n + 2):
                strip = strip_words(w, frozenset(range(1 << w)), wall)
                assert phys <= strip
                if w >= n:
                    assert phys == strip
                elif phys != strip:
                    ghosts.append((n, w, wall, min(strip - phys)))
        assert len(cone_outputs((0,) * n)) == n + 1
        print(f'n={n} walls={len(counts)} total={sum(counts)} worst={max(counts)}')
    assert ghosts
    print('first strict overcount at thinner width:', ghosts[0])


def weight_checks(p, q, width=3, k=3):
    # All 256 subsets, including the empty set. A different calculation supplies the cap.
    sets = [frozenset(i for i in range(1 << width) if mask >> i & 1)
            for mask in range(1 << (1 << width))]
    physical = {wall: len(cone_outputs(wall)) for wall in bitstrings(k)}
    @cache
    def weight(s, future):
        return sum(p ** (k-1-j) * q ** j * len(strip_words(width, s, future[:j]))
                   for j in range(k))
    bad = 0
    for s in sets:
        for wall, physical_count in physical.items():
            dest = children(width, s, wall[0])
            W = weight(s, wall[:-1])
            assert bool(W) == bool(s)
            nxt = sum(weight(v, wall[1:]) for v in dest)
            count = len(strip_words(width, s, wall))
            assert count <= physical_count
            assert q*nxt + (p**k)*bool(s) == p*W + (q**k)*count
            bad += q*nxt > p*W
    print(f'{p}/{q} rows={len(sets)*len(physical)} violations={bad}')
    return bad


if __name__ == '__main__':
    horizon_checks()
    assert weight_checks(17, 10) == 0
    assert weight_checks(1, 1) > 0
