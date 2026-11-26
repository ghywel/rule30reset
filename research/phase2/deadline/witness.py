"""Compare a finite outlier's gate with periodic locks and the Y schedule."""
import argparse
from collections import Counter

from replay import oracle, read_tables, white_rows
from pathlib import Path


def yscore(bits):
    """Longest prefix of a 2/45/4525 train from a kick, with 10001 every 57 samples."""
    if bits[:1] != "1":
        return 0
    # A tile joins two consecutive block-boundary kicks; its final kick starts
    # the next tile. These strings encode the readings after its first kick.
    tiles = ["01", "000100001", "0001000010100001"]
    queue = {0}
    last = 1
    for i in range(len(bits)):
        if i not in queue:
            continue
        for tile in tiles:
            rest = bits[i+1:i+1+len(tile)]
            common = 0
            for a, b in zip(tile, rest):
                if a != b:
                    break
                common += 1
            last = max(last, i+common+1)
            if common == len(tile):
                queue.add(i+len(tile))
    for i in range(last-56):
        if "10001" not in bits[i:i+57]:
            return i+56
    return last


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tables", type=Path)
    parser.add_argument("seed", type=int)
    parser.add_argument("samples", type=int)
    args = parser.parse_args()
    marks = read_tables(args.tables)
    fate = oracle(args.seed,args.samples-1,marks)
    print("fate(first_event_or_last,trap,phase)",fate)
    length = fate[1]+1
    gate = []
    for s, row in enumerate(white_rows(args.seed)):
        gate.append(str(row%2))
        if s+1 == length:
            break
    bits = "".join(gate)
    for start in sorted({0, max(0,length//2), max(0,length-256)}):
        sub = bits[start:]
        print("gate from sample",start,"first 96:",sub[:96], "length",len(sub))
        periods = [p for p in range(1,min(256,len(sub)//2)+1) if sub[:-p] == sub[p:]]
        kicks = [i for i,c in enumerate(sub) if c == "1"]
        gaps = Counter(b-a for a,b in zip(kicks,kicks[1:]))
        print("smallest period <=256 over suffix:",min(periods,default=None),"gaps:",sorted(gaps.items()))
    # All starts through a maximum of 8K samples keep this preliminary read
    # finite even for a very long requested horizon. Lookahead 1K exceeds N21.
    best, onset = 0, None
    for i,c in enumerate(bits[:8192]):
        if c == "1":
            n = yscore(bits[i:i+1024])
            if n > best:
                best, onset = n, i
    print("longest Y-reading prefix in specified scan",best,"from sample",onset)


if __name__ == "__main__":
    main()
