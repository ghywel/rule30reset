#!/usr/bin/env python3
"""claudeCloud_window_local.py: how few consecutive ticks can a local argument guarantee a singleton in, after a first
clock loss?  (ledger K100, the carrying read of I321.)

Relative wheels 0..W after a first loss at a: wheel 0 is white, wheel 1 is the driver x, wheel 2 is black
(firstLoss_cascade_and_immediate_catch).  The driver's bits over P + L ticks and the bits of wheels 3..W at tick 0 are
free; everything else follows from the recurrence d(k+2)(t+1) = d(k)(t) xor (d(k+1)(t) or d(k+2)(t)).  This frees
more than any physical strip allows (the driver's antiperiod, deeper history and the clocks are dropped), so a
counterexample here does not refute a physical statement; an empty count proves the local statement.

    python3 claudeCloud_window_local.py

For L consecutive ticks P .. P+L-1, with P prior ticks, count the assignments where no tick of the window has an
isolated black 010 with its three cells inside wheels 0..W.  Zero means: every L consecutive ticks have a singleton
within a+W, once P earlier driver ticks are given, at every dyadic clock whose white interval reaches past a+W.
"""
import sys


def count(L, P, W):
    T = P + L
    total = 0
    witness = None
    for xbits in range(1 << T):
        x = [(xbits >> t) & 1 for t in range(T)]
        cols = [[0] * T, x, [1] * T]

        def dfs(k):
            nonlocal total, witness
            if k > W:
                total += 1
                if witness is None:
                    witness = ([c[:] for c in cols])
                return
            for init in (0, 1):
                col = [init] + [0] * (T - 1)
                for t in range(T - 1):
                    col[t + 1] = cols[k - 2][t] ^ (cols[k - 1][t] | col[t])
                # a singleton centred at wheel k-1 (cells k-2, k-1, k) at a window tick ends this branch
                if any(cols[k - 2][t] == 0 and cols[k - 1][t] == 1 and col[t] == 0 for t in range(P, T)):
                    continue
                cols.append(col)
                dfs(k + 1)
                cols.pop()

        # singletons centred at wheel 1 (cells 0,1,2) never occur: wheel 2 is black
        dfs(3)
    return total, witness


def main():
    print('L ticks | P prior | W wheels | assignments with no singleton in the window')
    for L in (2, 3, 4, 5):
        for W in (7, 9, 12):
            row = []
            for P in range(0, 9):
                n, _ = count(L, P, W)
                row.append(n)
            print('%d | 0..8 | %d | %s' % (L, W, row))
            sys.stdout.flush()


if __name__ == '__main__':
    main()
