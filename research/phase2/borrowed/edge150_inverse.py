"""Finite black predecessors of the time (150,180) wall map, with a forward control."""


def forward(x):
    y = (x >> 1) ^ x ^ (x << 1)
    return (y >> 1) ^ (y & ~(y << 1))


def predecessors(z):
    for first in (0, 1):
        east, here, y = 0, first, first
        for i in range(z.bit_length() + 2):
            west = ((z >> i) & 1) ^ (here & (1 - east))
            y |= west << (i + 1)
            east, here = here, west
        assert here == 0  # zero forcing has closed each candidate tail

        parity = [0, 0, 0]
        for i in range(y.bit_length()):
            parity[i % 3] ^= (y >> i) & 1
        if parity[0] != parity[1] or parity[1] == parity[2]:
            continue
        # Read the unique finite Rule 150 predecessor from its outer white tail.
        west = here = x = 0
        for i in range(y.bit_length() - 1, 0, -1):
            east = ((y >> i) & 1) ^ here ^ west
            x |= east << (i - 1)
            west, here = here, east
        assert x & 1 and forward(x) == z
        yield x


def main():
    width = 12
    limit = 1 << width
    incoming = [set() for _ in range(limit)]
    # Rule 150 grows by one. A Rule 180 preimage of width W has width at most W+2.
    for x in range(1, 2 * limit, 2):
        z = forward(x)
        if z < limit:
            incoming[z].add(x)
    examples = {}
    for z, expected in enumerate(incoming):
        found = set(predecessors(z))
        assert found == expected, (z, found, expected)
        if z & 1 and z >= 3 and z >> (z.bit_length() - 2) == 3:
            examples.setdefault(len(found), (z, sorted(found)))
    print('exact target rows checked:', limit)
    print('least black growing target by number of black predecessors:', sorted(examples.items()))


if __name__ == '__main__':
    main()
