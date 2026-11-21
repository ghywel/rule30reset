#!/usr/bin/env python3
"""claudeCloud_m9_backbone.py: pull M9 (ledger K53, addendum 2). What does a run word FORCE? For a satisfiable
instance of claudeM5's builder (research/m9/claudeM5_m9_sat.py, unchanged), the BACKBONE is the set of cells that
take the same colour in every solution: every right half that enters the trap and then reads the word agrees there.

Method (exact, python-sat's CaDiCaL 1.9.5, incremental). Take one model; its literals are the candidates. Repeat: ask
for a model in which at least one remaining candidate is false. If there is none, every remaining candidate is in
the backbone. Otherwise drop every candidate the new model falsifies. Each answer "none" is an UNSAT call: COMPUTED,
not certified. Every model is checked cell by cell by claudeM5's verify.

Printed: for each sample (odd tick), how many columns from column 1 are forced without a break, and the forced cells
as a picture (# forced black, . forced white, blank free).

  python3 claudeCloud_m9_backbone.py KITFILE SPEC P OUT.json
"""
import json
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import claudeM5_m9_sat as M      # noqa: E402
from pysat.solvers import Cadical195      # noqa: E402


def backbone(kit, spec, P):
    trap = M.trap_codes(kit)
    word = M.gap_word(spec)
    cl, vid, nv, info = M.build(trap, word, P)
    cells = {v: k for k, v in vid.items()}
    t0 = time.time()
    with Cadical195(bootstrap_with=cl) as s:
        assert s.solve(), 'the instance is not satisfiable'
        model = s.get_model()
        w = M.verify(model, vid, trap, info, word, P)
        assert all(w[k] for k in ('start_in_trap', 'every_sample_window_in_trap', 'word_spelled',
                                  'solver_cells_agree_with_simulation'))
        cand = {l for l in model if abs(l) in cells}
        calls, models = 1, 1
        act = nv
        while cand:
            act += 1                                   # a fresh activation literal for this round's clause
            s.add_clause([-act] + [-l for l in cand])
            calls += 1
            if not s.solve(assumptions=[act]):
                break
            m2 = s.get_model()
            models += 1
            w = M.verify(m2, vid, trap, info, word, P)
            assert w['start_in_trap'] and w['word_spelled'] and w['solver_cells_agree_with_simulation']
            pos = {l for l in m2 if abs(l) in cells}
            cand &= pos
            s.add_clause([-act])
    forced = {cells[abs(l)]: (1 if l > 0 else 0) for l in cand}
    return forced, info, dict(calls=calls, models=models, seconds=round(time.time() - t0, 1), cells=len(cells),
                              forced=len(forced), word=word)


def main():
    kit, spec, P, outp = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
    forced, info, st = backbone(kit, spec, P)
    T, Mw, heads = info['T'], info['M'], info['heads']
    print('%s at P = %d: %d cells in the light cone, %d forced (%.1f%%); %d solver calls, %d models, %.0f s' % (
        spec, P, st['cells'], st['forced'], 100.0 * st['forced'] / st['cells'], st['calls'], st['models'], st['seconds']))
    depth = []
    print('sample gate  forced-from-column-1   picture of columns 1..70 (# forced black, . forced white, blank free)')
    for sm in range(T // 2 + 1):
        tau = 2 * sm
        d = 0
        while (tau, d + 1) in forced:
            d += 1
        depth.append(d)
        width = Mw - tau
        pic = ''.join(('#' if forced[(tau, j)] else '.') if (tau, j) in forced else ' ' for j in range(1, min(width, 70) + 1))
        g = heads[sm - P] if P <= sm < P + len(heads) else '-'
        print('%4d    %s   %3d of %3d             |%s|' % (sm, g, d, width, pic))
    json.dump(dict(spec=spec, P=P, stats=st, depth=depth, forced=[[t, j, v] for (t, j), v in sorted(forced.items())]),
              open(outp, 'w'))


if __name__ == '__main__':
    main()
