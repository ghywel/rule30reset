"""Finite seed, scalar replay and exhaustive strip checks for the sharp 29-fold charge."""

from functools import lru_cache

word = (
    "00100100100100100100100100100100100100100010010010010010010010010010010010010010"
)
e = list(map(int, word))
H = len(e) - 1
# Construct the positive and negative neighbors of the driven trace, then keep its finite initial cone.
r = [0] * (H + 2)
f = []
for t, b in enumerate(e):
    f.append(r[0])
    row = [b] + r
    r = [l ^ (c | u) for l, c, u in zip(row, row[1:], row[2:])]
cur, right = e, f
seed = e[0] << H
for distance in range(1, H + 1):
    new = [cur[t + 1] ^ (cur[t] | right[t]) for t in range(len(cur) - 1)]
    seed |= new[0] << (H - distance)
    cur, right = new, cur
black = {i for i in range(seed.bit_length()) if seed >> i & 1}
movie = []
for t in range(H + 1):
    movie.append([int(i in black) for i in (H - 2, H - 1, H)])
    touches = {i + k for i in black for k in (-1, 0, 1)}
    black = {i for i in touches if (i - 1 in black) != (i in black or i + 1 in black)}
assert [z[2] for z in movie] == e
bad = [i for i in range(H - 1) if sum(e[i : i + 3]) != 1]
assert bad == [39]


def bit(q, i):
    return (q >> i) & 1


@lru_cache(None)
def successors(p, w):
    # Scalar cell arrays; no bit-parallel Rule 30 formula used here.
    out = []
    for n in range(1 << w):
        middle = [bit(n, i) for i in range(w)]
        ends = []
        for g in range(2):
            a = [p] + middle + [g]
            nxt = [l ^ (c | r) for l, c, r in zip(a, a[1:], a[2:])]
            ends.append(sum(b << i for i, b in enumerate(nxt)))
        out.append(ends)
    return out


@lru_cache(None)
def test(s, p):
    current = set(range(1 << 12))
    for i in range(28):
        c, r, _ = movie[s + i]
        rn = movie[s + i + 1][1]
        a = int((p + i) % 3 == 2)
        an = int((p + i + 1) % 3 == 2)
        if not r and rn != (c ^ a):
            return False
        nexts = successors(a, 12)
        current = {z for x in current if (r ^ (a | bit(x, 0))) == an for z in nexts[x]}
        if not current:
            return False
    return bool(current)


failed = [
    s
    for s in range(H - 29)
    if not any(all(test(s + i, (p + i) % 3) for i in range(3)) for p in range(3))
]
assert failed == list(range(11, 40))
if __name__ == "__main__":
    print("seed", seed, "target", H, "bad triple", bad, "rejected starts", failed)
