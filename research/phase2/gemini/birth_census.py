"""Read the frozen singleton observations from K92.4. Counts are by birth tick."""
from array import array
from hashlib import sha256
from pathlib import Path
from sys import argv, byteorder

OBS_SHA = "a9989ed73021c2e7d945eca5a1eefa971cc573f8a25d5803facb8aac0897466f"
STOP = 2**22


def census(path):
    raw = Path(path).read_bytes()
    if sha256(raw).hexdigest() != OBS_SHA:
        raise ValueError("Expected K92.4 observations.u32le")
    obs = array("I")
    obs.frombytes(raw)
    if byteorder != "little":
        obs.byteswap()
    if obs.itemsize != 4 or len(obs) != STOP + 513:
        raise ValueError("Observation layout differs from K92.4")

    def gap(t):
        return ((obs[t] >> 1) & 1023) - 1

    def active(t):
        return bool(obs[t] & 1) or gap(t) == 0

    def minus_two(t):
        # Solve the time update at site -1 for its western neighbour.
        return (gap(t + 1) == 0) ^ active(t)

    # Independent whole-line simulation for the first 8192 updates.
    offset = 8200
    row = 1 << offset
    sums = [0] * 6
    shell = [0] * 6
    marked_max = -1
    marked_times = []
    print("start  stop_exclusive  -2_falls  births2  births6  marked_births2  centre_black  centre_white")
    for t in range(STOP):
        fall = minus_two(t) and not minus_two(t + 1)
        w = gap(t + 1) if active(t) else -1
        if (w >= 2) != (fall and active(t)):
            raise AssertionError(("birth/fall mismatch", t))
        if t < 8192:
            next_row = (row << 1) ^ (row | (row >> 1))
            west = (row >> (offset - 2)) & 1
            if west != minus_two(t) or (fall != bool(west and not (next_row >> (offset - 2)) & 1)):
                raise AssertionError(("physical row mismatch", t))
            if active(t):
                cells = row >> (offset - 1)
                if not cells & 3:
                    raise AssertionError(("active pair mismatch", t))
                width = 0
                while (row >> (offset - 2 - width)) & 1:
                    width += 1
                if width != w:
                    raise AssertionError(("birth width mismatch", t))
            row = next_row

        mark = w >= 2 and bool(obs[t + 1 + w] & 1)
        if mark and w >= marked_max:
            if w > marked_max:
                marked_max, marked_times = w, []
            marked_times.append(t)
        black = obs[t] & 1
        vals = (fall, w >= 2, w >= 6, mark, black, 1 - black)
        for i, val in enumerate(vals):
            shell[i] += val
            sums[i] += val
        end = t + 1
        if end & (end - 1) == 0:
            print(end // 2, end, *shell)
            shell = [0] * 6
    print("all", STOP, *sums)
    print("largest marked birth width, birth ticks", marked_max, *marked_times)


if __name__ == "__main__":
    census(argv[1])
