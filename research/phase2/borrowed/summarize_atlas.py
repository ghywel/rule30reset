"""Score frozen K98 output. Usage: py summarize_atlas.py DIRECTORY [--all]."""

from pathlib import Path
import re
import sys


PAIR = re.compile(r"(time|space) \((\d+), (\d+)\)")


def read_mode(directory, mode):
    walls = {}
    lines = {}
    for record in (directory / f"wall-{mode}.txt").read_text().splitlines():
        if record.startswith("== "):
            _, a, b = PAIR.fullmatch(record[3:]).groups()
            widths = {}
            walls[int(a), int(b)] = widths
        elif record[:1].isdigit():
            w, rows, longest, past, alive, carried, slow, seeds = record.split("|")
            widths[int(w)] = (int(rows), int(longest), tuple(map(int, past.split())),
                              int(alive), int(carried), int(slow), tuple(map(int, seeds.split())))
    for record in (directory / f"line-{mode}.txt").read_text().splitlines():
        match = PAIR.match(record)
        if match:
            _, a, b = match.groups()
            any_period, black, all_period, periods, singleton = record[match.end() + 2:].split("|")
            singleton = singleton.split("(w = white):", 1)[1].strip()
            lines[int(a), int(b)] = (int(any_period), int(black), int(all_period),
                                     periods.strip(), singleton)
    rules = (30, 60, 90, 120, 150, 180, 210, 240)
    assert {(a, b) for a in rules for b in rules} == walls.keys() == lines.keys()
    assert all(set(ws) == set(range(1, 23)) for ws in walls.values())
    return walls, lines


def main(directory, show_all):
    relatives = [(a, b) for r in (90, 150, 210, 120, 180)
                 for a, b in ((30, r), (r, 30))]
    controls = [(210, 180), (180, 210), (30, 30), (30, 240), (240, 30)]
    for mode in ("time", "space"):
        walls, lines = read_mode(directory, mode)
        for a, b in (sorted(walls) if show_all else relatives + controls):
            widths = walls[a, b]
            longest = max(record[1] for record in widths.values())
            first_w = min(w for w, record in widths.items() if record[1] == longest)
            denominator, numerator = (sum(widths[w][2][j] for w in (20, 21, 22))
                                      for j in (0, 1))
            alive, carried, slow = (sum(x[j] for x in widths.values()) for j in (3, 4, 5))
            least = min((x[6][0] for x in widths.values() if x[6]), default=None)
            annulus = any(widths[w][1] > w + 2 for w in range(16, 23))
            like = not alive and denominator <= 4 * numerator <= 3 * denominator and annulus
            assert denominator > 0
            any_period, black, all_period, periods, singleton = lines[a, b]
            print(f"{mode} ({a}, {b}) | {longest}@{first_w} | {numerator}/{denominator} "
                  f"| {alive}/{carried}/{slow} | {least} | {annulus}/{like} "
                  f"| {any_period}/{black}/{all_period} | {periods} | seed 1: {singleton}")


if __name__ == "__main__":
    main(Path(sys.argv[1]), "--all" in sys.argv[2:])
