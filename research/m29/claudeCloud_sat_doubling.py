#!/usr/bin/env python3
"""claudeCloud_sat_doubling.py: SAT test of white intervals on a Rule 30 left-edge strip (pull M29; K2).

An independent encoding, written from the definitions in R38-R44 and M41-M43, not from claudeM5's
claudeM5_sat_gap64.py.

Setting. Wheels are left diagonals numbered inward; D_j(t+1) = D_(j-2)(t) XOR (D_(j-1)(t) OR D_j(t)). A white
interval of gap n runs from a permanently white wheel A to the next permanently white wheel B = A + n. Put A = 0.
The variables are x[t][j] = D_j(t) for the interior wheels j = 1..n-1 and the T ticks of one period; D_0 = D_n = 0.
The source D_(A-1) is not a variable: D_1(t+1) = D_(-1)(t) XOR D_1(t), so any first child is driven by exactly one
source, b(t) = D_1(t) XOR D_1(t+1).

Constraints:
  dynamics    x[t+1][j] = x[t][j-2] XOR (x[t][j-1] OR x[t][j]) for j = 2..n, t mod T (j = n says D_(n-2) = D_(n-1));
  black A+2   x[t][2] = 1 (implied by the rest, since D_2(t+1) = D_1(t) OR D_2(t) and D_1 is not all white);
  whole       every interior wheel is black at some tick;
  doubling    (families odd, oddr) T = 2P and x[t+P][1] = NOT x[t][1]: the source has period P and odd weight,
              hence least period exactly P when P is a power of two, and the first child doubles the clock;
  reset-free  (families odd, even) the row at tick 0 has no maximal black run of length 1 mod 3 in A..B.
Families: even (period T = Q), odd (period 2P, antiperiodic first child), oddr (odd with no reset condition).

Every model is decoded and checked by plain simulation (check_orbit), independently of the clauses.

  python3 claudeCloud_sat_doubling.py solve --family odd --half 64 --gap 68 --timeout 3600 [--solver cadical195]
  python3 claudeCloud_sat_doubling.py check WITNESS.json      # check an orbit given as rows of 0/1 strings
  python3 claudeCloud_sat_doubling.py run QUEUE.json OUT.jsonl --workers 4   # a frozen batch, resumable
"""
import argparse, hashlib, json, multiprocessing as mp, os, sys, time


# ----------------------------------------------------------------------------------------------------------------
# The encoding

class CNF:
    def __init__(self):
        self.n = 0
        self.clauses = []

    def var(self):
        self.n += 1
        return self.n

    def add(self, lits):
        """Add a clause; literals are ints or Python bools (constants), simplified here."""
        out = []
        for l in lits:
            if l is True:
                return
            if l is False:
                continue
            out.append(l)
        if not out:
            raise ValueError('empty clause: the family is trivially unsatisfiable')
        self.clauses.append(out)


def neg(l):
    return (not l) if isinstance(l, bool) else -l


def encode(family, gap, T, half=None):
    n = gap
    if n < 5:
        raise ValueError('gap must be at least 5')
    c = CNF()
    X = [[None] * (n + 1) for _ in range(T)]
    for t in range(T):
        X[t][0] = False
        X[t][n] = False
        for j in range(1, n):
            X[t][j] = c.var()
    # dynamics y = a XOR (b OR v), as the 8 forbidden input/output combinations
    for t in range(T):
        u = (t + 1) % T
        for j in range(2, n + 1):
            y, a, b, v = X[u][j], X[t][j - 2], X[t][j - 1], X[t][j]
            for a0 in (0, 1):
                for b0 in (0, 1):
                    for v0 in (0, 1):
                        f = a0 ^ (b0 | v0)
                        c.add([neg(a) if a0 else a, neg(b) if b0 else b, neg(v) if v0 else v,
                               y if f else neg(y)])
    for t in range(T):
        c.add([X[t][2]])
    for j in range(1, n):
        c.add([X[t][j] for t in range(T)])
    if family in ('odd', 'oddr'):
        P = half
        assert T == 2 * P
        for t in range(P):
            c.add([X[t][1], X[t + P][1]])
            c.add([neg(X[t][1]), neg(X[t + P][1])])
    if family in ('odd', 'even'):
        reset_free_row(c, [X[0][j] for j in range(n + 1)])
    return c, X


def reset_free_row(c, row):
    """No maximal black run of length 1 mod 3 in row[0..n], with row[0] = row[n] = white.
    A 4-state automaton read left to right, its state in two bits (h, l): W = 00 after a white cell,
    R1 = 01, R2 = 10, R0 = 11 after a black run of length 1, 2, 0 mod 3. A white cell after R1 closes a reset."""
    n = len(row) - 1
    W, R1, R2, R0 = (0, 0), (0, 1), (1, 0), (1, 1)
    black_next = {W: R1, R1: R2, R2: R0, R0: R1}
    white_next = {W: W, R2: W, R0: W}          # R1 then white: rejected
    prev = (False, False)                       # after cell 0, which is white
    for j in range(1, n):
        cur = (c.var(), c.var())
        x = row[j]
        for s in (W, R1, R2, R0):
            # literals true exactly when prev != s
            ne = [neg(prev[0]) if s[0] else prev[0], neg(prev[1]) if s[1] else prev[1]]
            for bit in (0, 1):
                xl = neg(x) if bit else x       # false exactly when the cell has this colour
                if bit == 1:
                    nxt = black_next[s]
                elif s == R1:
                    c.add(ne + [x])             # after R1 the cell must be black
                    continue
                else:
                    nxt = white_next[s]
                for k in (0, 1):
                    c.add(ne + [xl, cur[k] if nxt[k] else neg(cur[k])])
        prev = cur
    # cell n is white: the state before it must not be R1
    c.add([prev[0], neg(prev[1])])


# ----------------------------------------------------------------------------------------------------------------
# The independent check

def runs_ok(row):
    """row: list of 0/1 for wheels A..B. True when no maximal black run has length 1 mod 3."""
    s = ''.join(map(str, row))
    return all(len(r) % 3 != 1 for r in s.split('0') if r)


def least_period(w):
    T = len(w)
    for p in range(1, T + 1):
        if T % p == 0 and all(w[t] == w[(t + p) % T] for t in range(T)):
            return p
    return T


def check_orbit(rows, family, half=None):
    """rows[t] = list of 0/1 for wheels 0..n (A..B) at tick t, one period. Returns (ok, facts)."""
    T, n = len(rows), len(rows[0]) - 1
    errs = []
    for t in range(T):
        r, s = rows[t], rows[(t + 1) % T]
        if r[0] or r[n]:
            errs.append('tick %d: an end wheel is black' % t)
        for j in range(2, n + 1):
            if s[j] != r[j - 2] ^ (r[j - 1] | r[j]):
                errs.append('tick %d wheel %d: dynamics' % (t, j))
        if r[2] != 1:
            errs.append('tick %d: wheel A+2 not black' % t)
    for j in range(1, n):
        if not any(rows[t][j] for t in range(T)):
            errs.append('wheel %d white throughout: interval not whole' % j)
    src = [rows[t][1] ^ rows[(t + 1) % T][1] for t in range(T)]
    facts = {'period': T, 'gap': n, 'source_least_period': least_period(src), 'source_weight': sum(src),
             'reset_free_ticks': [t for t in range(T) if runs_ok(rows[t])]}
    if family in ('odd', 'oddr'):
        P = half
        if any(rows[t + P][1] == rows[t][1] for t in range(P)):
            errs.append('first child not antiperiodic at %d' % P)
        facts['source_weight_per_half'] = sum(src[:P])
    if family in ('odd', 'even') and not runs_ok(rows[0]):
        errs.append('tick 0 has a reset')
    return (not errs), dict(facts, errors=errs[:5])


# ----------------------------------------------------------------------------------------------------------------
# Solving

def cnf_sha(c):
    h = hashlib.sha256()
    h.update(('p cnf %d %d\n' % (c.n, len(c.clauses))).encode())
    for cl in c.clauses:
        h.update((' '.join(map(str, cl)) + ' 0\n').encode())
    return h.hexdigest()


def _child(conn, family, gap, T, half, solver):
    from pysat.solvers import Solver
    c, X = encode(family, gap, T, half)
    conn.send({'vars': c.n, 'clauses': len(c.clauses), 'cnf_sha256': cnf_sha(c)})
    t0 = time.time()
    with Solver(name=solver, bootstrap_with=c.clauses) as s:
        sat = s.solve()
        model = s.get_model() if sat else None
    rows = None
    if sat:
        pos = set(l for l in model if l > 0)
        rows = [[1 if (isinstance(X[t][j], int) and X[t][j] in pos) else 0 for j in range(gap + 1)] for t in range(T)]
    conn.send({'sat': sat, 'solve_seconds': round(time.time() - t0, 2), 'rows': rows})


def solve(family, gap, half=None, period=None, timeout=600, solver='cadical195'):
    """Solve one instance in a spawned child process, killed at `timeout` wall-clock seconds (verdict UNKNOWN).
    The solver binding does not honour interrupts from another thread, so the limit is enforced from outside."""
    ctx = mp.get_context('spawn')
    T = 2 * half if family in ('odd', 'oddr') else period
    res = {'family': family, 'gap': gap, 'half': half, 'period': T, 'solver': solver, 'timeout': timeout}
    here, there = ctx.Pipe(duplex=False)
    p = ctx.Process(target=_child, args=(there, family, gap, T, half, solver))
    t0 = time.time()
    p.start()
    there.close()
    msgs = []
    while len(msgs) < 2:
        left = timeout - (time.time() - t0)
        if left <= 0 or not here.poll(left):
            break
        try:
            msgs.append(here.recv())
        except EOFError:
            break
    if p.is_alive():
        p.kill()
    p.join()
    res['seconds'] = round(time.time() - t0, 2)
    if msgs:
        res.update(msgs[0])
    if len(msgs) < 2:
        res['verdict'] = 'UNKNOWN' if p.exitcode in (None, -9) or res['seconds'] >= timeout else 'ERROR'
        return res
    r = msgs[1]
    res['solve_seconds'] = r['solve_seconds']
    res['verdict'] = 'SAT' if r['sat'] else 'UNSAT'
    if r['sat']:
        ok, facts = check_orbit(r['rows'], family, half)
        res['check'] = 'PASS' if ok else 'FAIL'
        res['facts'] = facts
        res['witness'] = [''.join(map(str, row)) for row in r['rows']]
    return res


def _task(job):
    r = solve(job['family'], job['gap'], job.get('half'), job.get('period'), job['timeout'], job.get('solver', 'cadical195'))
    r['phase'] = job.get('phase')
    return r


def run_queue(queue_path, out_path, workers):
    jobs = json.load(open(queue_path))
    done = set()
    if os.path.exists(out_path):
        for l in open(out_path):
            r = json.loads(l)
            done.add((r['family'], r['gap'], r['period'], r['solver']))
    todo = [j for j in jobs if (j['family'], j['gap'], 2 * j['half'] if j['family'] != 'even' else j['period'],
                                j.get('solver', 'cadical195')) not in done]
    print('%d jobs, %d done, %d to run on %d workers' % (len(jobs), len(jobs) - len(todo), len(todo), workers), flush=True)
    from concurrent.futures import ThreadPoolExecutor, as_completed
    import threading
    lock = threading.Lock()
    with ThreadPoolExecutor(workers) as ex, open(out_path, 'a') as out:
        futs = [ex.submit(_task, j) for j in todo]   # submitted in queue order; each worker takes the next
        for f in as_completed(futs):
            r = f.result()
            with lock:
                out.write(json.dumps(r) + '\n')
                out.flush()
            print('%-5s gap %3d T %3d %-10s %-7s %8.1fs %s' % (r['family'], r['gap'], r['period'], r['solver'],
                  r['verdict'], r['seconds'], r.get('check', '')), flush=True)


def main():
    ap = argparse.ArgumentParser()
    sp = ap.add_subparsers(dest='cmd', required=True)
    p = sp.add_parser('solve')
    p.add_argument('--family', choices=['even', 'odd', 'oddr'], required=True)
    p.add_argument('--gap', type=int, required=True)
    p.add_argument('--half', type=int)
    p.add_argument('--period', type=int)
    p.add_argument('--timeout', type=float, default=600)
    p.add_argument('--solver', default='cadical195')
    p = sp.add_parser('check')
    p.add_argument('witness')
    p.add_argument('--family', default='even')
    p.add_argument('--half', type=int)
    p = sp.add_parser('run')
    p.add_argument('queue')
    p.add_argument('out')
    p.add_argument('--workers', type=int, default=4)
    a = ap.parse_args()
    if a.cmd == 'solve':
        r = solve(a.family, a.gap, a.half, a.period, a.timeout, a.solver)
        print(json.dumps({k: v for k, v in r.items() if k != 'witness'}))
        if 'witness' in r:
            print('\n'.join(r['witness']))
    elif a.cmd == 'check':
        w = json.load(open(a.witness))
        rows = [[int(ch) for ch in s] for s in (w['rows'] if isinstance(w, dict) else w)]
        ok, facts = check_orbit(rows, a.family, a.half)
        print('PASS' if ok else 'FAIL', json.dumps(facts))
    else:
        run_queue(a.queue, a.out, a.workers)


if __name__ == '__main__':
    main()
