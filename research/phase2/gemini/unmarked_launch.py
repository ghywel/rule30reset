"""Check first visibility one tick past an unmarked cap on the frozen I283 archive."""

from array import array
from collections import Counter
from hashlib import sha256
from pathlib import Path
import sys

from birth_census import OBS_SHA, STOP


def load(path, digest):
    raw = path.read_bytes()
    if sha256(raw).hexdigest() != digest:
        raise ValueError(f"wrong input digest for {path}")
    words = array("I")
    words.frombytes(raw)
    if sys.byteorder == "big":
        words.byteswap()
    assert words.itemsize == 4
    return words


def west_flank(obs, s, width):
    # Invert the physical update spatially from the two adjacent time traces.
    n = width + 2
    east = [obs[s+j] & 1 for j in range(n)]
    here = [int(((obs[s+j] >> 1) & 1023) == 1) for j in range(n)]
    for _ in range(width + 1):
        west = [here[j+1] ^ (here[j] | east[j]) for j in range(len(here)-1)]
        east, here = here, west
    return here[0]


def cap_response(obs, s, width):
    blank, cap = 0, 1 << width
    for j in range(width + 1):
        boundary = obs[s+j] & 1
        blank = (blank >> 1) ^ (blank | (blank << 1) | boundary)
        cap = (cap >> 1) ^ (cap | (cap << 1) | boundary)
    return (blank ^ cap) & 1


def main(directory):
    obs = load(directory / "observations.u32le", OBS_SHA)
    fails = load(directory / "failures.u32le",
                 "83a22a62939b90d54ffd3ee3905335477d47b505e7cc464a3d7c1dc05bb32f45")
    counts = Counter()
    records = []
    previous_pair = -1
    for t in range(STOP):
        s = t + 1
        if not (obs[t] & 1 or ((obs[t] >> 1) & 1023) == 1):
            continue
        width = ((obs[s] >> 1) & 1023) - 1
        if width < 2:
            continue
        pair = s if (obs[s] ^ obs[s+1]) & 1 == 0 else s+1
        assert pair > previous_pair and (obs[pair] ^ obs[pair+1]) & 1 == 0
        previous_pair = pair
        counts["width2_or_more"] += 1
        if width < 8:
            continue
        counts["width8_or_more"] += 1
        a = s + width
        if obs[a] & 1:
            assert fails[s] == width
            continue
        counts["white_arrival"] += 1
        flank = west_flank(obs, s, width)
        response = cap_response(obs, s, width)
        visible = bool((obs[a+1] & 1) and (flank ^ response))
        assert fails[s] > width and (fails[s] == width+1) == visible, (s, width)
        counts["next_black"] += obs[a+1] & 1
        counts["one_later"] += visible
        if width >= 22:
            records.append((t, width, flank, response, obs[a+1] & 1, fails[s]))
    print(dict(counts))
    print("white arrivals of width >=22: birth, width, flank, correction, next centre, first failure")
    for record in records:
        print(*record)


if __name__ == "__main__":
    main(Path(sys.argv[1]))
