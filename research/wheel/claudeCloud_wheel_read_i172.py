#!/usr/bin/env python3
"""claudeCloud_wheel_read_i172.py: an independent replay of gptIntel's observer and exit rules (I171 to I181),
with K75's cone encoder and plain simulation. No file of gptIntel's is read.

  observer   48 clean samples force the trap: on the whole cone, a gate with none of 00000, 11, 101, 10001, 1001001
             on N samples and the last window outside the trap. N = 48 should be UNSAT; N = 47 SAT, and UNSAT once
             the one exceptional word of I181 is excluded.
  rows       the three finite rows of I172, I174 and I181 (black first, site 1 = bit 0), replayed: the 47 clean
             samples ending outside; the same 47 samples read ten samples after entry; the row whose detector
             fires latest.
  exits      I175's two exit rules and K77's two mixed powers, on the whole cone with no condition on the trap:
             3333333 53 is read by no right half; 33333333 55 ends in the trap; (33355)^7 and (333355)^9 are read
             by none, (33355)^6 and (333355)^8 by some.

    python3 claudeCloud_wheel_read_i172.py KITFILE observer|rows|exits [BUDGET]
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, '..', 'm9'))
import claudeCloud_m9_lift as L          # noqa: E402
import claudeCloud_wheel_runs as R       # noqa: E402

DEFECTS = ('00000', '11', '101', '10001', '1001001')
EXCEPTION = '00001001000010010000100001000010000100100001000'


def clean(bits):
    return not any(w in bits for w in DEFECTS)


def observer(trap, budget):
    for N, exclude in ((47, False), (47, True), (48, False)):
        t0 = time.time()
        cone = R.Cone(N)
        for s in range(N):
            for w in DEFECTS:
                if s + len(w) <= N:
                    cone.forbid_word(s, w)
        if exclude:
            cone.forbid_word(0, EXCEPTION)
        cone.forbid_codes(N - 1, trap)
        status, row = cone.solve(budget)
        out = dict(samples=N, exception_excluded=exclude, status=status, variables=cone.nv,
                   clauses=len(cone.clauses), cnf_sha256=cone.digest(), seconds=round(time.time() - t0, 1))
        if row is not None:
            gate, codes = R.simulate(row, N)
            bits = ''.join(map(str, gate))
            out.update(gate=bits, clean=clean(bits), is_the_exception=bits == EXCEPTION,
                       final_window=codes[-1], outside=codes[-1] not in set(trap))
        print(json.dumps(out))
        sys.stdout.flush()


def run_black_first(seed, ticks):
    """Rows at ticks 0..ticks from a finite seed (site 1 = bit 0); the wall is black at even ticks."""
    r, rows = seed, [seed]
    for t in range(ticks):
        x = (r << 1) | (1 if t % 2 == 0 else 0)
        r = x ^ ((x >> 1) | (x >> 2))
        rows.append(r)
    return rows


def rows(trap):
    trapset = set(trap)
    out = []
    # 1. the exterior row: samples 0..46 read the exception, the window at sample 46 is outside
    rs = run_black_first(0xa224d3200017fb5ccd115f23a59, 2 * 60)
    gate = ''.join(str(rs[2 * s + 1] & 1) for s in range(58))
    inside = [(rs[2 * s + 1] & 0xFFFF) in trapset for s in range(58)]
    out.append(dict(row='0xa224d3200017fb5ccd115f23a59', reads_exception_at_0=gate[:47] == EXCEPTION,
                    window_at_46=rs[2 * 46 + 1] & 0xFFFF, outside_at_46=not inside[46],
                    first_sample_inside=inside.index(True) if True in inside else None))
    # 2. the interior row: inside from sample 0, the same word at samples 10..56
    rs = run_black_first(0x4319fc9fcd612848b70077729985e4b9, 2 * 60)
    gate = ''.join(str(rs[2 * s + 1] & 1) for s in range(58))
    inside = [(rs[2 * s + 1] & 0xFFFF) in trapset for s in range(58)]
    out.append(dict(row='0x4319fc9fcd612848b70077729985e4b9', inside_from_sample_0=all(inside),
                    reads_exception_at_10=gate[10:57] == EXCEPTION))
    # 3. the latest alarm: from entry, the first offset at which the last 48 samples are clean
    rs = run_black_first(0x7fffff80fc, 2 * 140)
    S = 130
    gate = ''.join(str(rs[2 * s + 1] & 1) for s in range(S))
    inside = [(rs[2 * s + 1] & 0xFFFF) in trapset for s in range(S)]
    entry = inside.index(True)
    fire48 = next(k for k in range(47, S - entry) if clean(gate[entry + k - 47: entry + k + 1]))
    fire47 = next(k for k in range(46, S - entry)
                  if clean(gate[entry + k - 46: entry + k + 1]) and gate[entry + k - 46: entry + k + 1] != EXCEPTION)
    out.append(dict(row='0x7fffff80fc', entry_sample=entry, gate_from_entry=gate[entry: entry + 12],
                    first_offset_with_48_clean=fire48, first_offset_with_47_clean_not_exception=fire47))
    for d in out:
        print(json.dumps(d))


def word_bits(gaps):
    return '1' + ''.join('0' * (int(g) - 1) + '1' for g in gaps)


def exits(trap, budget):
    trapset = set(trap)
    cases = [('333333353', False, 'UNSAT'), ('3333333355', True, 'UNSAT'), ('3333333355', False, 'SAT'),
             ('33355' * 6, False, 'SAT'), ('33355' * 7, False, 'UNSAT'),
             ('333355' * 8, False, 'SAT'), ('333355' * 9, False, 'UNSAT')]
    for gaps, outside_at_end, want in cases:
        t0 = time.time()
        bits = word_bits(gaps)
        cone = R.Cone(len(bits))
        for i, ch in enumerate(bits):
            cone.clauses.append([cone.gate(i) if ch == '1' else -cone.gate(i)])
        if outside_at_end:
            cone.forbid_codes(len(bits) - 1, trap)
        status, row = cone.solve(budget)
        out = dict(gaps=gaps if len(gaps) < 12 else '(%s)^%d' % (gaps[:5] if gaps.startswith('33355') else gaps[:6],
                                                                 len(gaps) // (5 if gaps.startswith('33355') else 6)),
                   samples=len(bits), last_window_outside_required=outside_at_end, status=status, stated=want,
                   agrees=status == want, cnf_sha256=cone.digest(), seconds=round(time.time() - t0, 1))
        if row is not None:
            gate, codes = R.simulate(row, len(bits))
            out['replays'] = ''.join(map(str, gate)) == bits
            out['last_window_in_trap'] = codes[-1] in trapset
        print(json.dumps(out))
        sys.stdout.flush()


def main():
    kit, mode = sys.argv[1], sys.argv[2]
    budget = int(sys.argv[3]) if len(sys.argv) > 3 else 20_000_000
    trap = [int(c) for c in L.trap_codes(kit)]
    if mode == 'observer':
        observer(trap, budget)
    elif mode == 'rows':
        rows(trap)
    elif mode == 'exits':
        exits(trap, budget)
    else:
        raise SystemExit('unknown mode')


if __name__ == '__main__':
    main()
