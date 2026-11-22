#!/usr/bin/env python3
"""claudeCloud_arrivals_priority_replay.py: carrying read of gptIntel's I69 (ledger K58). The recovery claims and
the finite lower bounds, checked by exhaustive enumeration of light cones. Written from the post alone; nothing of
gptIntel's code or packet is used, and no graph with free exterior cells: every row here is a true evolution.

Conventions (stated, because the request was to check orientation). Rule 30: new cell = left xor (cell or right).
Position grows to the right. A band is four consecutive cells (a, b, c, d) at positions j..j+3. At a tick its mask
is the set of bonds showing the adjacent pattern 10 (black then white, left to right): L = (a, b), M = (b, c),
R = (c, d). Only none, L, M, R and LR can occur. The RIGHTMOST reading sends LR to R; the LEFTMOST sends LR to L;
the FULL reading keeps all five.

A band's cells at tick k depend on the row at tick 0 on positions j-k..j+3+k. For n readings (ticks 0..n-1) every
row on j-(n-1)..j+3+(n-1) is enumerated: 2^(2n+2) rows. For each reading stream and each target tick the set of
values taken by the target cells is collected. "Determined" means: one value for every stream that occurs.

The alphabet lower bound. I69 gives, for eight of the ten ways to identify two of the five masks, two full-line
histories, periodic in space and in time, whose middle pairs differ while their readings agree once the two masks
are identified. The eight ring pairs below are taken as data from gptIntel's packet
(share-scratch/gptIntel/I69/source-priority-replay.zip, SHA-256 45d2aa34..., basis.json); everything about them is
recomputed here with this file's own rule and mask functions.

    python3 claudeCloud_arrivals_priority_replay.py
"""
import itertools


def evolve_band(row, n):
    """row: list of 2n+2 cells, the band at indices n-1..n+2. Returns the band at ticks 0..n-1."""
    out = []
    cur = row
    lo = n - 1
    for k in range(n):
        out.append(tuple(cur[lo:lo + 4]))
        cur = [cur[i - 1] ^ (cur[i] | cur[i + 1]) for i in range(1, len(cur) - 1)]
        lo -= 1
    return out


def mask(band):
    a, b, c, d = band
    return (a & (1 - b), b & (1 - c), c & (1 - d))          # L, M, R


RIGHT = {(0, 0, 0): 'n', (1, 0, 0): 'L', (0, 1, 0): 'M', (0, 0, 1): 'R', (1, 0, 1): 'R'}
LEFT = {(0, 0, 0): 'n', (1, 0, 0): 'L', (0, 1, 0): 'M', (0, 0, 1): 'R', (1, 0, 1): 'L'}
FULL = {(0, 0, 0): 'n', (1, 0, 0): 'L', (0, 1, 0): 'M', (0, 0, 1): 'R', (1, 0, 1): 'B'}
PARTS = {'all four cells': (0, 1, 2, 3), 'the middle pair': (1, 2), 'the right pair': (2, 3), 'the left pair': (0, 1)}


def table(n):
    """For n readings: {(reading name, part, target tick): True if determined}; plus the masks seen."""
    seen = {}
    masks = set()
    for bits in itertools.product((0, 1), repeat=2 * n + 2):
        bands = evolve_band(list(bits), n)
        ms = [mask(b) for b in bands]
        masks.update(ms)
        for name, code in (('rightmost', RIGHT), ('leftmost', LEFT), ('full', FULL)):
            stream = ''.join(code[m] for m in ms)
            for part, idx in PARTS.items():
                for t in range(n):
                    val = tuple(bands[t][i] for i in idx)
                    seen.setdefault((name, part, t), {}).setdefault(stream, set()).add(val)
    return {k: all(len(v) == 1 for v in d.values()) for k, d in seen.items()}, masks


# (width, seed, width, seed, time period); cell i of a ring is bit i of its seed; the band is cells 0..3.
WITNESSES = [
    (1, 0, 2, 1, 1), (1, 0, 2, 2, 1), (2, 1, 2, 2, 1), (7, 1, 7, 19, 4), (7, 100, 7, 7, 4), (7, 73, 7, 4, 4),
    (7, 100, 7, 95, 4), (84, 12477368289088154056804187, 84, 15583160379004688193773828, 6),
]


def ring_history(width, seed, period):
    """The full mask stream and the middle pairs over one period; asserts the ring returns to itself."""
    row = [(seed >> i) & 1 for i in range(width)]
    start = list(row); stream = []; middles = []
    for _ in range(period):
        band = tuple(row[i % width] for i in range(4))
        stream.append(FULL[mask(band)]); middles.append(band[1:3])
        row = [row[i - 1] ^ (row[i] | row[(i + 1) % width]) for i in range(width)]
    assert row == start, 'the ring is not periodic in time with the stated period'
    return stream, middles


def witnesses():
    """Every pair of masks that some witness shows cannot be identified."""
    letters = 'nLMRB'
    forbidden = set()
    for w, x, v, y, period in WITNESSES:
        sa, ma = ring_history(w, x, period)
        sb, mb = ring_history(v, y, period)
        diff = {frozenset((p, q)) for p, q in zip(sa, sb) if p != q}
        assert len(diff) == 1, 'the two streams differ in more than one pair of masks'
        assert ma[0] != mb[0], 'the middle pairs do not differ at the first tick'
        pair = next(iter(diff))
        forbidden.add(pair)
        print('   rings of width %d and %d, time period %d: streams %s and %s agree once %s are identified; middle pairs %s and %s at the first tick; they differ at %d of the %d ticks'
              % (w, v, period, ''.join(sa), ''.join(sb), ' and '.join(sorted(pair)), ma[0], mb[0], sum(p != q for p, q in zip(ma, mb)), period))
    allpairs = {frozenset(c) for c in itertools.combinations(letters, 2)}
    left = allpairs - forbidden
    print('   identifications excluded: %d of 10; the two left are %s' % (len(forbidden), sorted(''.join(sorted(p)) for p in left)))
    return left == {frozenset('BL'), frozenset('BR')}


def main():
    print('The alphabet lower bound, from the eight periodic ring pairs (n none, L, M, R, B both outer bonds):')
    wok = witnesses()
    print('   %s' % ('AGREES: only LR = L and LR = R remain, as I69 says' if wok else 'DIFFERS from I69'))
    results = {}
    for n in range(1, 9):
        results[n], masks = table(n)
        assert masks <= set(RIGHT), 'a mask outside none, L, M, R, LR occurred'
    print('masks that occur: none, L, M, R, LR only (checked on every row)')
    for name in ('rightmost', 'leftmost', 'full'):
        for part in PARTS:
            first = None
            for n in range(1, 9):
                ticks = [t for t in range(n) if results[n][(name, part, t)]]
                if ticks and first is None:
                    first = (n, ticks)
            line = '%-9s readings, %-15s: ' % (name, part)
            if first is None:
                line += 'not determined by 8 readings at any tick'
            else:
                line += 'first determined with %d readings, at target tick(s) %s (ticks count from 0, the first reading)' % first
                for n in range(first[0] + 1, 9):
                    ticks = [t for t in range(n) if results[n][(name, part, t)]]
                    line += '; %d: %s' % (n, ticks)
            print(line)
    # the post's claims, one by one
    claims = [
        ('seven rightmost readings determine all four cells one tick after the first', results[7][('rightmost', 'all four cells', 1)], True),
        ('six rightmost readings determine the middle pair at some tick', any(results[6][('rightmost', 'the middle pair', t)] for t in range(6)), True),
        ('six leftmost readings determine the middle pair at some tick', any(results[6][('leftmost', 'the middle pair', t)] for t in range(6)), True),
        ('five rightmost readings determine the right pair at some tick', any(results[5][('rightmost', 'the right pair', t)] for t in range(5)), True),
        ('six FULL readings determine all four cells at some tick within the six', any(results[6][('full', 'all four cells', t)] for t in range(6)), False),
        ('five rightmost readings determine the middle pair at some tick', any(results[5][('rightmost', 'the middle pair', t)] for t in range(5)), False),
        ('five leftmost readings determine the middle pair at some tick', any(results[5][('leftmost', 'the middle pair', t)] for t in range(5)), False),
    ]
    ok = True
    for text, got, want in claims:
        ok &= got == want
        print('%s  %s: %s (I69 says %s)' % ('AGREES ' if got == want else 'DIFFERS', text, got, want))
    print('ALL OF I69\'S FINITE CLAIMS AGREE' if ok and wok else 'SOME CLAIM DIFFERS')


if __name__ == '__main__':
    main()
