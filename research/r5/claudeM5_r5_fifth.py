#!/usr/bin/env python3
"""claudeM5_r5_fifth.py: pull R5, third block (ledger M137). A fifth trap for 001, apart from the four known ones.

The wall: the drive word 110101100010000000000 (labels mod 21) with its 12 cells beyond, found by claudeM5_r5_census.cpp at
distance 117. Carried leftward it reaches 001. The trap is 117 columns that are functions of the label, then the closed
set of 12-cell windows: 129 cells.
Checked here on whole windows: every state's two successors are states; column 1 is one value at each white label; no state
is, cut to the narrower width, a state of t001 or the 15-trap (the kit's tables) or on the first columns of the 144- or
304-cell trap at a label of the same phase; and a half that starts in it stays in it and out of the kit's two for T ticks.

  python3 claudeM5_r5_fifth.py [T]"""
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f
import claudeM5_r5_chains as ch

SEED, VALUES, D, W, M = '110101100010000000000', '--1-0--111-0011111111', 117, 12, 21


def main(T):
    seed = [int(x) for x in SEED]
    vals = [0 if x == '-' else int(x) for x in VALUES]
    # columns leftward
    u, v, cols = seed, vals, [seed]
    for _ in range(D):
        left = [u[(t + 1) % M] ^ (u[t] | v[t]) for t in range(M)]
        cols.append(left)
        v, u = u, left
    r = ch.phase(cols[D])
    P = [[cols[D - j][(l - r) % M] for j in range(D + 1)] for l in range(M)]
    print('column 0 is 001 with label = phase:', all(P[l][0] == f.DRIVE[l % 3] for l in range(M)),
          '| the pattern is a rule-30 orbit:', all(P[(l + 1) % M][j] == P[l][j - 1] ^ (P[l][j] | P[l][j + 1]) for l in range(M) for j in range(1, D)))
    # the closed set beyond column D: forward closure of the limit windows, then its closed locked component
    c = [P[l][D] for l in range(M)]
    full = [set(range(1 << W)) for _ in range(M)]
    while True:
        new = [set() for _ in range(M)]
        for l in range(M):
            for x in full[l]:
                for z in (0, 1):
                    new[(l + 1) % M].add(f.strip_step(W, c[l], z, x))
        new = [new[l] & full[l] for l in range(M)]
        if all(len(a) == len(b) for a, b in zip(new, full)):
            break
        full = new
    need = {l: P[(l + 1) % M][D] ^ P[l][D - 1] for l in range(M) if c[l] == 0}
    # greatest set inside the limit that always passes its checks
    S = [{x for x in full[l] if l not in need or (x & 1) == need[l]} for l in range(M)]
    while True:
        ch_ = False
        for l in range(M):
            keep = {x for x in S[l] if all(f.strip_step(W, c[l], z, x) in S[(l + 1) % M] for z in (0, 1))}
            if len(keep) != len(S[l]):
                S[l] = keep
                ch_ = True
        if not ch_:
            break
    print('greatest closed locked set beyond column', D, 'of 12-cell windows:', sum(map(len, S)), 'by label', [len(s) for s in S][:21])
    b = D + W
    states = {(l, sum(P[l][j] << (j - 1) for j in range(1, D + 1)) | (x << D)) for l in range(M) for x in S[l]}
    closed = all(((l + 1) % M, f.strip_step(b, f.DRIVE[l % 3], z, s)) in states for l, s in states for z in (0, 1))
    gate = {}
    for l, s in states:
        gate.setdefault(l, set()).add(s & 1)
    print('states', len(states), 'of', b, 'cells; closed:', closed, '| column 1 one value at each white label:',
          all(len(g) == 1 for l, g in gate.items() if f.DRIVE[l % 3] == 0))
    g = ''.join(str(next(iter(gate[l]))) for l in range(1, M, 3))
    print('gate', max(g[i:] + g[:i] for i in range(len(g))))
    # apart from the four
    others = ch.patterns()
    for n in ('t001', 'fifteen'):
        Tb = f.load(n)
        cut = {(l % 3, s) for s, l in zip(Tb['st'], Tb['lab'])}
        hit = sum((l % 3, s & ((1 << Tb['b']) - 1)) in cut for l, s in states)
        print('states that, cut to', Tb['b'], 'cells, are a state of', n, 'at the phase:', hit)
    for n in ('b', 'c'):
        Q = others[n]
        k = min(D, len(Q[0]) - 1)
        hit = sum(all(P[l][j] == Q[m][j] for j in range(1, k + 1)) for l in range(M) for m in range(len(Q)) if l % 3 == m % 3)
        depth = max(next((j - 1 for j in range(1, k + 1) if P[l][j] != Q[m][j]), k) for l in range(M) for m in range(len(Q)) if l % 3 == m % 3)
        print('label pairs at which the first', k, 'columns equal those of', n, ':', hit, '(deepest agreement %d columns)' % depth)
    # a half that starts in it
    l0, s0 = min(states)
    row, t, stay, ent = s0, 0, True, 0
    sets = {n: {(l % 3, s) for s, l in zip(f.load(n)['st'], f.load(n)['lab'])} for n in ('t001', 'fifteen')}
    mask = {'t001': (1 << 47) - 1, 'fifteen': (1 << 52) - 1}
    while t < T:
        stay &= ((l0 + t) % M, row & ((1 << b) - 1)) in states
        ent += any(((l0 + t) % 3, row & mask[n]) in sets[n] for n in sets)
        fr = (row << 1) | f.DRIVE[(l0 + t) % 3]
        row = ((fr << 1) ^ (fr | (fr >> 1))) >> 1
        t += 1
    print('a half of', b, 'cells starting in it, white beyond, for', T, 'ticks: stays', stay, '| ticks in t001 or the 15-trap', ent)


if __name__ == '__main__':
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 5000)
