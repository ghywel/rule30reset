"""Find the physical singleton's first permanent prefix returns by simultaneous evolution."""

from argparse import ArgumentParser
from bisect import bisect_right


def front(width, period, horizon):
    if width < 1 or period < 1 or horizon < 0:
        raise ValueError("width and period must be positive and horizon nonnegative")
    mask = (1 << width) - 1

    def step(row):
        return ((row << 2) ^ ((row << 1) | row)) & mask

    row = later = 1
    for _ in range(period):
        later = step(later)

    times = []
    for tick in range(horizon + 1):
        difference = row ^ later
        equal = (difference & -difference).bit_length() - 1 if difference else width
        assert equal >= len(times)  # Each prefix evolves autonomously.
        times.extend([tick] * (equal - len(times)))
        if equal == width:
            break
        row = step(row)
        later = step(later)
    return times


def checkpoints(times):
    first = previous_tick = 0
    while first < len(times):
        deadline = (7 * first + 30) // 5
        width = bisect_right(times, deadline)
        if width <= first:
            raise ValueError(f"deadline fails at wheel {first}")
        tick = times[width - 1]
        yield tick - previous_tick, width
        first, previous_tick = width, tick


if __name__ == "__main__":
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("width", type=int, nargs="?", default=87868)
    parser.add_argument("period", type=int, nargs="?", default=16)
    parser.add_argument("horizon", type=int, nargs="?", default=125000)
    parser.add_argument("--cuts", action="store_true", help="print the Lean checkpoint pairs")
    args = parser.parse_args()
    times = front(args.width, args.period, args.horizon)
    if not times:
        raise SystemExit("No prefix returned by the supplied horizon")
    intercept = max(5 * t - 7 * j for j, t in enumerate(times))
    witness = next(j for j, t in enumerate(times) if 5 * t - 7 * j == intercept)
    print("returned prefixes", len(times), "last wheel", len(times) - 1, "time", times[-1])
    print("max(5T-7j)", intercept, "first attained at wheel", witness)
    sample = [2, 16, 85, 400, 4096, 53207, 58288, 87866, 87867]
    print("samples", [(j, times[j]) for j in sample if j < len(times)])
    if args.cuts:
        print(list(checkpoints(times)))
