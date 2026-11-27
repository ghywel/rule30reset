"""Independent checks for claudeIntel_ladder.cpp (K92.1, ledger N36).

1. Brute force: for every even H up to a small bound, every seed Y < 2^H is run forward under the kit's
   zero-wall map F(Y) = (Y >> 1) ^ (Y | (Y << 1)); its trace is tested by a direct transcription of the
   kit's acceptance (GValid, E2Run with the Lean `delta`, `accept`/`gateNext`, the trap word factors),
   and the least popcount is compared with the search's table.
2. Witnesses: every seed the search reports is run forward again, its trace accepted, its popcount
   matched to the table, and its trace's kicks matched to the reported gaps.

usage: python -I claudeIntel_ladder_check.py LANG TABLE [BRUTE_H]
"""
import sys

def F(y):
    return (y >> 1) ^ (y | (y << 1))

def trace(y, H):
    out = []
    for _ in range(H):
        out.append(y & 1)
        y = F(y)
    return out

PAIRS = {(2, 2), (2, 4), (2, 5), (3, 3), (3, 5), (4, 5), (5, 2), (5, 3), (5, 5)}

def gvalid(b):
    m = len(b) // 2
    if m > 0 and b[0] != 0:
        return False
    if any(b[2 * j + 1] != 1 for j in range(m)):
        return False
    return all(b[2 * j] or b[2 * j + 2] for j in range(m - 1))

def delta(q, k):
    """Rule30Certificates.PeriodTwoWidth13.delta with m = 1, transcribed."""
    if q < 10:
        return 10 if k else (q + 1 if q < 9 else None)
    if q < 60:
        s, pi = (q - 10) % 10, (q - 10) // 10
        if k:
            if s % 2 == 1 and s >= 3:
                g = (s + 1) // 2
                if 2 <= g <= 5 and (pi == 0 or (pi + 1, g) in PAIRS):
                    return 10 + 10 * (g - 1)
            return None
        return q + 1 if s < 9 else None
    return None

def e2run(b):
    q = 10
    for j in range(1, len(b)):
        q = delta(q, j % 2 == 0 and b[j] == 0)
        if q is None:
            return False
    return True

def gate_next(a, g):
    return {(0, False): 1, (1, False): 2, (2, False): 3, (2, True): 0, (3, False): 4, (4, True): 0}.get((a, g))

def accept35(b):
    """Rule30ZeroCoastBridge.accept, transcribed."""
    if not b:
        return True
    if b[0] != 0:
        return False
    a = 0
    for t in range(1, len(b)):
        if t % 2 == 1:
            if b[t] != 1:
                return False
        else:
            a = gate_next(a, b[t] == 0)
            if a is None:
                return False
    return True

def gaps(b):
    ks = [t // 2 for t in range(0, len(b), 2) if b[t] == 0]
    return [ks[i + 1] - ks[i] for i in range(len(ks) - 1)]

def has_factor(gs, words):
    s = ''.join(map(str, gs))
    return any(w in s for w in words)

TRAP = ['333', '3353', '3533', '3553', '5533']

def accepts(lang, b):
    if lang == 'G':
        return gvalid(b)
    if lang == 'GE2':
        return gvalid(b) and e2run(b)
    if not accept35(b):
        return False
    if lang == 'GAP35':
        return True
    words = TRAP + (['3535353'] if lang == 'CORE' else [])
    return not has_factor(gaps(b), words)

def read_table(path):
    rows = {}
    for line in open(path, encoding='utf-8'):
        if line.startswith('#'):
            continue
        H, w, vis, gw, hx = line.split()
        rows[int(H)] = (w, gw, hx)
    return rows

def main():
    lang, path = sys.argv[1], sys.argv[2]
    brute = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    rows = read_table(path)
    # 2. witnesses
    nw = 0
    for H, (w, gw, hx) in sorted(rows.items()):
        if hx == '-':
            continue
        y = int(hx, 16)
        assert y < (1 << H), H
        b = trace(y, H)
        assert accepts(lang, b), ('witness rejected', H)
        assert bin(y).count('1') == int(w), ('weight', H)
        g = gaps(b)
        ks = [t // 2 for t in range(0, H, 2) if b[t] == 0]
        assert gw == ','.join(map(str, g)) + ';+' + str(H // 2 - ks[-1]), ('gaps', H)
        nw += 1
    print(lang, 'witnesses checked:', nw)
    # 1. brute force
    for H in range(2, brute + 1, 2):
        least = min((bin(y).count('1') for y in range(1 << H) if accepts(lang, trace(y, H))), default=None)
        w = rows[H][0]
        assert w.startswith('>') or int(w) == least, ('brute', H, least, w)
        assert not w.startswith('>') or least is None or least > int(w[1:]), ('brute bound', H)
    if brute:
        print(lang, 'brute force agrees for every even H up to', brute)

if __name__ == '__main__':
    main()
