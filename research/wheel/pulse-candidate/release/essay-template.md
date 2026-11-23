---
Template: ComputationalEssay
Name: Two cells determine the next black pulse beside an alternating Rule 30 column
Author: {AUTHORS}
Date: 2026-11-23
Description: An exact return time from a spatial observation, with a finite consequence for the single-black-cell centre.
Abstract: {ABSTRACT}
Keywords: [Rule 30, alternating column, return time, period two, Lean]
Sources: ["[The 829-window gate trap](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261027-230bc7)", "[The empty right half](https://github.com/WolframInstitute/Rule30PrizeKit/pull/39)", "[Returns of 0101001](https://github.com/WolframInstitute/Rule30PrizeKit/pull/376)"]
---

## A pulse and its next return

Imagine watching a Rule 30 column alternate black, white, black, white. Call it site 0 and count sites to the right from 1. Inspect site 1 whenever site 0 is white. A black observation at site 1 is a pulse. Starting at the second white tick, two cells in the row at the pulse tell us the exact time of the next pulse, whatever lies farther right.

| Site 2 | Site 5 | White-to-white intervals until the next pulse | Physical ticks |
|---|---|---:|---:|
| White | White | 4 | 8 |
| White | Black | 2 | 4 |
| Black | White | 5 | 10 |
| Black | Black | 3 | 6 |

Thus when site 2 is white and site 5 is black, the next three white-time readings of site 1, including the present one, are black, white, black. In general, writing the measured colours as bits, the number of white-to-white intervals is 4 plus the bit at site 2 minus twice the bit at site 5. Every intervening white-time reading of site 1 is white.

## Why two sites suffice

At a white tick, eleven positive cells determine site 1 for the next ten physical updates. Each update uses only a cell and its two neighbours, with the boundary supplied by the alternating column. For every eleven-cell prefix starting with a black gate, direct evolution finds the first return and checks each earlier white reading. Even at the first white tick the return depends only on sites 2 through 5. The Lean theorem `next_gap` transfers this finite calculation to arbitrary infinite right halves.

After one white-to-white update, only six black-pulse prefixes of length five can occur. Reading outward from site 1, these are 10000, 10001, 10011, 10110, 11100 and 11101. The previous white row needs only seven sites to check this list. On all six prefixes the four-site calculation reduces to the two-site table above. Every pulse from the second white tick has such a previous row. At the first white tick the extra history matters. Starting with only site 3 black to the right of a black boundary, the measured pair predicts ten ticks and the pulse actually returns in six.

## Four finite starting rows

Encode the initial right half as an integer with site 1 in the lowest bit and all unlisted cells white. Starting the boundary black at tick zero, the following calculation evolves the actual cells. Each output row gives the seed, the two measurements at tick 3 and the elapsed physical time to the next black gate reading at a white tick.

```wl
step[r_, wall_] := BitXor[2 r + wall, BitOr[r, BitShiftRight[r, 1]]];
example[n_] := Module[{rows, r, g},
  rows = FoldList[step, n, Table[Boole[EvenQ[t]], {t, 0, 12}]];
  r = rows[[4]];
  g = First[Select[Range[5], OddQ[rows[[4 + 2 #]]] &]];
  {n, BitAnd[BitShiftRight[r, 1], 1], BitAnd[BitShiftRight[r, 4], 1], 2 g}
];
example /@ {15, 31, 7, 39}
```

The last column reads 8, 4, 10, 6. This gives a counting lower bound. Whatever function of the starting row one chooses, a single Boolean observation has only two possible values. A fixed decoder using that observation cannot return all four durations at the same age.

## A deadline on the genuine singleton

On the orbit started from one black cell, consider black-first centre alternation beginning at age A. Suppose the right neighbour is black at age A + 3. Read the two sites then and let d be the predicted gap in white-to-white intervals. If the centre agrees with the proposed clock at every tick from A through A + 3 + 2d − 1, the positive sites agree with the driven evolution through the endpoint A + 3 + 2d. In particular, the intermediate sampled gate readings must be white and the endpoint black. A premature pulse or a white endpoint therefore proves that the centre disagreed with the clock strictly before that endpoint. Ruling out eventual alternation would require showing that such failures must occur arbitrarily late.

## Earlier work

The kit's width-13 period-two analysis already restricts the late gap alphabet. Bosdure and collaborators proved the three-or-five alternative after entry into their closed gate trap. Lowry's empty-right-half argument also uses that alternative, and his seven-cell marker theorem concerns returns at a white site 1. Quint gives a two-step evolution law for the even-time right germ. The two measurements here select the next black-gate return on every right half, including times before trap entry. [Width-13 analysis](https://github.com/WolframInstitute/Rule30PrizeKit/blob/80994b1ae1e31c629367ec6133e2c3db63700a0a/lean/Ruliology/CellularAutomata/Rule30PeriodTwoWidth13.lean) · [Bosdure and collaborators](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261027-230bc7) · [Lowry's empty orbit](https://github.com/WolframInstitute/Rule30PrizeKit/pull/39) · [Lowry's return theorem](https://github.com/WolframInstitute/Rule30PrizeKit/pull/376) · [Quint's germ recurrence](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261102-75bd53)

## Lean statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission." <> #) & /@ {"next_gap_from_second_white", "no_one_bit_forecast", "first_white_can_fail", "singleton_clock_break"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[First[heads]]["KernelCheck"]
```
