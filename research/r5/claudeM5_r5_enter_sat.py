#!/usr/bin/env python3
"""claudeM5_r5_enter_sat.py: pull R5 (ledger M133, M134). Can a right half enter a trap from outside? AFTER THE FACT:
written when M133's prediction 2 failed in the front graph.

Unknown: cells 1..W of a right half at tick 0, white beyond. The drive is 0,0,1 from label l0. Asked: at tick T the first
b cells are a state of the trap whose label is l0 + T (mod m), and at tick 0 the first cell differs from the pattern of
label l0 (front at column 1) or the first `white` cells are white. The rule is encoded on the light cone exactly.

  python3 claudeM5_r5_enter_sat.py TRAP L0 T [front1 | whiteK | etherN]
  python3 claudeM5_r5_enter_sat.py late TRAP TAU GAP     for every label: off the pattern at column 1 at tick TAU, and a
                                                         state of the trap at tick TAU + GAP
Prints UNSAT or the cells, replayed with whole rows."""
import sys, pathlib, json
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f
from pysat.solvers import Cadical195


def build(T, l0, ticks, start, tau=None):
    P, K = f.pattern(T)
    b, m = T['b'], T['m']
    W = b + ticks
    nv = 0
    clauses = []
    def new():
        nonlocal nv
        nv += 1
        return nv
    TRUE = new(); clauses.append([TRUE])
    lit = lambda c: TRUE if c else -TRUE
    row = [lit(f.DRIVE[l0 % 3])] + [new() for _ in range(W)]
    init = row[:]
    if start == 'any':
        pass
    elif start.startswith('ether'):
        N = int(start[5:])                                  # the alignment (0, 0), so l0 must be a multiple of 3
        for j in range(1, N + 1):
            clauses.append([init[j]] if f.ETHER[j % 12][l0 % 3] else [-init[j]])
        clauses.append([-init[N + 1]] if f.ETHER[(N + 1) % 12][l0 % 3] else [init[N + 1]])
    elif start == 'front1':
        clauses.append([-init[1]] if P[l0][1] else [init[1]])
    elif start.startswith('front'):
        d = int(start[5:])
        for j in range(1, d):
            clauses.append([init[j]] if P[l0][j] else [-init[j]])
        clauses.append([-init[d]] if P[l0][d] else [init[d]])
    else:
        for j in range(1, int(start[5:]) + 1):
            clauses.append([-init[j]])
    width = W
    for t in range(ticks):
        if tau == t:
            clauses.append([-row[1]] if P[(l0 + t) % m][1] else [row[1]])
        # new cells 1..width-1
        nxt = [lit(f.DRIVE[(l0 + t + 1) % 3])]
        for j in range(1, width):
            a, c, d = row[j - 1], row[j], row[j + 1]
            x = new()
            # x = a xor (c or d)
            for va in (0, 1):
                for vc in (0, 1):
                    for vd in (0, 1):
                        v = va ^ (vc | vd)
                        clauses.append([-a if va else a, -c if vc else c, -d if vd else d, x if v else -x])
            nxt.append(x)
        row = nxt
        width -= 1
    lab = (l0 + ticks) % m
    sel = []
    for s, l in zip(T['st'], T['lab']):
        if l != lab:
            continue
        y = new(); sel.append(y)
        for j in range(1, b + 1):
            clauses.append([-y, row[j] if (s >> (j - 1)) & 1 else -row[j]])
    clauses.append(sel)
    return clauses, init, W


def replay(T, l0, cells, ticks):
    w = sum(c << i for i, c in enumerate(cells))
    for t in range(ticks):
        full = (w << 1) | f.DRIVE[(l0 + t) % 3]
        w = ((full << 1) ^ (full | (full >> 1))) >> 1
    return (w & ((1 << T['b']) - 1), (l0 + ticks) % T['m']) in set(zip(T['st'], T['lab']))


def solve(name, l0, ticks, start, tau=None):
    T = f.load(name)
    clauses, init, W = build(T, l0, ticks, start, tau)
    with Cadical195(bootstrap_with=clauses) as s:
        if not s.solve():
            return None
        mod = set(x for x in s.get_model() if x > 0)
        cells = [1 if v in mod else 0 for v in init[1:W + 1]]
    assert replay(T, l0, cells, ticks)
    return cells


if __name__ == '__main__':
    if sys.argv[1] == 'late':
        name, tau, gap = sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
        print(json.dumps(dict(trap=name, off_at=tau, entry=tau + gap, by_label=''.join(
            '-' if solve(name, l, tau + gap, 'any', tau) is None else 'S' for l in range(f.load(name)['m'])))))
        sys.exit()
    name, l0, ticks, start = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
    r = solve(name, l0, ticks, start)
    print(json.dumps(dict(trap=name, l0=l0, ticks=ticks, start=start, result='UNSAT' if r is None else ''.join(map(str, r)))))
