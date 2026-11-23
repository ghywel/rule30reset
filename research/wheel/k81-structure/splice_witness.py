"""Find and independently replay the length-40 symbolic splice on a finite driven right half."""

import json


PULSES = (0, 3, 8, 13, 18, 21, 26, 31, 36)
SPLICE = "".join("1" if i in PULSES else "0" for i in range(40))


def gate_trace(seed, count):
    """Bit zero is site 1. The imposed wall is black at physical tick zero."""
    row = seed
    trace = []
    for tick in range(2 * count):
        if tick % 2:
            trace.append(str(row & 1))
        row = ((row << 1) | (1 - tick % 2)) ^ (row | (row >> 1))
    return "".join(trace)


def replay(seed, start):
    """Recompute the small triangle from the literal eight-entry truth table."""
    last = 2 * (start + 39) + 1
    row = [(seed >> i) & 1 for i in range(last + 1)]
    trace = []
    for tick in range(last + 1):
        if tick % 2 and tick >= 2 * start + 1:
            trace.append(str(row[0]))
        wall = 1 - tick % 2
        row = [(30 >> (4 * left + 2 * centre + right)) & 1
               for left, centre, right in zip([wall] + row, row, row[1:])]
    return "".join(trace)


def main():
    for seed in range(256):
        start = gate_trace(seed, 512).find(SPLICE)
        if start >= 0:
            assert replay(seed, start) == SPLICE
            print(json.dumps(dict(seed=seed, first_white_sample=start,
                                  first_physical_tick=2 * start + 1, samples=SPLICE,
                                  pulse_offsets=PULSES, truth_table_replay=True)))
            return
    print(json.dumps(dict(seeds=256, white_samples_per_seed=512, found=False)))


if __name__ == "__main__":
    main()
