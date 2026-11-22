"""Reader's spot check of silver-pell.md's three continued-fraction cases (claudeIntel, for the I123 read).

beta = (a + sqrt(b)) / c with integers; floor(t * beta) is computed exactly with isqrt.
For each slope and each convergent index the claimed agreement interval is checked letter by letter.
"""
from math import isqrt
from fractions import Fraction


def make(a, b, c):
    # floor(t*(a+sqrt b)/c) for t >= 1, exactly (sqrt b irrational)
    def fl(t):
        s = isqrt(b * t * t)          # floor(t sqrt b)
        return (a * t + s) // c if c > 0 else None
    return fl


def convergents(a, b, c, n):
    # continued fraction of (a + sqrt b)/c by exact floor of x = (P + sqrt b)/Q
    P, Q = a, c
    digits = []
    for _ in range(n):
        d = (P + isqrt(b)) // Q if Q > 0 else (P + isqrt(b) + 1) // Q
        digits.append(d)
        P = d * Q - P
        Q = (b - P * P) // Q
    h0, h1, k0, k1 = 0, 1, 1, 0       # numerators/denominators
    out = []
    for d in digits:
        h0, h1 = h1, d * h1 + h0
        k0, k1 = k1, d * k1 + k0
        out.append((h1, k1, d))
    return digits, out                # out[i] = (u_i, d_i, digit_i)


def bit(fl, t):
    return fl(t) % 2


def agrees(fl, lo, hi, lag):
    return all(bit(fl, t) == bit(fl, t + lag) for t in range(lo, hi + 1))


def check(name, a, b, c, n=16):
    fl = make(a, b, c)
    digits, cv = convergents(a, b, c, n)
    print(name, 'digits', digits[:10])
    for i in range(2, n - 1):
        u_, r, _ = cv[i - 1]
        u, d, _ = cv[i]
        U, D, A = cv[i + 1]
        if d < 5:
            continue
        if u % 2 == 0:                                     # case 1, lag d
            assert agrees(fl, 1, D - 1, d), (name, i, 'case 1')
            print(f'  case 1  lag {d}: [1, {D - 1}] agrees')
        if A >= 3:                                         # case 2, lag 2d
            assert agrees(fl, 1, D - d - 1, 2 * d), (name, i, 'case 2')
            print(f'  case 2  lag {2 * d}: [1, {D - d - 1}] agrees')
        if u % 2 == 1 and u_ % 2 == 1 and U % 2 == 1 and A == 2:   # case 3, lag d + r
            lag = d + r
            assert agrees(fl, d + 1, d + D - 1, lag), (name, i, 'case 3 run')
            assert bit(fl, d) != bit(fl, d + lag) and bit(fl, d + D) != bit(fl, d + D + lag), (name, i, 'case 3 flanks')
            print(f'  case 3  lag {lag}: [{d + 1}, {d + D - 1}] agrees, flanks mismatch, later start {d + 1 + lag} = D + 1 = {D + 1}')


check('golden (sqrt5-1)/2', -1, 5, 2)
check('[0;3,3,3,...] (sqrt13-3)/2', -3, 13, 2)
check('silver 2-sqrt2', 2 * 1, 0, 1) if False else None
check('silver 2-sqrt2 = (4 - sqrt 8)/2', 4, 8, 2) if False else None
print('silver: use 2 - sqrt2 = (-sqrt2 + 2); computed via floor(2t - ceil(t sqrt2)) below')
fl = lambda t: 2 * t - (isqrt(2 * t * t) + 1)
for (u_, r), (u, d), (U, D) in [((1, 2), (3, 5), (7, 12)), ((3, 5), (7, 12), (17, 29)), ((7, 12), (17, 29), (41, 70)),
                                 ((17, 29), (41, 70), (99, 169)), ((41, 70), (99, 169), (239, 408))]:
    lag = d + r
    assert agrees(lambda t: fl(t) if t > 0 else 0, d + 1, d + D - 1, lag)
    print(f'  silver case 3 lag {lag}: [{d + 1}, {d + D - 1}] agrees')
print('all spot checks passed')
