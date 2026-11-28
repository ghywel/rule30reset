"""Reconstruct one periodic-in-time white-wall row and locate repeatable cuts.

The depth-one column consists of the first twelve physical readings from 125,
repeated forever. Two consecutive 12-bit columns determine their western neighbour.
"""

from edge150_inverse import forward


def main():
    period = 12
    mask = (1 << period) - 1
    even = sum(1 << t for t in range(0, period, 2))
    y = 125
    boundary = 0
    for t in range(0, period, 2):
        mid = (y >> 1) ^ y ^ (y << 1)
        boundary |= ((y & 1) << t) | ((mid & 1) << (t + 1))
        y = forward(y)
    assert boundary & even == even

    def advance(state):
        east, here = state
        shifted = (here >> 1) | ((here & 1) << (period - 1))
        side = ((here ^ east) & even) | (here & ~east & (mask ^ even))
        return here, shifted ^ side

    # Floyd cycle finding uses constant memory even if all 2^24 pairs occur.
    initial = 0, boundary
    slow, fast = advance(initial), advance(advance(initial))
    while slow != fast:
        slow, fast = advance(slow), advance(advance(fast))
    start, slow = 0, initial
    while slow != fast:
        slow, fast = advance(slow), advance(fast)
        start += 1
    length, fast = 1, advance(slow)
    while slow != fast:
        length += 1
        fast = advance(fast)

    state = initial
    states = []
    for _ in range(start + 2 * length + 3):
        states.append(state)
        state = advance(state)
    assert states[start] == states[start + length]
    def bit(i):
        if i >= start:
            i = start + (i - start) % length
        return states[i][1] & 1
    assert sum(bit(i) << i for i in range(12)) == 125

    cuts = []
    # Two spatial periods cover the parity of every possible cut width.
    for width in range(max(start + 2, 14), max(start + 2, 14) + 2 * length):
        if bit(width-2) and bit(width-1) and not bit(width):
            gap = 1
            while not bit(width + gap):
                gap += 1
            if (width + gap) % 2 == 0:
                cuts.append((gap, width))
    print('12-bit depth-one column, low bit first:', boundary, format(boundary, '012b')[::-1])
    print('pair preperiod, period, repeated (east, here):', start, length, states[start])
    print('qualifying cut residues over two periods:', len(cuts))
    if cuts:
        gap, width = min(cuts, key=lambda item: (-item[0], item[1]))
        print('largest gap, first such width, first missed even tick, safe width increment:',
              gap, width, width + gap, 2 * length)


if __name__ == '__main__':
    main()
