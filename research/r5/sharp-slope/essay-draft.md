---
Template: ComputationalEssay
Name: Three ticks per cell is the optimal Rule 30 trap-entry slope beside period three
Author: {AUTHORS}
Date: 2026-11-25
Description: Arbitrarily long exceptional ether-front runs give sharp linear entry beside 001 and 011.
Abstract: {ABSTRACT}
Keywords: [Rule 30, period three, right half, ether, optimal slope, Lean]
Sources: ["[Perez Morales, the period-3 ether erodes](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-1fc962)", "[Exact departure from an ether prefix](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-f214f2)", "[Finite-half entry beside period three](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261124-629dac)"]
---

## The optimal slope

Drive the right half by a column repeating 001 or 011. At each gate tick, record its first fourteen cells. Write D for an upper bound on the initial rightmost black site. The preceding entry theorem gives deadlines 3D + 170 beside 001 and 3D + 820 beside 011. For every n, we give finite rows of support at most 7n + 26 and 7n + 31, respectively, whose window is still outside the corresponding trap at tick 21n + 1. Hence every uniform affine deadline has slope at least three in physical ticks per site. For every D at least 26 beside 001 or 31 beside 011, the worst entry time is within an additive constant of 3D.

## The inverse sweep

Compare the row to the period-three ether and mark the first differing site d. Perez Morales identified an exceptional state with d in class 10 and both d and d + 1 differing. The phase of site p at tick t is its ether class modulo twelve. For the exceptional state, a forward jump of eight cells takes the new front back to class 10.

Rule 30 determines the old left input from the new bit and the old middle and right inputs. Starting with two white sites on the east, sweep leftward to construct the finite predecessor. Suppose the output first differs from the ether at d + 8, with another defect at d + 9. At sites d − 1 through d + 9 the output is `00100111101`. The sweep forces old bits `11` at d − 2,d − 1 and `01` at d,d + 1 for all four eastern input pairs. The first pair agrees with the old ether and gives agreement all the way west. The second pair is the exceptional front at d. Inverting drops the support bound by one and preserves the imposed wall at the preceding tick.

The inverse can be checked directly on all four choices. Each row displays the eastern pair, the reconstructed pair at d and d + 1, and the pair at d − 2 and d − 1.

```wl
sweep[pair_] := FoldList[{BitXor[#2, BitOr @@ #1], First[#1]} &, pair, Reverse[IntegerDigits[2^^00100111101, 2, 11]]];
Map[Function[pair, With[{states = sweep[pair]}, {pair, states[[10]], Last[states]}]], Tuples[{0, 1}, 2]]
```

To use this repeatedly, start at time n with an exceptional front at d + 8n, using `01001` from that site eastward and white cells beyond. Its next front advances two cells and is recurrent. Take n finite preimages. The resulting initial support is at most d + 7n + 4. Forward evolution spends n ticks advancing eight cells at each tick, then one tick reaching the recurrent class. The exact recurrent-front law takes 20n more ticks to retreat to d + 2. The starting phases 0 beside 001 and 2 beside 011 put the final tick on the respective gate phases. The depths d = 22 and d = 27 put the initial front in class 10 and leave the full fourteen-cell ether window intact at the final tick.

```wl
base = IntegerDigits[2^^000100111110, 2, 12];
ether[j_, s_, p_, t_] := base[[1 + Mod[j + p + 4 (t + s), 12]]];
rule[l_, c_, r_] := BitXor[l, BitOr[c, r]];
inverse[row_] := Reverse[Rest[FoldList[{rule[#2, #1[[1]], #1[[2]]], #1[[1]]} &, {0, 0}, Reverse[Rest[row]]]]][[All, 1]];
seed[j_, s_, d_, n_] := Nest[inverse, Join[Table[ether[j, s, p, n], {p, 1, d + 8 n - 1}], {0, 1, 0, 0, 1}], n];
advance[row_, wall_] := MapThread[rule, {Prepend[row, wall], Append[row, 0], Join[Rest[row], {0, 0}]}];
front[row_, j_, s_, t_] := With[{width = Length[row] + 12},
  First[FirstPosition[MapThread[Unequal, {PadRight[row, width], Table[ether[j, s, p, t], {p, 1, width}]}], True]]];
paths = Map[Function[drive, With[{j = drive[[1]], s = drive[[2]], d = drive[[3]], n = 10},
  With[{rows = FoldList[advance[#1, ether[j, s, 0, #2]] &, seed[j, s, d, n], Range[0, 21 n]]},
    MapIndexed[front[#1, j, s, First[#2] - 1] &, rows]]]], {{0, 0, 22}, {11, 2, 27}}];
ListLinePlot[paths, DataRange -> {0, 211}, Frame -> True, FrameLabel -> {"Physical tick", "First ether defect"}, PlotLegends -> {"001", "011"}]
```

For n = 3 these are the support and window checks. The window code puts site one in the low bit. The picture underneath compares the row beside 011 with the aligned ether. Black marks a site of disagreement.

```wl
cases = {{0, 0, 22}, {11, 2, 27}};
evolveRows[j_, s_, d_, n_] := FoldList[advance[#1, ether[j, s, 0, #2]] &, seed[j, s, d, n], Range[0, 21 n]];
Map[Function[c, With[{rows = evolveRows[c[[1]], c[[2]], c[[3]], 3]}, {c[[3]], Length[First[rows]], 64, FromDigits[Reverse[Take[Last[rows], 14]], 2]}]], cases]
```

The expected rows (front depth, initial width, physical tick, gate window) are (22, 47, 64, 9278) and (27, 52, 64, 1992).

```wl
exampleRows = evolveRows[11, 2, 27, 3];
ArrayPlot[Table[BitXor[exampleRows[[t + 1, p]], ether[11, 2, p, t]], {t, 0, 64}, {p, 1, 52}], ColorRules -> {0 -> White, 1 -> Black}, FrameLabel -> {"Physical tick", "Site"}]
```

## How the eastern tail changes the result

The inverse sweep also works when the two eastern bits come from a prescribed tail. Its rows at consecutive ticks must satisfy Rule 30. With an ether tail the initial defects occupy a band of width w = 7n + 5 after an ether prefix. That prefix survives through tick 21n + 5 = 3w − 10. Paired with Perez Morales's 3w + 6 upper bound, this fixes the slope while leaving the best additive constant open. With a white tail beside 011, either chosen colour persists at every gate sample through tick 21n + 5 for some row white beyond site 7n + 17, from any starting phase. This gives the lower bound on the slope of a uniform deadline to see the opposite colour.

An infinite tail allows a different outcome. For each finite length there is a row sustaining that many exceptional jumps. Choose a shared initial bit on an unbounded family of those rows, then a second shared bit on an unbounded subfamily, and continue. The resulting row agrees on every finite prefix with witnesses of arbitrarily long runs. Checking the front after t ticks uses initial sites only through d + 9t + 1, including the cell just past the defect. Hence this one row has its first defect at d + 8t for every t. This answers the infinite-run question in Perez Morales's erosion entry. The proof gives existence by compactness. With the two designated alignments, non-ether rows can stay outside the S16 traps at every gate tick.

The inverse calculation is uniform in the length of the run. The upper bounds and trap tables are from the preceding entry theorem. The exceptional-state classification is Perez Morales's, and the recurrent retreat uses the exact departure theorem. Period-three exclusion for the single-cell orbit remains open.

## Lean statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission.SharpSlope." <> #) & /@ {"extend_back", "family", "delayed_001", "delayed_011", "sharp_001", "sharp_011", "late_001", "late_011", "extend_back_tail", "family_tail", "holds_tail", "erosion_slope", "constant_gate_011", "gate_slope_011", "endless", "not_eroded", "stays_001", "stays_011"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[First[heads]]["KernelCheck"]
```
