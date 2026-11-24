"""Certified entropy intervals from the exact two-column multiplicity histogram.

All interval endpoints use integer arithmetic. The output is in bits, with
decimal lower endpoints rounded down and upper endpoints rounded up.
"""
import argparse
import csv
from collections import defaultdict
from functools import cache


PRECISION = 1 << 68
TERMS = 24
DECIMALS = 12


def ceil_div(a, b):
    return -(-a // b)


def log_ratio(numerator, denominator):
    """Bound PRECISION times ln(numerator/denominator) for a ratio in [1,2]."""
    assert denominator <= numerator <= 2 * denominator
    a, b = numerator-denominator, numerator+denominator
    # 2 atanh(a/b) = 2 sum_j (a/b)^(2j+1)/(2j+1).
    # Carry exact rational numerators and denominators, rounding only the sums.
    lower = upper = 0
    u, v = a, b
    for j in range(TERMS):
        factor = (2*j+1) * v
        lower += 2*PRECISION*u // factor
        upper += ceil_div(2*PRECISION*u, factor)
        u *= a*a
        v *= b*b
    # Since z <= 1/3, omitted terms <= 2 z^(2s+1)/(1-z^2) <= 3^(-2s).
    return lower, upper + ceil_div(PRECISION, 3**(2*TERMS))


LN2 = log_ratio(2, 1)


@cache
def log2_integer(m):
    k = m.bit_length()-1
    scale = 1 << k
    if scale == m:
        return k*PRECISION, k*PRECISION
    low, high = log_ratio(m, scale)
    return (k*PRECISION + PRECISION*low // LN2[1],
            k*PRECISION + ceil_div(PRECISION*high, LN2[0]))


def entropy(n, masses):
    total = 4**n
    assert sum(m*c for m, c in masses) == total
    low = high = 2*n*total*PRECISION
    for m, count in masses:
        a, b = log2_integer(m)
        low -= m*count*b
        high -= m*count*a
    return low // total, ceil_div(high, total)


def decimal(value, up):
    scale = 10**DECIMALS
    units = ceil_div(value*scale, PRECISION) if up else value*scale // PRECISION
    return f"{units//scale}.{units%scale:0{DECIMALS}}"


def report(path):
    groups = defaultdict(list)
    with open(path, newline="", encoding="utf8") as f:
        for row in csv.DictReader(f, delimiter="\t"):
            groups[int(row["n"])].append((int(row["rows_per_word"]), int(row["pair_words"])))
    last_a = last_b = 0
    print("n\tH_low\tH_high\tincrement_low\tincrement_high\tcollision_numerator\tcollision_denominator")
    for n, masses in sorted(groups.items()):
        a, b = entropy(n, masses)
        # The exact collision probability is sum_i (multiplicity_i / 4^n)^2.
        collision = sum(m*m*count for m, count in masses)
        print(n, decimal(a, False), decimal(b, True), decimal(a-last_b, False),
              decimal(b-last_a, True), collision, 16**n, sep="\t", flush=True)
        last_a, last_b = a, b


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("masses")
    report(parser.parse_args().masses)
