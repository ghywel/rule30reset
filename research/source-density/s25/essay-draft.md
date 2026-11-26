---
Template: ComputationalEssay
Name: The Upper Corner of Rule 30's Density Pentagon Is Rigid: a Bounded Deficit Fixes the Whole Left Half to One 155-Column Film
Author: {AUTHORS}
Date: 2026-11-26
Description: Core Lean. At a site of any rule 30 history, a bounded deficit at the corner (9/10, 2/5) of the density pentagon makes the whole left half one ten-tick film of 155 columns from a common tick on; so every ring at that corner, of any temporal period, has width divisible by 155.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, density, black frequency, run ends, pentagon, extreme point, rigidity, potential, zero-loss graph, spatial period, ring width, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

A history is a function `u t i` of tick `t` and site `i` that obeys rule 30 at every tick and site (`Evolution u`). At a site `j`, count in the first `n` ticks the black cells at `j`, `C(n)`, and the run ends, ticks where `j` is black and `j + 1` is white, `A(n)` (`black u j 0 n` and `ends u j 0 n`).

Our entry R30-20261123-b2be99 found the exact region of the limiting pair `(C(n)/n, A(n)/n)`: the pentagon `0 ≤ a ≤ c`, `3c ≤ 1 + 5a`, `2c ≤ 1 + 2a`, `6c ≤ 5 + a`. Its corner `(9/10, 2/5)` is exposed by `8c − 3a ≤ 6`. With its six-cell potential, the deficit `D(n) = 6n + 3A(n) − 8C(n)` is at least −6 on every history.

**The theorems**, all in the namespace `Rule30Submission`:
- `aligned_of_bounded`: if `D(n) ≤ B` for every `n`, there is a tick `s` after which column `j` reads `1111111110` and column `j + 1` reads `1010101010`, over and over, in phase (`Aligned`).
- `left_unique`: two histories with these two columns agree, from that tick, on every column to the left.
- `rigid_left_of_bounded`: so, if `D` is bounded above, from one tick `s` on the whole left half, columns `j, j − 1, j − 2, …`, equals one explicit film `film`, of temporal period 10 and spatial period 155. Nothing is assumed about the columns to the right of `j + 1`, or about the history before `s`.
- `return_multiple`: any spatial return of the two observed columns has width divisible by 155.
- `ring_width`: on a history of temporal period `p > 0` and spatial period `w`, if `D(p) = 0`, then 155 divides `w`.
- `sharp_ring`: the film is such a history, with period 10 in time and 155 in space, and 9 blacks and 4 run ends in ten ticks.

So 155 is the least width of a ring that meets the corner exactly, whatever its temporal period.

## 2. Where it sits

| | Earlier: R30-20261123-b2be99 (in the kit) | This entry |
|---|---|---|
| bounds at the corner | `8C − 3A ≤ 6n + 6` on every history, from the potential | equality up to a bound forces the left half |
| histories at the corner | a 155-column ring of period 10, found by computer search | every bounded-deficit history, from one tick on |
| least width | 155 among rings of temporal period 10, by search; "no theorem says so" | 155 for every temporal period, proved |

The single seed is not affected: the earlier entry already shows that its deficit grows at least like the logarithm of `n` (`Rule30DensityMargin.margin_nine_tenths`).

## 3. Exploration

**The film from two columns.** Rule 30 is permutive in its left cell: if `c` and `r` are a column and its right neighbour, the column to the left reads `c(t + 1) ⊕ (c(t) ∨ r(t))`. Start from the two observed columns, ten ticks each, and step left until the pair comes back:

```wl
observed = {Join[ConstantArray[1, 9], {0}], Table[Boole[EvenQ[t]], {t, 0, 9}]};
leftOf[{c_, r_}] := {Table[BitXor[c[[Mod[t + 1, 10] + 1]], BitOr[c[[t + 1]], r[[t + 1]]]], {t, 0, 9}], c};
pairs = NestList[leftOf, observed, 400];
First[Flatten[Position[Rest[pairs], observed]]]
```

The first return is after 155 columns. Here is the film, ten ticks down and 155 columns across, the observed site at the right edge:

```wl
rows = Transpose[Reverse[pairs[[1 ;; 155, 1]]]];
ArrayPlot[Join[rows, rows], Frame -> False, PixelConstrained -> 4]
```

**It is a rule 30 ring.** On a ring of 155 cells, each row steps to the next, and the tenth to the first. At the observed site there are 9 blacks and 4 run ends in ten ticks, so the deficit over a period is 0:

```wl
site = rows[[All, 155]]; rightSite = rows[[All, 1]];
{And @@ Table[CellularAutomaton[30, rows[[t]], 1][[2]] == rows[[Mod[t, 10] + 1]], {t, 10}],
 Total[site], Count[Transpose[{site, rightSite}], {1, 0}], 6*10 + 3*Count[Transpose[{site, rightSite}], {1, 0}] - 8*Total[site]}
```

**A glide.** Turning the ring by 31 columns gives the film eight ticks later. So 155 = 5 × 31, and a fundamental domain of the film has 310 cells:

```wl
Select[Flatten[Table[{s, k}, {s, 1, 154}, {k, 1, 9}], 1],
 And @@ Table[RotateLeft[rows[[t]], #[[1]]] == rows[[Mod[t - 1 + #[[2]], 10] + 1]], {t, 10}] &]
```

The glide does not change `ring_width`, which is about a pure spatial period.

## 4. The proof

1. **The loss** (the earlier entry's `Rule30DensityEscape`). A potential on six cells at `j` makes `D(n)` plus the initial potential minus the current one a sum of nonnegative losses, one per tick (`range_potential`, `band_edge`). The potential lies between 0 and 6.
2. **Bounded means eventually lossless** (`aligned_of_bounded`). If `D ≤ B`, the accumulated loss is at most `B + 6`. It is a nondecreasing integer, so it attains its maximum at some tick. After that every tick has zero loss, so the six-cell words at `j` follow edges of the kit's zero-loss graph `next`.
3. **Pruning** (`survive`). A word on an infinite path needs a predecessor and a successor on it. Four rounds of removing words without both leave 14 of the 64 six-cell words: 64, 20, 17, 15, 14. They fall into ten phases, and every surviving edge advances the phase by one, checked by kernel computation. From four ticks into the lossless stretch the phase advances every tick, and the phase fixes the two observed cells. This gives the aligned columns.
4. **To the left** (`left_unique`, `return_multiple`). By left permutivity the two columns fix the next column to the left, and so on, by induction over the distance. The resulting columns are the film's `column d`, computed once in a table of 155 pairs. The kernel checks that the table steps correctly through both seams and that no displacement below 155 repeats the observed pair.
5. **Rings** (`ring_width`). If the history has temporal period `p` and `D(p) = 0`, the accumulated loss after one period is 0, so every loss is 0 from the start. Step 3 aligns the columns, and a spatial period `w` is then a return of the observed pair, so 155 divides `w`.
6. **The film** (`sharp_ring`, `rigid_left_of_bounded`). The film obeys rule 30 at all 1,550 cells of a period, checked by kernel computation. It is aligned at site 0, so step 4 identifies every bounded-deficit left half with it.

## 5. Prior art and credit

- **The region and the corner** are our entry R30-20261123-b2be99, in the kit as thirteen modules (`Rule30SourceDensityRegion` to `Rule30DensityMixtures`). Its six-cell potential, its zero-loss graph, its period-ten corner film and its search for the least width at period ten are used here. The earlier essay said that 155 was the least width at period ten by search, and that no theorem said so.
- **The counts** `C` and `A` are those of David Condrey's `Rule30SourceObservables` (with OpenAI Codex), in the kit.
- **The search** for the least width was a SAT search over rings of temporal period ten, in the rule30reset record.
- **Search.** We searched the portal's 437 entries, the kit's catalogue and its open pull requests for the density corner, its films or the number 155. We found only the earlier entry.

## 6. What is not proved

- A history whose frequencies only converge to the corner has `D(n)/n → 0`, not a bounded `D`. The theorem says nothing about it.
- The other four corners are not treated here.
- The single seed's limiting frequencies, if they exist, are not decided. Problem 2 is not settled.

## The formal proof

The module is core Lean. It imports the kit's `Rule30Realization` and `Rule30Prize`, both present at the verifier's kit revision. Three kit modules that the revision lacks are carried, in their own namespaces, as in the kit at `71151d0`: David Condrey's `Rule30SourceObservables`, which defines the counts, and the earlier entry's `Rule30SourceDensityRegion` and `Rule30DensityEscape`. Then comes the module of this entry, in `Rule30Submission`, which holds the six headlines.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The six headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.rigid_left_of_bounded", "Rule30Submission.ring_width", "Rule30Submission.sharp_ring", "Rule30Submission.aligned_of_bounded", "Rule30Submission.return_multiple", "Rule30Submission.left_unique"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.sharp_ring"]["KernelCheck"]
```
