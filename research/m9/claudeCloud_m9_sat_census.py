#!/usr/bin/env python3
"""claudeCloud_m9_sat_census.py: pull M9 (ledger K53). A SAT census of short RUN WORDS in the gate trap: which words
of two or three closed runs can a right half read once it has been in the trap for P samples?

The instance is claudeM5's, unchanged: research/m9/claudeM5_m9_sat.py is imported for the word, the CNF (build), the
DIMACS text whose SHA-256 names the instance, and the cell-by-cell check of every model (verify). A run word
(r1, ..., rk) is the gap word 3 5^r1 3 ... 5^rk 3. UNSAT at P means the word never begins P or more samples after any
right half, finite or not, has entered the trap (the trap is closed, so the answer carries to every later sample).

Solving here is python-sat's CaDiCaL 1.9.5 with a conflict budget (a spent budget is UNKNOWN, never a negative).
  SAT    the model's initial row is simulated cell by cell by claudeM5's verify: it starts in the trap, stays in it,
         and spells the word. Rigorous whatever the solver.
  UNSAT  COMPUTED only: this host has no proof checker. Each instance is named by the SHA-256 of its DIMACS text, so
         that the M5 or the Intel can rebuild it from claudeM5's script and certify it with LRAT.

  python3 claudeCloud_m9_sat_census.py KITFILE OUT.jsonl PROCS BUDGET P SPEC [SPEC ...]
  SPEC: R:r1.r2.r3 (one word), pairs:LO:HI (every pair of runs in LO..HI), triples:LO:HI, or controls
"""
import hashlib
import itertools
import json
import multiprocessing
import os
import sys
import tempfile
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import claudeM5_m9_sat as M      # noqa: E402

KIT = None


def one(job):
    spec, P, budget = job
    from pysat.solvers import Cadical195
    trap = M.trap_codes(KIT)
    word = M.gap_word(spec)
    t0 = time.time()
    cl, vid, nv, info = M.build(trap, word, P)
    with tempfile.NamedTemporaryFile('w+', suffix='.cnf', delete=True) as f:
        M.dimacs(cl, nv, f.name)
        sha = hashlib.sha256(open(f.name, 'rb').read()).hexdigest()
    res = dict(spec=spec, word=word, P=P, samples=info['D'] + 1, variables=nv, clauses=len(cl), cnf_sha=sha,
               solver='python-sat CaDiCaL 1.9.5', budget=budget)
    t1 = time.time()
    with Cadical195(bootstrap_with=cl) as s:
        s.conf_budget(budget)
        r = s.solve_limited()
        res['status'] = {True: 'SAT', False: 'UNSAT', None: 'UNKNOWN'}[r]
        if r:
            w = M.verify(s.get_model(), vid, trap, info, word, P)
            res['verified'] = all(w[k] for k in ('start_in_trap', 'every_sample_window_in_trap', 'word_spelled',
                                                 'solver_cells_agree_with_simulation'))
            res['start_window'] = w['start_window']
            res['initial_row'] = w['initial_row']
    res['build_seconds'] = round(t1 - t0, 1)
    res['solve_seconds'] = round(time.time() - t1, 1)
    return res


def expand(specs):
    out = []
    for sp in specs:
        if sp.startswith('pairs:') or sp.startswith('triples:'):
            kind, lo, hi = sp.split(':')
            k = 2 if kind == 'pairs' else 3
            out += ['R:' + '.'.join(map(str, t)) for t in itertools.product(range(int(lo), int(hi) + 1), repeat=k)]
        else:
            out.append(sp)
    return out


def main():
    global KIT
    KIT, outp, procs, budget, P = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5])
    specs = sys.argv[6:]
    if specs == ['controls']:
        jobs = [('3535353', 0, budget), ('333', 0, budget), ('3555355535553555', 0, budget), ('R:4.4.4.4', 1, budget),
                ('R:4.4.4.4', 2, budget), ('R:4.4.4', 20, budget), ('P:5:4', 0, budget)]
        want = ['UNSAT', 'UNSAT', 'SAT', 'SAT', 'UNSAT', 'SAT', 'SAT']
    else:
        jobs, want = [(sp, P, budget) for sp in expand(specs)], None
    done = set()
    if os.path.exists(outp):
        for line in open(outp):
            d = json.loads(line)
            done.add((d['spec'], d['P']))
    jobs = [j for j in jobs if (j[0], j[1]) not in done] if want is None else jobs
    ok = True
    with multiprocessing.Pool(procs) as pool, open(outp, 'a') as out:
        for i, res in enumerate(pool.imap(one, jobs) if want else pool.imap_unordered(one, jobs)):
            out.write(json.dumps(res) + '\n')
            out.flush()
            line = '%-14s P = %3d: %-7s %4d samples, %7d variables, solve %7.1f s' % (
                res['spec'], res['P'], res['status'], res['samples'], res['variables'], res['solve_seconds'])
            if res['status'] == 'SAT':
                line += '; witness verified: %s' % res['verified']
                ok &= res['verified']
            if want:
                line += '   (M81 and L1614: %s)' % want[i]
                ok &= res['status'] == want[i]
            print(line, flush=True)
    if want:
        print('CONTROLS:', 'PASS' if ok else 'FAIL')


if __name__ == '__main__':
    main()
