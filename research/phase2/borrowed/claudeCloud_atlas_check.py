#!/usr/bin/env python3
"""claudeCloud_atlas_check.py: an independent replay of claudeCloud_atlas.cpp at small sizes (ledger K98).

Cells are held in Python lists and every update is written out cell by cell from the rule number's eight-entry
table, so nothing is shared with the C++ program's word operations.

    python3 claudeCloud_atlas_check.py ATLAS [A B]

ATLAS is the compiled program.  Both frames and both hybrid modes are compared: the wall frame to width 9 with
horizons 40 and 300, the line frame for starts below 32 over 200 ticks.  With A B only that pair is compared.
"""
import subprocess
import sys

NAMES = [240, 60, 90, 150, 120, 180, 210, 30]


def out(rule, l, c, r):
    return (rule >> (4 * l + 2 * c + r)) & 1


def wall_step(row, a, b, space, tick):
    """row[k] is depth k + 1; depth 0 is a white wall; the left neighbour of a depth is the next depth out."""
    n = len(row) + 1
    get = lambda k: row[k - 1] if 1 <= k <= len(row) else 0
    new = []
    for k in range(1, n + 1):
        rule = (a if k % 2 == 1 else b) if space else (b if tick % 2 else a)
        new.append(out(rule, get(k + 1), get(k), get(k - 1)))
    while new and new[-1] == 0:
        new.pop()
    return new


def wall_block(a, b, space, wmax, hfast, hslow):
    lines = []
    for w in range(1, wmax + 1):
        first = w if w % 2 == 0 else w + 1
        rows, longest, past, alive, imm, cand = 0, 0, [0] * 5, 0, 0, []
        for y0 in range(1, 1 << w, 2):
            if not (y0 >> (w - 1)) & 1:
                continue
            rows += 1
            row = [(y0 >> i) & 1 for i in range(w)]
            life = None
            for t in range(hslow):
                row = wall_step(row, a, b, space, t)
                if (t + 1) % 2 == 0 and not (row and row[0]):
                    life = t + 1
                    break
            if life is None or life > hfast:
                alive += 1
            if life is None:
                imm += 1
                if imm <= 4:
                    cand.append(y0)
            else:
                longest = max(longest, life)
            eff = 1 << 30 if life is None else life
            for k, more in enumerate((0, 1, 2, 4, 8)):
                if eff > first - 2 + 2 * more:
                    past[k] += 1
        lines.append('%d | %d | %d | %s | %d | %d | %d |%s' % (
            w, rows, longest, ' '.join(map(str, past)), alive, alive, imm, ''.join(' %d' % c for c in cand)))
    return lines


def line_stats(a, b, space, w0, T, M, pmax):
    some = some_black = every = 0
    per = {}
    single = []
    for s in range(1, 1 << w0):
        cells = {i: 1 for i in range(w0) if (s >> i) & 1}
        cols = {j: [] for j in range(-M, w0 + M)}
        for t in range(T + 1):
            for j in cols:
                cols[j].append(cells.get(j, 0))
            if t == T:
                break
            lo, hi = min(cells, default=0) - 1, max(cells, default=0) + 1
            new = {}
            for i in range(lo, hi + 1):
                rule = (a if i % 2 == 0 else b) if space else (b if t % 2 else a)
                if out(rule, cells.get(i - 1, 0), cells.get(i, 0), cells.get(i + 1, 0)):
                    new[i] = 1
            cells = new
        nper = nblack = 0
        for j in sorted(cols):
            c = cols[j]
            found = 0
            for p in range(1, pmax + 1):
                if all(c[t] == c[t + p] for t in range(T // 2, T - p + 1)):
                    found = p
                    break
            if found:
                nper += 1
                per[found] = per.get(found, 0) + 1
                white = not any(c[T // 2:])
                nblack += not white
                if s == 1:
                    single.append(' %d:%d%s' % (j, found, 'w' if white else ''))
        some += nper > 0
        some_black += nblack > 0
        every += nper == len(cols)
    return '%d | %d | %d |%s | single cell, site:period (w = white):%s' % (
        some, some_black, every, ''.join(' %d:%d' % (p, per[p]) for p in sorted(per)), ''.join(single) or ' none')


def main():
    atlas = sys.argv[1]
    only = tuple(map(int, sys.argv[2:4])) if len(sys.argv) >= 4 else None
    bad = total = 0
    for space in (False, True):
        mode = 'space' if space else 'time'
        for a in NAMES:
            for b in NAMES:
                if only and (a, b) != only:
                    continue
                got = subprocess.run([atlas, 'wall', mode, '9', '40', '300', '1000000', str(a), str(b)],
                                     capture_output=True, text=True).stdout.splitlines()
                got = [l for l in got if l[:1].isdigit()]
                want = wall_block(a, b, space, 9, 40, 300)
                total += 1
                if got != want:
                    bad += 1
                    print('WALL MISMATCH', mode, a, b)
                    for g, x in zip(got, want):
                        if g != x:
                            print('  c++   ', g)
                            print('  python', x)
                got = subprocess.run([atlas, 'line', mode, '5', '200', '6', '12', str(a), str(b)],
                                     capture_output=True, text=True).stdout.splitlines()[-1]
                want = '%s (%d, %d): %s' % (mode, a, b, line_stats(a, b, space, 5, 200, 6, 12))
                total += 1
                if got != want:
                    bad += 1
                    print('LINE MISMATCH', mode, a, b)
                    print('  c++   ', got)
                    print('  python', want)
    print('compared %d blocks, %d mismatches' % (total, bad))


main()
