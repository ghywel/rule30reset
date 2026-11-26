"""Look for all candidate period failures on the same physical gate trace."""
import argparse
from pathlib import Path
import random

from quiet_gate_diagonal import scalar


def gate(row, samples):
    width = 3*samples
    keep = (1 << width)-1
    observed = 0
    for sample in range(samples):
        row = (((row << 1) | 1) ^ (row | row >> 1)) & keep
        observed |= (row & 1) << sample
        row = ((row << 1) ^ (row | row >> 1)) & keep
        row = (((row << 1) | 1) ^ (row | row >> 1)) & keep
    return observed


def first_missing(trace, start, last, periods):
    for p in range(1, periods+1):
        mask = (1 << (last-p-start))-1
        if not (((trace ^ (trace >> p)) >> start) & mask):
            return p
    return None


def aligned_ether(width):
    # 1992 is the gate-zero 011 alignment at its white tick.
    # Run two ticks to the first bit of the 101 drive.
    row = sum(((1992 >> (i % 12)) & 1) << i for i in range(width+2))
    row = (row << 1) ^ (row | row >> 1)
    return (((row << 1) | 1) ^ (row | row >> 1)) & ((1 << width)-1)


def find(width, prefix, start, periods, rng, trials):
    assert width < 3*start+2
    samples = start+10*periods+64
    cone = 3*samples-1
    trace = gate(prefix, samples)
    p = first_missing(trace,start,samples,periods)
    if p is None:
        return 0,prefix,samples,trace
    best = p
    for attempt in range(1,trials+1):
        extension = (rng.getrandbits(cone-width) << width) | prefix
        trace = gate(extension,samples)
        p = first_missing(trace,start,samples,periods)
        if p is None:
            return attempt,extension,samples,trace
        best = max(p,best)
    raise RuntimeError(f"all trials stalled, maximum first missing period {best}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefix", choices=["white","ether","saved"], required=True)
    parser.add_argument("--width", type=int, required=True)
    parser.add_argument("--start", type=int, required=True)
    parser.add_argument("--periods", type=int, required=True)
    parser.add_argument("--trials", type=int, default=96)
    parser.add_argument("--seed", type=int, default=72)
    parser.add_argument("--resume", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    prefix = 0
    if args.prefix == "ether":
        prefix = aligned_ether(args.width)
    if args.prefix == "saved":
        prefix = int(args.resume.read_text(encoding="ascii").splitlines()[0],16)
    assert prefix.bit_length() <= args.width
    tries,row,samples,trace = find(args.width,prefix,args.start,args.periods,
                                  random.Random(args.seed),args.trials)
    furthest = 0
    witnesses = []
    for p in range(1,args.periods+1):
        differences = (trace ^ (trace >> p)) >> args.start
        offset = (differences & -differences).bit_length()-1
        first = args.start+offset
        assert 0 <= offset and first+p < samples
        furthest = max(furthest,first+p)
        witnesses.append((p,first,(trace >> first) & 1,(trace >> (first+p)) & 1))
    frozen = 3*furthest+2
    row &= (1 << frozen)-1
    assert gate(row,furthest+1)==trace & ((1 << (furthest+1))-1)
    for index in sorted({0,len(witnesses)//2,len(witnesses)-1}):
        p,first,b0,b1 = witnesses[index]
        assert scalar(row,first,p)==(b0,b1)
    with args.output.open("w",encoding="ascii") as out:
        print(f"{row:x}",file=out)
        for witness in witnesses:
            print(*witness,file=out)
    print(f"fixed width {args.width}; all periods 1..{args.periods} fail after "
          f"sample {args.start}; freeze {frozen} cells; candidate {tries}")


if __name__ == "__main__":
    main()
