#!/usr/bin/env python3
"""claudeCloud_m181_cnfread.py: a second read of N19's refusal formulas (ledger K86, K87).

N19's addenda rest on two formulas made by ../claudeIntel_cone.py: B*15 and B*16 on 80 columns.  Their proofs were
checked by lrat-check and cake_lpr, which shows the formulas have no model.  This program checks what the formulas
say, on the bytes the generator writes:

 1. the generator, run again here, writes a file with the digest N19 gives;
 2. its variables are the cells (column p, tick t), columns 1..81 and ticks 0..T, each used;
 3. its unit clauses are exactly: column 1 at tick 2s equals reading s of the word, a kick first, (3 5^5)^k then a kick;
 4. every other clause holds in every real evolution: for random right halves beside the wall (white at even ticks),
    simulated here with a separate rule table, all of them are satisfied.  So a right half that read the word would
    be a model, and "no model" means no right half reads it.  Column 81 enters only as a neighbour: a free edge.
 5. control: flipping one simulated cell breaks a clause.

    python3 claudeCloud_m181_cnfread.py ORDER WIDTH EXPECTED_SHA256 [HALVES]
"""
import hashlib, os, random, runpy, sys, tempfile

RULE30 = {(1, 1, 1): 0, (1, 1, 0): 0, (1, 0, 1): 0, (1, 0, 0): 1, (0, 1, 1): 1, (0, 1, 0): 1, (0, 0, 1): 1, (0, 0, 0): 0}


def main():
    order, width, want = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    halves = int(sys.argv[4]) if len(sys.argv) > 4 else 100
    here = os.path.dirname(os.path.abspath(__file__))
    gen = os.path.join(here, '..', 'claudeIntel_cone.py')
    with tempfile.TemporaryDirectory() as d:
        out = os.path.join(d, 'x.cnf')
        argv = sys.argv; sys.argv = ['cone', order, out, str(width)]
        g = runpy.run_path(gen); sys.argv = argv
        data = open(out, 'rb').read()
    got = hashlib.sha256(data).hexdigest()
    print('digest', got, 'as given' if got == want else 'DIFFERS from ' + want)
    assert got == want
    lines = data.decode().split('\n')
    nv, nc = map(int, lines[0].split()[2:4])
    clauses = [tuple(map(int, ln.split()[:-1])) for ln in lines[1:] if ln]
    assert len(clauses) == nc
    ids = g['ids']; T = g['T']; w = g['w']
    assert len(ids) == nv and sorted(ids.values()) == list(range(1, nv + 1))
    cells = {v: k for k, v in ids.items()}
    assert all(1 <= p <= width + 1 and 0 <= t <= T for (p, t) in ids)
    used = set(abs(x) for c in clauses for x in c); assert used == set(range(1, nv + 1))
    # the word, built here: a kick, then gaps 3 5 5 5 5 5 (B) or 3 5 5 5 (A), then the closing kick
    blocks = []
    i = 0
    while i < len(order):
        c = order[i]; i += 1; k = 1
        if i < len(order) and order[i] == '*':
            j = i + 1
            while j < len(order) and order[j].isdigit(): j += 1
            k = int(order[i + 1:j]); i = j
        blocks += [c] * k
    kicks = [0]
    for c in blocks:
        for gap in ([3, 5, 5, 5] if c == 'A' else [3, 5, 5, 5, 5, 5]): kicks.append(kicks[-1] + gap)
    n = kicks[-1] + 1; word = [1 if s in set(kicks) else 0 for s in range(n)]
    assert word == w and T == 2 * (n - 1)
    units = [c for c in clauses if len(c) == 1]; rest = [c for c in clauses if len(c) > 1]
    want_units = set((ids[1, 2 * s] if word[s] else -ids[1, 2 * s]) for s in range(n))
    assert len(units) == n and set(u[0] for u in units) == want_units
    print('order', order, 'blocks', len(blocks), 'readings', n, 'ticks', T, 'variables', nv, 'clauses', nc, 'unit', len(units))
    # the rest against real evolutions
    rng = random.Random(20261126); span = width + 1 + T + 2
    for h in range(halves):
        row = [0] + [rng.randint(0, 1) for _ in range(span)]            # row[0] is the wall
        val = {}
        for t in range(T + 1):
            row[0] = t % 2                                              # white at even ticks
            for p in range(1, width + 2): val[p, t] = row[p]
            nxt = [0] * len(row)
            for p in range(1, len(row) - 1): nxt[p] = RULE30[row[p - 1], row[p], row[p + 1]]
            row = nxt
        model = {v: val[cells[v]] for v in range(1, nv + 1)}
        bad = sum(1 for c in rest if not any((model[abs(x)] == 1) == (x > 0) for x in c))
        assert bad == 0, (h, bad)
        if h == 0:
            v0 = ids[5, 7]; model[v0] ^= 1
            broke = sum(1 for c in rest if not any((model[abs(x)] == 1) == (x > 0) for x in c))
            assert broke > 0; print('control: one flipped cell breaks', broke, 'clauses')
    print('every clause but the', n, 'readings holds in', halves, 'real evolutions: PASS')


main()
