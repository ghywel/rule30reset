#!/usr/bin/env python3
"""claudeM5_m9_runs_read.py: reading M78's run tables after the fact (written after the frozen run started).

  python3 claudeM5_m9_runs_read.py OUTDIR W [W ...]

For each width it loads runtab-W.npy and runs-W.json from M78's output folder and prints:
  L1614's measured absences (MEASURED in real rows) held against the lift: (4,4,4), (5,4,4), (r,4,4) for every r,
  five runs of five, and powers;
  the minimal automaton, when it has at most 60 states: each class with its run letters grouped by target.

  python3 claudeM5_m9_runs_read.py OUTDIR --analysis       every after-the-fact figure of M79, at 32 and 34
"""
import json
import pathlib
import sys

import numpy as np


class Tab:
    def __init__(self, tab, R, lcm):
        self.tab, self.R, self.lcm, self.n = tab, R, lcm, tab.shape[0]
        self.letters = list(range(3, R + 1))

    def col(self, r):
        if r > self.R:
            r = self.R - self.lcm + 1 + (r - (self.R - self.lcm + 1)) % self.lcm
        return r - 3

    def run(self, word, s=0):
        for r in word:
            if s < 0:
                return -1
            s = int(self.tab[s, self.col(r)])
        return s

    def minimize(self):
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


def kmp(f):
    """Matcher for the factor f over run letters: delta(j, r) = length of the longest prefix of f that is a suffix
    of f[:j] + [r]."""
    def delta(j, r):
        w = list(f[:j]) + [r]
        for k in range(min(len(w), len(f)), -1, -1):
            if w[len(w) - k:] == list(f[:k]):
                return k
        return 0
    return delta


def avoid_ok(t, factors):
    """Is every code word that contains none of `factors` read? (So that every unread word contains one of them.)
    Explores pairs (state, matcher states) over every run letter, never completing a factor."""
    ms = [kmp(f) for f in factors]
    start = (0,) + (0,) * len(factors)
    seen = {start}
    stack = [start]
    while stack:
        st = stack.pop()
        s, js = st[0], st[1:]
        for r in t.letters:
            nj = tuple(m(j, r) for m, j in zip(ms, js))
            if any(j == len(f) for j, f in zip(nj, factors)):
                continue
            tgt = int(t.tab[s, t.col(r)])
            if tgt < 0:
                return False
            nxt = (tgt,) + nj
            if nxt not in seen:
                seen.add(nxt)
                stack.append(nxt)
    return True


def witness(t, factors, letters=None):
    """The shortest unread code word (in runs, over `letters`) containing none of `factors`, or None."""
    from collections import deque
    letters = letters or t.letters
    ms = [kmp(f) for f in factors]
    start = (0,) + (0,) * len(factors)
    par = {start: None}
    dq = deque([start])
    while dq:
        st = dq.popleft()
        s, js = st[0], st[1:]
        for r in letters:
            nj = tuple(m(j, r) for m, j in zip(ms, js))
            if any(j == len(f) for j, f in zip(nj, factors)):
                continue
            tgt = int(t.tab[s, t.col(r)])
            if tgt < 0:
                w = [r]
                x = st
                while par[x] is not None:
                    x, rr = par[x]
                    w.append(rr)
                return w[::-1]
            nxt = (tgt,) + nj
            if nxt not in par:
                par[nxt] = (st, r)
                dq.append(nxt)
    return None


def minimal_words(t, k, letters=None):
    """Every minimal forbidden run word of exactly k runs over `letters` (unread; both one-run-shorter pieces read)."""
    letters = letters or t.letters
    cols = [t.col(r) for r in letters]
    n = t.n
    levels = []
    first = t.tab[0, cols]
    keys = {}
    for r, x in zip(letters, first):
        if x >= 0:
            keys.setdefault((int(x), 0), []).append((None, r))
    levels.append(keys)
    for j in range(2, k):
        nk = {}
        for (a, b) in levels[-1]:
            for r, c in zip(letters, cols):
                x, y = int(t.tab[a, c]), int(t.tab[b, c])
                if x >= 0:
                    nk.setdefault((x, y), []).append(((a, b), r))
        levels.append(nk)
    hits = []
    for (a, b) in levels[-1]:
        for r, c in zip(letters, cols):
            if int(t.tab[a, c]) < 0 and int(t.tab[b, c]) >= 0:
                hits.append(((a, b), r))
    out = []

    def back(level, pair, suffix):
        for prev, r in levels[level][pair]:
            if prev is None:
                out.append([r] + suffix)
            else:
                back(level - 1, prev, [r] + suffix)
    for pair, r in hits:
        back(len(levels) - 1, pair, [r])
    return sorted(out)


def ranges(rs, R):
    out, i = [], 0
    while i < len(rs):
        j = i
        while j + 1 < len(rs) and rs[j + 1] == rs[j] + 1:
            j += 1
        a, b = rs[i], rs[j]
        out.append(('%d+' % a) if b == R else (str(a) if a == b else '%d-%d' % (a, b)))
        i = j + 1
    return ','.join(out)


FACTORS = {}


def main():
    out = pathlib.Path(sys.argv[1])
    args = sys.argv[2:]
    if args == ['--analysis']:
        analysis(out)
        return
    if '--factors' in args:      # --factors W:4.4.4.4.6/6.4.4 ...  (a slash separates alternatives)
        i = args.index('--factors')
        for spec in args[i + 1:]:
            W, fs = spec.split(':')
            FACTORS.setdefault(int(W), []).append([tuple(map(int, f.split('.'))) for f in fs.split('/')])
        args = args[:i]
    for W in map(int, args):
        res = json.loads((out / ('runs-%d.json' % W)).read_text())
        t = Tab(np.load(out / ('runtab-%d.npy' % W)), res['letters'][1], res['lcm'])
        rd = lambda w: 'read' if t.run(w) >= 0 else 'NOT read'
        print('W = %d (%d run states)' % (W, t.n))
        for w in ([4, 4, 4], [5, 4, 4], [5, 5, 5, 5, 5], [4, 4, 4, 4, 4], [4, 4, 4, 4, 4, 4]):
            print('  %-14s %s' % (','.join(map(str, w)), rd(w)))
        pre = [r for r in range(3, 31) if t.run([r, 4, 4]) >= 0]
        print('  (r, 4, 4) read for r in: %s (L1614: real rows show only r = 3, 7, 11, 12)' % ranges(pre, 30))
        for fs in FACTORS.get(W, []):
            print('  every unread code word contains one of %s: %s' % (
                ' or '.join('(%s)' % ','.join(map(str, f)) for f in fs), avoid_ok(t, fs)))
        cls, k = t.minimize()
        print('  minimal automaton: %d live classes' % (k - 1))
        if k - 1 <= 60:
            dead = cls[t.n]
            start = cls[0]
            reps = {}
            for s in range(t.n):
                reps.setdefault(int(cls[s]), s)
            names = {c: 'q%d' % i for i, c in enumerate(sorted(reps, key=lambda c: (c != start, c)))}
            names[int(dead)] = 'dead'
            for c in sorted(reps, key=lambda c: (c != start, c)):
                s = reps[c]
                by = {}
                for r in t.letters:
                    tgt = t.tab[s, t.col(r)]
                    by.setdefault(names[int(dead if tgt < 0 else cls[tgt])], []).append(r)
                print('    %-5s %s' % (names[c], '   '.join('%s->%s' % (ranges(v, t.R), d) for d, v in by.items())))



def analysis(out):
    """Every after-the-fact figure M79 quotes, from runtab-32/34 and runs-32/34 (python3 ... OUTDIR --analysis)."""
    import collections
    tabs = {}
    for W in (32, 34):
        res = json.loads((out / ('runs-%d.json' % W)).read_text())
        tabs[W] = Tab(np.load(out / ('runtab-%d.npy' % W)), res['letters'][1], res['lcm'])
        print('W = %d: %d run states; code entropy %.12f; free code 0.0990561470135' % (W, tabs[W].n,
                                                                                         res['entropy_code']))
    t = tabs[32]
    K = (4, 6, 4, 4, 5, 5)
    print('32: every unread code word contains (4,6,4,4,5,5): %s' % avoid_ok(t, [K]))
    print('32: ... and (4,6,4,4): %s; but not always (4,4,6,4,4,5,5): %s' % (avoid_ok(t, [(4, 6, 4, 4)]),
                                                                           avoid_ok(t, [(4,) + K])))
    print('32: the run before the core is one of 3,4,5,6,8: %s' % avoid_ok(t, [(r,) + K for r in (3, 4, 5, 6, 8)]))
    post = collections.defaultdict(set)
    for s in range(t.n):
        x = t.run(list(K), s)
        if x >= 0:
            post[x].add(s)
    for x, pre in sorted(post.items(), key=lambda kv: -len(kv[1])):
        kills = []
        level = [((), x)]
        for k in range(1, 7):
            nxt = []
            for w, s in level:
                for r in range(3, 13):
                    y = int(t.tab[s, t.col(r)])
                    (kills.append(w + (r,)) if y < 0 else nxt.append((w + (r,), y)))
            level = nxt
        print('32: after the core, state %d (from %d states): %d killing suffixes to 6 runs over 3..12; first %s'
              % (x, len(pre), len(kills), ' '.join(','.join(map(str, w)) for w in kills[:12])))
    small = min(post, key=lambda x: len(post[x]))
    bad = np.array([t.run(list(K), s) == small for s in range(t.n)])
    full = np.vstack([np.where(t.tab < 0, t.n, t.tab), np.full((1, t.tab.shape[1]), t.n)])
    cls = np.concatenate([bad.astype(np.int64), [2]])
    k = 3
    while True:
        sig = np.concatenate([cls[:, None], cls[full]], axis=1)
        _, new = np.unique(sig, axis=0, return_inverse=True)
        new = new.ravel()
        k2 = int(new.max()) + 1
        if k2 == k:
            break
        cls, k = new, k2
    print('32: the left contexts (states leading to the rare one): %d states; their minimal automaton %d classes '
          'with dead' % (int(bad.sum()), k))
    t = tabs[34]
    print('34: the 6-run minimal forbidden words: %s' % minimal_words(t, 6))
    fam = [(4, 4, 4, 4), (6, 5, 5, 6), (6, 5, 6, 6), (6, 4, 4, 4, 6, 4, 4)]
    print('34: shortest unread avoiding (4,4,4,4): %s' % witness(t, [(4, 4, 4, 4)], list(range(3, 13))))
    print('34: shortest unread avoiding (4,4,4,4),(6,5,5,6),(6,5,6,6): %s'
          % witness(t, fam[:3], list(range(3, 13))))
    fs = list(fam)
    for _ in range(8):
        w = witness(t, fs, list(range(3, 13)))
        print('34: next unread avoiding %d factors: %s' % (len(fs), w))
        if w is None:
            break
        fs.append(tuple(w))
    for W in (32, 34):
        t = tabs[W]
        cls, k = t.minimize()
        reps = {}
        for s in range(t.n):
            reps.setdefault(int(cls[s]), s)
        C = np.concatenate([cls, [cls[t.n]]])
        ct = C[np.where(t.tab < 0, t.n, t.tab)[list(reps.values())]]
        diff = {r: int((ct[:, t.col(r)] != ct[:, t.col(r + 2)]).sum()) for r in range(3, 31)}
        last = max([r for r, d in diff.items() if d] + [0])
        print('%d: %d live classes; runs r and r+2 act alike in every class from r = %d on; differing classes: %s'
              % (W, k - 1, last + 1, ' '.join('%d:%d' % kv for kv in diff.items())))
        rd = lambda w: 'read' if t.run(w) >= 0 else 'NOT read'
        print('%d: L1614 absences: (4,4,4) %s, (5,4,4) %s, (5,5,5,5,5) %s; (r,4,4) read for r = %s'
              % (W, rd([4, 4, 4]), rd([5, 4, 4]), rd([5] * 5),
                 ranges([r for r in range(3, 31) if t.run([r, 4, 4]) >= 0], 30)))


if __name__ == '__main__':
    main()
