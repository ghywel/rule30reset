"""Can a right half read a given word at the white ticks beside an alternating column?  Strip of columns 1..W, east column free.
State = row at a white tick (bit 0 = column 1).  Subset simulation from all rows; the word dies at width W if the set empties."""
import sys, random
import numpy as np

def succ(states, W):
    mask = (1 << W) - 1
    out = []
    x = states
    for e1 in (0, 1):
        # tick with column 0 white: new_i = left xor (c or r); left of column 1 is 0
        left = (x << 1) & mask
        right = (x >> 1) | (e1 << (W - 1))
        y = left ^ (x | right)
        for e2 in (0, 1):
            left2 = ((y << 1) & mask) | 1        # column 0 black
            right2 = (y >> 1) | (e2 << (W - 1))
            out.append(left2 ^ (y | right2))
    return np.unique(np.concatenate(out))

def survives(word, W):
    s = np.arange(1 << W, dtype=np.int64)
    for k, b in enumerate(word):
        s = s[(s & 1) == b]
        if len(s) == 0: return k, 0
        if k + 1 < len(word): s = succ(s, W)
    return len(word), len(s)

def gapword(gaps, n):
    w = []
    for g in gaps:
        w += [1] + [0] * (g - 1)
        if len(w) >= n: break
    return w[:n]

def arc_order(al, ga, n, x=0.0):
    return [1 if ((x + t * al) % 1.0) < ga else 0 for t in range(n)]

if __name__ == '__main__':
    random.seed(5)
    phi = (5 ** .5 - 1) / 2
    r2 = 2 ** .5
    tests = []
    for name, al, ga in (('golden arc .3 (3 in arc)', phi, .3), ('golden arc .5', phi, .5), ('sqrt2-1 arc .2', r2 - 1, .2), ('sqrt2-1 arc .37', r2 - 1, .37), ('pi-3 arc .1', 3.14159265358979 - 3, .1),
                         ('e-2 arc .25', 2.718281828459045 - 2, .25), ('sqrt3-1 arc .2', 3 ** .5 - 1, .2), ('golden^2 arc .2', 1 - phi, .2)):
        c = arc_order(al, ga, 400)
        tests.append((name + ' 3/5', gapword([3 if x else 5 for x in c], 160)))
        tests.append((name + ' 5/3', gapword([5 if x else 3 for x in c], 160)))
        tests.append((name + ' 2/5', gapword([2 if x else 5 for x in c], 160)))
    tests.append(('control: all 3', gapword([3] * 200, 160)))
    tests.append(('control: all 5', gapword([5] * 200, 160)))
    tests.append(('control: 3 4', gapword([3, 4] * 100, 160)))
    tests.append(('control: half circle', arc_order(phi, .5, 160)))
    # a real right half
    rng = random.Random(3)
    T = 420; row = [rng.randrange(2) for _ in range(T + 2)]; out = []
    for t in range(T):
        if t % 2 == 0: out.append(row[0])
        row = [((t % 2) if i == 0 else row[i - 1]) ^ (row[i] | row[i + 1]) for i in range(len(row) - 1)]
    tests.append(('control: a real right half from sample 40', out[40:200]))
    for name, w in tests:
        res = []
        for W in (8, 12, 14, 16, 18, 20):
            k, left = survives(w, W)
            res.append('%d:%s' % (W, 'ok' if left else 'dies@%d' % k))
            if not left: break
        print('%-42s %s' % (name, ' '.join(res)))
        sys.stdout.flush()
