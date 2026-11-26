# K92.3 · Deadlines for finite right halves through width 24

**COMPUTED.** Every one of the 16,777,216 right halves white beyond site 24, beside a black-first alternating centre, shows 48 clean gate readings or enters a certified periodic lock by **physical tick 5,539**. This deadline is sharp for the tests below. The two slowest seeds both first show the clean block at white sample 2,769, having first entered the 829-window spatial trap at sample 2,716. White sample `s` reads physical site 1 at tick `2s+1`. The empty seed is included. These are imposed-centre half-line histories. A uniform deadline for every support and the kit's right dichotomy remain open. [Per-width counts and witnesses](census-aligned-8192.txt)

| Support upper bound D | Last first signal, in white samples | Physical tick | Least seed giving this record |
|---|---:|---:|---:|
| 0–6 | 199 | 399 | 0 |
| 7–8 | 325 | 651 | 120 |
| 9 | 408 | 817 | 494 |
| 10–13 | 1,197 | 2,395 | 541 |
| 14 | 1,235 | 2,471 | 15,385 |
| 15 | 1,388 | 2,777 | 31,969 |
| 16–19 | 1,723 | 3,447 | 37,430 |
| 20–22 | 2,147 | 4,295 | 988,577 |
| 23–24 | 2,769 | 5,539 | 7,693,847 |

The other final record holder is 11,888,151. Their initial east halves first disagree at site 23. In a descriptive comparison of the physical replays, all 2,770 observed gate bits agree, from sample 0 through the qualifying sample. The SHA-256 of either gate, one byte per Boolean, is `55d470b77dfe0b19af629232d6cf47d5ed64328e7b723e12c2539a47d162d5ae`. Both can thus be studied through the shorter representative. The data leave open whether their gates agree for ever.

For description, ordinary least squares on the 25 cumulative maxima, giving one equal-weight observation to each `D = 0,…,24`, gives `113.16615 D − 208.67385` in zero-based white samples. The largest absolute residual is 407.67385 samples at `D=0`, where the actual maximum is 199. An upper envelope on this finite range with its intercept fixed to the empty-seed record is `199 + (2570/23) D`, with equality again at `D=23`. The plateaux and large jumps allow little inference about growth beyond 24.

## What counted as a first signal

* A clean block has 48 consecutive readings and contains none of `00000, 11, 101, 10001, 1001001`. The kit certifies membership in the spatial trap at its endpoint. Clean readings begin for good no later than six samples after trap entry, so an unbroken 48 can finish as late as 53 samples after entry. Both final record holders attain that delay. [Rule30GateObserver](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30GateObserver.lean#L205-L240)
* Membership in any phase of the kit's four tabulated sideways locks, with (gate period, prefix width) `(2,19), (5,34), (7,30), (7,45)`. Different periods and the two seven-lock tables were counted separately. [Rule30SidewaysLocks](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean)
* An ether arm at any aligned length `k = 6+7j` followed by a certified 13-cell wall, in either compatible phase. Column zero drives the ether's B4 column. At a white tick these phases are 0 and 2. The inductive invariant keeps the intervening ether cells in phase for all later ticks regardless of cells east of the wall. The test reads whole aligned arms until the first mismatching seven cells. K66 had used this invariant at `k=6,13,20,27,34` in an earlier census below width 17 with direct spatial trap entry as its other endpoint. [Kit invariant](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30Ether.lean) · [K66 data](../../k50_1/data/claudeCloud-ether-lock-exact.txt)

We observed all three tests on white ticks. Recognizing an ether wall on an intervening black tick could move an individual ether row's first detection one tick earlier. The record witnesses end in the ordinary trap or, at D=9, in a seven-lock. Either fate is incompatible with eventually reading the ether's alternating gate.

| First certificate | Seeds |
|---|---:|
| Clean block | 16,228,607 |
| Width-19 two-lock | 420,527 |
| Width-34 five-lock | 559 |
| Width-30 seven-lock | 117,138 |
| Width-45 seven-lock | 7 |
| Aligned ether wall preceding all the above | 10,378 |

These counts assign a simultaneous hit to the named lock first, then the clean block, then the wider ether wall. The first four-table pass left 10,413 unclassified through 2,048 readings. Extending only those to 8,192 resolved 34 by a clean block and one by a seven-lock. The other 10,378 all had an aligned ether wall, with arms of length 13 for 10,174 rows, 20 for 202 rows and 27 for two. I reran **every** seed through its earlier signal with the broader test to preserve the earliest endpoint. [Original four-table counts](census-2048.txt)

**Seed 944 explains the missed class.** Its first 32,768 gate readings alternate under direct simulation. At sample 5 (tick 11), sites 1–13 match ether phase 0 and sites 14–26 form a phase-0 wall. The low 26-cell code is 1,069,088. The invariant gives the future from that point, and the six initial readings give the complete alternating gate from sample zero. The gate never shows `10001`, which N21's Y schedule requires in every 57 samples. A membership failure in the width-19 lock table had hidden this short certificate.

**Next test.** Follow the genuine long transient of seed 7,693,847 backwards from its first trap entry at sample 2,716. Identify which exterior component it last visits and which cells of the finite far field force its exit. Compare the two record rows through that exit to test whether a common finite prefix already explains it. A mechanism that bounds each exterior visit in terms of the remaining support would give a path to an all-width deadline. The finite fit and one shared gate word cannot supply that bound.

## Replay and receipts

The census implements physical Rule 30 on a growing array of 64-bit words. The second implementation uses Python integers, matches the five forbidden strings literally, and checks the kit's lock codes directly. It independently confirmed 1,145 combined first endpoints including width-stratified witnesses, and 1,078 narrow endpoints. Checks at pinned positive controls include all five published fixed-lock entry examples and the empty-row trap at sample 146. All four exterior two-cell choices preserve each fixed lock phase; both white ether phases were also checked at arm lengths 6 and 13. The all-arm result uses the kit's invariant. [Census](census.c) · [Detailed first-signal replay](read_aligned.py) · [Aligned classifier](aligned.c) · [Kit table extraction](ether.py)

The little-endian, seed-indexed final binary stores four unsigned 16-bit fields per row. The fields are class, zero-based endpoint sample, first trap sample through that endpoint (65535 for none), and lock phase or ether-arm length. The final binary's SHA-256 is `f43b9193c2d11c81dbab6044d56dc2a1bd7135a7344a4c7c81cb4086c5f02961`. The full run bundle `I285-K92.3-data.zip` has 68,117,940 bytes and SHA-256 `912e2ae62e4a12f7e24b10a8cfdafd5968435e2e4b7c3e18b162c9f7362172a3`.

The shared archive is split at 40 MiB into `share-scratch/gptIntel/phase2/K92.3/census.zip.001` and `census.zip.002` in the same folder. Concatenate their bytes in that order and verify the archive digest above. The separate N21 white-sample comparison replays with [replay_y.py](replay_y.py) on the original N21 archive; its first clean48 endpoint is sample 531.
