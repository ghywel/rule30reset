"""Identify exact first-entry witnesses for the two K92.3 record rows.

Run with the kit root, R65's W24.scc and an output JSON path. A site number
is one-based from the imposed column. Physical tick zero has a black wall.
"""
import argparse
import hashlib
import itertools
import json
import struct
from pathlib import Path

import numpy as np

from replay import step, white_rows
from tables import literal


SEEDS = (7693847, 11888151)
SAMPLE = 2716
TICK = 2 * SAMPLE + 1
WIDTH = 16
MASK = 2**WIDTH - 1


def crossing(row, trap):
    return row & MASK not in trap and step(step(row, 0), 1) & MASK in trap


def sites(mask):
    return [i + 1 for i in range(mask.bit_length()) if mask >> i & 1]


def records(path):
    raw = path.read_bytes()
    assert raw[:12] == b"K50SCC1\n" + struct.pack("<I", 24)
    by_code = {}
    offset = 12
    sizes = {}
    while offset < len(raw):
        least, count = struct.unpack_from("<II", raw, offset)
        members = struct.unpack_from(f"<{count}I", raw, offset + 8)
        assert min(members) == least and least not in sizes
        sizes[least] = count
        by_code.update(dict.fromkeys(members, least))
        offset += 8 + 4 * count
    assert len(by_code) == sum(sizes.values())
    assert sizes[519] == 15826 and sizes[1799] == 11069
    return by_code, hashlib.sha256(raw).hexdigest()


def physical_rows(seed):
    rows = [seed]
    for tick in range(TICK):
        rows.append(step(rows[-1], 1 - tick % 2))
    return rows


def truth(trap):
    vals = np.arange(1 << 18, dtype=np.uint32)
    table = np.zeros(MASK + 1, dtype=bool)
    table[list(trap)] = True
    return ~table[vals & MASK] & table[step(step(vals, 0), 1) & MASK]


def certificates(word, good):
    size = len(good)
    full = size - 1
    diffs = np.arange(size) ^ word
    bad_subset = ~good[diffs]
    for i in range(full.bit_length()):
        block = 1 << i
        paired = bad_subset.reshape(-1, 2 * block)
        paired[:, block:] |= paired[:, :block]
    sufficient = np.flatnonzero(~bad_subset).tolist()  # free sites
    largest = max(m.bit_count() for m in sufficient)
    masks = sorted(full ^ m for m in sufficient if m.bit_count() == largest)
    return {
        "minimum_masks": masks,
        "single_flip_breaks": sites(sum(1 << i for i in range(18)
                                        if not good[word ^ (1 << i)])),
        "sufficient_mask_count": len(sufficient),
    }


def last_component(rows, by_code, trap):
    mask = 2**24 - 1
    white = rows[1::2]
    labels = [by_code.get(x & mask) for x in white]
    runs = []
    start = 0
    for label, group in itertools.groupby(labels):
        end = start + sum(1 for _ in group)
        if label is not None:
            runs.append([start, end - 1, label])
        start = end
    if not runs:
        return {"runs": []}
    _, last, label = runs[-1]
    source = white[last] & mask
    choices = []
    for east in range(4):
        dest = step(step(source | (east << 24), 0), 1) & mask
        choices.append([east, dest, by_code.get(dest), dest & MASK in trap])
    return {"runs": runs, "source": source, "exit_east": (white[last] >> 24) & 3,
            "choices": choices, "last_label": label}


def first_hit(seed, trap):
    for s, row in enumerate(itertools.islice(white_rows(seed), SAMPLE + 1)):
        if row & MASK in trap:
            return s
    return None


def ternary_snapshot(seed, width):
    """Known value masks. A zero in both masks allows either colour independently."""
    bound = (1 << width) - 1
    black, white = seed & bound, ~seed & bound
    for t in range(TICK - 2):
        wall = 1 - t % 2
        left1, left0 = (black << 1) | wall, (white << 1) | (1 - wall)
        or1, or0 = black | (black >> 1), white & (white >> 1)
        black, white = (left1 & or0) | (left0 & or1), (left0 & or0) | (left1 & or1)
    return black & ((1 << 18) - 1), white & ((1 << 18) - 1)


def sufficient_prefix(seed, good):
    vals = np.arange(len(good), dtype=np.int32)
    def certifies(k):
        black, white = ternary_snapshot(seed, k)
        return bool(good[(vals & (black | white)) == black].all())
    lo, hi = 0, WIDTH + TICK
    assert not certifies(lo) and certifies(hi)
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if certifies(mid):
            hi = mid
        else:
            lo = mid
    return hi


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", type=Path)
    parser.add_argument("scc", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    gate = args.kit / "lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean"
    trap = set(literal(gate, "trapCodes"))
    assert len(trap) == 829
    by_code, digest = records(args.scc)
    good = truth(trap)
    rows = [physical_rows(seed) for seed in SEEDS]
    low = 2**18 - 1
    out = {"scc_sha256": digest, "number_crossing_words": int(good.sum()), "seeds": {}}
    for seed, path in zip(SEEDS, rows):
        assert first_hit(seed, trap) == SAMPLE
        word = path[-3] & low
        assert crossing(word, trap)
        scc = last_component(path, by_code, trap)
        per_seed = {
            "predecessor18": word, "middle17": path[-2] & (2**17-1),
            "entry16": path[-1] & MASK, "certificates": certificates(word, good),
            "component": scc, "ternary_prefix_bound": sufficient_prefix(seed, good),
        }
        hits = [first_hit(seed ^ (1 << i), trap) for i in range(WIDTH + TICK)]
        per_seed["single_initial_flip_first_hit"] = hits
        changed = [i + 1 for i, h in enumerate(hits) if h != SAMPLE]
        per_seed["last_changed_site"] = max(changed, default=None)
        per_seed["earlier_same_later"] = [sum(h is not None and h < SAMPLE for h in hits),
                                          hits.count(SAMPLE), hits.count(None)]
        out["seeds"][str(seed)] = per_seed
        print(seed, word, per_seed["entry16"], per_seed["certificates"],
              scc["runs"][-4:], per_seed["ternary_prefix_bound"],
              per_seed["last_changed_site"], per_seed["earlier_same_later"], flush=True)
    out["common22_completions"] = [
        [seed, first_hit(seed, trap)]
        for top in range(4) for seed in [(SEEDS[0] & (2**22 - 1)) | (top << 22)]
    ]
    diff = [a ^ b for a, b in zip(*rows)]
    out["first_identical_tick"] = next((i for i, d in enumerate(diff) if not d), None)
    out["first_different_site_at_crossing"] = [(d & -d).bit_length() if d else None
                                                for d in diff[-3:]]
    args.out.write_text(json.dumps(out, separators=(",", ":")) + "\n", encoding="ascii")


if __name__ == "__main__":
    main()
