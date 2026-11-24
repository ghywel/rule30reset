"""Build the prefix tree for 35 two-update steps. The Lean kernel checks every transition."""

import argparse
from collections import defaultdict
from pathlib import Path
from textwrap import wrap

from replay import closed_set


def window_images(x, width):
    mask = (1 << width) - 1

    def step(y, d):
        return ((y << 1) | d) ^ (y | (y >> 1))

    return {step(step(x | (e << width), 0), 1) & mask for e in range(4)}


def table(closed, n):
    # Bit 0 identifies the target. Bit t+1 certifies that a row can carry age t.
    marked = defaultdict(int)
    split = {(width, x % (1 << width)) for width in range(1, 12) for x in closed}
    layers = [{0, 1} for _ in range(n + 1)]
    for width in range(1, 22):
        if width > 1:
            for layer in layers:
                layer.update([x | (1 << (width - 1)) for x in layer])
        if width == 12:
            for x in closed:
                marked[12, x] = (1 << (n + 2)) - 1
            for layer in layers:
                layer.difference_update(closed)
        images = {x: window_images(x, width) for x in set.union(*layers)}
        for t in range(n - 1, -1, -1):
            dead = {x for x in layers[t] if images[x].isdisjoint(layers[t + 1])}
            for x in dead:
                marked[width, x] |= 1 << (t + 1)
            layers[t].difference_update(dead)
        for t in range(1, n + 1):
            reachable = {y for x in layers[t - 1] for y in images[x]}
            layers[t].intersection_update(reachable)
        surviving = set.union(*layers)
        if not surviving:
            break
        split.update((width, x) for x in surviving)
    assert not surviving
    leaf_index, branch_index = {}, {}

    def grow(width, x, mask):
        mask |= marked[width, x]
        if (width, x) not in split:
            return ~leaf_index.setdefault(mask, len(leaf_index))
        a, b = (grow(width + 1, x | (v << width), mask) for v in (0, 1))
        if a == b and a < 0:
            return a
        return branch_index.setdefault((a, b), len(branch_index))

    left, right = grow(1, 0, 0), grow(1, 1, 0)
    root = branch_index.setdefault((left, right), len(branch_index))
    assert root == len(branch_index) - 1

    def index(i):
        return ~i if i < 0 else len(leaf_index) + i

    return list(leaf_index), [index(a) | (index(b) << 16) for a, b in branch_index], width


def packed_line(values):
    return "\n".join(
        "  " + line
        for line in wrap(
            ", ".join(hex(x) for x in values), 110, break_long_words=False, break_on_hyphens=False
        )
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--form", choices=["extension", "portal", "kit"], default="extension")
    args = parser.parse_args()
    leaves, pairs, width = table(closed_set(args.source), 35)
    print("width", width, "leaves", len(leaves), "branches", len(pairs), flush=True)
    chunks = [sum(p << (32 * i) for i, p in enumerate(pairs[k : k + 32])) for k in range(0, len(pairs), 32)]
    template = Path(__file__).with_name("uniform.template").read_text(encoding="utf8")
    proof = (
        template.replace("LEAF_DATA", packed_line(leaves))
        .replace("BRANCH_DATA", packed_line(chunks))
        .replace("BRANCH_COUNT", str(len(pairs)))
    )
    if args.form == "portal":
        earlier = args.source.read_text(encoding="utf8")
        assert earlier.count("namespace Rule30Submission\n") == 1
        library = earlier.replace("namespace Rule30Submission\n", "namespace Rule30Submission.S17\n").replace(
            "end Rule30Submission\n", "end Rule30Submission.S17\n"
        )
        addition = (
            proof[proof.index("namespace Rule30UniformEntry") :]
            .replace("Rule30UniformEntry", "Rule30Submission")
            .replace("Rule30Submission Rule30Ether", "Rule30Submission.S17 Rule30Ether")
        )
        proof = library + "\n" + addition
    elif args.form == "kit":
        proof = proof.replace(
            "public import Rule30Submission",
            "public import Ruliology.CellularAutomata.Rule30AlternatingArrivals",
        )
        proof = proof.replace(
            "namespace Rule30UniformEntry", "namespace Ruliology.CellularAutomata.Rule30UniformEntry"
        )
        proof = proof.replace("end Rule30UniformEntry", "end Ruliology.CellularAutomata.Rule30UniformEntry")
        proof = proof.replace(
            "Ruliology.CellularAutomata Rule30Submission Rule30Ether",
            "Rule30AlternatingArrivals Rule30AlternatingArrivalsTables Rule30Ether",
        )
        proof = proof.replace(
            "open Rule30DrivenPrefix (step)",
            "open Rule30TrappedRunMasks (Tree)\nopen Rule30DrivenPrefix (step)",
        )
    args.output.write_bytes(proof.encode())
