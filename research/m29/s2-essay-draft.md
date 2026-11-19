---
Template: ComputationalEssay
Name: Every Number of Inverse Ticks Beside the White Wall: One Argument for Every k, Conditional on Reset Capacity
Author: {AUTHORS}
Date: {DATE}
Description: Core Lean. For every k at once, one argument proves that from an explicit age every k-tick predecessor of a nonzero finite row beside the white wall is finite with its edge exactly k cells inside, assuming one named property of the edge band, reset capacity. The property is open. Nothing here decides Q01.
Abstract: In core Lean 4.35.0 we prove the kit's inverse-tick statement beside the fixed white wall for every number of ticks k, by one argument, conditional on one named hypothesis. A row's top w cells evolve on their own by a band map. Let `K1 w` be the number of inverse layers that a fixed schedule of reset words clears on every phase of every cycle of that map. If every k has a width w with `K1 w ≥ k` (`CAP`), then for every k, every nonzero finite seed and every age t ≥ w − 1 + 2ʷ, with w the least such width, every k-tick predecessor of the row at age t, a priori of infinite support, is finite with its last black cell exactly k cells inside the row's edge, and every choice of the k cells beside the wall occurs (`Rule30Submission.conditional_every_k`). The catalog has one tick from age 8 and two from age 24 (`Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`), and our earlier entry four from age 80, each by its own cover. The proof is one induction over the layers: a closed black run of length 1 mod 3 fixes the layer below it, as in kit pull request 60, and each layer reads the band one tick earlier on its cycle. `CAP` is open. It holds for k ≤ 7,911 by an exact computation outside Lean, and would follow from every phase of every recurrent infinite strip having such runs arbitrarily deep. Nothing here decides `Q01`.
Keywords: [rule 30, Rule 30 Prize, zero-boundary left half, white wall, predecessors, inverse ticks, every k, edge band, reset words, conditional theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

The setting is the kit's zero-boundary left half: rule 30 on the cells at depths 1, 2, 3, … beside a wall at depth 0 that stays white (`Rule30ZeroBoundary.zrow`). A finite row is a natural number with depth `i + 1` in bit `i`, and one tick is `F Y = (Y >>> 1) ^^^ (Y ||| (Y <<< 1))`. A nonzero finite row gains exactly one cell per tick at its outer edge.

A *k-tick predecessor* of a row `Z` is a row `L`, a priori of infinite support, whose image `k` ticks later is `Z` at every positive depth. Going back one tick has one free choice, the parent's cell beside the wall, so a row has `2^k` histories of `k` ticks. The target for `k` ticks from age `a` (`TargetAt k a`) has three clauses. For every nonzero finite seed `Y` and every age `t ≥ a`:
- every `k`-tick predecessor of `Fᵗ Y` has its last black cell exactly `k` cells inside the edge of `Fᵗ Y`, and is white beyond it (`PhysicalEdge`);
- it is the row of a natural number `A` with `Fᵏ A = Fᵗ Y` (`FinitePredecessor`);
- each of the `2^k` choices of the `k` cells beside the wall occurs (`AllHistories`).

This generalises the kit's two-tick theorem from age 24 (`finite_row_aged_image_two_step_predecessor_true_edge`) and the two headlines of our four-tick entry from age 80.

**The edge band.** Number the cells of a row from its edge inwards: *wheel* `j` is the cell `j` places in from the last black cell. The top `w` cells, as a word `v` with wheel `j` in bit `j`, evolve on their own by the band map `v ↦ (4v ⊕ (2v ∨ v)) mod 2ʷ` (the kit's `Rule30UniversalLeftSide.stepK`). Wheel 0 is black, so the band is an odd residue (`OddBand`).

**Reset words.** A *reset word* is a closed black run whose length is one more than a multiple of three, `0 1^(3m+1) 0`, followed by one more symbol (`resetAt`). Inverting one tick reads the row from the wall side towards the edge, with a register of two parent cells. Started with all four registers allowed, the four readings agree from the symbol just after the first reset word they read in full, all the way to the edge.

**The schedule and its capacity.** Fix a word `v` on a cycle of the band map. Layer 1 reads `v` from its deepest wheel and stops at the deepest complete reset word (`firstReset`). Its four readings then agree on the parent's bits from there to the edge. Layer 2 reads the cycle's word one tick earlier, on exactly those bits, and so on: layer `d` reads phase `−d` of the same cycle (`schedule`). `K1 w` is the least number of layers this schedule closes, over every cycle of the band map at width `w` and every phase of each (`K1`). No single cycle is assumed.

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

**One inverse layer, and the reset rule.** The closed black runs of a word, the deepest complete reset word (`firstReset`), and one inverse layer started at wheel `s` with each of its four registers, giving the parent's wheels. On every phase of the single cell's cycle at width 200, the four readings agree on the parent's wheels from `j − 1` to the edge, where `j` is the wheel of the symbol just after the reset word that `firstReset` finds. Each pair below is the parent wheel from which they agree, then `j − 1`:

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

In Lean, the module's controls certify `K1 8 ≥ 1` and `K1 20 ≥ 2` by kernel reduction. With the counting bound they prove the one- and two-tick statements from ages 263 and 1,048,595, without the hypothesis. The kit puts every seed's band on `C20` from age 26 (`band_from_age_twenty_six`), so the sharper form gives both from age 26. These are the kit's two statements, at ages that are not sharp.

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

So the single cell needs ages 6, 19, 29, 50 and 57. The sharp ages over every seed are larger (section 5).

**Where the open statement lives.** The permanently white wheels of the single cell's cycle at width 450, and the interval from each to the next. For each interval: its two ends, the least period of the column just before it, whether the column just after it is antiperiodic at that period (a *doubling*: the clock doubles there), and in how many of the cycle's phases a reset word lies wholly inside it:

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

All three intervals are doublings, with source periods 1, 2 and 4, and each has a reset word in every phase. The white wheels at 28 and 399 are the kit's white diagonals (`Rule30LeftAntiPeriod`). Section 6 says why a reset in every phase of every doubling is the open statement.

## 4. The idea of the proof

1. **The band settles.** After `w − 1` ticks every nonzero row is at least `w` cells wide, and from then on its band evolves by the band map alone. The odd bands are finitely many, so by `w − 1 + 2^w` the band is on a cycle (`Settled`).
2. **The reset rule.** After an inverse layer has read a reset word and the symbol `z` after it, its register is (black, not `z`), whichever of the four registers it started from (`scheduled_layer`). So the four readings agree from there to the edge. That they agree nowhere earlier is a separate finite automaton check in our record, which the proof does not need. The same reset step is Lowry's `run_resets` in kit pull request 60, reproved here and credited.
3. **The schedule closes `k` layers.** Let the row's band be on a cycle whose every phase admits `k` layers. Each layer starts with every register allowed, so it covers every possible deeper part of every predecessor, infinite black tails included. Where it coalesces, every predecessor agrees with every other. Layer `d` reads the cycle's phase `−d`. The true ancestors' bands may still be transient there, but this does not matter. The cycle's phase `−1` is a band predecessor of phase 0, and coalescence makes every predecessor agree with it on the bits the layer fixed, the true ancestor included. So the next layer reads bits that are the same for every predecessor. The symbol after a reset word is never at wheel 0, since wheel 1 of a band with a black edge is black. When it is at wheel 1, the register it leaves is the parent's black edge and the white cell beyond it. That a supplied schedule of resets closes a cascade of any finite height is Lowry's `scheduled_cascade_closes` in kit pull request 60, reproved here and credited. What is new is where the schedule comes from: the capacity of the settled band, read against the phases of its cycle.
4. **The edge.** After `k` layers every predecessor agrees with the true ancestor to the edge, and the registers are zero beyond it, so every predecessor is finite. A nonzero finite row gains exactly one cell per tick, so its edge is `k` cells inside (`scheduled_edge`).
5. **The histories.** Going back one tick, prescribe the parent's cell beside the wall and reconstruct the rest of the parent from the wall outwards. Doing this at each of the `k` steps, in reverse order of the requested history, gives a predecessor with any prescribed cells beside the wall. By step 4 each one is finite, so it is the row of a natural number.

Nothing in these steps is a cover for a particular `k`. The number of layers is a variable of one induction, and the only input that depends on `k` is the width at which the capacity reaches `k`.

## 5. Why the ages grow

The theorem gives `f(k) ≤ g(W(k))`, where `W(k)` is the least width of capacity `k` and `g(w)` is the age by which every band of width `w` has settled. Two costs combine: the width the capacity needs, and the time that width takes to settle.
- **Width per layer.** Each layer spends one reset word, and along the schedule the usable reset words come about once every 11 wheels. Our exact schedule on the kit's four strips clears 7,911 layers at width 87,867, at 10.7 to 11.1 wheels per layer from width 4,096 on. So `W(k)` is about `11k` in that range.
- **Time per wheel.** The band settles in about 1.3 to 1.4 ticks per cell, in the samples above and in the moving cover.
- **Together** they suggest sufficient ages of about 15 ticks per layer, which is why each further tick has cost more age. The product is a heuristic: the two rates are measured over different ranges of width. The sharp age is 8 for one tick, 24 for two and 31 for three. It lies between 59 and 72 for four, 73 and 78 for five, and 104 and 108 for six. For seven to eleven ticks our upper bounds are 131, 132, 144, 157 and 172.
- **What is proved of the rates.** `g(w) ≤ w − 1 + 2^w` in general. At width 87,867 the kit's explicit fronts give `g ≤ 265,441` (`forced_front_four_uniform`). With the computed capacity this gives `f(k) ≤ 265,441` for every `k ≤ 7,911`, outside Lean. A linear `f` is not proved.

## 6. What is proved, and the one open statement

**In Lean, here:** `CAP` implies the target for every `k`, with the age `W(k) − 1 + 2^W(k)`, and the sharper form at any proved settling age.

**The hypothesis, by hand.** `CAP` would follow from this statement, which we call `(L∞)`: every phase word of every pointed recurrent strip contains reset words at arbitrarily large depths. A pointed recurrent strip is an infinite left side, with a black edge, on which every finite prefix of wheels is periodic in time. The cycles of the band map are exactly their finite prefixes, so depths without bound only make sense on the strips. Given resets in the `k` phases a schedule reads, deep enough, the schedule closes `k` layers. Compactness of the phases, and of the strips, then gives one width for all of them. Conversely, a phase with a last reset limits every width's capacity, so `(L∞)` is also what this route needs.

**The one open statement** is `(L∞)`. It has an equivalent form, and a lemma that would prove it:
- **Unique predecessors.** On the left side read as a 2-adic integer, with the band map as `x ↦ 4x ⊕ (2x ∨ x)`, `(L∞)` says that every recurrent point has exactly one preimage.
- **The doubling lemma.** The least common period of every prefix of a strip is a power of two, and it is first lost just after a permanently white wheel, where it doubles. Both are proved in Lean in our record. So every strip has such doubling intervals past every depth. So `(L∞)` follows, by a short hand argument, from a lemma: *every white interval at which the clock doubles contains a reset word in every phase.* Section 3 shows it at the single cell's first three doublings.

**Evidence for the lemma.** It holds wherever we have tested it: at every gap up to 30 for every power-of-two period, at every gap for power-of-two source periods up to 32, with no reset-free doubling at source period 64 below gap 74 except one undecided gap, and none at source period 128 up to gap 64. An exhaustive listing over every source period finds no doubling at all at gaps 31 to 55; at gaps 45, 50 and 51 to 55 the listing's completeness has a machine-checked proof. For source periods up to 28, the only doublings that return to white within 100 wheels are six from a source with one black tick per period, and the only one with a tick that has no reset is at period 5, which is not a power of two.

**What is proved towards it.** In Lean, on every pointed recurrent strip and from every starting tick, one fixed phase among any three consecutive phases has reset words at arbitrarily large depths. That is not enough, because the schedule needs the `k` consecutive phases it reads, not one chosen among them.

**Barriers.** Some pointed recurrent strip has a phase in which every wheel just beyond a permanently white wheel is black. That is certified in Lean, and it rules out an argument through such white diagonals alone. An eight-cell ring of period five has two consecutive phases with no reset word, so white-wheel constraints alone, read in one or two phases, do not force a reset. It has no physical edge and no power-of-two clock, which is why the lemma is stated for doublings.

## 7. Prior art and credit

- **The kit** supplies the setting and the tools: `Rule30ZeroBoundary` (the zero-boundary row, the integer form and the backward transducer), and the left-side recurrence of `Rule30AgedLeftDiagonals` (Lowry with OpenAI Codex). The one- and two-tick theorems are `Rule30AgeEightInverse` and `Rule30AgeTwentyFourInverse` by Scott Hughes with OpenAI Codex, with `band_from_age_twenty_six` by G.P.J.W. Quint and Gemini. The white diagonals at 28, 399 and 53,207 are in `Rule30LeftAntiPeriod` (Quint and Gemini). `Rule30ResetFreeThree` (Lowry with OpenAI Codex) puts a reset word in one of any three consecutive rows of a finite row's orbit.
- **The reset step and the cascade** are Lowry's, in kit pull request 60 (`run_resets`, `scheduled_cascade_closes`), open and unmerged, with the presence of resets as their hypothesis. The verifier's kit revision predates it, so this module proves both steps locally, with that credit; the kit version would import them once 60 is merged. Kit pull requests 47 and 52 close inverse cascades under reset or gate hypotheses on a reference trajectory.
- **Ancestry beside the wall.** `Rule30WallRecordAncestry` (Lowry, kit pull request 364) builds, for every wall record and every `k`, a finite row with a complete finite predecessor tree of height `k`. That is existence for some row, not the age statement for every row.
- **Ours, earlier.** Four ticks from age 80 ([R30-20261118-c8b41f](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261118-c8b41f)). The kit modules `Rule30UniversalLeftSide` (the band map and the left side shared by every configuration through wheel 53,207, whose fork Rowland located in 2006), `Rule30FourLeftSides` and `Rule30FourFronts` (the four strips and their explicit fronts). The reduction of the ages to the edge band's cycles and the capacity, the compactness argument and the computed range are in our public record.
- **Novelty.** The portal's list and the kit's open pull requests have no statement for every `k`. {NOVELTY}

## 8. What is not proved

- `CAP` is not proved. The theorem is conditional, and its hypothesis is open in general. It holds for `k ≤ 7,911` by a computation outside Lean.
- The age is explicit once `W(k)` is known, but `W(k)` is known only where it is computed, and the general settling bound is exponential in the width. The ages are not sharp.
- The theorem is about the zero-boundary left half beside a fixed white wall. It says nothing about the centre column's period, and it does not decide `Q01`.

## The formal proof

{LEAN: stream A's module `Rule30Submission`, A1's definitions with A2 and A3's proofs, carried as in our earlier entry, with any kit modules that the verifier's commit lacks carried byte for byte in a nested namespace.}

## The formal checks

{CHECKS: as in our earlier entry. The headline theorems as Lean prints them, their axioms, and the kernel replay last.}
