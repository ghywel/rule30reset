"""Exact depth-two driven rows, represented by shared suffix languages, edge first.

Usage: python3 threshold_language.py 1 2 3 4 5 6 7
The first all-zero register image gives T once the edge lies west of the wall.
"""
import argparse
from collections import Counter
from functools import cache

import numpy as np


EMPTY, END = 0, 1


class RowLanguage:
    """A node (left, right) denotes 0·left ∪ 1·right. END accepts the empty word."""

    def __init__(self):
        self.nodes = [(0, 0), (0, 0)]
        self.ids = {}
        self.root = EMPTY

    def node(self, left, right):
        if not (left or right):
            return EMPTY
        children = (left, right)
        if children not in self.ids:
            self.ids[children] = len(self.nodes)
            self.nodes.append(children)
        return self.ids[children]

    @classmethod
    def depth_two(cls):
        lang = cls()
        lang.root = lang.node(EMPTY, lang.node(END, END))
        return lang

    def advance(self):
        """In the edge frame, write a XOR (b OR c), then slide (a,b) to (b,c)."""
        out = RowLanguage()

        @cache
        def union(u, v):
            if not u or u == v:
                return v
            if not v:
                return u
            a, b = out.nodes[u]
            c, d = out.nodes[v]
            return out.node(union(a, c), union(b, d))

        @cache
        def visit(u, a, b):
            by_bit = [EMPTY, EMPTY]
            if u == END:
                for wall in (0, 1):
                    by_bit[a ^ (b | wall)] = END
            else:
                for c, child in enumerate(self.nodes[u]):
                    if child:
                        bit = a ^ (b | c)
                        by_bit[bit] = union(by_bit[bit], visit(child, b, c))
            return out.node(*by_bit)

        out.root = visit(self.root, 0, 0)
        visit.cache_clear()
        union.cache_clear()
        return out

    def prefix_length(self, word):
        """Longest prefix of word present in this physical language."""
        u = self.root
        for i, c in enumerate(word):
            u = self.nodes[u][int(c)]
            if u == EMPTY:
                return i
        return len(word)

    def count(self):
        sizes = [0, 1]
        for a, b in self.nodes[2:]:
            sizes.append(sizes[a] + sizes[b])
        return sizes[self.root]


class Inverse:
    """Register bits (current,east) at each of k inverse layers, low layer first."""

    def __init__(self, k):
        size = 4**k
        low = (size - 1) // 3  # bits 0, 2, ..., 2k-2
        on_zero = []
        for reg in range(size):
            current = reg & low
            east = (reg >> 1) & low
            above = (current << 2) & low
            on_zero.append((current << 1) | (above ^ (current | east)))
        self.step = np.array((on_zero, [r ^ 1 for r in on_zero]), dtype=np.int32)
        self.size = size
        self.nbytes = (size + 7) // 8
        self.all = (1 << size) - 1

    def flags(self, mask):
        raw = mask.to_bytes(self.nbytes, 'little')
        return np.unpackbits(np.frombuffer(raw, dtype=np.uint8), bitorder='little')[:self.size].view(bool)

    @staticmethod
    def mask(flags):
        return int.from_bytes(np.packbits(flags, bitorder='little').tobytes(), 'little')

    def image(self, lang):
        """All attainable registers at each node. Equal images share an integer ID."""
        masks = [0, self.all]
        ids = {m: i for i, m in enumerate(masks)}

        def intern(mask):
            if mask not in ids:
                ids[mask] = len(masks)
                masks.append(mask)
            return ids[mask]

        @cache
        def apply(bit, i):
            if not i:
                return 0
            flags = np.zeros(self.size, dtype=bool)
            flags[self.step[bit, self.flags(masks[i])]] = True
            return intern(self.mask(flags))

        @cache
        def combine(a, b):
            return intern(masks[apply(0, a)] | masks[apply(1, b)])

        nodes = {EMPTY: 0, END: 1}

        def visit(u):
            if u not in nodes:
                a, b = lang.nodes[u]
                nodes[u] = combine(visit(a), visit(b))
            return nodes[u]
        visit(lang.root)
        apply.cache_clear()
        combine.cache_clear()
        return {u: masks[i] for u, i in nodes.items()}

    def bad_words(self, lang, sets):
        """Follow only branches which can deliver a nonzero register to the edge."""
        def walk(u, forbidden, prefix):
            if not forbidden:
                return
            if u == END:
                yield prefix
                return
            for bit, child in enumerate(lang.nodes[u]):
                if child:
                    next_bad = sets[child] & self.mask(self.flags(forbidden)[self.step[bit]])
                    yield from walk(child, next_bad, prefix + str(bit))
        yield from walk(lang.root, sets[lang.root] & ~1, '')

    def bad_inputs(self, word):
        """All eastern wall registers that give a nonzero register at the western edge."""
        bad = np.arange(self.size) != 0
        for bit in word:
            bad = bad[self.step[int(bit)]]
        return bad


def explain(k, age, lang, previous, old_sets, inv):
    last = list(inv.bad_words(previous, old_sets))
    lo, hi = min(last), max(last)
    stem_length = next((i for i, (a, b) in enumerate(zip(lo, hi)) if a != b), len(lo))
    stem = lo[:stem_length]
    counts = Counter()
    missing_prefixes = Counter()
    algebraic = physical = 0
    first_missing = set()
    for parent in last:
        bad = inv.bad_inputs(parent)
        allowed = rejected = 0
        for bit, step in enumerate(inv.step):
            child = parent + str(bit)
            stays_bad = bad[step].any()
            match = lang.prefix_length(child)
            present = match == len(child)
            assert not (present and stays_bad)
            if present:
                allowed += 1
            else:
                missing_prefixes[child[:match + 1]] += 1
            if stays_bad:
                rejected += 1
                first_missing.add(match + 1)
        counts[allowed, rejected] += 1
        physical += allowed
        algebraic += rejected
    for word, children in sorted(missing_prefixes.items()):
        print(f'  k={k} absent prefix {word} ({children} candidate children)')
    print(f'k={k} T={age} rows={previous.count()}->{lang.count()} bad={len(last)} '
          f'stem={len(stem)}/{len(last[0])} stem_at_T={lang.prefix_length(stem)} '
          f'physical_children={physical} algebraically_bad_children={algebraic} '
          f'first_missing={sorted(first_missing)} profiles={sorted(counts.items())}', flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('layers', type=int, nargs='+')
    parser.add_argument('--start-age', type=int, default=1, help='first age to test; the previous age must fail')
    parser.add_argument('--max-age', type=int, default=200)
    args = parser.parse_args()
    if min(args.layers) < 1 or not 1 <= args.start_age <= args.max_age:
        parser.error('require positive layers and 1 <= start-age <= max-age')
    active = {k: Inverse(k) for k in sorted(set(args.layers))}
    lang = RowLanguage.depth_two()
    for age in range(1, args.max_age + 1):
        previous, lang = lang, lang.advance()
        if age < args.start_age:
            continue
        for k, inv in list(active.items()):
            if age + 2 <= k:
                continue
            sets = inv.image(lang)
            if sets[lang.root] == 1:
                old_sets = inv.image(previous)
                if old_sets[previous.root] == 1:
                    raise SystemExit(f'k={k} already passes at {age-1}; lower --start-age')
                explain(k, age, lang, previous, old_sets, inv)
                del active[k]
        if not active:
            return
    raise SystemExit(f'No threshold reached through {args.max_age} for k={sorted(active)}')


if __name__ == '__main__':
    main()
