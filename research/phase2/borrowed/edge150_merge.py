"""Look for a pair of black-to-black predecessors that merges for every common tail.

If the greatest differing index is d, leave the common bits at d+1..d+4 fixed.
No two-tick cone can see both a difference at or below d and a change from d+5 on.
The fixed low bits must already pass all even checks before the free tail arrives.
"""

from edge150_inverse import forward, predecessors


def main():
    least = None
    pairs = eligible = 0
    for target in range(1, 1 << 16, 2):
        roots = sorted(predecessors(target))
        if len(roots) != 2:
            continue
        pairs += 1
        a, b = roots
        width = (a ^ b).bit_length() + 4
        mask = (1 << width) - 1
        a, b = a & mask, b & mask
        assert forward(a) == forward(b)
        x = a
        for _ in range(0, width, 2):
            if not x & 1:
                break
            x = forward(x)
        else:
            eligible += 1
            witness = (width, a, b, forward(a))
            if least is None or witness < least:
                least = witness
    print('odd targets, double black predecessors, compatible prefix pairs:', 32768, pairs, eligible)
    print('least witness by fixed width and packed roots:', least)


if __name__ == '__main__':
    main()
