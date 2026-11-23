#!/usr/bin/env python3
"""claudeCloud_wheel_trains_initial.py: the trains of K79 under R65's tighter edges (ledger K79, addendum 1).

claudeCloud_wheel_trains.py lets column W + 1 be free at every tick (the kit's two free inputs per double step).
R65, R69 and placego use tighter edges: at a sample the two free cells are columns W + 1 and W + 2 of the row, and
column W + 1 one tick later follows from the rule (K78 met the same difference in the window counts). A strip with
the tighter edges reads no more than the loose strip of W columns and no less than the loose strip of W + 1, so a
death width can be one column smaller here. This script adds that one constraint to the frozen encodings and
changes nothing else.

    python3 claudeCloud_wheel_trains_initial.py KITFILE finite GAPS W N [N ...]
    python3 claudeCloud_wheel_trains_initial.py KITFILE periodic GAPS K W [W ...]
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'm9'))
import claudeCloud_m9_lift as L                      # noqa: E402
import claudeCloud_wheel_exterior_sat as F           # noqa: E402
import claudeCloud_wheel_trains as T                 # noqa: E402


def tighten(var, nv, W, sample_ticks, next_tick):
    """For each sample tick t: a new free cell (t, W + 2), and (t + 1, W + 1) = (t, W) xor ((t, W + 1) or it)."""
    extra = []
    for t in sample_ticks:
        t1 = next_tick(t)
        if t1 is None:
            continue
        nv += 1
        r = nv
        n, l, c = var[(t1, W + 1)], var[(t, W)], var[(t, W + 1)]
        extra += [[-c, -n, -l], [-c, n, l], [-r, -n, -l], [-r, n, l], [c, r, -n, l], [c, r, n, -l]]
    return nv, extra


def periodic(gaps, K, W, budget):
    gate = ''.join('1' + '0' * (int(g) - 1) for g in gaps) * K
    period = 2 * len(gate)
    var, nv = {}, 0
    for t in range(period):
        for x in range(1, W + 2):
            nv += 1
            var[(t, x)] = nv
    clauses = []
    for t in range(period):
        t1 = (t + 1) % period
        wall = t % 2
        for x in range(1, W + 1):
            n, c, r = var[(t1, x)], var[(t, x)], var[(t, x + 1)]
            if x == 1:
                clauses += ([[-c, n], [-r, n], [c, r, -n]] if wall == 0 else [[-c, -n], [-r, -n], [c, r, n]])
            else:
                l = var[(t, x - 1)]
                clauses += [[-c, -n, -l], [-c, n, l], [-r, -n, -l], [-r, n, l], [c, r, -n, l], [c, r, n, -l]]
    for s, ch in enumerate(gate):
        v = var[(2 * s, 1)]
        clauses.append([v if ch == '1' else -v])
    nv, extra = tighten(var, nv, W, range(0, period, 2), lambda t: (t + 1) % period)
    clauses += extra
    from pysat.solvers import Cadical195
    with Cadical195(bootstrap_with=clauses) as sol:
        sol.conf_budget(budget)
        r = sol.solve_limited()
        if not r:
            return 'UNSAT' if r is False else 'UNKNOWN', None
        model = set(v for v in sol.get_model() if v > 0)
    # replay with the model's column W + 1, and check the tighter edge at every sample
    row = [1 if var[(0, x)] in model else 0 for x in range(1, W + 1)]
    first, ok = list(row), True
    for t in range(period):
        if t % 2 == 0 and row[0] != int(gate[t // 2]):
            ok = False
        east = 1 if var[(t, W + 1)] in model else 0
        if t % 2 == 0:
            nxt = 1 if var[((t + 1) % period, W + 1)] in model else 0
            # (t + 1, W + 1) must be row[W - 1] xor (east or free): possible unless east = 1 and nxt != 1 - row[W-1]
            if east == 1 and nxt != 1 - row[W - 1]:
                ok = False
        ext = [t % 2] + row + [east]
        row = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, W + 1)]
    ok &= row == first
    return 'SAT', ok


def finite(trap, gaps, W, n, budget):
    gate, S, Tt, var, nv, clauses = F.instance(trap, gaps, W, n)
    nv, extra = tighten(var, nv, W, range(0, Tt, 2), lambda t: t + 1)
    clauses += extra
    from pysat.solvers import Cadical195
    with Cadical195(bootstrap_with=clauses) as sol:
        sol.conf_budget(budget)
        r = sol.solve_limited()
        return ('SAT' if r else ('UNSAT' if r is False else 'UNKNOWN')), S


def main():
    kit, mode = sys.argv[1], sys.argv[2]
    trap = [int(c) for c in L.trap_codes(kit)]
    gaps = T.word(sys.argv[3])
    if mode == 'finite':
        W = int(sys.argv[4])
        for n in map(int, sys.argv[5:]):
            t0 = time.time()
            status, S = finite(trap, gaps, W, n, 20_000_000)
            print(json.dumps(dict(edges='initial', word=sys.argv[3], columns=W, copies=n, samples=S, status=status,
                                  seconds=round(time.time() - t0, 1))))
            sys.stdout.flush()
    elif mode == 'periodic':
        K = int(sys.argv[4])
        for W in map(int, sys.argv[5:]):
            t0 = time.time()
            status, ok = periodic(gaps, K, W, 20_000_000)
            print(json.dumps(dict(edges='initial', word=sys.argv[3], columns=W, copies=K, status=status, replays=ok,
                                  seconds=round(time.time() - t0, 1))))
            sys.stdout.flush()
    else:
        raise SystemExit('unknown mode')


if __name__ == '__main__':
    main()
