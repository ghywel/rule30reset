"""Analysis of the K92.1 floor runs (ledger N36, claudeIntel): fits, first-moment slopes, the registered tests.

usage: python -I claudeIntel_ladder_analysis.py DIR OUT.json
DIR holds long_<LANG>_B<budget>.txt from claudeIntel_ladder.cpp and strip_count_22.txt from
claudeIntel_strip_count.cpp.
"""
import glob, itertools, json, math, os, sys

def h2(x):
    return -x * math.log2(x) - (1 - x) * math.log2(1 - x)

def h2inv(t):
    lo, hi = 1e-12, 0.5
    for _ in range(200):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if h2(mid) < t else (lo, mid)
    return lo

def first_moment(per_reading):
    return h2inv(1 - 0.5 * math.log2(per_reading))

def spectral_growth(gaps, forbidden, k, pairs=None):
    """Growth per reading of an anchored gap language: states are the last k gaps; edge weight z^g.
    Found as 1/z at the z where the transfer matrix has spectral radius one (power iteration)."""
    states = list(itertools.product(gaps, repeat=k))
    idx = {s: i for i, s in enumerate(states)}
    def ok(s, g):
        if pairs is not None and (s[-1], g) not in pairs:
            return False
        w = ''.join(map(str, s + (g,)))
        return not any(w.endswith(f) for f in forbidden)
    edges = [(idx[s], idx[s[1:] + (g,)], g) for s in states for g in gaps if ok(s, g)]
    def rad(z):
        v = [1.0] * len(states)
        r = 0.0
        for _ in range(3000):
            w = [0.0] * len(states)
            for i, j, g in edges:
                w[j] += v[i] * z ** g
            r = max(w)
            v = [x / r for x in w]
        return r
    lo, hi = 0.2, 1.0
    for _ in range(60):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if rad(mid) < 1 else (lo, mid)
    return 1 / lo

def word_counts(lang, M):
    """ln of the number of words of m readings, m <= M, by dynamic programming over the clock's states
    (the same acceptance as the search: kicks by the language's rule, quiet readings while the clock allows)."""
    PAIRS = {(2, 2), (2, 4), (2, 5), (3, 3), (3, 5), (4, 5), (5, 2), (5, 3), (5, 5)}
    TRAP = ['333', '3353', '3533', '3553', '5533']
    forb = TRAP + (['3535353'] if lang == 'CORE' else [])
    def kick_ok(since, gaps):
        if lang == 'GE2':
            return 2 <= since <= 5 and (not gaps or (gaps[-1], since) in PAIRS)
        if since not in (3, 5):
            return False
        if lang == 'GAP35':
            return True
        s = ''.join(map(str, gaps + (since,)))
        return not any(s.endswith(f) for f in forb)
    keep = {'GE2': 1, 'GAP35': 0, 'WORDS': 3, 'CORE': 6}[lang]
    cur = {(1, ()): 1}
    out = [0.0, 0.0]
    for m in range(2, M + 1):
        nxt = {}
        for (since, gaps), c in cur.items():
            if kick_ok(since, gaps):
                g = (gaps + (since,))[-keep:] if keep else ()
                nxt[(1, g)] = nxt.get((1, g), 0) + c
            if since <= 4:
                nxt[(since + 1, gaps)] = nxt.get((since + 1, gaps), 0) + c
        cur = nxt
        out.append(math.log(sum(cur.values())))
    return out

def load(path):
    d = {}
    for line in open(path, encoding='utf-8'):
        if line.startswith('#'):
            continue
        f = line.split()
        if not f[1].startswith('>'):
            d[int(f[0])] = (int(f[1]), f[3])
    return d

def fit(d, lo, hi):
    xs = [h for h in sorted(d) if lo <= h <= hi]
    n = len(xs)
    mx = sum(xs) / n
    my = sum(d[h] for h in xs) / n
    s = sum((h - mx) * (d[h] - my) for h in xs) / sum((h - mx) ** 2 for h in xs)
    c = my - s * mx
    return {'from': xs[0], 'to': xs[-1], 'slope': round(s, 5), 'intercept': round(c, 3),
            'max_dev': round(max(abs(d[h] - s * h - c) for h in xs), 3)}

def main():
    top, out = sys.argv[1], sys.argv[2]
    TRAP = ['333', '3353', '3533', '3553', '5533']
    PAIRS = {(2, 2), (2, 4), (2, 5), (3, 3), (3, 5), (4, 5), (5, 2), (5, 3), (5, 5)}
    growth = {
        'G': (1 + 5 ** 0.5) / 2,
        'GE2': spectral_growth([2, 3, 4, 5], [], 1, PAIRS),
        'GAP35': spectral_growth([3, 5], [], 1),
        'WORDS': spectral_growth([3, 5], TRAP, 3),
        'CORE': spectral_growth([3, 5], TRAP + ['3535353'], 6),
    }
    res = {'languages': {}}
    tables = {}
    for lang in ['GE2', 'GAP35', 'WORDS', 'CORE']:
        files = sorted(glob.glob(os.path.join(top, 'long_%s_B*.txt' % lang)))
        d = {h: w for h, (w, _) in load(files[-1]).items()}
        wit = load(files[-1])
        tables[lang] = d
        last = max(d)
        r = {'file': os.path.basename(files[-1]), 'exact_through': last, 'least_weight_at_last': d[last],
             'growth_per_reading': round(growth[lang], 6), 'first_moment_slope': round(first_moment(growth[lang]), 4),
             'fit_100_last': fit(d, 100, last), 'fit_200_last': fit(d, 200, last),
             'minimiser_gaps_at_last': wit[last][1]}
        res['languages'][lang] = r
    res['languages']['G'] = {'growth_per_reading': round(growth['G'], 6),
                             'first_moment_slope': round(first_moment(growth['G']), 4), 'ether_density': round(1 / 7, 4)}
    ge2, g35, wo, co = tables['GE2'], tables['GAP35'], tables['WORDS'], tables['CORE']
    L = {}
    f = fit(ge2, 200, max(ge2)); L['L1'] = {'slope_200_last': f['slope'], 'held': abs(f['slope'] - 0.2486) <= 0.01}
    dev = [abs(ge2[h] - (0.2527 * h + 5.06)) for h in ge2 if h >= 260]
    L['L2'] = {'max_dev_260_last': round(max(dev), 3) if dev else None, 'held': bool(dev) and max(dev) <= 2}
    f = fit(g35, 250, max(g35)); L['L3'] = {'slope_250_last': f['slope'], 'held': abs(f['slope'] - 0.2927) <= 0.01}
    band = [g35[h] - 0.307 * h for h in g35 if h >= 346]
    L['L4'] = {'range_346_last': [round(min(band), 3), round(max(band), 3)] if band else None,
               'held': bool(band) and min(band) >= 1 and max(band) <= 8}
    fw, fc = fit(wo, 300, max(wo)), fit(co, 300, max(co))
    L['L5'] = {'WORDS_slope_300_last': fw['slope'], 'CORE_slope_300_last': fc['slope'],
               'held': abs(fw['slope'] - 0.3497) <= 0.01 and abs(fc['slope'] - 0.3527) <= 0.01}
    hs = sorted(g35)
    tail = [g35[h] - 0.2927 * h for h in hs[-50:]]
    early = [g35[h] - 0.2927 * h for h in hs if 150 <= h <= 200]
    L['L6'] = {'mean_last50': round(sum(tail) / len(tail), 3), 'mean_150_200': round(sum(early) / len(early), 3),
               'held': sum(tail) / len(tail) > sum(early) / len(early)}
    sc = os.path.join(top, 'strip_count_22.txt')
    if os.path.exists(sc):
        rows = [tuple(map(float, l.split())) for l in open(sc) if l[0] != '#']
        ms = [r for r in rows if r[0] >= 60]
        if len(ms) >= 20:
            a, b = ms[-21], ms[-1]
            per = (b[1] / a[1]) ** (1 / (b[0] - a[0]))
            x = first_moment(per)
            L['L7'] = {'readings': [int(a[0]), int(b[0])], 'growth_per_reading': round(per, 6),
                       'first_moment_slope': round(x, 4), 'strip_min_slope_200_300': 0.37,
                       'held': abs(x - 0.37) <= 0.03}
    # L8: the annealed test, from the whole weight distributions
    ann = {}
    for lang in ['GE2', 'GAP35', 'WORDS', 'CORE']:
        p = os.path.join(top, 'dist_%s.txt' % lang)
        if not os.path.exists(p):
            continue
        rows = {}
        for line in open(p):
            if line[0] == '#':
                continue
            f = line.split()
            rows[int(f[0])] = {int(a): int(b) for a, b in (x.split(':') for x in f[1:])}
        H = max(rows)
        dist = rows[H]
        N = sum(dist.values())
        lnZ = math.log(sum(c * 0.5 ** w for w, c in dist.items()))
        E = lnZ - math.log(N) - H * math.log(0.75)
        # cross-check: least weight with a word equals the search's least weight
        agree = all(min(rows[h]) == tables[lang][h] for h in rows if h in tables[lang])
        Emax = max(math.log(sum(c * z ** w for w, c in rows[h].items())) - math.log(sum(rows[h].values()))
                   - h * math.log((1 + z) / 2) for h in rows for z in (0.25, 0.5, 0.75))
        ann[lang] = {'H': H, 'words': N, 'least_weight': min(dist), 'annealed_excess': round(E, 3),
                     'excess_per_tick': round(E / H, 5), 'max_excess_all_H_z_quarter_half_three_quarters': round(Emax, 3),
                     'least_weights_agree_with_search': agree}
    if ann:
        L['L8'] = {'by_language': ann, 'held': all(abs(v['excess_per_tick']) <= 0.01 for v in ann.values())}
    res['predictions'] = L

    # After the registration (not a registered test): the log correction and the annealed law's floor.
    post = {}
    for lang in ['GE2', 'GAP35', 'WORDS', 'CORE']:
        d = tables[lang]
        x = first_moment(growth[lang])
        theta = math.log((1 - x) / x)
        xs = [h for h in sorted(d) if h >= 100]
        # least squares for m - x H = c ln H + k
        u = [math.log(h) for h in xs]
        v = [d[h] - x * h for h in xs]
        mu, mv = sum(u) / len(u), sum(v) / len(v)
        c = sum((a - mu) * (b - mv) for a, b in zip(u, v)) / sum((a - mu) ** 2 for a in u)
        k = mv - c * mu
        dev = max(abs(b - c * a - k) for a, b in zip(u, v))
        # the floor the annealed law Z_H(z) <= e^0.3 N(H) ((1+z)/2)^H would prove, with N(H) counted exactly
        N = word_counts(lang, max(d) // 2)
        lnC = ann[lang]['max_excess_all_H_z_quarter_half_three_quarters'] if lang in ann else 1.2
        gaps = []
        for h in xs[::max(1, len(xs) // 12)] + [xs[-1]]:
            lnN = N[h // 2]
            best = 0
            for A in range(d[h], -1, -1):
                bound = min(-A * math.log(z) + lnC + lnN + h * math.log((1 + z) / 2) for z in [i / 400 for i in range(1, 400)])
                if bound < 0:
                    best = A + 1
                    break
            gaps.append((h, d[h], best))
        post[lang] = {'first_moment_slope': round(x, 4), 'bramson_coefficient_3_over_2theta': round(1.5 / theta, 3),
                      'fitted_log_coefficient': round(c, 3), 'constant': round(k, 3), 'max_dev': round(dev, 3),
                      'annealed_constant_lnC': lnC,
                      'annealed_floor_vs_exact': gaps}
    res['after_registration'] = post
    sel = [100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700]
    res['table'] = {h: {lang: tables[lang].get(h) for lang in tables} for h in sel}
    json.dump(res, open(out, 'w', encoding='utf-8', newline='\n'), indent=1)
    print(json.dumps(res, indent=1))

if __name__ == '__main__':
    main()
