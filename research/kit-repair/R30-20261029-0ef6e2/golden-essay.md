---
Template: ComputationalEssay
Name: The golden half-circle word at every phase beside a Rule 30 clock
Author: Gareth Herbert; Claude (Anthropic); GPT (OpenAI)
Date: 2026-11-23
Description: At every phase, long repeats in the golden half-circle word exclude it as the eventual even-time right neighbour of a Rule 30 clock.
Abstract: Suppose a Rule 30 row has a leftmost black cell at or left of the origin, and column zero eventually reads white at even ticks and black at odd ticks. For every real starting phase, its even-time right neighbour cannot eventually equal the golden half-circle word (`no_eventual_golden_neighbour`). The kit’s `Rule30FiniteMaskedJen` bounds how long two visible windows can agree beside such a clock. We prove that the golden word exceeds that bound at every phase. From scale three onward, one of six explicit lags at each scale gives an agreement interval whose excess is at least 0.0999 times the lag minus three. A quadratic unit sends floor changes to lattice points in a half-open strip. An exact cover of 27 intervals finds consecutive crossings at a lag whose approximating integer is even, and their sample times give the required repetition after any fixed transient. The cover treats one rotation angle. Problem 1 remains open for the single-seed centre column.
Keywords: [Rule 30, circle rotations, golden angle, half-circle coding, repetitions, Lean]
Sources: ["[Finite-arc rotation codes beside a Rule 30 clock](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-0ef6e2)", "[Every Sturmian word beside a period-two center](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8084e6)", "[The kit’s finite masked Jen theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean)", "[Günter Rote, Sequences with subword complexity 2n](https://page.mi.fu-berlin.de/rote/Papers/pdf/Sequences%2Bwith%2Bsubword%2Bcomplexity%2B2n.pdf)"]
---

## A repeat that a clock cannot support

Advance a point on the unit circle by $(\sqrt{5}-1)/2$ per sample and record which half of the circle contains it. One sample corresponds to two Rule 30 ticks. With twice the starting phase denoted by $\theta$, the bit at sample $t$ is the parity of $\lfloor\theta+t(\sqrt{5}-1)\rfloor$. Take the intervals closed on the left. Moving the starting point by half a turn exchanges the bits.

If the bits at $t$ and $t+q$ agree for every integer $a\le t\le b$, their **excess** is $b-2a-q$. Its dependence on the starting position matters. A long repeat occurring very late can have negative excess. For a centre that reads white on even ticks and black on odd ticks, equal visible bits on a window reconstruct equal left-column histories. The window form of Jen’s theorem bounds how long this can last before the moving leftmost black cell distinguishes the histories. A word with unbounded excess and lag, after any fixed starting time, therefore cannot be the even-time neighbour.

## Six lags at each scale

Write $d=\sqrt{5}$ and $(9+4d)^n=A_n+B_nd$. For each pair $(a,b)$ in the following list the corresponding lag is $A_n b-B_n a$. These are the six consecutive Fibonacci numbers $F_{6n+2}$ through $F_{6n+7}$, with $F_0=0$ and $F_1=1$. To see the indexing, the lists at scales zero and one are $(1,2,3,5,8,13)$ and $(21,34,55,89,144,233)$ respectively. Each entry and its Fibonacci counterpart advance six indices by the same recurrence $x_{n+2}=18x_{n+1}-x_n$, since $(9+4d)$ and $(9-4d)$ have sum 18 and product one and are the sixth powers of the two Fibonacci roots. The calculation gives all six at scale three.

```wl
families = {{-3,1}, {-4,2}, {-7,3}, {-11,5}, {-18,8}, {-29,13}};
{aa,bb} = MatrixPower[{{9,20},{4,9}},3].{1,0};
(aa #[[2]] - bb #[[1]]) & /@ families
```

At phase zero the second lag is 10,946. The first mismatch occurs at sample 17,711, so the prefix through sample 17,710 agrees with its translate and has excess 6,764. This is a direct computation on the word.

```wl
lags = (aa #[[2]] - bb #[[1]]) & /@ families;
q = lags[[2]];
bit[t_] := Mod[Floor[Sqrt[5 t t]] - t, 2];
firstMismatch = SelectFirst[Range[0,20000], bit[#] != bit[#+q] &];
{q, firstMismatch, firstMismatch-1-q}
```

## Why the estimate holds for every phase

Multiplication by $9-4d$ shrinks a signed displacement from its nearby even integer and preserves its parity. In rescaled lattice coordinates, each mismatch lies in a strip of width less than one. The height of a lattice point orders the signed mismatch times. Two consecutive crossings therefore give an actual run of agreement between them.

There are two real coordinates to control. In the first coordinate the proof uses 27 half-open intervals. For each intermediate integer height between a proposed pair of crossings, it supplies two consecutive integers on opposite sides of the strip. That rules out an intervening mismatch, even on an interval boundary. In the second coordinate the pair works on a closed interval, and one or two such intervals cover the required range. Every comparison is exact. The proof also covers a crossing before time zero by starting the resulting run at zero.

For every real phase and every scale $n\ge3$, the resulting interval has $b-2a-q\ge(999/10000)q-3$. Dropping a fixed initial segment changes the lower bound by at most twice its length. The phase, the time at which the clock starts and the time at which the visible word starts matching can all be chosen independently. If the clock is white on odd ticks, taking the row one tick later applies the same conclusion to the original odd-tick readings.

## Credit and scope

Erica Jen proved the left-edge obstruction for Rule 30. The kit’s `Rule30FiniteMaskedJen.window_jen_col` supplies the finite-window form used here. Our earlier finite-arc result applies when arbitrarily late continued-fraction digits exceed a threshold set by the cuts. The golden circle angle has every digit equal to one. [Jen, Global properties of cellular automata](https://doi.org/10.1007/BF01010579) · [Kit window theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean) · [Finite-arc exclusion, 0ef6e2](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-0ef6e2)

Our Sturmian result excludes mechanical words at every irrational slope and intercept. A further result gives an explicit horizon for repetitions of those words. Here the successive bit differences modulo two form the complement of a mechanical word of slope $\sqrt{5}-2$. Equal blocks of differences allow the underlying bits either to agree throughout or to be complements throughout. At a lag $q$, away from a crossing of the residual displacement, the parity of the integer nearest to $q(\sqrt{5}-1)$ decides which occurs. The ordinary convergents of $\sqrt{5}-1$ have odd numerators. The six lag families used here have even approximating integers, so their crossing-free intervals give agreement of the bits themselves. [Sturmian exclusion, 8084e6](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261023-8084e6) · [Explicit horizon for mechanical words, dc3d17](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261029-dc3d17)

Günter Rote studied these half-circle words through their factor complexity. They have $2n$ different factors of length $n$. Dvořáková, Medková and Pelantová determined the critical exponent and recurrence function of complementary symmetric Rote sequences. Our excess bound also controls how early a repeated factor begins, which is what the Rule 30 application requires. [Rote, Sequences with subword complexity 2n](https://page.mi.fu-berlin.de/rote/Papers/pdf/Sequences%2Bwith%2Bsubword%2Bcomplexity%2B2n.pdf) · [Dvořáková, Medková and Pelantová](https://dmtcs.episciences.org/articles/6519)

This cover works at every phase of one angle. Applying this method at another angle would require a cover for that angle. Whether the single-seed Rule 30 centre column is eventually periodic remains open.

## Formal statements and replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission.GoldenRotation." <> #) & /@ {"golden_repeats_at_scale", "unbounded_golden_repeats", "no_eventual_golden_neighbour"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[Last[heads]]["KernelCheck"]
```
