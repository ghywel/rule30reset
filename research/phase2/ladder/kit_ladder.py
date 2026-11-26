"""Count the actual kit ladder S(d,2j) for the white-first wall, plus its phase shift.

Each positive even d <= 48 is paired with 12 post-support checks. The output
also includes odd d; each row uses exact bitlength d (the top bit is black).
"""
import argparse


def first_invalid(seed, phase, horizon):
    """Return the first rejected tick, or horizon when the full prefix is valid."""
    row, previous_white_kick = seed, False
    wall = phase
    for time in range(horizon):
        kick = not row & 1
        if kick and (wall or previous_white_kick):
            return time
        if not wall:
            previous_white_kick = kick
        row = (row >> 1) ^ (row | (row << 1) | wall)
        wall = 1 - wall
    return horizon


def brute_valid(seed, phase, horizon):
    """Literal three-neighbour rule table and indexed kit K1/K3 for the small oracle."""
    west = [(seed >> i) & 1 for i in range(horizon + 1)]
    kicks = []
    for t in range(horizon):
        wall = (t + phase) % 2
        kicks.append(1 - west[0])
        west = [(30 >> (4*a + 2*b + c)) & 1
                for a, b, c in zip(west[1:], west, [wall] + west)]
    return all(not k or ((t + phase) % 2 == 0 and
                         (t + 2 >= horizon or not kicks[t+2])) for t, k in enumerate(kicks))


def census(phase, max_width, checks):
    parents = [0]
    for d in range(1, max_width + 1):
        current, counts = [], [0] * (checks + 1)
        top = 1 << (d - 1)
        for prefix in parents:
            for seed in (prefix, prefix + top):
                end = first_invalid(seed, phase, d + 2 * checks)
                if end < d:
                    continue
                current.append(seed)
                if seed >= top:
                    for j in range((end - d) // 2 + 1):
                        counts[j] += 1
        if d <= 8:
            for j in range(checks + 1):
                assert counts[j] == sum(brute_valid(x, phase, d+2*j) for x in range(top, 2*top))
        if phase == 0:
            a, b = 0, 1
            for _ in range((d + 1)//2 + 2):
                a, b = b, a+b
            assert len(current) == a
        print(phase, d, len(current), *counts, sep="\t", flush=True)
        parents = current


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--width", type=int, default=48)
    args = parser.parse_args()
    print("phase\twidth\tall_valid\t" + "\t".join(f"S{j}" for j in range(13)))
    for p in (0, 1):
        census(p, args.width, 12)
