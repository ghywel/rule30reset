#!/usr/bin/env python3
"""claudeCloud_r3_controls.py: controls for claudeCloud_r3_void_gaps.c (pull R3, ledger K34), by literal simulation
of the kit's acceptor (Rule30ZeroCoastBridge: F, trace, accept), with no anti-diagonal recursion.

  python3 claudeCloud_r3_controls.py small BINARY K      brute force over every y < 2^(2K+1): the counts of accepted
                                                         traces, the Void-phase histogram, the gaps and changes in
                                                         the Void phase, all against the C program at the same K
  python3 claudeCloud_r3_controls.py examples FILE...    every example seed in the C program's output: its support,
                                                         its Void length and its Void gaps, by literal simulation
  python3 claudeCloud_r3_controls.py rung                the kit's rung (R30-20261115-fdf6a3): the eight seeds of
                                                         popcount 38 survive to 102..110, as placego L1675 found
"""
import json
import subprocess
import sys


def F(y):
    return (y >> 1) ^ (y | (y << 1))


def life(y, limit):
    """(the largest H <= limit with SurvivesTo y H, the ticks of its resets, the gap ending at each reset)."""
    age, resets, gaps = 0, [0], []
    for t in range(limit):
        b = y & 1
        if t == 0:
            if b:
                return 0, [], []
        elif t & 1:
            if not b:
                return t, resets, gaps
        else:
            if b:
                if age == 4:
                    return t, resets, gaps
                age += 1
            else:
                if age not in (2, 4):
                    return t, resets, gaps
                gaps.append(3 if age == 2 else 5)
                resets.append(t)
                age = 0
        y = F(y)
    return limit, resets, gaps


def void_of(y):
    """Support, Void length, the gaps wholly inside the Void phase, and the gap in progress when it began."""
    s = y.bit_length()
    H, resets, gaps = life(y, s + 400)
    if H < s:
        return None
    inside = [g for i, g in enumerate(gaps) if resets[i] >= s - 1]
    boundary = [g for i, g in enumerate(gaps) if resets[i] < s - 1 and resets[i + 1] >= s]
    return s, H - s, inside, boundary


def small(binary, K):
    out = json.loads(subprocess.run([binary, str(K), '0', '1000', '1', '0'], capture_output=True, text=True).stdout)
    top = 2 * K + 1
    words = [0] * (top + 1)
    void_hist = [0] * 64
    gaps_hist = [0] * 16
    ch_hist = [0] * 8
    chb_hist = [0] * 8
    seeds = 0
    for y in range(1 << top):
        H, _, _ = life(y, top)
        # y's first n bits are an accepted prefix of n ticks for every n <= H; count each prefix once, by its value
        for n in range(1, top + 1, 2):
            if y < (1 << n) and H >= n:
                words[n] += 1
        if y and y.bit_length() >= 2:
            v = void_of(y)
            if v is not None:
                s, vl, inside, boundary = v
                seeds += 1
                void_hist[vl] += 1
                gaps_hist[min(len(inside), 15)] += 1
                ch = sum(1 for a, b in zip(inside, inside[1:]) if a != b)
                chb = ch + (1 if boundary and inside and boundary[0] != inside[0] else 0)
                ch_hist[min(ch, 7)] += 1
                chb_hist[min(chb, 7)] += 1
    ok = True
    for name, mine, theirs in (('accepted traces by length', [words[n] for n in range(1, top + 1, 2)], [out['words_at'][n] for n in range(1, top + 1, 2)]),
                               ('finite seeds', seeds, out['seeds']),
                               ('Void-length histogram', void_hist, out['void_hist']),
                               ('gaps inside the Void phase', gaps_hist, out['void_gaps_hist']),
                               ('changes inside the Void phase', ch_hist, out['void_changes_hist']),
                               ('changes with the gap in progress', chb_hist, out['void_changes_with_boundary_hist'])):
        same = mine == theirs
        ok = ok and same
        print('%-34s %s' % (name, 'SAME' if same else 'DIFFERENT: literal %s, C %s' % (mine, theirs)))
    print('recurrence B(s+5) = B(s+2) + B(s) on the C counts: %s' % all(
        out['words_at'][2 * s + 11] == out['words_at'][2 * s + 5] + out['words_at'][2 * s + 1] for s in range(0, K - 5)))
    print('CONTROL small K = %d: %s' % (K, 'PASS' if ok else 'FAIL'))


def examples(files):
    n = bad = 0
    for f in files:
        for line in open(f):
            d = json.loads(line)
            for e in d['examples']:
                y = int(e['seed'], 16)
                s, vl, inside, boundary = void_of(y)
                n += 1
                if (s, vl, inside[:12]) != (e['support'], e['void'], e['gaps']) or bin(y).count('1') != e['pop']:
                    bad += 1
                    print('DIFFERENT', e, (s, vl, inside, boundary))
    print('CONTROL examples: %d checked, %d different: %s' % (n, bad, 'none to check' if not n else 'PASS' if not bad else 'FAIL'))


def rung():
    roots = [42813888358306443700074217814, 148978366434744761789452353878, 2654468869608816557330812141910,
             20290708049760378067263390038, 871680261646910262683015020886, 3258683745119620012336052404566,
             793529923180978236193646670102, 343533199256979670105602359638]
    got = sorted(life(y, 400)[0] for y in roots)
    print('popcounts:', sorted(bin(y).count('1') for y in roots), ' survive to:', got)
    print('CONTROL rung: %s' % ('PASS' if got == [102, 102, 102, 103, 103, 103, 107, 110] else 'FAIL'))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['small']:
        small(a[1], int(a[2]))
    elif a[:1] == ['examples']:
        examples(a[1:])
    elif a[:1] == ['rung']:
        rung()
    else:
        sys.exit(__doc__)
