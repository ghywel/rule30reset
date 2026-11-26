#!/usr/bin/env python3
"""claudeCloud_pr443_444_checks.py: numerical checks of kit pull requests 443 and 444, with code of my own (ledger K91).

A right half is an integer Z, bit i = cell i + 1.  The centre is black at even ticks.  u(s) is cell 1 at tick 2s + 1.
FR1 is one tick beside a black centre, FR0 one beside a white centre, GR = FR0 after FR1 (the pull requests' names).

    python3 claudeCloud_pr443_444_checks.py        runs everything (about a minute)
 1. 443: u(s) = [Z_s = 0 mod 4] for every right half.
 2. 443: where the gaps are 3 or 5, a kick has Z_s = 4 mod 8, and bits 3, 4, 5 of Z_s tell 3 from 5.
 3. 444: the families of 112 (24 cells) and 31 (26 cells) keep an alternating gate for every tail tried; and ours of
    31 (28 cells) and 495 (24 cells), `Rule30EtherFamilies`.
 4. The least number of cells that forces each gate, by exhaustive search over 14 further cells.
 5. The four rings beside the alternating column (K79): which keep their gate against random tails.
"""
import os
import random
import sys


def FR1(Z): return ((Z << 1) | 1) ^ (Z | (Z >> 1))
def FR0(Z): return (Z << 1) ^ (Z | (Z >> 1))


def gate(Z, m):
    out, rows = [], []
    for _ in range(m):
        rows.append(Z); A = FR1(Z); out.append(A & 1); Z = FR0(A)
    return out, rows


def part1(rng):
    n = bad = 0
    for _ in range(300):
        g, rows = gate(rng.getrandbits(rng.randint(0, 60)), 300)
        for s in range(300):
            n += 1; bad += (g[s] == 1) != (rows[s] % 4 == 0)
    print('1. u = [Z_s mod 4 = 0]: cases', n, 'failures', bad)


def part2(rng):
    n = bad8 = bad35 = nonp = badnp = 0
    for _ in range(400):
        g, rows = gate(rng.getrandbits(rng.randint(1, 70)), 500)
        ks = [s for s in range(500) if g[s]]
        start = ks[0] if ks else 500
        for i in range(len(ks) - 1, 0, -1):
            if ks[i] - ks[i - 1] not in (3, 5):
                start = ks[i]; break
        for s in range(max(start, 1) + 6, 480):
            x = rows[s]
            if g[s]:
                n += 1; bad8 += x % 8 != 4
                d = next((k for k in range(1, 8) if g[s + k]), None)
                f = ((x >> 3) & 1) ^ (((x >> 4) & 1) | ((x >> 5) & 1))
                bad35 += (d == 3) != (f == 1)
            else:
                nonp += 1; badnp += x % 8 == 4
    print('2. kicks among gaps of 3 and 5:', n, '; not 4 mod 8:', bad8, '; wrong forecast from bits 3, 4, 5:', bad35,
          '; other samples that are 4 mod 8:', badnp, 'of', nonp)


def keeps(Z, phase, m):
    g, _ = gate(Z, m)
    return all(g[s] == (1 if s % 2 == phase else 0) for s in range(m))


def part3(rng):
    for who, base, cells, phase in (('444', 112, 24, 0), ('444', 31, 26, 1), ('ours', 31, 28, 1), ('ours', 495, 24, 1)):
        fails = sum(not keeps((base & ((1 << cells) - 1)) | (rng.getrandbits(200) << cells), phase, 1500) for _ in range(400))
        print('3.', who, 'family of', base, 'with', cells, 'cells fixed, 400 random tails, 1,500 readings: failures', fails)


def part4():
    for base, phase in ((112, 0), (31, 1), (495, 1)):
        for c in range(3, 30):
            p = base & ((1 << c) - 1)
            if all(keeps(p | (t << c), phase, 260) for t in range(1 << 14)):
                print('4. least cells that force the gate of', base, ':', c, '(one fewer fails for some tail)')
                break


def part5(rng):
    here = os.path.dirname(os.path.abspath(__file__))
    sys.argv = ['x', 'none']
    src = open(os.path.join(here, '..', '..', 'rule4', 'k84', 'claudeCloud_k84_tree.py')).read().split('def main():')[0]
    env = {}
    exec(src, env)
    decode_west = env['decode_west']
    M = 1200

    def want(gaps, phase, n):
        bits = [0] * n; s, i = phase, 0
        while s < n:
            bits[s] = 1; s += gaps[i % len(gaps)]; i += 1
        return bits
    for name, gaps, P in (('2', [2], 7), ('3', [3], 84), ('5', [5], 155), ('2,5', [2, 5], 728)):
        for phase in range(sum(gaps)):
            m = 2 * P + 60; T = 2 * m + 1; word = 0
            for b in want(gaps, phase, m):
                word = (word << 1) | b
            west = decode_west(word, T); row = [(west >> d) & 1 for d in range(T)]
            if not all(row[d] == row[d + P] for d in range(T - P)):
                continue
            right = [(1 if (x % P) == 0 else row[P - (x % P) - 1]) for x in range(1, 2 * M + 401)]
            Z = sum(b << i for i, b in enumerate(right)); bits = want(gaps, phase, M)
            assert gate(Z, M)[0] == bits
            res = []
            for c in (10, 20, 30, 40, 60, 80, 120, 200):
                first, broke = None, 0
                for _ in range(60):
                    g, _ = gate((Z & ((1 << c) - 1)) | (rng.getrandbits(2 * M) << c), M)
                    f = next((s for s in range(M) if g[s] != bits[s]), None)
                    if f is not None:
                        broke += 1; first = f if first is None else min(first, f)
                res.append('%d: %d of 60 (first at %s)' % (c, broke, first))
            print('5. ring of gate', name, '(%d columns)' % P, '| cells kept: tails that break the gate |', '; '.join(res))
            break


rng = random.Random(443)
part1(rng); part2(rng); part3(rng); part4(); part5(rng)
