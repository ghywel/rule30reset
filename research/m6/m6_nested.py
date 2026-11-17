#!/usr/bin/env python3
"""M6, second block: is one eternal row near-optimal at every horizon? (ledger M19)

Every survivor to horizon H is a prefix of an eternal row (extend its accepted trace by any accepted continuation;
seedOfTrace gives one 2-adic seed). So the least mass mu(H) = min popcount(y), over canonical survivors y < 2^H, is
the least prefix mass over all eternal rows. M6's claim, that the floor is set by one sparsest eternal row, holds in
a language exactly when some eternal row stays within a bounded deficit of mu(H) at every H.

Test. Enumerate every accepted word to Hmax exactly (each has exactly one canonical seed, built bit by bit by the
antidiagonal recurrence of m6_floors.py). Record mu(h) for every h <= Hmax and every minimiser at Hmax. For each
minimiser W, the deficit profile d_W(h) = popcount(W mod 2^h) - mu(h) for h <= Hmax. Report, over minimisers, the
least value of max_{h <= Hmax - m} d_W(h), for end margins m.

Languages:
- gap: Rule30ZeroCoastBridge.accept (white at 0, black at odd t, white even times 6 or 10 ticks apart);
- G (control): Rule30PeriodTwoMass.gstep. Its floor is set by the ether row 2538/127 (PRIOR-ART P1); the deficit of
  the ether's prefixes is also reported.
Kit controls: NoMass 37 102 and NoMass 38 111 (Rule30ZeroCoastBridge), and Conjecture S's 7 mu_G(H) >= H + 4.

Usage: m6_nested.py OUTFILE [--gap-H 180] [--g-H 56] [--split 70] [--g-split 30] [--procs 8]
"""
import argparse, json, multiprocessing, os, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m6_floors import extend

INF = 10 ** 9


def gap_moves(T, st):
    """(bit, next state) choices at tick T for the gap gate; st = age at the last even tick (None before t = 0)."""
    if T == 0:
        return [(0, 0)]
    if T % 2 == 1:
        return [(1, st)]
    out = []
    if st in (0, 1, 2, 3):
        out.append((1, st + 1))
    if st in (2, 4):
        out.append((0, 0))
    return out


def g_moves(T, st):
    """G rule; st = whether the last even tick was white."""
    if T == 0:
        return [(0, True)]
    if T % 2 == 1:
        return [(1, st)]
    return [(1, False)] + ([] if st else [(0, True)])


MOVES = {'gap': gap_moves, 'G': g_moves}


def subtree(job):
    lang, T0, A1, A2, st, seed, pc, Hmax, checks = job
    moves = MOVES[lang]
    mins = [INF] * (Hmax + 1)
    best = {H: [] for H in checks}

    def rec(T, A1, A2, st, seed, pc):
        if pc < mins[T]:
            mins[T] = pc
        if T in best:
            b = best[T]
            if not b or pc < b[0][0]:
                b[:] = [(pc, seed)]
            elif pc == b[0][0] and len(b) < 2000:
                b.append((pc, seed))
        if T == Hmax:
            return
        for b, nst in moves(T, st):
            A = extend(A1, A2, T, b)
            sb = (A >> T) & 1
            rec(T + 1, A, A1, nst, seed | (sb << T), pc + sb)
    rec(T0, A1, A2, st, seed, pc)
    return mins, best


def prefixes(lang, d0):
    moves = MOVES[lang]
    out = []
    mins = [INF] * (d0 + 1)

    def rec(T, A1, A2, st, seed, pc):
        mins[T] = min(mins[T], pc)
        if T == d0:
            out.append((T, A1, A2, st, seed, pc))
            return
        for b, nst in moves(T, st):
            A = extend(A1, A2, T, b)
            sb = (A >> T) & 1
            rec(T + 1, A, A1, nst, seed | (sb << T), pc + sb)
    rec(0, 0, 0, None, 0, 0)
    return out, mins


def run(lang, Hmax, d0, procs, checks):
    pre, mins0 = prefixes(lang, d0)
    jobs = [(lang,) + p + (Hmax, checks) for p in pre]
    with multiprocessing.Pool(procs) as pool:
        parts = pool.map(subtree, jobs, chunksize=1)
    mu = mins0[:d0] + [min(p[0][h] for p in parts) for h in range(d0, Hmax + 1)]
    best = {H: sorted({s for p in parts for pc, s in p[1][H] if pc == mu[H]}) for H in checks}
    return mu, best, len(pre)


def deficits(seed, mu, H):
    return [bin(seed & ((1 << h) - 1)).count('1') - mu[h] for h in range(H + 1)]


def trace_gaps(seed, H):
    Y, tr = seed, []
    for _ in range(H):
        tr.append(Y & 1)
        Y = (Y >> 1) ^ (Y | (Y << 1))
    whites = [t for t in range(0, H, 2) if tr[t] == 0]
    return [(b - a) // 2 for a, b in zip(whites, whites[1:])]


def report(lang, mu, best, Hmax, margins):
    out = {'Hmax': Hmax, 'mu': mu, 'by_horizon': {}}
    for H, seeds in best.items():
        prof = {s: deficits(s, mu, H) for s in seeds}
        row = {'minimisers': len(seeds),
               'least_max_deficit_by_margin': {m: min(max(d[:H - m + 1]) for d in prof.values())
                                               for m in margins if H - m > 0}}
        w = min(prof, key=lambda s: max(prof[s][:max(1, H - 20) + 1]))
        row['example'] = {'seed_hex': hex(w), 'deficits_every_10': prof[w][::10], 'gaps': trace_gaps(w, H)}
        out['by_horizon'][H] = row
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--gap-H', type=int, default=180)
    ap.add_argument('--g-H', type=int, default=56)
    ap.add_argument('--split', type=int, default=70)
    ap.add_argument('--g-split', type=int, default=30)
    ap.add_argument('--procs', type=int, default=8)
    a = ap.parse_args()
    t0 = time.time()
    margins = [0, 10, 20, 30, 40]
    res = {}
    # checkpoints must lie past the split depth, where the subtrees record minimisers (fix after M19, see M20)
    checks = sorted({h for h in (60, 80, 100, 120, 140, 160, 180) if a.split < h <= a.gap_H} | {a.gap_H})
    mu, best, nsub = run('gap', a.gap_H, a.split, a.procs, checks)
    res['gap'] = report('gap', mu, best, a.gap_H, margins)
    res['gap']['subtrees'] = nsub
    res['gap']['kit_control_NoMass_37_102'] = mu[102] >= 38 if a.gap_H >= 102 else None
    res['gap']['kit_control_NoMass_38_111'] = mu[111] >= 39 if a.gap_H >= 111 else None
    res['gap']['least_H_with_mu_ge'] = {M: next((h for h in range(len(mu)) if mu[h] > M), None) for M in (37, 38)}
    res['gap']['mu_increments_last_60'] = [mu[h + 10] - mu[h] for h in range(a.gap_H - 60, a.gap_H - 9, 10)]
    checks_g = sorted({h for h in (24, 32, 40, 48) if a.g_split < h < a.g_H} | {a.g_H})
    mu_g, best_g, nsub_g = run('G', a.g_H, a.g_split, a.procs, checks_g)
    res['G'] = report('G', mu_g, best_g, a.g_H, margins)
    res['G']['control_S_7mu_ge_H+4'] = all(7 * mu_g[h] >= h + 4 for h in range(2, a.g_H + 1))
    ether = (2538 * pow(127, -1, 1 << a.g_H)) % (1 << a.g_H)
    res['G']['ether_prefix_max_deficit'] = max(deficits(ether, mu_g, a.g_H))
    res['seconds'] = round(time.time() - t0, 1)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: {kk: vv for kk, vv in v.items() if kk != 'mu'} if isinstance(v, dict) else v
                      for k, v in res.items()}, indent=1))


if __name__ == '__main__':
    main()
