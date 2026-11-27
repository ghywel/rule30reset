"""claudeM5's replay of S31's computed claims (M217), sharing no code with the essay or claudeIntel's scripts.

The 13-cell strip with a memory of three gaps: warm-up sizes, lasting nodes, and the nontrivial strongly connected
parts; the clean primitive cycles through twelve gaps, those containing S30's ten-gap motif, and the growth rate of
clean words. Usage: python3 -I claudeM5_s31_replay.py
"""
import itertools, sys
import numpy as np
K = 13; N = 1 << K; M = N - 1
def tick_set(S, a):
    out = set()
    for r in S:
        base = ((r << 1) | a)
        for z in (0, 1):
            out.add((base ^ (r | (r >> 1) | (z << (K - 1)))) & M)
    return out
bcache = {}
def block_one(q, r):
    key = (q, r)
    if key not in bcache:
        S = tick_set({r}, 1)
        for _ in range(q): S = tick_set(S, 0)
        bcache[key] = frozenset(S)
    return bcache[key]
def block(q, S):
    out = set()
    for r in S: out |= block_one(q, r)
    return out
mems = [m for m in itertools.product((7, 9), repeat=3) if m != (7, 7, 7)]
def allowed(m, q):
    w = m + (q,)
    return w[1:] != (7, 7, 7) and w != (7, 9, 7, 9)
W = {m: set(range(N)) for m in mems}
sizes = [sum(len(v) for v in W.values())]
for _ in range(15):
    new = {m: set() for m in mems}
    for m in mems:
        for q in (7, 9):
            if allowed(m, q):
                new[m[1:] + (q,)] |= block(q, W[m])
    W = new; sizes.append(sum(len(v) for v in W.values()))
print('node counts by round:', sizes)
nodes = [(x, m) for m in mems for x in sorted(W[m])]
idx = {v: i for i, v in enumerate(nodes)}
succ = [[idx[(y, m[1:] + (q,))] for q in (7, 9) if allowed(m, q) for y in block_one(q, x)] for (x, m) in nodes]
assert all(all(0 <= j < len(nodes) for j in s) for s in succ)
sys.setrecursionlimit(100000)
# Tarjan, iterative
index = [None] * len(nodes); low = [0] * len(nodes); onst = [False] * len(nodes); st = []; comps = []; c = 0
for s0 in range(len(nodes)):
    if index[s0] is not None: continue
    work = [(s0, 0)]; index[s0] = low[s0] = c; c += 1; st.append(s0); onst[s0] = True
    while work:
        v, i = work[-1]
        if i < len(succ[v]):
            work[-1] = (v, i + 1); w = succ[v][i]
            if index[w] is None:
                index[w] = low[w] = c; c += 1; st.append(w); onst[w] = True; work.append((w, 0))
            elif onst[w]: low[v] = min(low[v], index[w])
        else:
            work.pop()
            if work: low[work[-1][0]] = min(low[work[-1][0]], low[v])
            if low[v] == index[v]:
                comp = []
                while True:
                    w = st.pop(); onst[w] = False; comp.append(w)
                    if w == v: break
                comps.append(comp)
parts = sorted((len(cp) for cp in comps if len(cp) > 1 or cp[0] in succ[cp[0]]), reverse=True)
print('lasting nodes:', len(nodes), 'parts:', parts)
def clean(w):
    n = len(w)
    return not any(tuple(w[(i + j) % n] for j in range(3)) == (7, 7, 7) or tuple(w[(i + j) % n] for j in range(4)) == (7, 9, 7, 9) for i in range(n))
def lyndon(n):
    for w in itertools.product((7, 9), repeat=n):
        if all(w < w[i:] + w[:i] for i in range(1, n)): yield w
motif = (9, 9, 7, 9, 9, 7, 9, 9, 7, 9)
def has_motif(w):
    s = w * (len(motif) // len(w) + 2)
    return any(s[i:i + 10] == motif for i in range(len(w)))
tot = cl = mo = 0
for n in range(1, 13):
    L = list(lyndon(n)); C = [w for w in L if clean(w)]
    tot += len(L); cl += len(C); mo += sum(has_motif(w) for w in C)
print('through 12 gaps: cycles', tot, 'clean', cl, 'clean with the motif', mo, 'pure nine counted once; new:', cl - mo - 1)
# growth: transfer matrix on the last three gaps
st3 = [m for m in itertools.product((7, 9), repeat=3) if m != (7, 7, 7)]
T = np.zeros((len(st3), len(st3)))
for i, m in enumerate(st3):
    for q in (7, 9):
        if allowed(m, q): T[i, st3.index(m[1:] + (q,))] = 1
print('growth factor of clean words:', round(max(abs(np.linalg.eigvals(T))), 4))
