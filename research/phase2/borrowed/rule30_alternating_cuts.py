"""Replay the actual Rule 30 cuts and the small (150,180) control.

The Rule 30 reference has boundary trace 10 repeated. Away from the
wall-adjacent cell it is black exactly at odd zero-based indices.
Width is actual support width in the tested range: 1, and 2,4,...,128.
"""

from collections import Counter
from edge150_check import cell, tick, unpack


def direct(row, rules, through):
    for t in range(through + 1):
        yield int(-1 in row)
        row = tick(row, rules[t % len(rules)], wall=0)


def hybrid_control():
    east, here = [0] * 4, [1, 0, 1, 1]
    initial = []
    for _ in range(4):
        initial.append(here[0])
        west = []
        for t in range(4):
            value = cell((150, 180)[t % 2], 0, here[t], east[t])
            west.append(value ^ here[(t + 1) % 4])
        east, here = here, west
    assert initial == [1, 1, 1, 1]
    trace = list(direct(unpack(7), (150, 180), 6))
    assert trace[:3] == [1, 0, 1] and trace[3] == 0
    assert trace[4] == 1 and trace[6] == 0
    print('hybrid reference begins 1111; crop 111 readings through 6:', trace)


def main():
    delays = Counter()
    for width in [1, *range(2, 129, 2)]:
        start = {-1, *(-i - 1 for i in range(1, width, 2))}
        deadline = width + 4
        trace = list(direct(start, (30,), deadline))
        missed = next((t for t in range(0, deadline + 1, 2) if trace[t] == 0), None)
        expected = 2 if width == 1 else width + (2 if width % 4 == 0 else 4)
        assert missed == expected, (width, missed, expected)
        delays[missed - width] += 1
    print('Rules 30 cuts checked:', sum(delays.values()), 'delays:', sorted(delays.items()))
    hybrid_control()


if __name__ == '__main__':
    main()
