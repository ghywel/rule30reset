"""Upper witnesses for the kick-anchored floor from the finite right halves of I246.

Run with the original sample-60.tsv. Its third and second columns store the high
and low limbs of a finite right row at the black tick before the anchor.
"""
import argparse


def step(row, wall=0):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def decode(right, horizon):
    """Reconstruct the white-tick west from the whole right's gate trace."""
    row = right
    wall_trace = 0
    prefix = 0
    for t in range(0, horizon, 2):
        row = step(row, 1)
        gate = row & 1
        if not t and not gate:
            return None
        if t < 120:
            prefix = (prefix << 1) | gate
        wall_trace |= ((1 - gate) | 2) << t
        row = step(row)
    # On an alternating history the west has the zero-wall trace just
    # assembled: at black centre times its first cell is already black.
    parent, column = 0, wall_trace
    west = 0
    for depth in range(horizon):
        west |= (column & 1) << depth
        parent, column = column, (column >> 1) ^ (column | parent)
    return west, prefix


def replay(right, west, h):
    """Start at the white tick. Evolve one full, unforced finite row."""
    east = step(right, 1)
    centre = h + 2
    row = (east << (centre + 1)) | sum(((west >> d) & 1) << (centre-d-1) for d in range(h))
    for t in range(h+1):
        assert (row >> centre) & 1 == t % 2
        row = step(row)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sample")
    parser.add_argument("--horizon", type=int, default=300)
    args = parser.parse_args()
    h = args.horizon
    if h < 120 or h % 2:
        parser.error("supply an even horizon at least 120")
    targets = range(2,h+1,2)
    best = {d:(d+1,None,None) for d in targets}
    count = 0
    with open(args.sample, encoding="utf-8-sig") as stream:
        for line in stream:
            previous_gate, low, high = map(int,line.split())
            if not (previous_gate >> 59):
                continue
            right = low | (high << 64)
            west, prefix = decode(right,h)
            assert prefix == previous_gate
            count += 1
            for d in targets:
                value = west & ((1 << d)-1)
                mass = value.bit_count()
                if mass < best[d][0]:
                    best[d] = (mass,right,value)
    print("# anchored sample size",count,"horizon",h)
    print("# H upper_bound right_preanchor_hex west_at_anchor_hex replay")
    for d,(mass,right,west) in best.items():
        replay(right,west,d)
        print(d,mass,format(right,"x"),format(west,"x"),"pass")


if __name__ == "__main__":
    main()
