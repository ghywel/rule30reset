#!/usr/bin/env python3
"""claudeCloud_m9_minimal_word.py: pull M9 (ledger K47). AFTER THE FACT. Inside a gap word that the W-column lift's
core does not read, find the shortest factor that it does not read (a minimal forbidden word of the eventual
language), by bisection at each end. Uses the direct method of claudeCloud_m9_verify_word.py: the core from the
whole lift, sets pushed forward with the rule written out cell by cell. The core is kept in a file between runs.

  python3 claudeCloud_m9_minimal_word.py KITFILE W COREFILE.npy WORD
"""
import os
import re
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from claudeCloud_m9_verify_word import double_step, samples, trap_codes   # noqa: E402


def direct_core(kitfile, W, corefile):
    if os.path.exists(corefile):
        return np.load(corefile)
    trap = trap_codes(kitfile)
    rank = np.full(1 << 16, -1, dtype=np.int64)
    rank[trap] = np.arange(len(trap))
    H = 1 << (W - 16)
    n = len(trap) * H
    cur = np.ones(n, bool)
    while True:
        idx = np.nonzero(cur)[0]
        active = trap[idx // H] | ((idx % H) << 16)
        nxt = np.zeros(n, bool)
        for x1 in (0, 1):
            for x2 in (0, 1):
                c = double_step(active, x1, x2, W)
                nxt[rank[c & 0xFFFF] * H + (c >> 16)] = True
        if np.array_equal(nxt, cur):
            break
        cur = nxt
    idx = np.nonzero(cur)[0]
    core = trap[idx // H] | ((idx % H) << 16)
    np.save(corefile, core)
    return core


def is_read(core_black, word, W):
    act = core_black
    for colour in samples(word)[1:]:
        act = np.unique(np.concatenate([double_step(act, x1, x2, W) for x1 in (0, 1) for x2 in (0, 1)]))
        act = act[(act & 1) == colour]
        if len(act) == 0:
            return False
    return True


def main(kitfile, W, corefile, word):
    core = direct_core(kitfile, W, corefile)
    black = core[(core & 1) == 1]
    print('W = %d: core %d windows (%d black)' % (W, len(core), len(black)))
    assert not is_read(black, word, W), 'the word is read'
    lo, hi = 1, len(word)                 # the shortest prefix that is not read
    while lo < hi:
        mid = (lo + hi) // 2
        if is_read(black, word[:mid], W):
            lo = mid + 1
        else:
            hi = mid
    word = word[:lo]
    lo, hi = 0, len(word) - 1             # the latest start from which it is still not read
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if is_read(black, word[mid:], W):
            hi = mid - 1
        else:
            lo = mid
    u = word[lo:]
    ok = (not is_read(black, u, W)) and is_read(black, u[1:], W) and is_read(black, u[:-1], W)
    print('minimal forbidden word (%d gaps, %d double steps): %s' % (len(u), sum(int(g) for g in u), u))
    print('   not read, and read with its first or its last gap removed: %s' % ok)
    print('   runs of 5 between the 3s: %s; a concatenation of the blocks 5 and 3555: %s' % (
        [len(r) for r in re.findall('5+', u)], re.fullmatch('(5|3555)*', u) is not None))
    sys.stdout.flush()


if __name__ == '__main__':
    main(sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4])
