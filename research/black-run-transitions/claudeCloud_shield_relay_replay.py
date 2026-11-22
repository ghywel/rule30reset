#!/usr/bin/env python3
"""claudeCloud_shield_relay_replay.py: carrying read of the finite claims of path 1 (ledger K64): gptIntel's I98,
I101, I103 and I105. Written from the posts and from the Lean statements alone (`Builds`, `Pulse`, `relay`,
`exact_first_relay`, `finite_relay` in Rule30PulseRelay.lean; the kit's `nine_black`). Nothing of gptIntel's code,
packets or SAT output is used.

Conventions, as in the kit. Positions grow to the right; the column at site 0 drives sites 1, 2, ... A tick:
    new(i) = old(i - 1) xor (old(i) or old(i + 1)).
Site i at tick t depends on sites 1 .. i + t at tick 0 and on the column at ticks 0 .. t - 1, so every claim below is
about a finite cone: every right half is covered by letting all its cells in the cone be free.

The checks (SAT by python-sat's CaDiCaL; UNSAT answers are COMPUTED, no certificate is written; every SAT model is
replayed by direct simulation, written separately below):
  S  shield: N consecutive black ticks fix sites 1 .. 2k to (white, black)^k at tick N, for every right half.
     k = 1: 9 suffice, 8 do not (the kit's control). k = 5: 44 and 43 (I98). k = 8: 70 and 69 (I101).
     k = 15: 128 and 127 (I96; there checked by LRAT outside Lean).
  R  relay (I103): the column black at ticks 0 .. n - 1 and white at n. Then site 2 is white at tick n + 2 and black
     at every tick 9 .. n + 1, for every right half, n = 9 .. 80. And the right half 19 (sites 1, 2, 5 black) has
     site 2 white at tick 8, so the loss of 7 is attained, n = 9 .. 400.
  A  agreement (finite_relay with the kit's nine-tick pair): two rows, any two right halves, both with the column
     black at ticks 0 .. n - 1, white at n, and the same column afterwards. With n = 7j + 2, site 1 agrees at ticks
     n .. n + 4j - 1. Checked for j = 1 .. 6.
  W  sharpness of A (I105 has witnesses for runs 9 to 30, and left 37 and 44 open): is there a pair with n = 7j + 2
     whose site 1 differs at tick n + 4j? j = 1 .. 6, and also every n from 9 to 44 at its own horizon 4j(n),
     j(n) = floor((n - 2) / 7).
  Q  the arithmetic of the period tests in I98 and I103 at their examples, and that 7P + 29 <= 11r implies the
     relay test for every r < P up to 2,000.

    python3 claudeCloud_shield_relay_replay.py            (everything)
    python3 claudeCloud_shield_relay_replay.py control    (the kit's 9 and 8 only)
"""
import sys, time
from pysat.solvers import Cadical195


class CNF:
    def __init__(self):
        self.n = 0; self.cl = []
        self.T = self.var(); self.cl.append([self.T])            # constant true
    def var(self):
        self.n += 1; return self.n
    def rule(self, a, b, c):
        """z <-> a xor (b or c), by its truth table."""
        z = self.var()
        for va in (0, 1):
            for vb in (0, 1):
                for vc in (0, 1):
                    f = va ^ (vb | vc)
                    lits = [(-a if va else a), (-b if vb else b), (-c if vc else c)]
                    self.cl.append(lits + [z if f else -z])
        return z


def cone(F, W, T, col):
    """Sites 1 .. W free at tick 0; col[t] is a literal for the column at tick t. Returns x[t][i] for i <= W - t."""
    x = [[None] + [F.var() for _ in range(W)]]
    for t in range(T):
        prev = x[-1]; row = [None]
        for i in range(1, W - t):
            left = col[t] if i == 1 else prev[i - 1]
            row.append(F.rule(left, prev[i], prev[i + 1]))
        x.append(row)
    return x


def solve(F, extra):
    with Cadical195(bootstrap_with=F.cl + extra) as s:
        ok = s.solve()
        return ok, (s.get_model() if ok else None)


def simulate(right, cols, T):
    """right: list of sites 1 .. W at tick 0 (index 0 = site 1); cols[t] the column. Returns rows; row t has sites 1 .. W - t."""
    rows = [list(right)]
    for t in range(T):
        p = rows[-1]; W = len(p)
        rows.append([(cols[t] if i == 0 else p[i - 1]) ^ (p[i] | (p[i + 1] if i + 1 < W else 0)) for i in range(W - 1)])
    return rows


def shield(k, N):
    """True if N black ticks fix sites 1..2k at tick N for every right half; else a replayed counterexample."""
    F = CNF(); W = 2 * k + N
    x = cone(F, W, N, [F.T] * N)
    target = [0, 1] * k
    bad = [(x[N][i] if target[i - 1] == 0 else -x[N][i]) for i in range(1, 2 * k + 1)]
    ok, model = solve(F, [bad])
    if not ok:
        return True, None
    m = set(l for l in model if l > 0)
    right = [1 if x[0][i] in m else 0 for i in range(1, W + 1)]
    rows = simulate(right, [1] * N, N)
    got = rows[N][:2 * k]
    assert got != target, 'a SAT model did not replay'
    return False, ''.join(map(str, right)).rstrip('0') or '0'


def relay_all(n):
    F = CNF(); W = n + 4
    col = [F.T] * n + [-F.T] + [F.var()]                 # the column at n + 1 is free: site 2 at n + 2 does not see it
    x = cone(F, W, n + 2, col)
    bad = [x[n + 2][2]] + [-x[t][2] for t in range(9, n + 2)]
    ok, _ = solve(F, [bad])
    return not ok


def relay_19(n):
    right = [1, 1, 0, 0, 1] + [0] * (n + 4)
    rows = simulate(right, [1] * n + [0, 0], n + 2)       # the column at n + 1 is not seen by site 2 at n + 2
    s2 = [rows[t][1] for t in range(n + 3)]
    return s2[8] == 0 and all(s2[t] == 1 for t in range(9, n + 2)) and s2[n + 2] == 0


def agree(n, h, want_differ_at=None):
    """Two rows, same column (black 0..n-1, white n, then shared free bits). If want_differ_at is None: True when site 1
    agrees at ticks n..n+h-1 for every pair. Else: a replayed pair differing at tick want_differ_at, or None."""
    T = (want_differ_at if want_differ_at is not None else n + h - 1)
    F = CNF(); W = T + 1
    free = [F.var() for _ in range(max(0, T - n - 1))]
    col = [F.T] * n + [-F.T] + free
    x = cone(F, W, T, col); y = cone(F, W, T, col)
    if want_differ_at is None:
        diffs = []
        for t in range(n, n + h):
            d = F.var()                                   # d -> x != y at tick t, site 1
            F.cl += [[-d, x[t][1], y[t][1]], [-d, -x[t][1], -y[t][1]]]
            diffs.append(d)
        ok, _ = solve(F, [diffs])
        return not ok
    t = want_differ_at
    ok, model = solve(F, [[x[t][1], y[t][1]], [-x[t][1], -y[t][1]]])
    if not ok:
        return None
    m = set(l for l in model if l > 0)
    rx = [1 if x[0][i] in m else 0 for i in range(1, W + 1)]
    ry = [1 if y[0][i] in m else 0 for i in range(1, W + 1)]
    cols = [1] * n + [0] + [1 if v in m else 0 for v in free]
    a = simulate(rx, cols, t); b = simulate(ry, cols, t)
    first = next(s for s in range(n, t + 1) if a[s][0] != b[s][0])
    assert first == t, 'the replayed pair differs before the requested tick'
    return (''.join(map(str, rx)).rstrip('0') or '0', ''.join(map(str, ry)).rstrip('0') or '0', ''.join(map(str, cols[n:])))


def H(j):
    return 9 * j - j // 5


def main():
    t0 = time.time()
    print('S. Shield: N black ticks fix sites 1..2k to (white, black)^k at tick N.')
    plan = [(1, 9), (1, 8)] if (len(sys.argv) > 1 and sys.argv[1] == 'control') else [(1, 9), (1, 8), (5, 44), (5, 43), (8, 70), (8, 69), (15, 128), (15, 127)]
    for k, N in plan:
        ok, wit = shield(k, N)
        print('   k = %2d, N = %3d: %s' % (k, N, 'every right half (UNSAT)' if ok else 'fails for right half %s (replayed)' % wit), flush=True)
    if len(sys.argv) > 1 and sys.argv[1] == 'control':
        return
    print('R. Relay: site 2 white at n + 2 and black at ticks 9 .. n + 1, for every right half.')
    bad = [n for n in range(9, 81) if not relay_all(n)]
    print('   n = 9 .. 80: %s' % ('holds at every n' if not bad else 'FAILS at %s' % bad), flush=True)
    bad19 = [n for n in range(9, 401) if not relay_19(n)]
    print('   right half 19: site 2 white at tick 8, black 9 .. n + 1, white at n + 2, for n = 9 .. 400: %s' % ('every n' if not bad19 else 'NOT at %s' % bad19), flush=True)
    print('A. Agreement: n = 7j + 2 black ticks, then the same drive: site 1 agrees at ticks n .. n + 4j - 1.')
    for j in range(1, 7):
        n = 7 * j + 2
        print('   j = %d, n = %2d: %s' % (j, n, 'every pair (UNSAT)' if agree(n, 4 * j) else 'FAILS'), flush=True)
    print('W. Sharpness: a pair whose site 1 first differs at tick n + 4j(n), j(n) = floor((n - 2) / 7).')
    for n in range(9, 45):
        j = (n - 2) // 7
        w = agree(n, None, want_differ_at=n + 4 * j)
        print('   n = %2d, j = %d: %s' % (n, j, 'first difference at +%d: right halves %s and %s, drive after the white tick %s (replayed)' % (4 * j, w[0], w[1], w[2]) if w else 'no pair differs at +%d (UNSAT)' % (4 * j)), flush=True)
    print('Q. Arithmetic of the period tests.')
    print('   I98 first test, r = 44, P = 64: H(floor((P - r + 3)/4)) = H(%d) = %d <= 44: %s' % ((64 - 44 + 3) // 4, H((64 - 44 + 3) // 4), H((64 - 44 + 3) // 4) <= 44))
    print('   I98 second test, s = 9, r = 45, P = 74: 1 + H(floor((P - s - r + 1)/4)) = %d <= 45: %s' % (1 + H((74 - 9 - 45 + 1) // 4), 1 + H((74 - 9 - 45 + 1) // 4) <= 45))
    print('   I103 first test, r = 16, P = 24: j = 2, r >= 16 and P - r = 8 <= 8: %s' % (16 >= 7 * 2 + 2 and 24 - 16 <= 8))
    print('   I103 second test, s = 9, r = 16, P = 35: j = 2, r >= 16 and P - s - r = 10 <= 10: %s' % (16 >= 16 and 35 - 9 - 16 <= 10))
    bad = [(r, P) for P in range(2, 2001) for r in range(1, P) if 7 * P + 29 <= 11 * r and not ((r - 2) // 7 >= 0 and r >= 7 * ((r - 2) // 7) + 2 and P - r <= 4 * ((r - 2) // 7))]
    print('   7P + 29 <= 11r implies the relay test for every r < P <= 2,000: %s' % ('yes' if not bad else 'NO, e.g. %s' % bad[:3]))
    print('   limiting fractions: 7/11 = %.4f; 44-tick block (cost 34, gain 20) 17/27 = %.4f; 70-tick block (54, 32) 27/43 = %.4f' % (7 / 11, 34 / 54, 54 / 86))
    print('time %.0f s' % (time.time() - t0))


if __name__ == '__main__':
    main()
