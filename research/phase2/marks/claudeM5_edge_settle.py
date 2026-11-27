"""K92.4, claudeM5: when does each left diagonal of the seed settle?

D j t = cell t (j - t). In these coordinates the left edge is autonomous:
    D j (t+1) = D (j-2) t  XOR  (D (j-1) t  OR  D j t),
so the first J diagonals are a J-bit state A(t) with A(t+1) = (A << 2) ^ ((A << 1) | A), cut to J bits, A(0) = 1.
The kit proves that the eventual period of D j divides 2^whiteCount(j), which is 16 for 399 <= j < 53,207.

F(j) is the first tick from which D j has period 16. The prefix 0..j is periodic for ever once it agrees with itself
16 ticks later, so F is exact when the last tested tick shows no difference.
Usage: python3 -I claudeM5_edge_settle.py J [OUT.json]
"""
import json, sys

def run(J, T):
    mask = (1 << J) - 1
    A, hist = 1, []
    for _ in range(T + 1):
        hist.append(A)
        A = ((A << 2) ^ ((A << 1) | A)) & mask
    return hist

def main():
    J = int(sys.argv[1]); T = 4 * J + 4096
    hist = run(J, T)
    left = (1 << J) - 1
    F = [0] * J
    assert (hist[T - 16] ^ hist[T]) == 0, 'not settled by the horizon'
    for t in range(T - 16, -1, -1):
        new = (hist[t] ^ hist[t + 16]) & left
        while new:
            b = new & -new; j = b.bit_length() - 1
            F[j] = t + 1; new ^= b; left ^= b
        if not left: break
    white = [j for j in range(J) if all(not (hist[T - i] >> j) & 1 for i in range(16))]
    per = []
    for j in range(J):
        s = [(hist[T - 16 + i] >> j) & 1 for i in range(16)]
        p = next(p for p in (1, 2, 4, 8, 16) if all(s[i] == s[(i + p) % 16] for i in range(16)))
        per.append(p)
    P = [0] * J; m = 0
    for j in range(J): m = max(m, F[j]); P[j] = m          # the prefix 0..j is settled from P[j]
    print('J', J, 'horizon', T)
    print('eventually white diagonals:', white)
    print('first diagonal of each period:', {p: per.index(p) for p in (1, 2, 4, 8, 16) if p in per})
    print('F(j) for j = 0..24:', F[:25])
    for j in (8, 16, 32, 64, 128, 256, 512, 1000, 2000, 4000, 8000):
        if j < J: print(f'j {j}: F {F[j]}, F/j {F[j]/j:.3f}, prefix settled from {P[j]}')
    lo = min(range(8, J), key=lambda j: F[j] - j)
    print('least F(j) - j for j >= 8:', F[lo] - lo, 'at j =', lo, '; j with F(j) <= j:', [j for j in range(J) if F[j] <= j][:20])
    r = [F[j] / j for j in range(1000, J)] if J > 1000 else []
    if r: print('F/j over 1000 <= j <', J, ': min', round(min(r), 3), 'max', round(max(r), 3))
    if len(sys.argv) > 2:
        json.dump({'J': J, 'horizon': T, 'F': F, 'white': white, 'period': per}, open(sys.argv[2], 'w'))

if __name__ == '__main__':
    main()
