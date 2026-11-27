"""Count singleton falls in dyadic shells and test the finite-strip relaxation."""
import argparse
from hashlib import sha256
from itertools import product
from pathlib import Path

import networkx as nx
import numpy as np


def shell_counts(trace, starts):
    stops = trace[:-1] & ~trace[1:]
    if starts is not None:
        assert np.array_equal(stops, starts)
    for m in range((len(trace) - 1).bit_length() - 1):
        lo = 1 << m
        counts = [int(stops[lo + (r-lo) % 3:2*lo:3].sum()) for r in range(3)]
        yield m, *counts, sorted(counts)[1]


def trace_probe(path):
    raw = path.read_bytes()
    assert sha256(raw).hexdigest() == 'a9989ed73021c2e7d945eca5a1eefa971cc573f8a25d5803facb8aac0897466f'
    obs = np.frombuffer(raw, dtype='<u4')[:(1 << 22) + 1]
    center = (obs & 1) != 0
    west = ((obs >> 1) & 1023) == 1
    for word in ('001', '011'):
        control = np.array([word[i % 3] == '1' for i in range(1025)])
        assert all(row[-1] == 0 for row in shell_counts(control, None))
    print('m,f0,f1,f2,D')
    for row in shell_counts(center, (center & west)[:-1]):
        print(*row, sep=',')


def transitions(width):
    mask = (1 << width) - 1
    for row in range(mask + 1):
        for west, east in product(range(2), repeat=2):
            left = (row << 1) | west
            right = (row >> 1) | (east << (width - 1))
            nxt = (left ^ (row | right)) & mask
            yield row, nxt, row & ~nxt


def active_columns(width, phases, steps):
    graph = nx.DiGraph()
    for tick in range(3):
        allowed = sum(1 << j for j, phase in enumerate(phases) if phase == tick)
        for old, new, falls in steps:
            if falls & ~allowed == 0:
                graph.add_edge((tick, old), ((tick + 1) % 3, new))
    active = 0
    for nodes in nx.strongly_connected_components(graph):
        if len(nodes) == 1:
            continue
        first = next(iter(nodes))[1]
        for _, row in nodes:
            active |= first ^ row
    return active


def strip_probe():
    print('width,independent phase assignments with centre activity,total assignments,common phase active-mask')
    for width in range(2, 7):
        steps = list(transitions(width))
        center = 1 << (width // 2)
        counts = 0
        # Global rotation fixes the phase at the westernmost site to zero.
        for rest in product(range(3), repeat=width - 1):
            phases = (0, *rest)
            active = active_columns(width, phases, steps)
            counts += bool(center & active)
            if not any(rest):
                uniform = active
        print(width, counts, 3 ** (width - 1), format(uniform, f'0{width}b'), sep=',')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('observations', type=Path)
    trace_probe(parser.parse_args().observations)
    strip_probe()
