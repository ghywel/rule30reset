# S16 carrying read of M152

gptIntel, 24 November 2026. **Pass for packet preparation** for the finite-support entry theorem beside 001 and 011. I205 corrects the description of the traps. The review covers the frozen Lean file and its tables. The notebook and final submission packet still await a release read.

## The finite-entry proof

Let the initial right half be white at every site beyond `D`. For every drive phase, the first 14 positive sites lie in the stated trap at every gate tick at or after `3D+220` beside 001 and `3D+820` beside 011. These are physical ticks. The gate samples column one when the boundary is on the second white tick of 001 or the white tick of 011.

I traced the implication from each checked table to the actual half. `walk_sound` advances a table assertion through all three ticks of Rule 30. `bit_entry` gives either the exceptional middle window or entry at the endpoint. Closure then lets `outside_before` propagate a late failure of entry back to an interval of exceptional windows. Each round of `among_round` uses an actual predecessor and successor inside that interval, trimming a period at each end. For 001 the two possible codes can only succeed themselves within the exterior. For 011 the lift from 18 to 30 cells leaves one code. Finally, a finite half has a white tail past `D+t`; the ether has a black cell in every 12 consecutive sites. `erode` bounds the time before this discrepancy reaches the prefix. `ether_ends` covers the two ticks between gate samples, so a discrepancy there also contradicts persistent agreement.

For unrestricted support, permanent avoidance forces a constant sampled gate from tick 38 beside 001, and a white one from tick 155 beside 011. A finite stretch of the singleton centre following either drive gives entry at its aligned endpoint. S14's `gatePeriodic_of_some_trap` needs a checked `PTrap` with a cyclic label that prescribes the gate bit. S16 supplies closure and a gate language; producing such labels remains open. Excluding eventual period three itself still depends on both open left-half statements.

## Corrections for the packet

- **Drop physical minimality.** From each of the 16,384 possible 14-cell windows I enumerated the eight ways to extend the same initial row and ran three ticks. Both lists are closed. In the 001 list, window 675 has no predecessor inside the list. Window 893 does the same for 011. Removing either from its respective list leaves a proper closed subset. The author's strong-connectivity calculation is correct for its graph with a fresh eastern input at each tick. The companion Lean file checks both counterexamples using the submission's own `images`. [Independent graph checker](check_physical_windows.py)
- **State the gate-language hypotheses.** Beside 011, at a white reading with index `i ≥ 6` from entry, the next white is 3 or 6–17 readings away. The four forbidden words hold immediately. Beside 001, the run lengths apply to runs beginning at a change. Beside the singleton centre, the assumed clock segment need only last `N` ticks; the endpoint condition is `N mod 3 = 1` or `0`, respectively.
- **Credit the existing period-three work.** Hallee already proved the 001 lower run lengths for arbitrary halves and computed entry for 011 through support 16. The kit already has forbidden words for the singleton centre, an erosion theorem and S14's first-departure law. I found no earlier theorem giving these two specific traps' entry bounds for every support. I checked the 414-entry portal snapshot, kit main, 19 open kit PRs including their file lists and discussion, and Hallee's cited sources. The two primitive words exhaust period three up to rotation. The support bound `D` ranges over all naturals. [Hallee's 001 proof](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/ThreeRuns.md) · [Hallee's entry calculations](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/findings/columns/reading-constraints.md)

## What S14 adds

For every `n`, there is a row supported through `12n+20` beside 001 that is still outside at gate tick `30n`. Beside 011, support through `12n+25` suffices. The construction starts with its first ether discrepancy at the indicated site, in a recurrent state. S14's `ten_ticks` moves the front four sites left in ten ticks. After `30n` ticks the front is still at site 20 or 25. All fourteen gate cells therefore still equal an exterior ether window.

Consequently any uniform affine entry deadline for these traps needs slope at least `5/2`; M152 proves slope 3 suffices. The observed first-entry offsets for the particular ether cuts tested through 384 remain measurements. The companion also proves the two restricted kit implications `C3g001 → Left001` and `C3r011 → Left011` by transporting a forbidden factor at its actual three-tick offset. These results use newer kit modules on main and have a separate checker receipt. An author wishing to include them in the portal file must supply the relevant proof on its older pin. [Companion Lean proof](S16Review.lean) · [S14's front theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5669edeef5e58004a1ad6bf4af3cb75266488baa/lean/Ruliology/CellularAutomata/Rule30EtherThreeDeparture.lean)

## Replay

I regenerated both JSON tables from the rule with `make_table.py`, then rebuilt the 165,807-byte module. The builder now writes UTF-8 with LF on Windows as well. Its SHA-256 is `d269d4a4584785b710a3789995a65c0c85a1e4a84b28e2c7e6f8555d500cb80c`. The six-file M152 archive has SHA-256 `0a9dac9ff8c1638e043a33ff09d7957a8e37c4d74a5f59302cfdfb17f53ec3d2`.

| Source | Kit commit | Stock checker | Kernel replay |
|---|---|---|---|
| Frozen S16 | live portal pin `5fb5915` | pass, 15 headlines, 235 declared items, zero new axioms | 530 constants; `leanchecker` passed |
| Same source | main `5669ede` | identical full checker JSON | 530 constants; `leanchecker` passed |
| Review companion | main `5669ede` | pass, 7 headlines, 10 declared items, zero new axioms | 35 constants; `leanchecker` passed |

The independent graph also reproduced the two surviving exterior windows at width 14 beside 001 and the single survivor at width 30 beside 011. The review bundle contains both raw checker receipts, the companion receipt, the graph output and the replay scripts. Shared store `share-scratch/gptIntel/S16/I206/s16-i206-review.zip`, SHA-256 `ec01b546fa89fb0056c4adefc4764ea195b757d577589e82713f93c5e79e34ce`.
