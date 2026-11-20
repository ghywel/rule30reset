#!/usr/bin/env python3
"""claudeCloud_m9_lift.py: pull M9, first block (ledger K42). The gate trap lifted to W columns: which gap words it
forbids, and the entropy of the gap language it reads.

Frame (kit Rule30GateTrap, Rule30GateTrapWords, Rule30GateTrapLift). A right half is driven by the alternating
column 1, 0, 1, 0, ... . A WINDOW is columns 1..W at an odd time, coded with bit i = column i + 1. Two steps later
the window is step2(w, x1, x2), where x1, x2 are the two values of column W + 1, which the window does not fix.
The kit's TRAP is a set of 829 sixteen-column windows closed under step2 for all x1, x2. The LIFT at W columns is
every W-column window whose first sixteen cells are a trap window; it is closed in the same way.

Column 1 is black at some windows. From a black window the next black one comes 3 or 5 double steps later (the
kit's layers): a GAP. The GAP GRAPH has the black lift windows as nodes and an edge labelled 3 or 5 for each way
of reaching the next black window. A gap word is READ if some path spells it.

Reported for each W:
  the sizes; the CORE (windows with arbitrarily long histories inside the lift);
  the deterministic automaton of the read words (subset construction from all black windows, and from the core's);
  the minimal forbidden gap words up to a given number of gaps;
  the entropy of the read language in bits per double step (growth of the number of words with total length).

  python3 claudeCloud_m9_lift.py KITFILE W [MAXGAPS [MAXSTATES]]
  python3 claudeCloud_m9_lift.py KITFILE check       the kit's facts at 16 and 18 columns
KITFILE is the kit's Rule30Certificates/GateTrap.lean, from which the 829 codes are read.
"""
import json
import math
import re
import sys

import numpy as np


def trap_codes(kitfile):
    text = open(kitfile).read()
    body = re.search(r'def trapCodes : List Nat := \[(.*?)\]', text, re.S).group(1)
    codes = [int(x) for x in re.findall(r'\d+', body)]
    return np.array(sorted(codes), dtype=np.int64)


def step(w, c0, x, W):
    """One tick of rule 30 on columns 1..W: column 0 is c0, column W + 1 is x. New column j = left xor (centre or right)."""
    r = (w << 1) | c0 | (x << (W + 1))
    return (r ^ ((r >> 1) | (r >> 2))) & ((1 << W) - 1)


def step2(w, x1, x2, W):
    """From an odd time: column 0 is white, then black."""
    return step(step(w, 0, x1, W), 1, x2, W)


class Lift:
    def __init__(self, trap, W):
        self.W = W
        hi = np.arange(1 << (W - 16), dtype=np.int64) << 16
        self.codes = np.sort((trap[None, :] | hi[:, None]).ravel())
        self.n = len(self.codes)
        self.succ = []
        for x1 in (0, 1):
            for x2 in (0, 1):
                nxt = step2(self.codes, x1, x2, W)
                idx = np.searchsorted(self.codes, nxt)
                idx = np.minimum(idx, self.n - 1)
                if not np.array_equal(self.codes[idx], nxt):
                    raise SystemExit('the lift is not closed at W = %d' % W)
                self.succ.append(idx)
        self.black = (self.codes & 1) == 1

    def image(self, mask):
        out = np.zeros(self.n, bool)
        for s in self.succ:
            out[s[mask]] = True
        return out

    def core(self):
        """Windows with arbitrarily long histories: iterate the image of the whole lift until it stops shrinking."""
        cur = np.ones(self.n, bool)
        k = 0
        while True:
            nxt = self.image(cur)
            if np.array_equal(nxt, cur):
                return cur, k
            cur = nxt
            k += 1

    def gap_edges(self):
        """Pairs (origin, target) of black windows 3 and 5 double steps apart, column 1 white in between."""
        n = self.n
        origins = np.nonzero(self.black)[0]

        def advance(pairs):                      # pairs: int64 keys origin * n + node
            o, v = pairs // n, pairs % n
            return np.unique(np.concatenate([o * n + s[v] for s in self.succ]))

        def split(pairs):
            b = self.black[pairs % n]
            return pairs[b], pairs[~b]

        p = origins * n + origins
        p = advance(p)
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


class Automaton:
    """Subset construction over gap words. State 0 is the start set; -1 means the empty set. Sets are kept over the
    black windows only, packed."""

    def __init__(self, lift, e3, e5, start_mask, max_states):
        self.ok = True
        bidx = np.cumsum(lift.black) - 1            # window index -> index among the black windows
        nb = int(lift.black.sum())
        edges = {3: (bidx[e3[0]], bidx[e3[1]]), 5: (bidx[e5[0]], bidx[e5[1]])}
        key0 = np.packbits(start_mask[lift.black]).tobytes()
        ids = {key0: 0}
        queue = [key0]
        self.delta = {3: [], 5: []}
        i = 0
        while i < len(queue):
            cur = np.unpackbits(np.frombuffer(queue[i], np.uint8))[:nb].astype(bool)
            queue[i] = None
            for g in (3, 5):
                src, dst = edges[g]
                out = np.zeros(nb, bool)
                out[dst[cur[src]]] = True
                if not out.any():
                    self.delta[g].append(-1)
                    continue
                key = np.packbits(out).tobytes()
                j = ids.get(key)
                if j is None:
                    j = len(queue)
                    ids[key] = j
                    queue.append(key)
                self.delta[g].append(j)
            i += 1
            if len(queue) > max_states:
                self.ok = False
                break
        self.nstates = len(queue)
        if self.ok:
            self.d3 = np.array(self.delta[3], dtype=np.int64)
            self.d5 = np.array(self.delta[5], dtype=np.int64)

    def run(self, word, state=0):
        for g in word:
            if state < 0:
                return -1
            state = int(self.d3[state] if g == 3 else self.d5[state])
        return state

    def minimal_forbidden(self, maxgaps):
        """Words w.g that are not read, with w read and (w.g) less its first letter read."""
        out = []
        level = [((), 0)]
        counts = [1]
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
            if len(level) > 2_000_000:
                break
        return out, counts

    def entropy(self, T=6000):
        """Bits per double step: growth of the number of read words with total length (sum of gaps)."""
        n = self.nstates
        hist = [np.zeros(n) for _ in range(5)]      # hist[k] = vector at total length t - k
        hist[0][0] = 1.0
        logs = 0.0
        marks = {}
        for t in range(1, T + 1):
            v = np.zeros(n)
            for g, d in ((3, self.d3), (5, self.d5)):
                src = hist[g - 1]
                ok = d >= 0
                np.add.at(v, d[ok], src[ok])
            hist = [v] + hist[:4]
            s = sum(h.sum() for h in hist)
            if s > 1e200:
                for h in hist:
                    h /= s
                logs += math.log2(s)
            if t in (T // 2, T):
                marks[t] = logs + math.log2(max(sum(h.sum() for h in hist), 1e-300))
        return (marks[T] - marks[T // 2]) / (T - T // 2)


def analyse(kitfile, W, maxgaps=24, max_states=400000):
    trap = trap_codes(kitfile)
    lift = Lift(trap, W)
    core, depth = lift.core()
    e3, e5 = lift.gap_edges()
    res = {'W': W, 'windows': lift.n, 'black': int(lift.black.sum()), 'core': int(core.sum()),
           'core_black': int((core & lift.black).sum()), 'core_reached_after': depth,
           'edges3': len(e3[0]), 'edges5': len(e5[0])}
    for name, start in (('entry', lift.black.copy()), ('eventual', core & lift.black)):
        a = Automaton(lift, e3, e5, start, max_states)
        r = {'states': a.nstates, 'complete': a.ok}
        if a.ok:
            mf, counts = a.minimal_forbidden(maxgaps)
            r['minimal_forbidden'] = mf
            r['words_by_gaps'] = counts
            r['entropy_bits_per_double_step'] = a.entropy()
        res[name] = r
    return res


def show(res):
    print('W = %d: %d windows (%d black); core %d (%d black), reached after %d double steps; gap edges %d + %d' % (
        res['W'], res['windows'], res['black'], res['core'], res['core_black'], res['core_reached_after'],
        res['edges3'], res['edges5']))
    for name in ('entry', 'eventual'):
        r = res[name]
        if not r['complete']:
            print('  %-8s automaton not completed: more than %d states' % (name, r['states']))
            continue
        mf = r['minimal_forbidden']
        print('  %-8s %d states; entropy %.6f bits per double step; words by number of gaps %s' % (
            name, r['states'], r['entropy_bits_per_double_step'], r['words_by_gaps'][:13]))
        print('           minimal forbidden (%d): %s' % (len(mf), ' '.join(mf[:40]) + (' ...' if len(mf) > 40 else '')))


def check(kitfile):
    ok = True
    trap = trap_codes(kitfile)
    print('trap: %d windows; entry code 49415 in it: %s' % (len(trap), 49415 in set(trap.tolist())))
    ok &= len(trap) == 829 and 49415 in set(trap.tolist())
    # the empty right half at time 293, simulated: columns 1..16 driven by the alternating column from the white row
    row = 0
    for t in range(293):
        c0 = 1 if t % 2 == 0 else 0
        r = (row << 1) | c0
        row = (r ^ ((r >> 1) | (r >> 2)))
    print('the empty right half at time 293 has window %d (kit: 49415)' % (row & 0xFFFF))
    ok &= (row & 0xFFFF) == 49415
    r16 = analyse(kitfile, 16, 12)
    show(r16)
    want = sorted(['333', '3353', '3533', '3553', '5533'])
    ok &= sorted(r16['entry']['minimal_forbidden']) == want
    print('16 columns forbids exactly 333, 3353, 3533, 3553, 5533 after entry (kit): %s' % (
        sorted(r16['entry']['minimal_forbidden']) == want))
    r18 = analyse(kitfile, 18, 12)
    show(r18)
    got = r18['entry']['minimal_forbidden']
    good = '3535353' in got and all(w in got for w in want)
    print('18 columns also forbids 3535353, minimally (kit): %s' % good)
    ok &= good
    free = math.log2(1.1938591113)      # the root of x^5 = x^2 + 1
    print('free 3/5 language: %.6f bits per double step' % free)
    print('CONTROLS:', 'PASS' if ok else 'FAIL')
    return ok


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[1] == 'check':
        sys.exit(0 if check(a[0]) else 1)
    res = analyse(a[0], int(a[1]), int(a[2]) if len(a) > 2 else 24, int(a[3]) if len(a) > 3 else 400000)
    show(res)
    print('JSON ' + json.dumps(res))
