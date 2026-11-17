#!/usr/bin/env python3
"""claudeM5's carrying read of R8: an independent replay of the moving-band induction and the four-tick scan.

Written without reusing twin_past.py or compare_branches.py; only C20 is taken from the kit (Rule30LateTwins.inC20).
F Y = (Y >> 1) ^ (Y | (Y << 1)) beside the white wall; bit i of Y is depth i + 1; a row's band of width w is its top
w cells, read as an integer whose top bit is the edge.

1. Base: every nonzero seed has its top 20 cells on C20 at every age >= 26. The kit proves it for seeds of width
   >= 20 (band_settles) and from age 45 for all (band_late); seeds of width <= 19 are checked here at age 26
   (C20 is closed under the band map, C20_closed, so age 26 suffices).
2. Cover: S(26) = C20; S(a + 1) = top (w + 1) cells of F(row) over every row whose top w + 1 cells are (p, b),
   p in S(a), b in {0, 1}. Computed with F on padded rows, checking independence from the padding.
3. Scan: for each word of S(80) and each of the 4 incoming parent pairs on each of four inverse layers, the parents
   are computed layer by layer, P(k + 1) = I(k) xor (P(k) or P(k - 1)), past the edge into the white exterior.
   A history closes when every layer is white from the edge on.
4. Physical check: random nonzero seeds, every one of the 16 four-tick wall histories built exactly, at ages
   46 .. 140; the black-headed count and the width-one bound of R9.

Usage: claudeM5_r8_replay.py OUTFILE [--four-step FILE]
"""
import argparse, json, multiprocessing, random, sys

C20 = (820683, 822904, 911005, 912610)


def F(y):
    return (y >> 1) ^ (y | (y << 1))


def top(row, w):
    return row >> (row.bit_length() - w)


def base_check():
    bad = 0
    for y in range(1, 1 << 19):
        row = y
        for _ in range(26):
            row = F(row)
        if top(row, 20) not in C20:
            bad += 1
    return bad


def cover(age_to, rnd):
    S = set(C20)
    w = 20
    for _ in range(26, age_to):
        new = set()
        for p in S:
            for b in (0, 1):
                outs = set()
                for pad in (0, rnd.getrandbits(9) | 1):
                    row = (((p << 1) | b) << 9) | (pad & 511)
                    outs.add(top(F(row), w + 1))
                assert len(outs) == 1
                new |= outs
        S, w = new, w + 1
    return S, w


EXTRA = 8


def closes(job):
    word, w = job
    n = w + EXTRA
    img0 = [(word >> k) & 1 for k in range(w)] + [0] * EXTRA
    fails = 0

    def layer(img, depth):
        nonlocal fails
        for pm1 in (0, 1):
            for p0 in (0, 1):
                P = [pm1, p0]                      # P(-1), P(0); P[k + 1] is P(k)
                for k in range(n):
                    P.append(img[k] ^ (P[k + 1] | P[k]))
                par = P[1:n + 1]                    # P(0) .. P(n - 1)
                tail_ok = all(x == 0 for x in par[w - depth:]) and P[n + 1] == 0
                if depth == 4:
                    if not tail_ok:
                        fails += 1
                else:
                    if not tail_ok:
                        fails += 4 ** (4 - depth)
                    else:
                        layer(par, depth + 1)
    layer(img0, 1)
    return fails


def parents(row):
    """Every finite parent of a nonzero finite row: the head (depth-1 bit) is free; a finite parent is one cell
    narrower, so it is checked by applying F."""
    out = []
    for h in (0, 1):
        P = [0, h]
        for k in range(row.bit_length() + 2):
            P.append(((row >> k) & 1) ^ (P[-1] | P[-2]))
        par = sum(b << i for i, b in enumerate(P[1:]))
        out.append((h, par if F(par) == row else None))
    return out


def histories(row, d):
    """All 2^d wall histories of d inverse ticks: lists of (heads, ancestor or None)."""
    layer = [((), row)]
    for _ in range(d):
        nxt = []
        for heads, r in layer:
            if r is None:
                nxt += [(heads + (0,), None), (heads + (1,), None)]
                continue
            for h, p in parents(r):
                nxt.append((heads + (h,), p))
        layer = nxt
    return layer


def physical(rnd, samples):
    rows = []
    for _ in range(samples):
        w = rnd.choice([1, 2, 3, 5, 8, 13, 19, 20, 21, 34, 55])
        y = (1 << (w - 1)) | rnd.getrandbits(w - 1) if w > 1 else 1
        a = rnd.randint(46, 140)
        row = y
        for _ in range(a):
            row = F(row)
        H = histories(row, 4)
        finite = sum(1 for _, p in H if p is not None)
        widths = {p.bit_length() for _, p in H if p is not None}
        # heads are listed from the newest past row (t - 1) to the oldest (t - 4)
        bh = [(hs, p) for hs, p in H if hs[1] == 1 and hs[3] == 1]
        rows.append({'w': w, 'age': a, 'finite': finite, 'widths': sorted(widths), 'black_headed': len(bh),
                     'black_headed_finite': sum(1 for _, p in bh if p is not None)})
    return rows


def width_one(dmax, tmax):
    """Least age t at which every one of the 2^d wall histories of the width-one seed's row is finite."""
    out = {}
    for d in range(1, dmax + 1):
        row, t = 1, 0
        while t <= tmax:
            if all(p is not None for _, p in histories(row, d)):
                out[d] = t
                break
            row, t = F(row), t + 1
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--four-step')
    a = ap.parse_args()
    rnd = random.Random(20261117)
    res = {'base_seeds_of_width_le_19_off_C20_at_age_26': base_check()}
    S, w = cover(80, rnd)
    res['cover_age'], res['cover_width'], res['cover_words'] = 80, w, len(S)
    if a.four_step:
        line = [l for l in open(a.four_step) if l.startswith('four-step edge certificate')][0]
        theirs = eval(line.split(': ', 1)[1], {})
        res['cover_equals_R8'] = (theirs[0], theirs[1], sorted(S)) == (80, 74, sorted(theirs[2]))
    with multiprocessing.Pool(8) as pool:
        fails = pool.map(closes, [(p, w) for p in sorted(S)], chunksize=32)
    res['word_register_pairs'] = 256 * len(S)
    res['unclosed_pairs'] = sum(fails)
    phys = physical(rnd, 3000)
    res['physical_samples'] = len(phys)
    res['physical_all16_finite_age_ge_80'] = sum(1 for r in phys if r['age'] >= 80 and r['finite'] == 16)
    res['physical_age_ge_80'] = sum(1 for r in phys if r['age'] >= 80)
    res['physical_all16_finite_age_46_79'] = sum(1 for r in phys if r['age'] < 80 and r['finite'] == 16)
    res['physical_age_46_79'] = sum(1 for r in phys if r['age'] < 80)
    res['physical_black_headed_counts'] = sorted({r['black_headed'] for r in phys})
    res['physical_widths_ok'] = all(len(r['widths']) <= 1 for r in phys)
    res['physical_failures_age_ge_80'] = [r for r in phys if r['age'] >= 80 and r['finite'] != 16][:5]
    res['physical_failures_age_46_79'] = [r for r in phys if r['age'] < 80 and r['finite'] != 16][:5]
    res['width_one_least_age_all_histories_finite'] = width_one(6, 200)
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res, indent=1))


if __name__ == '__main__':
    main()
