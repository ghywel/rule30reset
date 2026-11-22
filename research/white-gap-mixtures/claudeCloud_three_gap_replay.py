#!/usr/bin/env python3
"""claudeCloud_three_gap_replay.py: carrying read of gptIntel's I85 (ledger K64, path 2): exactly ten of the 512
three-gap words on 9..16 put every ordinary right half into the kit's absorbing set G. Written from I85, its summary
(cold-reset.md) and the kit's definitions; nothing of gptIntel's code or witnesses is used.

The kit's objects (Rule30StripCertificates, Rule30WhitePad10111, Rule30Certificates/ResetMixtures), restated:
  - a strip state is 8 bits, bit k = the cell k + 1 places right of the driven site;
  - one tick with driver bit a: new bit k = rule(left, bit k, right), left = a for k = 0, right = the exterior bit
    for k = 7 (either value: the set image takes both);
  - a gap q is one black driver tick followed by q white ticks;
  - A0 (all states), A1, A2, A3 and G are the kit's bitmasks over the 256 states, copied as data.
Rule 30: rule(l, c, r) = l xor (c or r).

Checks:
  K  control: the kit's six inclusions mac 9 A0 in A1, mac 9 A1 in A2, mac 9 A2 in A3, mac 9 A3 in A3,
     mac 17 A3 in G, mac 9 G in G, recomputed here.
  U  upper (free exterior bit at every tick): which of the 512 three-gap words, and of the 64 two-gap words, send
     A0 into G.
  L  lower (ordinary histories, the true Rule 30 cone): for every word, is there a right half whose 8 strip cells
     after the word are outside G? SAT (CaDiCaL), every model replayed by direct simulation.
I85 says: U finds exactly (q, 16, 16) for q = 9..16, (16, 10, 15) and (16, 10, 16); L finds an escape for each of the
other 502 triples and for all 64 pairs.

    python3 claudeCloud_three_gap_replay.py
"""
import itertools
from pysat.solvers import Cadical195

A0 = (1 << 256) - 1
A1 = 0xa868b02aa120302920298022a128222ba868a02b2120102220298062a028222b
A2 = 0x2868302aa120302920290022a128222b2868202b2120102220290062a028222b
A3 = 0x2028202a20202028202800222020202a2028202a20200022202800222020202a
G = 0x2020000000202000202000000020202020200000002000000020000000202020


def rule(l, c, r):
    return l ^ (c | r)


def strip_step(a, z, s):
    out = 0
    for k in range(8):
        left = a if k == 0 else (s >> (k - 1)) & 1
        right = z if k == 7 else (s >> (k + 1)) & 1
        out |= rule(left, (s >> k) & 1, right) << k
    return out


SUCC = {a: [(strip_step(a, 0, s), strip_step(a, 1, s)) for s in range(256)] for a in (0, 1)}


def image(a, S):
    out = 0
    for s in range(256):
        if (S >> s) & 1:
            u, v = SUCC[a][s]
            out |= (1 << u) | (1 << v)
    return out


def mac(q, S):
    S = image(1, S)
    for _ in range(q):
        S = image(0, S)
    return S


def sub(A, B):
    return A & ~B == 0


def escape(word):
    """An ordinary right half whose strip after the word is outside G, or None. Exact cone: sites 1..8+T."""
    drive = [b for q in word for b in [1] + [0] * q]
    T = len(drive); W = 8 + T
    n = [0]
    def v():
        n[0] += 1; return n[0]
    cl = []
    TRUE = v(); cl.append([TRUE])
    x = [[None] + [v() for _ in range(W)]]
    for t in range(T):
        p = x[-1]; row = [None]
        for i in range(1, W - t):
            l = (TRUE if drive[t] else -TRUE) if i == 1 else p[i - 1]
            z = v()
            for va, vb, vc in itertools.product((0, 1), repeat=3):
                f = va ^ (vb | vc)
                cl.append([(-l if va else l), (-p[i] if vb else p[i]), (-p[i + 1] if vc else p[i + 1]), (z if f else -z)])
            row.append(z)
        x.append(row)
    fin = x[T][1:9]
    for g in range(256):
        if (G >> g) & 1:
            cl.append([(-fin[k] if (g >> k) & 1 else fin[k]) for k in range(8)])
    with Cadical195(bootstrap_with=cl) as s:
        if not s.solve():
            return None
        m = set(l for l in s.get_model() if l > 0)
    right = [1 if x[0][i] in m else 0 for i in range(1, W + 1)]
    row = right[:]
    for t in range(T):
        row = [rule(drive[t] if i == 0 else row[i - 1], row[i], row[i + 1] if i + 1 < len(row) else 0) for i in range(len(row) - 1)]
    state = sum(row[k] << k for k in range(8))
    assert not (G >> state) & 1, 'a SAT model did not replay'
    return int(''.join(map(str, right[::-1])), 2), state


def main():
    checks = [('mac 9 A0 in A1', mac(9, A0), A1), ('mac 9 A1 in A2', mac(9, A1), A2), ('mac 9 A2 in A3', mac(9, A2), A3),
              ('mac 9 A3 in A3', mac(9, A3), A3), ('mac 17 A3 in G', mac(17, A3), G), ('mac 9 G in G', mac(9, G), G)]
    print('K. the kit\'s inclusions, recomputed: %s' % ', '.join('%s %s' % (name, 'yes' if sub(a, b) else 'NO') for name, a, b in checks))
    print('   |G| = %d states' % bin(G).count('1'))
    L = range(9, 17)
    up3 = [w for w in itertools.product(L, repeat=3) if sub(mac(w[2], mac(w[1], mac(w[0], A0))), G)]
    up2 = [w for w in itertools.product(L, repeat=2) if sub(mac(w[1], mac(w[0], A0)), G)]
    print('U. free exterior: three-gap words into G: %d: %s' % (len(up3), up3))
    print('   two-gap words into G: %d' % len(up2))
    claimed = [(q, 16, 16) for q in L] + [(16, 10, 15), (16, 10, 16)]
    print('   equals the ten words of I85: %s' % (sorted(up3) == sorted(claimed)))
    no_esc3 = []; esc3 = 0
    for w in itertools.product(L, repeat=3):
        e = escape(w)
        if e is None:
            no_esc3.append(w)
        else:
            esc3 += 1
    print('L. ordinary histories: three-gap words with an escape: %d; without: %d: %s' % (esc3, len(no_esc3), no_esc3))
    no_esc2 = [w for w in itertools.product(L, repeat=2) if escape(w) is None]
    print('   two-gap words without an escape: %d' % len(no_esc2))
    print('   exactly ten three-gap words force G for every ordinary right half, the same ten: %s' % (sorted(no_esc3) == sorted(claimed)))


if __name__ == '__main__':
    main()
