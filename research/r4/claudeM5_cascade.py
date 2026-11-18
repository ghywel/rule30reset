#!/usr/bin/env python3
"""R4, claudeM5's block (ledger M27): does a deep source forbid long white runs in the rows just before it?

Background (R19). A source row v with multiplicity m(v) is black on [-m, m - 2]; the white triangle of an earlier
source u has radius about m(u) - i at tick u + i, around cell -1. R19 proves v >= u + m(u) + 1.

Mechanism tested here. Left permutivity fixes the row before a black run from its two right-hand cells: the
recursion x(p - 1) = y(p) xor (x(p) or x(p + 1)) turns a black run into a period-3 stripe one tick back, and so on
backwards. If such backward histories never hold a long white run, a white triangle cannot overlap them, and
successive deep sources would satisfy the stronger spacing v - u >= m(u) + m(v) - C.

A. The seed, through tick T (exact). Every source row's m(u), streamed. For successive sources u < v with m >= 2,
   the slack v - u - m(u) - m(v). For each source v with m(v) >= 3, the longest white run in row v - j inside the
   shifted block [-m - j, m - 2 - j], for j = 1 .. m - 1.
B. The backward ring cascade (exact). On a ring of N cells, all preimages of the all-black ring, then all their
   preimages, to depth D: at each depth the number of rings and the longest cyclic white run over all of them.
Usage: claudeM5_cascade.py OUTFILE [--T 65536] [--N 96] [--D 18] [--cap 200000]
"""
import argparse, json
from collections import deque


def seed_part(T):
    OFF = T + 2
    x = 1 << OFF
    W = 160                      # window half-width read around cell -1 (multiplicities stay far below)
    recent = deque(maxlen=64)    # windows of the last rows, for the backward look
    srcs = []                    # (u, m) with m >= 2
    depth_max = {}               # j -> longest white run in the shifted block, over deep sources
    worst = {}
    for u in range(T + 1):
        win = (x >> (OFF - 1 - W)) & ((1 << (2 * W + 1)) - 1)   # bit W is cell -1
        c = lambda p: (win >> (W + 1 + p)) & 1                      # cell p, |p + 1| <= W
        m = 0
        if c(-1):
            L = 1
            while c(-1 - L):
                L += 1
            R = 1
            while c(-1 + R):
                R += 1
            m = min(L, R - 1 + c(R))
        if m >= 2:
            srcs.append((u, m))
        if m >= 3:
            for j in range(1, m):
                if j > len(recent):
                    break
                prev = recent[-j]
                pc = lambda p: (prev >> (W + 1 + p)) & 1
                run = best = 0
                for p in range(-m - j, m - 1 - j):
                    run = run + 1 if pc(p) == 0 else 0
                    best = max(best, run)
                if best > depth_max.get(j, -1):
                    depth_max[j] = best
                    worst[j] = (u, m)
        recent.append(win)
        x = (x << 1) ^ (x | (x >> 1))
    slack = [v - u - mu - mv for (u, mu), (v, mv) in zip(srcs, srcs[1:])]
    by_mv = {}
    for ((u, mu), (v, mv)), s in zip(zip(srcs, srcs[1:]), slack):
        by_mv[mv] = min(by_mv.get(mv, 10 ** 9), s)
    return {'T': T, 'sources_m_ge_2': len(srcs), 'max_m': max(m for _, m in srcs),
            'm_counts': {k: sum(1 for _, m in srcs if m == k) for k in sorted({m for _, m in srcs})},
            'least_slack': min(slack), 'least_slack_by_m_of_later_source': dict(sorted(by_mv.items())),
            'longest_white_run_in_shifted_block_by_depth': dict(sorted(depth_max.items())),
            'where': {j: worst[j] for j in sorted(worst)}}


def ring_preimages(y, N):
    out = []
    full = (1 << N) - 1
    bit = lambda v, i: (v >> (i % N)) & 1
    for x0 in (0, 1):
        for x1 in (0, 1):
            # new(p) = x(p - 1) xor (x(p) or x(p + 1)), so x(p - 1) = y(p) xor (x(p) or x(p + 1)), going down from p = 0
            xs_known = {0: x0, 1: x1}
            ok = True
            for p in range(0, -N, -1):
                v = bit(y, p) ^ (xs_known[p % N] | xs_known[(p + 1) % N])
                q = (p - 1) % N
                if q in xs_known:
                    if xs_known[q] != v:
                        ok = False
                        break
                else:
                    xs_known[q] = v
            if ok:
                x = sum(xs_known[i] << i for i in range(N))
                # verify on the ring
                img = 0
                for p in range(N):
                    img |= ((xs_known[(p - 1) % N] ^ (xs_known[p] | xs_known[(p + 1) % N])) << p)
                if img == (y & full):
                    out.append(x)
    return sorted(set(out))


def longest_cyclic_white(x, N):
    if x == 0:
        return N
    s = format(x, '0%db' % N)
    s2 = s + s
    return max(len(r) for r in s2.split('1'))


def ring_part(N, D, cap):
    level = {(1 << N) - 1}
    rows = []
    for d in range(1, D + 1):
        nxt = set()
        for y in level:
            nxt.update(ring_preimages(y, N))
            if len(nxt) > cap:
                break
        capped = len(nxt) > cap
        level = nxt if not capped else set(sorted(nxt)[:cap])
        rows.append({'depth': d, 'rings': len(nxt), 'capped': capped,
                     'longest_white_run': max(longest_cyclic_white(x, N) for x in level) if level else None})
        if not level:
            break
    return {'N': N, 'by_depth': rows}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--T', type=int, default=65536)
    ap.add_argument('--N', type=int, default=96)
    ap.add_argument('--D', type=int, default=18)
    ap.add_argument('--cap', type=int, default=200000)
    a = ap.parse_args()
    res = {'A_seed': seed_part(a.T), 'B_ring_cascade': ring_part(a.N, a.D, a.cap)}
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
