"""Integer Bellman certificates for the westward speed of a finite Rule 30 defect.

Find a potential with --make (requires NumPy). Verify a stored potential with
--check (standard library only, independent scalar application of the local rule).
"""
import argparse
from fractions import Fraction
import json
from pathlib import Path


def packed_step(row, west, width):
    return (((row << 1) | west) ^ (row | (row >> 1))) % (1 << width)


def make(width, iterations, scale):
    import numpy as np
    size = 1 << width
    states = np.arange(size * size, dtype=np.int64)
    a, b = states // size, states % size
    active = (a ^ b) % 2
    outcomes = np.empty((4, 4, len(states)), dtype=np.int64)
    for action in range(4):
        for coin in range(4):
            west, far = divmod(coin, 2)
            advance = active * (1 - west)
            def successor(a, east):
                stay = packed_step(a + east * size, west, width)
                fresh = (far ^ (a & 1)) | (packed_step(a, 0, width-1) << 1)
                return np.where(advance, fresh, stay)
            outcomes[action,coin] = successor(a, action//2)*size + successor(b, action%2)
    reward = (2 * scale) * active
    value = np.zeros(len(states), dtype=np.int64)
    for _ in range(iterations):
        future = reward + value[outcomes].sum(axis=1).max(axis=0)
        value = future//4 - (future[0]//4)
    upper = int((reward + value[outcomes].sum(axis=1).max(axis=0) - 4*value).max())
    return {"width": width, "scale": scale, "upper_numerator": upper,
            "upper_denominator": 4*scale, "potential": value.tolist()}


def verify(cert):
    w, scale = cert["width"], cert["scale"]
    potential = cert["potential"]
    size = 1 << w
    assert len(potential) == size*size and scale > 0 and all(isinstance(k,int) for k in potential)
    maximum = None
    for s, v in enumerate(potential):
        a, b = divmod(s,size)
        # Histories known at the record boundary; each action extends the east.
        for east_a in range(2):
            for east_b in range(2):
                total = 0
                for far in range(2):
                    for west in range(2):
                        advance = west == 0 and ((a ^ b) & 1) != 0
                        def successor(code, extension):
                            cells = [far,west] + [(code>>j)&1 for j in range(w)] + [extension]
                            start = 1 if advance else 2
                            return sum((cells[j-1] ^ (cells[j] | cells[j+1])) << (j-start)
                                       for j in range(start,start+w))
                        nxt = successor(a,east_a)*size + successor(b,east_b)
                        total += scale*int(advance) + potential[nxt] - v
                maximum = total if maximum is None else max(total,maximum)
    assert cert["upper_denominator"] == 4*scale and maximum == cert["upper_numerator"]
    return Fraction(maximum,4*scale)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--make", type=int, metavar="WIDTH")
    action.add_argument("--check", action="store_true")
    parser.add_argument("--iterations", type=int, default=256)
    parser.add_argument("--scale", type=int, default=1 << 20)
    parser.add_argument("certificate", type=Path)
    a = parser.parse_args()
    if a.check:
        cert = json.loads(a.certificate.read_bytes())
    else:
        cert = make(a.make, a.iterations, a.scale)
        a.certificate.write_text(json.dumps(cert, separators=(",",":"))+"\n",encoding="ascii")
    bound = verify(cert)
    print(cert["width"], len(cert["potential"]), bound, float(bound))
