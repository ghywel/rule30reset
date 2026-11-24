"""The one-tick decoder (claudeIntel): the least present prefix that fixes the old wall, by brute force over all old rows."""
from itertools import product
from fractions import Fraction as F
from collections import defaultdict

def decide(n):
    """for each present prefix y_1..y_n, the set of old walls u_0 over all old u_0..u_{n+1}"""
    d = defaultdict(set)
    for u in product((0, 1), repeat=n + 2):
        y = tuple(u[i - 1] ^ (u[i] | u[i + 1]) for i in range(1, n + 1))
        d[y].add(u[0])
    return d

dist = {}; decided = set(); rule_ok = True
for n in range(1, 15):
    d = decide(n)
    assert len(d) == 2 ** n
    new = [y for y in d if len(d[y]) == 1 and not any(y[:k] in decided for k in range(1, n))]
    for y in new: decided.add(y)
    dist[n] = len(new)
    # the run rule: virtual zero before y_2; first zero closing a run of ones of length 1 mod 3
    for y in product((0, 1), repeat=n):
        run = 0; R = None
        for k in range(2, n + 1):
            if y[k - 1]: run += 1
            else:
                if run % 3 == 1: R = k; break
                run = 0
        dec = any(y[:k] in decided for k in range(1, n + 1))
        if (R is not None) != dec: rule_ok = False
print('first decisions by length', dist, 'run rule agrees', rule_ok)
# generating function t^3/(4-2t-t^3): coefficients c_n with c_n = (2c_{n-1}+c_{n-3})/4 , t^3 term 1/4
c = {3: F(1, 4)}
for n in range(4, 15): c[n] = (2 * c.get(n - 1, 0) + c.get(n - 3, 0)) / 4
print('matches the generating function', all(F(dist[n], 2 ** n) == c[n] for n in range(3, 15)))
unres = {n: 2 ** n - sum(dist[k] * 2 ** (n - k) for k in range(1, n + 1)) for n in range(0, 15)}
print('unresolved counts', unres, 'recurrence', all(unres[n] == unres[n - 1] + 2 * unres[n - 3] for n in range(3, 15)))
