#!/usr/bin/env python3
"""claudeCloud_r5_cuts.py: pull R5, first block (ledger K35). Where does a cut period-three ether go after it first
departs?

Frame (kit Rule30EtherThree, Rule30WhiteTailErosion). The period-3 ether is the table ether3 below: 12 columns, 3
phases, a rule-30 orbit. Column 0 is driven by ether column j0 shifted by s, and for the six alignments A001 it reads
0, 0, 1, 0, 0, 1, ... The right half starts as the matching ether on columns 1..N and white beyond (the CUT at N),
and runs under rule 30: new cell = left xor (centre or right). Bit p of a row is column p; bit 0 is the driver.

Recorded for each alignment and cut:
  T_dep     the first tick at which column 1 differs from the ether;
  period    the least period (a multiple of 3, up to PMAX) of the strip of W columns beside the driver over the last
            TAIL ticks of the run, for several W, and of column 1 read on the driver's white phases;
  onset     the first tick from which that period holds.
And for the pair N, N + 12: the difference of the departure ticks, how many columns of the two strips agree at
departure, and the first tick after departure at which column 1's white-phase outputs differ.

  python3 claudeCloud_r5_cuts.py run NMAX AFTER [OUT.jsonl]     every alignment, cuts 0..NMAX, AFTER ticks beyond 3N
  python3 claudeCloud_r5_cuts.py one J0 S N AFTER               one cut, printed
  python3 claudeCloud_r5_cuts.py check                          the ether table against rule 30, the alignments, and
                                                                the uncut ether staying the ether
"""
import json
import sys

ETHER = [[0, 0, 1], [0, 0, 1], [0, 1, 1], [1, 1, 0], [0, 1, 0], [0, 1, 0],
         [1, 1, 0], [1, 0, 1], [1, 0, 0], [1, 0, 0], [1, 0, 1], [0, 1, 1]]
A001 = [(0, 0), (1, 0), (4, 2), (5, 2), (8, 1), (9, 1)]
WIDTHS = (1, 12, 24, 47, 52, 60)
PMAX = 630
TAIL = 2400


def ether3(j, phi):
    return ETHER[j % 12][phi % 3]


def ether_row(j0, s, t, n):
    """Columns 1..n of the aligned ether at tick t, as an int (bit p = column p)."""
    r = 0
    for p in range(1, n + 1):
        r |= ether3(j0 + p, t + s) << p
    return r


def step(row, d):
    full = row | d
    return ((full << 1) ^ (full | (full >> 1))) & ~1


def run_cut(j0, s, N, T):
    """Returns (T_dep, the list of strips: bits 1..60 of the row at each tick 0..T)."""
    row = ether_row(j0, s, 0, N)
    strips, dep = [], None
    mask = ((1 << 61) - 1) & ~1
    for t in range(T + 1):
        strips.append(row & mask)
        if dep is None and ((row >> 1) & 1) != ether3(j0 + 1, t + s):
            dep = t
        row = step(row, ether3(j0, t + s))
    return dep, strips


def least_period(seq, tail=TAIL, pmax=PMAX, by=3):
    """The least period P (a multiple of `by`) of seq over its last `tail` entries, and the first index from which
    it holds; (None, None) if no P up to pmax fits."""
    n = len(seq)
    lo = n - tail
    for P in range(by, pmax + 1, by):
        if all(seq[t] == seq[t + P] for t in range(lo, n - P)):
            t0 = lo
            while t0 > 0 and seq[t0 - 1] == seq[t0 - 1 + P]:
                t0 -= 1
            return P, t0
    return None, None


def analyse(j0, s, N, T):
    dep, strips = run_cut(j0, s, N, T)
    out = {'j0': j0, 's': s, 'N': N, 'T': T, 'dep': dep}
    for W in WIDTHS:
        m = ((1 << (W + 1)) - 1) & ~1
        P, t0 = least_period([x & m for x in strips])
        out['P%d' % W], out['on%d' % W] = P, t0
    # column 1 on the driver's white phases: one symbol per driver period, the two white ticks together
    base = next(t for t in range(3) if ether3(j0, t + s) == 0 and ether3(j0, t + 1 + s) == 0)
    white = [((strips[t] >> 1) & 1, (strips[t + 1] >> 1) & 1) for t in range(base, T, 3)]
    P, t0 = least_period(white, tail=TAIL // 3, pmax=PMAX // 3, by=1)
    out['Pwhite'] = None if P is None else 3 * P      # in ticks
    out['onwhite'] = None if t0 is None else base + 3 * t0
    return out, strips


def pair(a, sa, b, sb):
    """Cuts N (a) and N + 12 (b), each from its own departure tick."""
    da, db = a['dep'], b['dep']
    if da is None or db is None:
        return None
    agree = 0
    x = sa[da] ^ sb[db]
    while agree < 60 and not (x >> (agree + 1)) & 1:
        agree += 1
    n = min(len(sa) - da, len(sb) - db)
    j0, s = a['j0'], a['s']
    first = None
    for k in range(n):
        if ether3(j0, da + k + s) == 0 and ((sa[da + k] ^ sb[db + k]) >> 1) & 1:
            first = k
            break
    return {'ddep': db - da, 'agree_at_dep': agree, 'first_white_diff': first, 'compared': n}


def run(nmax, after, out=None):
    fh = open(out, 'w') if out else None
    for j0, s in A001:
        keep = {}
        for N in range(nmax + 1):
            T = 3 * N + after
            res, strips = analyse(j0, s, N, T)
            keep[N] = (res, strips)
            if N >= 12 and N - 12 in keep:
                res['pair'] = pair(keep[N - 12][0], keep[N - 12][1], res, strips)
                del keep[N - 12]
            line = json.dumps(res)
            if fh:
                fh.write(line + '\n')
                fh.flush()
            else:
                print(line)


def check():
    ok = all(ether3(j, phi + 1) == ether3(j + 11, phi) ^ (ether3(j, phi) | ether3(j + 1, phi)) for j in range(12) for phi in range(3))
    print('the table is a rule-30 orbit: %s' % ok)
    al = [(j0, s) for j0 in range(12) for s in range(3) if [ether3(j0, t + s) for t in range(3)] == [0, 0, 1]]
    print('alignments reading 0, 0, 1: %s (the kit lists %s)' % (al, A001))
    same = True
    for j0, s in A001:
        row = ether_row(j0, s, 0, 400)
        for t in range(100):
            row = step(row, ether3(j0, t + s))
        same = same and (row & ((1 << 200) - 2)) == ether_row(j0, s, 100, 199)
    print('an uncut ether of 400 columns is still the ether on its first 199 columns after 100 ticks: %s' % same)
    print('CONTROL check: %s' % ('PASS' if ok and al == A001 and same else 'FAIL'))


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['run']:
        run(int(a[1]), int(a[2]), a[3] if len(a) > 3 else None)
    elif a[:1] == ['one']:
        res, _ = analyse(int(a[1]), int(a[2]), int(a[3]), 3 * int(a[3]) + int(a[4]))
        print(json.dumps(res))
    elif a[:1] == ['check']:
        check()
    else:
        sys.exit(__doc__)
