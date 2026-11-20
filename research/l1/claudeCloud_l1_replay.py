#!/usr/bin/env python3
"""claudeCloud_l1_replay.py: pull L1 (placego L1679), first block (ledger K45). Replay the kit's surviving-seed law
against placego L1675's mass table.

Kit frame (Rule30ZeroCoastBridge, read at the source). A seed y is a left row as an integer, bit i = depth i + 1;
F y = (y >> 1) ^ (y | (y << 1)); the trace of y is bit 0 of y, F y, F F y, ... . SurvivesTo y H: the first H trace
bits are accepted: white at tick 0, black at every odd tick, and at even ticks the gap clock (gateNext: ages 0..4,
a white cell allowed at age 2 and forced at age 4).

  N(H)   the kit's law: N(H + 10) = N(H + 4) + N(H) for H >= 1, with N(1..10) = 1, 1, 1, 1, 1, 1, 2, 2, 2, 2
         (survivingSeeds_length_add_ten_and_initial_counts)
  A(H)   accepted traces of length H, counted through the acceptor, with no recurrence
  S(H)   seeds y < 2^H with SurvivesTo y H, by literal simulation of F and the acceptor (small H)
  B(H)   placego L1675's table: count, mean popcount and least popcount mu(H) of the accepted H-bit prefixes

The seed of each accepted trace is rebuilt here by the anti-diagonal recursion (depth d + 1 at tick t = depth d at
tick t + 1 xor (depth d or depth d - 1 at tick t)), and its popcount taken, to redo L1675's mean and mu.

  python3 claudeCloud_l1_replay.py run [HMAX_SEEDS]     everything; seeds rebuilt at the tabulated H up to HMAX_SEEDS
  python3 claudeCloud_l1_replay.py check                controls
"""
import json
import sys

# placego L1675, tests/probes/sepgap/local_q01gap_mass_table.out: H : B(H), mean popcount, mu(H)
L1675 = {22: (5, 10.000, 9), 42: (33, 20.727, 18), 62: (195, 30.908, 23), 82: (1129, 40.900, 30),
         102: (6654, 50.948, 38), 122: (39221, 60.950, 43), 142: (230552, 70.938, 49), 162: (1355842, 80.935, 55)}
KIT_INITIAL = [1, 1, 1, 1, 1, 1, 2, 2, 2, 2]                      # N(1) .. N(10)
KIT_SIX = {6: 1, 12: 2, 18: 4, 24: 7, 30: 12, 36: 20, 42: 33, 48: 55}


def F(y):
    return (y >> 1) ^ (y | (y << 1))


def gate_next(a, g):
    """The kit's gateNext: g is True when the even-tick cell is white."""
    return {(0, False): 1, (1, False): 2, (2, False): 3, (2, True): 0, (3, False): 4, (4, True): 0}.get((a, g))


def accept(bits):
    """The kit's accept on a list of trace bits (True = black)."""
    if not bits:
        return True
    if bits[0]:
        return False
    odd, a = True, 0
    for b in bits[1:]:
        if odd:
            if not b:
                return False
        else:
            a = gate_next(a, not b)
            if a is None:
                return False
        odd = not odd
    return True


def survives(y, H):
    bits = []
    for _ in range(H):
        bits.append(bool(y & 1))
        y = F(y)
    return accept(bits)


def kit_N(hmax):
    N = [None] + KIT_INITIAL[:]
    for H in range(1, hmax - 9):
        N.append(N[H + 4] + N[H])
    return N


def count_words(hmax):
    """A(H) for H = 0..hmax: accepted traces, by the acceptor's states (parity of the next tick, age)."""
    A = [1]
    state = {(True, 0): 1}            # after tick 0 (white): next tick is odd, age 0
    A.append(1)
    for H in range(2, hmax + 1):
        nxt = {}
        for (odd, a), c in state.items():
            if odd:                   # the cell must be black
                nxt[(False, a)] = nxt.get((False, a), 0) + c
            else:
                for white in (False, True):
                    a2 = gate_next(a, white)
                    if a2 is not None:
                        nxt[(True, a2)] = nxt.get((True, a2), 0) + c
        state = nxt
        A.append(sum(state.values()))
    return A


def seed_of_trace(col, H):
    """The seed below 2^H whose trace is col (bit t = the trace at tick t): the anti-diagonal recursion."""
    prev, cur = 0, col
    y = cur & 1
    for d in range(1, H):
        nxt = (cur >> 1) ^ (cur | prev)
        prev, cur = cur, nxt
        y |= (cur & 1) << d
    return y


def traces(H):
    """Every accepted trace of length H, as ints."""
    out = []

    def rec(t, col, a):
        if t == H:
            out.append(col)
            return
        if t % 2 == 1:
            rec(t + 1, col | (1 << t), a)
        else:
            for white in (False, True):
                a2 = gate_next(a, white)
                if a2 is not None:
                    rec(t + 1, col if white else col | (1 << t), a2)
    if H >= 1:
        rec(1, 0, 0)
    return out


def run(hmax_seeds=162):
    res = {}
    N = kit_N(320)
    A = count_words(320)
    rec_ok = all(A[H + 10] == A[H + 4] + A[H] for H in range(1, 311))
    same = all(N[H] == A[H] for H in range(1, 321))
    print('the kit law from its ten initial values equals the acceptor count at every H from 1 to 320: %s' % same)
    print('the acceptor count obeys A(H + 10) = A(H + 4) + A(H) for every H from 1 to 310: %s' % rec_ok)
    print('the kit values at H = 6, 12, ..., 48: %s' % all(N[H] == v for H, v in KIT_SIX.items()))
    lit = {}
    for H in range(1, 23):
        lit[H] = sum(1 for y in range(1 << H) if survives(y, H))
    lit_ok = all(lit[H] == N[H] for H in lit)
    print('literal seeds below 2^H that survive to H, H = 1..22: %s' % [lit[H] for H in sorted(lit)])
    print('   equal to the kit law at every H: %s' % lit_ok)
    res.update({'law_equals_count': same, 'recurrence': rec_ok, 'literal': lit, 'literal_ok': lit_ok})
    print('  H :   kit N(H)   L1675 B(H)  same |  mean popcount (mine / L1675) |  mu (mine / L1675)')
    table = {}
    for H, (B, mean, mu) in sorted(L1675.items()):
        row = {'N': N[H], 'B': B, 'count_same': N[H] == B}
        line = '%4d : %10d %12d  %-5s' % (H, N[H], B, N[H] == B)
        if H <= hmax_seeds:
            pops = [bin(seed_of_trace(c, H)).count('1') for c in traces(H)]
            my_mean, my_mu = sum(pops) / len(pops), min(pops)
            row.update({'seeds': len(pops), 'mean': my_mean, 'mu': my_mu,
                        'mean_same': abs(my_mean - mean) < 0.0006, 'mu_same': my_mu == mu,
                        'minimisers': sum(1 for p in pops if p == my_mu)})
            line += '|  %8.3f / %8.3f  %-5s    |  %3d / %3d  %-5s (%d seeds at mu)' % (
                my_mean, mean, row['mean_same'], my_mu, mu, row['mu_same'], row['minimisers'])
        table[H] = row
        print(line)
        sys.stdout.flush()
    res['table'] = table
    print('JSON ' + json.dumps(res))
    return res


def check():
    ok = True
    # 1. seed_of_trace inverts the trace: every seed below 2^12 is the seed of its own 12-tick trace
    good = True
    for y in range(1 << 12):
        col, z = 0, y
        for t in range(12):
            col |= (z & 1) << t
            z = F(z)
        good &= seed_of_trace(col, 12) == y
    print('1. the seed of the trace of y is y, for every y below 2^12: %s' % good)
    ok &= good
    # 2. the enumerated traces are exactly the accepted ones, and their seeds survive (H = 14, by brute force)
    H = 14
    tr = traces(H)
    seeds = sorted(seed_of_trace(c, H) for c in tr)
    brute = [y for y in range(1 << H) if survives(y, H)]
    print('2. enumerated seeds at H = 14 equal the brute-force survivors (%d): %s' % (len(brute), seeds == brute))
    ok &= seeds == brute
    # 3. the kit's rung (R30-20261115-fdf6a3): the eight c37Roots have popcount 38 and survive to 102
    roots = [42813888358306443700074217814, 148978366434744761789452353878, 2654468869608816557330812141910,
             20290708049760378067263390038, 871680261646910262683015020886, 3258683745119620012336052404566,
             793529923180978236193646670102, 343533199256979670105602359638]
    good = all(bin(y).count('1') == 38 and survives(y, 102) for y in roots)
    print('3. the kit rung: eight seeds of popcount 38 survive to 102: %s' % good)
    ok &= good
    print('CONTROLS:', 'PASS' if ok else 'FAIL')
    return ok


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[0] == 'check':
        sys.exit(0 if check() else 1)
    run(int(a[1]) if len(a) > 1 else 162)
