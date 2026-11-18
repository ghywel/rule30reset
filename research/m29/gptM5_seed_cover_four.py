"""Fixed-budget seed-anchored four-layer cover following R23."""
from functools import lru_cache
import json

from gptM5_three_tick import C20, aged, edge_step, failure, grow, scan


@lru_cache(maxsize=None)
def reverse_masks(bit):
    masks = [0] * 256
    for r in range(256):
        masks[scan(bit, r, 4)] |= 1 << r
    return masks


@lru_cache(maxsize=8192)
def transfer(mask, bit):
    result = 0
    parents = reverse_masks(bit)
    while mask:
        low = mask & -mask
        result |= parents[low.bit_length()-1]
        mask -= low
    return result


@lru_cache(maxsize=150000)
def successful(word):
    if not word:
        return 1
    return transfer(successful(word >> 1), word & 1)


ALL = (1 << 256) - 1
WALL = sum(1 << s for s in range(256) if (s & 0b10101010) == 0)


def check_narrow(width, age):
    for seed in range(1, 1 << (width - 1)):
        r = aged(seed, age)
        if successful(r) & WALL != WALL:
            path = failure(r, 4)
            assert path is not None
            return dict(narrow_witness=[seed, path])
    return dict(narrow_pass=(1 << (width - 1)) - 1)


def test(width, burn, start=59, end=80, limit=200000):
    words = set(range(1 << (width - 1), 1 << width))
    for _ in range(burn):
        words = {edge_step(p) for p in words}
    checks = []
    for a in range(burn, end + 1):
        if len(words) > limit:
            return dict(checks=checks, cutoff_age=a, cutoff_words=len(words))
        if a >= start:
            bad = sum(successful(p) != ALL for p in words)
            checks.append((a, len(words), bad))
            if bad == 0:
                narrow = check_narrow(width, a)
                if 'narrow_pass' in narrow:
                    return dict(checks=checks, passed_age=a, **narrow)
        if a < end:
            words = grow(words)
    return dict(checks=checks)


if __name__ == '__main__':
    # Direct step-by-step scanning on the small age-26 base, including wall states.
    for word in C20:
        ok = 0
        for incoming in range(256):
            s = incoming
            for i in range(word.bit_length()):
                s = scan((word >> i) & 1, s, 4)
            ok |= (s == 0) << incoming
        assert successful(word) == ok
    for seed, age in [(7815, 58), (1, 80), (13, 46), (617, 30)]:
        r = aged(seed, age)
        assert (successful(r) & WALL == WALL) == (failure(r, 4) is None)
    for width, burn in [(1, 0), (8, 2), (12, 4), (16, 8)]:
        result = test(width, burn)
        print(json.dumps(dict(width=width, burn=burn, **result)), flush=True)
        if result.get('passed_age') == 59:
            break
