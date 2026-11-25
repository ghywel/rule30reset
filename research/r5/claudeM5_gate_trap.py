# independent: the ether halves beside 011 with constant gate; closed-set of 14-cell windows; membership of 4345 and 1992
def step_row(bits):  # list indexes 0.., left of 0 unknown -> caller drives cell 0
    n=len(bits); return [bits[p-1]^(bits[p]|bits[p+1]) if 0<p<n-1 else 0 for p in range(n)]
# least closed set reachable from all-white finite completion windows beside 011: windows at white tick, w cells 1..14; 3-tick step with free east
W=14
def succ(code):
    out=set()
    # cells 1..W+3 with three free outer cells
    for e in range(8):
        row=code|(e<<W)               # bit i = cell i+1
        n=W+3
        for wall in (0,1,1):
            full=(row<<1)|wall        # bit p=cell p
            nxt=0
            for p in range(1,n):      # cell p needs p-1,p,p+1 <= n
                l=full>>(p-1)&1;c=full>>p&1;r=full>>(p+1)&1
                if l^(c|r): nxt|=1<<(p-1)
            n-=1; row=nxt&((1<<n)-1)
        out.add(row&((1<<W)-1))
    return out
# strongly connected terminal component(s) over all 2^14 codes
import sys
sys.setrecursionlimit(10**6)
S=[succ(c) for c in range(1<<W)]
# iterate image from all-white-tail code 0 many steps: reachable set from 0 eventually
import collections
def reach(x):
    seen={x};q=[x]
    while q:
        a=q.pop()
        for b in S[a]:
            if b not in seen: seen.add(b);q.append(b)
    return seen
r=reach(0)
best=min((reach(x) for x in list(r)[:400]),key=len)
core=best
while True:
    x=min(core); y=reach(x)
    if len(y)<len(core): core=y
    else: break
print('reach(0)',len(r),'least closed',len(core),'4345 in',4345 in core,'1992 in',1992 in core)
