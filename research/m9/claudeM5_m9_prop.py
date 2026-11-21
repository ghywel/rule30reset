#!/usr/bin/env python3
"""claudeM5_m9_prop.py: pull M9, the Lean route for "at most three runs of four" (M83). A prototype of the proof the
kernel would check: forced propagation on the light-cone triangle, all trap windows at once, each cell's knowledge a
pair of lane masks (lanes known black, lanes known white), one lane per trap window or per window and split.

The triangle and the constraints are M80's (claudeM5_m9_sat.py, imported unchanged): cells (tau, j), 1 <= j <= M - tau;
the rule y = a xor (b or c) for y = (tau+1, j), a = (tau, j-1) (the centre when j = 1: black iff tau odd),
b = (tau, j), c = (tau, j+1); the window at tau = 0 one trap code per lane; column 1 fixed at the word's samples.

Propagation is generalised arc consistency on each rule relation: for each lane, keep the tuples (a, b, c, y) of the
relation that agree with what is known, and record any value shared by all of them; a lane with no tuple left is
refuted. Passes alternate forward and backward in time until nothing changes.

  python3 claudeM5_m9_prop.py KITFILE four|five|control333|control3535353 [SPLITS]
Prints how many lanes propagation alone refutes, and then, for the rest, whether one split (on a cell, both values)
refutes each, searched over the cells of the triangle.
"""
import importlib.util
import pathlib
import sys
import time

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('m9sat', HERE / 'claudeM5_m9_sat.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)

CASES = {'four': ('3' + '55553' * 4, 2), 'five': ('55553' * 5, 0),
         'control333': ('333', 0), 'control3535353': ('3535353', 0)}
TUPLES = [(a, b, c, a ^ (b | c)) for a in (0, 1) for b in (0, 1) for c in (0, 1)]


class Grid:
    def __init__(self, word, P):
        wh = S.heads_of(word)
        self.D = P + len(wh) - 1
        self.T = 2 * self.D
        self.M = self.T + 1
        self.cells = [(tau, j) for tau in range(self.T + 1) for j in range(1, self.M - tau + 1)]
        self.rel = []                     # (a, b, c, y) as cell keys, a = 'C0'/'C1' for the centre
        for tau in range(self.T):
            for j in range(1, self.M - tau):
                a = ('C', tau % 2) if j == 1 else (tau, j - 1)
                self.rel.append((a, (tau, j), (tau, j + 1), (tau + 1, j)))
        self.samples = {2 * (P + s): h for s, h in enumerate(wh)}


TRAP = None          # set by main when the trap rule is on: the 829 codes


def trap_rule(g, K, full, refuted):
    """At every sample time (even tau), the window of cells 1..16 is a trap window (kit: win_mem_trap)."""
    changed = False
    for tau in range(0, g.T + 1, 2):
        if g.M - tau < 16:
            break
        cells = [(tau, j + 1) for j in range(16)]
        al1 = [full & ~K[c][1] for c in cells]    # may be black
        al0 = [full & ~K[c][0] for c in cells]
        p1 = [0] * 16
        p0 = [0] * 16
        anyw = 0
        for code in TRAP:
            m = full
            for j in range(16):
                m &= al1[j] if (code >> j) & 1 else al0[j]
                if not m:
                    break
            if not m:
                continue
            anyw |= m
            for j in range(16):
                if (code >> j) & 1:
                    p1[j] |= m
                else:
                    p0[j] |= m
        dead = full & ~anyw
        if dead & ~refuted:
            refuted |= dead
            changed = True
        for j, c in enumerate(cells):
            n1 = full & ~p0[j] & ~dead
            n0 = full & ~p1[j] & ~dead
            if n1 & ~K[c][0] or n0 & ~K[c][1]:
                K[c][0] |= n1
                K[c][1] |= n0
                changed = True
    return refuted, changed


def propagate(g, lanes, init, full):
    """init: dict cell -> (k1, k0) masks. Returns (refuted mask, knowledge)."""
    K = {c: [0, 0] for c in g.cells}
    for c, (k1, k0) in init.items():
        K[c][0] |= k1
        K[c][1] |= k0
    refuted = 0

    def known(x):
        if x[0] == 'C':                 # the centre: black iff tau odd, in every lane
            return (full, 0) if x[1] == 1 else (0, full)
        return K[x]

    changed = True
    passes = 0
    order = g.rel
    while changed:
        changed = False
        passes += 1
        for rel in (order if passes % 2 else reversed(order)):
            ks = [known(x) for x in rel]
            allowed = [(full & ~k0, full & ~k1) for (k1, k0) in ks]   # (may be 1, may be 0)
            poss = [[0, 0] for _ in range(4)]                        # per variable: lanes where 1 / 0 possible
            anyt = 0
            for t in TUPLES:
                m = full
                for v in range(4):
                    m &= allowed[v][0] if t[v] else allowed[v][1]
                anyt |= m
                for v in range(4):
                    poss[v][0 if t[v] else 1] |= m
            dead = full & ~anyt
            if dead & ~refuted:
                refuted |= dead
                changed = True
            for v, x in enumerate(rel):
                if x[0] == 'C':
                    continue
                n1 = full & ~poss[v][1] & ~dead      # no tuple with 0: forced black
                n0 = full & ~poss[v][0] & ~dead
                if n1 & ~K[x][0] or n0 & ~K[x][1]:
                    K[x][0] |= n1
                    K[x][1] |= n0
                    changed = True
                both = K[x][0] & K[x][1]
                if both & ~refuted:
                    refuted |= both
                    changed = True
        if TRAP is not None:
            refuted, ch = trap_rule(g, K, full, refuted)
            changed |= ch
    return refuted, K, passes


def window_init(g, codes, extra=None):
    """Lane i: trap code codes[i] at tau = 0, the word's samples; extra[i] = list of (cell, value) splits."""
    full = (1 << len(codes)) - 1
    init = {}

    def put(c, lane_mask, val):
        k = init.setdefault(c, [0, 0])
        k[0 if val else 1] |= lane_mask
    for i, code in enumerate(codes):
        for j in range(16):
            put((0, j + 1), 1 << i, (code >> j) & 1)
        for c, val in (extra[i] if extra else []):
            put(c, 1 << i, val)
    for tau, h in g.samples.items():
        put((tau, 1), full, h)
    return full, init


def main():
    kit, name = sys.argv[1], sys.argv[2]
    trap = S.trap_codes(kit)
    global TRAP
    if '--trap-rule' in sys.argv:
        TRAP = trap
        sys.argv.remove('--trap-rule')
    word, P = CASES[name]
    g = Grid(word, P)
    t0 = time.time()
    full, init = window_init(g, trap)
    ref, K, passes = propagate(g, full, init, full)
    open_lanes = [i for i in range(len(trap)) if not (ref >> i) & 1]
    print('%s: %d cells, %d relations; propagation alone refutes %d of %d trap windows in %d passes (%.1f s); '
          'open: %d' % (name, len(g.cells), len(g.rel), bin(ref).count('1'), len(trap), passes,
                        time.time() - t0, len(open_lanes)), flush=True)
    if not open_lanes or len(sys.argv) < 4:
        return
    # one split per open window: try candidate cells in parallel lanes (both values), keep the first that refutes both
    cand = [c for c in g.cells if c[1] <= 20 and c[0] >= 1]
    unresolved = []
    found = {}
    for w in open_lanes:
        code = trap[w]
        best = None
        for start in range(0, len(cand), 256):
            chunk = cand[start:start + 256]
            codes = [code] * (2 * len(chunk))
            extra = [[(c, 1)] for c in chunk] + [[(c, 0)] for c in chunk]
            fl, ini = window_init(g, codes, extra)
            r, _, _ = propagate(g, fl, ini, fl)
            for k, c in enumerate(chunk):
                if (r >> k) & 1 and (r >> (k + len(chunk))) & 1:
                    best = c
                    break
            if best:
                break
        if best:
            found[w] = best
        else:
            unresolved.append(w)
    print('%s: one split refutes %d of the %d open windows; unresolved: %d (%.0f s)' % (
        name, len(found), len(open_lanes), len(unresolved), time.time() - t0), flush=True)


if __name__ == '__main__':
    main()
