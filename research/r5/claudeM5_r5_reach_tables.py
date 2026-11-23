#!/usr/bin/env python3
"""claudeM5_r5_reach_tables.py: pull R5, third block. The windows of 20 cells that can ever lead to the kit's 15-trap,
as three layered automata, one for each phase of the drive, written as Lean tables.

A window is read from cell 20 down to cell 1. Node 0 is dead. Node i of phase p has the two successors
(T >> (26 i)) mod 2^13 (next cell white) and the next 13 bits (next cell black). A window is in the set when its reading
ends in a node other than 0. The set is the closure under predecessors of the trap's 15 patterns cut to 20 cells, 54,576
windows (M134, I173).

  python3 claudeM5_r5_reach_tables.py OUT.lean"""
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f

W, BITS = 20, 13


def closure():
    T = f.load('fifteen')
    P, K = f.pattern(T)
    todo = [(l % 3, sum(P[l][j] << (j - 1) for j in range(1, W + 1))) for l in range(15)]
    S = set(todo)
    while todo:
        p1, v = todo.pop()
        p = (p1 + 2) % 3
        for b in (0, 1):
            for z in (0, 1):
                xj, xj1, r, c = b, z, b << (W - 1), 0
                for j in range(W, 0, -1):
                    left = ((v >> (j - 1)) & 1) ^ (xj | xj1)
                    if j >= 2:
                        r |= left << (j - 2)
                    else:
                        c = left
                    xj1, xj = xj, left
                if c == f.DRIVE[p] and (p, r) not in S:
                    S.add((p, r))
                    todo.append((p, r))
    return S


def automaton(words):
    """minimal layered automaton, cells W..1; returns (root, list of (succ0, succ1))"""
    nodes, table = {}, [(0, 0)]

    def build(k, ws):
        """node after reading cells W..k+1, with ws the sorted tuple of remaining low-k-bit words"""
        if not ws:
            return 0
        key = (k, ws)
        if key in nodes:
            return nodes[key]
        if k == 0:
            table.append((0, 0))
        else:
            hi = 1 << (k - 1)
            a = build(k - 1, tuple(x for x in ws if not x & hi))
            b = build(k - 1, tuple(x ^ hi for x in ws if x & hi))
            table.append((a, b))
        nodes[key] = len(table) - 1
        return nodes[key]
    return build(W, tuple(sorted(words))), table


def main(out):
    S = closure()
    assert len(S) == 54576
    lines = []
    for p in range(3):
        root, table = automaton([r for q, r in S if q == p])
        assert len(table) < 1 << BITS
        n = sum((a | b << BITS) << (2 * BITS * i) for i, (a, b) in enumerate(table))
        lines.append('def tab%d : Nat := %d' % (p, n))
        lines.append('def root%d : Nat := %d' % (p, root))
        print('phase', p, 'windows', sum(1 for q, r in S if q == p), 'nodes', len(table), 'root', root, 'digits', len(str(n)))
    if out:
        pathlib.Path(out).write_text('\n'.join(lines) + '\n')
    return S


if __name__ == '__main__':
    sys.set_int_max_str_digits(0)
    main(sys.argv[1] if len(sys.argv) > 1 else None)
