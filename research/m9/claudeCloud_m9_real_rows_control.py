#!/usr/bin/env python3
"""claudeCloud_m9_real_rows_control.py: controls for claudeCloud_m9_real_rows.cpp (pull M9, ledger K55).

1. The delay convention. A SAT witness of claudeM5_m9_sat.py for a closed run word at delay P is padded with white
   and given to the simulator as a row at tick 1. The simulator must date that word at delay exactly P.
2. The simulator itself. The same rows, and a small cohort, are followed here with Python integers (the whole row,
   no light-cone cut) and read into run words; every table the C++ program writes must agree line for line.

3. Another worker's sequence. With a fourth argument, claudeM5's archived gate of the empty right half
   (share-scratch/claudeM5/M7/m7_u.txt, 450,000 samples, SHA-256 8394aa79..., ledger M16) is read into the same
   tables from its entry sample 146 and compared with the simulator's empty row.

    python3 claudeCloud_m9_real_rows_control.py KITFILE REAL_ROWS_BINARY WORKDIR [M7_U_FILE]
Prints only PASS or the first difference. It never prints a statistic of the cohort.
"""
import importlib.util, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('m9sat', os.path.join(HERE, 'claudeM5_m9_sat.py'))
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)

MARGIN, TMAX, MASK64 = 2000, 8001, (1 << 64) - 1


def splitmix(x):
    x = (x + 0x9E3779B97F4A7C15) & MASK64
    x = ((x ^ (x >> 30)) * 0xBF58476D1CE4E5B9) & MASK64
    x = ((x ^ (x >> 27)) * 0x94D049BB133111EB) & MASK64
    return x ^ (x >> 31)


def gate_after_entry(row, t0, stot, trap):
    """row: integer, bit i is column i + 1 at tick t0. Returns the gate from the entry sample, stot samples."""
    t, gate, entered = t0, [], False
    while True:
        if t & 1:
            if not entered:
                if (row & 0xFFFF) in trap:
                    entered = True
                elif t >= TMAX:
                    return None
            if entered:
                gate.append(row & 1)
                if len(gate) == stot:
                    return gate
        wall = 1 if t % 2 == 0 else 0
        row = ((row << 1) | wall) ^ (row | (row >> 1))
        t += 1


def tables(gates, S):
    """The word tables as the C++ program defines them: {k: {word: [total, late100, min, max, rows]}}."""
    T = {2: {}, 3: {}, 4: {}}
    for rowid, gate in gates:
        kicks = [d for d, g in enumerate(gate) if g]
        three = []
        for a, b in zip(kicks, kicks[1:]):
            assert b - a in (3, 5), 'a gap after entry is neither 3 nor 5'
            if b - a == 3:
                three.append(a)
        r = [(three[k + 1] - three[k] - 3) // 5 for k in range(len(three) - 1)]
        for k in range(len(r)):
            d = three[k]
            if d >= S:
                break
            for n in (2, 3, 4):
                if k + n < len(three):
                    w = ','.join(map(str, r[k:k + n]))
                    e = T[n].setdefault(w, [0, 0, 10 ** 18, -1, set()])
                    e[0] += 1; e[1] += d >= 100; e[2] = min(e[2], d); e[3] = max(e[3], d); e[4].add(rowid)
    return {n: {w: (e[0], e[1], e[2], e[3], len(e[4])) for w, e in T[n].items()} for n in T}


def read_tables(prefix):
    out = {}
    for n in (2, 3, 4):
        out[n] = {}
        with open('%s.words%d.tsv' % (prefix, n)) as f:
            next(f)
            for line in f:
                p = line.split('\t')
                out[n][p[0]] = tuple(int(x) for x in p[1:6])
    return out


def compare(name, mine, theirs):
    for n in (2, 3, 4):
        if mine[n] != theirs[n]:
            keys = sorted(set(mine[n]) | set(theirs[n]))
            bad = next(k for k in keys if mine[n].get(k) != theirs[n].get(k))
            print('FAIL %s: words of %d runs differ at %s: python %s, C++ %s' % (name, n, bad, mine[n].get(bad), theirs[n].get(bad)))
            sys.exit(1)
    print('PASS %s: %d, %d and %d distinct words of 2, 3 and 4 runs agree line for line' % (name, len(mine[2]), len(mine[3]), len(mine[4])))


def main():
    kit, binary, work = sys.argv[1], sys.argv[2], sys.argv[3]
    from pysat.solvers import Cadical195
    trap = M.trap_codes(kit); trapset = set(trap)
    os.makedirs(work, exist_ok=True)
    # 1. planted witnesses
    for spec_, P in (('R:4.4.4', 2), ('R:5.6.4.5', 6), ('R:4.5.6.5', 20)):
        word = M.gap_word(spec_) if hasattr(M, 'gap_word') else None
        cl, vid, nv, info = M.build(trap, word, P)
        with Cadical195(bootstrap_with=cl) as s:
            assert s.solve(), 'the planted instance is not satisfiable'
            w = M.verify(s.get_model(), vid, trap, info, word, P)
        assert all(w[k] for k in ('start_in_trap', 'every_sample_window_in_trap', 'word_spelled', 'solver_cells_agree_with_simulation'))
        bits = w['initial_row']; S = info['D'] + 50; out = os.path.join(work, 'plant-' + spec_[2:])
        subprocess.run([binary, kit, 'row1', bits, str(S), out], check=True, stdout=subprocess.DEVNULL)
        theirs = read_tables(out); runs = spec_[2:].replace('.', ','); n = runs.count(',') + 1
        got = theirs[n].get(runs)
        if got is None or got[2] != P:
            print('FAIL plant %s at P = %d: the simulator dates it %s' % (runs, P, got)); sys.exit(1)
        print('PASS plant: the witness of (%s) at P = %d is dated at delay %d by the simulator' % (runs, P, got[2]))
        row = sum(1 << i for i, c in enumerate(bits) if c == '1')
        g = gate_after_entry(row, 1, S + MARGIN + 1, trapset)
        compare('planted row (%s)' % runs, tables([(0, g)], S), theirs)
    # 2. a small cohort, both supports, against Python integers
    for N, rows, S, base in ((30, 60, 3000, 777), (64, 40, 3000, 778)):
        out = os.path.join(work, 'dev-cohort-%d' % N)
        subprocess.run([binary, kit, 'cohort', str(N), str(rows), str(S), out, str(base), '5'], check=True, stdout=subprocess.DEVNULL)
        gates = []
        for i in range(5, 5 + rows):
            x = splitmix((base * 0x100000001B3 + i) & MASK64)
            seed = (x if N == 64 else x & ((1 << N) - 1)) | (1 << (N - 1))
            g = gate_after_entry(seed, 0, S + MARGIN + 1, trapset)
            if g is not None:
                gates.append((i, g))
        compare('cohort of support %d, %d rows, %d entered' % (N, rows, len(gates)), tables(gates, S), read_tables(out))
    # 3. claudeM5's archived gate of the empty right half
    if len(sys.argv) > 4:
        import hashlib
        raw = open(sys.argv[4], 'rb').read()
        assert hashlib.sha256(raw).hexdigest().startswith('8394aa79bf3d3a6f'), 'not the archived file of M16'
        u = [1 if c == 49 else 0 for c in raw if c in (48, 49)]
        assert len(u) == 450000
        S = len(u) - 146 - MARGIN - 1
        out = os.path.join(work, 'empty-m16')
        subprocess.run([binary, kit, 'empty', str(S), out], check=True, stdout=subprocess.DEVNULL)
        compare("the empty right half against claudeM5's archived gate, %d samples from entry" % (len(u) - 146), tables([(0, u[146:])], S), read_tables(out))
    print('ALL CONTROLS PASS')


if __name__ == '__main__':
    main()
