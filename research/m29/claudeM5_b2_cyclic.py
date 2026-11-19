#!/usr/bin/env python3
"""Pull M29, stream B2 (K8): M44 B at gaps 51-100, frozen and blind, with I2's corrections.

The question (K8): does any doubling return to white at gaps 51-100 at a source period of 29 or more?

Method. M44 B's, with claudeM5_core_window.py imported unchanged as committed in M44.
  1. Listing. R_k(n) is the set of rows of G_n with a forward and a backward walk of length k = 32. It is listed by
     SAT (pysat's CaDiCaL 1.9.5) on a window of 2k+1 rows, blocking each centre row once found. New here: four middle
     free bits of the centre row split the listing into 16 cubes, run in parallel. A cube is complete only when the
     solver reports no further centre row in it.
  2. Certificate. When all 16 cubes complete, one more solve must be UNSAT: CaDiCaL 3.0.1 with --check (internal
     DRAT and LRAT checking) on the window plus every blocking clause. Only then does the listing count as complete.
  3. The cyclic part of G_n is the cyclic part of the graph on R_k, since every cycle of G_n lies in R_k.
  4. The swap test (R40, M44 B) runs in the pair graph of each component. For every pair component with a swappable
     pair, an exact walk is taken: BFS from (x, y) to (y, x) gives a closed walk of 2h rows. Reported: h; the
     source's least period and parity; the walk's interior coverage; its reset-free rows; and whether the pair
     component is one cycle (a single doubling up to rotation) or branches (doublings of unboundedly many periods).
I2's corrections.
  - An interrupted or capped listing is UNKNOWN and supports no exclusion.
  - A positive hit needs the exact walk and its coverage (item 4).
  - The two SAT families of M44 A are reported separately, in the post.
Order and time box. Gaps run one at a time from 51 upwards, each with its 16 cubes on the workers, under a per-gap
limit. The scan stops at the first gap that does not complete (K8: "stop there and say so"), or when the total box
is spent.
Controls, run before the scan.
  C1. The cube listing and certificate reproduce M44 B's cyclic rows exactly at gaps 45 and 50 (core-31-50-rows.jsonl).
  C2. K7's three single-pulse doublings are rebuilt by plain simulation from the sources 001, 0001 and 000001. Each
      must return to white exactly at gap 56, 88 or 98 (half-periods 3, 4 and 6). The window encoding must admit each
      of their rows as the centre row (a satisfiable window).
Predictions (written before the run).
  1. Both controls pass (95%).
  2. At every decided gap, no doubling has a source period of 29 or more. The answer to K8's question is no (98%).
  3. If gap 56 is decided, its only swappable pairs are the single-pulse P = 3 doubling: h = 3, one pair cycle, whole,
     with no reset-free row (90%).
  4. At every decided gap other than 56, 88 and 98, no component has a swappable pair (85%).
  5. Every gap whose cubes complete also passes the certificate (97%).
  6. The scan decides every gap from 51 through 55 at least (50%).
  7. Every decided gap has a cyclic part of at most 2,000 rows (75%).
Kill: a doubling with source period >= 29 at a decided gap. If it is dyadic, and a whole walk carries a reset-free
row, it is a counterexample to the doubling lemma.
Usage:
  claudeM5_b2_cyclic.py run OUTDIR M44_ROWS_JSONL [--k 32] [--jobs 9] [--gap-limit 10800] [--box 18000] [--gmax 100]
  claudeM5_b2_cyclic.py cube N K CUBE OUTFILE     (one cube's listing; used by run)
"""
import argparse, json, math, os, re, subprocess, sys, time
from collections import deque
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from claudeM5_core_window import window, succs                      # noqa: E402  (M44, unchanged)
from claudeM5_gap_audit import lift                                 # noqa: E402  (M42, unchanged)

BAD = re.compile(r'01(?:111)*0')
NCUBE_BITS = 4


def free_vars(v, n, k):
    return [v[k][1]] + [v[k][j] for j in range(3, n - 1)]


def cube_lits(v, n, k, cube):
    j0 = n // 2 - 1
    return [(v[k][j0 + i] if (cube >> i) & 1 else -v[k][j0 + i]) for i in range(NCUBE_BITS)]


def run_cube(n, k, cube, outfile):
    from pysat.solvers import Solver
    v, cl = window(n, k)
    free = free_vars(v, n, k)
    with open(outfile, 'w') as fh, Solver(name='cd19', bootstrap_with=cl) as s:
        for lit in cube_lits(v, n, k, cube):
            s.add_clause([lit])
        count = 0
        while s.solve():
            m = s.get_model()
            val = {abs(x): x > 0 for x in m}
            row = ''.join(str(int(val[v[k][j]])) for j in range(n + 1))
            fh.write(row + '\n')
            fh.flush()
            count += 1
            s.add_clause([-x if val[x] else x for x in free])
        fh.write('#complete %d\n' % count)


def read_cube(path):
    rows, complete = [], False
    if not os.path.exists(path):
        return rows, False
    for line in open(path):
        line = line.strip()
        if line.startswith('#complete'):
            complete = True
        elif line:
            rows.append(line)
    return rows, complete


def certificate(n, k, rows, path, limit):
    v, cl = window(n, k)
    free = free_vars(v, n, k)
    idx = [1] + list(range(3, n - 1))
    for r in rows:
        cl.append([-v[k][j] if r[j] == '1' else v[k][j] for j in idx])
    nv = v[-1][-1]
    with open(path, 'w') as fh:
        fh.write(f'p cnf {nv} {len(cl)}\n')
        for c in cl:
            fh.write(' '.join(map(str, c)) + ' 0\n')
    t0 = time.time()
    try:
        p = subprocess.run(['cadical', '-q', '--check', '-t', str(int(limit)), path], capture_output=True, text=True,
                           timeout=limit + 120)
        out = p.stdout
    except subprocess.TimeoutExpired:
        out = ''
    os.remove(path)
    st = 'UNSAT' if re.search(r'^s UNSATISFIABLE', out, re.M) else ('SAT' if re.search(r'^s SATISFIABLE', out, re.M)
                                                                    else 'UNKNOWN')
    return st, round(time.time() - t0, 1)


def listing(n, k, outdir, jobs, limit):
    """16 cube jobs in parallel under one wall-clock limit; returns rows, complete flag, seconds."""
    t0 = time.time()
    paths = [os.path.join(outdir, f'gap{n}-cube{c}.rows') for c in range(1 << NCUBE_BITS)]

    def one(c):
        left = limit - (time.time() - t0)
        if left <= 0:
            return
        p = subprocess.Popen([sys.executable, os.path.abspath(__file__), 'cube', str(n), str(k), str(c), paths[c]],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        try:
            p.wait(timeout=left)
        except subprocess.TimeoutExpired:
            p.kill()
            p.wait()
    with ThreadPoolExecutor(max_workers=jobs) as ex:
        list(ex.map(one, range(1 << NCUBE_BITS)))
    rows, complete = [], True
    for pth in paths:
        r, c = read_cube(pth)
        rows += r
        complete &= c
    return sorted(set(rows)), complete, round(time.time() - t0, 1)


def tup(r):
    return tuple(int(c) for c in r)


def sccs(nodes, E):
    idx, low, st, on, comps, c = {}, {}, [], set(), [], [0]
    for root in nodes:
        if root in idx:
            continue
        stack = [(root, iter(E[root]))]
        idx[root] = low[root] = c[0]; c[0] += 1; st.append(root); on.add(root)
        while stack:
            v, it = stack[-1]
            nxt = next(it, None)
            if nxt is not None:
                if nxt not in idx:
                    idx[nxt] = low[nxt] = c[0]; c[0] += 1; st.append(nxt); on.add(nxt)
                    stack.append((nxt, iter(E[nxt])))
                elif nxt in on:
                    low[v] = min(low[v], idx[nxt])
            else:
                stack.pop()
                if stack:
                    low[stack[-1][0]] = min(low[stack[-1][0]], low[v])
                if low[v] == idx[v]:
                    comp = []
                    while True:
                        x = st.pop(); on.discard(x); comp.append(x)
                        if x == v:
                            break
                    comps.append(comp)
    return comps


def period(comp, E):
    S = set(comp); d = {comp[0]: 0}; q = deque([comp[0]]); g = 0
    while q:
        u = q.popleft()
        for v in E[u]:
            if v not in S:
                continue
            if v not in d:
                d[v] = d[u] + 1; q.append(v)
            else:
                g = math.gcd(g, d[u] + 1 - d[v])
    return abs(g)


def cyclic_components(rows, n):
    S = set(rows)
    E = {w: [x for x in succs(w, n) if x in S] for w in rows}
    comps = sccs(rows, E)
    return [C for C in comps if len(C) > 1 or C[0] in E[C[0]]], E


def least_period(seq):
    T = len(seq)
    return next(p for p in range(1, T + 1) if T % p == 0 and all(seq[i] == seq[(i + p) % T] for i in range(T)))


def analyze(n, comps, E):
    full = (1 << n) - 2
    rmask = lambda w: sum(w[i] << i for i in range(1, n))
    bad = lambda w: not BAD.search(''.join(map(str, w)))
    out = []
    for C in comps:
        S = set(C)
        EC = {w: [x for x in E[w] if x in S] for w in C}
        cover = 0
        for w in C:
            cover |= rmask(w)
        rec = {'size': len(C), 'period': period(C, EC), 'whole': cover == full, 'bad': sum(bad(w) for w in C),
               'swaps': []}
        P = [(x, y) for x in C for y in C if x[1] != y[1]]
        PE = {(x, y): [(a, b) for a in EC[x] for b in EC[y] if a[1] != b[1]] for x, y in P}
        for D in sccs(P, PE):
            Dset = set(D)
            if len(D) == 1 and D[0] not in PE[D[0]]:
                continue
            sw = [(x, y) for x, y in D if (y, x) in Dset]
            if not sw:
                continue
            bsw = [(x, y) for x, y in sw if bad(x)]
            x0, y0 = (bsw or sw)[0]
            prev = {(x0, y0): None}; q = deque([(x0, y0)])
            while q:
                u = q.popleft()
                if u == (y0, x0) and u != (x0, y0):
                    break
                for v in PE[u]:
                    if v in Dset and v not in prev:
                        prev[v] = u; q.append(v)
            path, u = [], (y0, x0)
            while u is not None:
                path.append(u); u = prev[u]
            path.reverse()
            h = len(path) - 1
            walk = [p[0] for p in path] + [p[1] for p in path[1:]]      # w_0 .. w_2h, w_2h = w_0
            assert walk[-1] == walk[0] and len(walk) == 2 * h + 1
            walk = walk[:-1]
            ok = all(walk[(t + 1) % (2 * h)] in succs(walk[t], n) for t in range(2 * h))
            ok &= all(walk[(t + h) % (2 * h)][1] != walk[t][1] for t in range(2 * h))
            e = [walk[(t + 1) % (2 * h)][1] ^ walk[t][1] for t in range(2 * h)]
            lp = least_period(e)
            wcov = 0
            for w in walk:
                wcov |= rmask(w)
            single = all(len([v for v in PE[u] if v in Dset]) == 1 for u in D)
            rec['swaps'].append({'pairs': len(D), 'swappable': len(sw), 'swappable_bad': len(bsw), 'h': h,
                                 'walk_ok': ok, 'source_least_period': lp, 'source_parity': sum(e[:lp]) % 2,
                                 'walk_whole': wcov == full, 'walk_reset_free_rows': sum(bad(w) for w in walk),
                                 'single_cycle': single,
                                 'walk': [''.join(map(str, w)) for w in walk] if h <= 16 else None})
        out.append(rec)
    return out


def single_pulse(P, gmax=200):
    """Rebuild the doubling from the source with one black tick per period P; returns (gap, rows)."""
    T = 2 * P
    src = [1 if t % P == 0 else 0 for t in range(T)]
    cols = [src, src, [0] * T, lift(src, [0] * T, T, 0)]      # wheels A-2, A-1, A, A+1
    while len(cols) - 2 <= gmax:
        cols.append(lift(cols[-2], cols[-1], T))
        if not any(cols[-1]):
            break
    A = 2
    g = len(cols) - 1 - A
    rows = [''.join(str(cols[A + i][t]) for i in range(g + 1)) for t in range(T)]
    return g, rows


def control_c2(k):
    from pysat.solvers import Solver
    res = []
    for P, gexp in ((3, 56), (4, 88), (6, 98)):
        g, rows = single_pulse(P)
        rec = {'P': P, 'gap': g, 'expected_gap': gexp, 'rows': len(rows),
               'reset_free_rows': sum(not BAD.search(r) for r in rows)}
        whole = all(any(r[i] == '1' for r in rows) for i in range(1, g))
        rec['whole'] = whole
        if g == gexp:
            v, cl = window(g, k)
            sat = []
            for r in rows:
                with Solver(name='cd19', bootstrap_with=cl) as s:
                    for j in range(g + 1):
                        s.add_clause([v[k][j] if r[j] == '1' else -v[k][j]])
                    sat.append(s.solve())
            rec['window_sat_all_rows'] = all(sat)
        res.append(rec)
    ok = all(r['gap'] == r['expected_gap'] and r.get('window_sat_all_rows') for r in res)
    return ok, res


def do_gap(n, k, outdir, jobs, limit):
    rows, complete, secs = listing(n, k, outdir, jobs, limit)
    rec = {'gap': n, 'k': k, 'R_k': len(rows), 'cubes_complete': complete, 'listing_seconds': secs}
    if not complete:
        rec['status'] = 'UNKNOWN'
        return rec, None
    st, csecs = certificate(n, k, rows, os.path.join(outdir, f'gap{n}-cert.cnf'), limit)
    rec['certificate'] = st
    rec['certificate_seconds'] = csecs
    if st != 'UNSAT':
        rec['status'] = 'UNKNOWN'
        return rec, None
    comps, E = cyclic_components([tup(r) for r in rows], n)
    rec['status'] = 'DECIDED'
    rec['cyclic_rows'] = sum(len(C) for C in comps)
    rec['components'] = analyze(n, comps, E)
    swaps = [s for c in rec['components'] for s in c['swaps']]
    rec['doublings'] = [{'h': s['h'], 'P': s['source_least_period'], 'single_cycle': s['single_cycle'],
                         'whole': s['walk_whole'], 'reset_free_rows': s['walk_reset_free_rows']} for s in swaps]
    rec['answer_P_ge_29'] = any(s['source_least_period'] >= 29 or not s['single_cycle'] for s in swaps)
    return rec, [[''.join(map(str, w)) for w in C] for C in comps]


def main_run(a):
    os.makedirs(a.outdir, exist_ok=True)
    t0 = time.time()
    summ = {'k': a.k, 'jobs': a.jobs, 'gap_limit': a.gap_limit, 'box': a.box}
    # C2 first (cheap), then C1
    ok2, c2 = control_c2(a.k)
    summ['C2_ok'] = ok2
    summ['C2'] = c2
    print(json.dumps({'C2_ok': ok2, 'C2': c2}), flush=True)
    m44 = {}
    for line in open(a.m44_rows):
        d = json.loads(line)
        m44[d['gap']] = sorted(sorted(C) for C in d['components'])
    c1 = []
    for n in (45, 50):
        rec, comps = do_gap(n, a.k, a.outdir, a.jobs, a.gap_limit)
        same = comps is not None and sorted(sorted(C) for C in comps) == m44[n]
        c1.append({'gap': n, 'status': rec['status'], 'certificate': rec.get('certificate'), 'R_k': rec['R_k'],
                   'cyclic_rows': rec.get('cyclic_rows'), 'equal_to_M44': same,
                   'seconds': rec['listing_seconds'] + rec.get('certificate_seconds', 0)})
        print(json.dumps(c1[-1]), flush=True)
    summ['C1_ok'] = all(c['equal_to_M44'] for c in c1)
    summ['C1'] = c1
    scan = []
    for n in range(51, a.gmax + 1):
        if time.time() - t0 > a.box:
            summ['stopped'] = f'box spent before gap {n}'
            break
        rec, comps = do_gap(n, a.k, a.outdir, a.jobs, min(a.gap_limit, a.box - (time.time() - t0)))
        with open(os.path.join(a.outdir, f'gap{n}.json'), 'w') as fh:
            json.dump({'record': rec, 'cyclic_components': comps}, fh)
        brief = {x: rec.get(x) for x in ('gap', 'status', 'R_k', 'certificate', 'cyclic_rows', 'doublings',
                                         'answer_P_ge_29', 'listing_seconds', 'certificate_seconds')}
        scan.append(brief)
        print(json.dumps(brief), flush=True)
        if rec['status'] != 'DECIDED':
            summ['stopped'] = f'gap {n} did not complete'
            break
    dec = [r for r in scan if r['status'] == 'DECIDED']
    summ['decided_through'] = dec[-1]['gap'] if dec and dec[-1]['gap'] == 50 + len(dec) else None
    summ['scan'] = scan
    summ['verdicts'] = {
        '1_controls': summ['C1_ok'] and ok2,
        '2_no_doubling_P_ge_29': not any(r['answer_P_ge_29'] for r in dec),
        '3_gap56_single_pulse_only': None if not any(r['gap'] == 56 for r in dec) else
            [r for r in dec if r['gap'] == 56][0]['doublings'] == [{'h': 3, 'P': 3, 'single_cycle': True,
                                                                     'whole': True, 'reset_free_rows': 0}],
        '4_no_swaps_elsewhere': all(not r['doublings'] for r in dec if r['gap'] not in (56, 88, 98)),
        '5_certificates': all(r['certificate'] == 'UNSAT' for r in scan if r['certificate'] is not None),
        '6_decided_51_55': all(any(r['gap'] == g for r in dec) for g in range(51, 56)),
        '7_cyclic_le_2000': all(r['cyclic_rows'] <= 2000 for r in dec)}
    summ['seconds'] = round(time.time() - t0, 1)
    with open(os.path.join(a.outdir, 'summary.json'), 'w') as fh:
        json.dump(summ, fh, indent=1)
    print(json.dumps(summ['verdicts']), flush=True)


def main():
    if len(sys.argv) > 1 and sys.argv[1] == 'cube':
        run_cube(int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5])
        return
    ap = argparse.ArgumentParser()
    ap.add_argument('mode')
    ap.add_argument('outdir')
    ap.add_argument('m44_rows')
    ap.add_argument('--k', type=int, default=32)
    ap.add_argument('--jobs', type=int, default=9)
    ap.add_argument('--gap-limit', type=float, default=10800)
    ap.add_argument('--box', type=float, default=18000)
    ap.add_argument('--gmax', type=int, default=100)
    a = ap.parse_args()
    main_run(a)


if __name__ == '__main__':
    main()
