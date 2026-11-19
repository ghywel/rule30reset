---
Template: ComputationalEssay
Name: Every Number of Inverse Ticks Beside the White Wall: One Argument for Every k, Conditional on Reset Capacity
Author: {AUTHORS}
Date: 2026-11-19
Description: Core Lean. For every k at once, one argument proves that from an explicit age every k-tick predecessor of a nonzero finite row beside the white wall is finite with its edge exactly k cells inside, assuming one named property of the edge band, reset capacity. The property is open. Nothing here decides Q01.
Abstract: In core Lean 4.35.0 we prove the kit's inverse-tick statement beside the fixed white wall for every number of ticks k, by one argument, conditional on one named hypothesis. A row's top w cells evolve on their own by a band map. Let `K1 w` be the number of inverse layers that a fixed schedule of closed runs clears on every phase of every cycle of that map. If every k has a width w with `K1 w ≥ k` (`CAP`), then for every k, every nonzero finite seed and every age t ≥ w − 1 + 2ʷ, with w the least such width, every k-tick predecessor of the row at age t, a priori of infinite support, is finite with its last black cell exactly k cells inside the row's edge, and every choice of cell 1 at times 0 to k − 1 occurs (`Rule30Submission.conditional_every_k`). The catalog has one tick from age 8 and two from age 24 (`Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`), and our earlier entry four from age 80, each by a cover. The proof is one induction over the layers: a closed black run of length 1 mod 3 fixes the layer below it, as in kit pull request 60, and each layer reads the band one tick earlier on its cycle. `CAP` is open. It holds for k ≤ 7,911 by exact computation outside Lean, and would follow from every phase of every recurrent infinite strip having such runs arbitrarily deep. Nothing here decides `Q01`.
Keywords: [rule 30, Rule 30 Prize, zero-boundary left half, white wall, predecessors, inverse ticks, every k, edge band, closed runs, conditional theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

The setting is the kit's zero-boundary left half: rule 30 on the cells at depths 1, 2, 3, … beside a wall at depth 0 that stays white (`Rule30ZeroBoundary.zrow`). A finite row is a natural number with depth `i + 1` in bit `i`, and one tick is `F Y = (Y >>> 1) ^^^ (Y ||| (Y <<< 1))`. A nonzero finite row gains exactly one cell per tick at its outer edge.

A *k-tick predecessor* of a row `Z` is a row `L`, a priori of infinite support, whose image `k` ticks later is `Z` at every positive depth. Going back one tick has one free choice, the parent's cell 1 beside the wall, so a row has `2^k` histories of `k` ticks. The target for `k` ticks from age `a` (`TargetAt k a`) has three clauses. For every nonzero finite seed `Y` and every age `t ≥ a`:
- every `k`-tick predecessor of `Fᵗ Y` has its last black cell exactly `k` cells inside the edge of `Fᵗ Y`, and is white beyond it (`PhysicalEdge`);
- it is the row of a natural number `A` with `Fᵏ A = Fᵗ Y` (`FinitePredecessor`);
- each of the `2^k` choices of cell 1 at times `0, …, k − 1` occurs (`AllHistories`).

This generalises the kit's two-tick theorem from age 24 (`finite_row_aged_image_two_step_predecessor_true_edge`) and the two headlines of our four-tick entry from age 80.

**The edge band.** Number the cells of a row from its edge inwards: *wheel* `j` is the cell `j` places in from the last black cell. The top `w` cells, as a word `v` with wheel `j` in bit `j`, evolve on their own by the band map `v ↦ (4v ⊕ (2v ∨ v)) mod 2ʷ` (the kit's `Rule30UniversalLeftSide.stepK`). Wheel 0 is black, so the band is an odd residue (`OddBand`).

**Closed runs and complete factors.** A *closed run* is `0 1^(3m+1) 0`: a black run whose length is one more than a multiple of three, with a white cell at each end. A *complete factor* is a closed run followed by one more symbol `z` (`resetAt`). Inverting one tick reads the row from the wall side towards the edge, with a register of two parent cells. Started with all four registers allowed, the four readings agree once they have read a complete factor, with `z` read once: the register is then (black, not `z`), and they agree from there to the edge.

**The schedule and its capacity.** Fix a word `v` on a cycle of the band map. Layer 0 reads `v` from its deepest wheel and stops at the deepest complete factor (`firstReset`). Its four readings then agree on the parent's bits from there to the edge. Layer 1 reads the cycle's word one tick earlier, on exactly those bits, and so on: layer `d` reads phase `−d` of the same cycle (`schedule`), and `k` layers are layers 0 to `k − 1`. `K1 w` is the least number of layers this schedule closes, over every cycle of the band map at width `w` and every phase of each (`K1`). No single cycle is assumed.

**The theorem.** The hypothesis `CAP` says that for every `k` some width `w > 0` has `K1 w ≥ k`. Let `W k` be the least such width. Then for every `k`, `TargetAt k (W k − 1 + 2^(W k))` (`conditional_every_k`, the statement `ConditionalEveryK`). A sharper form takes any proved settling age: if `K1 w ≥ k` and every row of age at least `a` has its width-`w` band on a cycle (`Settled w a`), then `TargetAt k a` (`capacity_at_settling_age`). The proof does not depend on `k` except through the capacity.

## 2. The question

The kit has one inverse tick from age 8 (`Rule30AgeEightInverse`) and two from age 24 (`Rule30AgeTwentyFourInverse`). Our earlier entry proved four from age 80. Each step needed a larger age and a new cover, and the maintainers asked on kit pull request 357 for the statement for every `k`, by "an argument that does not need a new cover for each k". They also asked why the ages grow.

No single age can serve every `k`. If every `k`-tick history of the single black cell at age `t` closes, there are `2^k` distinct finite predecessors of width `t + 1 − k`. Only `2^(t − k)` rows have that width, so `t ≥ 2k`. The age has to grow with `k`, and the question is how to prove all the ages by one argument.

The single black cell beside the wall, read from its edge: the top 64 wheels from age 400 to age 463, with the edge on the left. Wheels 2, 7 and 28 stay white.

```wl
f[y_Integer] := BitXor[BitShiftRight[y, 1], BitOr[y, BitShiftLeft[y, 1]]];
step[w_Integer][v_Integer] := Mod[BitXor[BitShiftLeft[v, 2], BitOr[BitShiftLeft[v, 1], v]], 2^w];
band[w_Integer, y_Integer] := FromDigits[Reverse[Take[IntegerDigits[y, 2], w]], 2];
rows = NestList[f, 1, 1500];
ArrayPlot[Table[Reverse[IntegerDigits[band[64, rows[[a + 1]]], 2, 64]], {a, 400, 463}], ImageSize -> 360, Frame -> False]
```

## 3. Exploration

**The band runs on its own.** For every row at least `w` cells wide, the band of the next row is the band map applied to this one. At width 20, for the single black cell at every age from 19 to 1,499:

```wl
And @@ Table[band[20, rows[[a + 2]]] == step[20][band[20, rows[[a + 1]]]], {a, 19, 1499}]
```

At width 20 the band settles on the four-word cycle that the kit calls `C20`, here in wheel order. For the single black cell it is there from age 24 on. The kit proves it for every seed from age 26 (`band_from_age_twenty_six`). The last age at which the single cell is off the cycle:

```wl
C20 = FromDigits[Reverse[IntegerDigits[#, 2, 20]], 2] & /@ {820683, 822904, 911005, 912610};
Max[Select[Range[19, 1500], ! MemberQ[C20, band[20, rows[[# + 1]]]] &]]
```

**One inverse layer, and the reset rule.** The closed runs of a word, the deepest complete factor (`firstReset`), and one inverse layer started at wheel `s` with each of its four registers, giving the parent's wheels. On every phase of the single cell's cycle at width 200, the four readings agree on the parent's wheels from `j − 1` to the edge, where `j` is the wheel of the symbol `z` of the complete factor that `firstReset` finds. Each pair below is the parent wheel from which they agree, then `j − 1`:

```wl
closedRuns[v_Integer, avail_Integer] := Module[{bits = Reverse[IntegerDigits[v, 2, avail]], pos = 0, out = {}},
   Do[If[First[r] == 1, AppendTo[out, {pos, pos + Length[r] - 1}]]; pos += Length[r], {r, Split[bits]}];
   Select[out, #[[1]] >= 2 && #[[2]] <= avail - 2 && Mod[#[[2]] - #[[1]] + 1, 3] == 1 &]];
firstReset[v_Integer, avail_Integer] := With[{rs = closedRuns[v, avail]}, If[rs === {}, None, Max[rs[[All, 1]]] - 2]];
period[w_Integer, v_Integer] := SelectFirst[2^Range[0, 12], Nest[step[w], v, #] == v &, None];
phases[w_Integer] := With[{v = band[w, rows[[-1]]]}, NestList[step[w], v, period[w, v] - 1]];
layer[y_Integer, s_Integer, {a_, b_}] := Module[{x = <|s -> a, s - 1 -> b|>},
   Do[x[j - 2] = BitXor[BitGet[y, j], BitOr[x[j - 1], x[j]]], {j, s, 0, -1}]; x];
agreeFrom[y_Integer, s_Integer] := Module[{xs = layer[y, s, #] & /@ Tuples[{0, 1}, 2]},
   SelectFirst[Range[s, -2, -1], Function[c, AllTrue[Range[c, -2, -1], Function[i, Equal @@ (#[i] & /@ xs)]]]]];
{agreeFrom[#, 199], firstReset[#, 200] - 1} & /@ phases[200]
```

**The capacity grows with the width.** The schedule of section 1, layer by layer, taking the worst phase of the single cell's cycle at each width from 20 to 400:

```wl
capacity[w_Integer, v_Integer] := Module[{p = period[w, v], d = 0, avail = w, j},
   While[d < w && (j = firstReset[Nest[step[w], v, Mod[-d, p]], avail]) =!= None, d++; avail = j]; d];
caps = Table[{w, Min[capacity[w, #] & /@ phases[w]]}, {w, 20, 400, 20}]
```

That is about one layer per 11 wheels. Through wheel 53,207 every configuration with a leftmost black cell eventually shares the single cell's left side (`Rule30UniversalLeftSide`). So at these widths the band map has this one cycle, and these numbers are `K1` itself. Our record computes it at larger widths: 383 layers at width 4,096, and 7,911 at width 87,867 over every phase of the kit's four strips, at 10.7 to 11.1 wheels per layer in between.

**The smallest cases.** The least widths of capacity 1, 2 and 3, whether the width-20 cycle is the kit's `C20`, and the capacity of each of its four phases:

```wl
leastWidth[k_] := SelectFirst[Range[3, 100], Function[w, Min[capacity[w, #] & /@ phases[w]] >= k]];
{leastWidth /@ {1, 2, 3}, Sort[phases[20]] == Sort[C20], capacity[20, #] & /@ C20}
```

In Lean, our controls ([source](https://github.com/ghywel/rule30reset/blob/187fe52a7fc8b583c28b753402a89a1da13de341/research/m29/Rule30EveryKControls.lean), not part of this submission's source) certify `K1 8 ≥ 1` and `K1 20 ≥ 2` by kernel reduction. With the counting bound they prove the one- and two-tick statements from ages 263 and 1,048,595, without the hypothesis. The kit puts every seed's band on `C20` from age 26 (`band_from_age_twenty_six`). Reversing its twenty bits into wheel order, and projecting to eight for one tick, the sharper form gives both statements from age 26. That is a corollary on paper of the kit's theorem and this computation, not a kernel control. These are the kit's two statements, at ages that are not sharp.

**The band settles at a steady rate.** The first age at which the width-`w` band is on its cycle, the worst over the single cell and 20 random seeds:

```wl
settle[w_Integer, orbit_List] := SelectFirst[Range[1, Length[orbit] - 64],
    BitLength[orbit[[#]]] >= w && band[w, orbit[[#]]] == band[w, orbit[[# + 64]]] &] - 1;
SeedRandom[30];
orbits = NestList[f, #, 500] & /@ Join[{1}, RandomInteger[{1, 2^30}, 20]];
Table[{w, Max[settle[w, #] & /@ orbits]}, {w, 20, 300, 40}]
```

That is about 1.3 ticks per cell on these seeds. A moving cover over every seed certifies 26 at width 20, 97 at width 64 and 178 at width 128. The theorem itself uses only the counting bound: after `w − 1` ticks a row has a full band, and the band has `2^w` words, so it is on a cycle within `2^w` more.

**One seed's thresholds.** The last age at which the single black cell has a `k`-tick history that is not finite, for `k` from 1 to 5:

```wl
parent[r_Integer, h_Integer] := Module[{n = BitLength[r] + 2, p},
   p = ConstantArray[0, n + 2]; p[[2]] = h;
   Do[p[[k + 3]] = BitXor[BitGet[r, k], BitOr[p[[k + 2]], p[[k + 1]]]], {k, 0, n - 1}];
   With[{a = FromDigits[Reverse[Rest[p]], 2]}, If[f[a] === r, a, Missing["infinite"]]]];
histories[r_Integer, d_Integer] := Nest[Flatten[If[MissingQ[#], {#, #}, {parent[#, 0], parent[#, 1]}] & /@ #] &, {r}, d];
lastOpen[k_] := Max[Select[Range[k, 130], Count[histories[rows[[# + 1]], k], _Integer] < 2^k &]];
Table[{k, lastOpen[k]}, {k, 1, 5}]
```

So the single cell needs ages 6, 19, 29, 50 and 57. The scan stops at age 130, and still finds the last failures: the closing ages through `k = 5` are at most 8, 24, 31, 72 and 78 (the kit's two theorems, and our covers in the record). The sharp ages over every seed are larger (section 5).

**Where the open statement lives.** The permanently white wheels of the single cell's cycle at width 450, and the interval from each to the next. For each interval: its two ends, the least period of the column just before it, whether the column just after it is antiperiodic at that period (a *doubling*: the clock doubles there), and in how many of the cycle's phases a closed run lies wholly inside it:

```wl
whiteIntervals[w_Integer] := Module[{ph = phases[w], col, whites, lp, inside},
   col[j_] := BitGet[#, j] & /@ ph;
   whites = Select[Range[0, w - 1], AllTrue[col[#], # == 0 &] &];
   lp[c_] := SelectFirst[Divisors[Length[c]], RotateLeft[c, #] == c &];
   inside[u_, {a_, b_}] := AnyTrue[closedRuns[u, w], #[[1]] - 1 >= a && #[[2]] + 1 <= b &];
   Table[With[{b = SelectFirst[whites, # > a &], q = lp[col[a - 1]]},
      {a, b, q, RotateLeft[col[a + 1], q] == 1 - col[a + 1], Count[ph, u_ /; inside[u, {a, b}]], Length[ph]}], {a, Most[whites]}]];
whiteIntervals[450]
```

All three intervals are doublings, with source periods 1, 2 and 4, and each has a closed run in every phase. The white wheels at 28 and 399 are the kit's white diagonals (`Rule30LeftAntiPeriod`). Section 6 says why a reset in every phase of every doubling is the open statement.

## 4. The idea of the proof

1. **The band settles.** After `w − 1` ticks every nonzero row is at least `w` cells wide, and from then on its band evolves by the band map alone. The odd bands are finitely many, so by `w − 1 + 2^w` the band is on a cycle (`Settled`).
2. **The reset rule.** After an inverse layer has read a complete factor, with its symbol `z` read once, its register is (black, not `z`), whichever of the four registers it started from (`reset_closes`). `scheduled_layer` carries this to the physical predecessor, across its whole exterior. So the four readings agree from there to the edge. That they agree nowhere earlier is a separate finite automaton check in our record, which the proof does not need. The reset step is also Troy Lowry's `run_resets` in kit pull request 60, reproved here and credited.
3. **The schedule closes `k` layers.** Let the row's band be on a cycle whose every phase admits `k` layers. Each layer starts with every register allowed, so it covers every possible deeper part of every predecessor, infinite black tails included. Where it coalesces, every predecessor agrees with every other. Layer `d` reads the cycle's phase `−d`. The true ancestors' bands may still be transient there, but this does not matter. The cycle's phase `−1` is a band predecessor of phase 0, and coalescence makes every predecessor agree with it on the bits the layer fixed, the true ancestor included. So the next layer reads bits that are the same for every predecessor. The symbol `z` of a complete factor is never at wheel 0, since wheel 1 is black on an image band with a black edge and width at least two. When `z` is at wheel 1, the register it leaves is the parent's black edge and the white cell beyond it. That a supplied schedule of resets closes a cascade of any finite height is Troy Lowry's `scheduled_cascade_closes` in kit pull request 60, reproved here and credited. What is new is where the schedule comes from: the capacity of the settled band, read against the phases of its cycle.
4. **The edge.** After `k` layers every predecessor agrees with the true ancestor to the edge, and the registers are zero beyond it, so every predecessor is finite. A nonzero finite row gains exactly one cell per tick, so its edge is `k` cells inside (`scheduled_edge`).
5. **The histories.** Going back one tick, prescribe the parent's cell beside the wall and reconstruct the rest of the parent from the wall outwards. Doing this at each of the `k` steps, in reverse order of the requested history, gives a predecessor with any prescribed cells beside the wall. By step 4 each one is finite, so it is the row of a natural number.

Nothing in these steps is a cover for a particular `k`. The number of layers is a variable of one induction, and the only input that depends on `k` is the width at which the capacity reaches `k`.

## 5. Why the ages grow

The theorem gives `f(k) ≤ g(W(k))`, where `W(k)` is the least width of capacity `k` and `g(w)` is the age by which every band of width `w` has settled. Two costs combine: the width the capacity needs, and the time that width takes to settle.
- **Width per layer.** Each layer spends one complete factor, and along the schedule the usable ones come about once every 11 wheels. Our exact schedule on the kit's four strips clears 7,911 layers at width 87,867, at 10.7 to 11.1 wheels per layer from width 4,096 on. So `W(k)` is about `11k` in that range.
- **Time per wheel.** The band settles in about 1.3 to 1.4 ticks per cell, in the samples above and in the moving cover.
- **Together** they suggest sufficient ages of about 15 ticks per layer, which is why each further tick has cost more age. The product is a heuristic: the two rates are measured over different ranges of width. The sharp age is 8 for one tick, 24 for two and 31 for three. It lies between 59 and 72 for four, 73 and 78 for five, and 104 and 108 for six. For seven to eleven ticks our upper bounds are 131, 132, 144, 157 and 172.
- **What is proved of the rates.** `g(w) ≤ w − 1 + 2^w` in general. At width 87,867 the kit's explicit fronts give `g ≤ 265,441` (`forced_front_four_uniform`). With the computed capacity this gives `f(k) ≤ 265,441` for every `k ≤ 7,911`, outside Lean. A linear `f` is not proved.

## 6. What is proved, and the one open statement

**In Lean, here:** `CAP` implies the target for every `k`, with the age `W(k) − 1 + 2^W(k)`, and the sharper form at any proved settling age.

**The hypothesis, by hand.** `CAP` would follow from this statement, which we call `(L∞)`: every phase word of every pointed recurrent strip contains closed runs at arbitrarily large depths. A pointed recurrent strip is an infinite left side, with a black edge, on which every finite prefix of wheels is periodic in time. The cycles of the band map are exactly their finite prefixes, so depths without bound only make sense on the strips. Given resets in the `k` phases a schedule reads, deep enough, the schedule closes `k` layers. Compactness of the phases, and of the strips, then gives one width for all of them. Conversely, a phase with a last reset limits every width's capacity, so `(L∞)` is also what this route needs.

**The one open statement** is `(L∞)`. It has an equivalent form, and a lemma that would prove it:
- **Unique predecessors.** Read the left sides with a black edge as odd 2-adic integers, with the band map as `x ↦ 4x ⊕ (2x ∨ x)`. On that odd domain, `(L∞)` says that every recurrent point has exactly one preimage.
- **The doubling lemma.** The least common period of every prefix of a strip is a power of two, and it is first lost just after a permanently white wheel, where it doubles. Both are proved in Lean in our record. So every strip has such doubling intervals past every depth. So one sufficient route is a lemma, from which `(L∞)` follows by a short hand argument: *every white interval at which the clock doubles contains a closed run in every phase.* Section 3 shows it at the single cell's first three doublings.

**Evidence for the lemma.** It holds wherever we have tested it: at every gap up to 30 for every power-of-two period, at every gap for power-of-two source periods up to 32, with no reset-free doubling at source period 64 below gap 74 except one undecided gap, and none at source period 128 up to gap 64. An exhaustive listing over every source period finds no doubling at all at gaps 31 to 55; at gaps 45, 50 and 51 to 55 the listing's completeness has a machine-checked proof. For source periods up to 28, the only doublings that return to white within 100 wheels are six from a source with one black tick per period, and the only one with a tick that has no reset is at period 5, which is not a power of two.

**What is proved towards it.** In Lean (`one_of_three_unbounded`, [source](https://github.com/ghywel/rule30reset/blob/187fe52a7fc8b583c28b753402a89a1da13de341/research/m29/Rule30RecurrentStrip.lean)), on every pointed recurrent strip and from every starting tick, one fixed phase among any three consecutive phases has closed runs at arbitrarily large depths. That is not enough, because the schedule needs the `k` consecutive phases it reads, not one chosen among them.

**Barriers.** Some pointed recurrent strip has a phase in which every wheel just beyond a permanently white wheel is black (`exists_pointed_strip`, [source](https://github.com/ghywel/rule30reset/blob/187fe52a7fc8b583c28b753402a89a1da13de341/research/m29/Rule30PointedWhiteFork.lean)). That is certified in Lean, and it rules out an argument through such white diagonals alone. These two theorems are proved and independently read in our record; they are supporting results, not headlines of this submission. An eight-cell ring of period five has two consecutive phases with no closed run, so white-wheel constraints alone, read in one or two phases, do not force a reset. It has no physical edge and no power-of-two clock, which is why the lemma is stated for doublings.

## 7. Prior art and credit

- **The kit** supplies the setting and the tools: `Rule30ZeroBoundary` (the zero-boundary row, the integer form and the backward transducer), and the left-side recurrence of `Rule30AgedLeftDiagonals` (Lowry with OpenAI Codex). The one- and two-tick theorems are `Rule30AgeEightInverse` and `Rule30AgeTwentyFourInverse` by Scott Hughes with OpenAI Codex, with `band_from_age_twenty_six` by G.P.J.W. Quint and Gemini. The white diagonals at 28, 399 and 53,207 are in `Rule30LeftAntiPeriod` (Quint and Gemini). `Rule30ResetFreeThree` (Lowry with OpenAI Codex) puts a closed run in one of any three consecutive rows of a finite row's orbit.
- **The reset step and the cascade** are Troy Lowry's, in kit pull request 60 (`run_resets`, `scheduled_cascade_closes`), with the presence of resets as their hypothesis. That pull request, opened on 30 October, is unmerged, so it is not in the verifier's kit revision of 5 November. This module proves both steps locally, with that credit; a kit version would import them once 60 is merged. Kit pull requests 47 and 52 close inverse cascades under reset or gate hypotheses on a reference trajectory.
- **Ancestry beside the wall.** `Rule30WallRecordAncestry` (Lowry, kit pull request 364) builds, for every wall record and every `k`, a finite row with a complete finite predecessor tree of height `k`. That is existence for some row, not the age statement for every row.
- **Ours, earlier.** Four ticks from age 80 ([R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f)). The kit modules `Rule30UniversalLeftSide` (the band map and the left side shared by every configuration through wheel 53,207, whose fork Rowland located in 2006), `Rule30FourLeftSides` and `Rule30FourFronts` (the four strips and their explicit fronts). The reduction of the ages to the edge band's cycles and the capacity, the compactness argument and the computed range are in our public record.
- **Novelty.** The portal's list and the kit's open pull requests have no statement for every `k`. At the checks of 19 November, the portal's 377 entries and the kit's 15 open pull requests contain no statement for every `k`, and no implication from capacity over the recurrent bands to every physical predecessor and every wall history.

## 8. What is not proved

- `CAP` is not proved. The theorem is conditional, and its hypothesis is open in general. It holds for `k ≤ 7,911` by a computation outside Lean.
- The age is explicit once `W(k)` is known, but `W(k)` is known only where it is computed, and the general settling bound is exponential in the width. The ages are not sharp.
- The theorem is about the zero-boundary left half beside a fixed white wall. It says nothing about the centre column's period, and it does not decide `Q01`.

## The formal proof

The module is core Lean. It imports the kit's `Rule30ZeroBoundary` and `Rule30UniversalLeftSide`, both present at the verifier's kit revision. It has three parts, each in its own namespace: the statement (`Rule30EveryKStatement`), the scheduled cascade (`Rule30EveryKCascade`) and the assembly (`Rule30EveryKInverse`). The two headlines are aliases in `Rule30Submission`.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

```wl
rule30Submission = LeanImportString[(*Iconize["Lean source"]*)"import Ruliology.CellularAutomata.Rule30ZeroBoundary
import Ruliology.CellularAutomata.Rule30UniversalLeftSide

/-!
# S2 statement for review (K8, stream A1)

The kit numbers physical cells from the white wall, with cell 1 beside it.
In a band, bit 0 is the last black cell, and bit j is j cells towards the wall.
The band and the integer encoding of a physical row therefore read in opposite
directions. The propositions below are targets for review, with no proof assumed.
-/


namespace Ruliology.CellularAutomata.Rule30EveryKStatement

open Rule30ZeroBoundary Rule30ZeroBoundary.IntegerForm

abbrev bandStep := Rule30UniversalLeftSide.stepK
abbrev bandAt := Rule30UniversalLeftSide.rowAt

/-- Odd residues are exactly the width-w words with a black outer edge. -/
def OddBand (w v : Nat) : Prop := v < 2 ^ w ∧ v.testBit 0 = true

/-- Closed black run of length 3m+1. Bit j is the unconstrained symbol
read immediately after the shallow zero to finish agreement of the pair. -/
def resetAt (v j m : Nat) : Bool :=
  !(v.testBit (j + 1)) && !(v.testBit (j + 3*m + 3)) &&
    (List.range (3*m + 1)).all (fun i => v.testBit (j + 2 + i))

/-- First complete factor, scanning from the deepest available bit towards
the edge. Its two zeros, black run and following symbol all lie in the band. -/
def firstReset (v available : Nat) : Option Nat :=
  (List.range available).reverse.find? fun j =>
    (List.range (available / 3 + 1)).any fun m =>
      decide (j + 3*m + 4 ≤ available) && resetAt v j m

/-- The reference at layer d is d ticks *earlier* on the same cycle. Agreement
from wheel j outwards leaves j bits (0 through j-1) after the edge retreats.
Width w supplies sufficient fuel since a complete factor strictly spends width. -/
def schedule (w v period : Nat) : Nat → Nat → Nat → Nat
  | 0, _, _ => 0
  | fuel + 1, d, available =>
    let phase := (period - d % period) % period
    match firstReset (bandAt w v phase) available with
    | none => 0
    | some j => 1 + schedule w v period fuel (d + 1) j

def phaseCapacity (w v period : Nat) : Nat := schedule w v period w 0 w

/-- Find the first positive return. At positive width there are 2^(w-1)
odd residues, so failure within that many steps excludes exactly transients. -/
def returnPeriod (w v : Nat) : Option Nat :=
  let rec walk : Nat → Nat → Nat → Option Nat
    | 0, _, _ => none
    | fuel + 1, current, elapsed =>
      let next := bandStep w current
      if next = v then some (elapsed + 1) else walk fuel next (elapsed + 1)
  walk (2 ^ (w - 1)) v 0

/-- Worst one-layer schedule across every cycle and every phase. Enumerating
all odd initial words includes each periodic phase separately. Width zero is
excluded from CAP. This finite specification favours clarity over runtime. -/
def K1 : Nat → Nat
  | 0 => 0
  | n + 1 =>
    (List.range (2 ^ n)).foldl (fun worst i =>
      let v := 2*i + 1
      match returnPeriod (n + 1) v with
      | none => worst
      | some period => min worst (phaseCapacity (n + 1) v period)) (n + 1)

def CAP : Prop := ∀ k : Nat, ∃ w : Nat, 0 < w ∧ k ≤ K1 w

/-- The target in the kit's physical-row convention, with arbitrary
predecessor V and equality only on positive cells. -/
def PhysicalEdge (k age : Nat) : Prop :=
  ∀ (L : Nat → Bool) (m t : Nat), 1 ≤ m → L m = true →
    (∀ i, m < i → L i = false) → age ≤ t →
    ∀ V : Nat → Bool, (∀ i, 1 ≤ i → zrow V k i = zrow L t i) →
      V (m + t - k) = true ∧ ∀ i, m + t - k < i → V i = false

/-- Definitionally the kit's Rule30LateTwins.Top. That module postdates
the portal verifier pin, so we spell out its predicate on the same bits. -/
def Top (Y m : Nat) : Prop :=
  Y.testBit m = true ∧ ∀ i, m < i → Y.testBit i = false

/-- S1's first headline, with a finite representative of each predecessor. -/
def FinitePredecessor (k age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t → ∀ L : Nat → Bool,
    (∀ i, 1 ≤ i → zrow L k i = rowOfNat (iter F t Y) i) →
      ∃ A : Nat, (∀ i, 1 ≤ i → rowOfNat A i = L i) ∧
        iter F k A = iter F t Y ∧ Top A (Y.log2 + t - k)

/-- S1's second headline. Histories are specified in forward time at cell 1. -/
def AllHistories (k age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t → ∀ bits : Fin k → Bool,
    ∃ A : Nat, iter F k A = iter F t Y ∧ Top A (Y.log2 + t - k) ∧
      ∀ i : Fin k, rowOfNat (iter F i.val A) 1 = bits i

def TargetAt (k age : Nat) : Prop :=
  PhysicalEdge k age ∧ FinitePredecessor k age ∧ AllHistories k age

def EveryK (age : Nat → Nat) : Prop := ∀ k, TargetAt k (age k)

/-- Read an integer row's outer band in wheel order. Only full bands of
nonzero rows are used in the convergence statement below. -/
def topBand (w Y : Nat) : Nat :=
  (List.range w).foldl (fun word j =>
    if j ≤ Y.log2 ∧ Y.testBit (Y.log2 - j) = true then word + 2^j else word) 0

def Settled (w age : Nat) : Prop :=
  ∀ (Y t : Nat), Y ≠ 0 → age ≤ t →
    let output := iter F t Y
    let v := topBand w output
    w ≤ output.log2 + 1 ∧ OddBand w v ∧ ∃ q : Nat, 0 < q ∧ bandAt w v q = v

/-- M34's sharper form: any established uniform settling age at a witness
width may be used. First reset starts with free registers at the deep end. -/
def CapacityAtSettlingAge : Prop :=
  ∀ (k w age : Nat), 0 < w → k ≤ K1 w → Settled w age → TargetAt k age

/-- After w-1 ticks every nonzero seed has a full band. A further 2^w
ticks suffice by the finite-state bound of M35. No unique cycle is assumed. -/
def settlingBound (w : Nat) : Nat := w - 1 + 2^w

/-- The least positive witness at or below any supplied witness. The fallback
is the supplied witness itself. CAP provides the endpoint of the finite search. -/
noncomputable def widthFor (capacity : CAP) (k : Nat) : Nat :=
  let witness := Classical.choose (capacity k)
  ((List.range witness).find? (fun w => decide (0 < w ∧ k ≤ K1 w))).getD witness

/-- The conditional every-k statement. Its age depends only on k through the
least capacity witness. CAP remains the open mathematical hypothesis. -/
def ConditionalEveryK : Prop :=
  ∀ capacity : CAP, EveryK (fun k => settlingBound (widthFor capacity k))

end Ruliology.CellularAutomata.Rule30EveryKStatement

/-!
# Scheduled inverse layers at a finite Rule 30 edge

Troy Lowry's Rule30PrizeKit PR #60 gives the reset-word and scheduled-cascade
argument. Here the driver is the preceding phase of an odd edge cycle and the
cut is the one computed by Rule30EveryKStatement.firstReset.
-/


namespace Ruliology.CellularAutomata.Rule30EveryKCascade

open Rule30EveryKStatement Rule30ZeroBoundary Rule30UniversalLeftSide

abbrev Row := Nat → Bool
abbrev Pair := Bool × Bool

/-- Advance the inverse register one physical cell towards the exterior. -/
def advance (b : Bool) (s : Pair) : Pair := (s.2, xor b (s.2 || s.1))

def pair (P : Row) (x : Nat) : Pair := (P x, P (x+1))

private theorem black_cycle (s : Pair) :
    advance true (advance true (advance true (advance true s))) = advance true s := by
  obtain ⟨a,b⟩ := s
  cases a <;> cases b <;> rfl

private theorem black_run (r : Nat → Pair) (start m : Nat)
    (h : ∀ i, i < 3*m+1 → r (start+i+1) = advance true (r (start+i))) :
    r (start+(3*m+1)) = advance true (r start) := by
  induction m with
  | zero => simpa using h 0 (by decide)
  | succ m ih =>
    let n := 3*m+1
    have h1 := h n (by dsimp [n]; omega)
    have h2 := h (n+1) (by dsimp [n]; omega)
    have h3 := h (n+2) (by dsimp [n]; omega)
    have prev := ih (fun i hi => h i (by omega))
    rw [show start+(3*(m+1)+1) = start+(n+2)+1 by dsimp [n]; omega,
      h3, show start+(n+2) = start+(n+1)+1 by omega, h2,
      show start+(n+1) = start+n+1 by omega, h1, prev, black_cycle]

private theorem finish_reset (b : Bool) (s : Pair) :
    advance b (advance false (advance true (advance false s))) = (true, !b) := by
  obtain ⟨a,c⟩ := s
  cases a <;> cases c <;> cases b <;> rfl

/-- After reading 0, 3m+1 black cells, 0 and a free symbol, the pair is
independent of its entrance state. The free symbol is read at depth base+3m+4. -/
theorem reset_closes (P O : Row) (base m : Nat)
    (h : ∀ n, base ≤ n → pair P (n+1) = advance (O (n+1)) (pair P n))
    (a : O (base+1) = false)
    (bs : ∀ i, i < 3*m+1 → O (base+2+i) = true)
    (c : O (base+3*m+3) = false) :
    pair P (base+3*m+4) = (true, !(O (base+3*m+4))) := by
  have run := black_run (pair P) (base+1) m (by
    intro i hi
    rw [h _ (by omega), show base+1+i+1 = base+2+i by omega, bs i hi])
  have last := h (base+3*m+3) (by omega)
  rw [last, h (base+3*m+2) (by omega), c,
    show base+3*m+2 = base+1+(3*m+1) by omega, run, h base (by omega), a, finish_reset]

/-- A word placed with its low bit at physical depth e, white outside. -/
def reference (e v x : Nat) : Bool := if x ≤ e then v.testBit (e-x) else false

/-- The cell rule inverted at physical depth n+1. -/
def Drives (O P : Row) (base : Nat) : Prop :=
  ∀ n, base ≤ n → pair P (n+1) = advance (O (n+1)) (pair P n)

theorem physical_drives (P : Row) (t : Nat) :
    Drives (zrow P (t+1)) (zrow P t) 0 := by
  intro n _
  exact Prod.ext rfl (zrow_inv P t n)

/-- The previous phase is a valid reference parent on the available band and
the white exterior. This does not require that the actual seed's earlier band
was already recurrent. -/
theorem reference_drives (w u e base : Nat) (he : 0 < e) (hw : e ≤ base+w) :
    Drives (reference e (bandStep w u)) (reference (e-1) u) base := by
  intro n hn
  refine Prod.ext rfl ?_
  change reference (e-1) u (n+2) = xor (reference e (bandStep w u) (n+1))
    (reference (e-1) u (n+1) || reference (e-1) u n)
  by_cases h0 : e ≤ n
  · simp [reference, show ¬ n+1 ≤ e by omega, show ¬ n+2 ≤ e-1 by omega,
      show ¬ n+1 ≤ e-1 by omega, show ¬ n ≤ e-1 by omega]
  by_cases h1 : e = n+1
  · subst e
    simp [reference, show ¬ n+2 ≤ n by omega, show ¬ n+1 ≤ n by omega, stepK_bit_zero (by omega : 0 < w)]
  by_cases h2 : e = n+2
  · subst e
    simp [reference, stepK_bit_one (by omega : 1 < w)]
  let j := e-(n+3)
  have hj : j+2 < w := by dsimp [j]; omega
  simp only [reference, ite_eq_left (show n+2 ≤ e-1 by omega), ite_eq_left (show n+1 ≤ e by omega),
    ite_eq_left (show n+1 ≤ e-1 by omega), ite_eq_left (show n ≤ e-1 by omega)]
  rw [show e-1-(n+2) = j by dsimp [j]; omega, show e-(n+1) = j+2 by dsimp [j]; omega,
    show e-1-(n+1) = j+1 by dsimp [j]; omega, show e-1-n = j+2 by dsimp [j]; omega,
    stepK_bit_step hj]
  cases u.testBit j <;> cases (u.testBit (j+1) || u.testBit (j+2)) <;> rfl


/-- The actual edge is black even if no bits remain available to the next
scan. Agreement covers every exterior cell, including an infinite tail. -/
def Matches (P : Row) (e v available : Nat) : Prop :=
  P e = true ∧ ∀ x, e < x+available → P x = reference e v x

theorem firstReset_spec {v available j : Nat} (h : firstReset v available = some j) :
    ∃ m, j+3*m+4 ≤ available ∧ resetAt v j m = true := by
  unfold firstReset at h
  have hh := List.find?_some h
  obtain ⟨m, _, hm⟩ := List.any_eq_true.mp hh
  exact ⟨m, of_decide_eq_true (Bool.and_eq_true_iff.mp hm).1, (Bool.and_eq_true_iff.mp hm).2⟩

/-- Common output from base+1 onwards propagates agreement of an inverse
pair at cut to the whole exterior. -/
private theorem agree_after {O P Q : Row} {base cut : Nat}
    (hp : Drives O P base) (hq : Drives O Q base) (hc : base ≤ cut)
    (eq : pair P cut = pair Q cut) : ∀ x, cut ≤ x → P x = Q x := by
  intro x hx
  obtain ⟨i,rfl⟩ := Nat.exists_eq_add_of_le hx
  suffices z : pair P (cut+i) = pair Q (cut+i) by exact congrArg Prod.fst z
  clear hx
  induction i with
  | zero => exact eq
  | succ i ih => rw [← Nat.add_assoc, hp _ (by omega), hq _ (by omega), ih]

/-- One successful cut of A1's actual search fixes the next band and the
previous physical edge, including the cut j=0. -/
theorem scheduled_layer {P O : Row} {w u e available j : Nat}
    (full : available ≤ e) (width : available ≤ w)
    (drive : Drives O P 0)
    (matchOut : Matches O e (bandStep w u) available)
    (cut : firstReset (bandStep w u) available = some j) :
    Matches P (e-1) u j := by
  obtain ⟨m, bound, reset⟩ := firstReset_spec cut
  let v := bandStep w u
  let b := e-(j+3*m+4)
  have eb : e = b+j+3*m+4 := by dsimp [b]; omega
  let D := reference e v
  let Q := reference (e-1) u
  have dp : Drives D P b := by
    intro n hn
    dsimp [D, v]
    rw [← matchOut.2 (n+1) (by omega)]
    exact drive n (Nat.zero_le _)
  have dq : Drives D Q b := reference_drives w u e b (by omega) (by omega)
  obtain ⟨zeros, ones⟩ := Bool.and_eq_true_iff.mp reset
  obtain ⟨z1,z2⟩ := Bool.and_eq_true_iff.mp zeros
  have low : v.testBit (j+1) = false := by simpa using z1
  have high : v.testBit (j+3*m+3) = false := by simpa using z2
  have deep : D (b+1) = false := by
    simpa [D, reference, show b+1 ≤ e by omega, show e-(b+1) = j+3*m+3 by omega] using high
  have shallow : D (b+3*m+3) = false := by
    simpa [D, reference, show b+3*m+3 ≤ e by omega, show e-(b+3*m+3) = j+1 by omega] using low
  have run (i) (hi : i < 3*m+1) : D (b+2+i) = true := by
    have h := List.all_eq_true.mp ones (3*m-i) (List.mem_range.mpr (by omega))
    simpa [D, reference, show b+2+i ≤ e by omega,
      show e-(b+2+i) = j+2+(3*m-i) by omega] using h
  have same := (reset_closes P D b m dp deep run shallow).trans
    (reset_closes Q D b m dq deep run shallow).symm
  have tail := agree_after dp dq (by omega) same
  have exterior (x) (hx : e ≤ x) : P x = false := by
    rw [tail x (by omega)]
    simp [Q, reference, show ¬ x ≤ e-1 by omega]
  constructor
  · have h := congrArg Prod.snd (drive (e-1) (Nat.zero_le _))
    have he : e-1+1 = e := by omega
    change P (e-1+1+1) = xor (O (e-1+1)) (P (e-1+1) || P (e-1)) at h
    rw [he, matchOut.1, exterior e (by omega), exterior (e+1) (by omega)] at h
    cases hbit : P (e-1) <;> simp [hbit] at h ⊢
  · intro x hx
    exact tail x (by omega)


/-- Phase of the reference strip d inverse ticks from v. -/
def earlier (w v q d : Nat) := bandAt w v ((q - d%q)%q)

theorem earlier_step {w v q : Nat} (hq : 0 < q) (cycle : bandAt w v q = v) (d : Nat) :
    bandStep w (earlier w v q (d+1)) = earlier w v q d := by
  let r := d%q
  have hr : r < q := Nat.mod_lt _ hq
  have succmod : (d+1)%q = (r+1)%q := Nat.mod_add_mod .. |>.symm
  unfold earlier
  rw [succmod]
  change bandStep w (bandAt w v ((q-(r+1)%q)%q)) = bandAt w v ((q-r)%q)
  by_cases last : r+1 = q
  · rw [last]
    simp only [Nat.mod_self, Nat.sub_zero, rowAt]
    rw [show q-r = 1 by omega]
    by_cases one : q = 1
    · rw [one] at cycle ⊢
      simpa [rowAt] using cycle
    · rw [Nat.mod_eq_of_lt (by omega : 1 < q)]
      rfl
  · rw [Nat.mod_eq_of_lt (by omega : r+1 < q), Nat.mod_eq_of_lt (by omega : q-(r+1) < q)]
    change bandAt w v (q-(r+1)+1) = _
    rw [show q-(r+1)+1 = q-r by omega]
    by_cases zero : r = 0
    · simpa [zero, rowAt] using cycle
    · rw [Nat.mod_eq_of_lt (by omega : q-r < q)]

/-- From every physical k-tick preimage the computed schedule fixes the
edge at depth e-k and all cells beyond it. No support or trace condition is
imposed on the entrance row. -/
theorem scheduled_edge {w v q : Nat} (hq : 0 < q) (cycle : bandAt w v q = v)
    (fuel d a k e : Nat) (P : Row) (width : a ≤ w) (full : a ≤ e)
    (matched : Matches (zrow P k) e (earlier w v q d) a)
    (closed : k ≤ schedule w v q fuel d a) :
    zrow P 0 (e-k) = true ∧ ∀ x, e-k < x → zrow P 0 x = false := by
  induction fuel generalizing d a k e with
  | zero =>
    have hk : k = 0 := by simpa [schedule] using closed
    subst k
    exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
      (by simp [reference, show ¬ x ≤ e by omega])⟩
  | succ fuel ih =>
    cases k with
    | zero => exact ⟨matched.1, fun x hx => (matched.2 x (by omega)).trans
        (by simp [reference, show ¬ x ≤ e by omega])⟩
    | succ k =>
      simp only [schedule] at closed
      cases h : firstReset (earlier w v q d) a with
      | none =>
        unfold earlier at h
        simp only [h] at closed
        omega
      | some j =>
        have fj := h
        unfold earlier at h
        simp only [h] at closed
        obtain ⟨m, bound, _⟩ := firstReset_spec fj
        rw [← earlier_step hq cycle d] at fj matched
        have next := scheduled_layer full width (physical_drives P k) matched fj
        have result := ih (d+1) j k (e-1) (by omega) (by omega) next (by omega)
        simpa [show e-(k+1) = e-1-k by omega] using result

end Ruliology.CellularAutomata.Rule30EveryKCascade

/-!
# The conditional inverse-tick theorem at a uniform age

Attach the reviewed minimum over edge cycles to the physical cascade and to
finite rows at a fixed white wall. All widths and tick counts are natural numbers.
-/


namespace Ruliology.CellularAutomata.Rule30EveryKInverse

open Rule30EveryKStatement Rule30EveryKCascade Rule30ZeroBoundary
open Rule30ZeroBoundary.IntegerForm Rule30UniversalLeftSide

private theorem top_log {Y : Nat} (h : Y ≠ 0) : Top Y Y.log2 :=
  ⟨Nat.testBit_log2 h, fun i hi => Nat.testBit_lt_two_pow
    (Nat.lt_of_lt_of_le Nat.lt_log2_self (Nat.pow_le_pow_right (by omega) hi))⟩

private theorem log_of_top {Y i : Nat} (h : Top Y i) : Y.log2 = i := by
  have nz : Y ≠ 0 := by intro e; simpa [e] using h.1
  have t := top_log nz
  rcases Nat.lt_trichotomy Y.log2 i with hl | he | hg
  · exact absurd h.1 (by rw [t.2 i hl]; decide)
  · exact he
  · exact absurd t.1 (by rw [h.2 _ hg]; decide)

private theorem forward_top {Y m : Nat} (h : Top Y m) : Top (F Y) (m+1) := by
  refine ⟨testBit_F_succ_of_top h.1 h.2, fun i hi => ?_⟩
  obtain ⟨j,rfl⟩ : ∃ j, i = j+1 := ⟨i-1, by omega⟩
  rw [testBit_F_succ, h.2 (j+2) (by omega), h.2 (j+1) (by omega), h.2 j (by omega)]
  rfl

private theorem orbit_top {Y : Nat} (h : Y ≠ 0) (t : Nat) :
    Top (iter F t Y) (Y.log2+t) := by
  induction t with
  | zero => exact top_log h
  | succ t ih => exact forward_top ih

private theorem band_succ (w Y : Nat) :
    topBand (w+1) Y = if w ≤ Y.log2 ∧ Y.testBit (Y.log2-w) = true
      then topBand w Y + 2^w else topBand w Y := by
  simp [topBand, List.range_succ, List.foldl_append]

theorem band_lt (w Y : Nat) : topBand w Y < 2^w := by
  induction w with
  | zero => simp [topBand]
  | succ w ih => rw [band_succ, Nat.pow_succ]; split <;> omega

theorem band_bit (w Y i : Nat) :
    (topBand w Y).testBit i = (decide (i < w ∧ i ≤ Y.log2) && Y.testBit (Y.log2-i)) := by
  induction w with
  | zero => simp [topBand]
  | succ w ih =>
    rw [band_succ]
    split <;> rename_i h
    · rw [← Nat.or_two_pow_eq_add_of_lt (band_lt w Y), Nat.testBit_or, Nat.testBit_two_pow, ih]
      by_cases eq : i = w
      · subst i; simp [h]
      · simp [Ne.symm eq, show (i < w+1) = (i < w) by apply propext; omega]
    · by_cases eq : i = w
      · subst i; simp [ih]; grind
      · simpa [show (i < w+1) = (i < w) by apply propext; omega] using ih

private theorem band_evolves {Y w : Nat} (nz : Y ≠ 0) (full : w ≤ Y.log2+1) :
    topBand w (F Y) = bandStep w (topBand w Y) := by
  let m := Y.log2
  have top := top_log nz
  have log := log_of_top (forward_top top)
  apply Nat.eq_of_testBit_eq
  intro i
  by_cases inside : i < w
  · have fit : i ≤ m := by omega
    rw [band_bit, log]
    simp only [inside, show i ≤ Y.log2+1 by omega, and_self, decide_true, Bool.true_and]
    cases i with
    | zero =>
      rw [stepK_bit_zero (by omega), band_bit]
      simp [inside, top.1, (forward_top top).1]
    | succ i =>
      cases i with
      | zero =>
        rw [stepK_bit_one (by omega), band_bit, band_bit]
        have hm : 1 ≤ m := by omega
        let z := m-1
        have hz : m = z+1 := by dsimp [z]; omega
        change (F Y).testBit (m+1-1) = _
        rw [show m+1-1 = z+1 by omega, testBit_F_succ,
          top.2 (z+2) (by omega), show z+1 = Y.log2 by omega]
        simp [inside, show 0 < w by omega, show 1 ≤ Y.log2 by omega, top.1]
      | succ i =>
        rw [stepK_bit_step inside, band_bit, band_bit, band_bit]
        let z := m-(i+2)
        have idx : m+1-(i+2) = z+1 := by dsimp [z]; omega
        change (F Y).testBit (m+1-(i+2)) = _
        rw [idx, testBit_F_succ]
        simp [inside, show i < w by omega, show i+1 < w by omega, show i ≤ Y.log2 by omega,
          show i+1 ≤ Y.log2 by omega, show i+2 ≤ Y.log2 by omega,
          show z+2 = Y.log2-i by dsimp [z]; omega,
          show z+1 = Y.log2-(i+1) by dsimp [z]; omega, z, m]
  · have h1 := Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (band_lt w (F Y))
        (Nat.pow_le_pow_right (by decide : 0 < 2) (by omega : w ≤ i)))
    have h2 : bandStep w (topBand w Y) < 2^w := Nat.mod_lt _ (Nat.two_pow_pos _)
    rw [h1, Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le h2 (Nat.pow_le_pow_right (by decide) (by omega : w ≤ i)))]


private theorem collision (N : Nat) (a : Nat → Nat) (h : ∀ t, a t < N) :
    ∃ i j, i < j ∧ j ≤ N ∧ a i = a j := by
  apply Classical.byContradiction
  intro hn
  have nd := Rule30Jen.nodup_map_of_inj a (List.nodup_range (n := N+1)) (by
    intro i hi j hj e
    simp only [List.mem_range] at hi hj
    rcases Nat.lt_trichotomy i j with lt | eq | gt
    · exact (hn ⟨i,j,lt,by omega,e⟩).elim
    · exact eq
    · exact (hn ⟨j,i,gt,by omega,e.symm⟩).elim)
  have size := Rule30Jen.length_le_of_subset (l₂ := List.range N) nd (by
    intro x hx
    obtain ⟨t,_,rfl⟩ := List.mem_map.mp hx
    exact List.mem_range.mpr (h t))
  simp at size
  omega

private theorem orbit_add (w v i n : Nat) :
    bandAt w v (i+n) = bandAt w (bandAt w v i) n := by
  induction n with
  | zero => rfl
  | succ n ih => change bandStep w (bandAt w v (i+n)) = bandStep w (bandAt w (bandAt w v i) n); rw [ih]

private theorem push_eq {w v i j : Nat} (eq : bandAt w v i = bandAt w v j) (n : Nat) :
    bandAt w v (i+n) = bandAt w v (j+n) := by rw [orbit_add, orbit_add w v j, eq]

private theorem band_at_odd {n v : Nat} (odd : OddBand (n+1) v) (t : Nat) :
    OddBand (n+1) (bandAt (n+1) v t) := by
  induction t with
  | zero => exact odd
  | succ t ih => exact ⟨Nat.mod_lt _ (Nat.two_pow_pos _), (stepK_bit_zero (by omega) _).trans ih.2⟩

/-- A periodic odd word returns within the exact fuel used by A1's search.
Dividing an odd word by two codes the 2^n words at width n+1 injectively. -/
private theorem short_return {n v q : Nat} (odd : OddBand (n+1) v) (hq : 0 < q)
    (cycle : bandAt (n+1) v q = v) :
    ∃ p, 0 < p ∧ p ≤ 2^n ∧ bandAt (n+1) v p = v := by
  let a := bandAt (n+1) v
  obtain ⟨i,j,lt,bound,eq⟩ := collision (2^n) (fun t => a t / 2) (by
    intro t
    have h := (band_at_odd odd t).1
    rw [Nat.pow_succ] at h
    dsimp [a]; omega)
  have parity (t) : a t % 2 = 1 := by simpa [a, Nat.testBit_zero] using (band_at_odd odd t).2
  have same : a i = a j := by have := parity i; have := parity j; omega
  let b := (i+1)*q
  have le : i ≤ b := Nat.le_trans (by omega : i ≤ i+1) (Nat.le_mul_of_pos_right _ hq)
  have translated := push_eq same (b-i)
  have ix : i+(b-i) = 0+(i+1)*q := by dsimp [b]; omega
  have jx : j+(b-i) = (j-i)+(i+1)*q := by dsimp [b] at *; omega
  rw [ix, jx] at translated
  unfold bandAt at translated
  rw [rowAt_add_mul cycle, rowAt_add_mul cycle] at translated
  exact ⟨j-i,by omega,by omega,translated.symm⟩

private theorem walk_finds (w v fuel elapsed : Nat)
    (h : ∃ p, elapsed < p ∧ p ≤ elapsed+fuel ∧ bandAt w v p = v) :
    ∃ q, returnPeriod.walk w v fuel (bandAt w v elapsed) elapsed = some q ∧
      0 < q ∧ bandAt w v q = v := by
  induction fuel generalizing elapsed with
  | zero => obtain ⟨_,_,_,_⟩ := h; omega
  | succ fuel ih =>
    rw [returnPeriod.walk]
    split <;> rename_i eq
    · exact ⟨elapsed+1,rfl,by omega,eq⟩
    · apply ih (elapsed+1)
      obtain ⟨p,lo,hi,hp⟩ := h
      have ne : p ≠ elapsed+1 := by rintro rfl; exact eq hp
      exact ⟨p,by omega,by omega,hp⟩


private theorem fold_bound (step : Nat → Nat → Nat) (lower : ∀ b i, step b i ≤ b)
    (xs : List Nat) (b : Nat) : xs.foldl step b ≤ b := by
  induction xs generalizing b with
  | nil => exact Nat.le_refl _
  | cons a xs ih => exact Nat.le_trans (ih _) (lower b a)

private theorem fold_hit (step : Nat → Nat → Nat) (lower : ∀ b i, step b i ≤ b)
    {i limit : Nat} (hit : ∀ a, step a i ≤ limit) (xs : List Nat) (b : Nat) (mem : i ∈ xs) :
    xs.foldl step b ≤ limit := by
  induction xs generalizing b with
  | nil => simp at mem
  | cons a xs ih =>
    rcases List.mem_cons.mp mem with rfl | hm
    · exact Nat.le_trans (fold_bound step lower xs _) (hit b)
    · exact ih _ hm

private def entry (w b i : Nat) := match returnPeriod w (2*i+1) with
  | none => b
  | some p => min b (phaseCapacity w (2*i+1) p)

private theorem entry_le (w b i : Nat) : entry w b i ≤ b := by
  unfold entry; split
  · exact Nat.le_refl _
  · exact Nat.min_le_left ..

theorem capacity_on_cycle {w v : Nat} (hw : 0 < w) (odd : OddBand w v)
    (cycle : ∃ q, 0 < q ∧ bandAt w v q = v) :
    ∃ q, 0 < q ∧ bandAt w v q = v ∧ K1 w ≤ phaseCapacity w v q := by
  obtain ⟨n,rfl⟩ : ∃ n, w = n+1 := ⟨w-1,by omega⟩
  obtain ⟨q,hq,period⟩ := cycle
  obtain ⟨p,hp,bound,ret⟩ := short_return odd hq period
  obtain ⟨q',got,pos,period'⟩ := walk_finds (n+1) v (2^n) 0 ⟨p,hp,by omega,ret⟩
  have found : returnPeriod (n+1) v = some q' := got
  have lo := odd.1
  rw [Nat.pow_succ] at lo
  have parity : v%2 = 1 := by simpa [Nat.testBit_zero] using odd.2
  have eq : 2*(v/2)+1 = v := by omega
  refine ⟨q',pos,period',fold_hit (entry (n+1)) (entry_le _) (i := v/2) ?_ _ _ ?_⟩
  · intro a; simp only [entry,eq,found]; exact Nat.min_le_right ..
  · apply List.mem_range.mpr; omega

/-- A full physical band evolves autonomously from age w-1. Finite-state
pigeonhole gives the seed-independent age in the reviewed statement. -/
theorem uniform_settling {w : Nat} (hw : 0 < w) : Settled w (settlingBound w) := by
  intro Y t nz aged
  let s := w-1
  let a (i : Nat) := topBand w (iter F (s+i) Y)
  have log (i : Nat) := log_of_top (orbit_top nz i)
  have positive (i : Nat) : iter F i Y ≠ 0 := by
    intro z; simpa [z] using (orbit_top nz i).1
  have step (i : Nat) : a (i+1) = bandStep w (a i) := by
    dsimp only [a]
    rw [← Nat.add_assoc, iter]
    exact band_evolves (w := w) (positive (s+i)) (by rw [log]; dsimp [s]; omega)
  have advanceOrbit (i n : Nat) : bandAt w (a i) n = a (i+n) := by
    induction n with
    | zero => rfl
    | succ n ih => exact (congrArg (bandStep w) ih).trans (step (i+n)).symm
  obtain ⟨i,j,lt,bound,eq⟩ := collision (2^w) a fun _ => band_lt _ _
  have st : s+2^w ≤ t := aged
  let l := t-s
  have li : i ≤ l := by dsimp [l]; omega
  have cyc := congrArg (fun x => bandAt w x (l-i)) eq
  change bandAt w (a i) (l-i) = bandAt w (a j) (l-i) at cyc
  rw [advanceOrbit, advanceOrbit, show i+(l-i) = l by omega,
    show j+(l-i) = l+(j-i) by omega] at cyc
  have tl : s+l = t := by dsimp [l]; omega
  have per : bandAt w (a l) (j-i) = a l := (advanceOrbit l _).trans cyc.symm
  dsimp only [a] at per
  rw [tl] at per
  refine ⟨by rw [log]; dsimp [s] at st; omega, ⟨band_lt _ _, ?_⟩, j-i, by omega, per⟩
  rw [band_bit]; simp [hw, Nat.testBit_log2 (positive t)]


private theorem matches_band {P : Row} {t Y w : Nat} (nz : Y ≠ 0) (full : w ≤ Y.log2+1)
    (hpre : ∀ x, 1 ≤ x → zrow P t x = rowOfNat Y x) :
    Matches (zrow P t) (Y.log2+1) (topBand w Y) w := by
  constructor
  · simpa only [hpre _ (by omega : 1 ≤ Y.log2+1), rowOfNat] using (top_log nz).1
  · intro x hx
    obtain ⟨i,rfl⟩ : ∃ i, x = i+1 := ⟨x-1,by omega⟩
    rw [hpre _ (by omega)]
    change Y.testBit i = reference (Y.log2+1) (topBand w Y) (i+1)
    by_cases hi : i ≤ Y.log2
    · have idx : Y.log2+1-(i+1) = Y.log2-i := by omega
      simp [reference,hi,band_bit,idx,show Y.log2-i < w by omega,
        show Y.log2-(Y.log2-i) = i by omega]
    · rw [(top_log nz).2 i (by omega)]
      simp [reference,hi]

private theorem integer_edge {k w age Y t : Nat} {P : Row} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) (nz : Y ≠ 0) (aged : age ≤ t)
    (pre : ∀ x, 1 ≤ x → zrow P k x = rowOfNat (iter F t Y) x) :
    0 < Y.log2+t+1-k ∧ P (Y.log2+t+1-k) = true ∧ ∀ x, Y.log2+t+1-k < x → P x = false := by
  let Z := iter F t Y
  have top := orbit_top nz t
  have zn : Z ≠ 0 := by intro h; have z : Z.testBit (Y.log2+t) = true := top.1; simp [h] at z
  obtain ⟨full,odd,cycle⟩ := settled Y t nz aged
  obtain ⟨q,pos,ret,bound⟩ := capacity_on_cycle hw odd cycle
  have ma := matches_band zn full pre
  have ed := scheduled_edge pos ret w 0 w k (Z.log2+1) P (Nat.le_refl _) full
    (by simpa [earlier, rowAt] using ma) (Nat.le_trans cap bound)
  have log : Z.log2 = Y.log2+t := log_of_top top
  rw [log] at ed
  have posEdge : 1 ≤ Y.log2+t+1-k := by
    apply Classical.byContradiction
    intro h
    have z : Y.log2+t+1-k = 0 := by omega
    have bad := ed.1
    rw [z,zrow_wall] at bad
    contradiction
  exact ⟨posEdge,(zrow_zero_of_pos P posEdge).symm.trans ed.1, fun x hx =>
    (zrow_zero_of_pos P (by omega : 1 ≤ x)).symm.trans (ed.2 x hx)⟩

private theorem physical_clause {k w age : Nat} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) : PhysicalEdge k age := by
  intro L m t hm edge finite aged P pre
  let Y := natOfRow L m
  have top : Top Y (m-1) := by
    constructor
    · simpa [Y,testBit_natOfRow,show m-1 < m by omega,show m-1+1=m by omega] using edge
    · intro i hi; simp [Y,testBit_natOfRow,show ¬ i<m by omega]
  have nz : Y ≠ 0 := by intro z; simpa [z] using top.1
  have log := log_of_top top
  have rep := rowOfNat_natOfRow finite
  have ed := integer_edge hw cap settled nz aged (P := P) (fun x hx =>
    (pre x hx).trans ((zrow_congr (fun j hj => (rep j hj).symm) t x).trans (zrow_rowOfNat Y t x)))
  simpa only [log,show m-1+t+1 = m+t by omega] using ed.2

private theorem finite_clause {k w age : Nat} (hw : 0 < w) (cap : k ≤ K1 w)
    (settled : Settled w age) : FinitePredecessor k age := by
  intro Y t nz aged L pre
  obtain ⟨positive,edge,tail⟩ := integer_edge hw cap settled nz aged pre
  let e := Y.log2+t+1-k
  let A := natOfRow L e
  have rep : ∀ x, 1 ≤ x → rowOfNat A x = L x := rowOfNat_natOfRow tail
  have image : iter F k A = iter F t Y := by
    apply Nat.eq_of_testBit_eq
    intro i
    exact (zrow_rowOfNat A k (i+1)).symm.trans ((zrow_congr rep k _).trans (pre _ (by omega)))
  refine ⟨A,rep,image,?_,?_⟩
  · have ha := rep e positive
    obtain ⟨i,hi⟩ : ∃ i, e = i+1 := ⟨e-1,by omega⟩
    rw [hi] at ha
    change A.testBit i = L (i+1) at ha
    have eq : Y.log2+t-k = i := by dsimp [e] at hi; omega
    rw [eq, ha, ← hi]; exact edge
  · intro i hi
    have ht : e < i+1 := by dsimp [e]; omega
    exact (rep (i+1) (by omega)).trans (tail _ ht)

/-- Build a physical history with prescribed cell-1 bits in forward order,
allowing arbitrary support until the physical edge theorem is applied. -/
private theorem history (k : Nat) (E : Row) (bits : Fin k → Bool) :
    ∃ L : Row, (∀ x, 1 ≤ x → zrow L k x = E x) ∧
      ∀ i : Fin k, zrow L i.val 1 = bits i := by
  induction k with
  | zero => exact ⟨E,fun _ => zrow_zero_of_pos E,fun i => Fin.elim0 i⟩
  | succ k ih =>
    obtain ⟨P,endP,wall⟩ := ih (fun i => bits i.succ)
    let L := back (bits 0) P
    have shift (i x : Nat) : zrow L (i+1) x = zrow P i x := by
      rw [Nat.add_comm i 1,zrow_shift]
      exact zrow_congr (zrow_back (bits 0) P) i x
    refine ⟨L,fun x hx => (shift k x).trans (endP x hx),?_⟩
    intro i
    refine Fin.cases ?_ (fun j => ?_) i
    · rfl
    · exact (shift j.val 1).trans (wall j)

theorem capacity_at_settling_age : CapacityAtSettlingAge := by
  intro k w age hw cap settled
  have finite := finite_clause hw cap settled
  refine ⟨physical_clause hw cap settled,finite,?_⟩
  intro Y t nz aged bits
  obtain ⟨L,pre,trace⟩ := history k (rowOfNat (iter F t Y)) bits
  obtain ⟨A,rep,image,top⟩ := finite Y t nz aged L pre
  exact ⟨A,image,top,fun i => (zrow_rowOfNat A i.val 1).symm.trans
    ((zrow_congr rep i.val 1).trans (trace i))⟩

theorem conditional_every_k : ConditionalEveryK := by
  intro capacity k
  have spec : 0 < widthFor capacity k ∧ k ≤ K1 (widthFor capacity k) := by
    unfold widthFor
    dsimp only
    cases h : (List.range (capacity k).choose).find? (fun w => decide (0 < w ∧ k ≤ K1 w)) with
    | none => exact (capacity k).choose_spec
    | some w =>
      have found := List.find?_some h
      exact of_decide_eq_true found
  exact capacity_at_settling_age k _ _ spec.1 spec.2 (uniform_settling spec.1)

end Ruliology.CellularAutomata.Rule30EveryKInverse

namespace Rule30Submission

open Ruliology.CellularAutomata Rule30EveryKStatement

theorem conditional_every_k : ConditionalEveryK :=
  Rule30EveryKInverse.conditional_every_k

theorem capacity_at_settling_age : CapacityAtSettlingAge :=
  Rule30EveryKInverse.capacity_at_settling_age

end Rule30Submission
", "ProjectDir" -> $Rule30PrizeKit]
```

## The formal checks

The two headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.conditional_every_k", "Rule30Submission.capacity_at_settling_age"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms are standard ones only:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs; it comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.conditional_every_k"]["KernelCheck"]
```
