"""Find initial single flips that change the exit pair while preserving its X window."""
import argparse
import json
from pathlib import Path

from entry_cells import SEEDS, physical_rows
from exit_switch import LAST_X
from replay import step


T = 2*LAST_X + 1
INNER = 2**24 - 1
WINDOW = 2**26 - 1


def known_at(seed, k):
    """Three-valued simulation using the length of the contiguous known prefix.

    The next known prefix always contains the first n-1 sites. Site n is
    also determined exactly when its present value is black (assuming an
    unconstrained next site). The mask implementation in entry_cells.py can
    retain isolated known sites. Here only a contiguous prefix is needed.
    """
    row = seed & (2**k-1)
    for t in range(T):
        if not k:
            return 0, 0
        if not (row >> (k-1)) & 1:
            k -= 1
        row = step(row, 1-t%2) & (2**k-1)
    return k, row


def bound(seed, target):
    lo, hi = 0, T + 26
    while hi-lo > 1:
        mid = (lo+hi)//2
        if known_at(seed, mid)[0] >= 26:
            hi = mid
        else:
            lo = mid
    width, suffix = known_at(seed, hi)
    assert width >= 26 and suffix & WINDOW == target
    return hi


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("out", type=Path)
    args = p.parse_args()
    out = {}
    for seed in SEEDS:
        base = physical_rows(seed)
        target = base[T] & WINDOW
        assert target == 2549074
        hi = bound(seed, target)
        changed = []
        for site in range(1, hi+1):
            row = seed ^ (1 << (site-1))
            for t in range(T):
                row = step(row, 1-t%2)
            local = row & WINDOW
            if local & INNER == target and local != target:
                changed.append([site, local >> 24])
        examples = []
        for pair in (1, 2, 3):
            farthest = max((site for site, value in changed if value == pair), default=None)
            if farthest is None:
                continue
            path = physical_rows(seed ^ (1 << (farthest-1)))
            first24 = next((s for s in range(LAST_X+1)
                            if (path[2*s+1] ^ base[2*s+1]) & INNER), None)
            first_gate = next((s for s in range(LAST_X+1)
                               if (path[2*s+1] ^ base[2*s+1]) & 1), None)
            first26 = next(s for s in range(LAST_X+1)
                           if (path[2*s+1] ^ base[2*s+1]) & WINDOW)
            examples.append([farthest, pair, first24, first26, first_gate])
        out[str(seed)] = {"universal_prefix": hi, "conditional_single_flips": changed,
                          "farthest_per_pair": examples}
        print(seed, hi, len(changed), examples, flush=True)
    args.out.write_text(json.dumps(out, separators=(",", ":"))+"\n", encoding="ascii")


if __name__ == "__main__":
    main()
