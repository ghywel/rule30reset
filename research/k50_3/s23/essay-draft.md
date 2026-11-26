---
Template: ComputationalEssay
Name: Hughes's Inverse Ticks beside Every Wall: Ages 8 and 24, or 9 and 25 Next to the Wall, All Sharp
Author: {AUTHORS}
Date: 2026-11-26
Description: Core Lean. For rule 30's left half driven by a wall column with any values, every predecessor has the true edge from age 8, and every two-step predecessor from age 24; a start next to the wall needs 9 and 25. All four ages are the least.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, inverse ticks, predecessors, driven left half, prescribed wall, boundary column, leftmost black cell, Hughes's ages, sharp ages, finite certificate, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

**The driven left half.** The kit's `Rule30DrivenLeft.L c s t p` runs rule 30 on the sites `p < 0`. Site 0 is a wall: at time `t` it holds `c t`, for any `c : Nat → Bool`, and it is the right neighbour of site −1. The start `s` gives the cells at time 0. The kit shows that the real pattern is such a half from every time on, driven by its centre column (`Rule30DrivenLeft.cell_eq_L`).

**Starts and predecessors.** The start has its leftmost black cell at `-m`, with `m ≥ 1`: `s (-m) = true`, and `s p = false` for `p < -m`. The cells between it and the wall are arbitrary. Then the edge of the row at time `t` is at `-m - t`, whatever the wall does (`Rule30DrivenLeft.edge`). A predecessor of the row at time `t` is any `z : Int → Bool` with `rule (z (p - 1)) (z p) (z (p + 1)) = L c s t p` for every `p < 0`. Its value at the wall is free, and so is everything else about it.

**The theorems**, all in `Rule30Submission.Rule30DrivenLeftInverse`:
- `predecessor_edge`: from age 8 when `m ≥ 2`, and from age 9 when `m = 1`, every predecessor has its leftmost black cell at `-m - t + 1`, the edge of the row one tick earlier.
- `two_step_predecessor_edge`: from age 24 when `m ≥ 2`, and from age 25 when `m = 1`, every predecessor of a predecessor has its leftmost black cell at `-m - t + 2`.
- `sharp_examples`: a single black cell at −2 beside the white wall, aged 7, and a single black cell at −1 beside a wall that is black at tick 2 only, aged 8, have a common predecessor with black cells arbitrarily far to the left. Its wall bit is the wall's own at the time before.
- `sharp_two_step_examples`: black cells at −8 and −5 beside the white wall, aged 23, and a single black cell at −1 beside a wall black at ticks 2, 19 and 20, aged 24, each have a two-step predecessor with black cells arbitrarily far to the left. Both wall bits on the way are the wall's own.
- `least_age_nonadjacent`, `least_age_adjacent`, `two_tick_least_age_nonadjacent`, `two_tick_least_age_adjacent`: so the one-tick conclusion holds at every age from `a` on, for every wall and every start with `m ≥ 2`, exactly when `8 ≤ a`. For `m = 1` it holds exactly when `9 ≤ a`. The two-tick conclusion holds exactly when `24 ≤ a` and `25 ≤ a`.

## 2. Where it sits

| | One tick | Two ticks |
|---|---|---|
| beside the white wall (the kit, Hughes: `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`) | from age 8, for finite rows; age 7 fails, by a control outside Lean | from age 24; age 23 fails, by a control outside Lean |
| on the whole line (`Rule30TwoSidedInverse`) | from age 8, sharp | from age 24, sharp |
| beside every wall (this entry) | from age 8, or 9 next to the wall, sharp | from age 24, or 25 next to the wall, sharp |

With the white wall the start next to it needs no extra tick. The extra tick is forced by walls that change.

## 3. Exploration

**The band at the edge.** Hughes's argument reads the 8 cells next to the edge as a binary number, edge first. From age 8 it is 200 or 222, and below such a band every predecessor resets to white. Beside a wall the band is out of the wall's reach once the row is 8 cells wide. Before that, only the wall's first `8 - m` values reach it. So each start width `m < 8` has 128 cases: the row's `m - 1` free cells and the wall values that matter. The count of bad bands at ages 8 and 9, for `m` from 1 to 7:

```wl
step[row_List, w_Integer] := With[{ext = Join[{0, 0}, row, {w}]},
   Table[BitXor[ext[[i]], BitOr[ext[[i + 1]], ext[[i + 2]]]], {i, Length[row] + 1}]];
aged[row_List, wall_List, t_Integer] := Fold[step[#1, wall[[#2 + 1]]] &, row, Range[0, t - 1]];
good8 = {200, 222};
bad[m_Integer, t_Integer] := Count[Flatten[Table[
     FromDigits[Take[aged[Join[{1}, r], Join[w, ConstantArray[0, 40]], t], 8], 2],
     {r, Tuples[{0, 1}, m - 1]}, {w, Tuples[{0, 1}, 8 - m]}]], b_ /; ! MemberQ[good8, b]];
Table[{m, 2^7, bad[m, 8], bad[m, 9]}, {m, 1, 7}]
```

Every start of two or more cells has a good band at age 8. A single black cell next to the wall fails at age 8 for 20 of its 128 wall prefixes, and none at age 9. A bad band only means the argument does not apply. For the actual failure, here is the single black cell at −1 beside a wall black at tick 2 only. At age 8 its row has a predecessor `z`, black on all of `(-∞, -11]` and at −9, −5 and −2, and white at the wall:

```wl
y = aged[{1}, Join[{0, 0, 1}, ConstantArray[0, 40]], 8];
yAt[p_Integer] := If[-9 <= p <= -1, y[[p + 10]], 0];
z[p_Integer] := Boole[p <= -11 || MemberQ[{-9, -5, -2}, p]];
{y, AllTrue[Range[-60, -1], BitXor[z[# - 1], BitOr[z[#], z[# + 1]]] == yAt[#] &], z[0]}
```

For the twenty-cell bands of two ticks the direct table has 9,961,472 cases: rows of 1 to 19 cells, with the wall values that reach the band. They give the same picture. Every start of two or more cells has a good band at age 24. A single cell fails for 61,440 of its 524,288 cases at age 24, and for none at age 25.

## 4. The proof

1. **The moving word** (`runWord_spec`). In coordinates that move with the edge, the row at time `t` is a word whose cells from the wall on are cut off. One tick applies rule 30, then writes the wall's value `c (t + 1)` at the wall's place, `m + t + 1` cells from the edge. This is proved equal to `L` cell by cell. The packed form, Hughes's band map `R` followed by the wall bit, is proved equal to it (`updateWord_fast`, `runFast_eq`). Once the band lies west of the wall, a tick is `R` alone (`band_next`, `runFast_wide`).
2. **One tick** (`good_band_of_age`). For `m ≥ 8` the band never meets the wall, so the kit's `top8_from_age_eight` gives a good band from age 8. For `m ≤ 7` the table `narrowTable` checks the 7 × 128 cases at the threshold age by kernel computation. After that `R` keeps the band good, since it swaps 200 and 222.
3. **Below a good band** (`predecessor_edge`). `Rule30TwoSidedInverse.predecessor_edge_of_good8` runs the inverse rule `z (p - 1) = y p ⊕ (z p ∨ z (p + 1))` outward from *any* two cells. So the predecessor's cells near the wall, its wall bit included, do not matter.
4. **Two ticks** (`good_twenty_band_of_age`). The direct twenty-cell table is replaced by two small ones from the one-tick threshold on. There the band is good and the edge is at least 10 cells from the wall. Six ticks from either good eight-cell band, with any five further cells, give one of the kit's four thirteen-cell bands (`inC13`, table `table13`, 256 cases at depths 10 to 13). Ten more ticks from those, with any seven further cells, give one of Hughes's six good twenty-cell bands (`table20`, 2,560 cases at depths 16 to 20). Deeper starts reduce to the last depth, where no wall bit enters (`clamp_depth`). `R` keeps the six good bands good.
5. **Below a good twenty-cell band** (`two_step_predecessor_edge`). `Rule30TwoSidedInverse.predecessor_of_good20` gives the first predecessor its exact edge and a good eight-cell band, and step 3 then applies to the second.
6. **The least ages.** The examples are checked by kernel computation in the middle, and by hand on their tails: a black tail maps to white, and so does a white one. Each least-age theorem combines its upper theorem with the example at the age below.

## 5. Prior art and credit

- **Hughes's inverse theorems** are the kit's `Rule30AgeEightInverse` and `Rule30AgeTwentyFourInverse`, with `Rule30LateTwins`. They are stated beside the white wall. Their good bands, band map and the thirteen-cell bands `inC13` are used here through their public statements.
- **The inverse reset** below a good band, and the band update, are those of `Rule30TwoSidedInverse`, our entry R30-20261122-7c7bad, which proves Hughes's theorems on the whole line.
- **The driven left half** is the kit's `Rule30DrivenLeft`, whose edge lemma fixes the edge of every driven row.
- **The ages beside every wall** were first found by an exhaustive search of predecessor trees over all wall sequences, for rows up to 14 cells, in the rule30reset record. It reported 8 and 24, with 9 and 25 for the lone cell. The finite band tables and the two-stage certificate are ours.
- **Search.** We searched the portal's list of 435 entries, the kit's catalogue and its open pull requests for an inverse or predecessor theorem beside a wall that is not white. We found none. The portal's results on the driven left half concern its columns' periods and agreement windows.

## 6. What is not proved

- Three or more ticks beside a wall are not settled, as on the line.
- The theorems are about predecessors on the negative sites. They do not say which wall sequences come from a right half of the line.
- Nothing here concerns the centre column. Problem 1 and `Q01` are not decided.

## The formal proof

The module is core Lean. It imports the kit's `Rule30ZeroBoundary`, `Rule30FiniteConfigs`, `Rule30DrivenLeft` and `Rule30Prize`, all present at the verifier's kit revision. Four modules that the revision lacks are carried, each in its own namespace inside `Rule30Submission`: Hughes's three, `Rule30LateTwins`, `Rule30AgeEightInverse` and `Rule30AgeTwentyFourInverse`, as they stand at kit commit `40017e8`, and `Rule30TwoSidedInverse`, as in the kit. Then comes `Rule30DrivenLeftInverse`, which holds the eight headlines.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The eight headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.Rule30DrivenLeftInverse.predecessor_edge", "Rule30Submission.Rule30DrivenLeftInverse.two_step_predecessor_edge", "Rule30Submission.Rule30DrivenLeftInverse.least_age_nonadjacent", "Rule30Submission.Rule30DrivenLeftInverse.least_age_adjacent", "Rule30Submission.Rule30DrivenLeftInverse.two_tick_least_age_nonadjacent", "Rule30Submission.Rule30DrivenLeftInverse.two_tick_least_age_adjacent", "Rule30Submission.Rule30DrivenLeftInverse.sharp_examples", "Rule30Submission.Rule30DrivenLeftInverse.sharp_two_step_examples"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The two thresholds and the one-tick conclusion, as Lean holds them:

```wl
{rule30Submission["Rule30Submission.Rule30DrivenLeftInverse.threshold"]["TermForm"], rule30Submission["Rule30Submission.Rule30DrivenLeftInverse.twoTickThreshold"]["TermForm"], rule30Submission["Rule30Submission.Rule30DrivenLeftInverse.EdgeAt"]["TermForm"]}
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.Rule30DrivenLeftInverse.two_tick_least_age_adjacent"]["KernelCheck"]
```
