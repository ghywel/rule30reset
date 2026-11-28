"""Row-wise replay of K100's free-driver counts, on the rectangle it enumerates."""

from collections import Counter
from pathlib import Path


def count(length, history, width):
    mask = (1 << (width + 1)) - 1
    inner = (1 << width) - 2
    rows = Counter({(tail << 3) | 4 | driver: 1
                    for tail in range(1 << (width - 2)) for driver in (0, 2)})
    for t in range(history + length):
        if t >= history:
            rows = Counter({row: num for row, num in rows.items()
                            if not (row & ~(row << 1) & ~(row >> 1) & inner)})
        if t + 1 < history + length:
            new = Counter()
            for row, num in rows.items():
                forced = (((row << 2) ^ ((row << 1) | row)) & mask & ~7) | 4
                new[forced] += num
                new[forced | 2] += num
            rows = new
    return sum(rows.values())


def main():
    rows = Path(__file__).with_name('data') / 'claudeCloud-window-local.txt'
    checked = 0
    for line in rows.read_text().splitlines():
        if ' | 0..8 | ' in line:
            length, _, width, values = line.split(' | ')
            actual = [count(int(length), p, int(width)) for p in range(9)]
        elif ' | [' in line:
            length, values = line.split(' | ')
            actual = [count(int(length), 0, w) for w in range(4, 8)]
        else:
            continue
        expected = [int(v) for v in values.strip('[]').split(', ')]
        assert actual == expected, (line, actual)
        checked += len(actual)
    print('matching entries in the two K100 tables:', checked)


if __name__ == '__main__':
    main()
