#!/usr/bin/env python3
"""claudeCloud_front_criterion.py: which relatives of rule 30 are decided at the white wall by their front alone
(ledger K101, pull K92.5.B).

A system is a time hybrid (A, B) (A at even ticks, B at odd) or a space hybrid (A at odd depths, that is at the odd
sites -1, -3, ..., B at the others, as in claudeCloud_atlas.cpp's wall frame) of the rules new = left xor
f(centre, right).  Sites increase eastward; a finite west lies on sites < 0 and the wall
clamps every site >= 0 white at every tick.  Checks are at even ticks: site -1 must be black.

1. Front lemma (finite check).  With every site west of L white and the cells L .. L+2c arbitrary, 2c ticks (c rounds)
   later every site <= L is white: the front moves east by one site per c rounds, whatever lies further east.  It is
   tested for c = 1 .. CMAX, both parities of L for space hybrids, by enumerating all 2^(2c+1) windows.  The cone of
   site L after 2c ticks reaches only L + 2c, so the lemma holds at the wall too while L + 2c <= -1.
2. Terminal map.  Once the front is within 2c of the wall, the row lies on sites -2c .. -1.  Every such row is run with
   the wall until it fails an even check or repeats an even-phase state. Reaching the round limit with
   neither outcome leaves the row unresolved.
3. If the lemma holds and every terminal row dies, every finite west dies, and the deadline is at most
   2c max(W - 2c, 0) ticks plus the terminal maximum. If a terminal row cycles, that row is immortal.

    python3 claudeCloud_front_criterion.py [CMAX] [ATLAS-WALL-TIME.txt ATLAS-WALL-SPACE.txt]

With the atlas outputs it compares the verdict with the atlas's computed candidates (widths to 22).  COMPUTED.
"""
import re
import sys

NAMES = [240, 60, 90, 150, 120, 180, 210, 30]


def f(rule, c, r):
    return {240: 0, 60: c, 90: r, 150: c ^ r, 120: c & r, 180: c & (1 - r), 210: (1 - c) & r, 30: c | r}[rule]


def rule_at(mode, a, b, tick, site):
    if mode == 'time':
        return a if tick % 2 == 0 else b
    return a if site % 2 == 1 else b          # the atlas's convention: A at odd depths, and site -k is depth k


def step(cells, mode, a, b, tick, lo, hi, wall):
    """cells: dict site -> 1.  New row on lo-1 .. hi+1 (clamped below 0 if wall)."""
    out = {}
    top = min(hi + 1, -1) if wall else hi + 1
    for p in range(lo - 1, top + 1):
        rule = rule_at(mode, a, b, tick, p)
        v = cells.get(p - 1, 0) ^ f(rule, cells.get(p, 0), cells.get(p + 1, 0))
        if v:
            out[p] = 1
    return out


def front_lemma(mode, a, b, c):
    for parity in ((0,) if mode == 'time' else (0, 1)):
        L = 100 + parity                       # far from any wall
        for v in range(1 << (2 * c + 1)):
            cells = {L + i: 1 for i in range(2 * c + 1) if (v >> i) & 1}
            x = cells
            for t in range(2 * c):
                lo = min(x) if x else L
                x = step(x, mode, a, b, t, lo, L + 2 * c + 2 * c, False)
            # sites west of L and L itself must be white; cells east of L+2c were white here, but they cannot
            # reach site L within 2c ticks, and sites < L see even less
            if any(p <= L for p in x):
                return False
    return True


def terminal(mode, a, b, c, rounds=4096):
    worst, immortal, unresolved = 0, [], []
    width = 2 * c
    for v in range(1, 1 << width):
        x = {-1 - i: 1 for i in range(width) if (v >> i) & 1}
        seen = set()
        for t in range(2 * rounds + 1):
            if t % 2 == 0:
                if not x.get(-1, 0):
                    worst = max(worst, t)
                    break
                key = frozenset(x)
                if key in seen:
                    immortal.append(v)
                    break
                seen.add(key)
            if t == 2 * rounds:
                unresolved.append(v)
                break
            lo = min(x) if x else -1
            x = step(x, mode, a, b, t, lo, -1, True)
    return worst, immortal, unresolved


def atlas_candidates(paths):
    out = {}
    for path in paths:
        cur = None
        for l in open(path):
            m = re.match(r'== (time|space) \((\d+), (\d+)\)', l)
            if m:
                cur = (m.group(1), int(m.group(2)), int(m.group(3)))
                out[cur] = 0
            elif cur and l[:1].isdigit():
                out[cur] += int(l.split('|')[6])
    return out


def main():
    cmax = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    atlas = atlas_candidates(sys.argv[2:4]) if len(sys.argv) >= 4 else {}
    print('system | front lemma: least c (rounds per site), or none to %d | longest failure (ticks) | '
          'immortal rows | unresolved rows | verdict | atlas candidates to width 22 | agree' % cmax)
    tally = {}
    for mode in ('time', 'space'):
        for a in NAMES:
            for b in NAMES:
                c = next((c for c in range(1, cmax + 1) if front_lemma(mode, a, b, c)), None)
                immortal, unresolved = [], []
                if c is None:
                    verdict, worst = 'front not certified', '-'
                else:
                    worst, immortal, unresolved = terminal(mode, a, b, c)
                    if immortal:
                        verdict = 'immortal (terminal cycle)'
                    elif unresolved:
                        verdict = 'terminal unresolved'
                    else:
                        verdict = 'mortal at every width'
                key = (mode, a, b)
                ac = atlas.get(key)
                agree = '-'
                if ac is not None and c is not None and (immortal or not unresolved):
                    agree = 'yes' if (ac > 0) == bool(immortal) else 'NO'
                print('%s (%d, %d) | %s | %s | %s | %s | %s | %s | %s' % (
                      mode, a, b, c if c else 'none', worst, immortal if c else '-', unresolved if c else '-',
                      verdict, ac if ac is not None else '?', agree))
                tally.setdefault(verdict, []).append('%s (%d, %d)' % key)
                sys.stdout.flush()
    print()
    for k, v in tally.items():
        print('%s: %d' % (k, len(v)))


if __name__ == '__main__':
    main()
