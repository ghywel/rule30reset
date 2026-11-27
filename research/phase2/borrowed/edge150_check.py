"""Replay the (150,180) boundary and outer-edge predictions from the Wolfram tables.

Packed bit 0 is depth 1 beside the permanently white wall. A round has two ticks.
The front windows use ordinary west-to-east site coordinates with the first 1 at 0.
"""

from collections import Counter


def cell(rule, left, centre, right):
    return (rule >> (4 * left + 2 * centre + right)) & 1


def tick(sites, rule, wall=None):
    if not sites:
        return set()
    return {
        i for i in range(min(sites) - 1, max(sites) + 2)
        if (wall is None or i < wall)
        and cell(rule, i - 1 in sites, i in sites, i + 1 in sites)
    }


def step(sites, wall=None):
    return tick(tick(sites, 150, wall), 180, wall)


def edge_windows():
    counts = Counter()
    for bits in range(1 << 7):
        row = {0} | {j + 1 for j in range(7) if bits >> j & 1}
        nxt = step(row)
        if 1 in row:
            assert min(nxt) == -1 and 0 in nxt
            case = '11 grows'
        elif 2 in row:
            assert min(nxt) == 1
            case = '101 retreats'
        elif 3 in row:
            assert min(nxt) == 0 and 1 in nxt
            case = '1001 locks'
        else:
            assert min(nxt) == 0 and 1 not in nxt and 2 in nxt
            assert min(step(nxt)) == 1
            case = '1000 retreats in two'
        counts[case] += 1
    return counts


def unpack(row):
    return {-i - 1 for i in range(row.bit_length()) if row >> i & 1}


def pack(sites):
    return sum(1 << (-i - 1) for i in sites)


def locked(row):
    return row >= 3 and row >> (row.bit_length() - 2) == 3


def wall_check():
    # Memoisation shares only resolved forward paths. A repeat outside the claimed
    # terminals would be a counterexample, including a cycle with a nontrivial basin.
    delay = {0: 0, 1: 0, 2: 0}
    for start in range(3, 1 << 14):
        row = start
        path = []
        visited = set()
        while row not in delay and not locked(row):
            assert row not in visited, ('cycle', start, row)
            visited.add(row)
            path.append(row)
            row = pack(step(unpack(row), wall=0))
        assert row > 2, ('terminal preimage', start, row)
        n = delay.get(row, 0)
        for row in reversed(path):
            n += 1
            delay[row] = n
        delay.setdefault(start, 0)
    terminals = [pack(step(unpack(v), wall=0)) for v in range(16)]
    print('small forward map:', terminals)
    assert terminals[:3] == [0, 0, 2]
    for width in range(2, 15):
        starts = range(max(3, 1 << (width - 1)), 1 << width)
        slow = max(starts, key=delay.__getitem__)
        print('width, longest launch delay in rounds, least attaining row:',
              width, delay[slow], slow)
        assert delay[slow] <= 2 * width + 2


if __name__ == '__main__':
    print('full-line front windows:', dict(sorted(edge_windows().items())))
    wall_check()
