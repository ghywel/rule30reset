#!/usr/bin/env python3
"""claudeM5_m9_core.py: pull M9. Where do M81's two certified exclusions live? Minimal unsatisfiable cores of the
two instances, grouped first by column, then by cell, to find a reason short enough to write by hand.

The instances are M80's (claudeM5_m9_sat.py, imported unchanged): the five-run law, (55553)^5 at P = 0, and the
four-run law, 3(55553)^4 at P = 2. Every clause belongs to one group:
  rule j   the clauses defining the cells of column j (x[tau+1][j] from x[tau][j-1], x[tau][j], x[tau][j+1]);
  trap     the selectors and their cell clauses (the window at tau = 0 is a trap window);
  sample s the unit fixing column 1 at sample s.
Each group gets an assumption literal. Deletion over groups, from the widest column inward, gives a minimal set of
columns, then of samples, then whether the trap is needed. Then, inside the kept columns, deletion over single
cells (each cell's defining clauses) gives a minimal set of cells, started from the solver's own core.

  python3 claudeM5_m9_core.py KITFILE OUTDIR five|four|control3535353|control333
Writes OUTDIR/core-<name>.json: the kept columns, samples, trap flag, the kept cells as (tau, j), and their count.
"""
import importlib.util
import json
import pathlib
import sys
import time

from pysat.solvers import Cadical195

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('m9sat', HERE / 'claudeM5_m9_sat.py')
S = importlib.util.module_from_spec(spec)
spec.loader.exec_module(S)

CASES = {'five': ('55553' * 5, 0), 'four': ('3' + '55553' * 4, 2),
         'control3535353': ('3535353', 0), 'control333': ('333', 0)}   # controls: dead in the 18-column lift; in the trap


def groups(trap, word, P):
    """The M80 clauses, each tagged: ('rule', tau+1, j), ('trap',), ('sample', s)."""
    cl, vid, nv, info = S.build(trap, word, P)
    inv = {v: k for k, v in vid.items()}
    tags = []
    T, M = info['T'], info['M']
    nrule = 0
    for tau in range(T):
        for j in range(1, M - tau):
            n = 4 if j == 1 else 8
            tags += [('rule', tau + 1, j)] * n
            nrule += n
    wh = info['heads']
    tags += [('sample', P + s) for s in range(len(wh))]
    tags += [('trap',)] * (len(cl) - len(tags))
    assert len(tags) == len(cl)
    return cl, tags, nv, info


class Probe:
    def __init__(self, cl, tags, nv, key):
        """key(tag) -> group name; one assumption literal per group."""
        self.names = sorted(set(key(t) for t in tags), key=str)
        self.lit = {g: nv + 1 + i for i, g in enumerate(self.names)}
        self.s = Cadical195()
        for c, t in zip(cl, tags):
            self.s.add_clause(c + [-self.lit[key(t)]])
        self.calls = 0

    def unsat(self, keep):
        self.calls += 1
        return not self.s.solve(assumptions=[self.lit[g] for g in keep])

    def core(self, keep):
        assert self.unsat(keep)
        back = {v: g for g, v in self.lit.items()}
        return [back[x] for x in self.s.get_core()]

    def minimise(self, keep, order):
        """Deletion: drop each group in `order` if the rest stays UNSAT."""
        keep = list(keep)
        for g in order:
            if g in keep:
                trial = [x for x in keep if x != g]
                if self.unsat(trial):
                    keep = trial
        return keep


def run(kitfile, outdir, name):
    trap = S.trap_codes(kitfile)
    word, P = CASES[name]
    t0 = time.time()
    cl, tags, nv, info = groups(trap, word, P)
    out = {'name': name, 'word': word, 'P': P, 'samples': info['D'] + 1, 'clauses': len(cl), 'variables': nv}

    # 1. columns, samples, trap
    colkey = lambda t: ('rule', t[2]) if t[0] == 'rule' else t
    pr = Probe(cl, tags, nv, colkey)
    allg = list(pr.names)
    assert pr.unsat(allg), 'the full instance is not UNSAT'
    start = pr.core(allg)
    out['solver_core_groups'] = len(start)
    cols = sorted([g for g in start if g[0] == 'rule'], key=lambda g: -g[1])
    keep = pr.minimise(start, cols)
    samples = sorted([g for g in keep if g[0] == 'sample'], key=lambda g: g[1])
    keep = pr.minimise(keep, samples)
    keep = pr.minimise(keep, [('trap',)])
    out['columns'] = sorted(g[1] for g in keep if g[0] == 'rule')
    out['samples_needed'] = sorted(g[1] for g in keep if g[0] == 'sample')
    out['trap_needed'] = ('trap',) in keep
    out['group_calls'] = pr.calls
    print('%s: %s at P = %d; minimal columns %s; samples needed %d of %d (%s); trap needed: %s; %.0f s' % (
        name, word, P, out['columns'], len(out['samples_needed']), info['D'] + 1 - P,
        ','.join(map(str, out['samples_needed'])), out['trap_needed'], time.time() - t0), flush=True)

    # 2. cells inside the kept columns, with the kept samples and trap
    cols_kept = set(out['columns'])
    smp_kept = set(out['samples_needed'])

    def cellkey(t):
        if t[0] == 'rule':
            return ('cell', t[1], t[2]) if t[2] in cols_kept else ('off', t[2])
        if t[0] == 'sample':
            return t if t[1] in smp_kept else ('offsample', t[1])
        return t
    pc = Probe(cl, tags, nv, cellkey)
    base = [g for g in pc.names if g[0] in ('cell', 'trap', 'sample')]
    assert pc.unsat(base)
    core = pc.core(base)
    cells = sorted([g for g in core if g[0] == 'cell'], key=lambda g: (-g[2], -g[1]))
    keep = pc.minimise(core, cells)
    kept = sorted((g[1], g[2]) for g in keep if g[0] == 'cell')
    out['cells'] = kept
    out['cell_count'] = len(kept)
    out['cell_calls'] = pc.calls
    out['seconds'] = round(time.time() - t0, 1)
    bycol = {}
    for tau, j in kept:
        bycol.setdefault(j, []).append(tau)
    print('%s: minimal cells %d (from a solver core of %d); per column: %s; %.0f s' % (
        name, len(kept), len(cells), '  '.join('%d:%d[%d..%d]' % (j, len(v), min(v), max(v))
                                                for j, v in sorted(bycol.items())), out['seconds']), flush=True)
    pathlib.Path(outdir).mkdir(parents=True, exist_ok=True)
    (pathlib.Path(outdir) / ('core-%s.json' % name)).write_text(json.dumps(out))
    return out


if __name__ == '__main__':
    run(sys.argv[1], sys.argv[2], sys.argv[3])
