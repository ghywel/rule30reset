"""Read the census with ether walls, and independently check the endpoints and closure."""
from argparse import ArgumentParser
from collections import Counter
import hashlib
from pathlib import Path

import numpy as np
from ether import make, matches
from replay import FORBIDDEN, UNSEEN, read_tables, white_rows


def replay(seed, end, marks, ether):
    gate=""
    tr=UNSEEN
    for s,row in enumerate(white_rows(seed)):
        if tr==UNSEEN and row % 65536 in marks[0,16]:
            tr=s
        for (tag,width),phases in marks.items():
            word=row % (1<<width)
            if tag and word in phases:
                return tag,s,tr,phases[word]
        gate=(gate+str(row%2))[-48:]
        if len(gate)==48 and all(w not in gate for w in FORBIDDEN):
            return 1,s,tr,UNSEEN
        arm=matches(row,ether)
        if arm:
            assert tr==UNSEEN
            return 9,s,tr,arm[0]
        if s==end:
            return 0,s,tr,UNSEEN


def main():
    p=ArgumentParser(description=__doc__)
    p.add_argument("kit",type=Path)
    p.add_argument("tables",type=Path)
    p.add_argument("binary",type=Path)
    args=p.parse_args()
    marks=read_tables(args.tables)
    ether=make(args.kit)
    rows=np.memmap(args.binary,mode="r",dtype="<u2").reshape(-1,4)
    size=len(rows)
    assert size & (size-1)==0
    checks=set(range(min(size,1024)))
    cum=-1
    slowest=-1
    unknown=0
    print("D exact_rows clean lock2 lock5 lock7 lock7b aligned unknown exact_latest_sample least_seed cumulative_latest_sample least_seed_at_cumulative first_trap_at_cumulative")
    for d in range(size.bit_length()):
        start=1<<(d-1) if d else 0
        group=rows[start:1<<d]
        counts=np.bincount(group[:,0],minlength=10)
        assert len(group)==sum(counts[i] for i in (0,1,2,5,7,8,9))
        last=int(group[group[:,0]!=0,1].max())
        inds=np.flatnonzero((group[:,0]!=0)&(group[:,1]==last))
        seed=int(inds[0])+start
        checks.update(start+int(inds[i]) for i in {0,len(inds)//2,len(inds)-1})
        for tag in (2,5,7,8,9,0):
            sel=np.flatnonzero(group[:,0]==tag)
            if len(sel):
                checks.add(start+int(sel[0]))
                checks.add(start+int(sel[-1]))
        if last>cum:
            cum,slowest=last,seed
        unknown+=int(counts[0])
        tr=int(rows[slowest,2])
        print(d,len(group),*[counts[i] for i in (1,2,5,7,8,9,0)],last,seed,cum,slowest,
              "-" if tr==UNSEEN else tr)
    for seed in sorted(checks):
        expected=tuple(map(int,rows[seed]))
        assert replay(seed,expected[1],marks,ether)==expected,(seed,expected)
    groups,counts=np.unique(rows[rows[:,0]==9,3],return_counts=True)
    print("Aligned detections by arm k:",dict(zip(map(int,groups),map(int,counts))))
    print("Cumulative missing at horizon",unknown,"first examples",np.flatnonzero(rows[:,0]==0)[:10].tolist())
    print("Independently replayed",len(checks),"first signals; max resolved at seed",slowest,tuple(map(int,rows[slowest])))
    print("First result at 944",tuple(map(int,rows[944])))
    with args.binary.open("rb") as f:
        print("Binary SHA256:",hashlib.file_digest(f,"sha256").hexdigest())


if __name__=="__main__":
    main()
