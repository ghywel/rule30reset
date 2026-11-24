# A periodic singleton centre cannot have only white gaps of nine or at least fifteen

I78 extends this to every cyclic list with gaps at least nine that avoids a ten immediately followed by a nine, at any site of an initial row with a leftmost black cell. [Ordered-gap theorem and independent replay](ordered-gaps.md).

Count a gap by the number of white ticks between successive isolated black ticks. Take any nonempty cyclic list of gaps, each either 9 or at least 15. The single-seed centre cannot eventually repeat the associated word, for any onset or rotation. The **new case** mixes 9 with 15 or 16, with no gap of 17 or more. For example, gaps 9 and 15 in any order, with arbitrary repetitions, are covered by one certificate.

The kit already excludes a constant gap of 9 (WhiteEndNine), arbitrary lists with every gap at least 10 (GrammarRuns), and arbitrary lists with every gap at least 9 when at least one is 17 or larger (ResetMixtures). The latter two results are from AIOvernight. The proof below changes the hypothesis on a whole family and permits two gap lengths below the previous reset threshold. [WhiteEndNine](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30WhiteEndNine.lean) · [GrammarRuns](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30GrammarRuns.lean) · [ResetMixtures](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30ResetMixtures.lean)

The I77 continuation locates the seven-gap word required for disagreement on each of the two minimal gap alphabets and checks its marked pulse on ordinary 21-tick histories. [All-order result and physical witnesses](i77-disagreement-context.md).

## The right neighbor under an irregular drive

Start at a black pulse. Label its phase 0 and the following white ticks 1 through 9, 15 or 16. Suppose the gap stream uses those three lengths in any order and reaches phase 15 infinitely often. After some time, the first right neighbor is **white at phases 1 and 2 and black at every later white phase**. This statement applies to any physical right half, even with infinite support. Its onset can depend on the history.

Take the twelve right cells as a binary row. Each step admits either incoming rightmost bit. There are 17 phases, 4,096 rows, and 155,648 directed edges when both exterior choices are counted. Each vertex has an integer rank from 0 to 7. Every edge preserves or decreases rank. On an edge that preserves an odd rank, the source phase cannot be 15. On an edge that preserves an even rank, the right-neighbor bit obeys the rule above at every white phase. An infinite path eventually keeps one rank. A path visiting phase 15 infinitely often must therefore settle at an even rank.

With a periodic input, the masked right-neighbor trace is then periodic too. At a black tick the mask is automatically black, and at a white tick the bit is fixed by phase. The kit's masked Jen theorem excludes this on a singleton column. This also explains why the intermediate theorem about a driven right half does not require the input gap sequence to repeat. [Masked Jen theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30MaskedJen.lean)

[Run the independent standard-library checker](check-rank.py). It constructs the rank by monotone iteration from zero and checks every transition on its fixed-point pass. The fixed point takes 54 updates. The gap list 9, 10, 9, 10 is outside the theorem. The width and the threshold 15 have not been proved optimal.

## A separate test with eight cells

The kit's width-eight captured set A3 has 45 states. Starting there, the following four-state machine recognizes a larger set of finite gap words that enter its 16-state set G. Gap inputs below 9 are outside its domain.

| Current state | 9 | 10 | 11–15 | 16 | 17 or more |
|---|---:|---:|---:|---:|---:|
| Start | Start | Start | B | B | G |
| B | C | Start | B | B | G |
| C | Start | B | B | G | G |
| G | G | G | G | G | G |

Consequently a periodic gap list whose repetition contains an accepted factor is excluded, even with arbitrary other gaps of at least 9. For instance 11, 9, 16 is sufficient. No two gaps below 17 send all of A3 into G. This latter minimality concerns the width-eight observation. The twelve-cell result above proves additional exclusions by following individual paths after their ranks settle.

## Verification and the next case

The ranked twelve-cell proof and all 17 phase checks compile in Lean 4.35.0. The seven main modules in the shared packet pass native replay and the stock kit checker at 40017e8. There are 22 checked headlines and 190 replayed declarations in those modules. The result is in internal review for a possible kit submission.

An independent C++ implementation also used the literal eight-entry Rule 30 truth table. It found 116,736 distinct edges after dropping duplicate exterior choices, 108,848 equal-rank transitions before deduplication, and 46,800 strict decreases. A separate strongly connected component calculation did not use the rank. It found three recurrent components and none containing both a phase-15 visit and a wrong white-phase bit. When a phase-15 tick occurs at least once in every P ticks, at most 4(P−1)+7 white ticks deviate over the whole observation. Each of the four possible odd ranks contributes at most P−1 constant-rank ticks and there are at most seven strict drops. This last bound is a counting corollary. A second paper consequence gives a finite deadline for a proposed periodic centre segment: applying the kit’s local Jen window in eight disjoint intervals forces eight rank decreases, exceeding the maximum of seven. The proposed inclusive endpoint is 256s+510P for onset s and period P. The exact endpoint is being checked in Lean.

The free-strip settling result also gives a paper corollary for the new mixed 9/15/16 family at any column of any configuration with a leftmost black cell, by applying the kit's finite masked Jen theorem. The supplied end-to-end Lean exclusion uses the singleton theorem. The next exact test is to admit a gap of 14 among the nines. At width 13 the relaxed graph for 9 and 14 has a recurrent component carrying both a phase defect and a non-nine gap. A proof allowing a periodic, nonconstant label at the exceptional white phase might handle it. [Finite masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean)

The primary proof archive on the private store is `share-scratch/gptIntel/I77/sparse-pulses-and-mask.zip`, SHA-256 `4d2ee4ac75bfd41eede02a34522bb8c3b7beafb5627ab487d6f4f7fb0663e3f4`. Pass a pinned kit checkout to replay.py. The independent C++ source, replay and component check are in `I77/gap-9-15-16-independent-review.zip`, SHA-256 `41553fb14b44d31d70d2cfce022fa89372776d9791123658d12c0d3643b6ff24`.
