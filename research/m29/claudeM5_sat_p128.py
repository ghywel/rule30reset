#!/usr/bin/env python3
"""Pull M29 (M44): SAT probe of the dyadic doubling lemma at source period 128, gaps 5-64.

The lemma (M43): every whole white interval [A, B] whose source D(A-1) has dyadic least period P and odd parity
(a doubling: D(A+1) antiperiodic with half-period P) has a reset in every tick. M43 decided it at P = 64 for gaps
31-67 (kissat and CaDiCaL) and 69, 71, 73 (kissat). This probe takes P = 128 (orbit period T = 256).
Encoding: M43's, imported unchanged from claudeM5_sat_gap64.py (build, check_witness), so the clauses are the ones
already reviewed there. Columns d_0 .. d_g of T ticks; d_0 = d_g = 0, d_2 = 1, the band map at j = 2..g, every
interior column nonzero (a whole interval), d_1(t + 128) = not d_1(t) (forces a source of least period exactly 128
with odd parity), and (family odd) a reset-free row at tick 0 by the run-residue automaton.
Families (T = 256):
  odd:   the doubling with tick 0 reset-free. A SAT model is a counterexample to the lemma at P = 128.
  oddr:  the doubling without the reset condition: does a doubling of source period 128 return to white at gap g?
Solvers: each instance is a separate job for kissat and for CaDiCaL run with --check (its internal DRAT and LRAT
checkers verify every derived clause, so a CaDiCaL UNSAT comes with an internally checked proof). Every SAT model is
decoded and checked by plain simulation; a doubling witness is followed backwards for rootedness.
Jobs: odd at gaps 31-64 under both solvers; oddr at gaps 31-45 under kissat; the cross-check, odd and oddr at gaps
5-30 under kissat. Expected from M42's dump of every cyclic component of G_n (n <= 30), by claudeM5_p128_expect.py:
at half-period 128 no closed walk doubles, with or without a reset-free row (the same computation finds A0's
doublings at half-periods 1 and 2, gaps 5 and 21), so both families are UNSAT at every gap 5-30.
Controls (each under both solvers):
  M43's seven controls, unchanged (small T; they exercise the anti and reset-free clauses and both A0 doublings);
  even at T = 256, gap 32, reset-free: SAT (M43's period-64 witness, repeated four times, is a model);
  even at T = 256, gap 8, reset-free: SAT (the census's gap-8 intervals have period dividing 64);
  open at T = 256, gap 40: the odd clauses without d_g = 0 and without the reset condition: SAT, and the model's
    source has least period 128 and odd parity (the anti clauses admit a genuine period-128 doubling source).
Predictions (written before the run):
  1. Every control has its expected status under both solvers, and every control model verifies (95%).
  2. The cross-check: odd and oddr UNSAT at every gap 5-30 (95%).
  3. No SAT in odd at gaps 31-64 (85%).
  4. No SAT in oddr at gaps 31-45 (75%).
  5. kissat and CaDiCaL never disagree (99%).
  6. At least 23 of the 34 odd gaps 31-64 (two thirds) are decided by at least one solver within the timeout (55%).
  7. CaDiCaL with --check decides odd at every gap 31-47 (70%).
Kill: a verified SAT model in odd at any gap (a reset-free dyadic doubling at source period 128: the lemma is false
at P = 128 and R44's route to every k needs the rootedness check on that model).
Usage: claudeM5_sat_p128.py WORKDIR OUTFILE [--timeout 1800] [--jobs 10]
"""
import argparse, json, os, re, subprocess, sys, threading, time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from claudeM5_sat_gap64 import build, write_cnf, check_witness    # noqa: E402

T256 = 256


def build_open(g, T):
    """The odd clauses without d_g = 0 and without the reset condition (a positive control for the anti clauses)."""
    nv, cl, X = build(g, T, True, False)
    drop = {-X[g][t] for t in range(T)}
    cl = [c for c in cl if not (len(c) == 1 and c[0] in drop)]
    return nv, cl, X


def check_open(g, T, X, model):
    cols = [[1 if X[j][t] in model else 0 for t in range(T)] for j in range(g + 1)]
    ok = not any(cols[0]) and all(cols[2])
    ok &= all(cols[j][(t + 1) % T] == cols[j - 2][t] ^ (cols[j - 1][t] | cols[j][t])
              for j in range(2, g + 1) for t in range(T))
    ok &= all(cols[1][(t + T // 2) % T] == 1 - cols[1][t] for t in range(T))
    e = [cols[1][(t + 1) % T] ^ cols[1][t] for t in range(T)]
    lp = next(p for p in range(1, T + 1) if T % p == 0 and all(e[i] == e[(i + p) % T] for i in range(T)))
    return {'verified': bool(ok), 'source_least_period': lp, 'source_parity': sum(e[:lp]) % 2}


def solve(solver, path, timeout):
    cmd = {'kissat': ['kissat', '-q', f'--time={timeout}', path],
           'cadical': ['cadical', '-q', '--check', '-t', str(timeout), path]}[solver]
    t0 = time.time()
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout + 60)
        out = p.stdout
    except subprocess.TimeoutExpired:
        return {'status': 'UNKNOWN', 'seconds': round(time.time() - t0, 1)}, None
    st = 'UNKNOWN'
    if re.search(r'^s SATISFIABLE', out, re.M):
        st = 'SAT'
    elif re.search(r'^s UNSATISFIABLE', out, re.M):
        st = 'UNSAT'
    model = None
    if st == 'SAT':
        model = set()
        for line in out.splitlines():
            if line.startswith('v '):
                model.update(int(x) for x in line[2:].split() if x != '0')
    return {'status': st, 'seconds': round(time.time() - t0, 1)}, model


def make_spec(kind, name, g, T, anti, resetfree, expected=None):
    return {'kind': kind, 'family': name, 'gap': g, 'T': T, 'anti': anti, 'resetfree': resetfree,
            'expected': expected}


LOCK = threading.Lock()


def run_job(arg):
    spec, solver, workdir, timeout, log = arg
    if spec['family'] == 'open':
        nv, cl, X = build_open(spec['gap'], spec['T'])
    else:
        nv, cl, X = build(spec['gap'], spec['T'], spec['anti'], spec['resetfree'])
    path = os.path.join(workdir, f"{spec['kind']}_{spec['family']}_g{spec['gap']}_T{spec['T']}_{solver}.cnf")
    write_cnf(path, nv, cl)
    r, model = solve(solver, path, timeout)
    os.remove(path)
    res = dict(spec, solver=solver, vars=nv, clauses=len(cl), **r)
    if r['status'] == 'SAT':
        if spec['family'] == 'open':
            res['witness'] = check_open(spec['gap'], spec['T'], X, model)
        else:
            res['witness'] = check_witness(spec['gap'], spec['T'], spec['anti'], spec['resetfree'], X, model)
    with LOCK:
        with open(log, 'a') as fh:
            fh.write(json.dumps(res) + '\n')
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('workdir')
    ap.add_argument('outfile')
    ap.add_argument('--timeout', type=int, default=1800)
    ap.add_argument('--jobs', type=int, default=10)
    a = ap.parse_args()
    os.makedirs(a.workdir, exist_ok=True)
    log = a.outfile + '.jsonl'
    open(log, 'w').close()
    t0 = time.time()
    both = ('kissat', 'cadical')
    controls = [make_spec('control', 'ctl_odd_nores', 5, 2, True, False, 'SAT'),
                make_spec('control', 'ctl_odd_res', 5, 2, True, True, 'UNSAT'),
                make_spec('control', 'ctl_odd_nores', 21, 4, True, False, 'SAT'),
                make_spec('control', 'ctl_odd_res', 21, 4, True, True, 'UNSAT'),
                make_spec('control', 'ctl_odd_res', 23, 10, True, True, 'SAT'),
                make_spec('control', 'ctl_even_res', 7, 4, False, True, 'SAT'),
                make_spec('control', 'ctl_even_res', 8, 64, False, True, 'SAT'),
                make_spec('control', 'ctl_even_res', 32, T256, False, True, 'SAT'),
                make_spec('control', 'ctl_even_res', 8, T256, False, True, 'SAT'),
                make_spec('control', 'open', 40, T256, True, False, 'SAT')]
    main_jobs = []
    for g in range(64, 30, -1):                      # longest first
        for s in both:
            main_jobs.append((make_spec('main', 'odd', g, T256, True, True), s))
    for g in range(45, 30, -1):
        main_jobs.append((make_spec('main', 'oddr', g, T256, True, False), 'kissat'))
    cross_jobs = []
    for g in range(5, 31):
        cross_jobs.append((make_spec('cross', 'odd', g, T256, True, True, 'UNSAT'), 'kissat'))
        cross_jobs.append((make_spec('cross', 'oddr', g, T256, True, False, 'UNSAT'), 'kissat'))
    jobs = [(c, s) for c in controls for s in both] + main_jobs + cross_jobs
    with ThreadPoolExecutor(max_workers=a.jobs) as ex:
        results = list(ex.map(run_job, [(sp, s, a.workdir, a.timeout, log) for sp, s in jobs]))
    ctl = [r for r in results if r['kind'] == 'control']
    cross = [r for r in results if r['kind'] == 'cross']
    main_res = [r for r in results if r['kind'] == 'main']

    def status_of(fam, g):
        sts = {r['status'] for r in main_res if r['family'] == fam and r['gap'] == g} - {'UNKNOWN'}
        return 'CONFLICT' if len(sts) > 1 else (sts.pop() if sts else 'UNKNOWN')
    odd_status = {g: status_of('odd', g) for g in range(31, 65)}
    oddr_status = {g: status_of('oddr', g) for g in range(31, 46)}
    sat_models = [r for r in results if r['status'] == 'SAT']
    ctl_ok = all(r['status'] == r['expected'] for r in ctl)
    ctl_ok &= all(r['witness']['verified'] for r in ctl if r['status'] == 'SAT')
    ctl_ok &= all(r['witness']['source_least_period'] == 128 and r['witness']['source_parity'] == 1
                  for r in ctl if r['family'] == 'open' and r['status'] == 'SAT')
    cad = {r['gap']: r['status'] for r in main_res if r['family'] == 'odd' and r['solver'] == 'cadical'}
    summary = {
        '1_controls_ok': ctl_ok,
        '2_cross_check_unsat_5_30': all(r['status'] == 'UNSAT' for r in cross),
        'cross_check_not_unsat': [(r['family'], r['gap'], r['status']) for r in cross if r['status'] != 'UNSAT'],
        '3_no_odd_sat_31_64': all(s != 'SAT' for s in odd_status.values()),
        '4_no_oddr_sat_31_45': all(s != 'SAT' for s in oddr_status.values()),
        '5_no_conflict': 'CONFLICT' not in odd_status.values(),
        '6_odd_decided_31_64': sum(s in ('SAT', 'UNSAT') for s in odd_status.values()),
        '7_cadical_decides_31_47': all(cad[g] in ('SAT', 'UNSAT') for g in range(31, 48)),
        'odd_status': odd_status, 'oddr_status': oddr_status,
        'odd_decided_by_both': [g for g in range(31, 65)
                                if all(r['status'] != 'UNKNOWN' for r in main_res
                                       if r['family'] == 'odd' and r['gap'] == g)],
        'all_sat_models_verified': all(r['witness']['verified'] for r in sat_models),
        'kill_odd_sat': [g for g, s in odd_status.items() if s == 'SAT'] +
                        [r['gap'] for r in cross if r['family'] == 'odd' and r['status'] == 'SAT'],
        'seconds': round(time.time() - t0, 1)}
    with open(a.outfile, 'w') as fh:
        json.dump({'summary': summary, 'controls': ctl, 'cross': cross, 'instances': main_res}, fh, indent=1)
    print(json.dumps(summary))


if __name__ == '__main__':
    main()
