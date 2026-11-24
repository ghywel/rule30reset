#!/usr/bin/env python3
"""claudeM5_i66_check.py (ledger M155): the read of I203. No code shared with research/arrivals.

Beside an alternating column, black first. s counts the white ticks; x, y are the first two right cells at white tick s; the kick is
x; a = x xor y (Lowry's net on the white tick when the next centre cell is black); b = p and not q, for the cells p, q at the next
black tick (the net there).
"""
import itertools
import random
NINE = {'001010010', '001010100', '001010101', '010010010', '101010010', '101010101'}
PAIRS = {'22', '24', '25', '33', '35', '45', '52', '53', '55'}


def tick(r, wall, e):
    """r: tuple of cells 1..n; e: cell n+1"""
    c = (wall,) + r + (e,)
    return tuple(c[i - 1] ^ (c[i] | c[i + 1]) for i in range(1, len(r) + 1))


def ge2(word, full=False):
    """no factor that breaks GE2: gaps 2..5, consecutive pairs among the nine; gaps only between two ones of the word, and a run of
    five zeros is a break anywhere"""
    if '00000' in word or '11' in word:
        return False
    ones = [i for i, c in enumerate(word) if c == '1']
    g = [b - a for a, b in zip(ones, ones[1:])]
    return all(2 <= d <= 5 for d in g) and all('%d%d' % p in PAIRS for p in zip(g, g[1:]))


def strip(n_cells, samples, obs, need):
    """all paths of a strip of n_cells with both outer cells free; returns violations of `need`"""
    rows = list(itertools.product((0, 1), repeat=n_cells))
    nxt, blk = {}, {}
    for r in rows:
        nxt[r] = {tick(tick(r, 0, e), 1, f) for e in (0, 1) for f in (0, 1)}
        bs = {tick(r, 0, e)[:2] for e in (0, 1)}
        assert len(bs) == 1 or n_cells < 3
        blk[r] = next(iter(bs))
    cur = {(r, '', '', '', '') for r in rows}
    for i in range(samples):
        new = set()
        for r, g, a, b, m in cur:
            G = g + str(r[0])
            if not ge2(G):
                continue
            p, q = blk[r]
            st = (G, a + str(r[0] ^ r[1]), b + str(p & (1 - q)), m + str(r[0] & r[1]))
            if i + 1 == samples:
                new.add((None,) + st)
            else:
                new.update((t,) + st for t in nxt[r])
        cur = new
    return sorted({(g, a, b, m) for _, g, a, b, m in cur if need(g, a, b, m)})


white_bad = lambda g, a, b, m: (a[:9] in NINE) != (g[6] == '1')
black_bad = lambda g, a, b, m: (m[1] == '1') != (b[1] == '1' and b[5] == '0')
for extra in (2, 3, 4):
    v = strip(6, 9 + extra, None, white_bad)
    print('white rule, six cells,', extra, 'further samples: violations', len(v), sorted({x[1][:9] for x in v}))
for n in (4, 5):
    v = strip(n, 13, None, white_bad)
    print('white rule,', n, 'cells, 4 further samples: violations', len(v))
for back, fwd in ((1, 4), (0, 4), (1, 3)):
    def bad(g, a, b, m, k=back):
        return (m[k] == '1') != (b[k] == '1' and b[k + 4] == '0')
    v = strip(6, back + 5 + fwd, None, bad)
    print('black rule, six cells, %d before and %d after its last reading: violations' % (back, fwd), len(v))


# real halves: a long row, exact light cone
def half_run(n, steps, rnd, dens):
    r = tuple(int(rnd.random() < dens) for _ in range(n))
    out = []
    # black first: at t = 0 the wall is black
    for s in range(steps):
        c = (1,) + r
        r = tuple(c[i - 1] ^ (c[i] | c[i + 1]) for i in range(1, len(c) - 1))     # t odd: white tick s
        white = r
        c = (0,) + r
        r = tuple(c[i - 1] ^ (c[i] | c[i + 1]) for i in range(1, len(c) - 1))     # next black tick
        out.append((white[0], white[1], white[0] ^ white[1], r[0] & (1 - r[1])))
    return out


rnd = random.Random(66)
tot = odd_bad = adj = 0
whitebad = blackbad = late = pure4 = notge2 = evens = 0
for trial in range(600):
    S = 220
    o = half_run(2 * S + 40, S, rnd, rnd.choice((.5, .5, .2, .8, .05)))
    x = [k[0] for k in o]
    a = [k[2] for k in o]
    b = [k[3] for k in o]
    kicks = [s for s in range(S) if x[s]]
    nextgap = {s: t - s for s, t in zip(kicks, kicks[1:])}
    for s in range(1, S - 6):
        tot += 1
        mark = (a[s - 1] == 0 and a[s] == 0)
        odd = x[s] == 1 and nextgap.get(s) in (3, 5)
        odd_bad += mark != odd
        adj += a[s - 1] and a[s]
    g = ''.join(map(str, x[60:]))
    tail = [nextgap[s] for s in kicks if s >= 60 and s in nextgap]
    if tail and set(tail) == {4}:
        pure4 += 1
        continue
    if not ge2(g):
        notge2 += 1
        continue
    evens += any(t in (2, 4) for t in tail)
    for s in range(70, S - 14):
        late += 1
        whitebad += (''.join(map(str, a[s - 6:s + 3])) in NINE) != (x[s] == 1)
        blackbad += (x[s] == 1 and nextgap.get(s) in (3, 5)) != (b[s] == 1 and b[s + 4] == 0)
print('real halves: odd-return test at %d white ticks, failures %d; adjacent ones in the white net %d' % (tot, odd_bad, adj))
print('late GE2 ticks %d: white rule failures %d, black rule failures %d; halves with a gap of 2 or 4 late %d, pure four %d, not GE2 %d'
      % (late, whitebad, blackbad, evens, pure4, notge2))

# the symbolic graph: positions in gap sequences with the nine pairs and no 2,2,5; reading by distance to the next kick
NEXT = {2: (2, 4, 5), 3: (3, 5), 4: (5,), 5: (2, 3, 5)}


def words(n, seed=None):
    """all (reading, gate) words of n samples, from any place of any admitted gap word"""
    res = set()

    def rec(hist, left, rd, gt):
        if len(rd) >= n:
            res.add((rd[:n], gt[:n]))
            return
        g = hist[-1]
        for h in NEXT[g]:
            if h == 5 and len(hist) >= 2 and hist[-2:] == (2, 2):
                continue
            rec(hist[-1:] + (h,), 0, rd + emit(h), gt + '1' + '0' * (h - 1))
    emit = lambda d: {2: '10', 3: '010', 4: '1010', 5: '01010'}[d]
    for p in (2, 3, 4, 5):
        for q in NEXT[p]:
            for cut in range(q):
                rec((p, q), 0, emit(q)[cut:], ('1' + '0' * (q - 1))[cut:])
    return res


def ambiguous(past, fut):
    d = {}
    for rd, gt in words(past + fut + 1):
        d.setdefault(rd, set()).add(gt[past])
    return sum(len(v) > 1 for v in d.values()), len(d)


for p, f in ((6, 2), (5, 2), (6, 1), (5, 9), (12, 1)):
    print('symbolic, %d past and %d future readings: ambiguous words, of all' % (p, f), ambiguous(p, f))
print('words of nine readings', len({r for r, _ in words(9)}), 'that read a kick at the seventh', sorted({r for r, g in words(9) if g[6] == '1'}) == sorted(NINE))

# the readings emitted by a complete gap, on real halves from the second white tick
EMIT = {2: '10', 3: '010', 4: '1010', 5: '01010'}
rnd = random.Random(67)
seen = {}
bad = 0
for trial in range(600):
    S = 160
    o = half_run(2 * S + 40, S, rnd, rnd.choice((.5, .2, .8, .1)))
    x = [k[0] for k in o]
    a = ''.join(str(k[2]) for k in o)
    kicks = [s for s in range(1, S) if x[s]]
    for s, t in zip(kicks, kicks[1:]):
        seen[t - s] = seen.get(t - s, 0) + 1
        bad += EMIT.get(t - s) != a[s:t]
print('complete gaps from the second white tick', dict(sorted(seen.items())), 'not emitting the stated word', bad)
