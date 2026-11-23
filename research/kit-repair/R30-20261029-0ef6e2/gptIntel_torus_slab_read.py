"""Audit N9's 256-square grid with exact half-open arc membership on all slab boundaries.

This shares the frozen families, the floating-point time bounds and the first-pass
cell enclosure with v2. Only the slab construction and the finite directed-graph
pruning are independent. Coordinates below have common denominator 256.
"""

from functools import cmp_to_key
from itertools import product
from math import inf

import claudeIntel_torus_certificate_v2 as frozen


def sign(a, b, d):
    """Sign of the real embedding of a + b sqrt(d), using integer operations."""
    if b == 0 or a * b >= 0:
        return (a >= 0 and b >= 0) - (a <= 0 and b <= 0)
    norm = a * a - d * b * b
    return (1 if a > 0 else -1) * ((norm > 0) - (norm < 0))


def compare(left, right, d):
    return sign(left[0] - right[0], left[1] - right[1], d)


def endpoints(family, point, d, n):
    a, b = family["eps"]
    zero, minus_eps = (0, 0), (-a, -b)
    lo, hi = (minus_eps, zero) if sign(a, b, d) > 0 else (zero, minus_eps)
    return tuple((n * (u - point["a"]), n * (v - point["b"])) for u, v in (lo, hi))


def cell_value(angle, i, j, target):
    n = frozen.N
    box = (i/n, (i+1)/n, j/n, (j+1)/n)
    first = frozen.v1.f_lo(angle, *box, early=target)
    if first >= target:
        return first, False

    left, right = (i, j), (i+1, j+1)
    boundaries = {left, right}
    records = []
    for family in angle.families:
        classified = []
        for point in frozen.cell_points2(angle, family, *box):
            arc = endpoints(family, point, angle.d, n)
            for edge in arc:
                if compare(edge, left, angle.d) > 0 and compare(edge, right, angle.d) < 0:
                    boundaries.add(edge)
            classified.append((point, arc))
        records.append((family, classified))

    # Every arc is [lo, hi), so its status at a threshold is that of the
    # interval immediately to the right. Include the upper corner separately.
    worst = inf
    for s in sorted(boundaries, key=cmp_to_key(lambda a, b: compare(a, b, angle.d))):
        best = -inf
        for family, points in records:
            fixed, uncertain = [], []
            for point, (lo, hi) in points:
                if compare(lo, s, angle.d) <= 0 and compare(s, hi, angle.d) < 0:
                    (fixed if point["t_in"] else uncertain).append(point)
            if len(uncertain) > frozen.TAU_AMB_MAX:
                continue
            lower = inf
            for selected in product((False, True), repeat=len(uncertain)):
                active = fixed + [p for p, keep in zip(uncertain, selected) if keep]
                lower = min(lower, frozen.runs_bound(family, active))
            best = max(best, lower / family["tauq"])
            if best >= target:
                break
        worst = min(worst, best)
    return max(first, worst), True


def prune(cells, matrix, n):
    (a, b), (c, d) = matrix
    assert a*d - b*c == 1
    offsets = frozen.base.cell_offsets(a, b, c, d)
    sweeps = 0
    while True:
        sweeps += 1
        keep = set()
        for i, j in cells:
            forward = any(((a*i+b*j+h) % n, (c*i+d*j+k) % n) in cells for h, k in offsets)
            backward = any(((d*(i-h)-b*(j-k)) % n, (a*(j-k)-c*(i-h)) % n) in cells
                           for h, k in offsets)
            if forward and backward:
                keep.add((i, j))
        if keep == cells:
            return sweeps, keep
        cells = keep


def main():
    for name, target in (("silver", frozen.C_SILVER + 1e-12), ("golden", frozen.C_GOLD)):
        angle = frozen.base.Angle(name)
        undecided = set()
        exact_slabs = 0
        for i in range(frozen.N):
            for j in range(frozen.N):
                value, used_slabs = cell_value(angle, i, j, target)
                exact_slabs += used_slabs
                if (value <= frozen.C_SILVER if name == "silver" else value < frozen.C_GOLD):
                    undecided.add((i, j))
        print(f"{name}: {frozen.N**2} cells, {exact_slabs} exact-slab passes, "
              f"{len(undecided)} below the acceptance criterion", flush=True)
        if name == "silver":
            sweeps, core = prune(undecided, angle.Dm, frozen.N)
            print(f"silver: {sweeps} sweeps, {sorted(core)}", flush=True)


if __name__ == "__main__":
    main()
