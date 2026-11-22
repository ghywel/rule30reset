# Which gaps must occur in a periodic sparse column?

Suppose a site of an ordinary Rule 30 configuration eventually repeats a pattern of single black pulses, with at least nine white ticks between consecutive pulses. Assume the initial row has a leftmost black cell, as the singleton does. Count the white ticks in each gap, including across the wrap of the period.

**The gap order must contain (12,10,9), (10,12), and (12,12) as consecutive factors. It must also use at least one gap of 13 or 14.** Thus 9, 10 and 12 are compulsory, and at least four distinct gap sizes are needed. The previous family criterion required (10,9) somewhere. This narrows a family of periods of every length. [Earlier ordered-gap theorem](ordered-gaps.md).

## Why a missing pattern excludes a period

AIOvernight’s ResetMixtures excludes a periodic word with a gap of at least 17, so only eight letters remain. The 33-tick phase theorem fixes the right-neighbor observation everywhere on a white phase except the second white tick. For a row with a leftmost black cell, the kit’s masked Jen argument forces the sampled observations to avoid eventual periodicity if the proposed periodic drive actually occurs. [ResetMixtures](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30ResetMixtures.lean) · [Phase theorem](sparse-word-growth.md) · [Finite-left masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean).

At a black pulse, record the first W right cells. An edge labelled q connects two rows when one ordinary configuration realizes both, q+1 ticks apart. Following these edges permits the unobserved cells to change at gap boundaries. Every continuous physical history is included. To test avoidance of a factor, add the length of its longest prefix currently matched and discard the transition that would complete it. A periodic candidate eventually stays inside a single strongly connected component. That component must have both observation colors and internal edges labelled 9 and 10. The last condition follows from the earlier ordered-gap theorem. [Exact one-gap physics and its limitations](ordinary-gaps.md).

Inside each qualifying component, start two equal-input walks at the same row. Independently, work backwards from all equal endpoints. If a pair can occur in both searches, its two rows lie on equal-input paths with the same start and end. When every such pair has the same observed color, the input and both endpoints determine the entire response. For a periodic input this forces every infinite response in the component to be eventually periodic. One way to see the last step is to align at a recurring state and input phase. Any two return words can be taken in either order. Equality of the two responses then forces a period. This contradicts masked Jen.

| Restriction tested | Ordinary width | Rows in qualifying components | Pairs reached forward | Pairs reached backward |
|---|---:|---:|---:|---:|
| Omit 12 | 16 | 243 | 4,265 | 3,770 |
| Omit both 13 and 14 | 22 | 9,720 | 3,600,543 | 4,461,467 |
| Avoid (12,10,9) | 16 | 782 | 40,248 | 91,280 |
| Avoid (10,12) | 19 | 1,304 | 81,656 | 54,930 |
| Avoid (12,12) | 21 | 7,178 | 1,855,623 | 2,777,386 |

Every row of the table has zero differently colored pairs in the intersection. At width 22 the tests covered all 64 choices of allowed alphabet containing 9 and 10. Exactly 40 have no equal-input branching of this kind. The other 24 contain either {9,10,12,13} or {9,10,12,14}; both minimal sets still allow branching at that width. This is a sharp boundary for that particular strip test. None of those positive strip results establishes a periodic column of the singleton.

A separate calculation admitted arbitrary exterior bits at every tick, used independently generated open-boundary graphs, and proved the two alphabet exclusions again at widths 19 and 24. A Python implementation enumerating ordinary completions directly confirmed all 1,165 common pairs for the width-16 alphabet without 12. For the three-letter factor (12,10,9), a second check at width 19 inspected 116,711 common pairs and found zero color differences.

## Lower bound on the length of a possible period

Enumerate primitive cyclic gap words at the forced factor (12,10,9), retain the lexicographically first such rotation, and check the other required factors. Repeatedly reading the candidate from the all-row width-26 observer until it reaches its sink or a fixed state gives a necessary test for indefinite input readability. A separate phase-labelled SCC test then checks whether the observed output on a fixed clock can remain nonperiodic.

| Number of pulses | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Primitive cyclic inputs retained for the phase test | 1 | 4 | 19 | 61 | 221 | 745 | 2,331 | 7,425 | 23,153 | 71,371 |

All these clocks are excluded. In each recurrent component the right-neighbor output eventually repeats with the original clock period. Lengths 7–12 needed widths through 25, lengths 13–14 through 28. One 15-gap survivor at width 29 was finally excluded at width 31. Five 16-gap survivors required widths 30, 31, 32, 32 and 35. Each eventually has the original clock period as an output period. The candidate and resolved-word sets were compared in full, by rotation, for all 71,371 sixteen-gap words. A second enumeration agreed on every candidate through length 12. Independent ordinary-graph replays of the hardest nine- and twelve-gap cases found only one recurrent output cycle each.

Including the earlier six-gap census, **the primitive period of any such column has at least 18 pulses and spans at least 206 ticks**. All 216,930 admissible seventeen-pulse clocks were eliminated, with the last resolved at width 34. That brings the exhaustive 7–17 total to 322,261. To check all remaining clocks of at most 205 ticks, the width-26 reader enumerated by total cost, counting q+1 ticks per gap. Exactly 1,740 eighteen-pulse clocks and one nineteen-pulse clock survived the word filters. All resolved by width 22 and there were no twenty-pulse candidates. Twenty-one pulses alone cost at least 210 ticks. The boundary values 18 and 206 are necessary conditions. [Earlier six-gap controls](physical-padding.md).

## Why finite forbidden lists miss some gap orders

The ordinary width-29 reader rejects (16,12ⁿ,b) for every n ≥ 1 and b in {9,13,16}, while every proper contiguous factor is readable in its recurrent component. The exponent means any number of consecutive gaps of length twelve. The upper proof closes a finite set of rows under the twelve-gap transition. The two proper sides have explicit closed extensions, with each individual edge replayed on an ordinary cone. Consequently no finite list of forbidden *input-gap words* characterizes this strip language. This is a property of the enclosing reader. Its readable proper factors need not occur on a singleton. The mixed shift is full at widths 3–6 and demonstrably needs unbounded forbidden lengths at every width 7–29. The width-29 construction and the small-width onset are in `I81/gap-only-strict-sofic.zip` and `I81/first-strict-width.zip`.

## Finite repetitions and recent third-party work

Troyusrex2’s open PR 379 bounds matching windows of the actual singleton’s three-letter observation starting from a positive age T. Our extension gives a finite obstruction inside any component where the input and the endpoints determine those observations. Suppose the drive repeats a word of P ticks, and each of the first r²+1 aligned starts has an observed window of length L inside one such component of r rows, ending at the same offset in the repeated word. Take windows comprising whole periods after the 33-tick warm-up. There are at most r² pairs of endpoints. Two windows therefore agree, with the second starting at most r²P ticks later. The PR’s bound gives **L ≤ T + r²P**. This uses a finite stretch of the drive and requires no hypothesis about its continuation. The kernel theorem takes the endpoint-decoding property as a hypothesis. It was checked against PR head `8026612`, separate from the merged kit. [PR 379](https://github.com/WolframInstitute/Rule30PrizeKit/pull/379).

The maintainer’s request on PR 378 concerned arbitrarily late singleton starts entering a particular incompatible regime, or a right-prefix criterion that forces its lock. The sparse result here supplies a different family exclusion, building on the merged grammar and reset theorems. Entry into the lock from PR 378 remains open. [Maintainer’s review](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378).

## Evidence and next question

The numerical component and product tables are finite computations. General Lean theorems connect ordinary edges, periodic input and the second-white observation to the physical exclusion. The stock checker also accepted the separate finite-repetition pigeonhole argument. The next question is whether an ordinary trajectory can maintain the distinction on any of the surviving four-letter alphabets. A positive at one finite width supplies a candidate for this test.


The primary packet `I82/periodic-gap-requirements.zip` was read back at SHA-256 `6000120f12a4b40e5ef224e794b0deff8ac34fd54a83d8e8608917d0b1694e62`. The ordinary-edge, required-label monitor and literal cyclic-word kernel receipts are respectively `I82/ordinary-alphabet-diamond-kernel-03df8b57a993.zip`, `I82/required-labels-automata-kernel-3e325b2dc8d6.zip` and `I82/literal-gap-period-kernel-291e2035fe6a.zip`. The first fixed-clock census is `I82/physical-clocks-7-12.zip` at `f54fbe44413f830150fd5a3a19770cdea927100bfd69c934d0cdb899370e2077`. The continuation `I82/physical-clocks-13-15.zip` was read back at `9ea733f5d8e7e7765ee36680b1c9bdc49c16041b086177d3bf5cede5a9e04a7d`. Together the two phase tests exclude 33,960 filtered primitive necklaces over lengths 7–15. The PR 379 extension passed three stock headlines with no new axioms. [Independent equal-input path verifier](check-gap-requirements.py).


The read-back packets for the three latest censuses are `I82/physical-clocks-16.zip` (SHA-256 `3792452174b5e5336cc863e117f78f7f7e3457d28efe583f934045b596d9eb38`), `I82/physical-clocks-17.zip` (`81c64351fe2e963eced123ed9c898861e2fd633ab29e9df9a088d186b8b2682b`) and `I82/physical-span-205.zip` (`f2ffe4333ad26a285da9c188736fbfd1bbc8eff10d5f0afa4ac020fcfa5af8c1`).
