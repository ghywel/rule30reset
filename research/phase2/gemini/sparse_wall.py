"""Exact death tree for white-wall starts with a bounded number of black cells.

Every node y is a complete finite row in its own right. Its first failed tick
d bounds the position of the next added black that could repair that failure.
Run with a maximum *weight*, without any bound on support width or lifetime.
"""
from collections import Counter
from hashlib import sha256
from sys import argv


def step(y):
    return (y >> 1) ^ (y | (y << 1))


def first_failure(y):
    t = 0
    while y & 1:
        y = step(step(y))
        t += 2
    return t


def scan(max_weight):
    counts = Counter()
    worst = {}
    blocks = []
    digest = sha256()

    def visit(y, weight):
        d = first_failure(y)
        width = y.bit_length()
        counts[weight] += 1
        if weight not in worst or d > worst[weight][0]:
            worst[weight] = (d, y)
        digest.update(f"{y} {weight} {d}\n".encode("ascii"))
        if weight < max_weight:
            for pos in range(width, d + 1):
                visit(y + (1 << pos), weight + 1)

    visit(1, 1)
    for weight in range(1, max_weight + 1):
        if counts[weight]:
            blocks.append((weight, counts[weight], *worst[weight]))
    return blocks, digest.hexdigest()


if __name__ == "__main__":
    rows, digest = scan(int(argv[1]))
    print("weight  nodes  worst first failure (tick)  first maximizing visited row")
    for row in rows:
        print(*row)
    print("preorder sha256", digest)
