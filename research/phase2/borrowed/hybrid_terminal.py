"""Enumerate the terminal rows after the front reaches the three cells next to the wall."""
def step(row, rule):
    left, right = row >> 1, row << 1
    return left ^ ((row | right) if rule == 30 else (row & ~right))


def trajectory(row):
    seen = {}
    trace = []
    while row not in seen:
        seen[row] = len(trace)
        mid = step(row, 30)
        trace.append((row, mid))
        row = step(mid, 180)
    first = seen[row]
    return trace, first


if __name__ == "__main__":
    for start in range(8):
        path, first = trajectory(start)
        print(start, path, "cycle starts at", first)
        assert all(a < 8 for a, _ in path)
