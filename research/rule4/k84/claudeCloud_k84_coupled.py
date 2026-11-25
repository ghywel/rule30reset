#!/usr/bin/env python3
"""claudeCloud_k84_coupled.py: the longest alternation that a west of bounded support can keep with SOME right half
(ledger K84).

A centre black at even ticks, a west supported on depths 1..B at tick 0 and a right half of any support. The centre
stays alternating through tick T (its values at ticks 0..T are 1, 0, 1, ...) exactly when, for every t < T,
    even t: depth 1 of the west is black at t          (the west's own condition; while it holds the west evolves
                                                         as beside a white wall)
    odd t:  cell 1 of the right half at t = not (depth 1 of the west at t)    (the right half supplies the demand).
L(B) is the largest such T over all wests and right halves. It is decided by SAT on the two light cones: west cells
(d, t) with d + t <= T + 1 (depth d > B white at tick 0) and right cells (j, t) with j + t <= T, both closed under the
rule's dependencies. UNSAT is COMPUTED (python-sat, CaDiCaL 1.9.5); a SAT witness is replayed on the full line.

    python3 claudeCloud_k84_coupled.py longest B [TMAX]        L(B) by doubling and bisection, with the witness
    python3 claudeCloud_k84_coupled.py exact-depth B [TMAX]    the same with depth B black at tick 0
"""
import json
import sys
import time


def build(B, T, exact_depth=False):
    var = {}
    nv = [0]

    def v(key):
        if key not in var:
            nv[0] += 1
            var[key] = nv[0]
        return var[key]
    cl = []
    # west: z(d, t), d >= 1, d + t <= T + 1; the white wall at depth 0
    for t in range(T + 2):
        for d in range(1, T + 2 - t):
            v(('z', d, t))
    for d in range(1, T + 2):
        if d > B:
            cl.append([-var[('z', d, 0)]])
    if exact_depth and B <= T + 1:
        cl.append([var[('z', B, 0)]])
    for t in range(1, T + 2):
        for d in range(1, T + 2 - t):
            n = var[('z', d, t)]
            l = var[('z', d + 1, t - 1)]          # the deeper neighbour: rule 30's left argument
            c = var[('z', d, t - 1)]
            if d == 1:                            # right argument is the white wall: n = l xor c
                cl += [[-n, l, c], [-n, -l, -c], [n, -l, c], [n, l, -c]]
            else:
                r = var[('z', d - 1, t - 1)]
                cl += [[-c, -n, -l], [-c, n, l], [-r, -n, -l], [-r, n, l], [c, r, -n, l], [c, r, n, -l]]
    # right half: x(j, t), j >= 1, j + t <= T; centre black at even ticks
    for t in range(T + 1):
        for j in range(1, T + 1 - t):
            v(('x', j, t))
    for t in range(1, T + 1):
        for j in range(1, T + 1 - t):
            n, c, r = var[('x', j, t)], var[('x', j, t - 1)], var[('x', j + 1, t - 1)]
            if j == 1:
                if (t - 1) % 2 == 1:              # white centre: n = c or r
                    cl += [[-c, n], [-r, n], [c, r, -n]]
                else:                             # black centre: n = not (c or r)
                    cl += [[-c, -n], [-r, -n], [c, r, n]]
            else:
                l = var[('x', j - 1, t - 1)]
                cl += [[-c, -n, -l], [-c, n, l], [-r, -n, -l], [-r, n, l], [c, r, -n, l], [c, r, n, -l]]
    # the coupling, t < T
    for t in range(T):
        if t % 2 == 0:
            cl.append([var[('z', 1, t)]])
        else:
            g, z = var[('x', 1, t)], var[('z', 1, t)]
            cl += [[g, z], [-g, -z]]              # g = not z
    return var, cl, nv[0]


def replay_full(west_bits, right_bits, T):
    """Full-line check: cells -len(west)..len(right), the centre black at tick 0; returns the centre at 0..T."""
    W, R = len(west_bits), len(right_bits)
    n = W + 1 + R + 2 * T + 4
    off = W + T + 2                               # index of cell 0
    row = [0] * n
    for d, b in enumerate(west_bits, start=1):
        row[off - d] = b
    row[off] = 1
    for j, b in enumerate(right_bits, start=1):
        row[off + j] = b
    centre = [row[off]]
    for t in range(T):
        row = [0] + [row[i - 1] ^ (row[i] | row[i + 1]) for i in range(1, n - 1)] + [0]
        centre.append(row[off])
    return centre


def solve(B, T, exact_depth=False):
    from pysat.solvers import Cadical195
    var, cl, nv = build(B, T, exact_depth)
    with Cadical195(bootstrap_with=cl) as s:
        if not s.solve():
            return False, None, nv, len(cl)
        m = set(x for x in s.get_model() if x > 0)
    # depths beyond the west's cone (d > T + 1) cannot reach depth 1 by tick T: white in the witness
    west = [1 if (('z', d, 0) in var and var[('z', d, 0)] in m) else 0 for d in range(1, B + 1)]
    right = [1 if var[('x', j, 0)] in m else 0 for j in range(1, T + 1)]
    return True, (west, right), nv, len(cl)


def longest(B, TMAX=400, exact_depth=False):
    t0 = time.time()
    lo, wit = 0, None                             # SAT at lo; T = 0 is trivially SAT
    ok, w, _, _ = solve(B, 1, exact_depth)
    if not ok:
        return dict(B=B, L=0)
    lo, wit = 1, w
    hi = None
    T = 2
    while T <= TMAX:                              # doubling
        ok, w, nv, nc = solve(B, T, exact_depth)
        if ok:
            lo, wit = T, w
            T *= 2
        else:
            hi = T
            break
    if hi is None:
        return dict(B=B, L='>=%d' % lo)
    while hi - lo > 1:
        mid = (lo + hi) // 2
        ok, w, nv, nc = solve(B, mid, exact_depth)
        if ok:
            lo, wit = mid, w
        else:
            hi = mid
    west, right = wit
    centre = replay_full(west, right, lo)
    good = all(centre[t] == (1 if t % 2 == 0 else 0) for t in range(lo + 1))
    wh = ''.join(str(b) for b in reversed(west)).lstrip('0') or '0'
    return dict(B=B, exact_depth=exact_depth, L=lo, unsat_at=hi, west_hex=hex(int(wh, 2))[2:],
                witness_replayed=good, seconds=round(time.time() - t0, 1))


if __name__ == '__main__':
    mode, B = sys.argv[1], int(sys.argv[2])
    TMAX = int(sys.argv[3]) if len(sys.argv) > 3 else 400
    print(json.dumps(longest(B, TMAX, exact_depth=(mode == 'exact-depth'))), flush=True)
