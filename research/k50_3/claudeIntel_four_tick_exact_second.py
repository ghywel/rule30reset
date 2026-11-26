"""Second, independent count of the exact four-tick check (claudeIntel, N30). Shares no code with
claudeIntel_four_tick_exact.py: rows are edge-first tuples evolved with the literal Rule 30 table, and
the 256 registers run in parallel as the bits of Python integers.

Usage: python -I claudeIntel_four_tick_exact_second.py LAYERS M:AGE [M:AGE ...]
"""
import itertools
import sys

RULE = [(30 >> v) & 1 for v in range(8)]


def tick(row, w):
    """row: cells at sites f..-1, edge first; w: the wall bit. The row grows by one cell west."""
    ext = (0, 0) + row + (w,)
    return tuple(RULE[4 * ext[i] + 2 * ext[i + 1] + ext[i + 2]] for i in range(len(row) + 1))


def rows_at(m, age):
    R = {(1,) + rest for rest in itertools.product((0, 1), repeat=m - 1)}
    for _ in range(age):
        R = {tick(r, w) for r in R for w in (0, 1)}
    return R


def failing_registers(row, layers):
    n = 1 << (2 * layers)
    ALL = (1 << n) - 1
    lo = [sum(1 << r for r in range(n) if (r >> (2 * k)) & 1) for k in range(layers)]       # site -1
    hi = [sum(1 << r for r in range(n) if (r >> (2 * k + 1)) & 1) for k in range(layers)]   # site 0
    cur, nxt = lo[:], hi[:]
    cells = {}
    for i in range(len(row) - 1, -1, -1):           # image cell at edge offset i -> chain cells at i - 1
        above = ALL if row[i] else 0
        new = []
        for k in range(layers):
            new.append(above ^ (cur[k] | nxt[k]))
            above = cur[k]
        nxt, cur = cur, new
        cells[i - 1] = cur[layers - 1]
    good = cells[layers]
    for c in range(-1, layers):
        good &= ~cells[c]
    for k in range(layers):
        good &= ~(cur[k] | nxt[k])
    return ALL & ~good


if __name__ == "__main__":
    layers = int(sys.argv[1])
    for spec in sys.argv[2:]:
        m, age = map(int, spec.split(":"))
        R = rows_at(m, age)
        bad = [b for b in (failing_registers(r, layers) for r in R) if b]
        print(f"layers {layers}, depth {m}, age {age}: {len(R)} rows, {len(bad)} failing rows, "
              f"{sum(bin(b).count('1') for b in bad)} failing (row, register) pairs", flush=True)
