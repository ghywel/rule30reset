#!/usr/bin/env python3
"""Pull M29, M31's test 2: the first age at which a moving cover closes k inverse layers, for k = 5 and 6.

Covers (band words as integers, top bit the edge, as `top` in research/r2/claudeM5_r8_replay.py):
  s1   S1's cover: C20 at age 26, then one free interior bit per tick (M31's frozen test 2 uses this one);
  seed R23's seed-anchored cover: all 128 top-eight-bit words at age 0, two fixed-width ticks, then one free bit per
       tick (carried in M32). Seeds narrower than 8 bits are checked physically at the passing age.
Scan: S1's register scan to depth k, bit-sliced across words. Plane i holds bit i of every word (bit j of the plane
is word j). For each path of free incoming registers (P(-1), P(0)) on the layers, P(i + 1) = I(i) xor (P(i) or
P(i - 1)) is computed for all words at once, and a word fails at layer d when its layer-d parent is not white from
cell w - d on (the rule of `closes`). A word closes k layers when no register path fails at a layer <= k.
Controls, run first: s1 fails four layers at 79 (4 words) and passes at 80; seed fails four layers at 71 (12 words)
and passes at 72; seed fails three layers at 30 (28 words) and passes at 31 (M31, M32).
Predictions (written before the run): s1 first closes five layers at about 110 (M31); the seed cover about eight
ticks earlier, as at four layers (80 against 72).
Usage: claudeM5_cover_k.py OUTFILE --cover s1|seed --k K --lo A --hi B [--budget 4000000] [--procs 8]
"""
import argparse, json, multiprocessing, os, sys, time
import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'r2'))
from claudeM5_r8_replay import F, top, histories, C20  # noqa: E402

EXTRA = 8


def grow(S, w):
    out = set()
    for p in S:
        out.add(top(F(((p << 1) << 9)), w + 1))
        out.add(top(F((((p << 1) | 1) << 9)), w + 1))
    return out


def fixed(S, w):
    return {top(F(p << 9), w) for p in S}


def planes_of(words, w):
    nb = (w + 7) // 8
    A = np.frombuffer(b''.join(p.to_bytes(nb, 'little') for p in words), dtype=np.uint8).reshape(len(words), nb)
    B = np.unpackbits(A, axis=1, bitorder='little')[:, :w]
    return [int.from_bytes(np.packbits(B[:, i], bitorder='little').tobytes(), 'little') for i in range(w)]


def scan_chunk(job):
    words, w, k = job
    N = len(words)
    ALL = (1 << N) - 1
    n = w + EXTRA
    img0 = planes_of(words, w) + [0] * EXTRA
    failed = 0

    def layer(img, depth, alive):
        nonlocal failed
        for pm1 in (0, ALL):
            for p0 in (0, ALL):
                P = [pm1, p0]
                for i in range(n):
                    P.append(img[i] ^ (P[i + 1] | P[i]))
                bad = 0
                for i in range(w - depth + 1, n + 2):
                    bad |= P[i]
                bad &= alive
                failed |= bad
                ok = alive & ~bad & ~failed
                if depth < k and ok:
                    layer(P[1:n + 1], depth + 1, ok)
    layer(img0, 1, ALL)
    return bin(failed).count('1'), [words[j] for j in range(N) if (failed >> j) & 1][:4]


def scan(S, w, k, pool):
    words = sorted(S)
    chunk = max(2048, -(-len(words) // (4 * pool._processes)))
    jobs = [(words[i:i + chunk], w, k) for i in range(0, len(words), chunk)]
    res = pool.map(scan_chunk, jobs)
    return sum(r[0] for r in res)


def narrow_ok(age, k):
    bad = []
    for y in range(1, 1 << 7):
        r = y
        for _ in range(age):
            r = F(r)
        if any(q is None for _, q in histories(r, k)):
            bad.append(y)
    return bad


def cover_iter(kind):
    if kind == 's1':
        S, w, age = set(C20), 20, 26
    else:
        S, w, age = set(range(1 << 7, 1 << 8)), 8, 0
        S, age = fixed(S, w), 1
        S, age = fixed(S, w), 2
    while True:
        yield age, S, w
        S, w, age = grow(S, w), w + 1, age + 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('outfile')
    ap.add_argument('--cover', choices=['s1', 'seed'], required=True)
    ap.add_argument('--k', type=int, required=True)
    ap.add_argument('--lo', type=int, required=True)
    ap.add_argument('--hi', type=int, required=True)
    ap.add_argument('--budget', type=int, default=4000000)
    ap.add_argument('--procs', type=int, default=8)
    ap.add_argument('--controls', action='store_true')
    a = ap.parse_args()
    out = {'cover': a.cover, 'k': a.k, 'rows': []}
    with multiprocessing.Pool(a.procs) as pool:
        if a.controls:
            want = {('s1', 4, 79): 4, ('s1', 4, 80): 0, ('seed', 4, 71): 12, ('seed', 4, 72): 0,
                    ('seed', 3, 30): 28, ('seed', 3, 31): 0}
            got = {}
            for kind in ('s1', 'seed'):
                for age, S, w in cover_iter(kind):
                    for (kk, kk_k, kk_a), v in want.items():
                        if kk == kind and kk_a == age:
                            got[(kk, kk_k, kk_a)] = scan(S, w, kk_k, pool)
                    if age >= 80:
                        break
            out['controls'] = {'%s k=%d a=%d' % key: [got[key], want[key]] for key in want}
            out['controls_ok'] = all(got[key] == want[key] for key in want)
            print(json.dumps(out['controls']), out['controls_ok'], flush=True)
        first = None
        for age, S, w in cover_iter(a.cover):
            if age < a.lo:
                continue
            if age > a.hi or len(S) > a.budget:
                out['stopped'] = {'age': age, 'words': len(S), 'reason': 'hi' if age > a.hi else 'budget'}
                break
            t0 = time.time()
            nf = scan(S, w, a.k, pool)
            row = {'age': age, 'width': w, 'words': len(S), 'failing_words': nf, 'seconds': round(time.time() - t0, 1)}
            if nf == 0 and a.cover == 'seed':
                row['narrow_seeds_unclosed'] = narrow_ok(age, a.k)
            out['rows'].append(row)
            print(json.dumps(row), flush=True)
            if nf == 0 and first is None:
                first = age
            elif first is not None:
                break                                   # one age past the first pass, as a check
        out['first_pass'] = first
    with open(a.outfile, 'w') as fh:
        json.dump(out, fh, indent=1)
    print(json.dumps({'first_pass': first, 'stopped': out.get('stopped')}), flush=True)


if __name__ == '__main__':
    main()
