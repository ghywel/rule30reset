---
Template: ComputationalEssay
Name: Rotation-Ordered Blocks Beside an Alternating Rule 30 Column When the Denominator Ratios Have Limsup Above Six
Author: {AUTHORS}
Date: 2026-11-26
Description: Lean with Mathlib. Two nonempty blocks of readings set in the order of an irrational rotation through an arc, from any phase, are not read beside an alternating column when the angle has arbitrarily large straddling approximants with denominator ratio above six by a fixed margin. This includes √10 − 3.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, circle rotation, rotation coding, continued fractions, bounded type, every phase, repetitions, Jen's theorem, period two, alternating column, Lean 4, Mathlib, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)", "[Two blocks set in the order of an irrational rotation do not stand beside an alternating column](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261125-301e35)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

Take a row `x` of rule 30 with a leftmost black cell `lo`. Suppose column `i` alternates from tick `start` on, white at the even offsets (`clock`). Read its right-hand neighbour, column `i + 1`, at the white ticks.

Turn a circle of length one by an irrational angle `α`, and ask at each step `n` whether the point `frac(nα + θ)` lies in the half-open arc `[0, γ)`, `0 < γ < 1` (`arc alpha gamma theta n`). Let the answer *in* stand for one nonempty block of readings and *out* for another, of any lengths (`len`, `bits`). Set the blocks one after another in the order of the answers, and lay the first reading at tick `start` (`reads`, from any reading `cutoff` on).

**The theorems**, in `Rule30Submission`:
- `RelativeCutSpan.above_six`: suppose that for one positive integer `g`, and for arbitrarily large `q`, there are a positive denominator `Q` and integers `p` and `p'` with `pQ − p'q = ±1`, the errors `qα − p` and `Qα − p'` of opposite signs, and `(6g + 16)q ≤ gQ`. Then no such row reads the blocks in that order, at any phase `θ` and for any arc.
- `RelativeCutSpan.sixes_excluded`: the same for `α = √10 − 3`, the positive root of `α² + 6α = 1`, with no hypothesis on approximants. Its partial quotients are all 6, and its convergents are `(q, 6q + p)` from `(p, q)`.
- `JenBlockWindow.excludes_blocks`: if the coded word has, for every cutoff and every surplus, two equal stretches long enough, then no such row reads it. `JenBlockWindow.visible_window` is the finite window of Jen's theorem that this uses.
- `RelativeCutSpan.three_failures` and `RelativeCutSpan.repeat_of_span`: the step that provides the equal stretches.

**By hand, outside Lean.** If the ratio of consecutive convergent denominators exceeds six by a fixed margin infinitely often, the hypothesis of `above_six` holds: consecutive convergents are unimodular and straddle `α`. In particular every angle with infinitely many partial quotients at least 6 is covered: with partial quotients bounded by `A` the ratio is then at least `6 + 1/(A + 1)` at those steps, and unbounded partial quotients give unbounded ratios. Take the next block boundary after the agreement and alternating clock have both started. If that is block `k`, advance the phase to `θ + kα` and start at the white tick bearing its first reading. For the other half-open convention, `(0, γ]`, each endpoint is visited at most once because the angle is irrational. Choose `k` past both possible visits. The two codings then give identical block tails. With unequal block lengths their earlier differences may shift the reading index, so use the actual white tick of the common tail as the new start.

## 2. Where it sits

| | Angles | Phases | Blocks |
|---|---|---|---|
| R30-20261023-8084e6 (ours) | every | every | one reading a letter (Sturmian words) |
| R30-20261123-6c3fa9 (ours, in the kit) | the golden angle, half-circle arc | every | as in that entry |
| R30-20261125-301e35 (ours, in the kit as `Rule30RotationBlocks`) | every | the two end orbits of the arc | any two nonempty blocks |
| this entry | limsup of consecutive denominator ratios above six | every | any two nonempty blocks |

With one reading a letter nothing here is new. Beside an alternating column the neighbour's black readings come 2 to 5 apart from white sample 35 on (`Rule30UniformEntry`), which leaves only arcs with both ends on one orbit, and their words are block codes of Sturmian words, excluded at every start (R30-20261023-8084e6, `Rule30ZeroWallDiagonals`), as R30-20261125-301e35 explains. What is new is every phase with blocks of unequal lengths, at bounded type.

## 3. Exploration

**Which angles.** The ratio of consecutive convergent denominators, for five angles. At `[0; 2, 6, 2, 6, …]` the ratio exceeds six by a fixed margin at every other step. The table shows the ratios and the largest of the four displayed values.

```wl
angles = <|"all six, Sqrt[10] - 3" -> Sqrt[10] - 3, "all seven" -> (Sqrt[53] - 7)/2, "[0; 2, 6, 2, 6, ...]" -> FromContinuedFraction[{0, {2, 6}}],
   "silver, Sqrt[2] - 1" -> Sqrt[2] - 1, "golden" -> (Sqrt[5] - 1)/2|>;
ratios[x_] := With[{d = Denominator /@ Convergents[x, 16]}, N[Rest[d]/Most[d], 6]];
Dataset[KeyValueMap[<|"angle" -> #1, "last four ratios Q/q" -> Take[ratios[#2], -4], "largest displayed ratio" -> Max[Take[ratios[#2], -4]]|> &, angles]]
```

The silver and golden angles are not covered. The golden half-circle is our entry R30-20261123-6c3fa9, at every phase.

**The three trials.** At `α = √10 − 3` the convergent denominators include `q = 228` and `Q = 1405`. With cutoff `H = 0` and `E = 6` extra letters, `S = q + E` and `6(H + S) = 1404 < Q`. A trial at `a` asks the coded word to agree with itself `q` letters later on `[a, 2a + S)`. If it fails, the next trial starts after the first mismatch. For 300 random arcs and phases, the trial that succeeds:

```wl
alpha = N[Sqrt[10] - 3, 60]; q = 228; S = q + 6;
trials[g_, th_] := Module[{c = Table[Boole[FractionalPart[n alpha + th] < g], {n, 0, 2000}], a = 0, k = 0, t},
   While[k < 3, k++; t = SelectFirst[Range[a, 2 a + S - 1], c[[# + 1]] != c[[# + q + 1]] &, None];
    If[t === None, Return[k]]; a = t + 1]; "none"];
SeedRandom[30];
Counts[Table[trials[RandomReal[{1/100, 99/100}, WorkingPrecision -> 60], RandomReal[{0, 1}, WorkingPrecision -> 60]], {300}]]
```

All 300 sampled cases succeed within three trials. The theorem gives a successful trial for every arc and phase at these parameters. Arcs and phases chosen against one lag can make all three trials fail when `Q = 6(H + S)`, so six is the boundary of this test at one lag; that construction is in the rule30reset record, by hand and computed.

## 4. The proof

1. **Crossings** (`three_failures`). A mismatch between the word and its shift by `q` means that the displacement `qα − p` from the current point crosses an endpoint of the arc. For a straddling unimodular pair, two crossings of the same end are at least `Q` steps apart, since `‖kα‖ ≥ |qα − p|` for `0 < k < Q`. With two ends, three mismatches span at least `Q`.
2. **Three trials** (`repeat_of_span`). The greedy trials give mismatches `u`, `v`, `z` with `z − u ≤ 3u + 3S + 3 ≤ 6(H + S)`. So if `6(H + q + E) < Q`, some trial succeeds, at a start of at most `4H + 3S`.
3. **Unequal blocks** (`above_six`, with the carried `envelopes`). The number of readings contributed by the first `n` letters has upper and lower linear bounds whose relative difference tends to zero, at every phase, for any two block lengths. Taking `E = 2⌊q/g⌋` pays the slope difference with one half and the constant errors and any surplus with the other. So the readings repeat on stretches longer than their second start by any prescribed amount.
4. **Jen** (`excludes_blocks`, `visible_window`). Equal stretches of readings give equal masked windows on the alternating column and its neighbour. The kit's finite-left masked Jen theorem (`Rule30FiniteMaskedJen.window_jen_col`) forbids such a window once it is long enough past the row's left edge, which the surplus pays. This holds at every site, also west of the seed.

## 5. What is not shown

- **That any right half reads such a word.** No right half of rule 30 is shown to read any of these words for ever, beside an alternating column. Finite tests do not refuse them: blocks of 18 and 28 readings at the all-seven angle are read for 520 readings by real rows, in the rule30reset record. So the class excluded here is not shown to be non-empty.
- **The all-phase silver and golden cases**, beyond the golden half-circle, and tests that use several lags at once.
- **The hand steps** of §1: the continued-fraction form of the hypothesis, the alignment of the reading's start, the clock's phase and the half-open convention.

## 6. Prior art and credit

- **Our entries:** R30-20261125-301e35 (`Rule30RotationBlocks`, in the kit), whose prefix sums and block positions are carried here; R30-20261123-6c3fa9, the golden half-circle; R30-20261023-8084e6, Sturmian words; R30-20261029-0ef6e2, finite-arc codings at large partial quotients.
- **The frequency transfer** through a nonerasing image of a Sturmian word is Boris Adamczewski's idea (*On the expansion of some exponential periods in an integer base*, arXiv:1205.0961, the proof of Proposition 4). Here it is made uniform in the phase, for any two block lengths.
- **The count of crossings** for interval codings is in Quang-Khai Nguyen's *Spectrum of the refined Diophantine exponent* (arXiv:2608.20191, §7). His results give finite ordinary exponents at bounded type; the ratio six for this three-trial repeat at every phase is the new step.
- **Repeats beside the centre:** Troy Lowry's *How soon can the readings beside the Rule 30 center repeat?* (R30-20261122-094213) bounds them for its own gap class.
- **Jen's theorem** in its masked and finite-left forms is the kit's (`Rule30MaskedJen`, `Rule30FiniteMaskedJen`, with G.P.J.W. Quint and Gemini's finite forms).
- **Search.** We searched the portal's 442 entries, the kit's catalogue and its open pull requests for rotation codings, Sturmian words, continued fractions and bounded type. We found the entries above and none at every phase with unequal blocks.

## The formal proof

The source uses Mathlib's real numbers and floors for the angle. It imports the kit's `Rule30FiniteMaskedJen` and `Rule30Realization`, both present at the verifier's kit revision, and seven narrow Mathlib modules. The parts of `Rule30RotationBlocks` that it uses, the prefix sums and block positions, are carried from the kit in their own namespace. Then come five modules of this entry, in four namespaces inside `Rule30Submission`: `WeightedRepeatTransfer`; `SeparatedArcCuts`, which also holds the frequency envelopes of `FreePhaseFrequency`; `JenBlockWindow`; and `RelativeCutSpan`, which holds the main headlines.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The six headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.RelativeCutSpan.above_six", "Rule30Submission.RelativeCutSpan.sixes_excluded", "Rule30Submission.JenBlockWindow.excludes_blocks", "Rule30Submission.JenBlockWindow.visible_window", "Rule30Submission.RelativeCutSpan.three_failures", "Rule30Submission.RelativeCutSpan.repeat_of_span"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.RelativeCutSpan.sixes_excluded"]["KernelCheck"]
```
