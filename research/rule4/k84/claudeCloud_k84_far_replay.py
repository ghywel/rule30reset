#!/usr/bin/env python3
"""claudeCloud_k84_far_replay.py: replay every lower bound of claudeCloud_k84_far on the whole line (ledger K88).

For each depth T of the sampler's output: take its right half (256 cells, white beyond), read its gate word with big
integers, decode the west it demands, cut the west at B = T - run, and run Rule 30 on the whole line from that finite
west, a black centre and the right half.  The centre must alternate through tick T.  The simulation here shares no code
with the sampler.
    python3 claudeCloud_k84_far_replay.py FAR.txt [TMIN]
"""
import sys

TABLE = {(1, 1, 1): 0, (1, 1, 0): 0, (1, 0, 1): 0, (1, 0, 0): 1, (0, 1, 1): 1, (0, 1, 0): 1, (0, 0, 1): 1, (0, 0, 0): 0}


def life(west_bits, right_bits, ticks):
    pad = ticks + 2
    row = [0] * pad + list(reversed(west_bits)) + [1] + list(right_bits) + [0] * pad
    c = pad + len(west_bits)
    for t in range(ticks + 1):
        if row[c] != (1 if t % 2 == 0 else 0):
            return t - 1
        row = [0] + [TABLE[row[i - 1], row[i], row[i + 1]] for i in range(1, len(row) - 1)] + [0]
    return ticks


def decode_west(word, ticks):
    parent = sum(1 << t for t in range(0, ticks, 2))
    column = (1 << ticks) - 1
    for time in range(1, ticks, 2):
        column ^= (word >> (ticks // 2 - 1 - time // 2) & 1) << time
    west = []
    for depth in range(ticks):
        west.append(column & 1)
        parent, column = column, ((column >> 1) ^ (column | parent)) & ((1 << (ticks - depth - 1)) - 1)
    return west


def main():
    tmin = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    ok = bad = 0
    best = (0, 0, 0)
    for line in open(sys.argv[1]):
        if line.startswith('#'):
            M = int(line.split()[2]); continue
        T, run, share, right_hex, index = line.split()
        T, run = int(T), int(run)
        if T < tmin or run < 1:
            continue
        right = int(right_hex, 16)
        row, word = right, 0
        m = (T + 1) // 2
        for _ in range(m):
            row = ((row << 1) | 1) ^ (row | (row >> 1)); word = (word << 1) | (row & 1); row = (row << 1) ^ (row | (row >> 1))
        west = decode_west(word, 2 * m + 1)
        B = T - run
        assert all(b == 0 for b in west[B:T]), T
        got = life(west[:B], [(right >> i) & 1 for i in range(256)], T + 2)
        if got >= T:
            ok += 1
        else:
            bad += 1; print('FAIL at depth', T, 'support', B, 'life', got)
        if run > best[0]:
            best = (run, T, B, got)
    print('replayed', ok + bad, 'bounds from depth', tmin, ': pass', ok, 'fail', bad, '; largest excess', best[0], 'at tick', best[1], 'support', best[2], 'life on the line', best[3])


main()
