#!/usr/bin/env python3
"""claudeCloud_m9_verify_word.py: pull M9 (ledger K43). AFTER THE FACT: a second, independent check of whether one
gap word is read by the W-column lift of the kit's gate trap. Written after the frozen ladder
(claudeCloud_m9_lift.py) reported a code word that is not read at 32 columns.

It shares nothing with the ladder but the 829 trap codes and the rule. No core is carried from a narrower width,
no gap graph is built, and no automaton: the whole lift, 829 * 2^(W - 16) windows, is held as one table, and sets
of windows are pushed forward one double step at a time with the rule written out cell by cell.

  1. CORE, directly: start from every lift window and take images until the set stops shrinking.
  2. READ: start from the black windows (of the core, and of the whole lift), and for each double step keep the
     successors whose column 1 has the colour the word asks for. The word is read exactly when the set never
     empties.

  python3 claudeCloud_m9_verify_word.py KITFILE W WORD [WORD ...]
"""
import re
import sys
import time

import numpy as np


def trap_codes(kitfile):
    body = re.search(r'def trapCodes : List Nat := \[(.*?)\]', open(kitfile).read(), re.S).group(1)
    return np.array(sorted(int(x) for x in re.findall(r'\d+', body)), dtype=np.int64)


def cell_step(w, c0, x, W):
    """One tick, cell by cell: new column j = column j-1 xor (column j or column j+1), j = 1..W."""
    out = np.zeros_like(w)
    for j in range(1, W + 1):
        left = np.int64(c0) if j == 1 else (w >> (j - 2)) & 1
        centre = (w >> (j - 1)) & 1
        right = np.int64(x) if j == W else (w >> j) & 1
        out |= (left ^ (centre | right)) << (j - 1)
    return out


def double_step(w, x1, x2, W):
    return cell_step(cell_step(w, 0, x1, W), 1, x2, W)      # from an odd time: column 0 white, then black


def samples(word):
    """Colours of column 1 at successive double steps: black, then for each gap g, g - 1 whites and a black."""
    out = [1]
    for g in word:
        out += [0] * (int(g) - 1) + [1]
    return out


def main(kitfile, W, words):
    trap = trap_codes(kitfile)
    rank = np.full(1 << 16, -1, dtype=np.int64)
    rank[trap] = np.arange(len(trap))
    H = 1 << (W - 16)
    n = len(trap) * H
    print('W = %d: the whole lift has %d windows' % (W, n))

    def index(codes):
        r = rank[codes & 0xFFFF]
        assert (r >= 0).all(), 'a successor left the lift'
        return r * H + (codes >> 16)

    def codes_of(idx):
        return trap[idx // H] | ((idx % H) << 16)

    # 1. the core, directly
    t0 = time.time()
    cur = np.ones(n, bool)
    k = 0
    while True:
        active = codes_of(np.nonzero(cur)[0])
        nxt = np.zeros(n, bool)
        for x1 in (0, 1):
            for x2 in (0, 1):
                nxt[index(double_step(active, x1, x2, W))] = True
        if np.array_equal(nxt, cur):
            break
        assert not (nxt & ~cur).any()
        cur = nxt
        k += 1
    core = codes_of(np.nonzero(cur)[0])
    core_black = core[(core & 1) == 1]
    print('   core, directly: %d windows (%d black), stable after %d double steps, %.0f s' % (
        len(core), len(core_black), k, time.time() - t0))
    sys.stdout.flush()

    # 2. reading each word
    all_black = codes_of(np.arange(n))
    all_black = all_black[(all_black & 1) == 1]
    for word in words:
        sm = samples(word)
        for label, start in (('from the core', core_black), ('from every black lift window', all_black)):
            t0 = time.time()
            act = start
            died = None
            for i, colour in enumerate(sm[1:], 1):
                act = np.unique(np.concatenate([double_step(act, x1, x2, W) for x1 in (0, 1) for x2 in (0, 1)]))
                act = act[(act & 1) == colour]
                if len(act) == 0:
                    died = i
                    break
            gaps_done = None
            if died is not None:
                pos, gaps_done = 0, 0
                for g in word:
                    pos += int(g)
                    if pos >= died:
                        break
                    gaps_done += 1
            print('   %s (%d gaps, %d double steps) %s: %s, %.0f s' % (
                word if len(word) <= 24 else word[:10] + '...' + word[-8:], len(word), len(sm) - 1, label,
                'READ, %d windows at the end' % len(act) if died is None else
                'NOT READ: no window left at double step %d, inside gap %d' % (died, gaps_done + 1),
                time.time() - t0))
            sys.stdout.flush()


if __name__ == '__main__':
    main(sys.argv[1], int(sys.argv[2]), sys.argv[3:])
