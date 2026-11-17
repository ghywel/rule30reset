"""Compare a real four-tick history with the two black-headed paths through its twin."""
from ast import literal_eval
from collections import deque
from functools import lru_cache
from pathlib import Path
import sys

from twin_past import C20, edge_step, iterate

# Independent tuple implementation. At a cut, (left,current) uses ascending bit indices.
def advance(pairs, root_bit):
    next_pairs = []
    for left, current in pairs:
        next_pairs.append((current, root_bit ^ (left | current)))
        root_bit = current
    return tuple(next_pairs)


PAIRS = [tuple(((n >> (7 - 2*i)) & 1, (n >> (6 - 2*i)) & 1) for i in range(4))
         for n in range(256)]
TRANS = [[PAIRS.index(advance(pairs, b)) for pairs in PAIRS] for b in (0, 1)]


@lru_cache(maxsize=8192)
def transfer(word, width):
    # Compose single-bit maps beginning at the outside, where the terminal map is identity.
    if width == 0:
        return tuple(range(256))
    outer = transfer(word >> 1, width-1)
    return tuple(outer[d] for d in TRANS[word & 1])


def replay_certificate(path):
    line, = [l for l in Path(path).read_text().splitlines() if l.startswith("four-step edge certificate")]
    age, width, supplied = literal_eval(line.split(": ", 1)[1])
    words = set(C20)
    for _ in range(age - 26):
        # Scalar truth table on the extended moving band; the two sites beyond the top are white.
        new = set()
        for p in words:
            for low in (0, 1):
                extended = 2*p + low
                result = 0
                for i in range(extended.bit_length()):
                    a, b, c = [(extended >> j) & 1 for j in (i+2, i+1, i)]
                    result |= ((a+b+c+b*c) % 2) << i
                new.add(result)
        words = new
    assert width == 20 + age - 26 and sorted(words) == supplied
    assert all(set(transfer(word, width)) == {0} for word in words)
    print("independent replay: age, width, words, incoming registers", age, width, len(words), 256)


def start(first, third):
    return PAIRS.index(tuple((0, b) for b in (first, 1, third, 1)))


def move(state, table):
    actual, alt0, alt1 = (table[x] for x in state)
    if actual == alt0 or actual == alt1:
        return None
    return (actual, min(alt0, alt1), max(alt0, alt1))


def reachable():
    seen = set()
    queue = deque()
    for a in (0, 1):
        for b in (0, 1):
            triple = move((start(a,b), start(1-a,0), start(1-a,1)), TRANS[1])
            if triple is not None and triple not in seen:
                queue.append(triple)
                seen.add(triple)
    while queue:
        triple = queue.popleft()
        for table in TRANS:
            nxt = move(triple, table)
            if nxt is not None and nxt not in seen:
                if len(seen) >= 250000:
                    return None
                seen.add(nxt)
                queue.append(nxt)
    return seen


def main():
    replay_certificate(sys.argv[1])
    states = reachable()
    if states is None:
        print("relative closure UNKNOWN: 250000-state cap")
        return
    print("unmerged triples after arbitrary middle:", len(states))
    for width in (20, 24, 28, 32):
        extra = width - 20
        age = 26 if width == 20 else 46
        steps = age - max(26, width-1)
        words = {iterate(edge_step, (p << extra) | low, steps)
                 for p in C20 for low in range(1 << extra)}
        failed = []
        for word in sorted(words):
            end = transfer(word, width)
            mismatches = sum(end[x] == 0 and end[y] != 0 and end[z] != 0 for x,y,z in states)
            if mismatches:
                failed.append((word, mismatches))
        print("relative age, width, words, failing word/count:", age, width, len(words), failed)
        if not failed:
            return


if __name__ == '__main__':
    main()
