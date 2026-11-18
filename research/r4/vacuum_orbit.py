"""Finite controls for R20's one-orbit construction. Bit indices increase to the right."""
import json


def evolve(row, ticks):
    # Values crossing the left boundary can never reach a tested output in time.
    for _ in range(ticks):
        row = (row << 1) ^ (row | (row >> 1))
    return row


def check_window_maps():
    maps = inputs = 0
    for ticks in range(1, 5):
        for width in range(1, 5):
            size = 1 << width
            for suffix in range(1 << (2 * ticks)):
                outputs = {(evolve((suffix << width) | left, ticks) >> ticks) % size
                           for left in range(size)}
                assert len(outputs) == size, (ticks, width, suffix)
                maps += 1
                inputs += size
    return maps, inputs


def extend(row, cut, radius):
    # Positions >= -cut were fixed earlier. Add a marker at -cut-1.
    ticks = cut + 2 + radius
    next_cut = ticks + radius
    row = (row << (next_cut - cut)) | (1 << (next_cut - cut - 1))
    for pos in range(radius, -radius - 1, -1):
        if (evolve(row, ticks) >> (pos + next_cut)) & 1:
            row |= 1 << (pos - ticks + next_cut)
    return row, next_cut, ticks


def replay(row, cut, stages, prefix):
    # Pad farther left than the complete replay cone. Use the four black triples.
    origin = cut + max(t + r for t, r in stages) + 1
    row <<= origin - cut
    reference = 1 << origin
    counts = [0] * len(stages)
    for t in range(1 + max(s + r for s, r in stages)):
        assert row >> (origin + t - prefix) == reference >> (origin + t - prefix)
        for index, (start, radius) in enumerate(stages):
            if start <= t <= start + radius:
                remaining = start + radius - t
                mask = (1 << (2 * remaining + 1)) - 1
                assert ((row >> (origin - remaining)) & mask) == 0, (index, t)
                counts[index] += 1

        left, middle, right = row << 1, row, row >> 1
        row = ((~left & ~middle & right) | (~left & middle & ~right)
               | (~left & middle & right) | (left & ~middle & ~right))
        reference = (reference << 1) ^ (reference | (reference >> 1))
    return counts


def main():
    maps, inputs = check_window_maps()
    prefix = cut = 4
    row = 1 << cut
    stages = []
    for radius in (8, 96, 1024):
        old_row, old_cut = row, cut
        row, cut, start = extend(row, cut, radius)
        assert row >> (cut - old_cut) == old_row
        assert (row >> (cut - old_cut - 1)) & 1
        stages.append((start, radius))
    replay_counts = replay(row, cut, stages, prefix)
    print(json.dumps(dict(maps=maps, inputs=inputs, fixed_seed_from=-prefix,
                          stages=stages, white_triangle_rows=replay_counts,
                          last_initial_cut=-cut), indent=2))


if __name__ == '__main__':
    main()
