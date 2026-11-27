#!/usr/bin/env python3
"""claudeCloud_atlas_read.py: reads the wall-frame output of claudeCloud_atlas.cpp (ledger K98, pull K92.5).

Written after the registration and after the runs: it applies the registered definitions and adds one question
that the registration did not ask, whether an immortal candidate keeps a bounded width.

    python3 claudeCloud_atlas_read.py WALL-TIME.txt WALL-SPACE.txt

For every system: the number of immortal candidates listed, whether each of the least ones (up to four per width)
returns to an earlier row (a cycle of bounded width) or is still growing at tick 20000, the longest finite
lifetime, and whether the system is rule-30-like by the registered definition.
"""
import re
import sys

NAMES = [240, 60, 90, 150, 120, 180, 210, 30]
GROW = {90, 150, 210, 30}          # f(white, black) = black: a row gains one depth at every tick of the rule


def f(rule, c, r):
    return {240: 0, 60: c, 90: r, 150: c ^ r, 120: c & r, 180: c & ~r, 210: ~c & r, 30: c | r}[rule]


def step(y, a, b, space, tick):
    up, c, r = y >> 1, y, y << 1
    if space:
        n = r.bit_length() + 2
        odd = int('01' * (n // 2 + 1), 2)          # bit k even: depth k + 1 odd
        return up ^ ((f(a, c, r) & odd) | (f(b, c, r) & ~odd))
    return up ^ f(b if tick % 2 else a, c, r)


def fate(y, a, b, space, horizon=20000):
    """('cycle', period, widest) if the row returns to itself at an even tick, ('dies', tick), or ('grows', width)."""
    seen = {y: 0}
    widest = y.bit_length()
    for t in range(horizon):
        y = step(y, a, b, space, t)
        widest = max(widest, y.bit_length())
        if (t + 1) % 2 == 0:
            if not y & 1:
                return ('dies', t + 1)
            if y in seen:
                return ('cycle', t + 1 - seen[y], widest)
            if y.bit_length() <= 64:
                seen[y] = t + 1
    return ('grows', y.bit_length())


def read(path):
    systems, cur = {}, None
    for line in open(path):
        m = re.match(r'== (time|space) \((\d+), (\d+)\)', line)
        if m:
            cur = (m.group(1), int(m.group(2)), int(m.group(3)))
            systems[cur] = []
        elif cur and line[:1].isdigit():
            p = [x.strip() for x in line.split('|')]
            systems[cur].append(dict(w=int(p[0]), rows=int(p[1]), longest=int(p[2]),
                                     past=list(map(int, p[3].split())), alive=int(p[4]), carried=int(p[5]),
                                     imm=int(p[6]), cand=list(map(int, p[7].split())) if len(p) > 7 else []))
    return systems


def main():
    systems = {}
    for path in sys.argv[1:3]:
        systems.update(read(path))
    print('system | both rules grow | immortal candidates (capped at 64 a width) | fates of the least ones | '
          'longest finite lifetime, at width | pass ratio of the first check past the support, widths 20-22 | '
          'rule-30-like')
    tally = {}
    for key in sorted(systems, key=lambda k: (k[0], NAMES.index(k[1]), NAMES.index(k[2]))):
        mode, a, b = key
        rows = systems[key]
        imm = sum(r['imm'] for r in rows)
        alive = sum(r['alive'] for r in rows)
        fates = {}
        for r in rows:
            for y in r['cand']:
                ft = fate(y, a, b, mode == 'space')
                tag = 'cycle of %d ticks, width %d' % (ft[1], ft[2]) if ft[0] == 'cycle' else ft[0]
                fates.setdefault(tag if ft[0] != 'cycle' else 'cycle', []).append((y, tag))
        longest = max(rows, key=lambda r: r['longest'])
        p0 = sum(r['past'][0] for r in rows if 20 <= r['w'] <= 22)
        p1 = sum(r['past'][1] for r in rows if 20 <= r['w'] <= 22)
        ratio = p1 / p0 if p0 else float('nan')
        like = alive == 0 and 0.25 <= ratio <= 0.75 and any(r['longest'] > r['w'] + 2 for r in rows if r['w'] >= 16)
        grow = a in GROW and b in GROW
        desc = []
        for kind in ('cycle', 'grows', 'dies'):
            if kind in fates:
                ex = fates[kind][0]
                desc.append('%d %s (e.g. row %d: %s)' % (len(fates[kind]), kind, ex[0], ex[1]))
        print('%s (%d, %d) | %s | %d | %s | %d at %d | %.3f | %s' % (
            mode, a, b, 'yes' if grow else 'no', imm, '; '.join(desc) or '-', longest['longest'], longest['w'],
            ratio, 'yes' if like else 'no'))
        cls = 'rule-30-like' if like else ('immortal' if imm else 'deadline')
        tally.setdefault((grow, cls), []).append('%s (%d, %d)' % key)
    print()
    for (grow, cls), names in sorted(tally.items()):
        print('%s, %s: %d: %s' % ('both rules grow' if grow else 'one rule does not grow', cls, len(names),
                                    ', '.join(names)))
    twenty = [k for k in systems if k[1] != k[2] and 30 in k[1:] and (set(k[1:]) - {30}) <= {90, 150, 210, 120, 180}]
    print()
    print('the twenty: %d systems' % len(twenty))
    for k in sorted(twenty):
        rows = systems[k]
        print('  %s (%d, %d): immortal candidates %d' % (k + (sum(r['imm'] for r in rows),)))


main()


def combined(wall_paths, line_paths):
    """Both frames side by side: which systems are clean in both, and how the others fail."""
    systems = {}
    for path in wall_paths:
        systems.update(read(path))
    line = {}
    for path in line_paths:
        for l in open(path):
            m = re.match(r'(time|space) \((\d+), (\d+)\): (\d+) \| (\d+) \| (\d+) \|', l)
            if m:
                line[(m.group(1), int(m.group(2)), int(m.group(3)))] = tuple(map(int, m.groups()[3:]))
    linear = {240, 60, 90, 150}
    print('system | linear | wall: immortal candidates | line: starts with a periodic column | '
          'of them not eventually white | every column periodic')
    clean = {'linear': [], 'nonlinear': []}
    for key in sorted(systems, key=lambda k: (k[0], NAMES.index(k[1]), NAMES.index(k[2]))):
        imm = sum(r['imm'] for r in systems[key])
        some, black, every = line[key]
        lin = key[1] in linear and key[2] in linear
        print('%s (%d, %d) | %s | %d | %d | %d | %d' % (key + ('yes' if lin else 'no', imm, some, black, every)))
        if imm == 0 and some == 0:
            clean['linear' if lin else 'nonlinear'].append('%s (%d, %d)' % key)
    print()
    for kind in ('nonlinear', 'linear'):
        print('clean in both frames, %s: %d: %s' % (kind, len(clean[kind]), ', '.join(clean[kind])))


if len(sys.argv) >= 5:
    print()
    combined(sys.argv[1:3], sys.argv[3:5])
