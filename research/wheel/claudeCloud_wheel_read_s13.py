#!/usr/bin/env python3
"""claudeCloud_wheel_read_s13.py: an independent replay of the S13 candidate (I180), from the definitions, no Lean.

The candidate (research/wheel/pulse-candidate/Rule30Submission.lean): beside an alternating column, at a black
reading of column 1 on a white tick, the gap to the next black reading (in white ticks) is given

  (a) at every such reading, for every right half, by sites 2, 3, 4, 5 (the table `gap`);
  (b) from the second white tick on, by sites 2 and 5 alone: 00 -> 4, 01 -> 2, 10 -> 5, 11 -> 3 (`nearGap`);
  (c) not at the first white tick: the seed with only site 3 black reads (1, 0) there and returns after 3;
  (d) all four gaps occur at the second white tick on the finite seeds 7, 15, 31, 39 (site 1 = bit 0);
  (e) on the single-cell pattern, when the centre alternates for the 3 + 2 d ticks before the forecast endpoint,
      the forecast holds.

Convention (the kit's): the wall is black at even ticks; the start row is given at tick 0; the white ticks are
1, 3, 5, ...; reading s is at tick 2 s + 1.

Everything is checked on exact light cones: a row known on L cells is known on L - 1 cells one tick later, so no
statement here depends on what lies beyond the cells used.

    python3 claudeCloud_wheel_read_s13.py [AGES]        AGES = how far to follow the single cell (default 200000)
"""
import sys


def step_known(cells, wall):
    """cells = columns 1..L (a list of 0/1) known at this tick; returns columns 1..L-1 one tick later."""
    ext = [wall] + cells
    return [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, len(ext) - 1)]


def gap_table(b2, b3, b4, b5):
    if b2:
        if b3:
            return 3 if (b4 or b5) else 5
        return 5 if b4 else 4
    if b3:
        return 4
    return 2 if (b4 or b5) else 4


def near_gap(b2, b5):
    return (3 if b5 else 5) if b2 else (2 if b5 else 4)


def first_return(cells11):
    """From 11 known cells at a white tick with column 1 black: the gate at the next five white ticks, and the
    index of the first black one (None if none)."""
    row, gate = list(cells11), []
    for t in range(10):
        row = step_known(row, t % 2)            # the tick of `row` is white when t is even: wall 0
        if t % 2 == 1:
            gate.append(row[0])
    for j, g in enumerate(gate):
        if g:
            return j + 1, gate
    return None, gate


def part_a():
    worst, seen = 0, {}
    for code in range(1 << 10):
        cells = [1] + [(code >> i) & 1 for i in range(10)]
        d, gate = first_return(cells)
        assert d is not None, 'no return within five white ticks'
        assert d == gap_table(cells[1], cells[2], cells[3], cells[4]), (cells, d)
        seen[d] = seen.get(d, 0) + 1
        worst = max(worst, d)
    # every one of sites 2 to 5 matters: flipping it alone changes the gap for some setting of the other three
    matters = []
    for k in range(4):
        hit = False
        for code in range(16):
            b = [(code >> i) & 1 for i in range(4)]
            c = list(b)
            c[k] ^= 1
            hit |= gap_table(*b) != gap_table(*c)
        matters.append(hit)
    return seen, worst, matters


def part_b():
    """Every seven-cell prefix at a white tick, one white-to-white update later: where column 1 is black, the
    four-site table equals the two-site one. Seven cells give five two ticks later."""
    pulses, prefixes = 0, set()
    for code in range(1 << 7):
        x = [(code >> i) & 1 for i in range(7)]
        y = step_known(step_known(x, 0), 1)
        assert len(y) == 5
        if y[0]:
            pulses += 1
            prefixes.add(''.join(map(str, y)))
            assert gap_table(y[1], y[2], y[3], y[4]) == near_gap(y[1], y[4]), (x, y)
    # the pulse prefixes on which the two tables differ, among all 16: none of them is reached
    differ = sorted(''.join(map(str, [1, a, b, c, d])) for a in (0, 1) for b in (0, 1) for c in (0, 1) for d in (0, 1)
                    if gap_table(a, b, c, d) != near_gap(a, d))
    return pulses, sorted(prefixes), differ


def run_seed(seed, ticks, width):
    """A finite seed (site 1 = bit 0) from tick 0 with the wall black at even ticks; rows as lists, exact."""
    row = [(seed >> i) & 1 for i in range(width)]
    rows = [row]
    for t in range(ticks):
        ext = [1 if t % 2 == 0 else 0] + row + [0, 0]
        row = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, len(ext) - 1)]
        rows.append(row)
    return rows


def reading(rows, s):
    return rows[2 * s + 1]


def gap_at(rows, s):
    d = 1
    while reading(rows, s + d)[0] == 0:
        d += 1
    return d


def part_cd():
    out = {}
    rows = run_seed(4, 40, 8)
    r = reading(rows, 0)
    out['c'] = dict(seed=4, pulse=r[0], site2=r[1], site5=r[4], two_site_answer=near_gap(r[1], r[4]),
                    true_gap=gap_at(rows, 0), four_site_answer=gap_table(r[1], r[2], r[3], r[4]))
    assert r[0] == 1 and near_gap(r[1], r[4]) == 5 and gap_at(rows, 0) == 3
    out['d'] = []
    for seed, want in ((7, 5), (15, 4), (31, 2), (39, 3)):
        rows = run_seed(seed, 40, 8)
        r = reading(rows, 1)
        assert r[0] == 1 and gap_at(rows, 1) == want == near_gap(r[1], r[4]), seed
        out['d'].append(dict(seed=seed, site2=r[1], site5=r[4], gap=want))
    return out


def part_e(ages):
    """The single cell. Cell (t, x) for x in 0..6 from the full pattern, kept as a Python integer per row."""
    row = 1                                  # bit k = position k - t at tick t (the left edge at bit 0)
    centre, near = [], []                    # near[t] = cells 1..5 at tick t
    for t in range(ages + 16):
        centre.append((row >> t) & 1)
        near.append([(row >> (t + x)) & 1 for x in range(1, 6)])
        x = row << 1                         # rule 30: new(p) = old(p-1) xor (old(p) or old(p+1))
        row = (x << 1) ^ (x | (x >> 1))      # index shift: new bit k = position k - (t+1)
    tested = held = 0
    longest = 0
    for a in range(0, ages - 14):
        if not near[a + 3][0]:
            continue
        d = near_gap(near[a + 3][1], near[a + 3][4])
        if all(centre[a + j] == (1 if j % 2 == 0 else 0) for j in range(3 + 2 * d)):
            tested += 1
            ok = all(near[a + 3 + 2 * i][0] == 0 for i in range(1, d)) and near[a + 3 + 2 * d][0] == 1
            held += ok
            longest = max(longest, d)
    return tested, held, longest


def main():
    ages = int(sys.argv[1]) if len(sys.argv) > 1 else 200000
    seen, worst, matters = part_a()
    print('(a) all 1,024 eleven-cell cones with column 1 black: the gap equals the four-site table; gaps seen',
          dict(sorted(seen.items())), '; longest', worst, '; each of sites 2..5 matters:', matters)
    pulses, prefixes, differ = part_b()
    print('(b) all 128 seven-cell prefixes, two ticks later: %d have column 1 black; their five-site prefixes are %s;'
          % (pulses, prefixes))
    print('    on every one the two-site table equals the four-site table. Prefixes where the tables differ (never'
          ' reached after one update): %s' % differ)
    cd = part_cd()
    print('(c)', cd['c'])
    print('(d)', cd['d'])
    tested, held, longest = part_e(ages)
    print('(e) the single cell to age %d: %d pulses with the centre alternating for the 3 + 2 d ticks before the'
          ' endpoint; the forecast held on %d; longest gap %d' % (ages, tested, held, longest))
    assert tested == held
    print('S13 replay: all parts agree')


if __name__ == '__main__':
    main()
