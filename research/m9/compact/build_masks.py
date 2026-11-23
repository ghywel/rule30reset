"""Rebuild the two literal arrays in Rule30Submission.lean from the sparse prefix proof.

Run this file from any directory with NumPy installed. The Lean submission contains
the complete table and uses the stock kernel to check its meaning independently.
"""

from pathlib import Path
import lzma
import re
import sys

import numpy as np

HERE = Path(__file__).resolve().parent
RESEARCH = HERE.parent
sys.path.insert(0, str(RESEARCH))
import gptIntel_refutation_core as core


def children(key):
    """Keys have a sentinel above a spatial prefix. The next bit goes below the sentinel."""
    high = 1 << (key.bit_length() - 1)
    return key + high, key + 2 * high


def fine_graph(trap, records):
    forks = set()
    for _, width, _, _, code in records:
        for depth in range(16, width):
            forks.add((1 << depth) + code % (1 << depth))
    leaf_ids = {}

    def index(key):
        if key in forks:
            for child in children(key):
                index(child)
        else:
            leaf_ids[key] = len(leaf_ids)

    for code in trap:
        index(65536 + code)
    edges = [set() for _ in leaf_ids]

    def visit(width, code, source, target):
        if source is None:
            source = leaf_ids.get((1 << width) + code)
        if target is None and width >= 18:
            modulus = 1 << (width - 2)
            out = core.step(core.step(code, 0), 1)
            key = modulus + out % modulus
            target = leaf_ids.get(key)
            if target is None and key not in forks:
                return
        if source is not None and target is not None:
            edges[source].add(target)
            return
        visit(width + 1, code, source, target)
        visit(width + 1, code + (1 << width), source, target)

    for code in trap:
        visit(16, code, None, None)
    src = np.array([i for i, dest in enumerate(edges) for _ in dest], dtype=np.int32)
    dst = np.array([j for dest in edges for j in dest], dtype=np.int32)
    return list(leaf_ids), forks, src, dst


def reach(initial, source, target, size):
    states = [initial[0].copy()]
    for allowed in initial[1:]:
        image = np.bincount(target, weights=states[-1][source], minlength=size) > 0
        states.append(image & allowed)
    return states


def colour_tests(keys, delay):
    parity = np.array(keys, dtype=np.int64) % 2
    return [np.ones(len(keys), dtype=bool) if bit is None else parity == bit
            for bit in core.samples(delay)]


def useful_partition(fine_keys, all_forks, source, target):
    """Split only bins on a complete word path in the current coarse graph."""
    depth = np.array([k.bit_length() - 1 for k in fine_keys])
    code = np.array([k - (1 << (k.bit_length() - 1)) for k in fine_keys], dtype=np.int64)
    forks = set()
    while True:
        bins = 65536 + code % 65536
        for w in range(16, int(depth.max())):
            active = [k for k in forks if k.bit_length() == w + 1]
            if not active:
                break
            take = (depth > w) & np.isin(bins, active)
            size = 1 << (w + 1)
            bins[take] = size + code[take] % size
        keys, idx = np.unique(bins, return_inverse=True)
        keys = list(map(int, keys))
        size = len(keys)
        pairs = np.unique(idx[source].astype(np.int64) * size + idx[target])
        src, dst = (pairs // size).astype(np.int32), (pairs % size).astype(np.int32)
        allowed = colour_tests(keys, 2)
        before = reach(allowed, src, dst, size)
        after = reach(allowed[::-1], dst, src, size)[::-1]
        if not before[-1].any():
            if not reach(colour_tests(keys, 1), src, dst, size)[-1].any():
                raise ValueError("lost the delay-one positive control")
            return keys, forks, src, dst, allowed, after
        useful = np.logical_or.reduce([left & right for left, right in zip(before, after)])
        split = {k for k, active in zip(keys, useful) if active and k in all_forks}
        if not split:
            raise ValueError("a complete delay-two path survived the fine partition")
        forks.update(split)


def interpolate(keys, forks, src, dst, allowed, after, trap):
    """At each time choose a prefix set containing all required states and no completing state."""
    index = {key: i for i, key in enumerate(keys)}
    fine_first = sorted(forks, key=int.bit_length, reverse=True)
    masks = [1] * len(keys)
    current = allowed[0].copy()
    for t in range(1, len(allowed)):
        required = allowed[t] & (np.bincount(dst, weights=current[src], minlength=len(keys)) > 0)
        if (required & after[t]).any():
            raise ValueError("the reachability and completion sets intersect")
        if t == len(allowed) - 1:
            if required.any():
                raise ValueError("the final sample remains reachable")
            break
        label = {key: int(required[i]) + 2 * int(after[t][i]) for i, key in enumerate(keys)}
        for key in fine_first:
            a, b = children(key)
            label[key] = label[a] | label[b]
        current = np.zeros(len(keys), dtype=bool)

        def assign(key, state):
            if state == 3:
                state = label[key]
            if key in index:
                current[index[key]] = state == 1
            else:
                for child in children(key):
                    assign(child, state)

        for code in trap:
            assign(65536 + code, 3)
        current &= allowed[t]
        for i in np.flatnonzero(current):
            masks[i] |= 1 << t
    return dict(zip(keys, masks))


def encode_tree(values, forks):
    """Intern equal subtrees. Each branch refers only to nodes already constructed."""
    nodes, cache = [], {}

    def intern(node):
        if node not in cache:
            cache[node] = len(nodes)
            nodes.append(node)
        return cache[node]

    empty = intern((0,))

    def build(key, depth):
        if key in values:
            return intern((values[key],))
        if depth >= 16 and key not in forks:
            return empty
        a, b = (build(child, depth + 1) for child in children(key))
        if a == b and len(nodes[a]) == 1:
            return a
        return intern((a, b))

    root = build(1, 0)
    leaves = [i for i, node in enumerate(nodes) if len(node) == 1]
    branches = [i for i, node in enumerate(nodes) if len(node) == 2]
    order = {old: new for new, old in enumerate(leaves + branches)}
    if order[root] != len(nodes) - 1 or len(nodes) >= 65536:
        raise ValueError("node indices do not fit the Lean representation")
    words = [order[nodes[i][0]] + (order[nodes[i][1]] << 16) for i in branches]
    chunks = [sum(w << (32 * j) for j, w in enumerate(words[i:i + 32])) for i in range(0, len(words), 32)]
    return [nodes[i][0] for i in leaves], chunks, len(branches)


def main():
    kit = RESEARCH.parents[1] / "Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean"
    trap = sorted(core.read_trap(kit))
    raw = lzma.decompress((RESEARCH / "data/trapped-runs-core.xz").read_bytes())
    if not raw.startswith(core.HEADER):
        raise ValueError("invalid sparse proof header")
    keys, forks, src, dst = fine_graph(trap, core.RECORD.iter_unpack(raw[len(core.HEADER):]))
    print(f"Fine graph: {len(keys)} leaves and {len(src)} edges")
    keys, forks, src, dst, allowed, after = useful_partition(keys, forks, src, dst)
    print(f"Selected graph: {len(keys)} leaves and {len(src)} edges")
    values = interpolate(keys, forks, src, dst, allowed, after, trap)
    leaves, chunks, count = encode_tree(values, forks)
    source = (HERE / "Rule30Submission.lean").read_text(encoding="utf-8")
    for name, expected in [("leafMasks", leaves), ("branchChunks", chunks)]:
        match = re.search(rf"meta def {name} : Array Nat := #\[(.*?)\]", source, re.S)
        if not match or [int(x, 16) for x in match[1].split(",")] != expected:
            raise ValueError(f"{name} differs from the embedded table")
    if f"meta def branchCount : Nat := {count}\n" not in source:
        raise ValueError("branchCount differs")
    print(f"Verified {len(leaves)} leaf masks and {count} branches against the single-file proof")


if __name__ == "__main__":
    main()
