"""S30 review block (claudeIntel): how far does Galindo's passage from F into E reach among 7/9 clocks?

An independent implementation (numpy, written from the kit's definitions; no code shared with seven_nine.py) of
the width-12 strip of Rule30StripCertificates: a state r < 4096 holds sites 1..12 (bit k is site k+1), the
centre letter a is the left boundary and the right boundary z is free, so
    stripStep(a, z, r) = (((r << 1) | a) ^ (r | (r >> 1) | (z << 11))) mod 4096
and the image of a set takes both z. F and E are read from the kit's Rule30Certificates/MixedGapClocks.lean.

1. Replays gptIntel's reset: the image of F along blocks(9,9,7,9,9,7,9,9,7,9), one tick at a time, against the
   94 masks the Lean source checks (their sizes), and its inclusion in E.
2. For every cyclic word of gaps from {7, 9} with at most N gaps (one rotation per necklace class, primitive
   words only), repeats the word from F: since F is stable under every safe gap the sets decrease, and the
   word is excluded by Galindo's ranking as soon as one of them lies in E (some rotation suffices, since the
   onset is free). Reports how many necklaces are excluded, how many contain the motif cyclically, and the
   shortest excluded necklaces that do not contain it.

Usage: python -I claudeIntel_s30_reach.py MixedGapClocks.lean masks.txt N out.json
"""
import itertools
import json
import re
import sys

import numpy as np

K = 12
N_STATES = 1 << K
MOTIF = (9, 9, 7, 9, 9, 7, 9, 9, 7, 9)


def read_set(src, name):
    m = re.search(r"def " + name + r" : Nat := 0x([0-9a-f]+)", src)
    v = int(m.group(1), 16)
    return np.array([(v >> i) & 1 for i in range(N_STATES)], dtype=bool)


r = np.arange(N_STATES, dtype=np.int64)
SUCC = {(a, z): (((r << 1) | a) ^ (r | (r >> 1) | (z << (K - 1)))) % N_STATES for a in (0, 1) for z in (0, 1)}


def image(a, S):
    out = np.zeros(N_STATES, dtype=bool)
    for z in (0, 1):
        out[SUCC[(a, z)][S]] = True
    return out


def letters(gaps):
    for q in gaps:
        yield 1
        for _ in range(q):
            yield 0


def apply(gaps, S):
    for a in letters(gaps):
        S = image(a, S)
    return S


def necklaces(n):
    """Lexicographically least rotation of each primitive cyclic word over (7, 9) of length n."""
    seen = set()
    for w in itertools.product((7, 9), repeat=n):
        rots = [w[i:] + w[:i] for i in range(n)]
        least = min(rots)
        if least in seen:
            continue
        seen.add(least)
        if len(set(rots)) == n:
            yield least


def contains_motif_cyclically(w):
    m = len(MOTIF)
    ext = w * ((m // len(w)) + 2)
    return any(tuple(ext[i:i + m]) == MOTIF for i in range(len(w)))


def excluded(w, F, E):
    for i in range(len(w)):
        rot = w[i:] + w[:i]
        S = F.copy()
        while True:
            if not (S & ~E).any():
                return True
            T = apply(rot, S)
            if (T == S).all():
                break
            S = T
    return False


def main():
    src = open(sys.argv[1], encoding="utf-8").read()
    F, E = read_set(src, "F"), read_set(src, "E")
    lean_sizes = [bin(int(l.strip().rstrip(","), 16)).count("1")
                  for l in open(sys.argv[2], encoding="utf-8") if l.startswith("0x")]
    nmax, outp = int(sys.argv[3]), sys.argv[4]
    sizes, S = [], F.copy()
    for a in letters(MOTIF):
        S = image(a, S)
        sizes.append(int(S.sum()))
    res = {"F": int(F.sum()), "E": int(E.sum()), "motif_sizes_match_lean": sizes == lean_sizes,
           "motif_final_in_E": bool(not (S & ~E).any()), "motif_final_size": sizes[-1], "by_length": []}
    print(json.dumps({k: v for k, v in res.items() if k != "by_length"}), flush=True)
    for n in range(1, nmax + 1):
        total = exc = with_motif = exc_without = 0
        examples = []
        for w in necklaces(n):
            total += 1
            has = contains_motif_cyclically(w)
            ex = excluded(w, F, E)
            with_motif += has
            exc += ex
            if ex and not has:
                exc_without += 1
                if len(examples) < 5:
                    examples.append(list(w))
            assert not has or ex, w
        row = {"gaps": n, "primitive_necklaces": total, "excluded": exc, "containing_motif": with_motif,
               "excluded_without_motif": exc_without, "examples_without_motif": examples}
        res["by_length"].append(row)
        print(json.dumps(row), flush=True)
        open(outp, "w", encoding="ascii", newline="\n").write(json.dumps(res, indent=1) + "\n")


if __name__ == "__main__":
    main()
