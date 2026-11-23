"""Confirm the Rule 30 gate trap from column 1 sampled whenever the alternating wall is white."""
import argparse
import json
from collections import deque

FACTORS = ("00000", "11", "101", "10001", "1001001")
SAMPLES = 48
AMBIGUOUS_47 = "00001001000010010000100001000010000100100001000"


def first_confirmation(gate, *, adaptive=False):
    """Return the first confirming endpoint, indexed from the first supplied white tick."""
    # A factor blocks a window precisely when its start is inside that window.
    length = len(AMBIGUOUS_47) if adaptive else SAMPLES
    recent = deque(maxlen=length if adaptive else max(map(len, FACTORS)))
    last_bad_start = -1
    for end, bit in enumerate(gate):
        if bit not in ("0", "1"):
            raise ValueError("Each sampled gate reading must be 0 or 1.")
        recent.append(bit)
        suffix = "".join(recent)
        for word in FACTORS:
            if suffix.endswith(word):
                last_bad_start = max(last_bad_start, end + 1 - len(word))
        if end >= length - 1 and last_bad_start < end + 1 - length and (
                not adaptive or suffix != AMBIGUOUS_47):
            return end
    return None


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("gate", help="Gate bits at consecutive white ticks, in temporal order.")
    p.add_argument("--white-tick", type=int, default=0, help="Physical time of the first supplied sample.")
    p.add_argument("--adaptive", action="store_true",
                   help="Accept a clean 47-sample window unless it is the unique ambiguous word.")
    args = p.parse_args()
    if not args.gate or set(args.gate) - {"0", "1"} or args.white_tick < 0:
        p.error("Supply a nonempty binary gate and a nonnegative starting tick.")
    end = first_confirmation(args.gate, adaptive=args.adaptive)
    print(json.dumps({"confirmed": end is not None, "white_sample_offset": end,
                      "physical_tick": None if end is None else args.white_tick + 2 * end}))
