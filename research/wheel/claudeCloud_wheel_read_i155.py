#!/usr/bin/env python3
"""claudeCloud_wheel_read_i155.py: a replay of gptIntel's wheel results (I153 to I156) with code that shares nothing
with theirs (ledger K76). It uses the encoder and the plain simulator of claudeCloud_wheel_runs.py.

  1. The 28 thresholds of research/wheel/thresholds.json. From each white starting phase p, with threshold n:
     the wheel's n white samples cannot end outside the trap (UNSAT with only the white samples prescribed, the
     weaker hypothesis), and n - 1 samples can, even with every intervening tick of U prescribed (a row, replayed).
  2. The three fragments force the trap; each of them one sample shorter does not.
  3. The three witness rows of thresholds.json, replayed cell by cell: every tick of U from the stated phase, and
     the stated final window outside the trap. The four double steps from window 7772 land in the trap.
  4. On the 829 trap windows with a free exterior: from every kick, column 1 spells 110100 or 1101000100 to the
     next kick; and the reading at a black tick is the OR of the gate at the samples s, s - 1 and s - 3.
  5. No 17 consecutive ticks of a concatenation of those two tiles agree with the period-14 word at an aligned
     position, and 16 do.

    python3 claudeCloud_wheel_read_i155.py KITFILE THRESHOLDS.json
"""
import itertools
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_runs as R       # noqa: E402

U = '00010011010001001101000100110100010011010001001101001101'
U2 = '00010011001101'


def wheel_instance(trap, phase, n, full):
    cone = R.Cone(n)
    for s in range(n):
        ch = U[(2 * (phase + s)) % 56]
        cone.clauses.append([cone.gate(s) if ch == '1' else -cone.gate(s)])
        if full and s < n - 1:
            ch = U[(2 * (phase + s) + 1) % 56]
            v = cone.var[(2 * s + 1, 1)]
            cone.clauses.append([v if ch == '1' else -v])
    cone.forbid_codes(n - 1, trap)
    return cone


def column1(row_bits, ticks):
    n = len(row_bits)
    x = sum(int(b) << i for i, b in enumerate(row_bits))
    width = n
    col, codes = [], []
    for t in range(ticks):
        col.append(x & 1)
        codes.append(x & 0xFFFF if width >= 16 else None)
        if t == ticks - 1:
            break
        r = (x << 1) | (t % 2)
        x = (r ^ ((r >> 1) | (r >> 2))) & ((1 << (width - 1)) - 1)
        width -= 1
    return col, codes


def main():
    kit, tpath = sys.argv[1], sys.argv[2]
    trap = [int(c) for c in L.trap_codes(kit)]
    trapset = set(trap)
    d = json.load(open(tpath))
    ok = True

    # 1. thresholds
    bad = []
    for p, n in enumerate(d['white_samples']):
        st, _ = wheel_instance(trap, p, n, False).solve(10 ** 7)
        st2, row = wheel_instance(trap, p, n - 1, True).solve(10 ** 7)
        good = st == 'UNSAT' and st2 == 'SAT'
        if good:
            col, codes = column1(row, 2 * (n - 2) + 1)
            want = [int(U[(2 * p + t) % 56]) for t in range(2 * (n - 2) + 1)]
            good = col == want and codes[-1] not in trapset
        if not good:
            bad.append((p, n, st, st2))
    ok &= not bad
    print('1. thresholds at the 28 phases: %d agree (n white samples force; n - 1 with every tick of U do not, row replayed)%s'
          % (28 - len(bad), '' if not bad else '; exceptions ' + str(bad)))

    # 2. fragments
    res = []
    for m in d['markers']:
        w, p = m['word'], m['phase']
        assert w == ''.join(U[(2 * (p + s)) % 56] for s in range(len(w)))
        st, _ = wheel_instance(trap, p, len(w), False).solve(10 ** 7)
        st2, _ = wheel_instance(trap, p, len(w) - 1, False).solve(10 ** 7)
        res.append((p, len(w), st, st2))
    good = all(a == 'UNSAT' and b == 'SAT' for _, _, a, b in res)
    ok &= good
    print('2. fragments (phase, samples, as given, one sample shorter):', res)

    # 3. witness rows
    for wt in d['physical_witnesses']:
        row = [int(c) for c in wt['cells_positive_first']]
        p, n = wt['phase'], wt['samples']
        ticks = 2 * (n - 1) + 1
        col, codes = column1(row, ticks)
        want = [int(U[(2 * p + t) % 56]) for t in range(ticks)]
        fin = codes[-1]
        good = col == want and fin == wt['final_window'] and fin not in trapset
        ok &= good
        print('3. witness from phase %d: %d cells, %d white samples, every tick is U: %s; final window %s (stated %d), outside the trap: %s'
              % (p, len(row), n, col == want, fin, wt['final_window'], fin is not None and fin not in trapset))
    nxt = [int(L.step2(np.array([7772], dtype=np.int64), x1, x2, 16)[0]) for x1 in (0, 1) for x2 in (0, 1)]
    good = all(v in trapset for v in nxt)
    ok &= good
    print('   the four double steps from window 7772 are in the trap: %s' % good)

    # 4. tiles and the midpoint rule on the trap graph
    codes = np.array(sorted(trap), dtype=np.int64)
    idx = {int(c): i for i, c in enumerate(codes)}
    succ = [[idx[int(v)] for v in L.step2(codes, x1, x2, 16)] for x1 in (0, 1) for x2 in (0, 1)]
    g = [int(c) & 1 for c in codes]
    b = [(int(c) & 1) | ((int(c) >> 1) & 1) for c in codes]      # column 1 one tick later: gate OR column 2
    tiles = set()
    stack = [(i, str(g[i]) + str(b[i])) for i in range(len(codes)) if g[i]]
    seen = set(stack)
    while stack:
        i, w = stack.pop()
        for s in succ:
            j = s[i]
            if g[j]:
                tiles.add(w)
            else:
                item = (j, w + str(g[j]) + str(b[j]))
                if len(item[1]) <= 14 and item not in seen:
                    seen.add(item)
                    stack.append(item)
    good = tiles == {'110100', '1101000100'}
    ok &= good
    print('4. kick-to-kick words of column 1 over all paths in the trap: %s' % sorted(tiles))
    viol = 0
    paths = [(i,) for i in range(len(codes))]
    for _ in range(3):
        paths = list({p + (s[p[-1]],) for p in paths for s in succ})
    for p in paths:
        if b[p[3]] != (g[p[3]] | g[p[2]] | g[p[0]]):
            viol += 1
    ok &= viol == 0
    print('   black-tick reading = gate(s) OR gate(s-1) OR gate(s-3) on %d paths of four samples: %d exceptions' % (len(paths), viol))

    # 5. the period-14 word against tile sequences
    best = 0
    for n in range(1, 7):
        for seq in itertools.product(('110100', '1101000100'), repeat=n):
            w = ''.join(seq) * 3
            for off in range(0, 14, 2):                # aligned: white ticks on white ticks
                run = 0
                for t, ch in enumerate(w):
                    if ch == U2[(off + t) % 14]:
                        run += 1
                        best = max(best, run)
                    else:
                        run = 0
    good = best == 16
    ok &= good
    print('5. longest aligned agreement of a tile sequence with the period-14 word: %d ticks' % best)
    print('read', 'passed' if ok else 'FAILED')


if __name__ == '__main__':
    main()
