"""Scalar replay of the K81 finite-seed records and the M106 late wheel."""
import hashlib
import json
from pathlib import Path

from wheel_bridge import table


def trace(initial, samples, black_first):
    width = 16 + 2 * (samples - 1) + int(black_first)
    row = [(initial >> i) & 1 for i in range(width)]
    gates, windows = [], []
    for tick in range(width - 15):
        wall = (tick + black_first) % 2
        if wall == 0:
            gates.append(row[0])
            windows.append(sum(bit << i for i, bit in enumerate(row[:16])))
        left = [wall, *row]
        row = [(30 >> (4*a + 2*b + c)) & 1 for a, b, c in zip(left, row, row[1:])]
    return gates, windows


def verify(gates, windows, trap, entry, first, last, run, copies):
    assert all(code not in trap for code in windows[:entry])
    assert all(code in trap for code in windows[entry:])
    pulses = [s for s in range(first, last + 1) if gates[s]]
    assert (pulses[0], pulses[-1]) == (first, last)
    gaps = [b - a for a, b in zip(pulses, pulses[1:])]
    assert gaps == [3] + ([5] * run + [3]) * copies
    assert first - entry >= 60
    print(f"entry {entry}, samples {first}..{last}, {copies} closed runs of {run}")


if __name__ == "__main__":
    trap = set(table(Path("Rule30PrizeKit"), "trapCodes", "Rule30Certificates/GateTrap"))
    for seed, times, run, copies in [(9073, (5, 126, 489), 3, 20), (14571, (6, 706, 821), 5, 4)]:
        gates, windows = trace(seed, 1024, True)
        verify(gates, windows, trap, *times, run, copies)
    m106 = Path("research/m9/data/claudeM5-m80-runs-of-five-5x5-P100.json")
    record = json.loads(m106.read_bytes())
    bits = record["witness"]["initial_row"]
    assert hashlib.sha256(bytes(map(int, bits))).hexdigest() == record["witness"]["initial_row_sha"]
    gates, windows = trace(int(bits[::-1], 2), 244, False)
    verify(gates, windows, trap, 0, 100, 243, 5, 5)
    verify(gates[40:], windows[40:], trap, 0, 60, 203, 5, 5)
