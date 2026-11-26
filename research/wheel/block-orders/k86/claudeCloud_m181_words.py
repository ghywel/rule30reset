#!/usr/bin/env python3
"""claudeCloud_m181_words.py: the gap words for claudeCloud_m181_rho (ledger K86).

    python3 claudeCloud_m181_words.py all NMIN NMAX        every primitive cyclic gap word with gaps >= 2 and
                                                          NMIN <= sum of gaps <= NMAX, one per rotation class
    python3 claudeCloud_m181_words.py set 3,5 NMIN NMAX    the same with gaps from the given set only
    python3 claudeCloud_m181_words.py blocks KMAX         every primitive cyclic order of A = 3,5,5,5 and
                                                          B = 3,5,5,5,5,5 with at most KMAX blocks
A gap is the number of white-wall readings from one kick to the next; a kick is followed by a white reading, so
gaps are at least 2.  Words are printed as comma-separated gaps, least rotation, shortest first; a word of one gap ends in a comma.
"""
import sys


def necklaces(parts, nmin, nmax):
    out = []

    def rec(word, total):
        if nmin <= total <= nmax and word:
            n = len(word)
            if all(word <= word[i:] + word[:i] for i in range(1, n)):            # least rotation
                if not any(n % d == 0 and word == word[:d] * (n // d) for d in range(1, n)):   # primitive
                    out.append(tuple(word))
        for p in parts:
            if total + p <= nmax:
                if word and p < word[0]:
                    continue                                                    # cannot be a least rotation
                rec(word + [p], total + p)

    rec([], 0)
    out.sort(key=lambda w: (sum(w), w))
    return out


def main():
    mode = sys.argv[1]
    if mode == 'all':
        nmin, nmax = int(sys.argv[2]), int(sys.argv[3])
        ws = necklaces(list(range(2, nmax + 1)), nmin, nmax)
    elif mode == 'set':
        parts = sorted(int(x) for x in sys.argv[2].split(','))
        nmin, nmax = int(sys.argv[3]), int(sys.argv[4])
        ws = necklaces(parts, nmin, nmax)
    elif mode == 'blocks':
        kmax = int(sys.argv[2]); A = (3, 5, 5, 5); B = (3, 5, 5, 5, 5, 5)
        orders = necklaces([1, 2], 1, 2 * kmax)
        ws = []
        for o in orders:
            if len(o) <= kmax:
                w = ()
                for x in o:
                    w += A if x == 1 else B
                ws.append(w)
        ws.sort(key=lambda w: (sum(w), w))
    else:
        raise SystemExit(__doc__)
    for w in ws:
        print(','.join(map(str, w)) + (',' if len(w) == 1 else ''))        # a lone gap keeps a comma: "12," is one gap


main()
