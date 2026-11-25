#!/usr/bin/env python3
"""Test longer physical cones for fronts on the west reconstruction of the 011 gap-3 gate."""
import argparse
from importlib import import_module
import json
from pathlib import Path

background = import_module("periodic-gate-background")
front_cones = import_module("periodic-gate-front-cones")
stall = import_module("periodic-gate-stall")


def max_displacement(edges, width, phases, stride, slabs):
    """Upper bound on eastward displacement over slabs, starting at any front state."""
    best = dict.fromkeys(edges, 0)
    for count in range(1, slabs + 1):
        following = {}
        for state, displacement in best.items():
            phase, site, _ = state
            for shift, bit in edges[state]:
                target = ((phase + stride) % phases, (site + shift) % width, bit)
                travel = displacement + shift
                if target not in following or travel > following[target]:
                    following[target] = travel
        best = following
        if not best or max(best.values()) < 0:
            return count, max(best.values(), default=None)
    return slabs, max(best.values())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("strides", type=int, nargs="+")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    rows = background.sideways("011")
    width, phases = len(rows[0]), len(rows)
    assert (width, phases) == (135, 9)
    for stride in args.strides:
        print(f"Stride {stride} physical ticks", flush=True)
        edges = front_cones.refine(rows, stride)
        print("Max displacement test over 50 slabs:",
              max_displacement(edges, width, phases, stride, 50), flush=True)
        cycle = background.slab_cycle(edges, width, phases, stride)
        if not cycle:
            continue
        data = {"background": rows, "stride": stride, "cycle": cycle}
        (args.output / f"cycle-{stride}.json").write_text(json.dumps(data) + "\n")
        duration = stride * len(cycle)
        for turns in range(1, max(1, 72 // duration) + 1):
            horizon = duration * turns
            witness = args.output / f"front-{stride}-{horizon}.txt"
            witness.unlink(missing_ok=True)
            cnf = args.output / f"front-{stride}-{horizon}.cnf"
            stall.run(data, horizon, cnf, witness)
            if not witness.exists():
                break


if __name__ == "__main__":
    main()
