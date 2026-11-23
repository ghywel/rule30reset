---
Template: ComputationalEssay
Name: Leaving the period-three ether of Rule 30: an exact time, and a gate statement for 001
Author: {AUTHORS}
Date: 2026-11-23
Description: When an aligned prefix of the period-three ether breaks, its first column departs at an exact time, whatever lies beyond. A gate statement replaces a refuted hypothesis for the word 001.
Abstract: {ABSTRACT}
Keywords: [Rule 30, period three, ether, front, trap, 001, Lean]
Sources: ["[The period-3 ether erodes, L. Perez Morales](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261024-1fc962)", "[AbsorptionT t001 is false](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261110-2eb8e7)", "[Moving walls in Rule 30](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261103-87ba7a)", "[L. Hallee, four traps for 001](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/Traps001.md)", "[L. Hallee, windows that can reach a trap](https://github.com/lhallee/rule30-open/blob/a3b4a64f8423bbc8380149a021f39e528b4ea189/Rule30Open/Columns/ReachRefuted.md)", "[T. Lowry, erosion from a white tail](https://github.com/WolframInstitute/Rule30PrizeKit/blob/80994b1/lean/Ruliology/CellularAutomata/Rule30WhiteTailErosion.lean)"]
---

## The question

Suppose the centre column of Rule 30 ended in 0, 0, 1 for ever. Beside it there is one periodic picture that fits: the kit's *period-three ether*, which repeats every 12 columns and every 3 ticks. Two things were known about the right half beside such a column. Perez Morales proved that a finite disturbance of the ether eats its way back to the centre, at average speed at least 2/5 once it is under way. And the kit reduced the word 001 to one hypothesis, that every finite right half ends in one trap (`AbsorptionT t001`), which was then refuted by a second trap.

This essay answers two questions. *When exactly does the ether give way?* And *what should stand in place of the refuted hypothesis?*

## The front has one path

Call the first column that differs from the ether the *front*. Its state is the class of its column, one of twelve, and whether the next column differs too. The kit's proof shows that 5 D + 2 t + ψ never increases along the front, for a potential ψ on these states. On thirteen of the 24 states, which are closed under every input from the right, one can take ψ to be the class itself (with one exception), and then 5 D + 2 t + ψ is *constant* (`rigid_path`). At a given tick the class of column D is D plus a constant modulo twelve, so this leaves one possible D: two disturbances that start alike at their left end have the same front at every later tick, whatever lies to the right (`same_path`). Every ten ticks it moves exactly four columns.

The next cell runs three different right ends behind the same cut of 40 columns: white, and two random ones. A black square is a cell that differs from the ether. The left edges agree square by square.

```wl
ether = {{0, 0, 1}, {0, 0, 1}, {0, 1, 1}, {1, 1, 0}, {0, 1, 0}, {0, 1, 0}, {1, 1, 0}, {1, 0, 1}, {1, 0, 0}, {1, 0, 0}, {1, 0, 1}, {0, 1, 1}};
eth[p_, t_] := ether[[Mod[p, 12] + 1, Mod[t, 3] + 1]];
step[row_, c_] := With[{r = Join[{c}, row, {0, 0}]}, Table[BitXor[r[[i - 1]], BitOr[r[[i]], r[[i + 1]]]], {i, 2, Length[r] - 1}]];
evolve[row_, ticks_] := FoldList[step[#1, eth[0, #2]] &, row, Range[0, ticks - 1]];
front[row_, t_] := LengthWhile[Transpose[{row, Table[eth[p, t], {p, Length[row]}]}], Apply[Equal]] + 1;
SeedRandom[30];
cut = Append[Table[eth[p, 0], {p, 40}], 1 - eth[41, 0]];
runs = evolve[Join[cut, #], 98] & /@ {ConstantArray[0, 40], RandomInteger[1, 40], RandomInteger[1, 40]};
fronts = MapIndexed[front[#1, First[#2] - 1] &, #] & /@ runs;
GraphicsRow[Table[ArrayPlot[Table[Boole[run[[t + 1, p]] != eth[p, t]], {t, 0, 98}, {p, 60}], ImageSize -> 200], {run, runs}]]
```

```wl
{Equal @@ fronts, First[FirstPosition[#, 1]] - 1 & /@ fronts}
```

All three fronts are the same list, and column 1 departs at tick 98 in each.

## The time of departure

For a front of this kind the tick at which column 1 first leaves the ether is a table of ten phases and five distances, continued by ten ticks for each four columns (`first_departure`). From an aligned prefix of any length N, at least 3, that breaks at the next tick, the front starts at column N in one of eight states; six of them are among the thirteen, and the other two reach them after one or two ticks. So the time is a formula in N, the class g of column N and one bit u (`departure_after_exit`), and twelve more columns cost exactly thirty more ticks. The drive can be any ether column, so this covers both words of least period three, 001 and 011.

```wl
small = {{1, 1, 1, 3, 1, 1, 5, 1, 3, 2}, {2, 2, 4, 8, 2, 6, 6, 4, 4, 3}, {3, 5, 9, 9, 7, 7, 7, 5, 5, 4}, {6, 10, 10, 10, 8, 8, 10, 6, 8, 7}, {11, 11, 11, 13, 9, 11, 15, 9, 13, 12}};
slot[g_, u_] := If[g == 8 && u == 1, 9, {0, 7, 4, 1, 8, 5, 2, 0, 6, 3}[[g + 1]]];
ticks[0, _] = 0; ticks[1, j_] := small[[1, j + 1]];
ticks[d_, j_] := 10 Quotient[d - 2, 4] + small[[2 + Mod[d - 2, 4], j + 1]];
exitWait[n_, g_, u_] := Which[g == 9 && u == 1, ticks[n - 1, 7] + 2, g == 6 && u == 1, ticks[n - 2, 7] + 3, True, ticks[n - 1, slot[g, u]] + 1];
trial[n_] := Module[{row = Join[Table[eth[p, 0], {p, n}], RandomInteger[1, 30]], next, g, u, sim},
  next = step[row, eth[0, 0]];
  If[next[[n]] == eth[n, 1], Nothing,
   g = Mod[n + 4, 12]; u = Boole[next[[n + 1]] != eth[n + 1, 1]];
   sim = First[FirstPosition[MapIndexed[#1[[1]] == eth[1, First[#2] - 1] &, evolve[row, 110]], False]] - 1;
   {n, sim, exitWait[n, g, u]}]];
SeedRandom[31];
results = Flatten[Table[trial[n], {n, 3, 40}, {12}], 1];
{Length[results], Count[results, {_, s_, w_} /; s != w]}
```

The first number counts the random right ends whose prefix breaks at the next tick, the second the times the formula is wrong.

## A trap that these starts never enter

The trap that refutes `AbsorptionT t001` has 52 columns, 153 states and period 15. Which right halves can ever be caught in it? Run backward from its states, cut to their first twenty cells, with every cell beyond allowed: the windows that can lead to it are 54,576 of the 3,145,728. No window of the aligned ether is among them, and none that starts with sixteen white cells. Since the set is closed under predecessors, a half that shows either at some tick is never in the trap from then on, whatever lies beyond those cells (`no_fifteen_after_ether`, `no_fifteen_after_white`). In Lean the set is three small automata that read a window from the right, and the closure is checked by one recursion along them. The method, refuting entry by a set of windows closed under predecessors, is Hallee's.

## The gate statement

Beside 001, column 1 is free only on the second white tick of each period. Call those readings the *gate*. In the kit's trap `t001` the gate repeats 1100000, and in the 15-trap it repeats 11000. The next cell reads the gate of the empty right half, which the kit shows to enter `t001` at tick 1,270, and of the kit's 48-cell witness for the second trap.

```wl
gate[start_, from_, count_] := Module[{w = start, bits = {}}, Do[If[Mod[t, 3] == 1 && t >= from, AppendTo[bits, BitAnd[w, 1]]];
   With[{f = 2 w + Boole[Mod[t, 3] == 2]}, w = BitShiftRight[BitXor[2 f, BitOr[f, BitShiftRight[f, 1]]], 1]], {t, 0, from + 3 count}]; Take[bits, count]];
{gate[0, 1270, 28], gate[266113541000008, 1270, 25]}
```

**The gate statement** (`GateEntry`): *beside 001, the gate of every finite right half, from every phase, eventually repeats 1100000 or 11000.* It names no trap. Entry of every finite half into either of the kit's two traps gives it (`gateEntry_of_traps`). And it excludes 001 (`not_eventually_001_of_gateEntry`): on the first white tick column 1 is eventually white, by the kit's skeleton, so a periodic gate makes column 1 periodic on all the white ticks of the centre, against the masked form of Jen's theorem. The same holds if the gate is only eventually periodic (`not_eventually_001_of_gatePeriodic`).

A statement about the gate seems the right one to keep, because lists of traps keep failing. Hallee found four traps for 001, no three of which catch every finite half, and left entry into the four open. We have computed, outside Lean, a fifth of 129 cells apart from all four, so entry into those four fails as well. Its gate is again 1100000. We also took every word of length 3, 6, 9 and so on to 30, up to rotation, as a drive, with every closed set of nine-cell windows beside it whose first cell is fixed at the white ticks, and followed each to the left, column by column: 35,792,568 words at length 30. The traps for 001 that arise have gate 1100000 or 11000 and no other, and none arises for 011. Programs and outputs are in the [repository](https://github.com/ghywel/rule30reset/tree/main/research/r5).

## Earlier work

The front and its 24 states, with the bound on its speed, are Perez Morales's (R30-20261024-1fc962, the kit's `Rule30EtherThreeErosion`, imported here). Exact front speeds on two other backgrounds, up to a bounded window, are in our `Rule30MovingWall` (R30-20261103-87ba7a). Lowry's `Rule30WhiteTailErosion` bounds the departure of a white-tailed half, and Quint and Gemini prove that a finite half departs arbitrarily late (R30-20261113-8ef4c4). The trap `trap001fifteen` and the first refutation are Hallee's, restated in the kit. So are the method of sets closed under predecessors, and the idea that entry into *some* trap of the word is the statement to keep.

## What is not claimed

`GateEntry` and `GatePeriodic` are open, and the exclusion of 001 is conditional on them. Nothing here says that a finite half ever enters a trap. For 011 only the departure time is claimed. The census and the fifth trap are computations.

## Lean statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission." <> #) & /@ {"Rule30EtherThreeDeparture.departure_after_exit", "Rule30EtherThreeDeparture.first_departure", "Rule30EtherThreeDeparture.same_path", "Rule30EtherThreeDeparture.rigid_path", "Rule30EtherThreeNoFifteen.no_fifteen_after_ether", "Rule30EtherThreeNoFifteen.no_fifteen_after_white", "Rule30EtherThreeGate.gateEntry_of_traps", "Rule30EtherThreeGate.not_eventually_001_of_gateEntry"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[First[heads]]["KernelCheck"]
```
