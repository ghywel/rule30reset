"""Decode a four-cut partition from one binary arc, checking every phase exactly."""

from functools import cmp_to_key
from math import isqrt


# A pair (a,b) represents (a + b sqrt(2))/20. The rotation is sqrt(2)-1.
def floor(point):
    a, b = point
    root = isqrt(2 * b * b)
    return (a + (root if b >= 0 else -root - 1)) // 20


def shifted(point, steps):
    a, b = point
    a -= 20 * steps
    b += 20 * steps
    return a - 20 * floor((a, b)), b


def compare(left, right):
    if left == right:
        return 0
    return -1 if floor((left[0] - right[0], left[1] - right[1])) < 0 else 1


def ordered(points):
    return sorted(set(points), key=cmp_to_key(compare))


def trial(last):
    zero, gamma = (0, 0), (1, 0)
    cuts = ordered((zero, gamma, shifted(zero, 2), shifted(gamma, -3)))
    indices = range(-2, last + 1)
    # On each half-open atom every tested letter and the target colour are constant.
    # Its included left endpoint therefore represents all phases in that atom.
    endpoints = ordered(cuts + [shifted(p, -n) for n in indices for p in (zero, gamma)])
    outcomes = {}
    for point in endpoints:
        word = ''.join('1' if compare(shifted(point, n), gamma) < 0 else '0' for n in indices)
        colour = sum(compare(cut, point) <= 0 for cut in cuts) % 2
        outcomes.setdefault(word, set()).add(colour)
    ambiguous = sorted(word for word, colours in outcomes.items() if len(colours) > 1)
    return len(endpoints), len(outcomes), ambiguous


if __name__ == '__main__':
    assert trial(14) == (34, 23, ['0' * 17])
    assert trial(15) == (36, 26, [])
    print('Offsets -2 through 14: 34 atoms, 23 words, the 17 zeros are ambiguous.')
    print('Offsets -2 through 15: 36 atoms, 26 words, every target colour is determined.')
