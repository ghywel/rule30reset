"""Build or replay a sparse cylinder refutation for M9's four-run word.

A record forbids one low-bit spatial prefix at a single sample. Its justification
uses the next sample, the previous sample, or both one-bit extensions at the
same sample. The reader checks records in order and never performs the search.
"""
import argparse
from functools import cache
import lzma
from pathlib import Path
import struct

import numpy as np

from gptIntel_word_lift import allowed, successors, trap_codes


HEADER = b"M9C1"
RECORD = struct.Struct("<BBBBQ")
NEXT, PREVIOUS, SPLIT = range(3)
ROOT = 49


def samples(delay):
    values = [None] * delay + [1]
    for gap in "3" + "55553" * 4:
        values += [0] * (int(gap) - 1) + [1]
    return values


def step(row, left):
    return ((row << 1) | left) ^ (row | (row >> 1))


def following(width, target, code):
    mask = (1 << target) - 1
    return {step(step(code | (e << width), 0), 1) & mask
            for e in range(1 << max(0, target + 2 - width))}


def invert_step(code, width, left):
    # Given the two high input bits, output j gives input j-1 by left permutivity.
    for pair in range(4):
        row = pair << (width - 1)
        for j in range(width - 1, 0, -1):
            bit = ((code >> j) ^ ((row >> j) | (row >> (j + 1)))) & 1
            row |= bit << (j - 1)
        if (step(row, left) ^ code) & 1 == 0:
            yield row


@cache
def preceding(width, target, code):
    # A target no wider than width+2 only reads bits already reconstructed here.
    mask = (1 << target) - 1
    return {row & mask for mid in invert_step(code, width, 1)
            for row in invert_step(mid, width + 1, 0)}


class Evidence:
    def __init__(self, codes, delay):
        self.trap = set(map(int, codes))
        self.colours = samples(delay)
        self.bans = [{} for _ in self.colours]

    def base_ban(self, t, code):
        colour = self.colours[t]
        return (code & 65535) not in self.trap or (colour is not None and code & 1 != colour)

    def covers(self, t, width, code):
        if self.base_ban(t, code):
            return True
        return any(w <= width and (code & ((1 << w) - 1)) in xs
                   for w, xs in self.bans[t].items())

    def record(self, data):
        t, width, kind, target, code = data
        if not (0 <= t < len(self.colours) and 16 <= width <= 46 and code < 1 << width):
            raise ValueError(f"invalid cylinder {data}")
        if kind == SPLIT:
            if target != width + 1 or target > 46:
                raise ValueError(f"invalid split {data}")
            other, cases = t, (code, code | (1 << width))
        else:
            if not (16 <= target <= 46 and abs(target - width) <= 2):
                raise ValueError(f"invalid neighbouring width {data}")
            if kind == NEXT and t + 1 < len(self.colours):
                other, cases = t + 1, following(width, target, code)
            elif kind == PREVIOUS and t > 0:
                other, cases = t - 1, preceding(width, target, code)
            else:
                raise ValueError(f"invalid neighbour {data}")
        if not all(self.covers(other, target, x) for x in cases):
            raise ValueError(f"unjustified cylinder {data}")
        self.bans[t].setdefault(width, set()).add(code)

    def closed(self):
        return all(self.covers(ROOT, 16, x) for x in self.trap)


def verify(path, codes, delay):
    data = lzma.decompress(path.read_bytes())
    if data[:4] != HEADER or (len(data) - 4) % RECORD.size:
        raise ValueError("invalid M9 record stream")
    evidence = Evidence(codes, delay)
    counts = [0, 0, 0]
    for record in RECORD.iter_unpack(data[4:]):
        evidence.record(record)
        counts[record[2]] += 1
    if not evidence.closed():
        raise ValueError("the middle sample still has an uncovered trap code")
    return counts


def snapshots(codes):
    word = samples(2)
    widths = [16] * len(word)
    layers = [codes if bit is None else codes[(codes & 1) == bit] for bit in word]
    history = []
    while True:
        front = list(layers)
        for t in range(1, len(front)):
            images = np.unique(np.concatenate(list(successors(front[t-1], widths[t-1], widths[t]))))
            front[t] = front[t][allowed(images, front[t])]
        back = list(front)
        for t in reversed(range(len(back) - 1)):
            supported = np.zeros(len(back[t]), dtype=bool)
            for image in successors(back[t], widths[t], widths[t+1]):
                supported |= allowed(back[t+1], image)
            back[t] = back[t][supported]
        history.append((widths, [set(map(int, xs)) for xs in front],
                        [set(map(int, xs)) for xs in back]))
        if any(not len(xs) for xs in back):
            return history
        new = [w + int(w < 46 and len(xs) <= 256) for w, xs in zip(widths, back)]
        for t in range(1, len(new)):
            new[t] = min(new[t], new[t-1] + 2)
        for t in reversed(range(len(new) - 1)):
            new[t] = min(new[t], new[t+1] + 2)
        if new == widths:
            raise ValueError("a path survived the width schedule")
        layers = [np.concatenate((xs, xs | (1 << w))) if v > w else xs
                  for xs, w, v in zip(back, widths, new)]
        widths = new


def build(path, codes):
    history = snapshots(codes)
    records = bytearray(HEADER)
    evidence = Evidence(codes, 2)

    def emit(t, w, kind, target, x):
        row = t, w, kind, target, x
        evidence.record(row)
        records.extend(RECORD.pack(*row))

    def justify(k, t, code):
        w = history[k][0][t]
        if evidence.covers(t, w, code):
            return
        while k > 0:
            previous, _, back = history[k-1]
            prefix = code & ((1 << previous[t]) - 1)
            if prefix in back[t]:
                break
            k, code, w = k - 1, prefix, previous[t]
        if evidence.covers(t, w, code):
            return
        widths, front, back = history[k]
        if code in back[t]:
            raise ValueError("the search retained a requested exclusion")
        if code in front[t]:
            kind, other, cases = NEXT, t+1, following
        else:
            kind, other, cases = PREVIOUS, t-1, preceding
        target = widths[other]
        for child in sorted(cases(w, target, code)):
            justify(k, other, child)
        emit(t, w, kind, target, code)

    def close_prefix(k, w, x):
        if evidence.covers(ROOT, w, x):
            return
        while k < len(history) and history[k][0][ROOT] <= w:
            widths, _, back = history[k]
            low = x & ((1 << widths[ROOT]) - 1)
            if low not in back[ROOT]:
                justify(k, ROOT, low)
                return
            k += 1
        if w >= 46:
            raise ValueError("uncovered middle prefix")
        close_prefix(k, w+1, x)
        close_prefix(k, w+1, x | (1 << w))
        emit(ROOT, w, SPLIT, w+1, x)

    for code in sorted(evidence.trap):
        close_prefix(0, 16, code)
    if not evidence.closed():
        raise ValueError("incomplete generated refutation")
    path.write_bytes(lzma.compress(records, preset=9))


def main():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("command", choices=("build", "verify"))
    cli.add_argument("kit", type=Path, help="the official Lean source defining trapCodes")
    cli.add_argument("certificate", type=Path)
    cli.add_argument("--delay", type=int, choices=(1, 2), default=2, help="delay 1 is a rejection control")
    args = cli.parse_args()
    codes = trap_codes(args.kit)
    if args.command == "build":
        if args.delay != 2:
            cli.error("the generator targets delay 2")
        build(args.certificate, codes)
    a, b, c = verify(args.certificate, codes, args.delay)
    print(f"VERIFIED: {a} successor, {b} predecessor, {c} split records; {args.certificate.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
