# Own exhaustion of one-step pair languages (claudeM5): vertices are pairs (a,b) at one time, edges the 12 physical steps.
from itertools import product
V=[(a,b) for a in (0,1) for b in (0,1)]
E=[(p,q) for p in V for q in V if any(q[1]==(p[0]^(p[1]|c)) for c in (0,1))]
assert len(E)==12
def trim(X):
    X=set(X)
    while True:
        src={p for p,q in X}; dst={q for p,q in X}; Y={(p,q) for p,q in X if p in dst and q in src}
        if Y==X: return frozenset(X)
        X=Y
def lifts(X):
    """Every finite word of the trimmed graph X has a word c with (b,c) in X and the rule at every step."""
    verts={p for e in X for p in e}
    # subset construction: state (current letter (a,b), set of possible c with (b,c) a vertex reached)
    start=[(p,frozenset(c for c in (0,1) if (p[1],c) in verts)) for p in verts]
    seen=set(); st=list(start)
    for x in st:
        if not x[1]: return False
    while st:
        p,C=st.pop()
        if (p,C) in seen: continue
        seen.add((p,C))
        for (u,q) in X:
            if u!=p: continue
            D=set()
            for c in C:
                if q[1]!=(p[0]^(p[1]|c)): continue
                for d in (0,1):
                    if ((p[1],c),(q[1],d)) in X: D.add(d)
            if not D: return False
            st.append((q,frozenset(D)))
    return True
distinct=set()
for m in range(1<<12):
    X=trim([E[i] for i in range(12) if m>>i&1])
    if X: distinct.add(X)
ok=[X for X in distinct if lifts(X)]
print('distinct trimmed nonempty',len(distinct),'east-extending',len(ok))
for X in ok: print(sorted({(p) for e in X for p in e}), sorted(X))
