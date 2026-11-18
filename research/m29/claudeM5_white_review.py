#!/usr/bin/env python3
"""Pull M29 (M41): an independent carrying read of R37, R43 and R44 (white anchors, five- and three-phase resets).

Written from the definitions, without gptM5's sources. Band map in kit coordinates (wheel 0 the edge):
D_j(t+1) = D_(j-2)(t) xor (D_(j-1)(t) or D_j(t)). A reset in row t is a closed black run 0 1^n 0 with n = 1 mod 3.

  A. Three phases (R44). A path reads columns of three consecutive ticks from a permanent white A. Its state is the
     last two columns and the run residue mod 3 of each tick. It is rejected on a recurrence violation or a closed run
     with residue 1. Two starts:
     (gpt) gptM5's: x free at A+1, all black at A+2, no recurrence check there;
     (phys) the physical one: a free column y at A-1, white at A, the recurrence checked at A+1 and A+2, and A+2 all black.
     Claim: from every state reachable over arbitrary columns, a white column and then three more kill every path.
  B. Two phases (R44): the same with two ticks; a survivor of the white column and three more has child (0, 1).
  C. The box (R43): wheels A..A+7 over five ticks, all 2^10 free inputs. One of the five rows has a closed run of
     exactly one or four cells with both endpoints in the box; four rows do not suffice.
  D. The period-five ring (R42): the five rows return; wheel 0 is white and wheel 2 black; rows 4 and 0 are reset-free;
     A and B hold on the ring tiled in space.
  E. The four kit strips at width 87,867: every pair of consecutive permanent whites (A, B) with B + 3 < 87,867 and
     every tick s give a reset within [A, B+3] in one of s, s+1, s+2; when two ticks miss, the child at B+1 rises; the
     box holds at every white; B0 phase 9 is black beyond every white and has 12,532 reset factors (R37).
  F. True dynamics: excursions from a white A with every source column of period P <= 4 (and P = 8 with a cutoff), both
     lifts at A and at B, run to the next white B. A, B and C must hold on every one.
Predictions (written before the run): every check passes (95%). The (gpt) reachable set has 20 states (90%); the
physical start reaches no more states than gptM5's (95%). Kill: any rejected claim in A, B or C.
Usage: claudeM5_white_review.py LEANFILE OUTFILE
"""
import argparse, itertools, json, os, sys
from collections import deque

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from claudeM5_window_map import load_strips, phases, word, resets, K    # noqa: E402


# ---------- A, B: the n-tick automaton ----------
def ok_rec(a, b, c, n):
    return all(c[t + 1] == a[t] ^ (b[t] | c[t]) for t in range(n - 1))


def advance(state, c, n):
    """state = (a, b, res): columns at j-2, j-1 and residues; c = column at j. None if rejected."""
    a, b, res = state
    if not ok_rec(a, b, c, n):
        return None
    new = []
    for t in range(n):
        if c[t]:
            new.append((res[t] + 1) % 3)
        elif res[t] == 1:
            return None
        else:
            new.append(0)
    return (b, c, tuple(new))


def automaton(n):
    cols = list(itertools.product((0, 1), repeat=n))
    zero, black = (0,) * n, (1,) * n
    gpt = set()
    for x in cols:                                  # gptM5's start: residues after x at A+1 and black at A+2
        r1 = tuple(1 if x[t] else 0 for t in range(n))
        r2 = tuple((r1[t] + 1) % 3 for t in range(n))
        gpt.add((x, black, r2))
    phys = set()
    for y in cols:                                  # physical: y at A-1, white at A, checked steps at A+1, A+2
        s0 = (y, zero, (0,) * n)
        for x in cols:
            s1 = advance(s0, x, n)
            if s1 is None:
                continue
            s2 = advance(s1, black, n)
            if s2 is not None:
                phys.add(s2)

    def closure(starts):
        seen, q, edges = set(starts), deque(starts), 0
        while q:
            s = q.popleft()
            for c in cols:
                u = advance(s, c, n)
                if u is not None:
                    edges += 1
                    if u not in seen:
                        seen.add(u)
                        q.append(u)
        return seen, edges

    out = {}
    for name, st in (('gpt', gpt), ('phys', phys)):
        reach, edges = closure(st)
        after = {s2 for s in reach for s2 in [advance(s, zero, n)] if s2 is not None}
        sizes, cur, children = [len(after)], after, {}
        for k in range(3):
            nxt = set()
            for s in cur:
                for c in cols:
                    u = advance(s, c, n)
                    if u is not None:
                        nxt.add(u)
                        if k == 0:
                            children[c] = children.get(c, 0) + 1
            sizes.append(len(nxt))
            cur = nxt
        out[name] = {'reachable': len(reach), 'allowed_transitions': edges,
                     'survivors_white_then_1_2_3': sizes, 'trap': sizes[-1] == 0,
                     'children_surviving_one_wheel': sorted(''.join(map(str, c)) for c in children)}
        if n == 2:                                  # survivors of three wheels after the white, by child
            surv = set()
            for s in after:
                for c in cols:
                    u = advance(s, c, n)
                    if u is None:
                        continue
                    for c2 in cols:
                        u2 = advance(u, c2, n)
                        if u2 is None:
                            continue
                        for c3 in cols:
                            if advance(u2, c3, n) is not None:
                                surv.add(''.join(map(str, c)))
            out[name]['children_surviving_three_wheels'] = sorted(surv)
        out[name]['phys_subset_of_gpt_reach'] = None
    rg, _ = closure(gpt)
    rp, _ = closure(phys)
    out['phys']['phys_subset_of_gpt_reach'] = rp <= rg
    return out


# ---------- C: the eight-wheel box ----------
def hit(r, i, nn):
    return r[i] == 0 and all(r[i + 1 + k] for k in range(nn)) and r[i + 1 + nn] == 0


def in_box(r):
    return any(hit(r, i, 1) for i in range(6)) or any(hit(r, i, 4) for i in range(3))


def box_rows(drive, init):
    rows = [[0, drive[0], 1] + list(init)]
    for t in range(1, 5):
        p = rows[-1]
        r = [0, drive[t], 1]
        for k in range(3, 8):
            r.append(p[k - 2] ^ (p[k - 1] | p[k]))
        rows.append(r)
    return rows


def box_check():
    miss4 = 0
    for bits in itertools.product((0, 1), repeat=10):
        rows = box_rows(bits[:5], bits[5:])
        assert all(rows[t + 1][2] == rows[t][0] ^ (rows[t][1] | rows[t][2]) for t in range(4))
        if not any(in_box(r) for r in rows):
            return {'all_1024_covered': False}
        if not any(in_box(r) for r in rows[:4]):
            miss4 += 1
    return {'all_1024_covered': True, 'inputs_missing_in_first_four_rows': miss4}


# ---------- helpers on explicit rows ----------
def reset_runs(row, lo_lim, hi_lim):
    """closed runs with n = 1 mod 3, both white endpoints in [lo_lim, hi_lim]; row indexed by wheel."""
    out, j, n = [], lo_lim + 1, len(row)
    while j <= hi_lim - 1 and j < n:
        if row[j] and row[j - 1] == 0:
            k = j
            while k < n and row[k]:
                k += 1
            if k <= hi_lim and k < n and (k - j) % 3 == 1:
                out.append((j, k))
            j = k
        else:
            j += 1
    return out


def check_interval(rows_at, A, B, T):
    """rows_at(t) -> list indexed by wheel; checks R44's three- and two-phase claims on [A, B+3]."""
    bad3, rise_fail, two_miss = 0, 0, 0
    has = [bool(reset_runs(rows_at(t), A, B + 3)) for t in range(T)]
    for s in range(T):
        if not (has[s] or has[(s + 1) % T] or has[(s + 2) % T]):
            bad3 += 1
        if not has[s] and not has[(s + 1) % T]:
            two_miss += 1
            if not (rows_at(s)[B + 1] == 0 and rows_at((s + 1) % T)[B + 1] == 1):
                rise_fail += 1
    return bad3, rise_fail, two_miss


def box_at(rows_at, A, T):
    fails = 0
    for s in range(T):
        if not any(in_box(rows_at((s + d) % T)[A:A + 8]) for d in range(5)):
            fails += 1
    return fails


# ---------- D: the ring ----------
def ring_check():
    rows = ['01110000', '01100100', '01101111', '00100100', '00111111']
    n = 8

    def stp(r):
        b = [int(c) for c in r]
        return ''.join(str(b[(j - 2) % n] ^ (b[(j - 1) % n] | b[j])) for j in range(n))
    ret = all(stp(rows[i]) == rows[(i + 1) % 5] for i in range(5))
    anchors = all(r[0] == '0' and r[2] == '1' for r in rows)
    tiled = [[int(c) for c in r * 6] for r in rows]
    free = [not reset_runs(tiled[t], 0, 6 * n - 1) for t in range(5)]
    bad3, rise_fail, two_miss = check_interval(lambda t: tiled[t], 8, 16, 5)
    return {'returns_after_5': ret, 'white0_black2': anchors, 'reset_free_rows': [t for t in range(5) if free[t]],
            'three_phase_failures': bad3, 'two_phase_misses': two_miss, 'rise_failures': rise_fail,
            'box_failures': box_at(lambda t: tiled[t], 8, 5)}


# ---------- E: the kit strips ----------
def strips_check(leanfile):
    strips = load_strips(leanfile)
    out = {}
    for name, v in strips.items():
        ph = [word(r) for r in phases(v)[:16]]
        rows = [[int(ch) for ch in w] for w in ph]
        assert word(phases(v)[16]) == ph[0]
        whites = [j for j in range(K) if all(rows[t][j] == 0 for t in range(16))]
        blacks2 = all(all(rows[t][j + 2] == 1 for t in range(16)) for j in whites if j + 2 < K)
        pairs, bad3, rise_fail, two_miss, box_fail = 0, 0, 0, 0, 0
        for A, B in zip(whites, whites[1:]):
            if A < 2 or B + 3 >= K:
                continue
            pairs += 1
            b3, rf, tm = check_interval(lambda t: rows[t], A, B, 16)
            bad3 += b3
            rise_fail += rf
            two_miss += tm
        for A in whites:
            if A >= 2 and A + 8 <= K:
                box_fail += box_at(lambda t: rows[t], A, 16)
        rec = {'whites': whites, 'black_two_beyond': blacks2, 'interval_pairs': pairs,
               'three_phase_failures': bad3, 'two_phase_misses': two_miss, 'rise_failures': rise_fail,
               'box_failures': box_fail}
        if name == 'B0':
            p9 = rows[9]
            rec['B0_phase9_black_beyond_every_white'] = all(p9[j + 1] == 1 for j in whites if j + 1 < K)
            rec['B0_phase9_reset_factors'] = len(resets(ph[9]))
            rec['phases_black_beyond_every_white'] = [t for t in range(16)
                                                      if all(rows[t][j + 1] == 1 for j in whites if j + 1 < K)]
        out[name] = rec
    return out


# ---------- F: true dynamics ----------
def lift(a, b, T, c0=None):
    """T-periodic c with c(t+1) = a(t) xor (b(t) or c(t)); a, b lists. Returns the unique lift, or the one with c(0) = c0."""
    if any(b):
        t0 = b.index(1)
        c = [None] * T
        c[(t0 + 1) % T] = 1 - a[t0]
        t = (t0 + 1) % T
        for _ in range(T - 1):
            c[(t + 1) % T] = a[t] ^ (b[t] | c[t])
            t = (t + 1) % T
        assert c[(t0 + 1) % T] == a[t0] ^ (b[t0] | c[t0])
        return c
    c = [c0]
    for t in range(T - 1):
        c.append(a[t] ^ c[t])
    if (a[T - 1] ^ c[T - 1]) != c0:
        return None
    return c


def excursions(Pmax_full, cutoff_full, P8_cutoff):
    stats = {'excursions_to_white': 0, 'no_white_within_cutoff': 0, 'three_phase_failures': 0,
             'two_phase_misses': 0, 'rise_failures': 0, 'box_failures': 0}
    for P, cutoff in [(p, cutoff_full) for p in (1, 2, 4) if p <= Pmax_full] + [(8, P8_cutoff)]:
        T = 8 * P                                   # room for two doublings
        for src in itertools.product((0, 1), repeat=P):
            if not any(src):
                continue
            b = [src[t % P] for t in range(T)]
            for cA in (0, 1):
                cols = [b, b, [0] * T]               # wheels A-2, A-1, A (A = 2)
                cA1 = lift(b, [0] * T, T, cA)
                cols.append(cA1)
                B = None
                while len(cols) < cutoff:
                    c = lift(cols[-2], cols[-1], T)
                    cols.append(c)
                    if not any(c):
                        B = len(cols) - 1
                        break
                if B is None:
                    stats['no_white_within_cutoff'] += 1
                    continue
                for cB in (0, 1):
                    ext = list(cols)
                    c1 = lift(ext[B - 1], ext[B], T, cB)
                    if c1 is None:
                        continue
                    ext.append(c1)
                    ext.append(lift(ext[-2], ext[-1], T))
                    ext.append(lift(ext[-2], ext[-1], T))
                    for j in range(2, len(ext)):     # the recurrence holds on the whole patch
                        assert all(ext[j][(t + 1) % T] == ext[j - 2][t] ^ (ext[j - 1][t] | ext[j][t]) for t in range(T))
                    rows = [[ext[j][t] for j in range(len(ext))] for t in range(T)]
                    stats['excursions_to_white'] += 1
                    b3, rf, tm = check_interval(lambda t: rows[t], 2, B, T)
                    stats['three_phase_failures'] += b3
                    stats['rise_failures'] += rf
                    stats['two_phase_misses'] += tm
                    stats['box_failures'] += box_at(lambda t: rows[t], 2, T)
    return stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('leanfile')
    ap.add_argument('outfile')
    a = ap.parse_args()
    res = {'A_three_phase': automaton(3), 'B_two_phase': automaton(2), 'C_box': box_check(), 'D_ring': ring_check()}
    print(json.dumps(res), flush=True)
    res['E_strips'] = strips_check(a.leanfile)
    print(json.dumps({n: {k: v for k, v in r.items() if k != 'whites'} for n, r in res['E_strips'].items()}), flush=True)
    res['F_excursions'] = excursions(4, 100000, 5000)
    print(json.dumps(res['F_excursions']), flush=True)
    A3, B2 = res['A_three_phase'], res['B_two_phase']
    E, F, D = res['E_strips'], res['F_excursions'], res['D_ring']
    res['verdicts'] = {
        'A_trap_both_starts': A3['gpt']['trap'] and A3['phys']['trap'],
        'A_gpt_20_states': A3['gpt']['reachable'] == 20,
        'A_phys_subset': A3['phys']['phys_subset_of_gpt_reach'],
        'B_only_rise_survives': B2['gpt'].get('children_surviving_three_wheels') in ([], ['01']) and
                                B2['phys'].get('children_surviving_three_wheels') in ([], ['01']),
        'C_box': res['C_box']['all_1024_covered'] and res['C_box']['inputs_missing_in_first_four_rows'] > 0,
        'D_ring': D['returns_after_5'] and D['white0_black2'] and D['reset_free_rows'] == [0, 4] and
                  D['three_phase_failures'] == 0 and D['rise_failures'] == 0,
        'E_strips': all(r['three_phase_failures'] == 0 and r['rise_failures'] == 0 and r['box_failures'] == 0 and
                        r['black_two_beyond'] for r in E.values()) and
                    E['B0']['B0_phase9_black_beyond_every_white'] and E['B0']['B0_phase9_reset_factors'] == 12532,
        'F_excursions': F['three_phase_failures'] == 0 and F['rise_failures'] == 0 and F['box_failures'] == 0 and
                        F['excursions_to_white'] > 0}
    with open(a.outfile, 'w') as fh:
        json.dump(res, fh, indent=1)
    print(json.dumps(res['verdicts']))


if __name__ == '__main__':
    main()
