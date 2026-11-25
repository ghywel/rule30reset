"""Use the physical gate cone to close the gap in a free-edge strip census."""

import argparse
import collections
import json

from claudeCloud_k84_coupled import replay_full
from claudeCloud_k84_demand import Cone, replay
from pysat.solvers import Cadical195


def bits(n, k):
    return [(n >> i) & 1 for i in range(k)]


def read_right(row, readings):
    word = 0
    for _ in range(readings):
        row = ((row << 1) | 1) ^ (row | (row >> 1))
        word = (word << 1) | (row & 1)
        row = (row << 1) ^ (row | (row >> 1))
    return word


def decode_west(word, ticks):
    """Build the successive west columns from their two eastern columns."""
    parent = sum(1 << t for t in range(0, ticks, 2))
    column = (1 << ticks) - 1
    for time in range(1, ticks, 2):
        take = ticks // 2 - 1 - time // 2
        column ^= (word >> take & 1) << time
    west = 0
    for depth in range(ticks):
        west |= (column & 1) << depth
        next_column = ((column >> 1) ^ (column | parent)) & ((1 << (ticks - depth - 1)) - 1)
        parent, column = column, next_column
    return west


def load_words(args):
    with open(args.strip, encoding="utf-8-sig") as stream:
        upper = {int(line) for line in stream}
    lower = {}
    with open(args.physical, encoding="utf-8-sig") as stream:
        for line in stream:
            word, low, high = map(int, line.split())
            row = low | (high << 64)
            if read_right(row, args.readings) != word:
                raise ValueError(f"initial right does not replay {word}")
            if word not in upper:
                raise ValueError(f"strip omitted physical word {word}")
            lower[word] = row
    return upper, lower


class Physical:
    def __init__(self, horizon):
        self.horizon = horizon
        self.cone = Cone(2 * horizon)
        self.solver = Cadical195(bootstrap_with=self.cone.clauses)
        self.readings = [self.cone.reading(i) for i in range(horizon)]

    def solve(self, word, m):
        gate = bits(word, m)[::-1]
        assumptions = [lit if colour else -lit for lit, colour in zip(self.readings, gate)]
        if not self.solver.solve(assumptions=assumptions):
            return None
        positive = {lit for lit in self.solver.get_model() if lit > 0}
        row = [int(self.cone.var[j, 0] in positive) for j in range(1, 2 * m + 1)]
        if replay(row + [0], m) != gate:
            raise ValueError(f"SAT right does not replay {word} at {m}")
        return sum(bit << pos for pos, bit in enumerate(row))


def prefixes(upper, lower, shift):
    possible = {word >> shift for word in upper}
    known = {word >> shift: row for word, row in lower.items()}
    return possible, known


def counts(args, upper, lower):
    physical = Physical(args.stop)
    rejected = set()
    for m in range(args.start, args.stop + 1):
        possible, known = prefixes(upper, lower, args.readings - m)
        inherited = {word for word in possible if word >> 1 in rejected}
        if inherited & known.keys():
            raise ValueError("a physical witness extends a rejected prefix")
        missing = possible - known.keys() - inherited
        print(json.dumps({"m": m, "upper": len(possible), "physical_samples": len(known),
                          "queries": len(missing), "inherited": len(inherited)}), flush=True)
        false_words = []
        new_witnesses = {}
        for word in sorted(missing):
            row = physical.solve(word, m)
            if row is None:
                false_words.append(word)
            else:
                new_witnesses[word] = format(row, "x")
        rejected = inherited.union(false_words)
        print(json.dumps({"m": m, "exact": len(possible) - len(rejected),
                          "new_refusals": false_words, "new_witnesses": new_witnesses}), flush=True)


def support(args, upper, lower):
    physical = Physical(args.stop // 2)
    for ticks in range(args.start, args.stop + 1):
        m = ticks // 2
        possible, known = prefixes(upper, lower, args.readings - m)
        groups = collections.defaultdict(list)
        for word in possible:
            west = decode_west(word, ticks)
            groups[west.bit_length()].append((word, west))
        query_count = 0
        for depth in sorted(groups):
            found = False
            candidates = sorted(groups[depth], key=lambda pair: (pair[0] not in known, pair[0]))
            for word, west in candidates:
                right = known.get(word)
                if right is None:
                    query_count += 1
                    right = physical.solve(word, m)
                if right is None:
                    continue
                centre = replay_full(bits(west, depth), bits(right, 2 * m), ticks)
                if centre != [1 - t % 2 for t in range(ticks + 1)]:
                    raise ValueError(f"decoded west does not replay {word} at {ticks}")
                print(json.dumps({"T": ticks, "min_B": depth, "strip_min": min(groups),
                                  "words": len(possible), "queries": query_count,
                                  "gate": format(word, f"0{m}b"), "west_hex": format(west, "x"),
                                  "right_hex": format(right & ((1 << (2 * m)) - 1), "x"),
                                  "literal_replay": True}), flush=True)
                found = True
                break
            if found:
                break
        else:
            raise ValueError("no gate word at this time")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("counts", "support", "range"))
    parser.add_argument("strip")
    parser.add_argument("physical")
    parser.add_argument("readings", type=int)
    parser.add_argument("start", type=int)
    parser.add_argument("stop", type=int)
    args = parser.parse_args()
    upper, lower = load_words(args)
    if args.mode == "support":
        support(args, upper, lower)
    elif args.mode == "counts":
        counts(args, upper, lower)
    else:
        for m in range(args.start, args.stop + 1):
            possible, known = prefixes(upper, lower, args.readings - m)
            print(m, len(known), len(possible), len(possible - known.keys()), sep="\t")


if __name__ == "__main__":
    main()
