"""Three-tick carrying read and seed-anchored moving covers. No third-party dependencies."""
from functools import lru_cache
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "r2"))
from twin_past import C20, edge_step, scan, step


ALL = (1 << 64) - 1
TRANS = [[scan(b, s, 3) for s in range(64)] for b in range(2)]


@lru_cache(maxsize=8192)
def preimage(mask, bit):
    return sum(1 << s for s, target in enumerate(TRANS[bit]) if (mask >> target) & 1)


@lru_cache(maxsize=200000)
def closes_from(word):
    # Bit s marks an incoming register carried to zero after reading the whole word.
    if word == 0:
        return 1
    return preimage(closes_from(word >> 1), word & 1)


def grow(words):
    return {edge_step(2*p + b) for p in words for b in (0, 1)}


def stats(words):
    masks = [closes_from(p) for p in words]
    return dict(words=len(words), failing_words=sum(m != ALL for m in masks),
                failing_pairs=sum(64 - m.bit_count() for m in masks))


def finite_parent(y, head):
    # A nonzero finite parent must be one bit shorter. Forward validation is exact.
    prev, cur = 0, head
    parent = 0
    for i in range(y.bit_length() - 1):
        parent |= cur << i
        prev, cur = cur, ((y >> i) & 1) ^ (cur | prev)
    return parent if parent & 1 == head and step(parent) == y else None


def failure(y, depth):
    branches = [("", y)]
    for _ in range(depth):
        nxt = []
        for path, r in branches:
            for h in (0, 1):
                p = finite_parent(r, h)
                if p is None:
                    return path + str(h)
                nxt.append((path + str(h), p))
        branches = nxt
    return None


def aged(y, age):
    for _ in range(age):
        y = step(y)
    return y


def review():
    words = set(C20)
    cover = {}
    for a in range(26, 35):
        cover[a] = stats(words)
        words = grow(words)
    witnesses = []
    for k, (seed, age) in enumerate([(2, 7), (144, 23), (617, 30), (7815, 58),
                                      (144, 72), (18426, 103)], 1):
        path = failure(aged(seed, age), k)
        assert path is not None
        witnesses.append(dict(depth=k, seed=seed, age=age, failed_prefix=path))
    return dict(cover=cover, witnesses=witnesses)


def research(width, burn):
    # All high-width seeds. Fixed-width top updates until burn, then one extra
    # input symbol is admitted per tick. Narrower seeds are tested separately.
    words = set(range(1 << (width-1), 1 << width))
    for _ in range(burn):
        words = {edge_step(p) for p in words}
    checks = {}
    for a in range(burn, 35):
        if a >= 30:
            checks[a] = stats(words)
            if a >= 31 and checks[a]['failing_words'] == 0:
                for seed in range(1, 1 << (width-1)):
                    witness = failure(aged(seed, a), 3)
                    if witness is not None:
                        return dict(checks=checks, narrow_failure=[seed, a, witness])
                return dict(checks=checks, passed_age=a, narrow_seeds=(1 << (width-1))-1)
        if len(words) > 200000:
            return dict(checks=checks, cutoff_age=a)
        words = grow(words)
    return dict(checks=checks)


if __name__ == '__main__':
    print(json.dumps(review()))
    for width, burn in [(1, 0), (8, 2), (14, 6), (16, 8)]:
        result = research(width, burn)
        print(json.dumps(dict(width=width, burn=burn, **result)), flush=True)
        if result.get('passed_age') == 31:
            break
