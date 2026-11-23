#!/usr/bin/env python3
"""claudeCloud_wheel_trains.py: do the excursion trains of the two exterior components survive when the strip
beside the alternating wall is widened? (ledger K79)

A right half is driven by the alternating column 0. Its GATE is column 1 at the white ticks of the wall (the
samples); a KICK is a black gate sample; a GAP is the number of samples from one kick to the next. Outside the kit's
gate trap the only window components whose gate can vary are X and Y (R65, R69, K78):

    X   the loop A = 25 with the excursion E = 33535555; a SPACING n is the number of loops between two excursions
    Y   the loop 2 with the excursions S = 45 and L = 4525; a separator is a run of 2s

A TRAIN is a gap word repeated for ever, for example E A^7 (X, constant spacing 7) or 45 2^12 (Y). A STRIP of W
columns is columns 1..W with column W + 1 free at every tick (the kit's two free inputs per double step), so a
strip reads at least everything a real right half reads on its first W columns.

    alive at W    some closed walk of the W-column window graph spells the train: SAT on a time circle of K copies
                  of the word (the model is replayed tick by tick)
    dead at W     no W-column strip spells the word N times from a kick: UNSAT (COMPUTED only; python-sat CaDiCaL)

A W-column strip restricted to its first W - 1 columns is a strip, so alive at W gives alive below W and dead at W
gives dead above W. By compactness a train is dead at W exactly when some N is refused, and alive exactly when
some closed walk exists; the closed walk may need many copies, so near the edge a width can stay open here.

    python3 claudeCloud_wheel_trains.py KITFILE finite GAPS W N [N ...]
    python3 claudeCloud_wheel_trains.py KITFILE periodic GAPS K W [W ...]
    python3 claudeCloud_wheel_trains.py KITFILE death GAPS LO HI [KMAX NMAX BUDGET]
        binary search between LO and HI; prints every width tried and one final JSON line with the last width seen
        alive and the first width seen dead
    python3 claudeCloud_wheel_trains.py KITFILE witness GAPS K W OUT
        writes the rows of a closed walk (one line per tick, column 1 first) for a look at its far columns

A gap word is written with single digits; `E`, `A`, `S`, `L` and a count may be used: E A*7 -> 33535555 25 x 7,
S 2*12 -> 45 2 x 12. Pieces are joined with `.`: for example  E.A*7  or  S.2*12  or  S.2*3.L.2*3 .
"""
import hashlib
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'm9'))
import claudeCloud_m9_lift as L                      # noqa: E402
import claudeCloud_wheel_exterior_sat as F           # noqa: E402  (the finite strip, K77)

NAMES = {'E': '33535555', 'A': '25', 'S': '45', 'L': '4525'}


def word(spec):
    out = ''
    for piece in spec.split('.'):
        base, _, count = piece.partition('*')
        out += NAMES.get(base, base) * (int(count) if count else 1)
    assert out and all(ch in '2345' for ch in out), spec
    return out


def periodic(gaps, K, W, budget):
    """A closed walk: columns 1..W on a time circle, the gate reading K copies of the gap word, column W + 1 free.
    The same encoding as K77's strip(); rebuilt here so that the rows of the model can be returned."""
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
        wall = t % 2                                   # white at even ticks: the samples
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
    from pysat.solvers import Cadical195
    with Cadical195(bootstrap_with=clauses) as sol:
        sol.conf_budget(budget)
        r = sol.solve_limited()
        if not r:
            return ('UNSAT' if r is False else 'UNKNOWN'), None, None
        model = set(v for v in sol.get_model() if v > 0)
    row = [1 if var[(0, x)] in model else 0 for x in range(1, W + 1)]
    first, rows, ok = list(row), [], True
    for t in range(period):
        rows.append(list(row))
        if t % 2 == 0 and row[0] != int(gate[t // 2]):
            ok = False
        east = 1 if var[(t, W + 1)] in model else 0
        ext = [t % 2] + row + [east]
        row = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, W + 1)]
    ok &= row == first
    return 'SAT', ok, rows


def finite(trap, trapset, gaps, W, n, budget):
    """K77's finite strip: the word n times from a kick, every sample outside the trap. Returns the status."""
    gate, S, T, var, nv, clauses = F.instance(trap, gaps, W, n)
    h = hashlib.sha256()
    h.update(('p cnf %d %d\n' % (nv, len(clauses))).encode())
    for cl in clauses:
        h.update((' '.join(map(str, cl)) + ' 0\n').encode())
    from pysat.solvers import Cadical195
    with Cadical195(bootstrap_with=clauses) as sol:
        sol.conf_budget(budget)
        r = sol.solve_limited()
        status = 'SAT' if r else ('UNSAT' if r is False else 'UNKNOWN')
        replay = None
        if r:
            model = set(v for v in sol.get_model() if v > 0)
            row = [1 if var[(0, x)] in model else 0 for x in range(1, W + 1)]
            replay = True
            for t in range(T + 1):
                if t % 2 == 0:
                    code = sum(row[i] << i for i in range(16))
                    if row[0] != int(gate[t // 2]) or code in trapset:
                        replay = False
                if t == T:
                    break
                east = 1 if var[(t, W + 1)] in model else 0
                ext = [t % 2] + row + [east]
                row = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, W + 1)]
    return status, replay, S, h.hexdigest()


def state(trap, trapset, gaps, W, kmax, nmax, budget, log):
    """alive, dead or open at W, with the evidence."""
    K = 1
    while K <= kmax:
        t0 = time.time()
        status, ok, _ = periodic(gaps, K, W, budget)
        log(dict(columns=W, test='closed walk', copies=K, status=status, replays=ok, seconds=round(time.time() - t0, 1)))
        if status == 'SAT' and ok:
            return 'alive', K
        if status == 'SAT':
            raise SystemExit('a model that does not replay')
        K += 1
    n = 2
    while n <= nmax:
        t0 = time.time()
        status, replay, S, digest = finite(trap, trapset, gaps, W, n, budget)
        log(dict(columns=W, test='finite strip', copies=n, samples=S, status=status, replays=replay,
                 cnf_sha256=digest, seconds=round(time.time() - t0, 1)))
        if status == 'UNSAT':
            return 'dead', n
        if status == 'SAT' and not replay:
            raise SystemExit('a model that does not replay')
        n *= 2
    return 'open', None


def main():
    kit, mode = sys.argv[1], sys.argv[2]
    trap = [int(c) for c in L.trap_codes(kit)]
    trapset = set(trap)

    def log(d):
        print(json.dumps(d))
        sys.stdout.flush()

    if mode == 'finite':
        gaps, W = word(sys.argv[3]), int(sys.argv[4])
        for n in map(int, sys.argv[5:]):
            t0 = time.time()
            status, replay, S, digest = finite(trap, trapset, gaps, W, n, 20_000_000)
            log(dict(word=sys.argv[3], gaps=gaps, columns=W, copies=n, samples=S, status=status, replays=replay,
                     cnf_sha256=digest, seconds=round(time.time() - t0, 1)))
    elif mode == 'periodic':
        gaps, K = word(sys.argv[3]), int(sys.argv[4])
        for W in map(int, sys.argv[5:]):
            t0 = time.time()
            status, ok, _ = periodic(gaps, K, W, 20_000_000)
            log(dict(word=sys.argv[3], gaps=gaps, columns=W, copies=K, status=status, replays=ok,
                     seconds=round(time.time() - t0, 1)))
    elif mode == 'death':
        gaps, lo, hi = word(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5])
        kmax = int(sys.argv[6]) if len(sys.argv) > 6 else 3
        nmax = int(sys.argv[7]) if len(sys.argv) > 7 else 16
        budget = int(sys.argv[8]) if len(sys.argv) > 8 else 20_000_000
        seen = {}

        def at(W):
            if W not in seen:
                seen[W] = state(trap, trapset, gaps, W, kmax, nmax, budget, log)
            return seen[W][0]
        alive, dead, opened = None, None, []
        if at(lo) == 'alive':
            alive = lo
        if at(hi) == 'dead':
            dead = hi
        elif seen[hi][0] == 'alive':
            alive = hi
        a, d = (alive if alive is not None else lo), (dead if dead is not None else hi)
        while alive is not None and dead is not None and d - a > 1:
            m = (a + d) // 2
            s = at(m)
            if s == 'alive':
                a = alive = m
            elif s == 'dead':
                d = dead = m
            else:                                       # open: close in from the dead side, then stop
                opened.append(m)
                m2 = (m + d) // 2
                while m2 > m and m2 < d and at(m2) == 'dead':
                    d = dead = m2
                    m2 = (m + d) // 2
                break
        log(dict(word=sys.argv[3], gaps=gaps, samples_per_copy=sum(map(int, gaps)), last_alive=alive,
                 first_dead=dead, open_widths=sorted(opened), closed_walk_copies_tried=kmax,
                 finite_copies_tried=nmax, evidence={str(W): list(v) for W, v in sorted(seen.items())}))
    elif mode == 'witness':
        gaps, K, W, out = word(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]), sys.argv[6]
        status, ok, rows = periodic(gaps, K, W, 50_000_000)
        log(dict(word=sys.argv[3], columns=W, copies=K, status=status, replays=ok))
        if rows:
            with open(out, 'w') as f:
                for row in rows:
                    f.write(''.join(map(str, row)) + '\n')
    else:
        raise SystemExit('unknown mode')


if __name__ == '__main__':
    main()
