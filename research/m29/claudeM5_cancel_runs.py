#!/usr/bin/env python3
"""Pull M29 (M38): how far can the error edge jump in one tick, at each wheel of the edge cycle?

Two band words X (a post-cut word) and Y (the cycle word it will join, at the matching phase) evolve by the band map
R, new(j) = v(j - 2) xor (v(j - 1) or v(j)) in kit coordinates (bit 0 the edge). With d = X xor Y and error edge e
(d(j) = 0 for j < e, d(e) = 1), one tick later they agree at wheel j exactly when
    d(j - 2) = (X(j - 1) or X(j)) xor (Y(j - 1) or Y(j)),   X = Y xor d   (M37).
Where X(j - 1) = 1 this is a condition on d(j - 2) and Y alone, with d(j) free; where X(j - 1) = 0 it forces d(j).
J(e, Y) = the longest run of agreement from wheel e over every choice of the deeper differences, found by tracking
the reachable pairs (d(j - 1), d(j)). The new error edge is at most e + J(e, Y).

Computed on the width-4096 cycle (16 phases; every row's limit through wheel 53,207, Rule30UniversalLeftSide):
  A. J(e) for every wheel e and phase, with its maximum by depth block of 256 wheels.
  B. A rate certificate. Every post-cut word starts with e(0) <= 19 against every phase (K(20) >= 1, M36). With
     U(0) = 19 and U(s + 1) = max over e <= U(s) of e + J(e, phase psi + s), the error edge after s ticks is at most
     U(s). So phi(w) >= s*(w), the least s with U(s) >= w over the starting phases psi, and by M36's reduction
     f(k) <= max(g(w), w + k) when s*(w) >= k.
Controls: the observed jumps of M37 are allowed (some phase gives J(1) >= 18, J(2) >= 14, J(16) >= 45); and
s*(w) <= K(w) = phi(w) at the widths of M37, as a lower bound must be.
Predictions (written before the run): beyond wheel 64 the largest J stays at or below 45 to wheel 4096, with no growth
by depth block; s*(4096) >= 80. Kill: J grows with depth (a block maximum above 90 below wheel 1024).
Usage: claudeM5_cancel_runs.py OUTFILE [--W 4096]
"""
import argparse, json


def limit_cycle(W):
    M = (1 << W) - 1
    v = 1
    for _ in range(4 * W + 1000):
        v = ((v << 2) ^ ((v << 1) | v)) & M
    cyc = [v]
    while True:
        u = ((cyc[-1] << 2) ^ ((cyc[-1] << 1) | cyc[-1])) & M
        if u == cyc[0]:
            return cyc
        cyc.append(u)


def runs(Y, W):
    """J(e) for e = 0 .. W - 1 against the cycle word Y (a list of bits, wheel 0 the edge)."""
    J = [0] * W
    for e in range(1, W):
        # wheel e: d(e - 2) = d(e - 1) = 0, d(e) = 1; X(e - 1) = Y(e - 1)
        if Y[e - 1] == 0:
            continue                               # heals only under a black parent (heal_iff)
        S = {(0, 1)}                               # (d(j - 1), d(j)) after wheel j = e
        j = e + 1
        while S and j < W:
            nxt = set()
            yo = Y[j - 1] | Y[j]
            for p, q in S:                         # p = d(j - 2), q = d(j - 1)
                if Y[j - 1] ^ q:                   # X(j - 1) = 1
                    if p == 1 ^ yo:
                        nxt.add((q, 0))
                        nxt.add((q, 1))
                else:
                    nxt.add((q, p ^ Y[j] ^ yo))
            S = nxt
            if S:
                j += 1
        J[e] = j - e
    return J


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--W', type=int, default=4096)
    a = ap.parse_args()
    W = a.W
    cyc = limit_cycle(W)
    P = len(cyc)
    bits = [[(v >> j) & 1 for j in range(W)] for v in cyc]
    Js = [runs(b, W) for b in bits]
    blocks = {}
    for J in Js:
        for e, x in enumerate(J):
            b = (e // 256) * 256
            blocks[b] = max(blocks.get(b, 0), x)
    deep = max(x for J in Js for e, x in enumerate(J) if e >= 64)
    controls = {'J1': max(J[1] for J in Js), 'J2': max(J[2] for J in Js), 'J16': max(J[16] for J in Js)}
    # rate certificate: prefix maxima pm[phase][u] = max over e <= u of e + J(e)
    pm = []
    for J in Js:
        row, best = [0] * W, 0
        for e in range(W):
            best = max(best, e + J[e])
            row[e] = best
        pm.append(row)
    best_s = {}
    for psi in range(P):
        U, s, reached = 19, 0, {}
        while U < W and s < 4 * W:
            U = pm[(psi + s) % P][U]
            s += 1
            reached[s] = U
        best_s[psi] = reached
    def s_star(w):
        out = None
        for psi, reached in best_s.items():
            s = next((s for s in sorted(reached) if reached[s] >= w), None)
            if s is not None and (out is None or s < out):
                out = s
        return out
    steps = [(20, 2), (25, 3), (62, 4), (67, 5), (81, 6), (86, 7), (91, 8), (103, 9), (108, 10), (123, 11)]
    K = lambda w: max(k for w0, k in steps if w0 <= w)
    sstar = {w: s_star(w) for w in list(range(20, 129)) + [256, 512, 1024, 2048, W]}
    sound = all(sstar[w] <= K(w) for w in range(20, 129))
    res = {'W': W, 'period': P, 'max_J_by_block': dict(sorted(blocks.items())), 'max_J_beyond_wheel_64': deep,
           'controls': controls, 'controls_ok': controls['J1'] >= 18 and controls['J2'] >= 14 and controls['J16'] >= 45,
           's_star': sstar, 's_star_at_most_K_to_128': sound,
           'K_vs_s_star': {w: [K(w), sstar[w]] for w in (25, 62, 67, 81, 86, 91, 103, 108, 123, 128)}}
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: res[k] for k in ('period', 'max_J_by_block', 'max_J_beyond_wheel_64', 'controls',
                                          'controls_ok', 's_star_at_most_K_to_128', 'K_vs_s_star')}))
    print(json.dumps({w: sstar[w] for w in (256, 512, 1024, 2048, W)}))


if __name__ == '__main__':
    main()
