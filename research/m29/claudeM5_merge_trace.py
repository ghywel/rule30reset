#!/usr/bin/env python3
"""Pull M29 (M32): where in a real row do its k-tick wall histories merge?

A k-tick wall history of a row r is a choice of head on each of k inverse layers. Reading r from the wall outwards,
layer d keeps the pair (P_d(i - 1), P_d(i)) of its parent's cells, with P_d(-1) = 0 (the wall) and P_d(0) = h_d:
  P_1(i + 1) = r(i) xor (P_1(i) or P_1(i - 1)),   P_d(i + 1) = P_(d-1)(i) xor (P_d(i) or P_d(i - 1)).
Two histories whose states agree at a cell agree from there on. For a >= k the row's own orbit is one of the 2^k
histories and closes, so all histories close exactly when all have merged by the end: closure is synchronisation.

For every seed below 2^B and every age in [A0, A1], with E the row's width: m_d, the first cell at which the 2^k
histories agree on layers 1 .. d (None if never, within the row and 2k cells beyond). Reported by k and d: how far
m_d lies from the wall and from the edge (E - m_d), and the gap m_d - m_(d-1), over rows whose histories all merge;
the number that do not; and, by age, the largest m_k - E over the seeds ('unmerged' if some row fails).
Usage: claudeM5_merge_trace.py OUTFILE [--B 10] [--A0 8] [--A1 100] [--K 4]
"""
import argparse, json, os, sys
from statistics import median

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r2'))
from claudeM5_r8_replay import F  # noqa: E402


def merges(row, k):
    E = row.bit_length()
    states = set()
    for h in range(1 << k):
        states.add(tuple((0, (h >> d) & 1) for d in range(k)))   # per layer (P(i-1), P(i)) at i = 0
    m = [None] * k
    for i in range(E + 2 * k):
        for d in range(k):
            if m[d] is None and len({s[:d + 1] for s in states}) == 1:
                m[d] = i
        if m[k - 1] is not None:
            break
        x = (row >> i) & 1
        nxt = set()
        for s in states:
            new = []
            inp = x
            for (pm, pc) in s:
                nb = inp ^ (pc | pm)
                new.append((pc, nb))
                inp = pc                                     # the next layer reads this layer's current cell
            nxt.add(tuple(new))
        states = nxt
    return E, m


def summ(v):
    v = [x for x in v if x is not None]
    if not v:
        return None
    v.sort()
    return {'n': len(v), 'min': v[0], 'median': median(v), 'max': v[-1]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--B', type=int, default=10)
    ap.add_argument('--A0', type=int, default=8)
    ap.add_argument('--A1', type=int, default=100)
    ap.add_argument('--K', type=int, default=4)
    a = ap.parse_args()
    res = {'B': a.B, 'ages': [a.A0, a.A1]}
    for k in range(1, a.K + 1):
        from_wall = {d: [] for d in range(1, k + 1)}
        from_edge = {d: [] for d in range(1, k + 1)}
        gap = {d: [] for d in range(2, k + 1)}
        unmerged, total = 0, 0
        worst = {}                                           # age -> largest m_k - E over the rows of that age
        for y in range(1, 1 << a.B):
            r = y
            for _ in range(a.A0):
                r = F(r)
            for age in range(a.A0, a.A1 + 1):
                E, m = merges(r, k)
                total += 1
                if m[k - 1] is None:
                    unmerged += 1
                    worst[age] = 'unmerged'
                else:
                    if worst.get(age) != 'unmerged':
                        worst[age] = max(worst.get(age, -10 ** 9), m[k - 1] - E)
                    for d in range(1, k + 1):
                        from_wall[d].append(m[d - 1])
                        from_edge[d].append(E - m[d - 1])
                    for d in range(2, k + 1):
                        gap[d].append(m[d - 1] - m[d - 2])
                r = F(r)
        res['k%d' % k] = {'rows': total, 'not_merged': unmerged,
                          'merge_cell_from_wall': {d: summ(v) for d, v in from_wall.items()},
                          'merge_cell_from_edge': {d: summ(v) for d, v in from_edge.items()},
                          'gap_to_previous_layer': {d: summ(v) for d, v in gap.items()},
                          'worst_merge_minus_width_by_age': worst}
        print(json.dumps({'k': k, **res['k%d' % k]}), flush=True)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)


if __name__ == '__main__':
    main()
