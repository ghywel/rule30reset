#!/usr/bin/env python3
"""claudeCloud_m9_lift.py: pull M9, first block (ledger K42). The gate trap lifted to W columns: which gap words it
forbids, the entropy of the gap language it reads, and whether the free code {5, 3555} is still read.

Frame (kit Rule30GateTrap, Rule30GateTrapWords, Rule30GateTrapLift; placego L1610-L1614, GC2792-GC2800). A right
half is driven by the alternating column 1, 0, 1, 0, ... . A WINDOW is columns 1..W at an odd time, coded with bit
i = column i + 1. Two steps later the window is step2(w, x1, x2), where x1, x2 are the two values of column W + 1,
which the window does not fix. The kit's TRAP is a set of 829 sixteen-column windows closed under step2 for all x1,
x2. The LIFT at W columns is every W-column window whose first sixteen cells are a trap window; it is closed in the
same way.

Column 1 is black at some windows. From a black window the next black one comes 3 or 5 double steps later (the
kit's layers): a GAP. The GAP GRAPH has black windows as nodes and an edge labelled 3 or 5 for each way of reaching
the next black window. A gap word is READ if some path spells it.

The CORE at W is the set of lift windows with arbitrarily long histories inside the lift (the eventual image). The
EVENTUAL language is what paths from core windows read: the words that can occur arbitrarily late after entry.
The core at W + 2 lies inside the core at W extended by two columns (project a long history), so each core is
computed from the last one: extend, then take images until the set stops shrinking. At widths up to 22 the core is
also computed directly from the whole lift, as a control.

Reported for each W:
  the core; the deterministic automaton of the eventual language (subset construction over core black windows);
  its entropy in bits per double step (growth of the number of read words with their total length);
  the minimal forbidden gap words up to MAXGAPS gaps;
  whether every word of the free code {5, 3555}* is read, and if not the shortest code word that is not.
With "entry" also the language read from every black lift window (the kit's "after entry"), at small W.

  python3 claudeCloud_m9_lift.py KITFILE ladder WMAX [MAXGAPS [MAXSTATES]]    every even W from 16 to WMAX
  python3 claudeCloud_m9_lift.py KITFILE check                                the kit's facts at 16 and 18 columns
KITFILE is the kit's Rule30Certificates/GateTrap.lean, from which the 829 codes are read.
"""
import hashlib
import json
import math
import re
import sys
import time

import numpy as np


def trap_codes(kitfile):
    text = open(kitfile).read()
    body = re.search(r'def trapCodes : List Nat := \[(.*?)\]', text, re.S).group(1)
    codes = [int(x) for x in re.findall(r'\d+', body)]
    return np.array(sorted(codes), dtype=np.int64)


def step(w, c0, x, W):
    """One tick of rule 30 on columns 1..W: column 0 is c0, column W + 1 is x. New column = left xor (centre or right)."""
    r = (w << 1) | c0 | (x << (W + 1))
    return (r ^ ((r >> 1) | (r >> 2))) & ((1 << W) - 1)


def step2(w, x1, x2, W):
    """From an odd time: column 0 is white, then black."""
    return step(step(w, 0, x1, W), 1, x2, W)


class Graph:
    """A set of W-column windows closed under step2 for all inputs, with its four successor maps."""

    def __init__(self, codes, W):
        self.W = W
        self.codes = np.sort(codes)
        self.n = len(self.codes)
        self.succ = []
        for x1 in (0, 1):
            for x2 in (0, 1):
                nxt = step2(self.codes, x1, x2, W)
                idx = np.minimum(np.searchsorted(self.codes, nxt), self.n - 1)
                if not np.array_equal(self.codes[idx], nxt):
                    raise SystemExit('the window set is not closed at W = %d' % W)
                self.succ.append(idx)
        self.black = (self.codes & 1) == 1

    def image(self, mask):
        out = np.zeros(self.n, bool)
        for s in self.succ:
            out[s[mask]] = True
        return out

    def core(self):
        """Iterate the image of the whole set until it stops shrinking. Returns the mask and the number of steps."""
        cur = np.ones(self.n, bool)
        k = 0
        while True:
            nxt = self.image(cur)
            if np.array_equal(nxt, cur):
                return cur, k
            if (nxt & ~cur).any():
                raise SystemExit('images are not decreasing')
            cur = nxt
            k += 1

    def gap_edges(self, origin_mask):
        """Pairs (origin, target) of black windows 3 and 5 double steps apart, column 1 white in between."""
        n = self.n
        origins = np.nonzero(origin_mask & self.black)[0]

        def advance(pairs):                      # pairs: int64 keys origin * n + node
            o, v = pairs // n, pairs % n
            return np.unique(np.concatenate([o * n + s[v] for s in self.succ]))

        def split(pairs):
            b = self.black[pairs % n]
            return pairs[b], pairs[~b]

        p = advance(origins * n + origins)
        b, p = split(p)
        assert len(b) == 0, 'black one double step after black'
        p = advance(p)
        b, p = split(p)
        assert len(b) == 0, 'black two double steps after black'
        p = advance(p)
        e3, p = split(p)
        p = advance(p)
        b, p = split(p)
        assert len(b) == 0, 'black four double steps after black'
        p = advance(p)
        e5, p = split(p)
        assert len(p) == 0, 'white five double steps after black'
        return (e3 // n, e3 % n), (e5 // n, e5 % n)


def extend(codes, W):
    """Every (W + 2)-column window whose first W columns are in codes."""
    hi = np.arange(4, dtype=np.int64) << W
    return np.sort((codes[None, :] | hi[:, None]).ravel())


class Automaton:
    """Subset construction over gap words, on the black windows in start_mask and those reachable from them.
    State 0 is the start set; -1 means the empty set."""

    def __init__(self, graph, e3, e5, start_mask, max_states):
        self.ok = True
        n = graph.n
        reach = start_mask & graph.black
        while True:                               # black windows reachable from the start set
            new = reach.copy()
            for src, dst in (e3, e5):
                new[dst[reach[src]]] = True
            if np.array_equal(new, reach):
                break
            reach = new
        bidx = np.cumsum(reach) - 1
        nb = int(reach.sum())
        edges = {}
        for g, (src, dst) in ((3, e3), (5, e5)):
            keep = reach[src]
            edges[g] = (bidx[src[keep]], bidx[dst[keep]])
        start = (start_mask & graph.black)[reach]
        ids = {hashlib.blake2b(np.packbits(start).tobytes(), digest_size=16).digest(): 0}
        stack = [(0, np.packbits(start))]         # pending sets are kept packed
        d3, d5 = [-2], [-2]
        while stack:
            i, packed = stack.pop()
            cur = np.unpackbits(packed)[:nb].astype(bool)
            for g, d in ((3, d3), (5, d5)):
                src, dst = edges[g]
                out = np.zeros(nb, bool)
                out[dst[cur[src]]] = True
                if not out.any():
                    d[i] = -1
                    continue
                packed_out = np.packbits(out)
                key = hashlib.blake2b(packed_out.tobytes(), digest_size=16).digest()
                j = ids.get(key)
                if j is None:
                    j = len(d3)
                    ids[key] = j
                    d3.append(-2)
                    d5.append(-2)
                    stack.append((j, packed_out))
                d[i] = j
            if len(d3) > max_states:
                self.ok = False
                break
        self.nstates = len(d3)
        self.nodes = nb
        if self.ok:
            self.d3 = np.array(d3, dtype=np.int64)
            self.d5 = np.array(d5, dtype=np.int64)

    def run(self, word, state=0):
        for g in word:
            if state < 0:
                return -1
            state = int(self.d3[state] if g == 3 else self.d5[state])
        return state

    def minimal_forbidden(self, maxgaps, cap=3_000_000):
        """Words w.g that are not read, with w read and (w.g) less its first letter read."""
        out = []
        level = [((), 0)]
        counts = [1]
        complete_to = 0
        for n in range(1, maxgaps + 1):
            nxt = []
            for w, st in level:
                for g in (3, 5):
                    t = int(self.d3[st] if g == 3 else self.d5[st])
                    w2 = w + (g,)
                    if t >= 0:
                        nxt.append((w2, t))
                    elif self.run(w2[1:]) >= 0:
                        out.append(''.join(map(str, w2)))
            level = nxt
            counts.append(len(level))
            complete_to = n
            if len(level) > cap:
                break
        return out, counts, complete_to

    def code(self):
        """Is every word of {5, 3555}* read? Returns (yes, states met, the shortest code word not read or None)."""
        seen = {0: ''}
        order = [0]
        i = 0
        while i < len(order):
            st = order[i]
            i += 1
            for block in ((5,), (3, 5, 5, 5)):
                t = self.run(block, st)
                w = seen[st] + ''.join(map(str, block))
                if t < 0:
                    return False, len(seen), w
                if t not in seen:
                    seen[t] = w
                    order.append(t)
        return True, len(seen), None

    def entropy(self, T=6000):
        """Bits per double step: growth of the number of read words with total length (the sum of the gaps)."""
        n = self.nstates
        hist = [np.zeros(n) for _ in range(5)]      # hist[k] = vector at total length t - k
        hist[0][0] = 1.0
        ok3, ok5 = self.d3 >= 0, self.d5 >= 0
        t3, t5 = self.d3[ok3], self.d5[ok5]
        logs = 0.0
        marks = {}
        for t in range(1, T + 1):
            v = np.bincount(t3, weights=hist[2][ok3], minlength=n) + np.bincount(t5, weights=hist[4][ok5], minlength=n)
            hist = [v] + hist[:4]
            s = sum(h.sum() for h in hist)
            if s > 1e200:
                for h in hist:
                    h /= s
                logs += math.log2(s)
            if t in (T // 2, T):
                marks[t] = logs + math.log2(max(sum(h.sum() for h in hist), 1e-300))
        return (marks[T] - marks[T // 2]) / (T - T // 2)


def describe(a, maxgaps):
    r = {'states': a.nstates, 'complete': a.ok, 'black_windows': a.nodes}
    if a.ok:
        mf, counts, upto = a.minimal_forbidden(maxgaps)
        r['minimal_forbidden'] = mf
        r['minimal_forbidden_complete_to_gaps'] = upto
        r['words_by_gaps'] = counts[:16]
        r['entropy_bits_per_double_step'] = a.entropy()
        yes, met, bad = a.code()
        r['code_read'] = yes
        r['code_states'] = met
        r['code_first_unread'] = bad
        r['without_353'] = [w for w in mf if '353' not in w]
    return r


def show(W, res):
    print('W = %d: core %d windows (%d black)%s, %.0f s' % (
        W, res['core'], res['core_black'],
        '' if res.get('direct_core') is None else '; direct core from the whole lift agrees: %s' % res['direct_core'],
        res['seconds']))
    for name in ('entry', 'eventual'):
        r = res.get(name)
        if r is None:
            continue
        if not r['complete']:
            print('  %-8s automaton not completed: more than %d states' % (name, r['states']))
            continue
        mf = r['minimal_forbidden']
        lens = sorted(len(w) for w in mf)
        print('  %-8s %d states on %d black windows; entropy %.6f bits per double step' % (
            name, r['states'], r['black_windows'], r['entropy_bits_per_double_step']))
        print('           minimal forbidden to %d gaps: %d words%s; shortest first: %s' % (
            r['minimal_forbidden_complete_to_gaps'], len(mf),
            '' if not mf else ', of %d to %d gaps' % (lens[0], lens[-1]), ' '.join(sorted(mf, key=len)[:8])))
        print('           free code {5, 3555}* read: %s (%d states met)%s; minimal forbidden words without 353: %s' % (
            r['code_read'], r['code_states'],
            '' if r['code_read'] else ', first unread ' + r['code_first_unread'], ' '.join(r['without_353']) or 'none'))
    sys.stdout.flush()


def ladder(kitfile, wmax, maxgaps=24, max_states=400000, entry_to=18, direct_to=22):
    trap = trap_codes(kitfile)
    results = {}
    core_codes = None
    for W in range(16, wmax + 1, 2):
        t0 = time.time()
        cand = trap if W == 16 else extend(core_codes, W - 2)
        g = Graph(cand, W)
        core, _ = g.core()
        core_codes = g.codes[core]
        res = {'W': W, 'candidates': g.n, 'core': int(core.sum()), 'core_black': int((core & g.black).sum())}
        full = None
        if W <= direct_to:
            hi = np.arange(1 << (W - 16), dtype=np.int64) << 16
            full = Graph((trap[None, :] | hi[:, None]).ravel(), W)
            fcore, _ = full.core()
            res['direct_core'] = bool(np.array_equal(full.codes[fcore], core_codes))
            res['windows'] = full.n
        e3, e5 = g.gap_edges(core)
        res['eventual'] = describe(Automaton(g, e3, e5, core, max_states), maxgaps)
        if W <= entry_to and full is not None:
            f3, f5 = full.gap_edges(np.ones(full.n, bool))
            res['entry'] = describe(Automaton(full, f3, f5, np.ones(full.n, bool), max_states), maxgaps)
        res['seconds'] = time.time() - t0
        results[W] = res
        show(W, res)
    return results


def check(kitfile):
    ok = True
    trap = trap_codes(kitfile)
    print('trap: %d windows; entry code 49415 in it: %s' % (len(trap), 49415 in set(trap.tolist())))
    ok &= len(trap) == 829 and 49415 in set(trap.tolist())
    # the empty right half at time 293, simulated: columns 1.. driven by the alternating column from the white row
    row = 0
    for t in range(293):
        r = (row << 1) | (1 if t % 2 == 0 else 0)
        row = r ^ ((r >> 1) | (r >> 2))
    print('the empty right half at time 293 has window %d (kit: 49415)' % (row & 0xFFFF))
    ok &= (row & 0xFFFF) == 49415
    res = ladder(kitfile, 18, 12)
    want = sorted(['333', '3353', '3533', '3553', '5533'])
    got16 = sorted(res[16]['entry']['minimal_forbidden'])
    print('16 columns forbids exactly 333, 3353, 3533, 3553, 5533 after entry (kit): %s' % (got16 == want))
    ok &= got16 == want
    got18 = sorted(res[18]['entry']['minimal_forbidden'])
    print('18 columns forbids those and 3535353, and nothing else to 12 gaps (kit): %s' % (got18 == sorted(want + ['3535353'])))
    ok &= got18 == sorted(want + ['3535353'])
    ok &= res[16]['direct_core'] and res[18]['direct_core']
    # the entropy of words with no 33 and no 3553, by brute force on the last three letters
    frontier = {((), 0): 1}
    by_total = [0] * 3001
    while frontier:
        nf = {}
        for (suf, t), c in frontier.items():
            by_total[t] += c
            for g in (3, 5):
                w = suf + (g,)
                s = ''.join(map(str, w))
                if t + g <= 3000 and '33' not in s and '3553' not in s:
                    nf[(w[-3:], t + g)] = nf.get((w[-3:], t + g), 0) + c
        frontier = nf
    brute = (math.log2(sum(by_total[2996:3001])) - math.log2(sum(by_total[1496:1501]))) / 1500
    mine = res[16]['eventual']['entropy_bits_per_double_step']
    print('entropy at 16 columns: %.6f; words with no 33 and no 3553 by brute force: %.6f' % (mine, brute))
    ok &= abs(mine - brute) < 2e-6
    print('free 3/5 language: %.6f bits per double step' % math.log2(1.1938591113))
    print('CONTROLS:', 'PASS' if ok else 'FAIL')
    return ok


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[1] == 'check':
        sys.exit(0 if check(a[0]) else 1)
    if a[1] == 'ladder':
        res = ladder(a[0], int(a[2]), int(a[3]) if len(a) > 3 else 24, int(a[4]) if len(a) > 4 else 400000)
        print('JSON ' + json.dumps(res))
