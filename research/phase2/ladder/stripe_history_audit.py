"""Enumerate exact even-shell first-white offsets and compare independent physical cones."""

from collections import Counter


def front_step(word, parity):
    near = 1 - parity
    return (word ^ ((word << 1) | near | (word << 2) | (near << 1) | parity)) & 0xFFFFFFFF


def packed_step(row):
    return (row >> 1) ^ (row | (row << 1))


def first_offset(word):
    for j in range(32):
        if j % 2 and word % 2 == 0:
            return j-1  # subtract the one tick from arrival (width-1) to width
        word = packed_step(word)
    raise ValueError('No failed check in the 32-bit window')


def phase_table():
    word, parity = 1, 0
    by_residue = {}
    for time in range(4096):
        if time % 2:
            by_residue[((time+1)//2) % 2048] = first_offset(word)
        word = front_step(word, parity)
        parity = 1-parity
    assert (word, parity) == (1,0)
    return by_residue


def direct(n, even):
    row = (4**n-1)//3
    if even:
        row |= 1 << (2*n-1)
    for tick in range(2*n+31):
        if tick % 2 == 0 and row % 2 == 0:
            return tick
        row = packed_step(row)
    raise ValueError('Physical run exceeded the proved bound')


if __name__ == '__main__':
    by_residue = phase_table()
    print('delay after width -> number of n residues modulo 2048')
    print(sorted(Counter(by_residue.values()).items()))
    print('residues attaining +30', sorted(r for r,d in by_residue.items() if d == 30))
    for n in [*range(1,97), 2029, 2048, 2049, 4077]:
        assert direct(n, True) == 2*n + by_residue[n%2048]
        assert direct(n, False) == 2*n
    print('100 pairs of independent physical runs agree')
