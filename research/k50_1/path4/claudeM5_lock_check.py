"""claudeM5's independent test of S12's finite claims (M130). No Lean and none of gptIntel's code.

The lock class tables and the ring are read from the source, and every claim is tested by direct simulation of
Rule 30 driven by the black-first alternating column (altCol t = (t even), column 0)."""
import re
import sys

SRC = open(sys.argv[1], encoding="utf-8").read()


def table(name, brace):
    i = SRC.index(name)
    j = SRC.index(brace, i)
    return SRC[i:j]


codes = [[int(x) for x in re.findall(r"\d+", row)]
         for row in re.findall(r"\[([\d,\s]+)\]", SRC[SRC.index("def lock7Codes"):SRC.index("def word7")])]
assert len(codes) == 7
planes = [int(x, 16) for x in re.findall(r"0x([0-9a-f]+)", SRC[SRC.index("def planes"):SRC.index("def tile ")])]
assert len(planes) == 14


def alt(t):
    return 1 if t % 2 == 0 else 0


def window(right_bits, t, width=30):
    """Columns 1..width at time t of the right half whose cell p is bit p-1 of right_bits."""
    n = width + t + 2
    row = [alt(0)] + [(right_bits >> i) & 1 for i in range(n)]
    for s in range(t):
        new = [alt(s + 1)]
        for p in range(1, len(row) - 1):
            new.append(row[p - 1] ^ (row[p] | row[p + 1]))
        row = new
    return sum(row[p] << (p - 1) for p in range(1, width + 1))


def step_row(row, left):
    """One tick of a driven row of cells 1.., left neighbour of cell 1 given; loses one cell on the right."""
    ext = [left] + row
    return [ext[p - 1] ^ (ext[p] | ext[p + 1]) for p in range(1, len(ext) - 1)]


def lock_closure():
    """Every class window, with any two cells beyond it, goes to the next class after a double step from an odd tick.
    The double step takes cells 1..W and W+1, W+2 at the odd tick; column 0 is white then black there."""
    bad = 0
    total = 0
    for k in range(7):
        for c in codes[k]:
            for x1 in (0, 1):
                for x2 in (0, 1):
                    row = [(c >> i) & 1 for i in range(30)] + [x1, x2]
                    # odd tick: left neighbour white (altCol odd = 0), then black at the even tick
                    r1 = step_row(row, 0)
                    r2 = step_row(r1, 1)
                    w = sum(r2[i] << i for i in range(30))
                    total += 1
                    bad += w not in codes[(k + 1) % 7]
    return total, bad


def ring_checks():
    period = 728
    tile = lambda t, d: (planes[t % 14] >> (d % period)) & 1
    bad = 0
    for t in range(28):
        for d in range(1, period + 3):
            bad += tile(t, d + 2) != (tile(t + 1, d + 1) ^ (tile(t, d + 1) | tile(t, d)))
    return bad


def singleton_rows(T):
    rows = []
    row = {0: 1}
    lo, hi = 0, 0
    cur = [1]
    lo = 0
    for _ in range(T + 1):
        rows.append((lo, cur))
        ext = [0, 0] + cur + [0, 0]
        new = [ext[i - 1] ^ (ext[i] | ext[i + 1]) for i in range(1, len(ext) - 1)]
        lo, cur = lo - 1, new
    return rows


def main():
    print("lock closure: windows x completions", lock_closure())
    print("ring recurrence mismatches (tile):", ring_checks())

    # the 29-cell example: all four completions of sites 30,31 at tick 1
    prefix = 157190921
    outs = [window(prefix | (q << 29), 1) for q in range(4)]
    print("29-cell example windows:", outs, "all in class 4:", all(o in codes[4] for o in outs))

    # 28-cell witness: trapped at tick 83, never locked over 400 samples
    avoid = 150212610825
    in_class = [any(window(avoid, 1 + 2 * j) in c for c in codes) for j in range(400)]
    w16 = window(avoid, 83, 16)
    print("28-cell witness: locked in the first 400 samples?", any(in_class), "| first 28 bits match the 29-cell prefix:",
          (avoid ^ prefix) & (2**28 - 1) == 0)
    print("  window of 16 cells at tick 83:", w16)

    # Lowry: right half of the single seed at age 364
    rows = singleton_rows(364)
    lo, cur = rows[364]
    right = [cur[j - lo] if 0 <= j - lo < len(cur) else 0 for j in range(1, 90)]
    code80 = sum(b << i for i, b in enumerate(right[:80]))
    code77 = code80 & (2**77 - 1)
    print("first 80 right cells at age 364 equal Lowry's code:", code80 == 248139127718118986536413,
          "| low 77 bits:", code77 == 248139127718118986536413 % 2**77)
    import random
    rng = random.Random(30)
    ok = 0
    trials = 1500
    for _ in range(trials):
        bits = (248139127718118986536413 % 2**77) | (rng.getrandbits(60) << 77)
        w = window(bits, 95)
        ok += w in codes[6]
    print(f"77-cell completions, window at tick 95 in class 6: {ok} of {trials}")
    centre = rows
    cen = [r[1][-r[0]] for r in rows]
    print("centre 363..366 of the single seed:", [rows[i][1][-rows[i][0]] for i in range(363, 365)])


if __name__ == "__main__":
    main()
