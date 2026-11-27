"""Local test of simultaneous misses in a first-loss interval and its half-clock phase."""

from functools import cache


@cache
def children(a, b, ticks):
    mask = (1 << ticks) - 1
    result = []
    for initial in (0, 1):
        c = initial
        for j in range(ticks - 1):
            bit = ((a ^ (b | c)) >> j) & 1
            c |= bit << (j + 1)
        result.append(c & mask)
    return result


def last_depth(word, ticks, span, limit):
    """First spatial depth at which all completions have hit a reset, or zero."""
    full = (1 << ticks) - 1
    watched = ((1 << span) - 1) << (ticks - span)
    # Columns 0,1,2 are white, the driver, and black. At 2 the open
    # black run has length one or two according to the driver.
    worlds = {(word, full, (~word) & watched, word & watched)}
    for depth in range(3, limit + 1):
        following = set()
        for a, b, once, twice in worlds:
            for c in children(a, b, ticks):
                if once & ~c:
                    continue
                following.add((b, c, c & ~(once | twice) & watched, c & once))
        worlds = following
        if not worlds:
            return depth
    return 0


def main():
    # r simultaneous misses on both halves force the final r+1 driver
    # bits to be constant, since a driver change is a fall on one half.
    # Normalize this suffix to zero by exchanging the two halves.
    for span in range(1, 6):
        for past in range(1, 7):
            ticks = span + past
            mask = (1 << ticks) - 1
            failed = []
            worst = 0
            for w in range(1 << (past - 1)):
                depths = [d for v in (w, mask ^ w)
                          if (d := last_depth(v, ticks, span, 23)) != 0]
                if depths:
                    worst = max(worst, min(depths))
                else:
                    failed.append(w)
            print(span, past, len(failed), worst, failed[:3], flush=True)
            if not failed:
                break


if __name__ == "__main__":
    main()
