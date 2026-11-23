"""Compare the historical 56-tick wheel with the kit's white-time window graphs."""

import argparse
import ast
import json
from pathlib import Path
import re

import numpy as np


# The two literal words in placego's rule30_wheel_left.py, at its white time zero.
U = "00010011010001001101000100110100010011010001001101001101"
U2 = "00010011001101"


def table(kit, name, module):
    source = (kit / "lean/Ruliology/CellularAutomata" / (module + ".lean")).read_text(encoding="utf-8")
    literal = re.search(rf"def {name} : List (?:Nat|\(List Nat\)) := (\[.*?\n\])", source, re.S)
    return ast.literal_eval(literal.group(1))


def tick(row, wall):
    return ((row << 1) | wall) ^ (row | (row >> 1))


def graph(kit, width):
    states = np.arange(1 << width, dtype=np.uint32)
    successors = np.stack([tick(tick(states + (e << width), 0), 1) & ((1 << width) - 1)
                           for e in range(4)], axis=1)
    inside = np.zeros(65536, dtype=bool)
    codes = table(kit, "trapCodes", "Rule30Certificates/GateTrap")
    assert len(set(codes)) == 829
    inside[codes] = True
    inside = inside[states & 65535]
    assert inside[successors[inside]].all()
    return states, successors, inside


def exterior_clock(states, successors, inside, phase, full):
    """All paths avoiding the trap; stop at emptiness or an exact repeated layer."""
    active = states[~inside]
    seen = {}
    n = 0
    while len(active):
        p = (phase + n) % 28
        key = (p, active.tobytes())
        if key in seen:
            return {"cycle_from": seen[key], "cycle_to": n, "states": len(active)}
        seen[key] = n
        active = active[(active & 1) == int(U[2*p])]
        if full:
            active = active[((active & 3) != 0) == bool(int(U[2*p+1]))]
        dest = np.unique(successors[active])
        active = dest[~inside[dest]]
        n += 1
    return {"pairs": n}


def trap_blocks(states, successors, inside):
    """Physical column-one blocks from a white-time black pulse to before the next one."""
    active = {"": states[inside & ((states & 1) == 1)]}
    complete = set()
    for n in range(5):
        nxt = {}
        for word, rows in active.items():
            for middle in (0, 1):
                outgoing = rows[((rows & 3) != 0) == middle]
                if not len(outgoing):
                    continue
                label = word + str(int(n == 0)) + str(middle)
                after = np.unique(successors[outgoing])
                if np.any(after & 1):
                    complete.add(label)
                white = after[(after & 1) == 0]
                if len(white):
                    nxt[label] = white
        active = nxt
    assert not active
    return sorted(complete)


def longest(a, b):
    """Largest common cyclic factor with even relative phase, or equality of periodic words."""
    from math import lcm
    limit = lcm(len(a), len(b))
    best = 0
    for p in range(len(a)):
        for q in range(p % 2, len(b), 2):
            n = 0
            while n < limit and a[(p+n) % len(a)] == b[(q+n) % len(b)]:
                n += 1
            if n == limit:
                return {"equivalent": True, "phases": [p, q]}
            best = max(best, n)
    return {"max_ticks": best}


def locks(kit):
    result = {}
    for name in ("lock5Codes", "lock7Codes", "lock7bCodes"):
        classes = table(kit, name, "Rule30SidewaysLocks")
        pairs = [sorted({str(x & 1) + str(int((x & 3) != 0)) for x in phase}) for phase in classes]
        item = {"pairs": pairs}
        if all(len(p) == 1 for p in pairs):
            word = "".join(p[0] for p in pairs)
            item.update(word=word, U=longest(U, word), U2=longest(U2, word))
        result[name] = item
    return result


def witness(path):
    data = json.loads(path.read_bytes())
    row = list(map(int, data["witness"]["initial_row"]))
    bits = []
    for t in range(2 * data["samples"] - 1):
        bits.append(str(row[0]))
        lefts = [t % 2] + row
        row = [lefts[i] ^ (row[i] | row[i+1]) for i in range(len(row)-1)]
    trace = "".join(bits)
    start = 2 * data["P"]
    matches = []
    for shift in range(0, 56, 2):
        wanted = "".join(U[(t+shift) % 56] for t in range(len(trace)-start))
        if trace[start::2] == wanted[::2]:
            mismatches = [i for i, (a,b) in enumerate(zip(trace[start:], wanted)) if a != b]
            matches.append(dict(phase_at_start=shift, mismatches=mismatches))
    return {"start": start, "last_tick": len(trace)-1, "matches": matches}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("kit", type=Path)
    ap.add_argument("witness", type=Path)
    ap.add_argument("--width", type=int, default=16)
    args = ap.parse_args()
    states, successors, inside = graph(args.kit, args.width)
    result = {"width": args.width, "gate": U[::2], "trap_blocks": trap_blocks(states, successors, inside),
              "locks": locks(args.kit), "M106": witness(args.witness)}
    for full in (False, True):
        result["full" if full else "visible"] = [
            exterior_clock(states, successors, inside, p, full) for p in range(28)]
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
