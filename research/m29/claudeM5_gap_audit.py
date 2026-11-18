#!/usr/bin/env python3
"""Pull M29 (M42): audit R40's paired-row gap graph, then test (G), the gap bound for reset-free whole intervals.

Runs claudeM5_gap_audit (C, compiled separately) on the white-interval graph G_n at every gap n from 5 to NMAX; see
that file for the graph, the swap test and the self-checks. This driver adds the cross-checks:
  1. gptM5's own script (gptM5_white_gap_graph.py, cap 500,000) at gaps 5-19, field by field against mine at the
     same cap: nodes, cyclic, components, bad_cyclic, untested_pairs, swappable_pairs, swappable_bad_pairs.
  2. The census (M41): every reset-free whole interval it found at source periods 4, 8, 16 and 32 (gaps 7, 8, 14,
     16) is rebuilt from its source and lift; each reset-free row must be a bad row of a whole component of G_gap
     whose period (gcd of cycle lengths) is a power of two.
  3. Positive controls from the kit strip A0: its doublings at the whites 2 and 7 (gaps 5 and 21) give pairs
     (r_s, r_(s+P)) that must reach their swaps within P ticks in the pair graph.
Then (G): bad_whole(n), the reset-free rows on closed walks with no interior permanent white, and the same in
components of power-of-two period (the only ones a physical, dyadic excursion can use).
Predictions (written before the run):
  1. At gaps 5-19, swappable_bad_pairs = 0 at every gap, with no untested pairs at a cap of 2^26 (85%).
  2. My counts equal gptM5's script field by field at cap 500,000 (90%).
  3. Every self-check passes: the base partition (n <= 12), the pair BFS, exact walks inside swaps (97%).
  4. Every census row is a bad whole row of its gap in a component of power-of-two period (97%).
  5. Both kit doublings reach their swaps within P ticks (95%).
  6. (G): bad_whole_dyadic(n) = 0 at every gap 20 <= n <= NMAX (50%).
  Kill (the unrestricted doubling route): a swappable bad pair at some gap in a whole component of power-of-two period.
Usage: claudeM5_gap_audit.py AUDIT_BINARY LEANFILE CENSUS_CONTROL_JSONL CENSUS_32_JSON OUTFILE [--nmax 28]
"""
import argparse, json, os, subprocess, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from claudeM5_window_map import load_strips, phases, word    # noqa: E402

CAP_BIG = 1 << 26


def least_period_list(c):
    T = len(c)
    return next(p for p in range(1, T + 1) if T % p == 0 and all(c[t] == c[(t + p) % T] for t in range(T)))


def run_bin(binary, *args):
    out = subprocess.run([binary, *map(str, args)], capture_output=True, text=True, check=True).stdout
    return [json.loads(l) for l in out.splitlines() if l.strip()]


def lift(a, b, T, c0=None):
    if any(b):
        t0 = b.index(1)
        c = [None] * T
        c[(t0 + 1) % T] = 1 - a[t0]
        t = (t0 + 1) % T
        for _ in range(T - 1):
            c[(t + 1) % T] = a[t] ^ (b[t] | c[t])
            t = (t + 1) % T
        return c
    c = [c0]
    for t in range(T - 1):
        c.append(a[t] ^ c[t])
    return c


def census_rows(entry, P):
    """rows (as ints, bit i = wheel A + i) of a census reset-free excursion at its reset-free ticks."""
    T = 2 * P
    b = int(entry['b'], 16)
    src = [(b >> (t % P)) & 1 for t in range(T)]
    c0 = entry.get('c0', 0)
    cols = [src, src, [0] * T, lift(src, [0] * T, T, c0)]   # wheels A-2, A-1, A, A+1
    gap = entry['gap']
    while len(cols) - 2 <= gap:
        cols.append(lift(cols[-2], cols[-1], T))
    A = 2
    assert not any(cols[A + gap]) and all(any(cols[A + i]) for i in range(1, gap))
    bad = int(entry['bad'], 16)
    out = []
    for t in range(T):
        if (bad >> t) & 1:
            out.append(sum(cols[A + i][t] << i for i in range(gap + 1)))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('binary')
    ap.add_argument('leanfile')
    ap.add_argument('census_control')
    ap.add_argument('census32')
    ap.add_argument('outfile')
    ap.add_argument('--nmax', type=int, default=28)
    a = ap.parse_args()
    t0 = time.time()
    res = {}
    # my run at gptM5's cap, gaps 5-19, swap test on every bad component
    mine500 = {r['gap']: r for r in run_bin(a.binary, 'range', 5, 19, 500000, 19)}
    # gptM5's script at the same gaps
    gpt = {}
    proc = subprocess.run([sys.executable, os.path.join(HERE, 'gptM5_white_gap_graph.py'), *map(str, range(5, 20))],
                          capture_output=True, text=True, check=True)
    for l in proc.stdout.splitlines():
        r = json.loads(l)
        gpt[r['gap']] = r
    fields = ['nodes', 'cyclic', 'components', 'bad_cyclic', 'untested_pairs', 'swappable_pairs', 'swappable_bad_pairs']
    cmp = {n: {f: [mine500[n][f], gpt[n][f]] for f in fields} for n in range(5, 20)}
    res['vs_gptM5_cap500000'] = cmp
    res['vs_gptM5_equal'] = all(v[0] == v[1] for n in cmp for v in cmp[n].values())
    print(json.dumps({'vs_gptM5_equal': res['vs_gptM5_equal']}), flush=True)
    # my full run: big cap, swap test on every bad component to 19, on whole bad components above
    full = run_bin(a.binary, 'range', 5, a.nmax, CAP_BIG, 19)
    res['gaps'] = full
    for r in full:
        brief = {k: v for k, v in r.items() if k != 'bad_whole_rows'}
        print(json.dumps(brief), flush=True)
    by = {r['gap']: r for r in full}
    # census cross-check
    entries = []
    for l in open(a.census_control):
        d = json.loads(l)
        entries += [(d['P'], e) for e in d['bad']]
    d32 = json.load(open(a.census32))
    entries += [(32, e) for e in d32['bad']]
    miss, checked, nondyadic = [], 0, 0
    for P, e in entries:
        g = by[e['gap']]
        rows = {int(x.split(':')[0], 16): int(x.split(':')[1]) for x in g.get('bad_whole_rows', [])}
        for w in census_rows(e, P):
            checked += 1
            if w not in rows:
                miss.append([P, e['gap'], hex(w)])
            elif rows[w] == 0 or rows[w] & (rows[w] - 1):
                nondyadic += 1
    res['census_cross_check'] = {'rows_checked': checked, 'missing': miss[:20], 'missing_count': len(miss),
                                 'in_nondyadic_component': nondyadic}
    print(json.dumps(res['census_cross_check']), flush=True)
    # positive controls on the kit strip A0
    v = load_strips(a.leanfile)['A0']
    ph = [[int(ch) for ch in word(r)] for r in phases(v)[:16]]
    ctrl = []
    for A, B in ((2, 7), (7, 28)):
        n = B - A
        src = [ph[t][A - 1] for t in range(16)]
        P = least_period_list(src)
        child = [ph[t][A + 1] for t in range(16)]
        anti = all(child[(t + P) % 16] == 1 - child[t] for t in range(16))
        rows = [sum(ph[t][A + i] << i for i in range(n + 1)) for t in range(16)]
        for s in range(min(16, 2 * P)):
            x, y = rows[s], rows[(s + P) % 16]
            r = run_bin(a.binary, 'pair', n, format(x, 'x'), format(y, 'x'), max(P, 1))[0]
            ctrl.append({'A': A, 'B': B, 'P': P, 'antiperiodic': anti, 's': s, 'rows_valid': r['rows_valid'],
                         'swap_depth': r['swap_depth']})
    res['kit_doubling_controls'] = ctrl
    print(json.dumps(ctrl), flush=True)
    # verdicts
    low = [by[n] for n in range(5, 20)]
    high = [by[n] for n in range(20, a.nmax + 1)]
    res['verdicts'] = {
        '1_no_swappable_bad_5_19': all(r['swappable_bad_pairs'] == 0 and r['untested_pairs'] == 0 for r in low),
        '2_equal_to_gptM5': res['vs_gptM5_equal'],
        '3_selfchecks': all(r['base_selfcheck_ok'] and r['pair_selfcheck_ok'] and
                            r['exact_walk_rows_not_swappable'] == 0 for r in full),
        '4_census_rows_found': not miss and nondyadic == 0 and checked > 0,
        '5_kit_doublings_swap': all(c['antiperiodic'] and c['rows_valid'] and 1 <= c['swap_depth'] <= c['P']
                                    for c in ctrl),
        '6_G_no_bad_whole_dyadic_20_up': all(r['bad_whole_dyadic_period'] == 0 for r in high),
        'kill_swappable_bad_anywhere': [r['gap'] for r in full if r['swappable_bad_pairs'] > 0],
        'untested_anywhere': [r['gap'] for r in full if r['untested_pairs'] > 0]}
    res['seconds'] = round(time.time() - t0, 1)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res['verdicts']))


if __name__ == '__main__':
    main()
