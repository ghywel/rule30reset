#!/usr/bin/env python3
"""Pull M29 (M40): M35's one-layer schedule on all four strips at full width, for an explicit age f(k).

The schedule (M35, R28-R29). Layer 1 reads the top w cells of a phase word from the inner end with four free registers
until they coalesce; from the cell where all four parents agree it hands the common parent to layer 2, which starts
there with four free registers, and so on. K1(w) = the layers that close, worst phase.
Fast and exact. After a layer coalesces its four trajectories are the true one, so its parent from the agreement cell
on is the strip's previous phase, shifted one wheel inwards: layer d reads u_d(j) = v(p - d + 1)(j - d + 1). Each layer
is then simulated only until its registers merge, and the merged state is checked against the true register there.
The end conditions of M35 (all four end at 00; no black parent in the last d cells) then hold for the true orbit, and
are checked explicitly for every unmerged emission.
The age. Rule30FourFronts (forced_front_four_uniform): every array with the recurrence and a black start carries one of
the four strips through wheel 87,866 from tick at most 177,575 of its own clock. A row beside the wall whose edge
starts at depth D0 >= 1 has its top W = 87,867 cells evolving by the free recurrence from tick W - D0, when the wall
has passed wheel W - 1; extended freely beyond wheel W - 1 it is such an array. So every row of age >= 87,866 +
177,575 = 265,441 has its top 87,867 cells on a strip phase, and by M34's two-factor bound f(k) <= 265,441 for every
k <= K1min, the worst over the four strips and their 16 phases.
Controls: per phase, the fast schedule equals M35's claudeM5_deep_resets.one_layer_schedule on A0 at widths 25, 62, 81,
91, 96, 128, 256, 512 and 1024; its worst phase gives R29's 2, 3, 4, 6, 6, 9 at 25-128 and M35's 23, 46, 94, 192, 383 at
256-4096; every merged state is the true register.
Predictions (written before the run): K1min(87,867) lies in 7,700-8,600 (M35's rate of 10.7 wheels per layer)
(65%); the four strips' worst phases lie within 3% of each other; K1 on A0 grows linearly (wheels per layer within
10.0-11.5 at every width 4096-87,867). Kill: K1min below 4,000.
Usage: claudeM5_strip_schedule.py LEANFILE OUTFILE
"""
import argparse, json, os, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from claudeM5_window_map import load_strips, phases, word, K    # noqa: E402
from claudeM5_deep_resets import one_layer_schedule, bits_from_bottom, step   # noqa: E402


def fast_schedule(ph, p, w, stats):
    """K1 of phase p of the strip with phase words ph (16 strings, ph[t][j] = wheel j), top w cells."""
    L = w + 12                                   # M35 pads 12 white cells beyond the edge
    start, layers = 0, 0
    while True:
        d = layers + 1
        v = ph[(p - d + 1) % 16]
        par = ph[(p - d) % 16]

        def u(i):                                # layer d's input at cell i (wheel w - 1 - i)
            j = w - 1 - i - (d - 1)
            return 1 if 0 <= j and v[j] == '1' else 0

        def truth(i):                            # the true parent u_(d + 1) at cell i
            j = w - 1 - i - d
            return 1 if 0 <= j and par[j] == '1' else 0

        S = [0, 1, 2, 3]
        P = []
        i, merged = start, None
        while i < L:
            x = u(i)
            S = [step(s, x) for s in S]
            P.append([s & 1 for s in S])          # P[i + 1]
            if S[0] == S[1] == S[2] == S[3]:
                merged = i
                break
            i += 1
        if merged is None:
            return layers
        stats['merges'] += 1
        prev = truth(merged) if merged > start else None
        if (prev is not None and S[0] != (prev << 1 | truth(merged + 1))) or \
           (prev is None and (S[0] & 1) != truth(merged + 1)):
            stats['merge_not_true'] += 1
        for idx, row in enumerate(P):            # M35's 'bad': a black parent in the last d cells
            if start + idx + 1 >= w - d and any(row):
                return layers
        k = len(P) - 1
        while k >= 1 and len(set(P[k - 1])) == 1:
            k -= 1
        layers += 1
        start = start + k + 1                    # M35's 'agree'
        if start >= w - d:
            return layers


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('leanfile')
    ap.add_argument('outfile')
    a = ap.parse_args()
    t0 = time.time()
    strips = load_strips(a.leanfile)
    rows = {n: phases(v)[:16] for n, v in strips.items()}
    ph = {n: [word(r) for r in rr] for n, rr in rows.items()}
    stats = {'merges': 0, 'merge_not_true': 0}
    res = {'controls': {}}
    # control 1: per phase against M35's schedule on A0
    cmp = {}
    for w in (25, 62, 81, 91, 96, 128, 256, 512, 1024):
        slow = [one_layer_schedule(bits_from_bottom(rows['A0'][t], K, w), w) for t in range(16)]
        fast = [fast_schedule(ph['A0'], t, w, stats) for t in range(16)]
        cmp[w] = {'equal_all_phases': slow == fast, 'worst': min(fast)}
    res['controls']['fast_vs_M35_A0'] = cmp
    worst = {w: min(fast_schedule(ph['A0'], t, w, stats) for t in range(16)) for w in (2048, 4096)}
    res['controls']['worst_2048_4096'] = worst
    want = {25: 2, 62: 3, 81: 4, 91: 6, 96: 6, 128: 9, 256: 23, 512: 46, 1024: 94, 2048: 192, 4096: 383}
    got = {**{w: c['worst'] for w, c in cmp.items()}, **worst}
    res['controls']['R29_M35_worst_ok'] = all(got[w] == want[w] for w in want)
    print(json.dumps(res['controls']), flush=True)
    # A0 growth
    growth = {}
    for w in (8192, 16384, 32768, 53207, 65536):
        ks = [fast_schedule(ph['A0'], t, w, stats) for t in range(16)]
        growth[w] = {'worst': min(ks), 'mean': round(sum(ks) / 16, 1), 'wheels_per_layer': round(w / min(ks), 3)}
        print(json.dumps({w: growth[w]}), flush=True)
    res['A0_growth'] = growth
    # full width, all four strips
    W = K
    full = {}
    for n in ('A0', 'A1', 'B0', 'B1'):
        ks = [fast_schedule(ph[n], t, W, stats) for t in range(16)]
        full[n] = {'by_phase': ks, 'worst': min(ks), 'worst_phase': ks.index(min(ks)), 'best': max(ks),
                   'wheels_per_layer_worst': round(W / min(ks), 3)}
        print(json.dumps({n: full[n]}), flush=True)
    res['full_width'] = full
    kmin = min(f['worst'] for f in full.values())
    res['K1min'] = kmin
    res['age_bound'] = {'convergence_tick_FourFronts': 177575, 'wall_passes_band_by': W - 1,
                        'f_k_at_most': W - 1 + 177575, 'for_every_k_at_most': kmin}
    res['merge_stats'] = stats
    res['seconds'] = round(time.time() - t0, 1)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps({k: res[k] for k in ('K1min', 'age_bound', 'merge_stats', 'seconds')}))


if __name__ == '__main__':
    main()
