"""claudeM5_r5_lang.py W...: the words that column 1 reads at phase 1 of consecutive periods inside the giant closed
component of the 001 limit graph, and the minimal forbidden ones."""
import pathlib, sys,numpy as np,collections
DR=[0,0,1]
def build(w):
    def stpw(ww,c,z,r):
        f=(r<<1)|c|(z<<(ww+1)); return (((f<<1)^(f|(f>>1)))>>1)&((1<<ww)-1)
    ww=min(w,10); S=[np.arange(1<<ww,dtype=np.int64) for _ in range(3)]
    def fix(S,ww):
        while True:
            N=[None]*3
            for p in range(3):
                r=S[p]; c=DR[p]; im=np.unique(np.concatenate([stpw(ww,c,0,r),stpw(ww,c,1,r)])); N[(p+1)%3]=np.intersect1d(im,S[(p+1)%3],assume_unique=True)
            if all(len(N[p])==len(S[p]) for p in range(3)): return N
            S=N
    S=fix(S,ww)
    while ww<w:
        S=[np.sort(np.concatenate([S[p],S[p]|(1<<ww)])) for p in range(3)]; ww+=1; S=fix(S,ww)
    off=[0,len(S[0]),len(S[0])+len(S[1])]; n=sum(map(len,S)); succ=np.zeros((n,2),dtype=np.int64)
    for p in range(3):
        q=(p+1)%3
        for z in (0,1): succ[off[p]:off[p]+len(S[p]),z]=off[q]+np.searchsorted(S[q],stpw(w,DR[p],z,S[p]))
    return S,off,n,succ
def giant(S,off,n,succ):
    # closed giant: forward closure of everything reachable from a window known to be in the giant: take the white-start orbit late
    import scipy.sparse as sp
def largest(n,succ):
    # unique closed component: iterate image of all nodes until stable? use forward closure of a terminal node
    cur=0
    import random
    rng=random.Random(1)
    v=0
    for _ in range(20000): v=int(succ[v,rng.randrange(2)])
    seen=np.zeros(n,bool); seen[v]=True; fr=np.array([v])
    while len(fr):
        nx=np.unique(succ[fr].ravel()); nx=nx[~seen[nx]]; seen[nx]=True; fr=nx
    return seen
for w in map(int,sys.argv[1:]):
    S,off,n,succ=build(w); g=largest(n,succ)
    ph1=np.zeros(n,bool); ph1[off[1]:off[2]]=True
    col1=np.concatenate([s&1 for s in S]).astype(bool)
    # words read at phase 1 of consecutive periods, inside the giant
    cur={'':g&ph1}; counts=[]; forb=[]; allw=set()
    for L in range(1,25):
        nx={}
        for word,A in cur.items():
            for b in (0,1):
                if len(word)>=1 and (word+str(b))[1:] not in prev and L>1: continue
                B=A&(col1==bool(b))
                if not B.any():
                    forb.append(word+str(b)); continue
                idx=np.nonzero(B)[0]
                for _ in range(3):
                    idx=np.unique(succ[idx].ravel())
                C=np.zeros(n,bool); C[idx]=True; nx[word+str(b)]=C
        counts.append(len(nx)); prev=set(nx); cur=nx
        if len(nx)>1500: break
    print('width',w,'giant',int(g.sum()),'of',n,'words by length',counts,'growth per letter (last 4)',round((counts[-1]/counts[-5])**0.25,4),flush=True)
    print('   minimal forbidden words',len(forb),sorted(forb,key=lambda x:(len(x),x))[:30])
