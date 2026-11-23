"""claudeM5_r5_chains.py [DIR]: the patterns of the four known traps for 001, rebuilt by carrying their locks leftward
(Hallee, rule30-open, Traps001 and lock-chains), compared with the kit's two tables and with each other. With DIR, writes
pat_NAME.txt files for claudeM5_r5_limit.cpp and claudeM5_r5_backall.cpp, and claudeM5_r5_tables.txt, which
claudeM5_r5_door.c and claudeM5_r5_rungs.c read from the folder they run in."""
import itertools, pathlib, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import claudeM5_r5_front as f

SEEDS = {'t001': ('0' * 5 + '10' + '1' * 12 + '01', 38), 'fifteen': ('0' * 4 + '10' + '1' * 9, 47),
         'b': ('010' + '1' * 14 + '0111', 135), 'c': ('0' * 6 + '10' + '111' + '0' + '1' * 9, 299)}


def chain(seed, vals, n):
    """columns leftward from the seed; vals fixes the column to the seed's right at the seed's white phases"""
    m, v = len(seed), seed[:]
    w = [vals.get(t, 0) for t in range(m)]
    cols = [v]
    for _ in range(n):
        left = [v[(t + 1) % m] ^ (v[t] | w[t]) for t in range(m)]
        cols.append(left)
        w, v = v, left
    return cols


def phase(c):
    m = len(c)
    return next((r for r in range(3) if m % 3 == 0 and all(c[t] == (1 if (t + r) % 3 == 2 else 0) for t in range(m))), None)


def patterns():
    out = {}
    for n, (s, d) in SEEDS.items():
        seed = [int(x) for x in s]
        wh = [t for t, x in enumerate(seed) if x == 0]
        for bits in itertools.product((0, 1), repeat=len(wh)):
            cols = chain(seed, dict(zip(wh, bits)), d)
            first = next((k for k, c in enumerate(cols) if phase(c) is not None), None)
            if first == d:
                r, m = phase(cols[d]), len(seed)
                out[n] = [[cols[d - j][(l - r) % m] for j in range(d + 1)] for l in range(m)]
    return out


def common(P, Q):
    m = len(P)
    best = (0, 0)
    for a in range(0, m, 3):
        d = 0
        while d + 1 < min(len(P[0]), len(Q[0])) and all(P[l][d + 1] == Q[(l + a) % m][d + 1] for l in range(m)):
            d += 1
        best = max(best, (d, a))
    return best


if __name__ == '__main__':
    A = patterns()
    for n in ('t001', 'fifteen'):
        T = f.load(n)
        P0, K = f.pattern(T)
        print(n, 'chain pattern equals the kit table up to a label shift:',
              any(all(P0[l][:K + 1] == A[n][(l + 3 * a) % T['m']][:K + 1] for l in range(T['m'])) for a in range(T['m'] // 3)))
    for x, y in (('t001', 'b'), ('t001', 'c'), ('b', 'c')):
        print(x, y, 'common first columns:', common(A[x], A[y])[0])
    if len(sys.argv) > 1:
        for n, P in A.items():
            if n in ('t001', 'fifteen'):
                P = f.pattern(f.load(n))[0]
            pathlib.Path(sys.argv[1], 'pat_%s.txt' % n).write_text(
                '%d %d\n' % (len(P), len(P[0]) - 1) + '\n'.join(''.join(map(str, r)) for r in P) + '\n')
        T = f.load('t001')
        P, K = f.pattern(T)
        pathlib.Path(sys.argv[1], 'claudeM5_r5_tables.txt').write_text(
            ''.join('S %d %d\n' % x for x in zip(T['st'], T['lab'])) +
            ''.join('P %d %d %d\n' % (l, j, P[l][j]) for l in range(21) for j in range(K + 1)))
