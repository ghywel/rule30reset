"""Independent two-update graph replay and finite sharpness witness. Run with rule30-python."""

import argparse
import json
import re
from pathlib import Path

import numpy as np
from pysat.solvers import Solver


def closed_set(source):
    body = re.search(r"def closedSet : List Nat := \[([^\]]+)\]", source.read_text(encoding="utf8"))[1]
    words = set(map(int, re.findall(r"\d+", body)))
    assert len(words) == 777
    return words


def lookup(x):
    return sum(
        ((30 >> (4 * ((x >> i) & 1) + 2 * ((x >> (i + 1)) & 1) + ((x >> (i + 2)) & 1))) & 1) << i
        for i in range(8)
    )


LUT = np.array(list(map(lookup, range(1024))), dtype=np.uint32)


def tick(x, wall):
    padded = (x << 1) | wall
    return LUT[padded & 1023] | (LUT[(padded >> 8) & 1023] << 8) | (LUT[(padded >> 16) & 1023] << 16)


def graph(width, closed):
    rows = np.arange(1 << width, dtype=np.uint32)
    edges = [tick(tick(rows | (e << width), 0), 1) & ((1 << width) - 1) for e in range(4)]
    outside = ~np.isin(rows & 4095, list(closed))
    alive = outside.copy()
    layers = []
    while alive.any():
        layers.append(int(alive.sum()))
        prev = outside & np.logical_or.reduce([alive[y] for y in edges])
        if np.array_equal(alive, prev):
            at = int(np.flatnonzero(alive)[0])
            path, seen = [], {}
            while at not in seen:
                seen[at] = len(path)
                path.append(at)
                at = next(int(e[at]) for e in edges if alive[e[at]])
            return {"width": width, "cycle": path[seen[at] :]}, None
        alive = prev
    # Retain exactly the vertices at each time on a maximal path.
    viable = [outside]
    for _ in range(1, len(layers)):
        viable.append(outside & np.logical_or.reduce([viable[-1][y] for y in edges]))
    paths = [np.flatnonzero(viable[-1])]
    for remaining in reversed(viable[:-1]):
        reached = np.unique(np.concatenate([e[paths[-1]] for e in edges]))
        paths.append(reached[remaining[reached]])
    # Distinct gate words, preserving correlation along edges.
    words = {int(v): {int(v) & 1} for v in paths[0]}
    for keep in paths[1:]:
        nxt = {int(v): set() for v in keep}
        for v, prefixes in words.items():
            for y in {int(e[v]) for e in edges} & nxt.keys():
                nxt[y].update((p << 1) | (y & 1) for p in prefixes)
        words = nxt
    gates = sorted(format(w, f"0{len(paths)}b") for w in set.union(*words.values()))
    return {
        "width": width,
        "outside_counts": layers,
        "maximal_layer_sizes": list(map(len, paths)),
        "gate_words": gates,
        "final_windows12": sorted({int(v) & 4095 for v in paths[-1]}),
    }, paths


def physical_model(paths, width, closed, wanted, last):
    # A zero-extended black start. Every tested bit has its full eastern light cone.
    ticks = 2 * len(paths) - 1
    size = width + ticks
    row = lambda t, j: 1 + t * (size + 1) + j

    def live(solver, t, patterns, length):
        # The trie excludes exactly the missing sibling prefixes, low bit first.
        frontier = {0}
        for j in range(length):
            actual = {int(x) & ((1 << (j + 1)) - 1) for x in patterns}
            for v in {x | (b << j) for x in frontier for b in (0, 1)} - actual:
                solver.add_clause([row(t, i) * (-1 if (v >> i) & 1 else 1) for i in range(j + 1)])
            frontier = actual

    with Solver(name="cadical195") as sat:
        for t in range(ticks):
            for j in range(size - t - 1):
                for pat in range(8):
                    l, c, r = (pat >> 2) & 1, (pat >> 1) & 1, pat & 1
                    if not j and l != int(t % 2 == 0):
                        continue
                    bits = [(row(t, j), c), (row(t, j + 1), r)]
                    if j:
                        bits.append((row(t, j - 1), l))
                    sat.add_clause(
                        [(-v if b else v) for v, b in bits] + [row(t + 1, j) * (1 if (30 >> pat) & 1 else -1)]
                    )
        for k, patterns in enumerate(paths):
            live(sat, 2 * k + 1, patterns, width)
            sat.add_clause([row(2 * k + 1, 0) * (1 if wanted[k] == "1" else -1)])
        live(sat, ticks, [last], 12)
        if not sat.solve():
            return None
        # Minimize the black initial integer lexicographically, highest bit first.
        for j in reversed(range(size)):
            bit = row(0, j)
            sat.add_clause([-bit if sat.solve(assumptions=[-bit]) else bit])
        assert sat.solve()
        model = set(sat.get_model())
    x = sum(1 << i for i in range(size) if row(0, i) in model)

    def literal_step(y, wall):
        return ((y << 1) | wall) ^ (y | (y >> 1))

    y = literal_step(x, 1)
    windows = []
    for _ in range(len(paths) + 1):
        windows.append(y & 4095)
        y = literal_step(literal_step(y, 0), 1)
    assert all(w not in closed for w in windows[:-1]) and windows[-1] in closed
    gate = "".join(str(w & 1) for w in windows[:-1])
    assert gate == wanted and windows[-2] == last
    return {
        "black_seed": str(x),
        "occupied_sites": [i + 1 for i in range(x.bit_length()) if (x >> i) & 1],
        "windows12": windows,
        "gate": gate,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    K = closed_set(args.source)
    small, _ = graph(20, K)
    large, paths = graph(21, K)
    assert small["cycle"] and paths is not None
    print("width 20 cycle", small["cycle"], "width 21 layers", large, flush=True)
    examples = {
        f"{word}/{last}": physical_model(paths, 21, K, word, last)
        for word in large["gate_words"]
        for last in large["final_windows12"]
    }
    assert all(example is not None for example in examples.values()), "unrealized gate word or endpoint"
    result = {"width20": small, "width21": large, "physical_by_gate_and_endpoint": examples}
    args.out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf8")
    print("black starts", {k: v and v["black_seed"] for k, v in examples.items()}, flush=True)
