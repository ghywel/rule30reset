"""Greatest set from which either complete block can return in a free-edge strip.

Each bit of a gate word is read at a white centre tick. The state at the end of
the word belongs to the input set and supplies the next block's starting pulse.
"""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np


def word(fives):
    return "100" + "10000" * fives


def kernel(w, a, b, output):
    rows = np.arange(1 << w, dtype=np.uint32)
    mask = (1 << w) - 1
    # The two exterior bits change only the last two output bits. Use a
    # short lookup on the possible suffixes to avoid four gathers per row.
    base = (rows << 1) ^ (rows | (rows >> 1))
    base = (((base << 1) | 1) ^ (base | (base >> 1))) & mask
    top = rows >> (w-4)
    lows = base & ((1 << (w-2))-1)
    choices = np.zeros(16, dtype=np.uint8)
    for s in range(16):
        for ext in range(4):
            x = s | (ext << 4)
            y = (x << 1) ^ (x | (x >> 1))
            z = ((y << 1) | 1) ^ (y | (y >> 1))
            choices[s] |= 1 << ((z >> 2) & 3)
    allowed = choices[top]
    pulse = rows % 2 == 1

    def back(target, letters):
        for letter in reversed(letters):
            flags = target.reshape(4, -1).astype(np.uint8)
            options = flags[0] | (flags[1]<<1) | (flags[2]<<2) | (flags[3]<<3)
            target = ((options[lows] & allowed) != 0) & (pulse if letter=="1" else ~pulse)
        return target

    target = pulse.copy()
    sizes = []
    while True:
        nxt = back(target, word(a)) & back(target, word(b))
        assert not np.any(nxt & ~target)
        sizes.append(int(nxt.sum()))
        if np.array_equal(nxt, target):
            break
        target = nxt
    raw = np.packbits(target, bitorder="little").tobytes()
    output.write_bytes(raw)
    print(json.dumps(dict(width=w, fives=[a,b], sizes=sizes,
                          sha256=hashlib.sha256(raw).hexdigest())), flush=True)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("width", type=int, choices=range(4,29))
    p.add_argument("short", type=int)
    p.add_argument("long", type=int)
    p.add_argument("output", type=Path)
    args = p.parse_args()
    kernel(args.width,args.short,args.long,args.output)
