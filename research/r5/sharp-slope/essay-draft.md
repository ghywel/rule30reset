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

To use this repeatedly, start at time n with an exceptional front at d + 8n, using `01001` from that site eastward and white cells beyond. Its next front advances two cells and is recurrent. Take n finite preimages. The resulting initial support is at most d + 7n + 4. Forward evolution spends n ticks advancing eight cells at each tick, then one tick reaching the recurrent class. The exact recurrent-front law takes 20n more ticks to retreat to d + 2. The initial choices d = 22 beside 001 and d = 27 beside 011 put the final tick on the gate phase, with a full fourteen-cell ether window still present.

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

The inverse calculation is uniform in the length of the run. The upper bounds and trap tables are from the preceding entry theorem. The exceptional-state classification is Perez Morales's, and the recurrent retreat uses the exact departure theorem. Period-three exclusion for the single-cell orbit remains open.

## Lean statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission.SharpSlope." <> #) & /@ {"extend_back", "family", "delayed_001", "delayed_011", "sharp_001", "sharp_011", "late_001", "late_011"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[First[heads]]["KernelCheck"]
```
