"""Confirm the Rule 30 gate trap from column 1 sampled whenever the alternating wall is white."""
import argparse
import json
from collections import deque

FACTORS = ("00000", "11", "101", "10001", "1001001")
SAMPLES = 48


def first_confirmation(gate):
    """Return the first confirming endpoint, indexed from the first supplied white tick."""
    # A factor blocks a window precisely when its start is inside that window.
    recent = deque(maxlen=max(map(len, FACTORS)))
    last_bad_start = -1
    for end, bit in enumerate(gate):
        if bit not in ("0", "1"):
            raise ValueError("Each sampled gate reading must be 0 or 1.")
        recent.append(bit)
        suffix = "".join(recent)
        for word in FACTORS:
            if suffix.endswith(word):
                last_bad_start = max(last_bad_start, end + 1 - len(word))
        if end >= SAMPLES - 1 and last_bad_start < end + 1 - SAMPLES:
            return end
    return None


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("gate", help="Gate bits at consecutive white ticks, in temporal order.")
    p.add_argument("--white-tick", type=int, default=0, help="Physical time of the first supplied sample.")
    args = p.parse_args()
    if not args.gate or set(args.gate) - {"0", "1"} or args.white_tick < 0:
        p.error("Supply a nonempty binary gate and a nonnegative starting tick.")
    end = first_confirmation(args.gate)
    print(json.dumps({"confirmed": end is not None, "white_sample_offset": end,
                      "physical_tick": None if end is None else args.white_tick + 2 * end}))
