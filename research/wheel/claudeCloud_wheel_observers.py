#!/usr/bin/env python3
"""claudeCloud_wheel_observers.py: which words of gaps force the gate trap (ledger K75, addendum 1).

A gap word g1 g2 ... gk is read by a right half when column 1 is black at a sample s0 and next at s0 + g1,
s0 + g1 + g2, ..., and white at the samples between. The word FORCES the trap if every right half that reads it has
its sixteen columns in the kit's trap at the last kick. gptIntel's three wheel fragments (I155) are forcing words of
29 to 33 samples. This script looks for all the short ones.

  graph W K        every W-column window with a free exterior (an over-approximation of real rows, so a word found
                   forcing here forces for real rows): the minimal forcing words of up to K gaps over the letters
                   3 and 5, and with `any` as a third argument over the letters 1 to 6
  sat WORD ...     real rows, exactly, by SAT on the light cone: can the word end outside the trap?
                   A word is written as its gaps, for example 35553; a leading or trailing lower-case w adds one
                   white sample of context before the first kick or after the last (so `ww35553` has two).
  language W K     the gap words over 3 and 5 of up to K gaps that can be read outside the trap for ever on the
                   graph: read from the recurrent windows only (both an endless past and an endless future outside)

    python3 claudeCloud_wheel_observers.py KITFILE MODE ...
SAT answers as in claudeCloud_wheel_runs.py, whose encoder is imported: a model is replayed cell by cell; UNSAT is
COMPUTED only.
"""
import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_runs as R       # noqa: E402


def successors(windows, W, inside):
    """Windows one double step later that are outside the trap, for every exterior."""
    out = []
    for x1 in (0, 1):
        for x2 in (0, 1):
            v = L.step2(windows, x1, x2, W)
            out.append(v[~inside[v & 0xFFFF]])
    return np.unique(np.concatenate(out))


def read_gap(A, g, W, inside):
    """From a set of black outside windows: the black outside windows g samples later, white in between."""
    for i in range(g):
        A = successors(A, W, inside)
        if len(A) == 0:
            return A
        black = (A & 1) == 1
        A = A[black] if i == g - 1 else A[~black]
        if len(A) == 0:
            return A
    return A


def graph(trap, W, K, letters):
    inside = np.zeros(1 << 16, bool)
    inside[np.array(trap)] = True
    allw = np.arange(1 << W, dtype=np.int64)
    start = allw[(~inside[allw & 0xFFFF]) & ((allw & 1) == 1)]
    del allw
    level = {'': start}
    readable = {''}
    forcing = []
    counts = []
    for k in range(1, K + 1):
        nxt = {}
        for w, A in level.items():
            for g in letters:
                w2 = w + str(g)
                # only extend words whose suffix is readable: otherwise a shorter forcing word is inside
                if w2[1:] not in readable:
                    continue
                B = read_gap(A, g, W, inside)
                if len(B):
                    nxt[w2] = B
                else:
                    forcing.append(w2)
        level = nxt
        readable |= set(level)
        counts.append(len(level))
        if not level:
            break
    return forcing, counts


def language(trap, W, K):
    inside = np.zeros(1 << 16, bool)
    inside[np.array(trap)] = True
    n = 1 << W
    allw = np.arange(n, dtype=np.int64)
    out_black = (~inside[allw & 0xFFFF]) & ((allw & 1) == 1)
    start = allw[out_black]
    del allw
    # edges between black outside windows by a 3-gap or a 5-gap, built per start window in bulk
    edges = {}
    for g in (3, 5):
        src = start.copy()
        cur = start.copy()
        for i in range(g):
            parts_s, parts_c = [], []
            for x1 in (0, 1):
                for x2 in (0, 1):
                    v = L.step2(cur, x1, x2, W)
                    keep = ~inside[v & 0xFFFF]
                    keep &= ((v & 1) == 1) if i == g - 1 else ((v & 1) == 0)
                    parts_s.append(src[keep])
                    parts_c.append(v[keep])
            key = np.unique(np.concatenate(parts_s) * n + np.concatenate(parts_c))
            src, cur = key // n, key % n
        edges[g] = (src, cur)
    T = np.zeros(n, bool)
    T[start] = True
    while True:
        f = np.zeros(n, bool)
        b = np.zeros(n, bool)
        for s, d in edges.values():
            ok = T[s] & T[d]
            f[s[ok]] = True
            b[d[ok]] = True
        new = T & f & b
        if np.array_equal(new, T):
            break
        T = new

    def post(g, A):
        s, d = edges[g]
        o = np.zeros(n, bool)
        ok = A[s] & T[d]
        o[d[ok]] = True
        return o

    level = {'': T}
    forbidden = []
    counts = []
    for k in range(1, K + 1):
        nxt = {}
        for w, A in level.items():
            for g in (3, 5):
                B = post(g, A)
                w2 = w + str(g)
                if B.any():
                    nxt[w2] = B
                elif k == 1 or w2[1:] in level:
                    forbidden.append(w2)
        level = nxt
        counts.append(len(level))
        if len(level) > 4000:
            break
    return int(T.sum()), forbidden, counts


def sat_word(trap, spec, budget):
    lead = len(spec) - len(spec.lstrip('w'))
    trail = len(spec) - len(spec.rstrip('w'))
    gaps = spec.strip('w')
    bits = '0' * lead + '1' + ''.join('0' * (int(g) - 1) + '1' for g in gaps) + '0' * trail
    N = len(bits)
    cone = R.Cone(N)
    for i, ch in enumerate(bits):
        cone.clauses.append([cone.gate(i) if ch == '1' else -cone.gate(i)])
    cone.forbid_codes(N - 1, trap)
    status, row = cone.solve(budget)
    out = dict(word=spec, samples=N, status=status, variables=cone.nv, clauses=len(cone.clauses),
               cnf_sha256=cone.digest())
    if row is not None:
        gate, codes = R.simulate(row, N)
        trapset = set(trap)
        out['verified'] = bool(''.join(map(str, gate)) == bits and codes[-1] not in trapset)
        out['row'] = ''.join(map(str, row))
        out['final_window'] = codes[-1]
    return out


def main():
    kit, mode = sys.argv[1], sys.argv[2]
    trap = [int(c) for c in L.trap_codes(kit)]
    if mode == 'graph':
        W, K = int(sys.argv[3]), int(sys.argv[4])
        letters = (1, 2, 3, 4, 5, 6) if len(sys.argv) > 5 and sys.argv[5] == 'any' else (3, 5)
        t0 = time.time()
        forcing, counts = graph(trap, W, K, letters)
        print(json.dumps(dict(W=W, K=K, letters=letters, minimal_forcing_words=forcing,
                              words_readable_outside_by_gaps=counts, seconds=round(time.time() - t0, 1))))
    elif mode == 'language':
        W, K = int(sys.argv[3]), int(sys.argv[4])
        t0 = time.time()
        nT, forbidden, counts = language(trap, W, K)
        print(json.dumps(dict(W=W, recurrent_black_windows_outside=nT, minimal_words_not_read=forbidden,
                              words_read_by_gaps=counts, seconds=round(time.time() - t0, 1))))
    elif mode == 'sat':
        budget = int(sys.argv[3])
        for spec in sys.argv[4:]:
            t0 = time.time()
            r = sat_word(trap, spec, budget)
            r['seconds'] = round(time.time() - t0, 1)
            print(json.dumps(r))
            sys.stdout.flush()
    else:
        raise SystemExit('unknown mode')


if __name__ == '__main__':
    main()
