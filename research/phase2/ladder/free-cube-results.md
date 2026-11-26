# K92.2 · Twelve checks past a finite west

**COMPUTED.** At width at most 48, with the nearest west cell pinned black at the even ticks before time 48, exactly 3,517 of the 16,777,216 eligible Rule 30 rows pass the next twelve even-tick checks. All 4,096 twelve-bit outcome words occur. Individual word counts range from 2,901 to 5,890. Multiplying the twelve observed marginal pass fractions predicts 4,085.67 all-pass rows. The checks are dependent on this cube.

## What was counted

The [separate kit ladder](kit_ladder.py) uses exact bitlength and checks the full kick constraints. At width 43 its white-first count is 23,148 at the support and 16 after twelve pairs of ticks. All 47 other widths tested (1 through 48) had none left at that final horizon. Its width-48 counts for zero through nine pairs are 60,042, 24,721, 9,644, 4,059, 1,603, 671, 346, 65, 16 and 0. The archive `share-scratch/gptIntel/phase2/K92.2/ladders.zip` contains both sets of tables, including the full histograms and both kit phases. SHA-256 `64dbcb923336796b3f60f7b64349b74631d3309d6c45306cbfc4047c83f74e9b`.

At physical width bound `W` choose `n` free wall readings before time `W`, pinning the readings of the other parity black. Sideways reconstruction gives one starting row per free word. Extend it by whites past depth `W`, and evolve forward beside the white wall. Check 1 reads the wall at the first pinned-parity tick at or after `W`. Check 12 is 22 ticks later. The three conventions are even pins at `W=2n`, odd pins at `W=2n`, and odd pins at `W=2n−1`. The last agrees with the opposite-phase first check in M10. At each width and phase the initial denominator is exactly `2^n`.

The full enumeration covers `n=1,…,24`, each of the three conventions, and Rule 30, the 90/150 hybrid, uniform 90 and 150, and the fixed plant with `L=1`. These counts track black pins. The kit's exact-width `S(W,2j)` has an additional restriction on kicks and a different denominator. [The two ladders and published proofs](sources.md)

| n | Width bound | Pin parity | Pass one | Pass two | Pass twelve | Twelve independent fair checks |
|---:|---:|---|---:|---:|---:|---:|
| 20 | 40 | even | 524,338 | 263,368 | 242 | 256 |
| 21 | 42 | even | 1,047,587 | 523,727 | 530 | 512 |
| 22 | 44 | even | 2,096,556 | 1,047,631 | 1,401 | 1,024 |
| 23 | 46 | even | 4,182,361 | 2,101,409 | 1,968 | 2,048 |
| 24 | 48 | even | 8,392,278 | 4,198,552 | 3,517 | 4,096 |
| 24 | 48 | odd | 8,413,212 | 4,206,564 | 4,007 | 4,096 |
| 24 | 47 | odd | 8,405,395 | 4,216,262 | 3,616 | 4,096 |

The preregistered departure greater than 1/16 from one half occurs even with thousands of survivors. At `n=22` the eleventh even check passes on 2,610 of the 4,388 ten-check survivors (59.48%), versus 50.05% over the whole original cube. At `n=24` the same conditional fraction is 7,739/17,046 (45.40%). The direction changes across widths. A next test is to evaluate the earlier spatial-window certificate on those two conditioned classes and identify which cancellation is lost. The two ratios do not give an all-width or all-check contraction.

## Products, controls and replay

For check number `j`, the computed Boolean polynomial is the indicator that the first `j` post-support checks **all** pass, in the `n` original free readings. A Möbius transform gives its algebraic normal form. At `n=24` the twelve even-phase degrees in order are 23, 23, 23, 23, 24, 24, 24, 24, 24, 23, 24, 24. The product indicators retain high degree even far down this finite survivor ladder.

At the same width, even phase, uniform rules 90 and 150 lose every row on the first check. The hybrid retains 8,388,608 at each of the twelve checks. Its survival indicator has degree one throughout. The planted control adds exactly one to each of the twelve Rule 30 counts, hence passes twelve on 3,518 rows. Its conjugacy replaces one truncated stripe by an immortal stripe. In the free cube this changes at most the all-black free word, which changes only the full-degree coefficient of each affected indicator. At width 47, odd phase, the exceptional row already passes the first check, and the planted first-check count agrees exactly. The high degrees and near-halving counts alone cannot exclude a finite immortal row. [Planted control and proof](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30PlantedSurvivor.lean)

The exhaustive physical enumeration through `n=5` independently matches every joint histogram for Rule 30, 90, 150 and the hybrid. The main and opposite-phase first degrees match the kit and M10 at every `n`. The linear controls use the exact affine image of the free-bit basis. All-zero indicator degree is encoded as −1. The source includes the build and invocation. [Census and control checks](free_cube.cpp)

Intel receipts, 26 November 2026 UTC. The TSV contains one row per `(rule,n,W,pin)`, with all twelve survivor counts and degrees. The sparse histogram uses bit 0 for the first post-support check. Free-cube source SHA-256 `aa4e364cdd25268b325c14fb3d8309d9ddf6a475ce387956baa15c12a12796a6`; `summary.tsv` (32,997 bytes) `df2201def96fa28c430a64aae8490376229c71dfe4d0f4916248b6e531a918b0`; `histograms.tsv` (6,234,051 bytes) `8fbc4f605ff2a16de1f83b11e8066d5fbbe1ccb49c4bb8e2af29ea18edad6e1f`.
