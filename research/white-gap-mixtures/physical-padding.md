# A finite strip can branch on exponentially many physically excluded clocks

I79 bounded the gap strings readable on the width-27 strip where the second-white bit can vary. A natural next test was to keep only periodic inputs for which the *same input* permits different outputs. **That test has exactly the same exponential growth rate as the original reader. Even the clocks on which the ordinary Rule 30 dynamics provably settle have that full rate.** This gives a limitation of the strip test and a uniform way to construct false positives for it. [The I79 language and bound](sparse-word-growth.md).

More precisely, every readable word of n gap lengths embeds at a fixed offset in a cyclic word of n+289 gaps with both properties below. Each gap is between 9 and 16.

- On the width-27 strip, if the exterior bit can be chosen afresh at every tick, either of two different responses can be selected on **each repetition independently**.
- On every ordinary full-line history with that periodic drive, the right strip enters the kit’s absorbing set G. From then on the right neighbor is white on the first two white phases and black on all later white phases. Finite-left masked Jen therefore excludes the drive at every site of every initial row with a leftmost black cell, including the singleton.

## A clock with independently selectable responses

Start at a black pulse with the 27-bit right row 1,803,301, closest cell in the low bit. Read the following twenty gap lengths in order:

```text
14 12 14 12 12 10 9 10 10 10 10 12 12 12 12 10 12 11 14 14
```

Two exterior choices return the strip to its original row after 252 ticks. Their second-white observations differ at exactly one position, tick 92. Thus m repetitions have at least 2ᵐ distinct response words. Lean checks both walks directly from the Rule 30 update, the differing tick, and injectivity for every sequence of choices. [Rows and exterior bits](padding-witness.json) · [Independent per-cell replay](check-padding.py).

Both values at tick 92 can also occur on ordinary full-line histories with the same drive and the same initial 27 right cells. The finite positive initial rows `0x1ffffffffffffffff81b8425` and `0x1fffffffffffc7fe081b8425` give white and black respectively. Lean verifies both through the kit's realization theorem. The two exact relaxed walks cannot be reproduced in full. The black/white endpoint alternatives are genuine, while one prescribed 27-cell path already fails at the next pulse and the other at the second pulse. Both impossibility certificates passed lrat-check and cake_lpr.

Under indefinite repetition, every ordinary history enters G by 248 pulse intervals (3,078 ticks) from the displayed start, or 250 intervals (3,093 ticks) from any pulse in the word. In particular **13 consecutive copies send every ordinary history into G**. Width 34 still has a recurrent non-G strip and width 35 removes the last one. A second implementation obtained a sufficient 256-interval bound by a different elimination order. Once G is reached, arbitrary gaps of nine or more preserve it. [Kit reset and closure theorems](https://github.com/WolframInstitute/Rule30PrizeKit/blob/40017e8/lean/Ruliology/CellularAutomata/Rule30ResetMixtures.lean).

## Why the number of false positives is so large

The width-27 component has 163,889 pulse rows. From the specified row every component row is reachable in exactly **16 gaps**. Every row can return to it in exactly **13 gaps**. Both claims were checked by propagating sets for a fixed number of steps, independently in C++ and NumPy.

Take any readable gap word u. Choose a path reading it, add a 16-gap path from the specified row to its start, then add a 13-gap return from its end. Appending the 20-gap branching clock gives a word only 49 gaps longer than u. Appending thirteen copies instead gives an ordinary reset as well, for total overhead 289. In either case u is recovered by taking n letters after the first sixteen. Distinct inputs therefore give distinct outputs. The padding injection and the arbitrary binary choices are proved in Lean. The concrete component radii and higher-width physical capture are finite computations.

Let N(n) count the original reader's n-letter words and B(n) the marked n-gap clocks with both properties. Then N(n−289) ≤ B(n) ≤ N(n) for n ≥ 289. The upper inequality holds since a nonperiodic strip response must visit both colors recurrently. Because N is submultiplicative, its exponential growth rate exists. The two inequalities give the same rate for B, between **2.951 and 2.953 per gap**.

The conclusion persists for primitive clocks counted up to rotation. A nonprimitive word is a power of a readable root of length at most ⌊n/2⌋. The I79 upper bound gives at most 711 × 3^⌊n/2⌋ such words. The integer lower certificate gives N(m) ≥ 2.951ᵐ. Consequently there is at least one primitive, physically excluded clock with independent strip branching at **each gap count n ≥ 599**. Quotienting by the at most n rotations leaves the exponential rate unchanged. The threshold 599 is sufficient.

## Irregular drives and the next test

The same separation occurs without periodicity. Use the first thirteen letters of the displayed clock, then the ten gaps `12,12,10,12,11,b,9,9,14,14`, where b is independently 13 or 14 in every frame. Both choices complete a width-27 return and keep the selectable tick-92 bit. Yet every ordinary history reaches G within 309 pulse intervals (3,792 ticks) from the frame start, for all sequences of b. The all-pulse-phase bound is 311 intervals (3,814 ticks), verified at width 38. This provides a driver carrying one arbitrary binary input per frame whose ordinary right response eventually has a fixed value on every white phase.

The maintainer's request on PR 378 asks for a family or entry criterion. The fixed reset block and padding construction apply to every word of the reader. The spatial closure G and masked Jen are prior kit results. The open question is whether an efficiently verified test on *ordinary exterior histories* cuts the exponential growth rate of the surviving physical candidates. A first test is to require each selected strip transition to have an ordinary continuation through two consecutive pulse blocks, then measure the resulting input language. [Maintainer's request](https://github.com/WolframInstitute/Rule30PrizeKit/pull/378) · [GrammarRuns](https://github.com/WolframInstitute/Rule30PrizeKit/pull/36).

The first pulse of the displayed 252-tick clock already separates the two models. From the specified row, an exhaustive enumeration of the next fifteen initial right cells yields 13 possible ordinary endpoint rows. Free exterior bits produce 21. Each proposed 20-step path contains ten individual transitions that fail the ordinary one-gap check. All twenty failures are detected by retaining at most four extra right cells during the gap, even when those cells may be reselected independently before the next gap. Both values of the later tick-92 bit remain physically realizable.

An independent six-gap calculation also settled all 43,596 primitive rotation classes. Five width-16 clocks permit repeated independent branch choices. All five lose that ambiguity at greater width and are covered by one variable-gap reset family. The remaining period-doubled case also has periodic output. Together with I79, any actual periodic column with isolated pulses and gaps ≥9 would need **at least seven pulses and a span of at least 71 ticks**.

### Receipts and review

The native Lean checker and the kit's stock checker passed 15 headlines across six modules, replaying 258 declarations with no new axioms. These cover the padding injection, the fixed-clock criterion, the width-27 walks, independently selectable inputs and responses, and the ordinary pair at tick 92. Two implementations checked the physical reset bounds. The numerical graph and growth data are separate from the kernel proofs. All packets below were read back from `share-scratch/gptIntel/`.

| Packet | Evidence | SHA-256 |
|---|---|---|
| `I80/ambiguous-padding.zip` | Source, Lean checks, 27-cell graph and radii, ordinary witnesses and LRAT negatives | `893328b043890fe379570591b61671cc19de4e46d7753ba3009bdd26e4af4994` |
| `I80/physical-synchronizers.zip` | Independent stock-G capture bounds for both displayed languages and the six-gap family | `927f5657408904467f3cca04e6acdb5a22f6bb01163de6549cf551d2aa4d258c` |
| `I80/six-gap-separation.zip` | Complete six-gap census, finite physical controls, dual LRAT and defect-count bounds | `43b4b051b0fba9318d22353bef45be20053cb6c118c377572e38ac82777d2f42` |

This continuation is filed against I79 while the ledger awaits the owner's K57 rotation decision.
