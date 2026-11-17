#!/usr/bin/env python3
"""claudeM5's carrying read of R11 (research/r2/black-even.md): an independent check of the width partition, the
odd-multiplicity step, the sharpness of the width bound, and the tick-46 singleton.

A guarded history of a row E at an even tick T goes back two ticks at a time: the wall-adjacent cell is free at the
odd tick and black at the even one, so E has 2^j guarded histories over its last 2j ticks. Parents are built by
claudeM5_r8_replay.parents (the head is free; a finite parent is checked by applying F).

1. For j = 1 .. 9: rows of width <= 2j + 1 black at the wall at every even tick 0 .. 2j; their split into width <=
   2j and width exactly 2j + 1 (kit: first_check_count, ones); the parity of the first part (first_check_parity);
   their grouping by the full row at tick 2j, the split of each group between the two black-headed two-tick parents
   of the endpoint, and whether an odd group exists.
2. Sharpness: for j = 1 .. 4, the least seed width at which some endpoint has all 2^j guarded histories finite.
3. The tick-46 singleton of R11, replayed by inverse search.
Usage: claudeM5_r11_check.py OUTFILE
"""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from claudeM5_r8_replay import F, parents


def passes(y, T):
    row = y
    for t in range(T + 1):
        if t % 2 == 0 and not row & 1:
            return False
        row = F(row)
    return True


def guarded_back(row):
    """The two-tick guarded parents of a row, one per choice of the odd-tick head: list of (h, row or None)."""
    out = []
    for h, p in parents(row):
        q = None
        if p is not None:
            for hh, pp in parents(p):
                if hh == 1:
                    q = pp
        out.append((h, q))
    return out


def full_tree(row, j):
    level = [row]
    for _ in range(j):
        nxt = []
        for r in level:
            for _, q in guarded_back(r):
                if q is None:
                    return False
                nxt.append(q)
        level = nxt
    return True


def part1(jmax):
    out = {}
    for j in range(1, jmax + 1):
        T = 2 * j
        le, eq = [], []
        for y in range(1, 1 << (2 * j + 1)):
            if passes(y, T):
                (le if y.bit_length() <= 2 * j else eq).append(y)
        groups = {}
        for y in le:
            E = y
            for _ in range(T):
                E = F(E)
            groups.setdefault(E, []).append(y)
        splits, odd = [], 0
        for E, ys in groups.items():
            heads = {}
            for y in ys:
                r = y
                for _ in range(T - 1):
                    r = F(r)
                heads.setdefault(r & 1, 0)
                heads[r & 1] += 1          # the head at tick T - 1 picks the immediate branch
            m1, m2 = heads.get(0, 0), heads.get(1, 0)
            splits.append((m1, m2))
            odd += (len(ys) % 2 == 1)
        out[j] = {'passing_width_le_2j+1': len(le) + len(eq), 'width_le_2j': len(le), 'width_eq_2j+1': len(eq),
                  'first_part_parity_equals_j_parity': len(le) % 2 == j % 2, 'endpoints': len(groups),
                  'endpoints_with_odd_multiplicity': odd,
                  'any_endpoint_with_equal_split': any(a == b for a, b in splits),
                  'max_multiplicity': max(len(v) for v in groups.values())}
    return out


def sharpness(jmax, wmax):
    out = {}
    for j in range(1, jmax + 1):
        T = 2 * j
        found = None
        for w in range(1, wmax + 1):
            for y in range(1 << (w - 1), 1 << w):
                if not passes(y, T):
                    continue
                E = y
                for _ in range(T):
                    E = F(E)
                if full_tree(E, j):
                    found = (w, y)
                    break
            if found:
                break
        out[j] = {'least_seed_width_with_full_guarded_tree': None if found is None else found[0],
                  'bound_2j+2': 2 * j + 2, 'example_seed': None if found is None else found[1]}
    return out


def singleton():
    y = 0x19da5dcb
    E = y
    for _ in range(46):
        E = F(E)
    res = {'seed_passes_through_46': passes(y, 46), 'end_hex': hex(E), 'end_width': E.bit_length()}
    branches = {}
    for h, q in guarded_back(E):
        counts, level = {}, ([q] if q is not None else [])
        for T in range(44, -1, -2):
            counts[T] = len(level)
            nxt = []
            if T > 0:
                for r in level:
                    nxt += [qq for _, qq in guarded_back(r) if qq is not None]
            level = nxt
        branches[h] = {T: counts[T] for T in (44, 42, 40, 38, 36, 28, 0)}
    res['guarded_ancestors_by_branch'] = branches
    return res


def main():
    res = {'part1': part1(9), 'sharpness': sharpness(4, 14), 'singleton': singleton()}
    with open(sys.argv[1], 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
