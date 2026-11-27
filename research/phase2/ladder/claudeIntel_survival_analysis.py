"""Score K92.2's registered tests (ledger N38) from the survival table and the coalescence runs.

usage: python -I claudeIntel_survival_analysis.py SURVIVAL_TABLE COAL_DIR OUT.json
"""
import json, math, os, statistics, sys

def main():
    table, cdir, out = sys.argv[1], sys.argv[2], sys.argv[3]
    rows = {}
    for line in open(table, encoding='utf-8'):
        if line[0] == '#':
            continue
        f = line.split()
        rows[int(f[0])] = (int(f[1]), [int(x) for x in f[3:]])
    N = max(rows)
    def A(n, k):
        return sum(rows[n][1][k:])
    res = {'N': N}
    # S1: k_max(n) - n on 33..N
    ex = {n: rows[n][0] - n for n in rows}
    res['S1'] = {'k_max_minus_n_33_N': {n: ex[n] for n in range(33, N + 1)},
                 'held': all(-8 <= ex[n] <= 0 for n in range(33, N + 1))}
    # S2: R(k, n) on A >= 64
    Rs = [(A(n, k) * 2.0 ** (k - n), n, k) for n in rows for k in range(0, rows[n][0] + 1) if A(n, k) >= 64]
    lo, hi = min(Rs), max(Rs)
    res['S2'] = {'min_R': [round(lo[0], 4), lo[1], lo[2]], 'max_R': [round(hi[0], 4), hi[1], hi[2]],
                 'held': lo[0] >= 0.25 and hi[0] <= 8}
    # S3: least theta for C = 1, 4, 16 on n = 10..N
    th = {}
    for C in (1, 4, 16):
        th[C] = max((A(n, k) / (C * 2 ** n)) ** (1 / k) for n in range(10, N + 1) for k in range(1, rows[n][0] + 1))
    res['S3'] = {'least_theta': {str(C): round(v, 4) for C, v in th.items()}, 'held': th[16] <= 0.53}
    # S4, S5 from the coalescence runs
    z = {}
    for n in (12, 20, 22, 24, 26):
        p = os.path.join(cdir, 'coal_%d.txt' % n)
        if not os.path.exists(p):
            continue
        L = [l.split() for l in open(p) if l[0] != '#']
        first = L[0]
        L12 = [x for x in L if int(x[0]) <= 12]
        z[n] = {'seeds': int(first[1]), 'distinct_rows': int(first[2]), 'mean_cluster': round(int(first[1]) / int(first[2]), 3),
                'median_abs_z_seeds': round(statistics.median(abs(float(x[5])) for x in L12), 3),
                'median_abs_z_rows': round(statistics.median(abs(float(x[6])) for x in L12), 3)}
    res['coalescence'] = z
    four = [z[n] for n in (20, 22, 24, 26) if n in z]
    res['S4'] = {'held': all(v['median_abs_z_rows'] <= 2 and v['median_abs_z_seeds'] > 4 for v in four),
                 'rows_part_held': all(v['median_abs_z_rows'] <= 2 for v in four),
                 'seeds_part_held': all(v['median_abs_z_seeds'] > 4 for v in four)}
    mc = [z[n]['mean_cluster'] for n in (12, 20, 22, 24, 26) if n in z]
    res['S5'] = {'mean_clusters': mc, 'held': all(a < b for a, b in zip(mc, mc[1:]))}
    # extinction against log2 of distinct rows, extrapolated at 1.762 per n from n = 26
    if 26 in z:
        D26 = z[26]['distinct_rows']
        res['extinction_vs_log2D'] = {n: [rows[n][0], round(math.log2(D26) + (n - 26) * math.log2(1.762), 2)]
                                      for n in range(27, N + 1)}
    res['per_n'] = {n: {'k_max': rows[n][0], 'A1': A(n, 1), 'A2': A(n, 2), 'A4': A(n, 4), 'A12': A(n, 12),
                        'R12': round(A(n, 12) * 2.0 ** (12 - n), 4)} for n in range(20, N + 1, 2)}
    json.dump(res, open(out, 'w', encoding='utf-8', newline='\n'), indent=1)
    print(json.dumps({k: v for k, v in res.items() if k != 'per_n'}, indent=1))

if __name__ == '__main__':
    main()
