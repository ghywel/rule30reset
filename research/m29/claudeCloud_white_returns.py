#!/usr/bin/env python3
"""claudeCloud_white_returns.py: the driver for claudeCloud_white_returns.c, and the seed's own strip (K2).

Part 1, random excursions. For each (Q, parity) of the frozen grid, run the C probe and collect the gap to the next
white wheel and each tick's first closed reset. Tests the counting picture: a white interval of temporal period Q
returns to white at a rate of about 2^-Q per wheel (the next white needs two consecutive wheels to agree on all Q
ticks), so the gap is near-geometric with mean about 2^Q; a doubling (odd source of period P) has Q = 2P. Within a
tick's row, the stretch before the first closed reset decays like a fair-coin string's, at the rate lambda* that
solves 4 l^3 - 2 l^2 - 1 = 0 (lambda* = 0.84780...), from the 4-state run-residue automaton.

Part 2, the seed. Strip A0 from the kit: iterate v -> 4v XOR (2v OR v) mod 2^87867 from v = 1 (Rule30FourLeftSides,
Rule30SeedLeftSide: the seed is A0 from tick 177,560 on). Bit j of v is wheel j. Read the 16-tick cycle, its white
wheels, and for each white interval [A, B]: the source D_(A-1) (least period, weight), the interval's period,
the gap against 2^Q, and every tick's first closed reset.

  python3 claudeCloud_white_returns.py BUILD_DIR OUT.json [--workers 4]
"""
import argparse, hashlib, json, math, os, subprocess, sys, time
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, 'claudeCloud_white_returns.c')

# frozen grid: (Q, parity, samples); cap = 40 * 2^Q wheels; seeds fixed
GRID = [(Q, 'even', n) for Q, n in ((4, 20000), (6, 20000), (8, 20000), (10, 20000), (12, 20000), (14, 20000),
                                     (16, 10000), (18, 4000), (20, 2000), (22, 800), (24, 300))] + \
       [(Q, 'odd', n) for Q, n in ((4, 20000), (6, 20000), (8, 20000), (10, 20000), (12, 20000), (14, 20000),
                                    (16, 10000), (18, 4000), (20, 2000), (22, 800), (24, 300))]
LAMBDA = None


def lambda_star():
    lo, hi = 0.5, 1.0                     # 4 l^3 - 2 l^2 - 1 is increasing on [0.5, 1]
    for _ in range(200):
        m = (lo + hi) / 2
        if 4 * m ** 3 - 2 * m ** 2 - 1 < 0:
            lo = m
        else:
            hi = m
    return lo


def run_probe(binary, Q, parity, n, seed):
    cap = 40 * (1 << Q)
    t0 = time.time()
    out = subprocess.run([binary, str(Q), parity, str(n), str(cap), str(seed)], capture_output=True, text=True, check=True)
    r = json.loads(out.stdout)
    r['seconds'] = round(time.time() - t0, 2)
    r['seed'] = seed
    return r


def tail_rate(hist, min_count=200, start=15):
    """Survival S(L) = ticks whose first reset closes beyond wheel L. Least-squares slope of log S over the
    window L >= start where S(L) >= min_count; returns (rate, L_lo, L_hi) or None."""
    tot = sum(hist)
    S, acc = [], 0
    for L in range(len(hist)):
        acc += hist[L]
        S.append(tot - acc)               # resolved strictly beyond L
    pts = [(L, math.log(S[L])) for L in range(start, len(S)) if S[L] >= min_count]
    if len(pts) < 5:
        return None
    n = len(pts)
    mx = sum(p[0] for p in pts) / n
    my = sum(p[1] for p in pts) / n
    sxy = sum((p[0] - mx) * (p[1] - my) for p in pts)
    sxx = sum((p[0] - mx) ** 2 for p in pts)
    return math.exp(sxy / sxx), pts[0][0], pts[-1][0]


def runs_first_reset(bits):
    """bits: list of 0/1 from wheel A (white) inward. Wheel index of the white cell closing the first black run of
    length 1 mod 3, or None."""
    run = 0
    for j, b in enumerate(bits):
        if b:
            run += 1
        else:
            if run % 3 == 1:
                return j
            run = 0
    return None


def least_period(w):
    T = len(w)
    for p in range(1, T + 1):
        if T % p == 0 and all(w[t] == w[(t + p) % T] for t in range(T)):
            return p
    return T


def seed_strip(width=87867, settle=177560):
    mask = (1 << width) - 1
    v = 1
    for _ in range(settle):
        v = ((v << 2) ^ ((v << 1) | v)) & mask
    rows = []
    for _ in range(32):
        rows.append(v)
        v = ((v << 2) ^ ((v << 1) | v)) & mask
    period = next(p for p in range(1, 33) if all(rows[t] == rows[(t + p) % 32] for t in range(32 - p)))
    cyc = rows[:period]
    union = 0
    for r in cyc:
        union |= r
    whites = [j for j in range(width) if not (union >> j) & 1]
    D = lambda j: [(r >> j) & 1 for r in cyc]
    intervals = []
    for A, B in zip(whites, whites[1:]):
        src = D(A - 1)
        Q = 1
        for j in range(A, B + 1):
            p = least_period(D(j))
            Q = Q * p // math.gcd(Q, p)
        first = []
        free = []
        for t in range(period):
            row = [(cyc[t] >> j) & 1 for j in range(A, B + 1)]
            f = runs_first_reset(row)
            if f is None:
                free.append(t)
            else:
                first.append(f)
        intervals.append({'A': A, 'B': B, 'gap': B - A, 'source_least_period': least_period(src),
                          'source_weight': sum(src) * least_period(src) // period, 'doubling': None,
                          'interval_period': Q, 'gap_over_2Q': (B - A) / 2 ** Q, 'reset_free_ticks': free,
                          'max_first_reset_depth': max(first) if first else None})
        s = intervals[-1]
        s['doubling'] = (s['source_weight'] % 2 == 1)
    h = hashlib.sha256(b''.join(r.to_bytes((width + 7) // 8, 'little') for r in cyc)).hexdigest()
    last = whites[-1]
    lsrc = D(last - 1)
    last_white = {'wheel': last, 'source_least_period': least_period(lsrc),
                  'source_weight': sum(lsrc) * least_period(lsrc) // period,
                  'doubling': (sum(lsrc) * least_period(lsrc) // period) % 2 == 1}
    return {'width': width, 'settle_ticks': settle, 'cycle_period': period, 'cycle_sha256': h, 'whites': whites,
            'intervals': intervals, 'last_white': last_white}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('build')
    ap.add_argument('out')
    ap.add_argument('--workers', type=int, default=4)
    a = ap.parse_args()
    os.makedirs(a.build, exist_ok=True)
    binary = os.path.join(a.build, 'white_returns')
    subprocess.run(['gcc', '-O2', '-Wall', '-o', binary, SRC, '-lm'], check=True)
    lam = lambda_star()
    t0 = time.time()
    jobs = [(Q, par, n, 1000 + 2 * Q + (par == 'odd')) for Q, par, n in GRID]
    jobs.sort(key=lambda j: -(j[2] << j[0]))          # longest first
    with ThreadPoolExecutor(a.workers) as ex:
        res = list(ex.map(lambda j: run_probe(binary, *j), jobs))
    res.sort(key=lambda r: (r['parity'], r['Q']))
    for r in res:
        tr = tail_rate(r['resolution_hist'])
        r['tail_rate'] = None if tr is None else {'rate': round(tr[0], 5), 'from': tr[1], 'to': tr[2]}
    seed = seed_strip()
    out = {'lambda_star': lam, 'probe_sha256': hashlib.sha256(open(SRC, 'rb').read()).hexdigest(),
           'driver_sha256': hashlib.sha256(open(os.path.abspath(__file__), 'rb').read()).hexdigest(),
           'seconds': round(time.time() - t0, 1), 'random_excursions': res, 'seed_strip_A0': seed}
    json.dump(out, open(a.out, 'w'), indent=1)
    print('lambda* = %.5f' % lam)
    print('%-5s %3s %3s %7s %6s %12s %8s %8s %6s %7s %6s %s' % ('par', 'Q', 'p', 'samples', 'cens', 'mean_gap',
          'mean/2^Q', 'med/ln2', 'cv', 'free', 'maxres', 'tail'))
    for r in res:
        t = r['tail_rate']
        print('%-5s %3d %3d %7d %6d %12.1f %8.3f %8.3f %6.3f %7d %6d %s' % (r['parity'], r['Q'], r['source_period'],
              r['samples'], r['censored'], r['mean_gap'], r['mean_over_2Q'], r['median_over_2Q_ln2'], r['cv'],
              r['returns_with_reset_free_tick'], r['max_resolution_depth'],
              '%.4f [%d,%d]' % (t['rate'], t['from'], t['to']) if t else '-'))
    print('seed strip A0: cycle period %d, whites %s' % (seed['cycle_period'], seed['whites']))
    for s in seed['intervals']:
        print('  [%d, %d] gap %d, source period %d weight %d (%s), interval period %d, gap/2^Q %.3f, '
              'reset-free ticks %s, max first reset at wheel %s' % (s['A'], s['B'], s['gap'], s['source_least_period'],
              s['source_weight'], 'doubling' if s['doubling'] else 'no doubling', s['interval_period'],
              s['gap_over_2Q'], s['reset_free_ticks'], s['max_first_reset_depth']))
    print('  last white %(wheel)d: source period %(source_least_period)d, weight %(source_weight)d, doubling %(doubling)s'
          % seed['last_white'])


if __name__ == '__main__':
    main()
