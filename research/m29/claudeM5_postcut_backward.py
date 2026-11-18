#!/usr/bin/env python3
"""Pull M29, M36's next test, done exactly: phi(w) for widths beyond exhaustive reach, and the error edge's jumps.

phi(w) = the least number of band-map steps by which a post-cut word of width w reaches the edge cycle C_w (M36).
A word u has transient T(u) = t exactly when R^t(u) is on C_w and R^(t-1)(u) is not, so the words of transient t are
the t-th backward layer of C_w under R (kit coordinates, bit 0 the edge, R(v) = 4v xor (2v or v) mod 2^w). Layer t
is found from layer t - 1 by solving R(v) = u bit by bit: new(j) = v(j - 2) xor (v(j - 1) or v(j)), so v(j) is forced
when v(j - 1) = 0 and free (or impossible) when v(j - 1) = 1. phi(w) = the first layer holding a post-cut word
(some incoming register leaves the one-layer inverse recursion off 00 after the edge cell). This replaces M36's
frozen heuristic search with an exact computation; the predictions are M36's.

Controls: phi = 2, 2, 2, 2, 2, 3, 3 at widths 20-26 (M36, exhaustive); the backward layers' sizes sum, over all
transients, to 2^(w-1) at width 20 (every odd word, counted once).
Reported per width: layer sizes up to phi, phi, M34's K(w), the minimisers, and their error edges e(s) (the
shallowest wheel at which R^s(u) differs from the cycle orbit it joins), with the longest one-tick advance before
the last step, and the difference pattern beneath it.
Predictions (M36): phi(w) = K(w) at every width reached; the longest one-tick jump stays below 20. Kill: a jump that
grows with the width.
Usage: claudeM5_postcut_backward.py OUTFILE [--w0 20] [--w1 128] [--widths a,b,...] [--cap 3000000]
"""
import argparse, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))


def R(v, M):
    return ((v << 2) ^ ((v << 1) | v)) & M


def cycle_of(w):
    M = (1 << w) - 1
    v = 1
    for _ in range(40 * w + 400):
        v = R(v, M)
    cyc = [v]
    while True:
        u = R(cyc[-1], M)
        if u == cyc[0]:
            return cyc
        cyc.append(u)


def preimages(u, w):
    """Every width-w word v with R(v) = u (mod 2^w)."""
    if not (u & 1):
        return []
    out, stack = [], [(1, 1, 1)]     # (next bit j, v so far, v(j - 1)); v(0) = u(0) = 1
    while stack:
        j, v, prev = stack.pop()
        if j == w:
            out.append(v)
            continue
        vm2 = (v >> (j - 2)) & 1 if j >= 2 else 0
        target = ((u >> j) & 1) ^ vm2            # must equal v(j - 1) or v(j)
        if prev == 1:
            if target == 1:
                stack.append((j + 1, v, 0))
                stack.append((j + 1, v | (1 << j), 1))
        elif target:
            stack.append((j + 1, v | (1 << j), 1))
        else:
            stack.append((j + 1, v, 0))
    return out


def post_cut(u, w):
    for pm1 in (0, 1):
        for p0 in (0, 1):
            p, c = pm1, p0
            for j in range(w - 1, -1, -1):
                x = (u >> j) & 1
                p, c = c, x ^ (c | p)
            if p | c:
                return True
    return False


def lowbit(d):
    return (d & -d).bit_length() - 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--w0', type=int, default=20)
    ap.add_argument('--w1', type=int, default=128)
    ap.add_argument('--cap', type=int, default=3000000)
    ap.add_argument('--widths', default='')
    a = ap.parse_args()
    steps = [(20, 2), (25, 3), (62, 4), (67, 5), (81, 6), (86, 7), (91, 8), (103, 9), (108, 10), (123, 11)]
    K = {w: max(k for w0, k in steps if w0 <= w) for w in range(20, 129)}   # M34's strip capacity
    # control: the full backward basin at width 20 holds every odd word once, the last layer at transient 26
    M20, cyc20 = (1 << 20) - 1, cycle_of(20)
    seen20, lay, n = set(cyc20), list(cyc20), 0
    while lay:
        nx = []
        for u in lay:
            for v in preimages(u, 20):
                if v not in seen20:
                    seen20.add(v)
                    nx.append(v)
        lay = nx
        n += 1 if lay else 0
    control = {'basin_words_w20': len(seen20), 'expected': 1 << 19, 'deepest_layer_w20': n, 'expected_deepest': 26}
    print(json.dumps(control), flush=True)
    rows = []
    widths = [int(x) for x in a.widths.split(',')] if a.widths else list(range(a.w0, a.w1 + 1))
    for w in widths:
        M = (1 << w) - 1
        cyc = cycle_of(w)
        order = {c: i for i, c in enumerate(cyc)}
        seen = set(cyc)
        layer = list(cyc)
        sizes = [len(layer)]
        phi, mins = None, []
        if any(post_cut(c, w) for c in cyc):
            phi, mins = 0, [c for c in cyc if post_cut(c, w)]
        t = 0
        capped = False
        while phi is None:
            t += 1
            nxt = []
            for u in layer:
                for v in preimages(u, w):
                    if v not in seen:
                        seen.add(v)
                        nxt.append(v)
            layer = nxt
            sizes.append(len(layer))
            if not layer or len(seen) > a.cap:
                capped = True
                break
            hits = [v for v in layer if post_cut(v, w)]
            if hits:
                phi, mins = t, hits
        jumps, worst = [], None
        for u in mins[:500]:
            xs = [u]
            for _ in range(phi):
                xs.append(R(xs[-1], M))
            land = order[xs[-1]]
            ys = [cyc[(land - phi + s) % len(cyc)] for s in range(phi + 1)]
            e = [lowbit(x ^ y) if x != y else w for x, y in zip(xs, ys)]
            inner = [e[s + 1] - e[s] for s in range(phi - 1)]
            if inner:
                jmax = max(inner)
                jumps.append(jmax)
                if worst is None or jmax > worst['jump']:
                    s = inner.index(jmax)
                    d = xs[s] ^ ys[s]
                    worst = {'jump': jmax, 'from_wheel': e[s], 'to_wheel': e[s + 1], 'tick': s,
                             'difference_wheels': [j for j in range(e[s], min(w, e[s + 1] + 3)) if (d >> j) & 1],
                             'error_edges': e}
        row = {'w': w, 'period': len(cyc), 'layer_sizes': sizes, 'capped': capped, 'phi': phi, 'K': K.get(w),
               'phi_equals_K': phi == K.get(w), 'minimisers': len(mins),
               'longest_inner_jump': max(jumps) if jumps else None, 'worst': worst}
        rows.append(row)
        print(json.dumps({k: row[k] for k in ('w', 'layer_sizes', 'phi', 'K', 'phi_equals_K', 'minimisers',
                                                'longest_inner_jump')}), flush=True)
    with open(a.outfile, 'w') as fh:
        json.dump({'control': control, 'rows': rows}, fh, indent=1)


if __name__ == '__main__':
    main()
