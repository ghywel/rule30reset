"""claudeIntel's independent check of S28's three finite-support statements (N29). No kit code and no
shared code: the literal Rule 30 rule on finite windows.

Conventions, read from the kit at aaaefdd (`glue`, `altCol`, `drv`, `u`):
- glue L R: site -k is L[k] for k >= 1, site 0 is black, site p >= 1 is R[p]. L[0] and R[0] are unused.
- the centre alternates when it is black at even ticks and white at odd ticks (altCol t = t % 2 == 0).
- u R s: site 1 at the white tick 2s+1 of the right half driven by the alternating centre.

The required west Psi R is computed greedily, depth by depth: L[d] is the bit that keeps the centre alternating
through tick d, given L[1..d-1]. The script asserts that exactly one bit works at every depth (exact death), then
tests the three statements:
1. alternation through T (ticks 0..T inclusive) iff L agrees with Psi R at depths 1..T;
2. some west supported in depths 1..B works through T iff Psi R is white at depths B+1..T (by brute force over
   every west supported in 1..B);
3. Psi R and Psi R' agree at depths 1..T iff u R s = u R' s at every white tick 2s+1 < T.
"""
import itertools
import random


def rule(l, c, r):
    return l ^ (c | r)


def centre_alternates(L, R, T):
    """Ticks 0..T of the physical centre of glue L R, from the light cone of sites -T..T."""
    row = [L[-p] if p < 0 else (1 if p == 0 else R[p]) for p in range(-T - 1, T + 2)]
    off = T + 1                                   # index of site 0
    if row[off] != 1:
        return False
    for t in range(1, T + 1):
        row = [rule(row[i - 1], row[i], row[i + 1]) for i in range(1, len(row) - 1)]
        off -= 1
        if row[off] != (1 if t % 2 == 0 else 0):
            return False
    return True


def required_west(R, T):
    """Psi R at depths 1..T, greedily; asserts exactly one bit works at each depth."""
    L = [0] * (T + 2)
    for d in range(1, T + 1):
        good = []
        for b in (0, 1):
            L[d] = b
            if centre_alternates(L, R, d):
                good.append(b)
        assert len(good) == 1, (d, good)
        L[d] = good[0]
    return L


def gates(R, T):
    """u R s for 2s+1 < T: site 1 at tick 2s+1 of the right half driven by the alternating centre."""
    width = T + 3
    row = [1] + [R[p] for p in range(1, width + 1)]   # row[0] is the forced centre
    out = []
    for t in range(T):
        nxt = [1 if (t + 1) % 2 == 0 else 0]
        nxt += [rule(row[p - 1], row[p], row[p + 1]) for p in range(1, len(row) - 1)]
        row = nxt
        if (t + 1) % 2 == 1 and t + 1 < T:
            out.append(row[1])
    return out


def rand_bits(rng, n):
    return [rng.randint(0, 1) for _ in range(n)]


def main():
    rng = random.Random(28)
    counts = {"exact": 0, "s1": 0, "s1_agree": 0, "s2": 0, "s2_true": 0, "s3": 0, "s3_equal": 0}
    for _ in range(300):
        T = rng.randint(1, 24)
        R = rand_bits(rng, T + 6)
        psi = required_west(R, T)
        counts["exact"] += 1
        # statement 1: random wests, and wests that agree with psi up to a random depth
        for _ in range(12):
            L = rand_bits(rng, T + 2)
            if rng.random() < 0.6:
                k = rng.randint(0, T + 1)
                L[1:k + 1] = psi[1:k + 1]
            agree = all(L[d] == psi[d] for d in range(1, T + 1))
            assert centre_alternates(L, R, T) == agree, (T, R, L)
            counts["s1"] += 1
            counts["s1_agree"] += agree
    for _ in range(150):
        T = rng.randint(1, 12)
        R = rand_bits(rng, T + 6)
        psi = required_west(R, T)
        for B in range(0, T + 1):
            exists = False
            for bits in itertools.product((0, 1), repeat=B):
                L = [0] + list(bits) + [0] * (T + 1 - B)
                if centre_alternates(L, R, T):
                    exists = True
                    break
            white = all(psi[d] == 0 for d in range(B + 1, T + 1))
            assert exists == white, (T, B, R)
            counts["s2"] += 1
            counts["s2_true"] += white
    for _ in range(400):
        T = rng.randint(1, 24)
        R = rand_bits(rng, T + 6)
        R2 = list(R)
        k = rng.randint(1, T + 5)                   # flip one site, so the gate words share a prefix
        R2[k] ^= 1
        if rng.random() < 0.3:
            R2 = rand_bits(rng, T + 6)
        p1, p2 = required_west(R, T), required_west(R2, T)
        same_west = all(p1[d] == p2[d] for d in range(1, T + 1))
        same_gate = gates(R, T) == gates(R2, T)
        assert same_west == same_gate, (T, R, R2)
        counts["s3"] += 1
        counts["s3_equal"] += same_west
    # the census form: distinct required prefixes equal distinct gate words, over every R on sites 1..T+1
    census = []
    for T in range(1, 12):
        wests, gate_words = set(), set()
        for bits in itertools.product((0, 1), repeat=T + 1):
            R = [0] + list(bits) + [0] * 4
            wests.add(tuple(required_west(R, T)[1:T + 1]))
            gate_words.add(tuple(gates(R, T)))
        assert len(wests) == len(gate_words) <= 2 ** (T // 2), (T, len(wests), len(gate_words))
        census.append((T, len(wests), len(gate_words)))
    print(f"exact death: exactly one west bit works at every depth, {counts['exact']} random right halves, T up to 24")
    print(f"1. alternation through T iff agreement with Psi at depths 1..T: {counts['s1']} wests, "
          f"{counts['s1_agree']} of them agreeing")
    print(f"2. a west supported in 1..B works through T iff Psi is white on (B, T]: {counts['s2']} (R, B, T), "
          f"{counts['s2_true']} true, every west supported in 1..B tried")
    print(f"3. equal required prefixes iff equal gates at white ticks below T: {counts['s3']} pairs, "
          f"{counts['s3_equal']} equal")
    print("census (T, distinct required prefixes, distinct gate words) over every right half on sites 1..T+1:")
    print("   " + ", ".join(f"({t}, {a}, {b})" for t, a, b in census))
    print("all checks pass")


if __name__ == "__main__":
    main()
