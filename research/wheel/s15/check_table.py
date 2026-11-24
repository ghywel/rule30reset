#!/usr/bin/env python3
"""check_table.py TABLE.json TRAPCODES: S15's finite checks on the table, outside Lean (ledger M148): the walk of the table
against itself, the ends of the nine lines, the settling line, the five whites and the starts. Then 300 tables with one
bit of one leaf flipped, as a control: a bit that no row can reach is free, the others must fail."""
import json,random,sys
sys.setrecursionlimit(10000); random.seed(1)
D=json.load(open(sys.argv[1])); NL=len(D['leaves'])
trap=set(int(x) for x in open(sys.argv[2]).read().split())
words=[(20,0x12121),(23,0x484842),(26,0x484242),(29,0x12108421),(30,0x24210908),(30,0x24210909),(31,0x10842108),(33,0x21084842),(38,0x212108424)]
off=D['offsets']; last=0
for (n,c),o in zip(words,off): last|=1<<(o+n-1)
def dbl(x):
    y=(x<<1)^(x|(x>>1)); return ((y<<1)|1)^(y|(y>>1))
def verify(leaves):
    lo=list(leaves);hi=list(leaves);kids=[None]*NL
    for a,b in D['branches']: kids.append((a,b)); lo.append(lo[a]&lo[b]); hi.append(hi[a]|hi[b])
    root=len(kids)-1; ch=lambda a,b:a if kids[a] is None else kids[a][b]
    def follow(a,r,k):
        for i in range(k): a=ch(a,(r>>i)&1)
        return a
    def check(col,a,b,k,p,n):
        if ((hi[a]<<1)&col)&~lo[b]==0: return True
        if n==0 or (kids[a] is None and kids[b] is None): return False
        for bit in (0,1):
            q=p+(1<<(k+2)) if bit else p
            if not check(col,ch(a,bit),ch(b,(dbl(q)>>k)&1),k+1,q,n-1): return False
        return True
    for p in range(16):
        o=dbl(p)
        if not check(D['black'] if o&1 else D['white'],follow(root,p,4),follow(root,o,2),2,p,46): return 'steps'
    def ends(a,k,p,n):
        if hi[a]&last==0: return True
        if n==0: return p in trap
        return ends(ch(a,0),k+1,p,n-1) and ends(ch(a,1),k+1,p+(1<<k),n-1)
    if not ends(root,0,0,16): return 'ends'
    if not all(lo[follow(root,x,16)]>>260&1 for x in trap): return 'settle'
    if hi[root]>>272&1: return 'settled'
    if not lo[ch(root,0)]>>273&1 or hi[root]>>277&1: return 'whites'
    if not all(lo[ch(root,c&1)]>>o&1 for (n,c),o in zip(words,off)): return 'starts'
    return 'pass'
print('table:',verify(D['leaves']))
from collections import Counter
c=Counter()
for _ in range(300):
    L=list(D['leaves']); i=random.randrange(NL); b=random.randrange(D['bits']); L[i]^=1<<b; c[verify(L)]+=1
print('one flipped bit, 300 times:',dict(c))
