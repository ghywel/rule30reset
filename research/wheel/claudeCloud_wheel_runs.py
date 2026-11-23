#!/usr/bin/env python3
"""claudeCloud_wheel_runs.py: the wheel fragments read as runs of 5-gaps, a general observer for the gate trap, and
the gates that avoid the fragments (ledger K75; it continues gptIntel's I152 to I156, research/wheel/README.md).

Frame, as in research/m9/claudeCloud_m9_lift.py. A right half is driven by the alternating column 0. A SAMPLE is a
tick at which column 0 is white; the next tick it is black. The GATE is column 1 at the samples, and a KICK is a
black gate sample. A window is columns 1..W at a sample, coded with bit i = column i + 1. The kit's TRAP is a set of
829 sixteen-column windows closed under the double step for every exterior. Inside it consecutive kicks are 3 or 5
samples apart (a GAP). A RUN is the number of 5-gaps between two consecutive 3-gaps.

gptIntel's three fragments (I155) are words of gate bits: 33 from phase 12, 29 from phase 21 and 29 from phase 26
of the wheel, whose gaps are 5 5 5 5 5 3 for ever.

  selftest       the fragments as gap factors and as a rule on runs, checked on every cyclic gap word to 14 gaps;
                 the SAT encoder against plain simulation; the trap's closure
  observer W     every W-column window, free exterior (an over-approximation of real rows): the longest stretch of
                 samples whose gate is a factor of a word with gaps 3 and 5 only, and which ends outside the trap
  observer-sat   the same for real rows, exactly, by SAT on the light cone: the largest N for which some right half
                 reads N such samples and is outside the trap at the last
  ladder WMAX    the trap's core lifted to W = 16, 18, ..., WMAX columns: which gates avoid all three fragments for
                 ever (a greatest fixed point), the periodic run words among them, and the short run words that the
                 core does not read
  free-sat P N   real rows, by SAT: in the trap at sample 0, and no fragment on the samples P .. P + N - 1
  mean FILE      the mean run from a summary written by research/m9/claudeCloud_m9_real_rows.cpp

    python3 claudeCloud_wheel_runs.py KITFILE MODE ...
KITFILE is the kit's Rule30Certificates/GateTrap.lean. SAT answers: a model is replayed here cell by cell, so SAT is
rigorous; UNSAT is COMPUTED only (python-sat's CaDiCaL 1.9.5, no proof checked on this host), and a spent conflict
budget is UNKNOWN.
"""
import hashlib
import itertools
import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L      # noqa: E402

FRAGMENTS = {12: '010000100001001000010000100001000',
             21: '00100100001000010000100001000',
             26: '10000100001000010000100001001'}
FACTORS = ('5535555', '355555', '555553')          # the same three, as words of gaps (to be checked by selftest)
WHEEL_GATE = '0001000010000100001000010010'


# ---------------------------------------------------------------- words

def gate_of(gaps):
    """Gate bits of a gap word, from just after a kick to its last kick: gap g is g - 1 whites and a kick."""
    return ''.join('0' * (int(g) - 1) + '1' for g in gaps)


def runs_of_cyclic(gaps):
    """Runs of a cyclic gap word that has at least one 3, in order, starting after its first 3."""
    i = gaps.index('3')
    rot = gaps[i + 1:] + gaps[:i + 1]
    out, r = [], 0
    for g in rot:
        if g == '5':
            r += 1
        else:
            out.append(r)
            r = 0
    return out


def run_rule(runs):
    """The rule on a cyclic sequence of runs: every run at most 4, and no 4 straight after a run of 2 or more."""
    n = len(runs)
    return all(r <= 4 for r in runs) and not any(runs[i] == 4 and runs[i - 1] >= 2 for i in range(n))


def avoid_dfa(patterns):
    """DFA over the letters '3', '5' for words avoiding the patterns. States are the proper prefixes of the
    patterns; delta[state][letter] is the next state, or -1 when a pattern has been completed."""
    prefixes = sorted({p[:k] for p in patterns for k in range(len(p))}, key=lambda s: (len(s), s))
    index = {s: i for i, s in enumerate(prefixes)}
    delta = []
    for s in prefixes:
        row = {}
        for g in '35':
            t = s + g
            if any(t.endswith(p) for p in patterns):
                row[g] = -1
            else:
                while t not in index:
                    t = t[1:]
                row[g] = index[t]
        delta.append(row)
    return prefixes, delta


# ---------------------------------------------------------------- the driven half-line, plainly

def simulate(row_bits, samples):
    """row_bits[i] is column i + 1 at sample 0. Returns the gate bits and the 16-column window codes at the samples
    0 .. samples - 1; the row must hold at least 16 + 2 (samples - 1) columns."""
    n = len(row_bits)
    assert n >= 16 + 2 * (samples - 1)
    x = 0
    for i, b in enumerate(row_bits):
        x |= int(b) << i
    gate, codes = [], []
    width = n
    for s in range(samples):
        gate.append(x & 1)
        codes.append(x & 0xFFFF)
        if s == samples - 1:
            break
        for wall in (0, 1):
            r = (x << 1) | wall
            x = (r ^ ((r >> 1) | (r >> 2))) & ((1 << (width - 1)) - 1)
            width -= 1
    return gate, codes


# ---------------------------------------------------------------- SAT on the light cone

class Cone:
    """Variables for columns 1 .. 16 + (T - t) at tick t = 0 .. T, T = 2 (samples - 1), and the rule's clauses."""

    def __init__(self, samples):
        self.S = samples
        self.T = 2 * (samples - 1)
        self.var = {}
        self.clauses = []
        nv = 0
        for t in range(self.T + 1):
            for x in range(1, 16 + (self.T - t) + 1):
                nv += 1
                self.var[(t, x)] = nv
        self.nv = nv
        for t in range(self.T):
            wall = t % 2
            for x in range(1, 16 + (self.T - t - 1) + 1):
                n, c, r = self.var[(t + 1, x)], self.var[(t, x)], self.var[(t, x + 1)]
                if x == 1:
                    # new = wall xor (c or r)
                    if wall == 0:
                        self.clauses += [[-c, n], [-r, n], [c, r, -n]]
                    else:
                        self.clauses += [[-c, -n], [-r, -n], [c, r, n]]
                else:
                    l = self.var[(t, x - 1)]
                    self.clauses += [[-c, -n, -l], [-c, n, l], [-r, -n, -l], [-r, n, l], [c, r, -n, l], [c, r, n, -l]]

    def gate(self, s):
        return self.var[(2 * s, 1)]

    def window(self, s):
        return [self.var[(2 * s, x)] for x in range(1, 17)]

    def forbid_codes(self, s, codes):
        w = self.window(s)
        for code in codes:
            self.clauses.append([(-w[i] if (code >> i) & 1 else w[i]) for i in range(16)])

    def require_codes(self, s, codes):
        """Window at sample s is one of the codes: forbid every shortest prefix that no code has."""
        w = self.window(s)
        codes = sorted(set(int(c) for c in codes))

        def rec(prefix_bits, members):
            k = len(prefix_bits)
            if not members:
                self.clauses.append([(-w[i] if prefix_bits[i] else w[i]) for i in range(k)])
                return
            if k == 16:
                return
            for b in (0, 1):
                rec(prefix_bits + [b], [m for m in members if (m >> k) & 1 == b])

        rec([], codes)

    def forbid_word(self, s, word):
        """The gate does not read the bit word at the samples s, s + 1, ..."""
        self.clauses.append([(-self.gate(s + i) if ch == '1' else self.gate(s + i)) for i, ch in enumerate(word)])

    def gap_language(self, a, b):
        """On the samples a .. b - 1 the gate is a factor of a word whose gaps are 3 and 5 only: no two kicks 1, 2
        or 4 apart, and no five whites in a row."""
        for s in range(a, b):
            for d in (1, 2, 4):
                if s + d < b:
                    self.clauses.append([-self.gate(s), -self.gate(s + d)])
            if s + 4 < b:
                self.clauses.append([self.gate(s + i) for i in range(5)])

    def solve(self, budget):
        from pysat.solvers import Cadical195
        with Cadical195(bootstrap_with=self.clauses) as sol:
            sol.conf_budget(budget)
            r = sol.solve_limited()
            if r:
                model = set(v for v in sol.get_model() if v > 0)
                row = [1 if self.var[(0, x)] in model else 0 for x in range(1, 16 + self.T + 1)]
                return 'SAT', row
            return ('UNSAT' if r is False else 'UNKNOWN'), None

    def digest(self):
        h = hashlib.sha256()
        h.update(('p cnf %d %d\n' % (self.nv, len(self.clauses))).encode())
        for cl in self.clauses:
            h.update((' '.join(map(str, cl)) + ' 0\n').encode())
        return h.hexdigest()


def in_gap_language(gate):
    kicks = [i for i, b in enumerate(gate) if b]
    if any(b - a not in (3, 5) for a, b in zip(kicks, kicks[1:])):
        return False
    return '00000' not in ''.join(map(str, gate))


def observer_sat_one(trap, N, budget):
    cone = Cone(N)
    cone.gap_language(0, N)
    cone.forbid_codes(N - 1, trap)
    status, row = cone.solve(budget)
    out = dict(N=N, status=status, variables=cone.nv, clauses=len(cone.clauses), cnf_sha256=cone.digest())
    if row is not None:
        gate, codes = simulate(row, N)
        trapset = set(trap)
        out['verified'] = bool(in_gap_language(gate) and codes[-1] not in trapset)
        out['gate'] = ''.join(map(str, gate))
        out['row'] = ''.join(map(str, row))
        out['final_window'] = codes[-1]
        out['first_sample_in_trap'] = next((i for i, c in enumerate(codes) if c in trapset), None)
    return out


def free_sat_one(trap, P, N, budget):
    S = P + N
    cone = Cone(S)
    cone.require_codes(0, trap)
    for s in range(P, P + N):
        for f in FRAGMENTS.values():
            if s + len(f) <= P + N:
                cone.forbid_word(s, f)
    status, row = cone.solve(budget)
    out = dict(P=P, N=N, status=status, variables=cone.nv, clauses=len(cone.clauses), cnf_sha256=cone.digest())
    if row is not None:
        gate, codes = simulate(row, S)
        trapset = set(trap)
        g = ''.join(map(str, gate))
        out['verified'] = bool(all(c in trapset for c in codes) and not any(f in g[P:] for f in FRAGMENTS.values()))
        out['gate'] = g
        out['row'] = ''.join(map(str, row))
        kicks = [i for i, b in enumerate(gate) if b]
        out['gaps'] = ''.join(str(b - a) for a, b in zip(kicks, kicks[1:]))
    return out


# ---------------------------------------------------------------- observer on the window graph

def observer_graph(trap, W, cap=5000):
    """Layers of (window, automaton state) reachable by paths that are outside the trap at every sample and whose
    gate stays in the gap language. Automaton: 'pre' p = p whites and no kick yet (p = 0..4); 'post' z = z whites
    since the last kick (z = 0 means a kick now). Returns the number of samples of the longest such path, or None
    if the layers start to repeat (paths of every length)."""
    n = 1 << W
    inside = np.zeros(1 << 16, bool)
    inside[np.array(trap)] = True
    allw = np.arange(n, dtype=np.int64)
    out_mask = ~inside[allw & 0xFFFF]
    # states: 0..4 = pre p (p whites seen, p >= 1 for 1..4; index 0 unused), 5..9 = post z
    PRE, POST = 0, 5
    layer = {}
    black = (allw & 1) == 1
    layer[POST + 0] = out_mask & black
    layer[PRE + 1] = out_mask & ~black
    del allw
    seen = {}
    length = 1
    while True:
        total = sum(int(m.sum()) for m in layer.values())
        if total == 0:
            return length - 1, None
        key = hashlib.blake2b(b''.join(bytes([q]) + np.packbits(m).tobytes() for q, m in sorted(layer.items())),
                              digest_size=16).digest()
        if key in seen or length > cap:
            return None, dict(first=seen.get(key), again=length, states=total)
        seen[key] = length
        nxt = {}
        for q, m in layer.items():
            w = np.nonzero(m)[0].astype(np.int64)
            if len(w) == 0:
                continue
            for x1 in (0, 1):
                for x2 in (0, 1):
                    v = L.step2(w, x1, x2, W)
                    v = v[~inside[v & 0xFFFF]]
                    for bit in (0, 1):
                        u = v[(v & 1) == bit]
                        if len(u) == 0:
                            continue
                        if q < POST:                       # pre p
                            p = q - PRE
                            q2 = POST if bit else (PRE + p + 1 if p + 1 <= 4 else None)
                        else:
                            z = q - POST
                            if bit:
                                q2 = POST if z in (2, 4) else None
                            else:
                                q2 = POST + z + 1 if z + 1 <= 4 else None
                        if q2 is None:
                            continue
                        if q2 not in nxt:
                            nxt[q2] = np.zeros(n, bool)
                        nxt[q2][u] = True
        layer = nxt
        length += 1


# ---------------------------------------------------------------- the ladder

def pre(edges, target):
    """Black windows with an edge into the target set."""
    src, dst = edges
    out = np.zeros(len(target), bool)
    out[src[target[dst]]] = True
    return out


def post(edges, source):
    src, dst = edges
    out = np.zeros(len(source), bool)
    out[dst[source[src]]] = True
    return out


def forever(e3, e5, n, gapword):
    """Black windows from which the gap word can be read again and again for ever (a greatest fixed point)."""
    T = np.ones(n, bool)
    while True:
        A = T
        for g in reversed(gapword):
            A = pre(e3 if g == '3' else e5, A)
        A &= T
        if np.array_equal(A, T):
            return T
        T = A


def marker_free(e3, e5, n, black_core):
    """Pairs (black window, DFA state) with a marker-free gap word of every length ahead of them."""
    prefixes, delta = avoid_dfa(FACTORS)
    S = np.zeros((len(prefixes), n), bool)
    S[:] = black_core[None, :]
    rounds = 0
    while True:
        new = np.zeros_like(S)
        for q in range(len(prefixes)):
            ok = np.zeros(n, bool)
            for g, e in (('3', e3), ('5', e5)):
                q2 = delta[q][g]
                if q2 >= 0:
                    ok |= pre(e, S[q2])
            new[q] = S[q] & ok
        rounds += 1
        if np.array_equal(new, S):
            return prefixes, delta, S, rounds
        S = new


def run_words(e3, e5, start, alphabet, maxruns):
    """Closed run words over the alphabet read from the start set (black windows that close a 3-gap): returns the
    minimal words not read."""
    def read(A, r):
        for _ in range(r):
            A = post(e5, A)
            if not A.any():
                return A
        return post(e3, A)

    level = {(): start}
    forbidden = []
    for k in range(1, maxruns + 1):
        nxt = {}
        for w, A in level.items():
            for r in alphabet:
                B = read(A, r)
                w2 = w + (r,)
                if B.any():
                    nxt[w2] = B
                elif k == 1 or (w2[1:] in level or len(w2) == 1):
                    forbidden.append(w2)
        level = nxt
        if len(level) > 200000:
            break
    # keep the minimal ones: no proper factor is itself listed
    fs = set(forbidden)
    minimal = []
    for w in sorted(fs, key=len):
        if not any(w[i:j] in fs for i in range(len(w)) for j in range(i + 1, len(w) + 1) if (i, j) != (0, len(w))):
            minimal.append(w)
    return minimal, len(level)


PERIODIC = {'3': (3,), '4,1': (4, 1), '3,3,1': (3, 3, 1), '3,1,1': (3, 1, 1), '3,3,1,1': (3, 3, 1, 1),
            '4': (4,), '5 (the wheel)': (5,), '1': (1,), '3,1': (3, 1), '6': (6,), '7': (7,), '9': (9,)}


def gapword_of_runs(runs):
    return ''.join('5' * r + '3' for r in runs)


def ladder(kitfile, wmax, maxruns=7):
    trap = L.trap_codes(kitfile)
    core_codes = None
    for W in range(16, wmax + 1, 2):
        t0 = time.time()
        cand = trap if W == 16 else L.extend(core_codes, W - 2)
        g = L.Graph(cand, W)
        core, _ = g.core()
        core_codes = g.codes[core]
        e3, e5 = g.gap_edges(core)
        black_core = core & g.black
        res = dict(W=W, core=int(core.sum()), core_black=int(black_core.sum()))
        # from here on, nodes are the black core windows only
        idx = np.cumsum(black_core) - 1
        n = int(black_core.sum())
        for e in (e3, e5):
            assert black_core[e[0]].all() and black_core[e[1]].all()
        e3 = (idx[e3[0]], idx[e3[1]])
        e5 = (idx[e5[0]], idx[e5[1]])
        black_core = np.ones(n, bool)
        res['edges_3'], res['edges_5'] = int(len(e3[0])), int(len(e5[0]))
        prefixes, delta, S, rounds = marker_free(e3, e5, n, black_core)
        anyq = S.any(axis=0)
        res['marker_free_forever_windows'] = int(anyq.sum())
        res['marker_free_rounds'] = rounds
        if not anyq.any():
            res['longest_marker_free_gaps'] = rounds - 1
        per = {}
        for name, runs in PERIODIC.items():
            T = forever(e3, e5, n, gapword_of_runs(runs)) & black_core
            per[name] = int(T.sum())
        res['read_for_ever_from_windows'] = per
        closers = post(e3, black_core) & black_core
        minimal, live = run_words(e3, e5, closers, (1, 3, 4), maxruns)
        res['run_words_134_not_read'] = [','.join(map(str, w)) for w in minimal]
        res['run_words_134_read_at_%d_runs' % maxruns] = live
        minimal13, live13 = run_words(e3, e5, closers, (1, 3), maxruns + 3)
        res['run_words_13_not_read'] = [','.join(map(str, w)) for w in minimal13]
        res['run_words_13_read_at_%d_runs' % (maxruns + 3)] = live13
        res['seconds'] = round(time.time() - t0, 1)
        print(json.dumps(res))
        sys.stdout.flush()


# ---------------------------------------------------------------- selftest and readers

def selftest(kitfile):
    ok = True
    # 1. fragments are factors of the wheel's gate at their phases
    for ph, f in FRAGMENTS.items():
        rep = WHEEL_GATE * 4
        good = rep[ph:ph + len(f)] == f
        ok &= good
        print('fragment at phase %d (%d samples) is the wheel from that phase: %s' % (ph, len(f), good))
    # 2. on cyclic gap words: a fragment occurs in the gate iff a gap factor occurs; and iff the run rule fails
    bad1 = bad2 = total = 0
    for n in range(1, 15):
        for w in itertools.product('35', repeat=n):
            w = ''.join(w)
            total += 1
            gate = gate_of(w) * (1 + 80 // len(gate_of(w)) + 2)
            frag = any(f in gate for f in FRAGMENTS.values())
            ww = w * (1 + 14 // n + 2)
            fact = any(p in ww for p in FACTORS)
            if frag != fact:
                bad1 += 1
            if '3' in w:
                rule = run_rule(runs_of_cyclic(w))
                if rule == fact:
                    bad2 += 1
            elif fact:
                bad2 += 1
    ok &= bad1 == 0 and bad2 == 0
    print('cyclic gap words to 14 gaps: %d; fragment occurs iff a gap factor %s occurs: %d exceptions; '
          'no factor iff every run <= 4 and no 4 after a run >= 2 (words with a 3; the all-5 word has no factor): '
          '%d exceptions' % (total, '/'.join(FACTORS), bad1, bad2))
    # 3. the DFA agrees with plain search
    prefixes, delta = avoid_dfa(FACTORS)
    bad = 0
    for n in range(1, 13):
        for w in itertools.product('35', repeat=n):
            w = ''.join(w)
            q = 0
            for ch in w:
                q = delta[q][ch]
                if q < 0:
                    break
            if (q < 0) != any(p in w for p in FACTORS):
                bad += 1
    ok &= bad == 0
    print('avoidance DFA (%d states) against plain search to 12 gaps: %d exceptions' % (len(prefixes), bad))
    # 4. the trap is closed under the simulated double step, and the encoder agrees with simulation
    trap = [int(c) for c in L.trap_codes(kitfile)]
    trapset = set(trap)
    rng = np.random.default_rng(1)
    closed = True
    for code in trap[::7]:
        for _ in range(4):
            row = [(code >> i) & 1 for i in range(16)] + list(rng.integers(0, 2, 8))
            gate, codes = simulate(row, 5)
            closed &= all(c in trapset for c in codes)
    ok &= closed
    print('trap closed under the plain double step on %d sampled windows with random exteriors: %s' % (len(trap[::7]), closed))
    cone = Cone(6)
    row = list(rng.integers(0, 2, 16 + cone.T))
    for x in range(1, 16 + cone.T + 1):
        cone.clauses.append([cone.var[(0, x)] if row[x - 1] else -cone.var[(0, x)]])
    status, back = cone.solve(10 ** 6)
    gate, codes = simulate(row, 6)
    from pysat.solvers import Cadical195
    with Cadical195(bootstrap_with=cone.clauses) as sol:
        sol.solve()
        model = set(v for v in sol.get_model() if v > 0)
    enc_gate = [1 if cone.gate(s) in model else 0 for s in range(6)]
    enc_codes = [sum((1 << i) for i, v in enumerate(cone.window(s)) if v in model) for s in range(6)]
    same = status == 'SAT' and enc_gate == gate and enc_codes == codes
    ok &= same
    print('cone encoder against plain simulation on a random row, 6 samples: %s' % same)
    # 5. known: the wheel fragments force the trap (I155), on the encoder: fragment at phase 26, 29 samples
    f = FRAGMENTS[26]
    cone = Cone(len(f))
    for i, ch in enumerate(f):
        cone.clauses.append([cone.gate(i) if ch == '1' else -cone.gate(i)])
    cone.forbid_codes(len(f) - 1, trap)
    status, _ = cone.solve(10 ** 7)
    good = status == 'UNSAT'
    ok &= good
    print('control: the 29-sample fragment from phase 26 cannot end outside the trap (I155): %s' % status)
    cone = Cone(len(f) - 1)
    for i, ch in enumerate(f[:-1]):
        cone.clauses.append([cone.gate(i) if ch == '1' else -cone.gate(i)])
    cone.forbid_codes(len(f) - 2, trap)
    status, row = cone.solve(10 ** 7)
    print('control: one sample fewer can end outside (I155 has 28 samples outside from phase 26): %s' % status)
    ok &= status == 'SAT'
    print('selftest', 'passed' if ok else 'FAILED')
    return ok


def mean(path):
    kicks = g3 = g5 = None
    bins, hist = [], {}
    for line in open(path):
        p = line.split()
        if not p:
            continue
        if p[0] == 'kicks':
            kicks, g3, g5 = int(p[1]), int(p[3]), int(p[5])
        elif p[0] == 'BIN':
            bins.append((int(p[1]), int(p[3]), int(p[5])))
        elif p[0] == 'HIST' and p[1].lstrip('-').isdigit():
            hist[int(p[1])] = [int(x) for x in p[2:]]
    print('all delays: kicks %d, 3-gaps %d, 5-gaps %d, 5-gaps per 3-gap %.5f' % (kicks, g3, g5, g5 / g3))
    late_runs = late_sum = 0
    var_num = 0.0
    for d, runs, sumlen in bins:
        if runs:
            print('  delay from %7d: runs %10d  mean run %.5f' % (d, runs, sumlen / runs))
        if d >= 100:
            late_runs += runs
            late_sum += sumlen
    m = late_sum / late_runs
    cnt = np.zeros(64)
    for d, h in hist.items():
        if d >= 100:
            cnt += np.array(h[:64], float)
    lens = np.arange(64)
    mh = (cnt * lens).sum() / cnt.sum()
    sd = (((cnt * (lens - mh) ** 2).sum()) / cnt.sum()) ** 0.5
    print('delay 100 on: runs %d, mean run %.5f, standard deviation of a run %.3f, standard error if independent %.5f'
          % (late_runs, m, sd, sd / late_runs ** 0.5))
    print('  runs of 63 or more are counted as 63 in the deviation; the mean uses the exact sum of lengths')
    print('  kicks per 28 samples at this mean: %.5f (the wheel has 6)' % (28 * (m + 1) / (5 * m + 3)))


def main():
    kit, mode = sys.argv[1], sys.argv[2]
    if mode == 'selftest':
        sys.exit(0 if selftest(kit) else 1)
    trap = [int(c) for c in L.trap_codes(kit)]
    if mode == 'observer':
        for W in map(int, sys.argv[3:]):
            t0 = time.time()
            longest, cyc = observer_graph(trap, W)
            print(json.dumps(dict(W=W, longest_samples_outside=longest, layers_repeat=cyc,
                                  seconds=round(time.time() - t0, 1))))
            sys.stdout.flush()
    elif mode == 'observer-sat':
        budget = int(sys.argv[3])
        for N in map(int, sys.argv[4:]):
            t0 = time.time()
            r = observer_sat_one(trap, N, budget)
            r['seconds'] = round(time.time() - t0, 1)
            print(json.dumps(r))
            sys.stdout.flush()
    elif mode == 'free-sat':
        budget, P = int(sys.argv[3]), int(sys.argv[4])
        for N in map(int, sys.argv[5:]):
            t0 = time.time()
            r = free_sat_one(trap, P, N, budget)
            r['seconds'] = round(time.time() - t0, 1)
            print(json.dumps(r))
            sys.stdout.flush()
    elif mode == 'ladder':
        ladder(kit, int(sys.argv[3]))
    elif mode == 'mean':
        mean(sys.argv[3])
    else:
        raise SystemExit('unknown mode')


if __name__ == '__main__':
    main()
