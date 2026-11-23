#!/usr/bin/env python3
"""claudeCloud_wheel_budget.py: how many excursions can ANY right half make outside the gate trap?
(ledger K79, addendum 2)

Outside the kit's gate trap the gate of a right half beside the alternating column can vary only in two window
components (R65, R69, K78):

    X   the loop A = 25 and the excursion E = 33535555
    Y   the loop 2 and the excursions S = 45 and L = 4525

RD's open case is one right half that makes infinitely many excursions. The window graph at 43 columns allows any
number, with free cells beyond the window. This script asks the whole light cone instead, so the answer holds for
every right half of every support: SAT on the cone of N samples, with a small automaton reading the gate, for

    x N K      from a kick: a word of (A | E)* holding at least K complete excursions E, any numbers of loops
               between them, the window at the last sample outside the trap
    y N K      from a kick: a word of (2 | 45 | 4525)* holding at least K gaps of 4 (one in each excursion), the
               window at the last sample outside the trap
    xfix N K n1 n2 ...   as x, with the numbers of loops between successive excursions fixed (a check of the
               automaton against K75's plain cone)

A model is replayed cell by cell and its gate parsed again by a separate reader. UNSAT is COMPUTED only (python-sat,
CaDiCaL 1.9.5): then no right half reads K excursions within N samples.

    python3 claudeCloud_wheel_budget.py KITFILE MODE N K [...] [--budget B]
"""
import json
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_runs as R       # noqa: E402

# gap-level automata: state -> {gap: (next state, counted)}
X_DFA = {
    'u': {2: ('a1', 0), 3: ('e1', 0)},
    'a1': {5: ('u', 0)},
    'e1': {3: ('e2', 0)}, 'e2': {5: ('e3', 0)}, 'e3': {3: ('e4', 0)}, 'e4': {5: ('e5', 0)},
    'e5': {5: ('e6', 0)}, 'e6': {5: ('e7', 0)}, 'e7': {5: ('u', 1)},
}
Y_DFA = {
    'u': {2: ('u', 0), 4: ('y4', 1)},
    'y4': {5: ('yS', 0)},
    'yS': {2: ('yS2', 0), 4: ('y4', 1)},
    'yS2': {5: ('u', 0), 2: ('u', 0), 4: ('y4', 1)},
}


def add_automaton(cone, dfa, start, K):
    """One-hot variables for (gap state, whites since the last kick, count) at every sample; the gate drives them."""
    states = []
    for u in dfa:
        longest = max(dfa[u])
        for z in range(longest):                      # z whites read since the last kick; a gap g needs z = g - 1
            for c in range(K + 1):
                states.append((u, z, c))
    index = {s: i for i, s in enumerate(states)}
    q = []
    for s in range(cone.S):
        row = []
        for _ in states:
            cone.nv += 1
            row.append(cone.nv)
        q.append(row)
        cone.clauses.append(list(row))                                    # at least one
    cone.clauses.append([q[0][index[(start, 0, 0)]]])
    cone.clauses.append([cone.gate(0)])
    for s in range(cone.S - 1):
        g = cone.gate(s + 1)
        for (u, z, c), i in index.items():
            here = q[s][i]
            # next bit white: one more white, if some gap from u is longer than z + 1
            if (u, z + 1, c) in index:
                cone.clauses.append([-here, g, q[s + 1][index[(u, z + 1, c)]]])
            else:
                cone.clauses.append([-here, g])                          # must be a kick now
            # next bit black: the gap z + 1 must be allowed from u
            if (z + 1) in dfa[u]:
                v, counted = dfa[u][z + 1]
                cone.clauses.append([-here, -g, q[s + 1][index[(v, 0, min(K, c + counted))]]])
            else:
                cone.clauses.append([-here, -g])
    # at the end the count has reached K
    cone.clauses.append([q[cone.S - 1][i] for (u, z, c), i in index.items() if c == K])
    return q, index


def gaps_of(gate):
    ks = [i for i, b in enumerate(gate) if b]
    return [b - a for a, b in zip(ks, ks[1:])]


def count_x(gaps):
    """Parse a gap list as (25 | 33535555)*, a last block possibly cut short; return the number of whole E."""
    s = ''.join(map(str, gaps))
    i, n = 0, 0
    while i < len(s):
        if s.startswith('25', i):
            i += 2
        elif s.startswith('33535555', i):
            i += 8
            n += 1
        elif '25'.startswith(s[i:]) or '33535555'.startswith(s[i:]):
            break
        else:
            return None
    return n


def count_y(gaps):
    s = ''.join(map(str, gaps))
    if re.fullmatch(r'(2|45|4525)*(4|452)?', s) is None:
        return None
    return s.count('4')


def solve(trap, mode, N, K, budget, spacings=None):
    cone = R.Cone(N)
    add_automaton(cone, X_DFA if mode in ('x', 'xfix') else Y_DFA, 'u', K)
    if mode == 'xfix':
        word = '33535555' + ''.join('25' * n + '33535555' for n in spacings)
        bits = '1' + ''.join('0' * (int(g) - 1) + '1' for g in word)
        assert len(bits) <= N, 'N too small for the fixed word'
        for i, ch in enumerate(bits):
            cone.clauses.append([cone.gate(i) if ch == '1' else -cone.gate(i)])
    cone.forbid_codes(N - 1, trap)
    status, row = cone.solve(budget)
    out = dict(mode=mode, samples=N, excursions=K, status=status, variables=cone.nv, clauses=len(cone.clauses),
               cnf_sha256=cone.digest())
    if spacings is not None:
        out['spacings'] = spacings
    if row is not None:
        gate, codes = R.simulate(row, N)
        gaps = gaps_of(gate)
        n = count_x(gaps) if mode in ('x', 'xfix') else count_y(gaps)
        out['verified'] = bool(gate[0] == 1 and n is not None and n >= K and codes[-1] not in set(trap))
        s = ''.join(map(str, gaps))
        out['gaps'] = s
        if mode in ('x', 'xfix'):
            out['read'] = re.sub(r'(25)+', lambda m: ' A%d ' % (len(m.group(0)) // 2), s.replace('33535555', ' E ')).split()
        else:
            out['read'] = re.sub(r'2{3,}', lambda m: ' 2x%d ' % len(m.group(0)), s).split()
        out['row'] = ''.join(map(str, row))
        out['final_window'] = codes[-1]
    return out


def main():
    args = sys.argv[1:]
    budget = 20_000_000
    if '--budget' in args:
        i = args.index('--budget')
        budget = int(args[i + 1])
        del args[i:i + 2]
    kit, mode, N, K = args[0], args[1], int(args[2]), int(args[3])
    trap = [int(c) for c in L.trap_codes(kit)]
    spacings = [int(a) for a in args[4:]] if mode == 'xfix' else None
    t0 = time.time()
    out = solve(trap, mode, N, K, budget, spacings)
    out['seconds'] = round(time.time() - t0, 1)
    print(json.dumps(out))


if __name__ == '__main__':
    main()
