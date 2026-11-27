#!/usr/bin/env python3
"""claudeCloud_front_check.py: an independent check of HybridWallFront.lean (ledger K99, the carrying read of
K92.5.B).  Nothing here is shared with gptIntel's Lean or hybrid_terminal.py: cells are lists, the rules are their
eight-entry tables, and the wall is applied as in claudeCloud_atlas.cpp.

    python3 claudeCloud_front_check.py WALL-TIME.txt

1. The four-tick step on the whole line: with every site west of L white, the cells L .. L+6 take all 128 values and
   four ticks (30, 180, 30, 180) are applied.  Is every site up to L white afterwards?  Is two ticks (one pair) ever
   enough to clear L?  How often does the first pair leave L black?
2. The speed is sharp: some start keeps its leftmost black cell at L + n exactly at tick 4n for long.
3. The three cells beside the wall: the two-tick map on rows 0..7, and the first white even tick from each.
4. The deadline 4 max(W - 3, 0) + 6 against the longest lifetimes in the frozen atlas, time (30, 180).
5. The reversed order: row 7 under (180, 30).
6. The order at the wall across the atlas: time hybrids whose two orders fall in different classes.
"""
import re
import sys

TABLE = {30: 30, 180: 180, 90: 90, 150: 150, 120: 120, 210: 210, 60: 60, 240: 240}


def out(rule, l, c, r):
    return (rule >> (4 * l + 2 * c + r)) & 1


def line_step(cells, rule, lo, hi):
    """cells: dict site -> 1 for black; the new row on sites lo-1 .. hi+1 (left neighbour is site - 1)."""
    return {p: 1 for p in range(lo - 1, hi + 2) if out(rule, cells.get(p - 1, 0), cells.get(p, 0), cells.get(p + 1, 0))}


def part1():
    L, worst_pair_clears, stalls, bad = 0, 0, 0, []
    for v in range(128):
        cells = {L + i: 1 for i in range(7) if (v >> i) & 1}
        x = cells
        ok_pair = True
        for k, rule in enumerate((30, 180, 30, 180)):
            x = line_step(x, rule, L - 1, L + 40)
            # sites far east are a fixed (white) background here; only sites <= L matter and they see L+4 at most
            if k == 1:
                if any(p <= L - 1 for p in x):
                    bad.append(('pair re-blackens west of L', v))
                if x.get(L, 0):
                    stalls += 1
        if any(p <= L for p in x):
            bad.append(('four ticks leave L or west black', v))
    return stalls, bad


def part2(width=12, ticks=800):
    least = None
    for s in range(1, 1 << width):
        x = {i: 1 for i in range(width) if (s >> i) & 1}
        L0 = min(x)
        for t in range(ticks):
            x = line_step(x, 30 if t % 2 == 0 else 180, min(x) if x else 0, max(x) if x else 0)
            if not x:
                break
        if x:
            adv = min(x) - L0
            least = adv if least is None else min(least, adv)
    return least, ticks // 4


def wall_step(row, rule):
    """row[k] is depth k + 1; depth 0 is the white wall; the west neighbour of depth k is depth k + 1."""
    get = lambda k: row[k - 1] if 1 <= k <= len(row) else 0
    new = [out(rule, get(k + 1), get(k), get(k - 1)) for k in range(1, len(row) + 2)]
    while new and not new[-1]:
        new.pop()
    return new


def pack(row):
    return sum(b << i for i, b in enumerate(row))


def unpack(v, n=3):
    return [(v >> i) & 1 for i in range(n)]


def part3():
    nxt, first_white = [], []
    for v in range(8):
        r = wall_step(wall_step(unpack(v), 30), 180)
        assert len(r) <= 3
        nxt.append(pack(r))
    for v in range(8):
        y, k = v, 0
        while y & 1:
            y, k = nxt[y], k + 1
            if k > 20:
                break
        first_white.append(2 * k)
    return nxt, first_white


def part4(path):
    rows, on = {}, False
    for l in open(path):
        if l.startswith('== time (30, 180)'):
            on = True
            continue
        if on and l.startswith('summary'):
            break
        if on and l[:1].isdigit():
            p = [x.strip() for x in l.split('|')]
            rows[int(p[0])] = (int(p[2]), int(p[4]))
    return [(w, rows[w][0], 4 * max(w - 3, 0) + 6) for w in sorted(rows)]


def part5():
    row, seen = unpack(7), []
    for t in range(12):
        seen.append(pack(row))
        row = wall_step(row, 180 if t % 2 == 0 else 30)
    return seen


def part6(path):
    cls, cur, data = {}, None, {}
    for l in open(path):
        m = re.match(r'== time \((\d+), (\d+)\)', l)
        if m:
            cur = (int(m.group(1)), int(m.group(2)))
            data[cur] = []
        elif cur and l[:1].isdigit():
            p = [x.strip() for x in l.split('|')]
            data[cur].append((int(p[0]), int(p[2]), int(p[4]), int(p[6])))
    for k, rows in data.items():
        imm = sum(r[3] for r in rows)
        alive = sum(r[2] for r in rows)
        cls[k] = 'immortal' if imm else ('alive at 100' if alive else 'dies')
    diff = sorted((a, b) for (a, b) in cls if a < b and cls[(a, b)] != cls[(b, a)])
    return [(a, b, cls[(a, b)], cls[(b, a)]) for a, b in diff]


def main():
    stalls, bad = part1()
    print('1. four ticks clear L from every one of the 128 windows L..L+6: %s; the first pair leaves L black in %d '
          'of 128; problems: %s' % ('yes' if not bad else 'NO', stalls, bad or 'none'))
    least, n = part2()
    print('2. starts below 2^12, 800 ticks: least advance of the leftmost black cell %s sites; the bound gives %d' % (least, n))
    nxt, fw = part3()
    print('3. two-tick map on the three wall cells:', nxt, '; first white even tick from rows 0..7:', fw)
    rows = part4(sys.argv[1])
    print('4. width | longest lifetime in the atlas | deadline 4 max(W-3,0)+6')
    for w, life, dl in rows:
        print('   %d | %d | %d%s' % (w, life, dl, '' if life <= dl else '   EXCEEDS'))
    print('5. reversed order (180 first) from row 7, packed rows at ticks 0..11:', part5())
    print('6. time hybrids whose two orders fall in different wall classes (A first | B first):')
    for a, b, x, y in part6(sys.argv[1]):
        print('   (%d, %d): %s | (%d, %d): %s' % (a, b, x, b, a, y))


main()
