---
Template: ComputationalEssay
Name: An exact polygon for the black-cell and run-end counts at one site of Rule 30
Author: {AUTHORS}
Date: 2026-11-22
Description: At any site of any Rule 30 history, three sharp inequalities bound the black count and the run-end count, a linear inequality holds uniformly exactly when it holds at five explicit periodic histories, and every rational point of the resulting pentagon is the limit of one history.
Abstract: {ABSTRACT}
Keywords: [Rule 30, density, run ends, sources, polygon, single seed, period two, Lean]
Sources: ["[Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[Condrey's run-end density bound](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261110-21dc25)", "[Quint and Gemini's interval form](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261111-15cfcd)", "[Ulrey's two-block identities](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261106-2b2509)"]
---

## Two counts at one site

Watch one site of a Rule 30 history for T ticks. The history may be any evolution of the whole line: periodic, finite, or the single seed. Count two things.

- **C** is the number of ticks on which the site is black.
- **A** is the number of ticks on which the site is black and its right neighbour is white. On such a tick a horizontal run of black cells ends at the site. David Condrey calls this a run-end source.

Always 0 ≤ A ≤ C ≤ T. Condrey proved one more inequality between the three numbers, 3C ≤ T + 5A + 3. This entry finds the rest. There are exactly two more, and the five inequalities together are complete: no other linear inequality holds uniformly unless it follows from them. Nothing inside is missed either: every rational point of the pentagon they cut out is the limit of the two densities along one history.

## Three inequalities

| Inequality | Where it comes from |
|---|---|
| 3C ≤ T + 5A + 3 | Condrey, for arbitrary column streams; on every interval by Quint and Gemini. In the kit as Rule30SourceObservables. |
| 2C ≤ T + 2A + 1 | The site and its right neighbour are both black exactly when the neighbour turns white at the next tick. A column cannot turn white on two consecutive ticks. |
| 6C ≤ 5T + A + 5 | New. During one run of black ticks at the site, the neighbour is black on at most five of them. |

All three hold on every interval of every history, at every site (Rule30Submission.three_faces).

**The middle one.** C − A counts the ticks on which the site and its neighbour are both black. Rule 30 then turns the neighbour white. Conversely, when the neighbour goes from black to white, the site was black. So C − A is exactly the number of black-to-white steps of the neighbouring column. Matthew Payton Ulrey proved this at the centre of the single seed, for one tick and as a count, and Quint and Gemini's two-block laws contain the count too. The argument is the same at any site. Two such steps are never consecutive, which gives the inequality.

**The new one.** While the site stays black, its right neighbour can be black at most every other tick. After nine black ticks the kit's nine-black shield forces the neighbour white, and every later tick of the run still has nine black ticks behind it. So one black run pays for at most five ticks on which both cells are black. There are at most T − C + 1 black runs, so C − A ≤ 5(T − C + 1). The Lean proof replaces this count by a potential on six cells that loses a nonnegative amount at every tick.

**The constants cannot be lowered.** On one explicit history the three inequalities hold with equality, on intervals of three, nine and nine ticks (Rule30Submission.sharp_constants).

## Five histories at the corners

Divide by T. The pair (C/T, A/T) is confined, up to an error of order 1/T, to the pentagon with these corners. Each corner is attained exactly by a history that is periodic in space and in time (Rule30Submission.five_corners).

| Black density | Run-end density | Spatial period | Time period |
|---:|---:|---:|---:|
| 0 | 0 | 1 | 1 |
| 1/3 | 0 | 12 | 3 |
| 3/4 | 1/4 | 7 | 4 |
| 9/10 | 2/5 | 155 | 10 |
| 1 | 1 | 2 | 1 |

The next cell rebuilds the five histories from their rows, written as numbers with one bit for each cell. It checks that each row follows from the one before by Rule 30 on the ring, and counts C and A at the first two sites over one period.

```wl
ringStep[row_List] := BitXor[RotateRight[row], BitOr[row, RotateLeft[row]]];
film[codes_List, w_Integer] := Reverse[IntegerDigits[#, 2, w]] & /@ codes;
corners = {{"(0, 0)", {0}, 1}, {"(1/3, 0)", {1086, 3651, 996}, 12}, {"(3/4, 1/4)", {63, 1, 67, 100}, 7}, {"(9/10, 2/5)", {22364166761352886330248667905436134650317087919, 943260612036182369894495806319073627262730145, 25243588250845306632945480358184787135387500723, 38002158838135629437645119658196073906492981660, 15259041586202999734043493176161320457643975399, 15125989181040382708526709206527425412287510073, 15608807197675132236311395596094114999849702223, 14454267534527582520094306874066992432633109873, 16334798694532088711177678668394574799844590875, 12991227405587955460699643260428529581349301673}, 155}, {"(1, 1)", {1}, 2}};
cornerRow[{name_, codes_, w_}] := With[{f = film[codes, w], p = Length[codes]}, {name, w, p, AllTrue[Range[p], ringStep[f[[#]]] === f[[Mod[#, p] + 1]] &], Total[f[[All, 1]]], Total[f[[All, 1]] (1 - f[[All, Mod[1, w] + 1]])]}];
TableForm[cornerRow /@ corners, TableHeadings -> {None, {"corner", "width", "T", "obeys Rule 30", "C", "A"}}]
```

Three periods of the history at the corner (9/10, 2/5). Time runs downwards, and the two observed sites are the leftmost columns.

```wl
ArrayPlot[Join @@ ConstantArray[film[corners[[4, 2]], 155], 3], Frame -> False, PixelConstrained -> 4]
```

## Every uniform linear inequality

Take integers α, β and γ. Ask whether some constant K makes

α C + β A ≤ γ T + K

hold on every interval, at every site, of every history. The answer is yes exactly when the inequality holds, with K = 0, at the five corners (Rule30Submission.linear_bound_iff):

0 ≤ γ, α ≤ 3γ, 3α + β ≤ 4γ, 9α + 4β ≤ 10γ and α + β ≤ γ.

When it holds, K = 9|α| + 4|β| suffices (Rule30Submission.linear_bound_constant).

- **Why the five conditions are needed.** Run a corner history for many periods. An inequality that fails at the corner loses a fixed amount each period, and no constant K can absorb that.
- **Why they suffice.** The pair (α, β) points into the normal cone of one corner of the pentagon. There it is a nonnegative combination of the two inequalities that meet at that corner, among A ≥ 0, the three above, and A ≤ C.

The same five conditions decide the question when only nonzero finite seeds are allowed (Rule30Submission.finite_seed_bound_iff). A finite seed can copy any number of periods of a corner history inside a light cone, with one black cell placed beyond it.

```wl
n = 2000;
rows = CellularAutomaton[30, {{1}, 0}, n];
c0 = rows[[1 ;; n, n + 1]]; c1 = rows[[1 ;; n, n + 2]];
cC = Total[c0]; aA = Total[c0 (1 - c1)];
Graphics[{EdgeForm[Black], LightGray, Polygon[{{0, 0}, {1/3, 0}, {3/4, 1/4}, {9/10, 2/5}, {1, 1}}], Black, PointSize[0.025], Point[{cC/n, aA/n}], Text["single seed", {cC/n, aA/n}, {-1.3, 0}]}, Axes -> True, AxesLabel -> {"C/T", "A/T"}, AspectRatio -> 1, PlotRange -> {{0, 1.05}, {0, 1.05}}, ImageSize -> 330]
```

The dot is the centre column of the single seed after 2,000 ticks. It sits near (1/2, 1/4), in the middle of the pentagon.

## Each corner from any right half

The periodic histories are special. The corners are also reached by histories whose right half is arbitrary. Prescribe every cell at the sites j ≥ 0 at tick 0. Then some configuration of the whole line has that right half and, from a fixed tick W on, keeps both counts within a fixed distance of a chosen corner for ever (Rule30Submission.corners_from_any_right_half).

| Corner | W | The bound on the ticks W, …, W + T − 1 |
|---|---:|---|
| (0, 0) | 2 | C = 0 and A = 0 |
| (1/3, 0) | 6 | \|3C − T\| ≤ 3 and A ≤ 1 |
| (3/4, 1/4) | 21 | \|4C − 3T\| ≤ 3 and \|4A − T\| ≤ 3 |
| (9/10, 2/5) | 37 | \|10C − 9T\| ≤ 12 and \|10A − 4T\| ≤ 12 |
| (1, 1) | 3 | C = T and A = T |

Here C and A count the ticks W, …, W + T − 1, for every T. The left half does the steering. Rule 30 is a bijection in its left input, so the bits of the observed site can be chosen freely, and the kit's realization theorem supplies a left half that produces them. Each corner has a finite controller: it reads the W cells at the sites 0 to W − 1, the observed site among them, and chooses the observed site's next bit before it knows the cell at site W. Lean checks that the controller stays inside its table for both values of that cell.

## Every rational point of the pentagon

The corners are not the only points that are reached. Give the five corners whole-number weights w0, …, w4, in the order of the table, with sum K > 0. Run the five controllers in turn, in rounds. In round e, the controller of corner i gets its W steering ticks and then w_i e controlled ticks. One history follows this schedule for ever, and its right half is again arbitrary. Counting from tick 0, for every T,

60 K C differs from P T by at most K (60 K + 4317) √(2T + 2), where P = 20 w1 + 45 w2 + 54 w3 + 60 w4,

and the same holds for A with P = 15 w2 + 24 w3 + 60 w4 (Rule30Submission.every_rational_point). The two values of P/(60K) are the weighted averages of the corners' densities. So (C/T, A/T) converges to the point with weights w_i/K on the five corners, with an error of order 1/√T.

Every point of the pentagon with rational coordinates has such weights. So the possible rational limits are exactly the rational points of the pentagon. By the three inequalities and 0 ≤ A ≤ C, (C/T, A/T) can converge only to a point of the pentagon. It does converge to each rational point of the pentagon, for a suitable history, whatever the right half.

- **Why a square root, and how slowly.** A round costs a bounded error: 69 steering ticks in all, and the caps of the controllers. Round e lasts 69 + K e ticks, so about √(2T/K) rounds fit into T ticks. The convergence is slow. In a simulation outside Lean, equal weights bring both densities within 0.01 of their target after 60,000 ticks, while the schedule aimed at the corner (0, 0) still has black density 0.18.
- **Any order, any durations.** The file proves more than this schedule: the controllers can be visited in any order for any durations, and in every controlled stretch both counts stay within that controller's cap (schedule, in Rule30DensityMixtures).

## On the single seed

The single seed obeys the three inequalities like every history. Two things are special to it.

**Two corners are missed by a growing margin.** At any site j, set d(0) = |j| and d(k + 1) = 2 d(k) + |j| + 11. For every T ≥ d(k), counting from tick 0,

2T + 7A − 5C ≥ k − 4.

This is the distance, in counts, from the corner (3/4, 1/4) (Rule30Submission.margin_three_quarters). With 23 in place of 11, 6T + 3A − 8C ≥ k − 6, the distance from (9/10, 2/5) (Rule30Submission.margin_nine_tenths). So the single seed cannot follow either corner with bounded error: the error grows at least like the logarithm of T. These are counts. The ratios C/T and A/T could still converge to the corner. The reason is that a long stretch with no loss would make two neighbouring columns repeat with period 4 or 10, and such a repeat cannot reach the moving left edge.

**The middle inequality is the period-two question.** T − 2(C − A) at site j stays bounded as T grows exactly when column j + 1 is eventually periodic with period two (Rule30Submission.middle_bounded_iff_period_two). At j = −1 that column is the centre. So the centre column of the single seed is eventually alternating exactly when this count, read at the site to its left, stays bounded.

The slack in each inequality and the two margins, for the centre column over the same 2,000 ticks:

```wl
{n + 5 aA + 3 - 3 cC, n + 2 aA + 1 - 2 cC, 5 n + aA + 5 - 6 cC, 2 n + 7 aA - 5 cC, 6 n + 3 aA - 8 cC}
```

## Credit and scope

**Credit.**
- David Condrey: the run-end count and the first inequality (Rule30SourceObservables).
- Matthew Payton Ulrey: a black-to-white step of the centre is a black centre with a black left neighbour, for one tick and as a count (Rule30TwoBlockCounts). The middle inequality is that identity at an arbitrary site.
- G.P.J.W. Quint and Gemini: the first inequality on every interval, and the same count in their two-block laws.
- The kit: the nine-black shield (Rule30BlackRuns) and the realization theorem (Rule30Realization). Two of the controllers use the ether of Rule30Ether and the period-five lock of Rule30SidewaysLocks.

**What is new here:** the inequality 6C ≤ 5T + A + 5; the corners (3/4, 1/4) and (9/10, 2/5); the classification of every uniform linear inequality; the two growing margins on the single seed; and each corner, and every rational point of the pentagon, reached from an arbitrary right half.

**What is not proved.**
- The densities of the single seed. Nothing here bounds the black density of the centre column, and Problem 2 is untouched.
- Limits at the points of the pentagon with an irrational coordinate. The same schedule with slowly changing weights should give them. That is not formalized.
- That 155 is the least width of a history with time period 10 at the corner (9/10, 2/5): a computer search found no smaller one, and no theorem says so.

## Formal statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = {"Rule30Submission.linear_bound_iff", "Rule30Submission.finite_seed_bound_iff", "Rule30Submission.linear_bound_constant", "Rule30Submission.three_faces", "Rule30Submission.five_corners", "Rule30Submission.sharp_constants", "Rule30Submission.corners_from_any_right_half", "Rule30Submission.every_rational_point", "Rule30Submission.margin_three_quarters", "Rule30Submission.margin_nine_tenths", "Rule30Submission.middle_bounded_iff_period_two"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["KernelCheck"] &, heads]
```
