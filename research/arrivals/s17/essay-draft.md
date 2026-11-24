---
Template: ComputationalEssay
Name: If the Rule 30 centre eventually alternates, Lowry's source net is aperiodic on each phase
Author: {AUTHORS}
Date: 2026-11-24
Description: The net and shell of Lowry, and the returns of the kicks, on the two phases of a centre that would alternate for ever; a local law, a closed set of 777 windows, and what nine readings decide.
Abstract: {ABSTRACT}
Keywords: [Rule 30, period two, source arrivals, right half, closed set, Lean]
Sources: ["[Source arrivals, T. Lowry](https://github.com/WolframInstitute/Rule30PrizeKit/pull/374)", "[Period two: every right half forces the left trace into a nine-pair gap language, AIOvernight](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261109-62afca)", "[The first return of a pulse beside an alternating column](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-78e431)", "[Four runs of four 5-gaps](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-71bab6)", "[Event returns, T. Lowry](https://github.com/WolframInstitute/Rule30PrizeKit/pull/376)"]
---

## The question

Grow Rule 30 from one black cell. No one knows whether the centre column is eventually periodic, and in particular whether it can end up alternating between black and white. Suppose it did. Then the cells to its right evolve beside an alternating column, and several things about them cannot repeat.

T. Lowry's *net* is one of those things. Call a black cell followed on its right by a white one a *source*. At each tick, count modulo two the sources at sites −1 and +1 and, one tick later, the source at site 0. The result is the net, and the exclusive-or of sites −2 and +2 is the *shell*. Lowry proves that the net of a periodic centre tail cannot be eventually periodic if two black ticks follow each white one (`Rule30SourceArrivals`). An alternating tail has one. Here is the result, **conditional on an alternating tail**: *then the net and the shell are not eventually periodic, on the white ticks alone or on the black ticks alone* (`both_phases`).

On an alternating centre the net is a reading of the right half. Write x and y for the first two cells to the right at a white tick, where x is the *kick*. The net is x xor y there. At the black tick after it, the net is the first cell and not the second. The shell equals the net on the white ticks and is its complement on the black ones.

## The local law

Beside any alternating column, take any right half, of any support, as a number whose low bit is the first cell. One period is a white tick, then a black one.

```wl
step[d_, x_] := BitXor[2 x + d, BitOr[x, BitShiftRight[x, 1]]];
tick[x_] := step[1, step[0, x]];
half[x_, n_] := NestList[tick, step[1, x], n];
kick[x_] := BitAnd[x, 1];
net[x_] := Mod[BitGet[x, 0] + BitGet[x, 1], 2];
black[x_] := With[{y = step[0, x]}, BitGet[y, 0] (1 - BitGet[y, 1])];
```

The kicks and the net then obey a law that involves no other cells. *The net is complemented at every white tick that is not a kick. At a kick the net just before was white, and kicks stand alone.* (`law_of_alt`). Here it is checked at sixty ticks of two hundred random halves.

```wl
SeedRandom[17];
law[x_] := With[{w = half[x, 60]}, With[{g = kick /@ w, a = net /@ w}, And @@ Table[If[g[[k + 1]] == 1, a[[k]] == 0 && g[[k]] == 0, a[[k + 1]] == 1 - a[[k]]], {k, Length[w] - 1}]]];
And @@ Table[law[RandomInteger[2^60 - 1]], {200}]
```

So the net counts down. It is black exactly when the next kick is an even number of white ticks away (`net_of_return`), and two successive nets are equal exactly at a kick whose net is white (`odd_of_equal_nets`). Call such a kick *odd*: its next kick is an odd number of white ticks later. Here are the kicks (top), the net and the odd kicks of the half whose only black cell is the fourth, over fifty white ticks. Its gaps begin 4, 5, 2, 5, 5, 5, 3.

```wl
w = half[8, 50];
ArrayPlot[{kick /@ w, net /@ w, MapThread[#1 (1 - #2) &, {kick /@ w, net /@ w}]}, Mesh -> All, ImageSize -> 700]
```

## A closed set

Keep the first twelve cells at a white tick, as a number from 0 to 4,095: a *window*. One period later its value depends on two cells more, so a window has four images at most. Start with the window of the white half after two hundred periods and add images until nothing is new.

```wl
images[x_] := Table[Mod[tick[x + 2^12 e], 2^12], {e, 0, 3}];
closed = FixedPoint[Union[#, Flatten[images /@ #]] &, {Mod[Nest[tick, step[1, 0], 200], 2^12]}];
Length[closed]
```

The set of 777 windows is **closed**: a half whose window is in it stays in it, whatever lies beyond (`stays`). Along it the kicks are two to five white ticks apart, and consecutive gaps are only nine of the sixteen pairs of them; and the gaps 2, 2, 5 never occur (`clean_of_set`). The graph shows the pairs that do.

```wl
pairs = {{2, 2}, {2, 4}, {2, 5}, {3, 3}, {3, 5}, {4, 5}, {5, 2}, {5, 3}, {5, 5}};
Graph[DirectedEdge @@@ pairs, VertexLabels -> Automatic, VertexSize -> Medium, ImageSize -> 320]
```

A half that is not in the set can be outside for ever only in one way: **every right half, of any support, either enters the set or, from some tick on, kicks once in four white ticks** (`every_half`, `enters_or_four`). Here are the white ticks at which two hundred halves of sixty random cells enter.

```wl
SeedRandom[9];
member = AssociationThread[closed -> True];
entry[x_, max_: 120] := LengthWhile[half[x, max], ! KeyExistsQ[member, Mod[#, 2^12]] &];
enters = Table[entry[RandomInteger[2^60 - 1]], {200}];
{Max[enters], Counts[enters] // KeySort}
```

## What the readings decide

In the set the kick is a function of the nets: **nine nets, at white ticks k to k + 8, give the kick at k + 6** (`kick_of_white_nets`), and two black nets, at k + 1 and k + 5, give the odd kick at k + 1 (`odd_of_black_nets`). In the set an odd kick is one whose next kick comes three or five white ticks later (`odd_iff`).

```wl
words = {{0, 0, 1, 0, 1, 0, 0, 1, 0}, {0, 0, 1, 0, 1, 0, 1, 0, 0}, {0, 0, 1, 0, 1, 0, 1, 0, 1}, {0, 1, 0, 0, 1, 0, 0, 1, 0}, {1, 0, 1, 0, 1, 0, 0, 1, 0}, {1, 0, 1, 0, 1, 0, 1, 0, 1}};
test[x_] := With[{k = entry[x]}, With[{w = Drop[half[x, k + 40], k]}, With[{g = kick /@ w, a = net /@ w, b = black /@ w}, Table[{g[[j + 7]] == Boole[MemberQ[words, a[[j + 1 ;; j + 9]]]], g[[j + 2]] (1 - a[[j + 2]]) == b[[j + 2]] (1 - b[[j + 6]])}, {j, 0, Length[w] - 10}]]]];
SeedRandom[5];
Counts[Flatten[Table[test[RandomInteger[2^60 - 1]], {100}], 1]]
```

For unrestricted starting halves nine nets do not decide it. **Two finite halves read the same nine nets and differ in the kick at the seventh reading** (`nine_collision`), so no function of nine nets gives the kick at sample index 6 of every starting half (`no_unrestricted_nine`). Their cells are sites 4, 5, 6 and sites 1, 4.

```wl
{Table[net /@ half[x, 8], {x, {56, 9}}], Table[kick[half[x, 6][[7]]], {x, {56, 9}}]}
```

## The streams repeat together

Beside an alternating column, for every right half of any support, **the kicks, the net and the odd kicks are eventually periodic together, and if the black net is eventually periodic then so are they** (`periodic_together_of_alt`). In the set the nets give the kicks, and the kicks give the net through the countdown. Otherwise the kicks come once in four white ticks, the net alternates and there are no odd kicks (`four_tail`).

**The single cell.** If its centre alternates from some tick on, masked Jen says that the kicks are not eventually periodic (`Rule30MaskedJen`), so the fours are excluded and the half is in the set from some tick on (`single_enters`). None of the streams is then eventually periodic: not the kicks, not the net on either phase, not the shell on either phase, and not the odd kicks (`both_phases`, `odd_kicks_aperiodic`).

## The proof

Number the white ticks from any one of them, and give each *prefix of the row*, the cells from the first to the k-th, the set of times at which a row that begins so can still be outside the set. Further lines of time say that the set is closed, and that its rows read none of ten words. One walk of this table against itself checks that a row which carries a time carries the next one two ticks later, whenever the colour of the first cell allows it, whatever the cells beyond. The table has 810 branches and the walk 5,860 steps.

It leaves 47 windows of twelve cells, those that lie on an endless path outside the set. With a thirteenth cell and seventeen rounds of dropping the windows that have no image or no predecessor in the list, ten are left, and they repeat the kick word 1000. The decoders are a search over the words that the closed set allows, with the letters of the law as its alphabet. The law is a table of six cells.

## Earlier work

Lowry's definitions, the two-step identity and the two earlier aperiodicity theorems are `Rule30SourceArrivals`; on the segment 0101 a change of the unpaired left source changes the net between the two white ticks (`alternating_change_visible`). A black net at a white tick that is not a kick is the right part of Lowry's event word 0101001; `Rule30EventReturns` gives the return times of that word. That the kicks of every right half are eventually in the nine-pair gap language, or come once in four, is AIOvernight's `Rule30PeriodTwoWidth13`, by a rank certificate of a strip of thirteen columns; here an explicit closed set replaces it. The six-column theorem of our `Rule30PeriodTwoOnset` already excludes 2, 2, 5 once one full white–black period has elapsed, with closed sets of twenty windows on five cells and thirty-eight on six. The return of a kick from sites two and five is our `Rule30GatePulseReturn`, and the table and walk are those of our `Rule30TrappedRuns`.

## What is not claimed

Nothing here excludes an alternating centre, and this proof gives no uniform deadline for entry. The closed set is not shown to be least. No half is exhibited that kicks once in four from some tick on.

## Lean statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = ("Rule30Submission." <> #) & /@ {"both_phases", "odd_kicks_aperiodic", "lowry_odd_return", "every_half", "enters_or_four", "periodic_together_of_alt", "four_tail", "periodic_together", "stays", "clean_of_set", "kick_of_white_nets", "odd_of_black_nets", "odd_of_equal_nets", "net_of_return", "odd_iff", "nine_collision", "no_unrestricted_nine", "single_enters"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission[First[heads]]["KernelCheck"]
```
