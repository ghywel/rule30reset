"""Verify the sparse-pulse rank from scratch. Requires only Python 3.

Run with no arguments. Phase 0 reads a black driver bit. The following 9,
15 or 16 ticks read white. The input from the outside of the strip can
change arbitrarily at each tick.
"""

WIDTH = 12
STATES = 1 << WIDTH
PHASES = 17
GAPS = (9, 15, 16)


def successors(phase, row):
    """Return the two possible strip rows, independently updating all cells."""
    result = []
    for exterior in (0, 1):
        above = ((row << 1) | int(phase == 0)) & (STATES - 1)
        below = (row >> 1) | (exterior << (WIDTH - 1))
        result.append(above ^ (row | below))
    return result


def main():
    levels = [bytearray(STATES) for _ in range(PHASES)]
    # A rank of even parity requires the predicted right-neighbor bit on
    # white ticks. A rank of odd parity forbids reaching phase 15. These
    # obligations apply whenever the edge preserves rank.
    edges = [[successors(phase, row) for row in range(STATES)]
             for phase in (0, 1)]  # all positive phases have the same update
    checked = 0
    for iteration in range(100):
        new = [bytearray(row) for row in levels]
        changed = False
        checked = 0
        for phase in range(PHASES):
            targets = ([phase + 1] if phase < 16 else []) + ([0] if phase in GAPS else [])
            update = edges[int(phase != 0)]
            for row, possible in enumerate(update):
                bad = phase != 0 and (row & 1) != int(phase >= 3)
                value = levels[phase][row]
                for target in targets:
                    future = levels[target]
                    for nxt in possible:
                        later = future[nxt]
                        parity_conflict = (bad and later % 2 == 0) or (phase == 15 and later % 2 == 1)
                        value = max(value, later + parity_conflict)
                        checked += 1
                new[phase][row] = value
                changed |= value != levels[phase][row]
        levels = new
        if not changed:
            maximum = max(map(max, levels))
            assert (iteration, maximum, checked) == (54, 7, 155648)
            print(f"Verified {checked:,} edges, 54 rank updates, maximum rank {maximum}.")
            return
    raise RuntimeError("No fixed point within the stated horizon")


if __name__ == "__main__":
    main()
