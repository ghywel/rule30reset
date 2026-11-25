# I244: independent test of the colour deadline beside 011 on random finite right halves
import random
def run(R,D,phi,steps,word=(0,1,1)):
    # row: int, bit p = cell p (p>=0), cell 0 driven by word at (t+phi)%3; evolve, return gate readings at white-wall ticks
    row=0
    for p in range(1,D+1):
        if R>>(p-1)&1: row|=1<<p
    out=[]
    for t in range(steps):
        row=(row&~1)|word[(t+phi)%3]
        if word[(t+phi)%3]==0: out.append((t,row>>1&1))
        nxt=(row<<1)^(row|(row>>1))  # new p = l xor (c or r); l = p-1
        row=nxt
    return out
random.seed(244)
worst={0:(-10**9,),1:(-10**9,)}; gapmax=0; viol=0; n=0; tight=None
wrun=0
for D in [0,1,2,3,5,8,13,21,34,55,89]:
    for trial in range(60 if D>8 else 2**min(D,8)):
        R=(trial if D<=8 else random.getrandbits(D)) & ((1<<D)-1) if D else 0
        for phi in range(3):
            Tmax=200; steps=Tmax+3*(D+Tmax+13)+10
            o=run(R,D,phi,steps); n+=1
            for b in (0,1):
                times=[t for t,g in o if g==b]
                i=0
                for T in range(0,Tmax+1):
                    while i<len(times) and times[i]<T: i+=1
                    if i==len(times): viol+=1; break
                    d=times[i]-T; bound=3*(D+T+13)+6
                    if d>bound: viol+=1
                    if d-0>worst[b][0]: worst[b]=(d,D,T,phi,bound)
print('halves',n,'violations',viol,'longest wait for white/black',worst)
# late whites: longest run of blacks among late readings
import collections
lm=0
for k in range(300):
    D=random.randrange(1,120); R=random.getrandbits(D); phi=random.randrange(3)
    o=run(R,D,phi,3*D+822+3000)
    late=[g for t,g in o if t>=3*D+822+60]
    r=0
    for g in late:
        r=r+1 if g else 0; lm=max(lm,r)
print('longest late black run',lm,'(theorem allows 16)')
# each constant gate is held by the aligned ether: a finite prefix of N ether cells holds it for about 5N/2 ticks
eth=[[0,0,1],[0,0,1],[0,1,1],[1,1,0],[0,1,0],[0,1,0],[1,1,0],[1,0,1],[1,0,0],[1,0,0],[1,0,1],[0,1,1]]
for j,c in ((2,1),(11,0)):
    for N in (60,120,240):
        R=sum(eth[(j+p)%12][0]<<(p-1) for p in range(1,N+1))
        g=[x for _,x in run(R,N,0,1200)]
        k=next(i for i,x in enumerate(g) if x!=c)
        print('alignment',j,'prefix',N,'colour',c,'kept for',k,'readings,',3*k,'ticks; deadline',3*(N+13)+6)
# forks: every width-12 prefix against its seven single flips beyond it
bad=worst=0
for pre in range(1<<12):
    a=[x for _,x in run(pre,12,0,216)]; first=None
    for e in range(7):
        b=[x for _,x in run(pre|(1<<(12+e)),19,0,216)]
        d=[i for i,(x,y) in enumerate(zip(a,b)) if x!=y]
        if d: first=d[0] if first is None else min(first,d[0])
    if first is None: bad+=1
    else: worst=max(worst,first)
print('width-12 prefixes without a fork',bad,'; worst first fork at reading',worst)
