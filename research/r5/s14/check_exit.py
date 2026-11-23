#!/usr/bin/env python3
"""check_exit.py: the exit law of Rule30EtherThreeDeparture.departure_after_exit against whole rows, no Lean (ledger M138).
Random aligned prefixes of N columns, every ether column at site 0, random cells beyond with a real exit at the next tick."""
import pathlib, random, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
import claudeM5_r5_front as f

E = f.ETHER
ROW = [[], [1, 1, 1, 3, 1, 1, 5, 1, 3, 2], [2, 2, 4, 8, 2, 6, 6, 4, 4, 3], [3, 5, 9, 9, 7, 7, 7, 5, 5, 4],
       [6, 10, 10, 10, 8, 8, 10, 6, 8, 7], [11, 11, 11, 13, 9, 11, 15, 9, 13, 12]]


def eth(j0, s, p, t):
    return E[(j0 + p) % 12][(t + s) % 3]


def slot(g, u):
    return 9 if g == 8 and u else [0, 7, 4, 1, 8, 5, 2, 0, 6, 3][g]


def ticks(d, j):
    sw = lambda d, j: 0 if d == 0 else ROW[min(d, 5)][j]
    return sw(d, j) if d < 2 else 10 * ((d - 2) // 4) + sw(2 + (d - 2) % 4, j)


def exit_wait(N, g, u):
    if g == 9 and u:
        return ticks(N - 1, 7) + 2
    if g == 6 and u:
        return ticks(N - 2, 7) + 3
    return ticks(N - 1, slot(g, u)) + 1


def main(runs, seed):
    rng = random.Random(seed)
    n = bad = 0
    by, states, words = {}, set(), set()
    while n < runs:
        j0, s, t0, N = rng.randrange(12), rng.randrange(3), rng.randrange(3), rng.randrange(3, 41)
        x = [eth(j0, s, p, t0) for p in range(N + 1)] + [rng.randrange(2) for _ in range(rng.randrange(2, 90))] + [0, 0]
        w = sum(b << i for i, b in enumerate(x))

        def step(w, t):
            return (((w << 1) ^ (w | (w >> 1))) & ~1) | eth(j0, s, 0, t + 1)
        w1 = step(w, t0)
        if all(((w1 >> p) & 1) == eth(j0, s, p, t0 + 1) for p in range(N + 1)):
            continue
        n += 1
        g, u = (j0 + N + 4 * (t0 + 1 + s)) % 12, int(((w1 >> (N + 1)) & 1) != eth(j0, s, N + 1, t0 + 1))
        want, t, k, v = exit_wait(N, g, u), t0, 0, w
        while ((v >> 1) & 1) == eth(j0, s, 1, t) and k < 400:
            v = step(v, t)
            t += 1
            k += 1
        bad += k != want
        states.add((g, u))
        words.add(''.join(str(E[j0][(q + s) % 3]) for q in range(3)))
        by[N] = by.get(N, 0) + 1
    print('exits', n, 'prefix lengths', min(by), 'to', max(by), '| exit states met', sorted(states), '| words at site 0', sorted(words), '| wrong times', bad)


if __name__ == '__main__':
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 40000, 138)
