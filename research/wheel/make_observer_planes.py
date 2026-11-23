"""Encode the pruned time memberships as wide decision diagrams with packed numeric leaves."""

import argparse
from pathlib import Path

import numpy as np
from observer_bilift import strip_layers


def planes(values):
    keys = np.unique(np.concatenate(values))
    masks = np.zeros(len(keys), dtype=np.int64)
    for t, rows in enumerate(values):
        masks[np.searchsorted(keys, rows)] |= 1 << t
    return keys, masks


def build(kit):
    for W, front, active in strip_layers(kit, 48, last_width=30):
        kf, ff = planes(front)
        kb, bb = planes(active)
        both = np.zeros_like(ff)
        both[np.searchsorted(kf, kb)] = bb
        yield W, kf, np.stack((ff, both), axis=-1)


def dump(path, kit, chunk=3):
    out = ["module", "@[expose] public section", "namespace Ruliology.CellularAutomata.WheelObserverPlanes"]

    def array(name, vals):
        vals = list(map(int, vals))

        def branch(lo, hi):
            if hi == lo + 1:
                return hex(vals[lo])
            mid = (lo + hi) // 2
            return f"(if i < {mid} then {branch(lo, mid)} else {branch(mid, hi)})"

        out.append(f"def {name} (i : Nat) : Nat := " + branch(0, len(vals)))

    out += [
        "@[inline] def read (tbl : Nat → Nat) (bits index : Nat) : Nat :=",
        "  ((tbl (index/64)) >>> (bits*(index%64))) % (2^bits)",
    ]

    def packed(name, vals):
        vals = list(map(int, vals))
        sz = max(1, max(vals).bit_length())
        banks = []
        for i in range(0, len(vals), 64):
            banks.append(sum(x << (sz * j) for j, x in enumerate(vals[i : i + 64])))
        array(name, banks)
        return sz

    for W, keys, fb in build(kit):
        labels, child = np.unique(
            np.concatenate((np.zeros((1, 2), dtype=np.int64), fb)), axis=0, return_inverse=True
        )
        child = child[1:]
        vals = [int(f) + (int(b) << 48) for f, b in labels]
        array(f"labels{W}", vals)
        chain = []
        for level in range(0, W, chunk):
            digits = min(chunk, W - level)
            bits = W - level - digits
            lo = keys & ((1 << bits) - 1)
            hi = keys >> bits
            keys, cls = np.unique(lo, return_inverse=True)
            rows = np.zeros((len(keys), 1 << digits), dtype=np.int64)
            rows[cls, hi] = child
            rows, child = np.unique(
                np.concatenate((np.zeros((1, 1 << digits), dtype=np.int64), rows)),
                axis=0,
                return_inverse=True,
            )
            child = child[1:]
            name = f"d{W}n{bits}"
            sz = packed(name, rows.ravel())
            chain.append(f"  let k := read {name} {sz} (k*{1 << digits} + (x >>> {bits})%{1 << digits})")
        assert len(keys) == 1
        out.extend(
            [
                f"def lookup{W} (x : Nat) : Nat :=",
                f"  let k := {child[0]}",
                *reversed(chain),
                f"  labels{W} k",
            ]
        )
    out += (
        ["def lookup : Nat → Nat → Nat"]
        + [f"  | {W} => lookup{W}" for W in range(16, 31)]
        + [
            "  | _ => fun _ => 0",
            "def front (W u : Nat) : Nat := (lookup W u)%2^48",
            "def both (W u : Nat) : Nat := (lookup W u) >>> 48",
            "end Ruliology.CellularAutomata.WheelObserverPlanes",
        ]
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(("\n".join(out) + "\n").encode())


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("kit", type=Path)
    p.add_argument("lean", type=Path)
    p.add_argument("--chunk", type=int, default=3)
    a = p.parse_args()
    dump(a.lean, a.kit, a.chunk)
