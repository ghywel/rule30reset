"""claudeM5_r5_closure2.py: second code for the 15-trap's backward closure at widths 16 and 20 (predecessors solved from
the left with the drive known), with a forward control."""
# second code for the 15-trap's backward closure at width w: predecessors found by forward steps on all candidate windows
# that could map in: r -> step(r,z); uses a different predecessor routine (solve cell by cell from the LEFT with the drive known)
import pathlib, sys
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f
T=f.load('fifteen'); P,K=f.pattern(T); DR=f.DRIVE
def preds(w,v,phase):
    """all windows r (cells 1..w) at `phase` with some z such that strip_step(w, DR[phase], z, r) = v; left to right."""
    out=set(); 
    # r bits chosen left to right: new_j = r_{j-1} ^ (r_j | r_{j+1})
    def rec(j,a,b,bits):
        # cells j-1=a and j=b known, need (b|c) = a ^ v_j for c = cell j+1
        need=a^((v>>(j-1))&1)
        for c in (0,1):
            if (b|c)!=need: continue
            if j==w: out.add(bits)           # c is the exterior cell z
            else: rec(j+1,b,c,bits|(c<<j))
    for b in (0,1): rec(1,DR[phase],b,b)
    return out
sys.setrecursionlimit(10000)
for w in (16,20):
    S=set(); todo=[]
    for l in range(15):
        r=sum(P[l][j]<<(j-1) for j in range(1,w+1)); S.add((l%3,r)); todo.append((l%3,r))
    while todo:
        p,v=todo.pop(); q=(p+2)%3
        for r in preds(w,v,q):
            if (q,r) not in S: S.add((q,r)); todo.append((q,r))
    eth=[(t,sum(f.ETHER[(j0+j)%12][(t+s)%3]<<(j-1) for j in range(1,w+1))) for j0,s in f.A001 for t in range(3)]
    # forward control: every window outside stays outside
    import random
    rng=random.Random(5); bad=0
    for _ in range(200000):
        p=rng.randrange(3); r=rng.getrandbits(w)
        if (p,r) in S: continue
        z=rng.randrange(2); n=((p+1)%3,f.strip_step(w,DR[p],z,r))
        bad+= n in S
    print('width',w,'closure',len(S),'ether windows inside',sum(x in S for x in eth),'white inside',sum((p,0) in S for p in range(3)),'forward control failures',bad)
    import hashlib; print('   sha256 of the sorted set',hashlib.sha256(repr(sorted(S)).encode()).hexdigest()[:16])
