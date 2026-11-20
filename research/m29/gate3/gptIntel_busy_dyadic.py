#!/usr/bin/env python3
"""Exact finite certificates for busy dyadic sources (Gate 3; wheel 0 is white).

Use the existing excursion solver beside this script (or put it on PYTHONPATH).
A seed of length p has pulses at 0,5,...,5(m-1), where m=(p-e)/5 is odd.
Its closing gap is 5+e. A block is this source rotated to its specified cut;
rotating in time does not change catches or wheel weights.

At each cut the two lifts, one period apart, have the same pair of width-52
row states U,V in all four seeds. Each period exchanges the states. Both
halves have a 20-tick closed walk at the cut, driven by four ordinary pulses.
These explicit forward paths can be joined in any order and the closed walks
repeated independently. An odd number of blocks exchanges U,V, producing the
two halves of a doubled excursion when the source is repeated. Each full
block appears on both lifts, so no column 1..52 is everywhere white: the
finite witness checks this on each original seed. Column 1 starts as a lift
of the source and the cyclic child is unique whenever its parent is nonwhite.
Thus the constructed states equal the true excursion up to wheel 52.

All retained and inserted rows have a closed reset by wheel 52. Each extra
20 ticks per source period add 40 rows on the doubled band. None is black
on wheel 23 and exactly eight are still bare there. Counts on successive
blocks add, since both lifts of every block occur exactly once in the doubled
period. This is a theorem for the described language, not for all busy words.
"""
import claudeCloud_excursions as ex

W = 52
LOOP = 20
MASK = (1 << (W + 1)) - 1
# p: (exceptional gap minus 5, cut, black ticks on wheel 23, rows still
# uncaught through 23, last catch); a set of four residue classes modulo 20.
SEEDS = {
    104: (-1, 75, 17, 36, 49),
    108: (3, 75, 22, 38, 49),
    112: (-3, 80, 19, 38, 49),
    116: (1, 80, 21, 39, 52),
}
U, V = 0x105203ef7fbb76, 0x1a78e727064ccc
# U has a black first wheel. V matches the first wheel 0 used by the solver.
assert (U & 3, V & 3) == (2, 0)


def source(p, e):
    m, remainder = divmod(p - e, 5)
    assert not remainder and m % 2 == 1
    return "".join("1" if t % 5 == 0 and t < 5 * m else "0" for t in range(p))


def step(row, pulse):
    line = ((row << 2) ^ ((row << 1) | row)) & MASK
    return (line & ~3) | ((row & 2) ^ (int(pulse) << 1))


def first_catch(row):
    run = 0
    for j in range(1, W + 1):
        if row & (1 << j):
            run += 1
        else:
            if run % 3 == 1:
                return j
            run = 0
    return None


def counts(rows):
    catches = [first_catch(row) for row in rows]
    assert None not in catches
    return sum((row >> 23) & 1 for row in rows), sum(j > 23 for j in catches), max(catches)


def solve(word):
    wheels, gap = ex.excursion(word, W)
    assert gap is None and all(any(col) for col in wheels[1:])
    rows = [sum(bit << j for j, bit in enumerate(row)) for row in zip(*wheels)]
    assert not (rows[0] & 3)
    assert all(step(row, word[t % len(word)]) == rows[(t+1) % len(rows)]
               for t, row in enumerate(rows))
    return rows


def block(p, repeats):
    e, cut, black, bare, last = SEEDS[p]
    word = source(p, e)
    rows = solve(word)
    assert counts(rows) == (black, bare, last)
    assert {rows[cut], rows[p+cut]} == {U, V}
    assert all(rows[t] == rows[t+LOOP] for t in (cut, p+cut))
    assert word[cut:cut+LOOP] == "10000" * 4
    looprows = rows[cut:cut+LOOP] + rows[p+cut:p+cut+LOOP]
    assert counts(looprows)[:2] == (0, 8)
    word = word[cut:] + word[:cut]
    rows = rows[cut:] + rows[:cut]
    word = word[:LOOP] * repeats + word
    paths = {half[0]: half[:LOOP] * repeats + half for half in (rows[:p], rows[p:])}
    assert all(step(half[-1], word[-1]) == (V if start == U else U)
               for start, half in paths.items())
    return word, paths


def verify_join(blocks):
    assert len(blocks) % 2 == 1
    parts = [block(p, repeats) for p, repeats in blocks]
    word = "".join(w for w, paths in parts)
    state, rows = V, []
    for _ in range(2):
        for w, paths in parts:
            rows.extend(paths[state])
            state = V if state == U else U
    assert state == V and rows == solve(word)
    assert counts(rows) == (sum(SEEDS[p][2] for p, k in blocks),
                            sum(SEEDS[p][3] + 8*k for p, k in blocks),
                            max(SEEDS[p][4] for p, k in blocks))
    assert word.count("1") % 2 == 1
    return len(word), word.count("1"), *counts(rows)


def main():
    ref, gap = ex.excursion("00001", W)
    assert gap == 23 and ex.first_resets(ref).count(None) == 2
    for p in SEEDS:
        print("seed", p, "statistics (P, pulses, black23, bare23, last)", verify_join([(p, 0)]))
        verify_join([(p, 1)])
        verify_join([(p, 3)])
    print("single-seam dyadics:")
    for p in (16, 32, 64, 128, 256, 512, 1024, 2048):
        base = next(s for s in SEEDS if s % LOOP == p % LOOP)
        if p < base:
            rows = solve(source(p, SEEDS[base][0]))
            print(p, counts(rows))
        else:
            print(p, verify_join([(base, (p-base)//LOOP)])[2:])
    # Three different abnormal spacings, covering the same four residues.
    triples = {sum(v) % LOOP: v for omit in SEEDS for v in [tuple(p for p in SEEDS if p != omit)]}
    assert sorted(triples) == [4, 8, 12, 16]
    print("three-seam dyadics (P, pulses, black23, bare23, last):")
    for p in (512, 1024, 2048, 4096):
        seeds = triples[p % LOOP]
        k, remainder = divmod(p - sum(seeds), LOOP)
        assert not remainder and k >= 0
        blocks = [(s, k if i == 0 else 0) for i, s in enumerate(seeds)]
        print(verify_join(blocks))


if __name__ == "__main__":
    main()
