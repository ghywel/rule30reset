# A ten-white gap must be followed somewhere by a nine-white gap

Consider the Rule 30 evolution of any full-line initial row with a leftmost black cell. Fix any site, any onset and any rotation of a nonempty cyclic word made of isolated black pulses. Count white ticks strictly between consecutive pulses. **If the site repeats the word forever and all its gaps have length at least nine, every gap lies between nine and sixteen and some ten is immediately followed by a nine.** This applies in particular to the single-seed centre. The right half of the initial row may be infinite.

For instance, the repeating gap list `(9,10,11)` is excluded. Reversing it gives `(11,10,9)`, which survives this test. The theorem gives a necessary condition. Whether any surviving word occurs on the singleton remains open. Adjacency includes the last gap followed by the first.

## Why the order matters

At a black pulse, call the phase zero. On the next white ticks the phases are one, two, three and so on. Track the twelve cells immediately to the right, allowing either exterior bit at every tick. Twenty-seven clock labels suffice to remember whether the preceding gap was ten until the next gap reaches its tenth white. Exactly one edge closes a nine immediately after a ten. Removing that edge leaves 110,592 clock-and-row states and 278,528 exterior-labelled transitions.

An integer rank from 0 to 20 never increases along any remaining edge. Once it stops falling, the first right neighbor is white at the first white phase and black at phases three and later. The second white phase depends on a three-valued mode. Mode zero persists. The other two modes exchange across a nine and return to mode one across any longer gap. On the second white phase, mode two alone gives a black neighbor. At the pulse itself the target already makes the OR of the two cells black.

This works for nonrepeating legal drives too. If the drive repeats with period P ticks, its two-cell OR eventually repeats after 2P ticks. It repeats after P ticks whenever at least one gap is longer than nine. The kit's finite-left masked Jen theorem rules this out at any site of a row with a leftmost black cell. For any gap of seventeen or more, the kit's earlier eight-cell reset into G supplies the periodic mask, with the same finite-left conclusion. [Masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean) · [AIOvernight's reset-mixture result, PR 43](https://github.com/WolframInstitute/Rule30PrizeKit/pull/43).

## What survives a ten followed by a nine

Keep the exceptional edge and the same mode labels. In any finite interval containing B exceptional joins, at most **20 + 2B** ticks mispredict the two-cell OR or its next mode, counting a tick once if both fail. A second rank proves the local inequality `fault + next_rank ≤ rank + 2 × exceptional_join`. Adding it over the interval gives the bound. A closed 35-tick path in the width-twelve strip has two faults per join on every repetition. The coefficient two is therefore sharp for this strip and these labels. The example uses a freely chosen exterior.

There is also a physical example of the exceptional second-white behavior. Drive site zero with the repeated gaps `(9,9,14)` on a full-line history supplied by the kit's realization theorem. The initial positive half is the finite bit string `0x40400803d3a454ea5`, least significant bit at site +1. The ordinary orbit follows the active prediction on ticks 0 through 256 inclusive and first differs on tick 257. This gives seven complete periods and twelve more matching frames. The history need not have a leftmost black.

The order can be checked independently at width twelve. Call two strip paths a diamond if they start together, read identical gaps, disagree on the observed output, and return to the same state. The cyclic inputs `(9,10,10)` and `(13,10,9,12)` each admit a recurrent diamond and share exactly one ordered adjacent pair, ten followed by nine. Removing this pair eliminates all recurrent diamonds at this width. Removing the reverse pair leaves diamonds. Thus ten followed by nine is the unique single ordered pair whose removal works for this strip test. The alternating input `(9,10)` still contains that pair and has no recurrent diamond at this width.

## Sources and verification

**A periodic trace with these sparse pulses must have at least four black ticks per period.** With two gaps, the only cyclic list surviving the ordered-gap theorem is the alternating nine and ten. With three, rotating the required adjacency to the front leaves just `(10,9,q)` for q from nine through sixteen. In every one of these cases the first right neighbor itself eventually repeats the same word of phases: black on each pulse, white at the first two whites and black on every later white. At widths 12 through 18, propagating the set of every possible right row and both exterior bits reaches equality across one period. From that point the predicted bit agrees on every reachable row at every phase. This again contradicts finite-left masked Jen. A single gap is covered by the general theorem.

For the three-gap lists in increasing q order, universal agreement starts by tick 55, 56, 57, 58, 94, 24, 24 and 24 respectively when the initial pulse precedes the ten-gap. The two independent finite-set calculations agree on every case. These short-cycle supplements are computational certificates. The general ordered-gap theorem above has also passed Lean. [Standalone short-cycle check](check-short-cycles.py).

The four-pulse minimum also forces a period of at least 41 ticks: each black plus the following white gap uses at least ten ticks, and the required ten-white gap uses eleven. For the alternating two-gap case, the sharp onset for the standard right-neighbor word is tick 76 from the black before a nine or tick 87 from the black before a ten. Ordinary full-line histories with a finite positive half attain the last mismatch in each orientation.

WhiteEndNine excludes every constant gap of nine or more at the singleton centre. AIOvernight's GrammarRuns handles arbitrary orderings when all gaps are at least ten, and ResetMixtures handles any gap of seventeen or more when all are at least nine. I77 added all mixtures of nine with fifteen or sixteen. I78 adds mixed lists containing nine, such as `(9,11)`, lets the gap occupy the whole intermediate range and singles out one order at the join. [WhiteEndNine](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30WhiteEndNine.lean) · [GrammarRuns](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30GrammarRuns.lean) · [I77](README.md).

Run `python check-parity.py` from this directory. It uses the scalar Rule 30 update, reads the adjacent frozen certificate, tests all 286,720 exterior-labelled transitions including the exceptional edge, and replays the sharp cycle. The inequality also proves the settling result directly when B is zero. [Checker](check-parity.py) · [Certificate and cycle](parity-certificate.json.gz).

The source and receipts are on the private store under `share-scratch/gptIntel/I78/`.

| Packet | Evidence | Read-back SHA-256 |
|---|---|---|
| `gap-parity.zip` | All 54 phase kernels, scalar verifier, eight headline modules, 19 official headlines, 113 replayed declarations | `58e10858a35c084ac4cb167edcc164f4296233aefa75bb45ce7716e8a6be6283` |
| `I78-guarded-cyclic-leftmost-kernel-e3f022fdee3b.zip` | Literal full-line and singleton conclusions, modulo phase, same-period mask and large-gap branch, 28 official headlines | `e3f022fdee3beddd58d31c8aba196737fb25198708ef30ad9062233f32dd20c6` |
| `gap-diamond-boundary.zip` | Independent scalar graph checks, width obstructions and ordinary 257-frame prefix with stock/native replay | `2354a76c4d3cc0c21fe89358d463a4fcac0ff3da84ec88296a63238f2dc9668c` |
| `cyclic-order.zip` | Two independent diamond witnesses at width twelve, a wrap-sensitive example at width sixteen and per-tick replay | `3b2034c58dd28840d2882ac4e0637cfc410a9cafae61c1173c2552a04504d778` |

The first two packets use the kit at `40017e8` and Lean 4.35.0. Native and official replay passed with no new axioms. The physical exclusion appears as `GapFiniteFamily.all_sites` and `GapFiniteFamily.singleton` in the second packet. The next question is whether the surviving four-gap arrangements admit a common argument. The kit's prior all-sites WhiteEnd theorem already treats a single gap of ten or more. [WhiteEnd](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30WhiteEnd.lean#L435).
