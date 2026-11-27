"""K92.4, claudeM5: an upper bound on the forcing prefix at large widths, by three-valued evolution.

As claudeM5_forcing_prefix.py, but each free cell is just "unknown": OR is known when one side is black or both are
white, XOR when both sides are known. A forced verdict here is a true one; cancellations between unknowns are
missed, so rK(l, k) >= rmin(l, k). Bit-parallel over the row, so widths in the thousands are cheap.
The 16 settled ages k = P(l) .. P(l) + 15 are tested for each width.
Usage: python3 -I claudeM5_forcing_front.py [EXACT.json] l1 l2 ...
"""
import json, sys

def edge(J, T):
    mask = (1 << J) - 1
    A, h = 1, []
    for _ in range(T + 1):
        h.append(A); A = ((A << 2) ^ ((A << 1) | A)) & mask
    return h

def forced3(l, word, r):
    """Sites -l..l are bits 0..2l. West white; context cells 0..r-1 known from word; r..l unknown."""
    full = (1 << (2 * l + 1)) - 1
    V = (word & ((1 << r) - 1)) << l
    U = (((1 << (l + 1)) - 1) ^ ((1 << r) - 1)) << l
    for _ in range(l):
        Lv, Lu = (V << 1) & full, (U << 1) & full
        Rv, Ru = V >> 1, U >> 1
        one = V | Rv
        zero = ~(V | U) & ~(Rv | Ru) & full
        ou = ~(one | zero) & full
        U = Lu | ou
        V = (Lv ^ one) & ~U & full
    return not (U >> l) & 1, (V >> l) & 1

def rK(l, word):
    a, b = 0, l + 1
    if forced3(l, word, 0)[0]: return 0
    while b - a > 1:
        m = (a + b) // 2
        if forced3(l, word, m)[0]: b = m
        else: a = m
    return b

def main():
    args = sys.argv[1:]
    exact = None
    if args and args[0].endswith('.json'):
        exact = json.load(open(args[0]))['rmin']; args = args[1:]
    ls = [int(x) for x in args]
    J = max(ls) + 1; T = 3 * J + 4096
    h = edge(J, T)
    assert h[T - 16] == h[T]
    F = [0] * J; left = (1 << J) - 1
    for t in range(T - 16, -1, -1):
        new = (h[t] ^ h[t + 16]) & left
        while new:
            b = new & -new; F[b.bit_length() - 1] = t + 1; new ^= b; left ^= b
        if not left: break
    P = []; m = 0
    for j in range(J): m = max(m, F[j]); P.append(m)
    if exact:
        worse = same = 0
        for l, row in exact.items():
            l = int(l)
            for k, v in row.items():
                r3 = rK(l, h[int(k)] & ((1 << (l + 1)) - 1))
                assert r3 >= v['rmin'] or not v['exact']
                same += r3 == v['rmin']; worse += r3 > v['rmin']
        print('against the exact table: equal', same, ', three-valued larger', worse)
    for l in ls:
        mask = (1 << (l + 1)) - 1
        rs = []
        for k in range(P[l], P[l] + 16):
            r = rK(l, h[k] & mask)
            ok, v = forced3(l, h[k] & mask, r)
            assert ok and v == (h[k + l] >> l) & 1
            rs.append(r)
        print(f'l {l:5d}: F(l) {F[l]}, rK over the 16 settled ages: least {min(rs)}, greatest {max(rs)}, mean {sum(rs)/16:.1f}, mean/l {sum(rs)/16/l:.3f}', flush=True)

if __name__ == '__main__':
    main()
