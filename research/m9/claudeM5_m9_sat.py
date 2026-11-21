#!/usr/bin/env python3
"""claudeM5_m9_sat.py: pull M9, third claudeM5 block. Can a code word occur in a real right half after it has spent
P samples inside the gate trap? L1614's finite criterion (placego, 9 November), re-implemented, with every SAT answer
checked by plain simulation and every UNSAT answer certified by LRAT.

The instance (as placego's local_word_sat_past.py). Time tau = 0 is an odd absolute time (a sample). The centre,
column 0, is black at even absolute times, so at local time tau it is black exactly when tau is odd. At tau = 0 the
right half's cells 1..16 are one of the kit's 829 trap windows (selector variables, at least one). The rule
x[tau+1][j] = x[tau][j-1] xor (x[tau][j] or x[tau][j+1]) holds on the light-cone triangle: cell j at tau depends only
on the initial cells up to j + tau, so the initial cells 1..2D+1 decide every sample, D = P + the word's samples.
Column 1 is free at samples 0..P-1, black at sample P, and spells the gap word from there. SAT: some right half,
finite or infinite (any assignment extends), that has been inside the trap for P samples reads the word next. UNSAT:
no right half does, and by the trap's closure the word never starts at any later sample either.

A run word (r1, ..., rk) is the gap word 3 5^r1 3 ... 5^rk 3, written R:r1.r2...; a power r^k is P:r:k.

  python3 claudeM5_m9_sat.py KITFILE OUTDIR WORDSPEC P [--cap SECONDS] [--certify]
  python3 claudeM5_m9_sat.py KITFILE OUTDIR controls

Solving: Kissat with a time cap (a cap is UNKNOWN, never a negative). SAT: the model's initial row is simulated
cell by cell, here, independently of the clauses: its window must be a trap window, every sample window from 0 to the
end must be a trap window (the trap is closed), and column 1 must spell the word. UNSAT with --certify: CaDiCaL
writes a binary LRAT proof, which cake_lpr checks; acceptance is its line `s VERIFIED UNSAT`.
"""
import hashlib
import json
import pathlib
import re
import subprocess
import sys
import time


def trap_codes(kitfile):
    text = open(kitfile).read()
    body = re.search(r'def trapCodes : List Nat := \[(.*?)\]', text, re.S).group(1)
    codes = [int(x) for x in re.findall(r'\d+', body)]
    assert len(codes) == 829
    return codes


def gap_word(spec):
    if spec.startswith('R:'):
        runs = [int(x) for x in spec[2:].split('.')]
        return '3' + ''.join('5' * r + '3' for r in runs)
    if spec.startswith('P:'):
        _, r, k = spec.split(':')
        return '3' + ('5' * int(r) + '3') * int(k)
    assert set(spec) <= set('35'), spec
    return spec


def heads_of(word):
    h = [1]
    for g in word:
        h += [0] * (int(g) - 1) + [1]
    return h


def build(trap, word, P):
    """The CNF (as a list of clauses), the variable map and the sizes."""
    wh = heads_of(word)
    D = P + len(wh) - 1
    T = 2 * D
    M = T + 1
    vid = {}

    def v(tau, j):
        k = (tau, j)
        if k not in vid:
            vid[k] = len(vid) + 1
        return vid[k]

    cl = []
    for tau in range(T):
        for j in range(1, M - tau):
            z, b, c = v(tau + 1, j), v(tau, j), v(tau, j + 1)
            if j == 1:
                a0 = 1 if tau % 2 == 1 else 0
                for bb in (0, 1):
                    for cc in (0, 1):
                        zz = a0 ^ (bb | cc)
                        cl.append([(-b if bb else b), (-c if cc else c), (z if zz else -z)])
            else:
                a = v(tau, j - 1)
                for aa in (0, 1):
                    for bb in (0, 1):
                        for cc in (0, 1):
                            zz = aa ^ (bb | cc)
                            cl.append([(-a if aa else a), (-b if bb else b), (-c if cc else c), (z if zz else -z)])
    for s, h in enumerate(wh):
        cl.append([v(2 * (P + s), 1) if h else -v(2 * (P + s), 1)])
    ncell = len(vid)
    sel = [ncell + 1 + i for i in range(len(trap))]
    cl.append(sel)
    for i, code in enumerate(trap):
        for j in range(16):
            cl.append([-sel[i], v(0, j + 1) if (code >> j) & 1 else -v(0, j + 1)])
    return cl, vid, ncell + len(trap), dict(D=D, T=T, M=M, heads=wh)


def dimacs(cl, nv, path):
    with open(path, 'w') as f:
        f.write('p cnf %d %d\n' % (nv, len(cl)))
        for c in cl:
            f.write(' '.join(map(str, c)) + ' 0\n')


def simulate(row, T):
    """Plain cell-by-cell rule 30 on the right half: row[j] for j = 1..len, column 0 black iff tau odd. Returns the
    rows at every tau as lists (index 0 is column 0)."""
    width = len(row) + T + 2
    cur = [0] + list(row) + [0] * (width - len(row))
    rows = [cur]
    for tau in range(T):
        cur = [1 if tau % 2 == 1 else 0] + cur[1:]
        nxt = [0] * (width + 1)
        nxt[0] = 1 if (tau + 1) % 2 == 1 else 0
        for j in range(1, width):
            nxt[j] = cur[j - 1] ^ (cur[j] | (cur[j + 1] if j + 1 < len(cur) else 0))
        cur = nxt[:width + 1]
        rows.append(cur)
    return rows


def verify(model, vid, trap, info, word, P):
    pos = set(x for x in model if x > 0)
    M, T, wh = info['M'], info['T'], info['heads']
    row = [1 if vid[(0, j)] in pos else 0 for j in range(1, M + 1)]
    rows = simulate(row, T)
    trapset = set(trap)
    win = lambda r: sum(r[j + 1] << j for j in range(16))
    ok_start = win(rows[0]) in trapset
    ok_closed = all(win(rows[2 * s]) in trapset for s in range(T // 2 + 1))
    samples = [rows[2 * s][1] for s in range(T // 2 + 1)]
    ok_word = samples[P:P + len(wh)] == wh
    # the solver's own values agree with the simulation on every constrained cell
    agree = all((vid[(tau, j)] in pos) == bool(rows[tau][j]) for (tau, j) in vid)
    head = ''.join(map(str, samples[:P]))
    return dict(start_window=win(rows[0]), start_in_trap=ok_start, every_sample_window_in_trap=ok_closed,
                word_spelled=ok_word, solver_cells_agree_with_simulation=agree, head_before_P=head,
                initial_row_sha=hashlib.sha256(bytes(row)).hexdigest(), initial_row=''.join(map(str, row)))


def solve(kitfile, outdir, spec, P, cap=3600, certify=False):
    trap = trap_codes(kitfile)
    word = gap_word(spec)
    out = pathlib.Path(outdir)
    out.mkdir(parents=True, exist_ok=True)
    tag = '%s_P%d' % (spec.replace(':', '-').replace('.', '_'), P)
    t0 = time.time()
    cl, vid, nv, info = build(trap, word, P)
    cnf = out / (tag + '.cnf')
    dimacs(cl, nv, cnf)
    res = dict(spec=spec, word=word, P=P, samples=info['D'] + 1, variables=nv, clauses=len(cl),
               cnf_sha=hashlib.sha256(cnf.read_bytes()).hexdigest(), build_seconds=round(time.time() - t0, 1))
    t1 = time.time()
    p = subprocess.run(['kissat', '--time=%d' % cap, '-q', str(cnf)], capture_output=True, text=True)
    res['solve_seconds'] = round(time.time() - t1, 1)
    status = {10: 'SAT', 20: 'UNSAT'}.get(p.returncode, 'UNKNOWN')
    res['status'] = status
    if status == 'SAT':
        model = [int(x) for line in p.stdout.splitlines() if line.startswith('v ') for x in line[2:].split()]
        res['witness'] = verify(model, vid, trap, info, word, P)
        res['verified'] = all(res['witness'][k] for k in ('start_in_trap', 'every_sample_window_in_trap',
                                                          'word_spelled', 'solver_cells_agree_with_simulation'))
    elif status == 'UNSAT' and certify:
        proof = out / (tag + '.lrat')
        t2 = time.time()
        try:
            q = subprocess.run(['cadical', '-q', '--lrat=true', str(cnf), str(proof)], capture_output=True,
                               text=True, timeout=2 * cap)
            res['cadical'] = {10: 'SAT', 20: 'UNSAT'}.get(q.returncode, 'UNKNOWN')
            r = subprocess.run(['cake_lpr', str(cnf), str(proof)], capture_output=True, text=True, timeout=4 * cap)
            res['certificate'] = 's VERIFIED UNSAT' in r.stdout
            res['proof_bytes'] = proof.stat().st_size
        except subprocess.TimeoutExpired:
            res['certificate'] = None          # pending: the UNSAT answer stays COMPUTED, uncertified
        res['certify_seconds'] = round(time.time() - t2, 1)
        if proof.exists():
            proof.unlink()
    cnf.unlink()
    (out / (tag + '.json')).write_text(json.dumps(res))
    line = '%-22s P = %3d: %-7s %6d samples, %7d variables, %8d clauses, solve %7.1f s' % (
        spec, P, status, res['samples'], nv, len(cl), res['solve_seconds'])
    if status == 'SAT':
        line += '; start window %d; witness verified: %s' % (res['witness']['start_window'], res['verified'])
    if 'certificate' in res:
        line += '; LRAT checked by cake_lpr: %s' % ('pending (cap)' if res['certificate'] is None
                                                      else res['certificate'])
    print(line, flush=True)
    return res


def controls(kitfile, outdir):
    """L1614's controls and outcomes: 3535353 UNSAT at entry (dead at 18 columns); 333 UNSAT at entry (the kit's
    gap_words_of_entry); 3555355535553555 SAT at entry; the (4, 4, 4) word SAT at P = 20 and 60 (L1614: 4.3 s, 30.1 s)."""
    want = [('3535353', 0, 'UNSAT'), ('333', 0, 'UNSAT'), ('3555355535553555', 0, 'SAT'),
            ('R:4.4.4', 20, 'SAT'), ('R:4.4.4', 60, 'SAT')]
    ok = True
    for spec, P, w in want:
        r = solve(kitfile, outdir, spec, P, cap=600, certify=True)
        good = r['status'] == w and (w != 'SAT' or r['verified']) and (w != 'UNSAT' or r.get('certificate'))
        ok &= good
    # the empty right half enters the trap at absolute time 293 with window 49415 (the kit): the simulator's rule
    # the kit's run starts at absolute time 0, which is even, so it is stepped here directly
    row = [0] * 600
    for t in range(293):
        c0 = 1 if t % 2 == 0 else 0
        cur = [c0] + row
        row = [cur[j - 1] ^ (cur[j] | (cur[j + 1] if j + 1 < len(cur) else 0)) for j in range(1, len(cur))]
    win = sum(row[j] << j for j in range(16))
    print('the empty right half at time 293 has window %d (kit: 49415): %s' % (win, win == 49415))
    ok &= win == 49415
    print('CONTROLS:', 'PASS' if ok else 'FAIL')
    return ok


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[2] == 'controls':
        sys.exit(0 if controls(a[0], a[1]) else 1)
    cap = int(a[a.index('--cap') + 1]) if '--cap' in a else 3600
    solve(a[0], a[1], a[2], int(a[3]), cap=cap, certify='--certify' in a)
