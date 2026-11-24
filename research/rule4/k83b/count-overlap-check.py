"""Verify the overlap graph's positive weights with an independent sideways language.

Usage: python count-overlap-check.py r upper_numerator denominator certificate.tsv
"""
import argparse
import csv


def language(length):
    east = [[0, 1]]
    for n in range(1, length):
        half = 1 << (n-1)
        new = [[] for _ in range(2*half)]
        for g in range(2*half):
            for masked in {g | h for h in east[g % half]}:
                west = (g >> 1) ^ masked
                new[west].append(g)
                new[west ^ half].append(g | (2*half))
        east = new
    return east


def check(r, numerator, denominator, path):
    with open(path, newline="", encoding="utf8") as f:
        weights = {}
        for row in csv.DictReader(f, delimiter="\t"):
            code, weight = int(row["vertex"]), int(row["weight"])
            assert code not in weights and weight > 0
            weights[code] = weight
    high = 1 << r
    mask = high-1
    following = dict.fromkeys(weights, 0)
    edges = 0
    for west, gates in enumerate(language(r+1)):
        assert len(gates) == len(set(gates))
        for gate in gates:
            source = (west << r) | (gate & mask)
            # The two western choices at the last tick produce two edges.
            low_target = ((west >> 1) << r) | (gate >> 1)
            high_target = low_target | (high << (r-1))
            following[source] += weights[low_target] + weights[high_target]
            edges += 2
    for vertex, total in following.items():
        assert 0 < total*denominator <= weights[vertex]*numerator
    print(f"PASS {len(weights)} vertices, {edges} physical edges, "
          f"all positive weights satisfy Av <= ({numerator}/{denominator})v")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("r", type=int)
    parser.add_argument("numerator", type=int)
    parser.add_argument("denominator", type=int)
    parser.add_argument("weights")
    args=parser.parse_args()
    check(args.r, args.numerator, args.denominator, args.weights)
