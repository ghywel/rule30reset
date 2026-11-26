#!/usr/bin/env python3
"""claudeM5_wall_examples.py: replay R127's and R130's four sharp examples beside a prescribed wall (M197).

  python3 -I research/k50_3/claudeM5_wall_examples.py

Own simulator of the kit's driven left half (Rule30DrivenLeft.L): sites p < 0 run rule 30, and site 0 holds the wall
value c(t). Each example gives a start s (edge at -m), a wall c and an age t; the predecessors are rebuilt here from
the numbers in Rule30DrivenLeftInverse.lean (bit k of a code is site -k-1). Checked on sites -LO..-1: the forward
image, each inverse equation (with the predecessor's wall bit at site 0 set to the wall's value one tick earlier), the
west tails, and that the last predecessor is black far to the west, so it has no leftmost black cell. Controls: the
same starts one tick older have no such predecessor among those the inverse rule builds from any two east cells.
"""
LO = 200


def rule(l, c, r):
    return l ^ (c | r)


def half(s, c, t):
    row = {p: s(p) for p in range(-LO - t - 2, 0)}
    for k in range(t):
        row[0] = c(k)
        row = {p: rule(row.get(p - 1, 0), row[p], row[p + 1]) for p in range(-LO - t - 2 + k + 1, 0)}
    row[0] = c(t)
    return row


def code(n):
    return lambda p: (n >> (-p - 1)) & 1 if p < 0 else 0


def check_pred(z, y, wallbit):
    zz = lambda p: wallbit if p == 0 else z(p)
    return all(rule(zz(p - 1), zz(p), zz(p + 1)) == y(p) for p in range(-LO, 0))


def west_black(z):
    return all(z(p) == 1 for p in range(-LO - 1, -40))


def edge(y):
    return max(p for p in range(-LO, 0) if all(y(q) == 0 for q in range(-LO, p)) and y(p) == 1)


def preds(y):
    """every predecessor on sites -LO..0: the inverse rule z(p-1) = y(p) xor (z(p) or z(p+1)), from the two east cells"""
    out = []
    for a in (0, 1):
        for b in (0, 1):
            z = {0: a, -1: b}
            for q in range(-1, -LO, -1):
                z[q - 1] = y(q) ^ (z[q] | z[q + 1])
            out.append(lambda p, z=z: z.get(p, 0))
    return out


def control(s, wall, t, k, expect):
    """at age t, every k-step predecessor has its edge at expect"""
    H = half(s, wall, t)
    layer = [lambda p, H=H: H[p]]
    for _ in range(k):
        layer = [z for y in layer for z in preds(y)]
    return all(edge(z) == expect for z in layer), len(layer)


def main():
    # one tick (R127): z black on (-inf,-11] and at -9, -5, -2, white at the wall
    z1 = lambda p: 1 if (p <= -11 or p in (-9, -5, -2)) else 0
    for name, m, wall, t in [('depth 2, white wall, age 7', 2, lambda k: 0, 7),
                             ('depth 1, wall black at tick 2, age 8', 1, lambda k: int(k == 2), 8)]:
        H = half(lambda p, m=m: int(p == -m), wall, t)
        y = lambda p, H=H: H[p]
        print(name, '| image edge', edge(y), '| z predecessor:', check_pred(z1, y, wall(t - 1)),
              '| z black far west:', west_black(z1))
    # two ticks (R130)
    for name, m, wall, t, seed, first, second in [
            ('depth 8, white wall, age 23', 8, lambda k: 0, 23, 144, 692192899, 763101946),
            ('depth 1, wall black at 2, 19, 20, age 24', 1, lambda k: int(k in (2, 19, 20)), 24, 1, 10815524, 11923384)]:
        width = m + t
        H = half(code(seed), wall, t)
        y = lambda p, H=H: H[p]
        w = code(first)
        z = lambda p, second=second, width=width: 1 if p <= -(width + 1) else code(second)(p)
        print(name, '| seed edge', -m, 'black at', [p for p in range(-20, 0) if code(seed)(p)],
              '| image edge', edge(y), '| w pred:', check_pred(w, y, wall(t - 1)),
              '| w edge', edge(w), '| z pred of w:', check_pred(z, w, wall(t - 2)), '| z black far west:', west_black(z))

    # controls one tick older: every predecessor the inverse rule builds has the true edge
    print('control depth 2, white, age 8, one tick:', control(lambda p: int(p == -2), lambda k: 0, 8, 1, -2 - 8 + 1))
    print('control depth 1, pulse at 2, age 9, one tick:', control(lambda p: int(p == -1), lambda k: int(k == 2), 9, 1, -1 - 9 + 1))
    print('control depth 8, white, age 24, two ticks:', control(code(144), lambda k: 0, 24, 2, -8 - 24 + 2))
    print('control depth 1, pulses 2, 19, 20, age 25, two ticks:',
          control(code(1), lambda k: int(k in (2, 19, 20)), 25, 2, -1 - 25 + 2))


if __name__ == '__main__':
    main()
