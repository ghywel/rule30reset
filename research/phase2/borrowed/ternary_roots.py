"""Check ordered ternary half-step tables against all eight binary neighbourhoods.

The embedded binary symbols are 0 and 2. The first half-step sits on a bond;
the second returns to the original integer lattice.
"""
from itertools import product


def digits(code):
    return tuple(code // (3 ** k) % 3 for k in range(9))


def squares_to_30(table):
    for l, c, r in product((0, 1), repeat=3):
        a = table[6*l + 2*c]
        b = table[6*c + 2*r]
        if table[3*a+b] != 2*(l ^ (c | r)):
            return False
    return True


if __name__ == "__main__":
    roots = [n for n in range(3**9) if squares_to_30(digits(n))]
    print("ordered tables:", 3**9, "embedding: 0,2", "roots:", roots)
    for n in roots:
        t = digits(n)
        print(n, t, "bond codes for 00,01,10,11:", [t[i] for i in (0, 2, 6, 8)])
