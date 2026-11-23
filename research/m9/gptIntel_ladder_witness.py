"""Test the four-run word with the two independent exterior bits of the kit's LiftPath."""
import argparse

import numpy as np

from gptIntel_word_lift import allowed, successors, tick, trap_codes
from gptIntel_refutation_core import samples


def images(rows, old, new, width):
    if new < width:
        yield from successors(rows, old, new)
        return
    mask = (1 << width) - 1
    for extra in range(1 << (width + 1 - old)):
        mid = tick(rows | (extra << old), 0) & mask
        for second in (0, 1):
            yield tick(mid | (second << width), 1) & mask


def run(codes, width, delay):
    word = samples(delay)
    layers = [codes if bit is None else codes[(codes & 1) == bit] for bit in word]
    widths = [16] * len(word)
    while True:
        for t in range(len(word) - 1):
            dest = np.unique(np.concatenate(list(images(layers[t], *widths[t:t+2], width))))
            layers[t+1] = layers[t+1][allowed(dest, layers[t+1])]
            if not len(layers[t+1]):
                return None
        for t in reversed(range(len(word) - 1)):
            good = np.zeros(len(layers[t]), dtype=bool)
            for dest in images(layers[t], *widths[t:t+2], width):
                good |= allowed(layers[t+1], dest)
            layers[t] = layers[t][good]
        if min(widths) == width:
            first = int(layers[0][0])
            row = np.array([first], dtype=np.int64)
            choices = []
            for dest in layers[1:]:
                for choice, image in enumerate(images(row, width, width, width)):
                    if allowed(dest, image)[0]:
                        row = image
                        choices.append(choice)
                        break
                else:
                    raise RuntimeError("disconnected witness")
            return first, choices
        new = [w + int(w < width and len(xs) <= 65536) for w, xs in zip(widths, layers)]
        for t in range(1, len(new)):
            new[t] = min(new[t], new[t-1] + 2)
        for t in reversed(range(len(new) - 1)):
            new[t] = min(new[t], new[t+1] + 2)
        if new == widths:
            raise ValueError("inconclusive at the selected per-slice precision")
        for t, (w, v) in enumerate(zip(widths, new)):
            if w < v:
                layers[t] = np.concatenate((layers[t], layers[t] | (1 << w)))
        widths = new


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kit", help="the official file defining trapCodes")
    parser.add_argument("width", type=int, choices=range(16, 59))
    parser.add_argument("delay", type=int, choices=(1, 2))
    args = parser.parse_args()
    result = run(trap_codes(args.kit), args.width, args.delay)
    if result is None:
        print("EMPTY")
    else:
        first, choices = result
        print("PATH", first, "".join(map(str, choices)))
