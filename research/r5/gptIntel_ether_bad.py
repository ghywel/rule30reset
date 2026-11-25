"""Check whether inverse Rule 30 steps can extend the exceptional ether front."""
import argparse
from itertools import product

ETHER = tuple(int(b) for b in "000100111110")


def ether(p, t):
    return ETHER[(p+4*t) % 12]


def inverse_slice(output, pair):
    """The initial pair is just east of the preimage cells being computed."""
    near, far = pair
    old = []
    for value in reversed(output):
        bit = value ^ (near | far)
        old.append(bit)
        near, far = bit, near
    return tuple(reversed(old))


def inverse_step(row):
    """Positive cells of the finite predecessor of the positive output row."""
    return inverse_slice(row[1:], (0, 0))


def advance(row, wall):
    extended = (wall,) + row + (0, 0)
    return tuple(l ^ (c | r) for l, c, r in zip(extended, extended[1:], extended[2:]))


def front(row, t, origin):
    width = len(row)
    for i in range(width+12):
        if (row[i] if i < width else 0) != ether(origin+i+1,t):
            return i+1
    raise AssertionError("finite row must differ")


def inspect(jump):
    # The current bad front is at spatial coordinate zero and has ether class 10.
    # The next one is at jump and has class (10+4+jump) mod 12.
    output = tuple(ether(10+i,1) ^ int(i in (jump,jump+1))
                   for i in range(-2,jump+2))
    rows = [inverse_slice(output,pair) for pair in product((0,1),repeat=2)]
    print("jump",jump,"output","".join(map(str,output)))
    for pair, old in zip(product((0,1),repeat=2),rows):
        diffs = [i for i,b in enumerate(old,-3) if b != ether(10+i,0)]
        print("  east pair",pair,"old","".join(map(str,old)),"defects",diffs)


def replay_families(max_n):
    for drive, origin, phase, base in (("001", 0, 0, 22), ("011", 11, 2, 27)):
        for n in range(max_n+1):
            last = base+8*n
            row = tuple(ether(origin+p,phase+n) if p < last else int(p in (last+1,last+4))
                        for p in range(1,last+5))
            for _ in range(n):
                row = inverse_step(row)
            support = len(row)
            assert support == base+7*n+4
            for t in range(21*n+2):
                first = front(row,phase+t,origin)
                if t <= n:
                    assert first == base+8*t
                    assert row[first] != ether(origin+first+1,phase+t)
                elif (t-n-1) % 10 == 0:
                    assert first == last+2-4*((t-n-1)//10)
                row = advance(row,ether(origin,phase+t))
        print(drive, f"all n=0..{max_n} checked; last case has D={support}, t={21*max_n+1}")


if __name__ == "__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("jumps",type=int,nargs="*")
    parser.add_argument("--families",type=int)
    args=parser.parse_args()
    if any(j < 0 for j in args.jumps) or (args.families is not None and args.families < 0):
        parser.error("jumps and family indices must be nonnegative")
    for jump in args.jumps:
        inspect(jump)
    if args.families is not None:
        replay_families(args.families)
