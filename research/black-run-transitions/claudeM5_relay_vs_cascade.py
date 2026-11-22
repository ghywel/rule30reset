#!/usr/bin/env python3
"""claudeM5_relay_vs_cascade.py: which (r, P) each black-run test excludes (ledger M95, PRIOR-ART P46).

  python3 research/black-run-transitions/claudeM5_relay_vs_cascade.py [N]

A period P of a column holds r consecutive blacks, then white (r < P). Three sufficient tests for "this period is
impossible", each transcribed from its Lean statement:
  - Bosdure, kit Rule30BlackRuns.no_long_black_run_quarter (single seed): 9 * ceil((P - r) / 4) <= r;
  - Norris, portal R30-20261023-603218, no_long_black_run_cascade (single seed): some j >= 1 and depth d with
    9 j <= r and P - r + 9 <= 4 * cascadePairs d j, where cascadePairs d j = j + extraPairs d j and
    extraPairs (d + 1) j = 2j/9 + extraPairs d (2j/9) (integer division);
  - the relay, gptIntel's Rule30PulseRelay.black_period with `seven` and the kit's nine-tick pair (every site of every
    row with a leftmost black cell): some j with 7 j + 2 <= r and P - r <= 4 j.
For every P < N (default 400) it counts the pairs each test excludes that the others do not, and prints the least
excluded r at a few periods. Norris's test is evaluated at depths 0 to 11, which is every depth that can matter here,
since extraPairs vanishes once 2j < 9 and j <= r / 9 < N / 9.
"""
import sys


def bosdure(r, P):
    return r < P and 9 * (-(-(P - r) // 4)) <= r


def extra(d, j):
    return 0 if d == 0 else (2 * j) // 9 + extra(d - 1, (2 * j) // 9)


def norris(r, P):
    return r < P and any(9 * j <= r and P - r + 9 <= 4 * (j + extra(d, j))
                         for j in range(1, r // 9 + 1) for d in range(12))


def relay(r, P):
    return r < P and any(7 * j + 2 <= r and P - r <= 4 * j for j in range(1, r + 1))


def main():
    N = int(sys.argv[1]) if len(sys.argv) > 1 else 400
    pairs = [(r, P) for P in range(2, N) for r in range(1, P)]
    only_relay = [q for q in pairs if relay(*q) and not (norris(*q) or bosdure(*q))]
    print('P < %d: %d pairs in all' % (N, len(pairs)))
    print('excluded by the relay and by neither Norris nor Bosdure: %d, first %s' % (len(only_relay), only_relay[:6]))
    print('excluded by Norris, not by the relay: %d' % sum(1 for q in pairs if norris(*q) and not relay(*q)))
    print('excluded by Bosdure, not by the relay: %d' % sum(1 for q in pairs if bosdure(*q) and not relay(*q)))
    for P in (24, 64, 100, 200, N - 1):
        least = [min([r for r in range(1, P) if f(r, P)] or [None]) for f in (bosdure, norris, relay)]
        print('P = %d, least excluded r: Bosdure %s, Norris %s, relay %s' % (P, *least))


if __name__ == '__main__':
    main()
