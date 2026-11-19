#!/usr/bin/env python3
"""Pull M29 (M43): SAT probe at source period 64 for whole white intervals of gap 5-96.

Columns d_0 .. d_g of T ticks, bit t of d_j = wheel A + j at tick t (cyclic in t). Constraints:
  d_0 = d_g = 0 (permanent whites A and B = A + g); d_2 = 1 (latched black two beyond A, implied, given as units);
  d_j(t+1) = d_(j-2)(t) xor (d_(j-1)(t) or d_j(t)) for j = 2..g; d_j != 0 for 1 <= j <= g - 1 (a whole interval:
  no interior wheel white at every tick). Column 1 is driven by the free source, d_1(t+1) = e(t) xor d_1(t).
Families (P = 64):
  even:  T = 64, period 64, no condition on d_1. Every 64-periodic whole interval, with tick 0 reset-free.
  odd:   T = 128 with d_1(t + 64) = not d_1(t): a doubling whose source has least period exactly 64; tick 0 reset-free.
  oddr:  the odd family without the reset condition: does a doubling of source period 64 return to white at gap g?
A reset is a closed black run of length 1 mod 3 with both white ends in [A, B]. Tick 0 is no loss: any reset-free
tick can be rotated there. The reset-free row is encoded by a run-residue automaton (one-hot residues 1 and 2).
Encoded from the definitions, not from gptM5's z3 script. Solved by kissat (and CaDiCaL on the controls); every
model is decoded and checked by plain simulation, and a doubling witness is followed backwards for rootedness.
Controls (each solved by both solvers): gap 5, T = 2 doubling: SAT without the reset condition (A0's 2->7), UNSAT
with it; gap 21, T = 4 doubling: SAT without, UNSAT with (A0's 7->28); gap 23, T = 10 doubling, reset-free: SAT (M42's
odd-period witness); gap 7, T = 4 and gap 8, T = 64, reset-free: SAT (the census's intervals).
Cross-check at gaps 5-30 against M42's graph: even SAT exactly at gaps 7, 8, 14, 16; odd and oddr UNSAT everywhere.
Predictions (written before the run): every control and every decided cross-check agrees (95%); at gaps 31-96 no
family has a SAT instance (70%); at least half of the gap-31-96 instances are decided within the timeout (60%).
Kill: a checked SAT witness in family odd at any gap (a reset-free dyadic doubling), or in even at gap >= 31 (a
counterexample to (G30)).
Usage: claudeM5_sat_gap64.py WORKDIR OUTFILE [--timeout 300] [--jobs 10] [--gmax 96]
"""
import argparse, json, os, re, subprocess, time
from concurrent.futures import ThreadPoolExecutor


def build(g, T, anti, resetfree):
    nv = 0
    X = [[0] * T for _ in range(g + 1)]
    for j in range(g + 1):
        for t in range(T):
            nv += 1
            X[j][t] = nv
    cl = []
    for t in range(T):
        cl.append([-X[0][t]])
        cl.append([-X[g][t]])
        cl.append([X[2][t]])
    for j in range(2, g + 1):                        # y = a xor (b or c)
        for t in range(T):
            a, b, c, y = X[j - 2][t], X[j - 1][t], X[j][t], X[j][(t + 1) % T]
            for va in (0, 1):
                for vb in (0, 1):
                    for vc in (0, 1):
                        f = va ^ (vb | vc)
                        cl.append([(-a if va else a), (-b if vb else b), (-c if vc else c), (y if f else -y)])
    for j in range(1, g):
        cl.append([X[j][t] for t in range(T)])
    if anti:
        h = T // 2
        for t in range(h):
            p, q = X[1][t], X[1][t + h]
            cl.append([p, q])
            cl.append([-p, -q])
    if resetfree:
        r = [X[k][0] for k in range(g + 1)]
        O, W = [0] * (g + 1), [0] * (g + 1)
        for k in range(g + 1):
            nv += 1; O[k] = nv
            nv += 1; W[k] = nv
        cl.append([-O[0]]); cl.append([-W[0]])
        for k in range(1, g + 1):
            cl += [[-O[k], r[k]], [-W[k], r[k]],
                   [-r[k], O[k - 1], W[k - 1], O[k]], [-O[k], -O[k - 1]], [-O[k], -W[k - 1]],
                   [-r[k], -O[k - 1], W[k]], [-W[k], O[k - 1]],
                   [-O[k - 1], r[k]]]                # no residue-1 run closes at k
    return nv, cl, X


def write_cnf(path, nv, cl):
    with open(path, 'w') as fh:
        fh.write(f'p cnf {nv} {len(cl)}\n')
        for c in cl:
            fh.write(' '.join(map(str, c)) + ' 0\n')


def solve(solver, path, timeout):
    cmd = {'kissat': ['kissat', '-q', f'--time={timeout}', path],
           'cadical': ['cadical', '-q', '-t', str(timeout), path]}[solver]
    t0 = time.time()
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout + 30)
        out = p.stdout
    except subprocess.TimeoutExpired:
        return {'status': 'UNKNOWN', 'seconds': round(time.time() - t0, 1)}
    st = 'UNKNOWN'
    if re.search(r'^s SATISFIABLE', out, re.M):
        st = 'SAT'
    elif re.search(r'^s UNSATISFIABLE', out, re.M):
        st = 'UNSAT'
    model = set()
    if st == 'SAT':
        for line in out.splitlines():
            if line.startswith('v '):
                model.update(int(x) for x in line[2:].split() if x != '0')
    return {'status': st, 'seconds': round(time.time() - t0, 1), 'model': model}


def check_witness(g, T, anti, resetfree, X, model):
    cols = [[1 if X[j][t] in model else 0 for t in range(T)] for j in range(g + 1)]
    ok = not any(cols[0]) and not any(cols[g]) and all(cols[2])
    ok &= all(cols[j][(t + 1) % T] == cols[j - 2][t] ^ (cols[j - 1][t] | cols[j][t])
              for j in range(2, g + 1) for t in range(T))
    ok &= all(any(cols[j]) for j in range(1, g))
    if anti:
        ok &= all(cols[1][(t + T // 2) % T] == 1 - cols[1][t] for t in range(T))
    rows = [''.join(str(cols[j][t]) for j in range(g + 1)) for t in range(T)]
    free = [t for t in range(T) if not re.search(r'01(?:111)*0', rows[t])]
    if resetfree:
        ok &= 0 in free
    e = [cols[1][(t + 1) % T] ^ cols[1][t] for t in range(T)]
    lp = next(p for p in range(1, T + 1) if T % p == 0 and all(e[i] == e[(i + p) % T] for i in range(T)))
    period = next(p for p in range(1, T + 1) if T % p == 0 and all(rows[t] == rows[(t + p) % T] for t in range(T)))
    # backwards from (D(A-1), D(A)) = (e, 0): rooted if it reaches two white wheels
    x, y, rooted = e[:], [0] * T, None
    seen = set()
    for s in range(200000):
        prev = [y[(t + 1) % T] ^ (x[t] | y[t]) for t in range(T)]
        x, y = prev, x
        if not any(x) and not any(y):
            rooted = s + 1
            break
        key = (tuple(x), tuple(y))
        if key in seen:
            rooted = -1
            break
        if s < 50000:
            seen.add(key)
    return {'verified': bool(ok), 'reset_free_ticks': free, 'source_least_period': lp,
            'source_parity': sum(e[:lp]) % 2, 'orbit_period': period, 'rooted': rooted,
            'rows': rows if T <= 16 else rows[:4]}


def instance(args):
    name, g, T, anti, resetfree, solvers, workdir, timeout = args
    nv, cl, X = build(g, T, anti, resetfree)
    path = os.path.join(workdir, f'{name}_g{g}_T{T}.cnf')
    write_cnf(path, nv, cl)
    res = {'family': name, 'gap': g, 'T': T, 'vars': nv, 'clauses': len(cl)}
    for s in solvers:
        r = solve(s, path, timeout)
        model = r.pop('model', None)
        res[s] = r
        if r['status'] == 'SAT':
            res[s + '_witness'] = check_witness(g, T, anti, resetfree, X, model)
    os.remove(path)
    sts = {res[s]['status'] for s in solvers} - {'UNKNOWN'}
    res['status'] = 'CONFLICT' if len(sts) > 1 else (sts.pop() if sts else 'UNKNOWN')
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('workdir')
    ap.add_argument('outfile')
    ap.add_argument('--timeout', type=int, default=300)
    ap.add_argument('--jobs', type=int, default=10)
    ap.add_argument('--gmax', type=int, default=96)
    a = ap.parse_args()
    os.makedirs(a.workdir, exist_ok=True)
    t0 = time.time()
    both = ('kissat', 'cadical')
    controls = [('ctl_odd_nores', 5, 2, True, False, 'SAT'), ('ctl_odd_res', 5, 2, True, True, 'UNSAT'),
                ('ctl_odd_nores', 21, 4, True, False, 'SAT'), ('ctl_odd_res', 21, 4, True, True, 'UNSAT'),
                ('ctl_odd_res', 23, 10, True, True, 'SAT'), ('ctl_even_res', 7, 4, False, True, 'SAT'),
                ('ctl_even_res', 8, 64, False, True, 'SAT')]
    jobs = [(c[0], c[1], c[2], c[3], c[4], both, a.workdir, a.timeout) for c in controls]
    fam = {'even': (64, False, True), 'odd': (128, True, True), 'oddr': (128, True, False)}
    for g in range(5, a.gmax + 1):
        for name, (T, anti, rf) in fam.items():
            jobs.append((name, g, T, anti, rf, ('kissat',), a.workdir, a.timeout))
    with ThreadPoolExecutor(max_workers=a.jobs) as ex:
        results = list(ex.map(instance, jobs))
    ctl = results[:len(controls)]
    main_res = results[len(controls):]
    for r, c in zip(ctl, controls):
        r['expected'] = c[5]
    expect_even_sat = {7, 8, 14, 16}
    cross = [r for r in main_res if r['gap'] <= 30]
    def expected(r):
        if r['family'] == 'even':
            return 'SAT' if r['gap'] in expect_even_sat else 'UNSAT'
        return 'UNSAT'
    cross_ok = all(r['status'] in (expected(r), 'UNKNOWN') for r in cross)
    new = [r for r in main_res if r['gap'] >= 31]
    witnesses = [r for r in main_res if r['status'] == 'SAT']
    summary = {
        'controls_ok': all(r['status'] == r['expected'] and
                           all(r[s]['status'] == r['expected'] for s in both) for r in ctl),
        'controls_witnesses_verified': all(r[s + '_witness']['verified'] for r in ctl for s in both
                                           if r[s]['status'] == 'SAT'),
        'cross_check_agrees': cross_ok,
        'cross_check_undecided': [(r['family'], r['gap']) for r in cross if r['status'] == 'UNKNOWN'],
        'new_sat': [(r['family'], r['gap']) for r in new if r['status'] == 'SAT'],
        'new_decided': sum(r['status'] != 'UNKNOWN' for r in new), 'new_total': len(new),
        'new_unknown': [(r['family'], r['gap']) for r in new if r['status'] == 'UNKNOWN'],
        'all_witnesses_verified': all(r['kissat_witness']['verified'] for r in witnesses),
        'kill_odd_sat': [r['gap'] for r in main_res if r['family'] == 'odd' and r['status'] == 'SAT'],
        'kill_even_sat_31_up': [r['gap'] for r in new if r['family'] == 'even' and r['status'] == 'SAT'],
        'seconds': round(time.time() - t0, 1)}
    with open(a.outfile, 'w') as fh:
        json.dump({'summary': summary, 'controls': ctl, 'instances': main_res}, fh, indent=1)
    print(json.dumps(summary))


if __name__ == '__main__':
    main()
