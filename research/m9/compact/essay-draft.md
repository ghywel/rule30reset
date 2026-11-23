---
Template: ComputationalEssay
Name: When four runs of four 5-gaps can occur in the trapped Rule 30 gate
Author: {AUTHORS}
Date: 2026-11-23
Description: Two forbidden gap words beside an alternating column and two physical right halves that attain the neighbouring cases.
Abstract: {ABSTRACT}
Keywords: [Rule 30, alternating column, gate trap, gap word, finite certificate, Lean]
Sources: ["[Renaud Bosdure's gate trap](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261027-230bc7)", "[Gate-trap word exclusions](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261109-897fd1)", "[Packed driven prefixes in the Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit/blob/5fb591588cfa869bfdc47946799b5ddd70a903d1/lean/Ruliology/CellularAutomata/Rule30DrivenPrefix.lean)"]
---

## The word and the waiting time

Prescribe a column that alternates black, white, black, white, starting black at tick zero. Choose any initial right half. The gate is its first cell, immediately to the right of the prescribed column. Read the gate at odd ticks. One sample is two ticks.

Renaud Bosdure identified a closed set of 829 possible windows of the first sixteen cells. Once a window at an odd tick belongs to this set, the next black gate sample after a black sample is either three or five samples away. Write down those gaps. Call a run of four 5-gaps **closed** when there is a 3-gap on each side. Adjacent closed runs share their separating 3-gap.

Suppose the window is trapped at an odd tick. Two words obey the following bounds.

| Gap word | Gate samples, including both black endpoints | Earliest delay from which it is excluded |
|---|---:|---|
| `3 (5 5 5 5 3)⁴` | 96 | Two samples |
| `(5 5 5 5 3)⁵` | 116 | Zero samples |

The first delay is exact. A physical right half gives all four closed runs at delay one. A second right half gives three closed runs at delay sixty. The second exclusion follows from the first because the 96-sample word starts at offset 20 within the 116-sample word.

## Replay the two witnesses

Pack the initial right half into an integer with the gate in bit zero. Each tick uses Rule 30 with the prescribed colour as its left neighbour. This computation compares every black and white sample, including both endpoints of the word.

```wl
packedStep[row_, tick_] := BitXor[BitOr[BitShiftLeft[row, 1], Boole[EvenQ[tick]]], BitOr[row, BitShiftRight[row, 1]]];
closedWord[n_] := Module[{gaps = Join[{3}, Flatten[ConstantArray[{5, 5, 5, 5, 3}, n]]]},
  Join[{1}, Flatten[Table[Join[ConstantArray[0, gap - 1], {1}], {gap, gaps}]]]];
replayGate[a_, n_, delay_] := Module[{word = closedWord[n], last, rows, actual},
  last = 2 (delay + Length[word] - 1) + 1;
  rows = FoldList[packedStep, a, Range[0, last - 1]];
  actual = Table[BitAnd[rows[[2 (delay + i) + 2]], 1], {i, 0, Length[word] - 1}];
  {n, delay, Mod[rows[[2]], 2^16], Length[word], actual === word}];
examples = {{17911952117231624625415841284791634824617432618773606279499, 4, 1},
  {88769951030016947892698456558596051073035529750717722303543758321481268415460012, 3, 60}};
TableForm[replayGate @@@ examples, TableHeadings -> {None, {"closed runs", "delay", "trap code at tick one", "samples", "all match"}}]
```

The four-run witness gives trap code 44920 and matches 96 samples. The three-run witness gives trap code 40615 and matches 73 samples. Both trap memberships are checked in the Lean proof.

## Why every right half obeys the exclusion

Assume that four closed runs occur at delay two or later. Take the two samples immediately preceding the word. Both are in the trap. This gives 98 consecutive samples, numbered 0 through 97. Any such finite part of a physical right half agrees with a sufficiently long packed prefix throughout the observed interval.

To each spatial prefix the certificate assigns a set of possible sample times, stored as a bit mask. Every starting trap window has time zero. Whenever two Rule 30 ticks take a row with time i to a row with the required next gate colour, the new row must have time i+1. The checker splits input prefixes into both possible next bits. The next output bit is determined once the input has two additional cells. A whole branch closes when every candidate time from the source is already covered at the destination. Lean verifies these inclusions, the starting windows and the word's colours.

An occurrence would therefore put time 97 in the mask for its final row. The union of all the masks omits time 97. This excludes the word for any right half satisfying the trap condition. The result adds two words and two witnesses to the alternating-column reduction for Problem 1.

## Formal statements and replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = {"Rule30Submission.no_four_runs_of_four", "Rule30Submission.no_five_runs_of_four", "Rule30Submission.four_one_sample", "Rule30Submission.three_sixty_samples"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

One kernel replay checks the module containing all four theorems.

```wl
rule30Submission["Rule30Submission.no_four_runs_of_four"]["KernelCheck"]
```
