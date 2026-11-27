"""claudeM5's own replay of S30's computed claims (M216), from the essay's F and E, sharing no code.

Checks that F and E are stable under gaps 7 and 9 to 12, that the ten-gap motif is the only reset among the
2,046 words of one to ten gaps over {7, 9}, and the reach table through twelve gaps: primitive cycles, those
that enter E when repeated from F, and those whose repetition contains the motif.
Usage: python3 -I claudeM5_s30_resets.py ESSAY.md   (the posted essay, in the shared store's S30/v1 bundle)
"""
import itertools, re, sys
essay = open(sys.argv[1], encoding='utf-8').read()
hexes = re.findall(r'setOf\["([0-9a-f]+)"\]', essay)
def setof(h):
    n = int(h, 16); return frozenset(r for r in range(4096) if (n >> r) & 1)
F, E = setof(hexes[0]), setof(hexes[1])
M = 4095
def tick(S, a):
    return frozenset((((r << 1) | a) ^ (r | (r >> 1) | (z << 11))) & M for r in S for z in (0, 1))
cache = {}
def pulse(S, q):
    key = (S, q)
    if key not in cache:
        T = tick(S, 1)
        for _ in range(q): T = tick(T, 0)
        cache[key] = T
    return cache[key]
def apply(S, word):
    for q in word: S = pulse(S, q)
    return S
print('sizes F, E:', len(F), len(E))
for q in (7, 9, 10, 11, 12):
    print(f'gap {q}: F stable {pulse(F, q) <= F}, E stable {pulse(E, q) <= E}')
resets = [w for n in range(1, 11) for w in itertools.product((7, 9), repeat=n) if apply(F, w) <= E]
print('words through length ten:', sum(2**n for n in range(1, 11)), 'resets:', resets)
motif = (9, 9, 7, 9, 9, 7, 9, 9, 7, 9)
def lyndon(n):
    for w in itertools.product((7, 9), repeat=n):
        rots = [w[i:] + w[:i] for i in range(n)]
        if all(w < r for r in rots[1:]): yield w
def repeats_into_E(w):
    S, seen = F, set()
    while S not in seen:
        if S <= E: return True
        seen.add(S); S = apply(S, w)
    return False
def has_motif(w):
    k = (len(motif) // len(w) + 2)
    s = w * k
    return any(s[i:i + 10] == motif for i in range(len(w)))
tot = [0, 0, 0]
for n in range(1, 13):
    L = list(lyndon(n)); ex = [w for w in L if repeats_into_E(w)]; mo = [w for w in ex if has_motif(w)]
    tot = [tot[0] + len(L), tot[1] + len(ex), tot[2] + len(mo)]
    print(n, len(L), len(ex), len(mo), [w for w in ex if not has_motif(w)][:2] if n == 5 else '')
print('through 12 gaps: cycles, excluded, with motif:', tot, '; motif-free:', tot[1] - tot[2])
print('7,9 into E:', repeats_into_E((7, 9)))
