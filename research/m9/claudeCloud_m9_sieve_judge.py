#!/usr/bin/env python3
"""claudeCloud_m9_sieve_judge.py: pull M9 (ledger K60). SAT judges every candidate of the sieve.

The solver call is claudeCloud_m9_sat_census.py's, imported unchanged (claudeM5's builder; every SAT model replayed
cell by cell; UNSAT is COMPUTED until a certifying host checks it). For each candidate word:
    1. P = 20;
    2. if SAT there, P = 40;
    3. if UNSAT at either, the first forbidden delay is found by bisection between the last SAT delay known and
       the first UNSAT delay known. This uses two facts: a witness at delay P is a witness at every smaller delay
       (start counting one sample later), and UNSAT at P holds at every larger P (the trap is closed).
Answers already in the record (the JSONL files of K53 to K56) are reused, never solved again. Every new answer is
appended to OUT.jsonl at once, so the run can be stopped and started again.

    python3 claudeCloud_m9_sieve_judge.py KITFILE CANDIDATES.json OUT.jsonl PROCS MAXSAMPLES [KNOWN.jsonl ...]
Candidates whose word lasts more than MAXSAMPLES samples are listed as not run.
"""
import json, multiprocessing, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import claudeCloud_m9_sat_census as C      # noqa: E402

BUDGET = 20000000


def init(kit):
    C.KIT = kit


def main():
    kit, candfile, out, procs, maxs = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), int(sys.argv[5])
    cands = json.load(open(candfile))
    run = [c for c in cands if c['samples'] <= maxs]
    skipped = [c for c in cands if c['samples'] > maxs]
    spec = lambda c: 'R:' + c['word'].replace(',', '.')
    known = {}
    for path in sys.argv[6:] + ([out] if os.path.exists(out) else []):
        for line in open(path):
            d = json.loads(line)
            if d['status'] in ('SAT', 'UNSAT'):
                known[(d['spec'], d['P'])] = d['status']
    C.KIT = kit

    def solve(jobs, label):
        jobs = [j for j in jobs if j not in known]
        if not jobs:
            return
        print('%s: %d instances' % (label, len(jobs)), flush=True)
        size = {spec(c): c['samples'] for c in run}
        jobs.sort(key=lambda j: size[j[0]] + j[1])
        with multiprocessing.Pool(procs, initializer=init, initargs=(kit,)) as pool, open(out, 'a') as f:
            for res in pool.imap_unordered(C.one, [(s, P, BUDGET) for s, P in jobs]):
                f.write(json.dumps(res) + '\n'); f.flush()
                if res['status'] in ('SAT', 'UNSAT'):
                    known[(res['spec'], res['P'])] = res['status']
                else:
                    known[(res['spec'], res['P'])] = 'UNKNOWN'
                assert res['status'] != 'SAT' or res['verified'], 'a SAT witness failed its replay: ' + res['spec']
                print('   %-16s P = %3d: %-7s %4d samples, %7d variables, %7.1f s' % (
                    res['spec'], res['P'], res['status'], res['samples'], res['variables'], res['solve_seconds']), flush=True)

    solve([(spec(c), 20) for c in run], 'stage 1, P = 20')
    solve([(spec(c), 40) for c in run if known.get((spec(c), 20)) == 'SAT'], 'stage 2, P = 40')
    for rnd in range(1, 8):                               # bisection of each onset
        jobs = []
        for c in run:
            s = spec(c)
            sat = [P for (x, P), st in known.items() if x == s and st == 'SAT']
            uns = [P for (x, P), st in known.items() if x == s and st == 'UNSAT']
            unk = [P for (x, P), st in known.items() if x == s and st == 'UNKNOWN']
            if not uns:
                continue
            lo, hi = max(sat, default=-1), min(uns)
            assert lo < hi, 'SAT at a delay after an UNSAT delay: ' + s
            if hi - lo > 1 and (lo + hi) // 2 not in unk:
                jobs.append((s, (lo + hi) // 2))
        if not jobs:
            break
        solve(jobs, 'bisection round %d' % rnd)
    print('\nword | expected late | verdict')
    laws = 0
    for c in cands:
        s = spec(c)
        sat = sorted(P for (x, P), st in known.items() if x == s and st == 'SAT')
        uns = sorted(P for (x, P), st in known.items() if x == s and st == 'UNSAT')
        unk = sorted(P for (x, P), st in known.items() if x == s and st == 'UNKNOWN')
        if c['samples'] > maxs and not sat and not uns:
            v = 'not run (%d samples)' % c['samples']
        elif uns:
            laws += 1
            lo = max(sat, default=None)
            v = 'LAW: UNSAT from P = %d' % min(uns) + (' (SAT through %d)' % lo if lo is not None and lo == min(uns) - 1 else
                                                      (' (UNSAT at 0)' if min(uns) == 0 else ' (onset between %s and %d)' % (lo, min(uns))))
        elif sat:
            v = 'possible: SAT through P = %d' % max(sat)
        else:
            v = 'undecided'
        if unk:
            v += '; budget spent at P = %s' % unk
        print('(%s) | %.0f | %s' % (c['word'], c['expected'], v))
    print('\n%d candidates; %d laws; %d not run' % (len(cands), laws, sum(1 for c in skipped)))


if __name__ == '__main__':
    main()
