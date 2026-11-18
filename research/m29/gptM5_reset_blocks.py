"""Largest certified stack allowing sequential blocks of at most three joint layers."""
from functools import cache
import json

from gptM5_strip_review import ReverseScan, cycle, greedy
from twin_past import scan


@cache
def block(word, width, depth):
    """At a passing edge, return the longest common suffix of deepest-layer input to the next block."""
    states = set(range(4**depth))
    bitpos = 2*(depth-1)
    suffix_start = 0
    output = 0
    for j in range(width):
        heads = {(s >> bitpos) & 1 for s in states}
        if len(heads) > 1:
            suffix_start = j+1
        elif heads == {1}:
            output |= 1 << j
        b = (word >> j) & 1
        states = {scan(b, s, depth) for s in states}
    if states != {0}:
        return None
    assert 0 < suffix_start <= width
    return output >> suffix_start, width-suffix_start


@cache
def best(word, width, limit):
    result = 0
    for depth in range(1, limit+1):
        suffix = block(word, width, depth)
        if suffix is None:
            break  # a deeper pass projects to this pass
        result = max(result, depth + best(*suffix, limit))
    return result


if __name__ == '__main__':
    scanner = ReverseScan()
    rows = []
    for w in range(20,129):
        phases = cycle(w)
        capacities = [min(best(p,w,b) for p in phases) for b in (1,2,3)]
        assert capacities[0] == min(greedy(p,'run') for p in phases)
        exact = capacities[-1]
        assert all(scanner.start(p,exact) == 1 for p in phases)
        while all(scanner.start(p,exact+1) == 1 for p in phases):
            exact += 1
        rows.append([w, *capacities, exact])
    print(json.dumps(rows))
