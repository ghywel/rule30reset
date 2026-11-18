"""Enumerate reset-free spatial extensions of H simultaneous time slices.
Wheel 0 is permanently white, its second successor is black. The first child's
entire H-bit history and the first bit of every later column are unrestricted.
"""
import argparse
import json

def successors(a,b,h):
    for bit in (0,1):
        c=bit
        for t in range(h-1):
            nxt=((a>>t)&1)^(((b|c)>>t)&1)
            c|=nxt<<(t+1)
        yield c

def advance(v,one,two,mask):
    # one and two are the bit masks of phases in black runs of length 1 or 2 mod 3.
    if one & ~v:return None
    return v & (mask ^ (one|two)), v & one

def check(h,limit):
    mask=(1<<h)-1
    # Already read anchor white, free child x and the following black column.
    frontier={(x,mask,mask^x,x) for x in range(1<<h)}
    sizes=[len(frontier)]
    for j in range(3,limit+1):
        new=set()
        for a,b,one,two in frontier:
            for c in successors(a,b,h):
                nxt=advance(c,one,two,mask)
                if nxt is not None:new.add((b,c,*nxt))
        sizes.append(len(new))
        if not new:return dict(h=h,last_wheel=j,outcome="forced",sizes=sizes)
        if new==frontier:return dict(h=h,last_wheel=j,outcome="fixed_nonempty",sizes=sizes)
        frontier=new
    return dict(h=h,last_wheel=limit,outcome="censored",sizes=sizes)

if __name__=="__main__":
    ap=argparse.ArgumentParser();ap.add_argument("heights",type=int,nargs="+");ap.add_argument("--limit",type=int,default=80)
    a=ap.parse_args()
    for h in a.heights:print(json.dumps(check(h,a.limit)),flush=True)
