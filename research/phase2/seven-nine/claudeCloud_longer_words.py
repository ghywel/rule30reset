#!/usr/bin/env python3
"""claudeCloud_longer_words.py: words of 11 to 13 gaps with no three 7s in a row, on 16 cells (K94; development).

Each such primitive cyclic word is put to the word-by-word test of claudeCloud_ranked.py on 16 cells; a survivor is
tested again on 17.  It stops at the first length with a survivor.

    python3 claudeCloud_longer_words.py DIR KIT      DIR holds claudeCloud_review.py and claudeCloud_ranked.py
"""
import os, sys
HERE = sys.argv[1]; kit = sys.argv[2]
ARGV, sys.argv = sys.argv, ['x', 'none']
exec(open(os.path.join(HERE, 'claudeCloud_review.py')).read().split('\ndef main():')[0])
import numpy as np
SRC = open(os.path.join(HERE, 'claudeCloud_ranked.py')).read()
exec('def components(' + SRC.split('\ndef components(')[1].split('\ndef main():')[0])
letters = (7, 9)
def has777(w):
    n = len(w)
    return any(w[i] == 7 and w[(i + 1) % n] == 7 and w[(i + 2) % n] == 7 for i in range(n))
graphs = {}
for cells in (16, 17):
    tab = make_tables(cells)
    states = start_set(kit, cells, letters, tab)
    succ, read = blocks_of(states, letters, tab)
    graphs[cells] = (len(states), succ, read)
found = []
for length in (11, 12, 13):
    words = [w for w in necklaces(letters, length) if not has777(w)]
    surv = []
    for w in words:
        ok, _ = judge(w, *graphs[16])
        if not ok:
            surv.append(w)
    print('length', length, ': words with no three 7s in a row:', len(words), '; not excluded on 16 cells:', len(surv), flush=True)
    for w in surv[:6]:
        ok17, _ = judge(w, *graphs[17])
        print('    ', ' '.join(map(str, w)), '| on 17 cells:', 'excluded' if ok17 else 'NOT excluded', flush=True)
    if surv:
        break
