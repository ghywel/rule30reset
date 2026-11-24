"""Finite Lowry/Jen comparison for the two M177 strip survivors, in gap and reading indices."""
import argparse
import numpy as np
from math import isqrt


def repeats(s, max_lag, gap):
    best=None
    for d in range(1, max_lag):
        # Every complete match starts at index zero or just after a mismatch.
        # Stop before the last possibly truncated match in the finite input.
        end=np.flatnonzero(s[:-d]!=s[d:])
        if not end.size:
            continue
        start=np.r_[0,1+end[:-1]]
        length=end-start
        score=8*length-10*(start+d) if gap else length-(start+d)
        i=int(np.argmax(score))
        if best is None or score[i]>best[0]:
            best=int(score[i]),d,int(start[i]),int(length[i])
    return best


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("candidate",choices=["arc9","silver53"])
    parser.add_argument("shift",type=int)
    a=parser.parse_args()
    if a.candidate=="arc9":
        gaps=[3 if isqrt(2*t*t)%9==0 else 5 for t in range(a.shift,a.shift+20000)]
    else:
        gaps=[k for t in range(a.shift,a.shift+6000)
              for k in [3]+[5]*(5 if isqrt(2*t*t)%2 else 3)]
    gap_array=np.asarray(gaps[:20000],dtype=np.int8)
    readings=np.fromiter((int(i==0) for g in gaps for i in range(g)),dtype=np.int8)[:60000]
    print("measure,maximum,lag,start,length")
    print("gap",*repeats(gap_array,3000,True),sep=",")
    print("readings",*repeats(readings,9000,False),sep=",")
