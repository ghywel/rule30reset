"""Try to refute successive candidate gate periods using nested initial cones.

The driven site 0 reads 101 repeated, so sample site 1 at ticks 3*m+1.
Each candidate is one row, with a white tail beyond its final set bit.
After a mismatch, keep its entire backward cone in the fixed prefix.
"""
import argparse
import random


def trial(row, sample, period, width):
    """Return the two gate readings on a cone wide enough for both."""
    first, last = 3*sample+1, 3*(sample+period)+1
    assert width >= last+1
    keep = (1 << width)-1
    first_bit = None
    for t in range(last):
        if t == first:
            first_bit = row & 1
        left = (row << 1) | int(t % 3 != 1)
        row = (left ^ (row | (row >> 1))) & keep
    return first_bit, row & 1


def extend(prefix, width, length, attempts, rng):
    yield prefix
    for k in range(min(length-width, attempts-1)):
        yield prefix | (1 << (width+k))
    for _ in range(max(0, attempts-1-(length-width))):
        yield prefix | (rng.getrandbits(length-width) << width)


def find_extensions(count, prefix=0, width=0, attempts=96, seed=72):
    """Enumerate requirements (onset, period) by increasing sum."""
    rng = random.Random(seed)
    completed = 0
    for diagonal in range(1, count+1):
        for period in range(1, diagonal+1):
            onset = diagonal-period
            # Start the second observation beyond the previously frozen cone.
            # When possible the first observation is fixed by that cone.
            sample = max(onset, (width+1)//3-period+4)
            for delay in (0, 4, 16, 64):
                s = sample+delay
                length = 3*(s+period)+2
                assert length > width
                for visit,row in enumerate(extend(prefix,width,length,attempts,rng),1):
                    first, second = trial(row,s,period,length)
                    if first != second:
                        prefix, width = row, length
                        completed += 1
                        yield (onset,period,s,first,second,width,visit,delay,prefix)
                        break
                else:
                    continue
                break
            else:
                raise RuntimeError(f"stalled at {onset=} {period=} {width=} {completed=}")


def scalar(row, sample, period):
    """Independent list replay on a shrinking causal cone."""
    first, last = 3*sample+1, 3*(sample+period)+1
    cells = [bool(row >> i & 1) for i in range(last+1)]
    reading = None
    for t in range(last):
        if t == first:
            reading = cells[0]
        west = (t % 3 != 1)
        following = []
        for mid,east in zip(cells,cells[1:]):
            following.append(west != (mid or east))
            west = mid
        cells = following
    return int(reading), int(cells[0])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--diagonals", type=int, required=True)
    parser.add_argument("--prefix", type=lambda s: int(s,0), default=0)
    parser.add_argument("--width", type=int, default=0)
    parser.add_argument("--seed", type=int, default=72)
    args = parser.parse_args()
    assert 0 <= args.prefix < 1 << args.width
    rows = list(find_extensions(args.diagonals,args.prefix,args.width,seed=args.seed))
    *_, width, _, _, row = rows[-1]
    for n,p,s,a,b,w,attempt,delay,_ in rows:
        assert w <= width and n <= s and (a,b) == trial(row,s,p,w) and a != b
        print(n,p,s,a,b,w,attempt,delay)
    # Shrinking-cone control for the first, middle and last witnesses.
    for k in sorted({0,len(rows)//2,len(rows)-1}):
        _,p,s,a,b,*_ = rows[k]
        assert scalar(row,s,p) == (a,b)
    print(f"checked {len(rows)} requirements; final cone width {width}; row {row:x}")
