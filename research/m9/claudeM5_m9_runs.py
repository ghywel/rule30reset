#!/usr/bin/env python3
"""claudeM5_m9_runs.py: pull M9, second block (claudeM5). The run grammar of the free code in the gate trap's lifts:
which code words each lift forbids late, whether they follow a rule, and which codes of run lengths are still read.

Frame: research/m9/claudeCloud_m9_lift.py (K42, frozen `cd0fa27a...`), whose window sets, rule, cores and gap steps
this script imports unchanged. A CODE WORD is a gap word whose 3s are separated by at least three 5s (it avoids 33,
353 and 3553): the factors of {5, 3555}* (GC2800). A RUN is the number r >= 3 of 5s between two 3s. A RUN WORD
(r1, ..., rk) stands for the gap word 3 5^r1 3 5^r2 3 ... 3 5^rk 3. It is READ LATE at W if a path of the gap graph
from a black window of the core at W spells it (the eventual language of K42); a right half that has spent at least
`settle` double steps inside the trap is in the core (its window has that long a history inside the lift), so a run
word that is not read late at W never occurs in a real right half after that time.

The RUN AUTOMATON: its states are the sets of core black windows reached just after a 3, starting from
S0 = (all core black windows) . 3, and the letter r maps S to S . 5^r . 3. Sets are built lazily from the four
successor maps, one gap at a time, and each set is identified by a hash of its sorted indices. For each state the
chain S . 5^j is followed until it repeats or dies, so every run length r, however long, is covered: beyond the chain's
first repeat, T_r depends only on r modulo the repeat's period.

  python3 claudeM5_m9_runs.py KITFILE dev WMAX                      controls at every even W <= WMAX (W <= 30 known)
  python3 claudeM5_m9_runs.py KITFILE run W1,W2,... OUTDIR [KMAX]   the block: report and JSON per width
KITFILE is the kit's Rule30Certificates/GateTrap.lean. Cores are cached in OUTDIR as core-W.npy.
"""
import hashlib
import importlib.util
import itertools
import json
import math
import pathlib
import sys
import time

import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
LIFT = HERE / 'claudeCloud_m9_lift.py'
LIFT_SHA = 'cd0fa27a2a6669864883'  # first 20 hex digits of the frozen K42 ladder


def load_lift():
    sha = hashlib.sha256(LIFT.read_bytes()).hexdigest()
    if not sha.startswith(LIFT_SHA):
        raise SystemExit('the K42 ladder is not the frozen one: %s' % sha)
    spec = importlib.util.spec_from_file_location('m9lift', LIFT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


L = load_lift()


def cores(kitfile, widths, cache=None):
    """The core at each even W up to max(widths), each from the last (K42's rule). Yields (W, graph, core mask,
    settle), where settle is the sum of the image steps of every rung to W: a right half that has spent that many
    double steps inside the trap has its W-column window in the core, whatever lies beyond column W."""
    trap = L.trap_codes(kitfile)
    core_codes = None
    total = 0
    for W in range(16, max(widths) + 1, 2):
        path = None if cache is None else pathlib.Path(cache) / ('core-%d.npy' % W)
        cand = trap if W == 16 else L.extend(core_codes, W - 2)
        if path is not None and path.exists() and W not in widths:
            core_codes = np.load(path)
            total += json.loads(path.with_suffix('.json').read_text())['steps']
            continue
        g = L.Graph(cand, W)
        core, steps = g.core()
        total += steps
        core_codes = g.codes[core]
        if path is not None:
            np.save(path, core_codes)
            path.with_suffix('.json').write_text(json.dumps({'W': W, 'steps': steps, 'core': len(core_codes)}))
        if W in widths:
            yield W, g, core, total
        else:
            del g


class Core:
    """The core at W as its own closed graph, with int32 indices; gap steps on sets of black windows."""

    def __init__(self, g, core):
        self.W = g.W
        idx = np.cumsum(core) - 1
        self.n = int(core.sum())
        for s in g.succ:
            assert core[s[core]].all(), 'a successor of a core window is outside the core'
        self.succ = [idx[s[core]].astype(np.int32) for s in g.succ]
        self.black = g.black[core]
        self.nblack = int(self.black.sum())

    def img(self, S):
        if len(S) > self.n // 24:
            m = np.zeros(self.n, bool)
            for s in self.succ:
                m[s[S]] = True
            return np.nonzero(m)[0].astype(np.int32)
        return np.unique(np.concatenate([s[S] for s in self.succ]))

    def gaps(self, S):
        """(S . 3, S . 5) for a set S of black core windows, as sorted int32 arrays; checks the kit's layer facts."""
        x1 = self.img(S)
        assert not self.black[x1].any(), 'black one double step after black'
        x2 = self.img(x1)
        assert not self.black[x2].any(), 'black two double steps after black'
        x3 = self.img(x2)
        b = self.black[x3]
        s3, w3 = x3[b], x3[~b]
        x4 = self.img(w3)
        assert not self.black[x4].any(), 'black four double steps after black'
        x5 = self.img(x4)
        assert self.black[x5].all(), 'white five double steps after black'
        return s3, x5


def key(S):
    return hashlib.blake2b(S.tobytes(), digest_size=16).digest() if len(S) else b'EMPTY'


class Sets:
    """Lazy gap transitions on hashed sets. memo[h] = (h3, h5); arrays kept only until a set is expanded."""

    def __init__(self, core):
        self.c = core
        self.memo = {}
        self.arr = {}
        self.expanded = 0

    def add(self, S):
        h = key(S)
        if h != b'EMPTY' and h not in self.memo and h not in self.arr:
            self.arr[h] = S
        return h

    def step(self, h):
        if h == b'EMPTY':
            return b'EMPTY', b'EMPTY'
        r = self.memo.get(h)
        if r is None:
            S = self.arr.pop(h)
            s3, s5 = self.c.gaps(S)
            r = (self.add(s3), self.add(s5))
            self.memo[h] = r
            self.expanded += 1
        return r


def run_automaton(core, max_states=400000, chain_cap=400):
    """States: sets just after a 3. T[i] = dict r -> state or -1 for r in 3..cut-1; tail[i] = (start, period, states)
    so that for r >= start, T_r = states[(r - start) % period] (an empty list: dead for every r >= start)."""
    sets = Sets(core)
    allb = np.nonzero(core.black)[0].astype(np.int32)
    hb = sets.add(allb)
    h0, _ = sets.step(hb)
    ids = {h0: 0}
    order = [h0]
    T, tail, r1 = [], [], []
    i = 0
    while i < len(order):
        h = order[i]
        i += 1
        chain = [h]
        pos = {h: 0}
        trans = {}
        y = h
        start = period = None
        three = []
        for j in range(chain_cap):
            y3, y5 = sets.step(y)
            three.append(y3)
            if y5 == b'EMPTY':
                start, period = j + 1, 0
                break
            if y5 in pos:
                start, period = pos[y5], j + 1 - pos[y5]
                break
            pos[y5] = j + 1
            chain.append(y5)
            y = y5
        if start is None:
            raise SystemExit('a chain of 5s did not repeat within %d' % chain_cap)

        def sid(h3):
            if h3 == b'EMPTY':
                return -1
            k = ids.get(h3)
            if k is None:
                k = len(order)
                ids[h3] = k
                order.append(h3)
            return k

        r1.append(three[1] != b'EMPTY' if len(three) > 1 else False)
        for r in range(3, len(three)):
            trans[r] = sid(three[r])
        if period == 0:
            tl = (len(three), 0, [])
        else:
            # three[j] = chain[j] . 3 for j < len(chain); the cycle is chain[start:]
            cyc = [sid(sets.step(chain[start + q])[0]) for q in range(period)]
            tl = (start, period, cyc)
            for r in range(max(3, start), len(three)):
                assert trans[r] == cyc[(r - start) % period]
        T.append(trans)
        tail.append(tl)
        if len(order) > max_states:
            return None, len(order), sets
    return RunDFA(T, tail, r1), len(order), sets


class RunDFA:
    def __init__(self, T, tail, r1):
        self.T, self.tail, self.r1 = T, tail, r1
        self.n = len(T)
        periods = [tl[1] for tl in tail if tl[1] > 0]
        self.lcm = 1
        for p in periods:
            self.lcm = self.lcm * p // math.gcd(self.lcm, p)
        R = 3
        for t, (start, period, _) in zip(T, tail):
            R = max(R, max(t) if t else 3, start + self.lcm + 1)
        self.R = R
        self.letters = list(range(3, R + 1))
        self.tab = self.table(self.letters)

    def go(self, s, r):
        if s < 0:
            return -1
        t = self.T[s].get(r)
        if t is not None:
            return t
        start, period, cyc = self.tail[s]
        if r < start:
            return -1
        return -1 if period == 0 else cyc[(r - start) % period]

    def col(self, r):
        """The letter column standing for run length r (exact for every r: beyond R, r is reduced mod lcm)."""
        if r > self.R:
            r = self.R - self.lcm + 1 + (r - (self.R - self.lcm + 1)) % self.lcm
        return r - 3

    def run(self, word, s=0):
        for r in word:
            if s < 0:
                return -1
            s = int(self.tab[s, self.col(r)])
        return s

    def table(self, letters):
        return np.array([[self.go(s, r) for r in letters] for s in range(self.n)], dtype=np.int64)

    def minimize(self):
        """Moore refinement of the complete automaton (a dead state appended); the number of classes, dead included."""
        n = self.n
        full = np.vstack([np.where(self.tab < 0, n, self.tab), np.full((1, len(self.letters)), n)])
        cls = np.zeros(n + 1, np.int64)
        cls[n] = 1
        k = 2
        while True:
            sig = np.concatenate([cls[:, None], cls[full]], axis=1)
            _, new = np.unique(sig, axis=0, return_inverse=True)
            new = new.ravel()
            k2 = int(new.max()) + 1
            if k2 == k:
                return new, k2
            cls, k = new, k2

    def closure_ok(self, allowed):
        """Is every run word over the run lengths `allowed` read (no dead letter from any state reached from 0)?"""
        cols = sorted(set(self.col(r) for r in allowed))
        seen = np.zeros(self.n, bool)
        seen[0] = True
        front = np.array([0])
        while len(front):
            nxt = self.tab[front][:, cols].ravel()
            if (nxt < 0).any():
                return False
            nxt = np.unique(nxt)
            nxt = nxt[~seen[nxt]]
            seen[nxt] = True
            front = nxt
        return True

    def power_free(self, r, kmax=60):
        """The least k with r^k not read, or None up to kmax."""
        s = 0
        for k in range(1, kmax + 1):
            s = int(self.tab[s, self.col(r)])
            if s < 0:
                return k
        return None

    def minimal_forbidden(self, kmax, examples=6, maxpairs=20_000_000, strict=True):
        """Minimal forbidden run words over the letters 3..R by length k (in runs): w = a.v.b not read, with a.v and
        v.b read. Counted exactly on pairs (state after a.v from 0, state after v from 0); a few words recovered."""
        n, m = self.n, len(self.letters)
        first = self.tab[0]
        keys = np.unique(first[first >= 0].astype(np.int64) * (n + 1) + 0)
        counts = np.bincount(np.searchsorted(keys, first[first >= 0].astype(np.int64) * (n + 1)),
                             minlength=len(keys)).astype(float)
        hist = [(keys, None, None)]
        out = {1: (int((first < 0).sum()), [[r] for r, t in zip(self.letters, first) if t < 0][:examples])}
        for k in range(2, kmax + 1):
            s1, s2 = keys // (n + 1), keys % (n + 1)
            t1, t2 = self.tab[s1], self.tab[s2]           # shape (pairs, m)
            hit = (t1 < 0) & (t2 >= 0)
            cnt = float((counts[:, None] * hit).sum())
            ex = []
            for pi, li in zip(*np.nonzero(hit)):
                if len(ex) >= examples:
                    break
                ex.append(self._back(hist, len(hist) - 1, int(pi)) + [self.letters[int(li)]])
            out[k] = (cnt, ex)
            live = t1 >= 0
            if strict:   # S0 . a lies inside S0, so the set after a.v lies inside the set after v
                assert (t2[live] >= 0).all(), 'a state after a.v is live where the state after v is dead'
            else:
                live &= t2 >= 0
            nk = t1[live] * (n + 1) + t2[live]
            par = np.nonzero(live)[0]
            lets = np.nonzero(live)[1]
            w = counts[par]
            keys2, inv = np.unique(nk, return_inverse=True)
            counts = np.bincount(inv.ravel(), weights=w, minlength=len(keys2))
            firstidx = np.full(len(keys2), -1, np.int64)
            firstidx[inv.ravel()[::-1]] = np.arange(len(inv.ravel()))[::-1]
            hist.append((keys2, par[firstidx], lets[firstidx]))
            keys = keys2
            if len(keys) > maxpairs:
                return out, k
        return out, kmax

    def _back(self, hist, level, idx):
        """A run word a.v reaching pair hist[level][0][idx] (first letter a, then v)."""
        word = []
        while level > 0:
            _, par, lets = hist[level]
            word.append(self.letters[int(lets[idx])])
            idx = int(par[idx])
            level -= 1
        key0 = int(hist[0][0][idx])
        s1 = key0 // (self.n + 1)
        a = next(r for r, t in zip(self.letters, self.tab[0]) if t == s1)
        return [a] + word[::-1]

    def entropy(self, allowed=None, rmax=90, iters=44, burn=60, power=240):
        """Bits per double step of the run language over `allowed` run lengths (None: every r >= 3): the root z of
        spectral radius 1 of M(z) = sum_r z^(5r+3) [T_r], a run word of total length D weighing z^D."""
        rs = list(range(3, rmax + 1)) if allowed is None else sorted(set(r for r in allowed if r <= rmax))
        n = self.n
        src, dst, dur = [], [], []
        for r in rs:
            t = self.tab[:, self.col(r)]
            ok = t >= 0
            src.append(np.nonzero(ok)[0])
            dst.append(t[ok])
            dur.append(np.full(int(ok.sum()), 5 * r + 3, float))
        src, dst, dur = np.concatenate(src), np.concatenate(dst), np.concatenate(dur)
        if len(src) == 0:
            return 0.0
        pk, pinv = np.unique(src * (n + 1) + dst, return_inverse=True)
        ps, pd = pk // (n + 1), pk % (n + 1)

        def rho(z):
            w = np.bincount(pinv.ravel(), weights=z ** dur, minlength=len(pk))
            v = np.ones(n)
            logs = 0.0
            for it in range(burn + power):
                u = np.bincount(pd, weights=w * v[ps], minlength=n)
                nrm = u.max()
                if nrm == 0:
                    return 0.0
                v = u / nrm
                if it >= burn:
                    logs += math.log(nrm)
            return math.exp(logs / power)

        lo, hi = 0.80, 1.0
        for _ in range(iters):
            z = (lo + hi) / 2
            if rho(z) > 1:
                hi = z
            else:
                lo = z
        return -math.log2((lo + hi) / 2)


def block_code_states(core, sets):
    """K42's code(): the states met by {5, 3555} from the start set of every core black window, read gap by gap."""
    allb = np.nonzero(core.black)[0].astype(np.int32)
    h = sets.add(allb)
    seen = {h}
    order = [h]
    i = 0
    while i < len(order):
        x = order[i]
        i += 1
        for block in ((5,), (3, 5, 5, 5)):
            y = x
            for g in block:
                y3, y5 = sets.step(y)
                y = y3 if g == 3 else y5
                if y == b'EMPTY':
                    return False, len(seen)
            if y not in seen:
                seen.add(y)
                order.append(y)
    return True, len(seen)


def gap_word(runs):
    return '3' + ''.join('5' * r + '3' for r in runs)


def runs_of(word):
    """'3 5^a 3 5^b 3' -> (a, b); the word must begin and end with 3."""
    assert word[0] == '3' and word[-1] == '3'
    return tuple(len(x) for x in word[1:-1].split('3'))


def contains(y, x):
    return set(x[0]) <= set(y[0]) and (y[1] or not x[1])


def report(W, g, core_mask, steps, kmax):
    t0 = time.time()
    c = Core(g, core_mask)
    dfa, nstates, sets = run_automaton(c)
    res = {'W': W, 'core': c.n, 'core_black': c.nblack, 'settle': steps, 'run_states': nstates,
           'sets_expanded': sets.expanded}
    del sets
    if dfa is None:
        res['complete'] = False
        return res, None
    res['complete'] = True
    res['letters'] = [3, dfa.R]
    res['lcm'] = dfa.lcm
    res['tails'] = sorted(set((tl[0], tl[1]) for tl in dfa.tail))[:20]
    res['r1_353_read'] = bool(dfa.r1[0])
    res['code_read'] = dfa.closure_ok(dfa.letters)
    _, ncls = dfa.minimize()
    res['minimal_states'] = ncls - 1                      # less the dead class
    res['power_free'] = {r: dfa.power_free(r) for r in range(3, 13)}
    mf, done = dfa.minimal_forbidden(kmax)
    res['minimal_forbidden_by_runs'] = {k: v[0] for k, v in mf.items()}
    res['minimal_forbidden_examples'] = {k: v[1] for k, v in mf.items() if v[1]}
    res['minimal_forbidden_complete_to_runs'] = done
    base = list(range(3, 10))
    longr = list(range(10, dfa.R + 1))
    codes = []
    for k in range(len(base) + 1):
        for A in itertools.combinations(base, k):
            for wl in (False, True):
                allowed = list(A) + (longr if wl else [])
                if allowed and dfa.closure_ok(allowed):
                    codes.append((A, wl))
    maximal = [x for x in codes if not any(y != x and contains(y, x) for y in codes)]
    res['maximal_read_codes'] = [[list(A), wl] for A, wl in maximal]
    res['entropy_code'] = dfa.entropy()
    res['entropy_maximal'] = [[list(A), wl, dfa.entropy(list(A) + (list(range(10, 91)) if wl else []))]
                              for A, wl in maximal]
    res['seconds'] = time.time() - t0
    return res, dfa


def show(res):
    print('W = %d: core %d windows (%d black), a right half is in it after %d double steps in the trap; '
          'run automaton %s states, %d sets'
          % (res['W'], res['core'], res['core_black'], res['settle'], res['run_states'], res['sets_expanded']))
    if not res['complete']:
        print('  not completed')
        sys.stdout.flush()
        return
    print('  letters 3..%d stand for every run length (lcm of the 5-chain periods %d); 353 read: %s; every code word '
          'read: %s; minimal automaton %d states' % (res['letters'][1], res['lcm'], res['r1_353_read'],
                                                    res['code_read'], res['minimal_states']))
    print('  least k with r^k not read: %s' % ', '.join('%d:%s' % (r, k) for r, k in res['power_free'].items()))
    print('  minimal forbidden run words over runs 3..%d, by number of runs (complete to %d):' % (
        res['letters'][1], res['minimal_forbidden_complete_to_runs']))
    for k, cnt in res['minimal_forbidden_by_runs'].items():
        if cnt:
            ex = res['minimal_forbidden_examples'].get(k, [])
            print('    %2d runs: %-14s e.g. %s' % (k, '%.0f' % cnt, '  '.join(','.join(map(str, w)) for w in ex)))
    print('  maximal codes read (run lengths among 3..9; "+" means with every run length >= 10):')
    for A, wl, h in res['entropy_maximal']:
        print('    {%s}%s  entropy %.6f' % (','.join(map(str, A)), ' +' if wl else '', h))
    print('  entropy of the code words read: %.6f bits per double step (%.0f s)' % (res['entropy_code'],
                                                                                    res['seconds']))
    sys.stdout.flush()


def dev(kitfile, wmax):
    """Controls on known widths: K42's code states met (3, 6, 8, 10, 21, 80, 298, 2,180 at 16..30), every code word
    read to 30 (K47), and the free-code entropy log2 of the root of x^18 = x^13 + 1 (GC2800: 0.0990561470135)."""
    want = {16: 3, 18: 6, 20: 8, 22: 10, 24: 21, 26: 80, 28: 298, 30: 2180}
    ok = True
    for W, g, core, steps in cores(kitfile, list(range(16, wmax + 1, 2))):
        t0 = time.time()
        c = Core(g, core)
        yes, met = block_code_states(c, Sets(c))
        dfa, n, _ = run_automaton(c)
        allread = dfa.closure_ok(dfa.letters)
        h = dfa.entropy()
        mf, done = dfa.minimal_forbidden(12)
        nmf = sum(v[0] for v in mf.values())
        good = yes and met == want.get(W, met) and allread and abs(h - 0.0990561470135) < 2e-6 and nmf == 0
        ok &= good
        print('W = %d: code states met %d (K42 %s), block code read %s, run code read %s, %d run states (R %d, '
              'lcm %d), no minimal forbidden run word to %d runs: %s, code entropy %.9f, settle %d, %.0f s: %s'
              % (W, met, want.get(W), yes, allread, dfa.n, dfa.R, dfa.lcm, done, nmf == 0, h, steps,
                 time.time() - t0, 'ok' if good else 'FAIL'))
        sys.stdout.flush()
    # A negative control: kill the letter 4 at the state s3 reached by (4, 4, 4) in the last automaton. Then 4^j is
    # first unread for j = 1 + the least i with 4^i reaching s3 (s3 may be reached already by (4, 4)), 4^j must be
    # among the minimal forbidden words of j runs, and the code must not be read.
    s3 = dfa.run([4, 4, 4])
    j = 1 + min(i for i in range(4) if dfa.run([4] * i) == s3)
    dfa.tab[s3, dfa.col(4)] = -1
    mf, _ = dfa.minimal_forbidden(6, strict=False)
    neg = mf[j][0] >= 1 and dfa.power_free(4) == j and not dfa.closure_ok(dfa.letters)
    print('negative control at W = %d: killing 4 at the state of (4,4,4), first reached by 4^%d, gives 4^%d unread '
          '(least k: %s), %.0f minimal forbidden words of %d runs, e.g. %s, and code read %s: %s'
          % (W, j - 1, j, dfa.power_free(4), mf[j][0], j, mf[j][1][:3], dfa.closure_ok(dfa.letters),
             'ok' if neg else 'FAIL'))
    ok &= neg
    print('CONTROLS:', 'PASS' if ok else 'FAIL')
    return ok


def main():
    a = sys.argv[1:]
    if a[1] == 'dev':
        sys.exit(0 if dev(a[0], int(a[2])) else 1)
    widths = [int(x) for x in a[2].split(',')]
    out = pathlib.Path(a[3])
    out.mkdir(parents=True, exist_ok=True)
    kmax = int(a[4]) if len(a) > 4 else 24
    for W, g, core, steps in cores(a[0], widths, cache=out):
        res, dfa = report(W, g, core, steps, kmax)
        show(res)
        (out / ('runs-%d.json' % W)).write_text(json.dumps(res, default=str))
        if dfa is not None:
            np.save(out / ('runtab-%d.npy' % W), dfa.tab)
        del g, dfa


if __name__ == '__main__':
    main()
