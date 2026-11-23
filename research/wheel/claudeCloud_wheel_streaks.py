#!/usr/bin/env python3
"""claudeCloud_wheel_streaks.py: on real trapped rows, how long are the streaks of one run? (ledger K81, addendum 1)

A right half with a random far field is followed exactly beside the alternating column. From 60 samples after it
enters the kit's gate trap its gate is read as runs (the numbers of 5-gaps between successive 3-gaps), and for each
run value the script counts how often it occurs and the longest streak of it in a row. It also counts the longest
exact repetition of a block of two or three runs (the block read twice or more in a row).

    python3 claudeCloud_wheel_streaks.py KITFILE ROWS SAMPLES [SEED]
"""
import collections
import os
import random
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'm9'))
import claudeCloud_m9_lift as L      # noqa: E402


def main():
    kit, rows, S = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    rng = random.Random(int(sys.argv[4]) if len(sys.argv) > 4 else 20261123)
    trap = set(int(c) for c in L.trap_codes(kit))
    count, streak = collections.Counter(), collections.Counter()
    block_rep = collections.Counter()               # (block length, copies in a row) -> how often, maximal ones
    longest_block = {2: 0, 3: 0}
    total_runs = used = 0
    for _ in range(rows):
        width = 2 * S + 40
        x = rng.getrandbits(width)
        gate, entry = [], None
        for s in range(S):
            if entry is None and (x & 0xFFFF) in trap:
                entry = s
            gate.append(x & 1)
            for wall in (0, 1):
                r = (x << 1) | wall
                x = (r ^ ((r >> 1) | (r >> 2))) & ((1 << (width - 1)) - 1)
                width -= 1
        if entry is None:
            continue
        used += 1
        ks = [i for i in range(entry + 60, S) if gate[i]]
        gaps = [b - a for a, b in zip(ks, ks[1:])]
        threes = [i for i, g in enumerate(gaps) if g == 3]
        rs = [threes[i + 1] - threes[i] - 1 for i in range(len(threes) - 1)]
        total_runs += len(rs)
        i = 0
        while i < len(rs):
            j = i
            while j < len(rs) and rs[j] == rs[i]:
                j += 1
            count[rs[i]] += j - i
            streak[rs[i]] = max(streak[rs[i]], j - i)
            i = j
        for b in (2, 3):
            i = 0
            while i + 2 * b <= len(rs):
                blk = rs[i:i + b]
                if len(set(blk)) == 1:
                    i += 1
                    continue
                c = 1
                while rs[i + c * b: i + (c + 1) * b] == blk:
                    c += 1
                if c >= 2:
                    longest_block[b] = max(longest_block[b], c)
                    block_rep[(b, c)] += 1
                    i += c * b
                else:
                    i += 1
    print('%d rows, %d samples each; %d entered the trap in time; %d runs read from 60 samples after entry'
          % (rows, S, used, total_runs))
    print('run: share, longest streak')
    for r in sorted(count):
        if count[r] * 2000 >= total_runs or r <= 12:
            print('  %2d: %.4f, %d' % (r, count[r] / total_runs, streak[r]))
    print('longest exact repetition of a block of two different-looking runs: %d copies; of three: %d copies'
          % (longest_block[2], longest_block[3]))
    print('block repetitions (block length, copies): count', dict(sorted(block_rep.items())))


if __name__ == '__main__':
    main()
