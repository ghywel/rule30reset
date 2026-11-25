#!/usr/bin/env python3
"""Replay the finite-white-tail witness and look for a closed strip around its front."""
from collections import deque
from importlib import import_module

sideways = import_module("periodic-gate-background").sideways


def step(row, wall):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def agrees(row, reference, front):
    site, next_defect = front
    mask = (1 << (site + 1)) - 1
    difference = (1 << (site - 1)) | (next_defect << site)
    return (row ^ reference) & mask == difference


def strip_failure(width, wall, references, schedule, seed):
    """Find a legal local input path leaving the scheduled front, if there is one."""
    mask = (1 << width) - 1
    queue = deque([(1, seed & mask, 0)])
    seen = {(1, seed & mask)}
    while queue:
        phase, row, tick = queue.popleft()
        if not agrees(row, references[phase], schedule[phase]):
            return tick, len(seen)
        next_phase = (phase + 1) % len(wall)
        for outer in (0, 1):
            child = step(row | (outer << width), wall[phase]) & mask
            state = (next_phase, child)
            if state not in seen:
                seen.add(state)
                queue.append((*state, tick + 1))
    return None, len(seen)


def main():
    background = sideways("011")
    wall = [line[0] for line in background]
    references = [sum(line[p] << (p - 1) for p in range(1, 5)) for line in background]
    schedule = [(3, 1), (3, 1), (2, 1), (2, 0), (1, 1), (1, 1), (1, 0), (1, 1), (3, 1)]
    seed = 28  # Sites 1 onward are 00111 followed by white.
    row = seed
    seam = []
    for tick in range(1, 10_001):
        phase = tick % 9
        if not agrees(row, references[phase], schedule[phase]):
            raise AssertionError(f"First physical front failure at tick {tick}, phase {phase}")
        if not wall[phase]:
            assert (row & 1) == (references[phase] & 1)
            if tick <= 9:
                seam.append((phase, row & 1))
        row = step(row, wall[phase])
    print("10,000 ticks replayed on a finite white-tailed half")
    print("Wall:", "".join(map(str, wall)), "white-phase east readings:", seam)
    actual = [(0, 0), (3, 1), (6, 1)]
    print("Target wall: 011011011. White-phase east readings:", actual)
    for width in range(4, 31):
        fail, visited = strip_failure(width, wall, references, schedule, seed)
        if fail is None:
            print(f"Width {width}: closed, {visited} states")
            break
        print(f"Width {width}: first strip failure at step {fail}, {visited} discovered states")


if __name__ == "__main__":
    main()
