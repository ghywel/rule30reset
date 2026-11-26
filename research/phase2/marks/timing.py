"""Read the archived U32 observations of seed_records. Fixed timing tests from I281/I282."""
from array import array
from collections import Counter
import argparse
from pathlib import Path
import sys


def words(path):
    a = array("I")
    assert a.itemsize == 4
    a.frombytes(path.read_bytes())
    if sys.byteorder != "little":
        a.byteswap()
    return a


def timing(directory):
    obs = words(directory/"observations.u32le")
    failures = words(directory/"failures.u32le")
    H = len(failures) - 1
    assert H == 2**22
    cut = H//2
    periods = {2,7,28,399 % 256}
    train = [Counter(), Counter()]
    test = [Counter(), Counter()]
    fixed = [[0,0],[0,0]]
    ray = [[0]*4 for _ in range(2)]
    rays = [[0]*4 for _ in range(2)]
    best = -1
    records = []
    checkpoints = []
    for s in range(1,H+1):
        length = ((obs[s]>>1) & 1023)-1
        assert length >= 0
        if obs[s+length] & 1:
            if length > best:
                records.append((s,length))
                best = length
            if length >= 14:
                split = int(s>cut)
                for side, age in enumerate((s,s+length)):
                    (test if split else train)[side][age%16] += 1
                    fixed[split][side] += age%256 in periods
                # The earliest right-going characteristic from D_j to (s,0)
                # departs at u=(s+j)/2 when integral and u>=j.
                for i,j in enumerate((2,7,28,399)):
                    if s>=j and (s+j)%2==0:
                        u=(s+j)//2
                        rays[split][i]+=1
                        ray[split][i]+=(obs[u]>>(11+i))&1
        if s >= 1024 and s & (s-1) == 0:
            checkpoints.append((s,best))
    print("dyadic horizon, largest mark", checkpoints)
    print("strict mark records (birth,width)", records)
    for i,name in enumerate(("birth","arrival")):
        mode = min(range(16),key=lambda v:(-train[i][v],v))
        print(name,"mode16",mode,"train",train[i][mode],"/",train[i].total(),
              "holdout",test[i][mode],"/",test[i].total(),
              "fixed residues mod256 train/holdout",fixed[0][i],fixed[1][i])
    print("rays D2,D7,D28,D399 black/available on marked births >=14, train",list(zip(ray[0],rays[0])),
          "holdout",list(zip(ray[1],rays[1])))
    # Independent row convention, pinned central index t in packed full row.
    row=1
    for t in range(769):
        west=row & ((1<<t)-1)
        gap=t-west.bit_length() if west else -1
        assert gap == ((obs[t]>>1)&1023)-1 and (row>>t)&1 == obs[t]&1
        for i,j in enumerate((2,7,28,399)):
            assert ((row>>j)&1) == (obs[t]>>(11+i))&1
        row=(row<<2)^((row<<1)|row)
    print("769 literal row centres, west gaps and four diagonals agree")


if __name__ == "__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("directory", type=Path)
    timing(p.parse_args().directory)
