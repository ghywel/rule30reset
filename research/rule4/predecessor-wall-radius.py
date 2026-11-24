"""Replay the optimal one-step predecessor-wall reading law using Python 3."""

from collections import Counter
from itertools import product


def extend(mask, output):
    """Bit 2*b+c gives the wall when the eastern predecessor pair is (b,c)."""
    result = 0
    for b, c in product(range(2), repeat=2):
        a = output ^ (b | c)
        if mask & (1 << (2 * a + b)):
            result |= 1 << (2 * b + c)
    return result


def closed_run(word):
    """Search for the first closing zero, starting after the ignored first bit."""
    ones = 0
    for output in word[1:]:
        if output:
            ones += 1
        elif ones % 3 == 1:
            return True
        else:
            ones = 0
    return False


def direct_wall_counts(n):
    """Independent forward enumeration of every length-(n+2) predecessor."""
    counts = Counter()
    for parent in product(range(2), repeat=n+2):
        word = tuple(a ^ (b | c) for a, b, c in zip(parent, parent[1:], parent[2:]))
        counts[word, parent[0]] += 1
    return counts


if __name__ == "__main__":
    def quotient(mask):
        return min(mask, 15 - mask)

    table = [[quotient(extend(mask, bit)) for bit in (0, 1)] for mask in range(4)]
    assert table == [[0, 0], [1, 2], [0, 3], [1, 1]]
    print("Quotient transitions for inputs 0,1:", table)

    unresolved = []
    for n in range(13):
        counts = direct_wall_counts(n)
        ambiguous = 0
        for word in product(range(2), repeat=n):
            mask = 12
            for bit in word:
                mask = extend(mask, bit)
            black = mask.bit_count()
            assert (counts[word, 0], counts[word, 1]) == (4 - black, black)
            assert closed_run(word) == (black in (0, 4))
            ambiguous += 0 < black < 4
        unresolved.append(ambiguous)
    assert unresolved[:3] == [1, 2, 4]
    assert all(unresolved[n] == unresolved[n-1] + 2 * unresolved[n-3]
               for n in range(3, len(unresolved)))
    print("Unresolved counts, n=0..12:", unresolved)
