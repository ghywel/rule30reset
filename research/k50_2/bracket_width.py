"""Least freely driven strip width excluding every completed 5,2^k,5 for k >= 2."""


def tick(row, width, wall, exterior):
    mask = (1 << width) - 1
    return (((row << 1) | wall) ^ (row | (row >> 1) | (exterior << (width - 1)))) & mask


def graph(width):
    # Both eastern input bits are free, also at width one.
    return [[tick(tick(row, width, 0, a), width, 1, b) for a in (0, 1) for b in (0, 1)]
            for row in range(1 << width)]


def after(edges, states, gap):
    for offset in range(1, gap + 1):
        states = frozenset(y for x in states for y in edges[x] if (y & 1) == (offset == gap))
    return states


def witness(width, gaps):
    edges = graph(width)
    states = {x: (x, '') for x in range(1, 1 << width, 2)}
    readings = [True] + [i == d for d in gaps for i in range(1, d + 1)]
    for reading in readings[1:]:
        states = {y: (x0, path + format(ab, '02b')) for x, (x0, path) in states.items()
                  for ab, y in enumerate(edges[x]) if (y & 1) == reading}
    endpoint = min(states)
    start, east = states[endpoint]
    # Separate replay as scalar cells, with one eastern boundary bit per tick.
    row = [(start >> i) & 1 for i in range(width)]
    observed = [row[0]]
    for t, e in enumerate(map(int, east)):
        padded = [t % 2, *row, e]
        row = [padded[i] ^ (padded[i+1] | padded[i+2]) for i in range(width)]
        if t % 2:
            observed.append(row[0])
    assert observed == readings and sum(bit << i for i, bit in enumerate(row)) == endpoint
    return start, east, endpoint


def first_repeat(width):
    edges = graph(width)
    states = after(edges, range(1, 1 << width, 2), 5)
    states = after(edges, after(edges, states, 2), 2)
    seen, rows = {}, []
    k = 2
    while states not in seen:
        seen[states] = k
        exits = after(edges, states, 5)
        rows.append((k, len(states), len(exits)))
        states = after(edges, states, 2)
        k += 1
    return seen[states], k - seen[states], rows


if __name__ == '__main__':
    width = 1
    while True:
        start, period, rows = first_repeat(width)
        print('width', width, 'repeat from k', start, 'period', period,
              '(k, windows after twos, possible 5 endpoints)', rows)
        if not any(n for _, _, n in rows):
            break
        width += 1
    k = next(k for k, _, n in first_repeat(width-1)[2] if n)
    print('last surviving width', width-1, 'k', k, '(initial row, eastern bits, final row)',
          witness(width-1, [5] + [2]*k + [5]))
