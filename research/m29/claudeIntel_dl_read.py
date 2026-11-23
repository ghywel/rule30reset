"""claudeIntel, N11. Independent checks for the read of R30-20261123-98c017 (kit #404) and R30-20261123-16f287
(kit #407) against the parked wall (DL-1). Written from the kit's definitions; shares no code with K5, M41, M62 or Quint.

A strip column is a list of bits over one period L. Column i+2 is the unique L-periodic solution of
  x(t+1) = a(t) xor (b(t) or x(t))      a = column i, b = column i+1,
which exists and is unique once b has a black tick.
Reset at tick s between wheels j < k: white, black run of length n = 1 mod 3, white, all at tick s.

Usage: python claudeIntel_dl_read.py [all]     ('all' adds e = 4, about half a minute)
"""
import sys
from itertools import product


def child(a, b):
    L = len(a)
    t0 = next((t for t in range(L) if b[t]), None)
    if t0 is None:
        return None                              # b white: not determined
    x = [0] * L
    x[(t0 + 1) % L] = a[t0] ^ 1
    for k in range(1, L):
        t = (t0 + k) % L
        x[(t + 1) % L] = a[t] ^ (b[t] | x[t])
    t = t0
    assert x[(t0 + 1) % L] == a[t0] ^ (b[t0] | x[t0])
    return x


def catches(cols, lo, hi, s):
    """Is there a reset at tick s with both white ends in wheels lo..hi of cols?"""
    L = len(cols[0])
    for j in range(lo, hi):
        if cols[j][s % L]:
            continue
        n = 0
        while j + 1 + n <= hi and cols[j + 1 + n][s % L]:
            n += 1
        if n % 3 == 1 and j + 1 + n <= hi:
            return True
    return False


def stretch(driver, cap):
    """Wheels from a white wheel 0 with wheel 1 = driver, until the next white wheel or cap."""
    L = len(driver)
    cols = [[0] * L, list(driver)]
    while len(cols) <= cap:
        c = child(cols[-2], cols[-1])
        cols.append(c)
        if not any(c):
            return cols, len(cols) - 1
    return cols, None


def closing(driver, cap=400):
    """(latest first-closing wheel over ticks, missed ticks, gap).  Stops as soon as every tick has closed."""
    L = len(driver)
    cols = [[0] * L, list(driver)]
    run = [driver[t] for t in range(L)]          # black run length so far at each tick, after wheel 0 (white)
    done, worst = [False] * L, 0
    while True:
        c = child(cols[-2], cols[-1])
        cols.append(c)
        w = len(cols) - 1
        for t in range(L):
            if c[t]:
                run[t] += 1
            else:
                if run[t] % 3 == 1 and not done[t]:
                    done[t] = True
                    worst = max(worst, w)
                run[t] = 0
        if all(done):
            return worst, [], None
        if not any(c):
            return worst, [t for t in range(L) if not done[t]], w
        if w >= cap:
            return worst, [t for t in range(L) if not done[t]], None


def part_A():
    print('A. every anti-periodic driver, e = 0..3 here (e = 4 in part A4), period L = 2^(e+1)')
    for e in range(4):
        P = 2 ** e
        worst, miss, n = 0, 0, 0
        for half in product((0, 1), repeat=P):
            d = list(half) + [1 - x for x in half]
            w, m, g = closing(d)
            worst, miss, n = max(worst, w), miss + bool(m), n + 1
        print('  e=%d  L=%-3d drivers=%-6d latest closing wheel=%d  drivers with a missed tick=%d' % (
            e, 2 * P, n, worst, miss))


def part_A4():
    e, P = 4, 16
    worst, miss, n = 0, 0, 0
    for k in range(2 ** P):
        half = [(k >> i) & 1 for i in range(P)]
        d = half + [1 - x for x in half]
        w, m, g = closing(d)
        worst, miss, n = max(worst, w), miss + bool(m), n + 1
    print('  e=%d  L=%-3d drivers=%-6d latest closing wheel=%d  drivers with a missed tick=%d' % (
        e, 2 * P, n, worst, miss))


def part_B():
    print('B. the non-dyadic control, source period 5 (doubled period 10): every anti-periodic driver')
    bad = []
    for half in product((0, 1), repeat=5):
        d = list(half) + [1 - x for x in half]
        w, m, g = closing(d, 2000)
        if m:
            bad.append((''.join(map(str, d)), m, g))
    for b in bad:
        print('  driver %s  missed ticks %s  next white wheel %s' % b)


def part_C():
    print('C. the strip of two_interval_fails_without_firstLoss')
    mask = lambda r: {0: 0, 1: 7, 2: 15, 3: 1, 4: 5, 5: 9, 6: 9}[r % 7]
    ce = lambda i, t: (mask(i % 28) >> ((t % 4 + 3 * ((i % 28) // 7)) % 4)) & 1
    ok = all(ce(i + 2, t + 1) == ce(i, t) ^ (ce(i + 1, t) | ce(i + 2, t)) for i in range(60) for t in range(8))
    W = [i for i in range(60) if not any(ce(i, t) for t in range(4))]
    cols = [[ce(i, t) for t in range(4)] for i in range(120)]
    print('  recurrence holds:', ok, ' white wheels:', W[:10])
    for k in range(6):
        lo, hi = 7 * k, 7 * k + 7
        print('  interval [%d,%d] misses ticks %s' % (lo, hi, [s for s in range(4) if not catches(cols, lo, hi, s)]))
    # how many consecutive intervals miss one tick, and is wheel 1 anti-periodic at 1, 2 or 4?
    best = 0
    for s in range(4):
        run = 0
        for k in range(12):
            run = run + 1 if not catches(cols, 7 * k, 7 * k + 7, s) else 0
            best = max(best, run)
    print('  longest run of consecutive intervals missing one tick:', best)
    print('  wheel 1 over a period:', cols[1], ' anti-periodic at 2:',
          all(cols[1][(t + 2) % 4] == 1 - cols[1][t] for t in range(4)))


def part_D():
    print('D. the local windows of local_paired_nfa_escapes_in_five')
    key = lambda d: d if d < 2 else 2 + d % 2
    A, B = {0: 12, 1: 28, 2: 4, 3: 30}, {0: 22, 1: 6, 2: 30, 3: 4}
    r = 24
    a = [[(A[key(r - 1 - j)] >> k) & 1 for k in range(6)] for j in range(r)]
    b = [[(B[key(r - 1 - j)] >> k) & 1 for k in range(6)] for j in range(r)]
    ok = all(w[j + 1][k + 2] == w[j][k] ^ (w[j][k + 1] | w[j][k + 2]) for w in (a, b) for j in range(r - 1) for k in range(4))
    print('  recurrence holds on both windows (24 rows):', ok)
    print('  wheel-1 of A, oldest to newest:', ''.join(str(a[j][1]) for j in range(r)))
    # push the windows FORWARD in time: wheel 1 free at each new tick (B complementary), wheel 5 must stay white
    states = {((tuple(a[-1])), tuple(b[-1]))}
    for f in range(1, 12):
        new = set()
        for sa, sb in states:
            na = [0, None, None, None, None, None]
            nb = list(na)
            for k in range(4):
                na[k + 2] = sa[k] ^ (sa[k + 1] | sa[k + 2])
                nb[k + 2] = sb[k] ^ (sb[k + 1] | sb[k + 2])
            if na[5] or nb[5] or not na[2] or not nb[2]:
                continue
            for x in (0, 1):
                na[1], nb[1] = x, 1 - x
                new.add((tuple(na), tuple(nb)))
        states = new
        print('  %2d ticks into the future: %d paired rows keep wheel 5 white' % (f, len(states)))
        if not states:
            break


def part_E():
    print('E. the period-5 orbit on the relaxed form')
    L, d = 10, [0] * 5 + [1] * 5
    cols, gap = stretch(d, 2000)
    miss = [s for s in range(L) if not catches(cols, 0, gap, s)]
    src = cols[gap - 1]
    print('  next white wheel %d, missed ticks %s, wheel %d white at all ticks: %s' % (gap, miss, gap, not any(cols[gap])))
    x, w = [], 0
    for t in range(2 * L):
        x.append(w)
        w ^= src[t % L]
    assert sum(src) % 2 == 1 and w == 0          # odd weight: the clock doubles again, to 20
    cols2 = [[0] * (2 * L), x]
    while len(cols2) <= 400 and any(cols2[-1]):
        cols2.append(child(cols2[-2], cols2[-1]))
    hit = {s: next((h for h in range(2, len(cols2)) if catches(cols2, 0, h, s)), None) for s in range(2 * L)}
    print('  second stretch: %d of 20 ticks caught, latest closing wheel %s' % (
        sum(v is not None for v in hit.values()), max(v for v in hit.values() if v is not None)))
    print('  the rows that continue the missed ticks close at wheels', [hit[s] for s in range(2 * L) if s % L in miss])


if __name__ == '__main__':
    part_A()
    part_B()
    part_C()
    part_D()
    part_E()
    if len(sys.argv) > 1 and sys.argv[1] == 'all':
        part_A4()
