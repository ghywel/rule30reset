"""Replay a two-step east-extension obstruction using only Python's standard library."""
import argparse
import json
from collections import Counter
from functools import lru_cache
from itertools import product
from pathlib import Path


def physical_edges():
    words = set()
    for row in range(64):
        word = []
        for _ in range(3):
            word.append(2 * ((row >> 2) & 1) + ((row >> 3) & 1))
            row = (row << 1) ^ (row | (row >> 1))
        words.add(tuple(word))
    return sorted(words)


EDGES = physical_edges()
INDEX = {edge: i for i, edge in enumerate(EDGES)}
ENDS = [(4 * a + b, 4 * b + c) for a, b, c in EDGES]


@lru_cache(None)
def paths(mask):
    # Transitive closure by Warshall, including only paths of positive length.
    reach = [0] * 16
    for i, (u, v) in enumerate(ENDS):
        if mask >> i & 1:
            reach[u] |= 1 << v
    for k in range(16):
        for u in range(16):
            if reach[u] >> k & 1:
                reach[u] |= reach[k]
    return reach


@lru_cache(None)
def core(mask):
    reach = paths(mask)
    cycles = [i for i in range(16) if reach[i] >> i & 1]
    future = sum(1 << i for i in cycles)
    past = 0
    for i in cycles:
        past |= reach[i]
    # An edge lies on a two-sided path iff one can arrive from a cycle and leave to one.
    return sum(1 << i for i, (u, v) in enumerate(ENDS)
               if mask >> i & 1 and past >> u & 1 and reach[v] & future)


def no_east_lift(mask, word):
    # Work from the *last* tick to the first. Suffix states are two leading bits
    # of an eastern boundary that lifts the suffix's entire temporal word.
    west = [s >> 1 for s in word]
    center = [s & 1 for s in word]
    vertices = {u for i, (u, _) in enumerate(ENDS) if mask >> i & 1}
    left = len(word) - 2
    states = {(a, b) for a, b in product((0, 1), repeat=2)
              if west[left] ^ (center[left] | a) == center[left + 1]
              and 4 * (2 * center[left] + a) + 2 * center[left + 1] + b in vertices}
    for j in reversed(range(left)):
        earlier = set()
        for a in (0, 1):
            if west[j] ^ (center[j] | a) != center[j + 1]:
                continue
            for b, c in states:
                triple = (2 * center[j] + a, 2 * center[j + 1] + b,
                          2 * center[j + 2] + c)
                ei = INDEX.get(triple)
                if ei is not None and mask >> ei & 1:
                    earlier.add((a, b))
        states = earlier
    return not states


def only_simple_cycles(mask):
    reach = paths(mask)
    # Every cyclic SCC is a directed cycle iff each of its members has
    # exactly one internal out-edge. Edges between SCCs are immaterial.
    internal = Counter(u for i, (u, v) in enumerate(ENDS)
                       if mask >> i & 1 and reach[v] >> u & 1)
    return all(count == 1 for count in internal.values())


def check(filename):
    data = json.loads(filename.read_text(encoding="ascii"))
    assert len(EDGES) == 32 and [tuple(e) for e in data["edges"]] == EDGES
    proof = {int(k): item for k, item in data["proof"].items()}
    rate = data["rate"]
    assert type(rate) is int and rate >= 1
    explored = set()
    counts = Counter()
    pending = [core((1 << len(EDGES)) - 1)]
    while pending:
        mask = pending.pop()
        if mask in explored:
            continue
        explored.add(mask)
        kind, *args = proof[mask]
        counts[kind] += 1
        active = [i for i in range(len(EDGES)) if mask >> i & 1]
        if kind == "growth":
            k, = args
            assert type(k) is int and k >= 1
            row_sums = [1] * 16
            for _ in range(k):
                updated = [0] * 16
                for i in active:
                    u, v = ENDS[i]
                    updated[u] += row_sums[v]
                row_sums = updated
            assert max(row_sums) <= rate ** k, ("growth", mask)
        elif kind == "cycles":
            assert only_simple_cycles(mask), ("cycles", mask)
        elif kind == "miss":
            word, = args
            assert len(word) >= 2 and all(type(s) is int and 0 <= s <= 3 for s in word)
            assert no_east_lift(mask, word), ("lift exists", mask, word)
            if len(word) == 2:
                vertex = 4 * word[0] + word[1]
                remove = sum(1 << i for i in active if vertex in ENDS[i])
                assert remove, ("missing vertex", mask, word)
                pending.append(core(mask ^ remove))
            else:
                for t in set(zip(word, word[1:], word[2:])):
                    i = INDEX[t]
                    assert mask >> i & 1, ("missing edge", mask, t)
                    pending.append(core(mask ^ (1 << i)))
        else:
            raise ValueError(f"Unsupported proof node kind {kind!r}")
    assert explored == set(proof), "extraneous certificate nodes"
    print(filename.name, len(explored), dict(sorted(counts.items())), "passed")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("certificate", type=Path, nargs="+")
    arguments = parser.parse_args()
    if not __debug__:
        parser.error("Run without -O so the certificate checks are enabled.")
    for certificate in arguments.certificate:
        check(certificate)
