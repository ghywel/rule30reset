"""Count finite seeds with a prescribed even trace, grouped by their full ending row."""
from collections import Counter, defaultdict
import json

from twin_past import iterate, odd_grandparents, step


def eligible_prefixes(width, age, miss):
    """A fresh bit i toggles wall tick i and leaves every previous tick unchanged."""
    rows = [0]
    for i in range(width):
        if i % 2 or i > age:
            rows += [x | (1 << i) for x in rows]
        else:
            wanted = int(i != miss)
            rows = [x | (((iterate(step, x, i) & 1) ^ wanted) << i) for x in rows]
    return rows


def endpoint(seed, age, miss):
    row = seed
    for t in range(0, age + 1, 2):
        if (row & 1) != (t != miss):
            return None
        if t < age:
            row = step(step(row))
    return row


def fibres(seeds, age, miss):
    groups = defaultdict(list)
    for seed in seeds:
        z = endpoint(seed, age, miss)
        if z is not None:
            assert z.bit_length() == age + seed.bit_length()
            groups[z].append(seed)
    return {z: sorted(group) for z, group in groups.items()}


def multiplicities(groups):
    return dict(sorted(Counter(map(len, groups.values())).items()))


def recent_counts(root, generations):
    layer = {root}
    counts = []
    for _ in range(generations):
        layer = {parent for z in layer for parent in odd_grandparents(z)}
        counts.append(len(layer))
    return counts


def census(width, age):
    miss = 2 * (age // 4)
    black, control = [fibres(eligible_prefixes(width, age, m), age, m)
                      for m in (None, miss)]
    common = black.keys() & control.keys()
    paired = Counter((len(black[z]), len(control[z])) for z in common)
    result = {
        "age": age, "width_cap": width, "control_white_at": miss,
        "black_histogram": multiplicities(black), "control_histogram": multiplicities(control),
        "matched_size_pairs": [[b, c, n] for (b, c), n in sorted(paired.items())],
        "black_endpoints": {hex(z): [hex(x) for x in seeds] for z, seeds in sorted(black.items())},
        "control_endpoints": {hex(z): [hex(x) for x in seeds] for z, seeds in sorted(control.items())},
    }
    if black:
        z = min(black, key=lambda k: (len(black[k]), k))
        result["least_fibre_example"] = {"end": hex(z), "seeds": list(map(hex, black[z]))}
    if age in (46, 48, 54):
        for name, groups in (("black", black), ("control", control)):
            split = Counter(tuple(sorted(len(odd_grandparents(p)) for p in odd_grandparents(z)))
                            for z in groups)
            result[name + "_four_tick_splits"] = [[k, v] for k, v in sorted(split.items())]
        if age == 46 and black:
            result["least_fibre_recent_counts"] = recent_counts(z, 12)
    return result


def self_check():
    for width, age in ((12, 8), (12, 18), (16, 32)):
        for miss in (None, 2 * (age // 4)):
            assert fibres(eligible_prefixes(width, age, miss), age, miss) == fibres(
                range(1, 1 << width), age, miss)


if __name__ == "__main__":
    self_check()
    print(json.dumps([census(30, t) for t in (32, 46, 48, 54, 60)], indent=1))
