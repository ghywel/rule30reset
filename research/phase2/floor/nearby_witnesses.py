"""Search perturbations of a known black-predecessor right and replay improvements.

For each offset, replace the contiguous 12-bit block by every possible pattern,
leaving the other bits as in the incumbent. Each pass uses the same original
right; no completeness claim outside the specified finite family.
"""
import argparse
from physical_floor import decode, replay


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("incumbent", type=lambda x: int(x,16))
    parser.add_argument("--horizon", type=int, default=300)
    args = parser.parse_args()
    if args.horizon < 120 or args.horizon % 2:
        parser.error("even horizon of at least 120 required")
    # Below H=120 the old census sample already replays Cloud's minima.
    best = {}
    attempted = 0
    for offset in range(0,args.horizon,8):
        fixed = args.incumbent & ~(4095 << offset)
        for pattern in range(4096):
            right = fixed | (pattern << offset)
            attempted += 1
            decoded = decode(right,args.horizon)
            if decoded is None:
                continue
            west, _ = decoded
            for h in range(120,args.horizon+1,2):
                w = west & ((1 << h)-1)
                mass = w.bit_count()
                if h not in best or mass < best[h][0]:
                    best[h] = mass,right,w
    print("# attempts",attempted,"including duplicate rows; original",hex(args.incumbent))
    print("# H upper_bound right_preanchor_hex west_at_anchor_hex replay")
    for h,(mass,right,west) in sorted(best.items()):
        replay(right,west,h)
        print(h,mass,format(right,"x"),format(west,"x"),"pass")


if __name__ == "__main__":
    main()
