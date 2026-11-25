"""Certified K84 gate-word lower counts from replayed M181 block witnesses."""
import argparse
from pathlib import Path

from check import extensions, physical, target


def count(orders, length):
    factors = set()
    for order in orders:
        w = target(order)+"1"
        # Each start after sample zero has a preceding black tick on this
        # genuine cone. It can restart a black-first K84 observation there.
        factors.update(w[i:i+length] for i in range(1,len(w)-length+1))
    return len(factors)


if __name__ == "__main__":
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("census",type=Path)
    p.add_argument("extensions",type=Path,nargs="*")
    a=p.parse_args()
    orders=physical(a.census,5)
    for path in a.extensions:
        orders.update(extensions(path,5))
    for length in (35,56,80,100,128,168,196,224,256):
        print(length,count(orders,length),flush=True)
