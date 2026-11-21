"""Identify the ether sink and project the two width-24 components using saved SCC memberships."""
import argparse
from pathlib import Path
from struct import iter_unpack

from gptM5_sample import Destinations


def memberships(directory, width):
    data = (directory / f"W{width}.scc").read_bytes()
    if data[:8] != b"K50SCC1\n":
        raise ValueError("Unrecognised SCC certificate")
    words = iter(x[0] for x in iter_unpack("<I", data[8:]))
    if next(words) != width:
        raise ValueError("Width in file differs from its name")
    groups = {}
    for representative in words:
        size = next(words)
        vertices = {next(words) for _ in range(size)}
        if len(vertices) != size or min(vertices) != representative:
            raise ValueError("Inconsistent SCC record")
        groups[representative] = vertices
    return groups


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("--kit", type=Path, default=Path(__file__).resolve().parents[2] / "Rule30PrizeKit")
    args = parser.parse_args()
    dest = Destinations(args.kit)
    groups = {w: memberships(args.directory, w) for w in range(16, 25)}
    for w in range(19, 25):
        sink = groups[w][6809]
        phases = [0, 0, 0, 0]
        for x in sink:
            witness = dest.classify(x & ((1 << 19) - 1), 1)
            if not witness or witness["class"] != "ether" or witness["k"] != 6:
                raise ValueError(f"Width {w} contains a vertex outside the six-column ether family")
            phases[witness["phase"]] += 1
        print(f"W={w} ether sink={len(sink)} phase0={phases[0]} phase2={phases[2]}")
    for representative in (519, 1799):
        for w in (20, 16):
            projections = {x % (1 << w) for x in groups[24][representative]}
            match, = [m for m, vertices in groups[w].items() if projections <= vertices]
            print(f"W24:{representative} -> W{w}:{match} ({len(projections)} different projections)")
    for name, _, _, classes in dest.locks:
        projections = {x % (1 << 24) for x in classes}
        match, = [m for m, vertices in groups[24].items() if projections <= vertices]
        print(f"{name}: {len(classes)} windows project into W24:{match}")


if __name__ == "__main__":
    main()
