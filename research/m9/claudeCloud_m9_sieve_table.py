#!/usr/bin/env python3
"""claudeCloud_m9_sieve_table.py: pull M9 (ledger K65). Reads the sieve's table from the answers saved so far.
It solves nothing. The reading rules are the judge's (claudeCloud_m9_sieve_judge.py): a word is a LAW when some
delay is UNSAT, with its first forbidden delay bracketed by the largest SAT delay and the smallest UNSAT delay;
it is POSSIBLE through its largest SAT delay otherwise.

    python3 claudeCloud_m9_sieve_table.py CANDIDATES.json MAXSAMPLES ANSWERS.jsonl [ANSWERS.jsonl ...]

It prints the table, the instances the judge would still solve at delay 40, and the brackets it would still bisect.
"""
import json
import sys


def main():
    cands = json.load(open(sys.argv[1])); maxs = int(sys.argv[2])
    known = {}
    for path in sys.argv[3:]:
        for line in open(path):
            d = json.loads(line)
            if d['status'] in ('SAT', 'UNSAT'):
                known[(d['spec'], d['P'])] = d['status']
    spec = lambda c: 'R:' + c['word'].replace(',', '.')
    laws, possible, left40, notrun, bisect = [], [], [], [], []
    print('word | runs | samples | expected | verdict')
    for c in cands:
        s = spec(c)
        sat = sorted(P for (x, P), st in known.items() if x == s and st == 'SAT')
        uns = sorted(P for (x, P), st in known.items() if x == s and st == 'UNSAT')
        lo = max(sat, default=-1)
        if c['samples'] > maxs and not sat and not uns:
            v = 'not run (%d samples)' % c['samples']; notrun.append(c['word'])
        elif uns:
            hi = min(uns); laws.append(c['word'])
            assert lo < hi, 'SAT at a delay after an UNSAT delay: ' + s
            if hi - lo == 1:
                v = 'LAW from delay %d (possible through %d)' % (hi, lo) if lo >= 0 else 'LAW from delay 0'
            else:
                v = 'LAW, first forbidden delay in %d..%d' % (lo + 1, hi); bisect.append((c['word'], lo + 1, hi))
        elif sat and lo >= 40:
            v = 'possible through delay %d' % lo; possible.append(c['word'])
        elif sat:
            v = 'possible through delay %d; delay 40 not judged' % lo; left40.append(c['word'])
        else:
            v = 'undecided'
        print('(%s) | %d | %d | %.0f | %s' % (c['word'], c['runs'], c['samples'], c['expected'], v))
    one = lambda ws: sum(1 for w in ws if '1' in w.split(','))
    print('\n%d candidates: %d laws, %d possible through delay 40 or more, %d not judged at delay 40, %d not run'
          % (len(cands), len(laws), len(possible), len(left40), len(notrun)))
    print('with a run of 1: %d of the %d laws, %d of the %d possible, %d of all %d candidates'
          % (one(laws), len(laws), one(possible), len(possible), one([c['word'] for c in cands]), len(cands)))
    print('still to judge at delay 40 (%d): %s' % (len(left40), '; '.join('(%s)' % w for w in left40)))
    print('still to bisect (%d): %s' % (len(bisect), '; '.join('(%s) in %d..%d' % b for b in bisect)))
    print('not run (%d): %s' % (len(notrun), '; '.join('(%s)' % w for w in notrun)))


if __name__ == '__main__':
    main()
