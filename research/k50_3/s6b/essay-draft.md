---
Template: ComputationalEssay
Name: Inverse Ticks without the White Wall: Hughes's Ages on the Line, Both Sharp, and Every k from Reset Capacity
Author: {AUTHORS}
Date: 2026-11-26
Description: Core Lean. The kit's inverse-tick theorems hold on the whole line, for every configuration with a leftmost black cell: Hughes's ages 8 and 24, both sharp, and every number of ticks from reset capacity. No wall is needed. Reset capacity and the relaxed doubling lemma remain open.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, inverse ticks, predecessors, every k, leftmost black cell, left-finite configurations, white wall, reset capacity, Hughes's ages, sharp ages, conditional theorem, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

This entry replaces R30-20261122-7c7bad. Its first version proved both of Hughes's ages on the line and showed that the first, 8, cannot be lowered. This version shows that the second, 24, cannot be lowered either, so that both are the least ages. Everything else is unchanged.

**Configurations.** A configuration is `x : Int → Bool`, evolved by rule 30 on the whole line, `Rule30Realization.evol x t`. It has a leftmost black cell at `lo` when `x lo = true` and `x p = false` for every `p < lo`. Every nonzero finite configuration has one, and so does the single black cell. The leftmost black cell moves one place left at each tick (`Rule30FiniteConfigs.evol_left_edge`), so at time `t` it is at `lo - t`.

**Predecessors.** A predecessor of a configuration `y` is any `z : Int → Bool` with `rule (z (p - 1)) (z p) (z (p + 1)) = y p` for every `p`. A `k`-tick predecessor of `y` is any `V` with `evol V k = y`. Nothing else is assumed of them: a predecessor may be infinite in either direction, and may have no leftmost black cell at all.

**The theorems.** Let `x` have a leftmost black cell at `lo`.
- `Rule30Submission.predecessor_edge_from_age_eight`: if `t ≥ 8`, every predecessor `z` of `evol x t` has `z (lo - t + 1) = true` and is white below it.
- `Rule30Submission.predecessor_edge_fails_at_age_seven`: the configuration with black cells at 0 and 3 has, at age 7, a predecessor of its image that has black cells arbitrarily far to the left. So the age 8 cannot be lowered.
- `Rule30Submission.two_step_predecessor_edge_from_age_twenty_four`: if `t ≥ 24`, every two-step predecessor has its leftmost black cell at `lo - t + 2`.
- `Rule30Submission.two_step_predecessor_edge_fails_at_age_twenty_three`: the configuration with black cells at 0, 3, 4, 6, 7, 10, 11, 12 and 14 has, at age 23, a predecessor of its image, and a predecessor of that one which has black cells arbitrarily far to the left. So the age 24 cannot be lowered.
- `Rule30Submission.one_tick_least_age` and `Rule30Submission.two_tick_least_age`: the one-tick conclusion holds at every age from `a` on exactly when `8 ≤ a`, and the two-tick conclusion exactly when `24 ≤ a`.
- `Rule30Submission.kTick_edge_line`: if `0 < w` and `k ≤ K1 w`, then for every `t` from `2 ^ w` on, every `k`-tick predecessor of `evol x t` has its leftmost black cell at `lo - t + k`.
- `Rule30Submission.every_k_line_of_cap`: from `CAP`, for every `k` there is an age from which this holds.
- `Rule30Submission.every_k_line_of_dlMinusOne`: the same from the relaxed doubling lemma `DLMinusOne`.

In each positive case the leftmost black cell of the predecessor is the one of `evol x (t - k)`, the predecessor that the configuration's own history provides.

## 2. Where it sits

| | Beside the white wall (the kit) | On the line (this entry) |
|---|---|---|
| one tick | from age 8, for finite rows (`Rule30AgeEightInverse`); age 7 fails, by a control outside Lean | from age 8; age 7 fails, in Lean |
| two ticks | from age 24 (`Rule30AgeTwentyFourInverse`); age 23 fails, by a control outside Lean | from age 24; age 23 fails, in Lean |
| every k | from `CAP`, age `w - 1 + 2 ^ w` (`Rule30EveryKInverse`) | from `CAP`, age `2 ^ w` |
| from `LInfinity`, from `DLMinusOne` | our entries R30-20261120-eb2bcc and R30-20261120-8dc0b3 | this entry |

So the chain from the relaxed doubling lemma, through closed runs and reset capacity, to every number of inverse ticks does not need the white wall. It holds for every configuration with a leftmost black cell, and on the line Hughes's two ages are exact.

## 3. Exploration

**The band at the edge.** The 8 cells next to the leftmost black cell, read as a binary number with the edge cell first, from twelve random starts at ages 7, 8, 9 and 30:

```wl
SeedRandom[30];
edgeBand[x_List, t_Integer, w_Integer] := FromDigits[CellularAutomaton[30, {x, 0}, t][[-1, 1 ;; w]], 2];
starts = Table[Join[{1}, RandomInteger[1, 39]], {12}];
tab = Table[edgeBand[x, t, 8], {x, starts}, {t, {7, 8, 9, 30}}];
{tab, Union[Flatten[tab[[All, 2 ;;]]]]}
```

From age 8 every band is 200 or 222, and the two alternate. At age 7 one start still shows 223. These are Hughes's two good bands, here on the line: the band moves out by one cell at each tick and updates by itself, whatever lies further in.

**Age 7 is not enough.** The configuration with black cells at 0 and 3, and a predecessor of its image at age 7 that is black on the left, black on the right, and has a word of 19 cells between:

```wl
x = {1, 0, 0, 1};
y7 = CellularAutomaton[30, {x, 0}, 7][[-1]];
yAt[p_Integer] := If[-7 <= p <= 10, y7[[p + 8]], 0];
mid = IntegerDigits[FromDigits["0100010010000011001", 2], 2, 19];
z[p_Integer] := Which[p <= -9, 1, p >= 11, 1, True, mid[[p + 9]]];
step[p_Integer] := BitXor[z[p - 1], BitOr[z[p], z[p + 1]]];
{AllTrue[Range[-60, 60], step[#] == yAt[#] &], Table[z[p], {p, -14, 14}]}
```

One tick of `z` gives the image at age 7 at every position checked, and beyond them both tails are black and map to white. So the image has a predecessor with no leftmost black cell. In Lean, `predecessor_edge_fails_at_age_seven` checks the 21 middle cells by kernel computation and the two tails by the left- and right-edge lemmas.

**Age 23 is not enough.** The configuration with black cells at 0, 3, 4, 6, 7, 10, 11, 12 and 14. At age 23 its image, on the cells from −23 to 37, has a predecessor `w` that is white through −23, black from 37 on, with a word of 59 cells between. And `w` has a predecessor `v` that is black through −24, then a word of 59 cells, then `001` repeated from 36 on:

```wl
seed = IntegerDigits[FromDigits["100110110011101", 2], 2, 15];
img = CellularAutomaton[30, {seed, 0}, 23][[-1]];
imgAt[p_Integer] := If[-23 <= p <= 37, img[[p + 24]], 0];
wMid = IntegerDigits[FromDigits["10100101000010000001001111111010000010011100110011010010000", 2], 2, 59];
vMid = IntegerDigits[FromDigits["01011010111101111110110100100101111101110011010000101110000", 2], 2, 59];
w[p_Integer] := Which[p <= -23, 0, p >= 37, 1, True, wMid[[p + 23]]];
v[p_Integer] := Which[p <= -24, 1, p >= 36, Boole[Mod[p - 36, 3] == 2], True, vMid[[p + 24]]];
stepOf[f_][p_Integer] := BitXor[f[p - 1], BitOr[f[p], f[p + 1]]];
{AllTrue[Range[-90, 90], stepOf[w][#] == imgAt[#] &], AllTrue[Range[-90, 90], stepOf[v][#] == w[#] &], Table[v[p], {p, -30, -20}]}
```

Both ticks hold at every position checked, and beyond them the tails map as they should: white to white, black to white, and the period-three tail `001` to black at each of its phases. So `v` has no leftmost black cell. `w` has the true edge, at −22, as the one-tick theorem requires at age 23. A search over all finite seeds of width at most 21 finds none of width 14 or less with such a two-step predecessor at age 23, this one alone at width 15, and none at all at age 24.

## 4. The proof

1. **The band updates by itself** (`band_step`). For a configuration white left of `f`, the `w` cells from `f`, one tick later, are the `w` cells from `f - 1`, and they are the kit's band map `Rule30LateTwins.R` of the `w` cells before. So the band at the edge at age `t` is `R` applied `t` times to the band at age 0.
2. **Good bands at ages 8 and 24** (`good8_of_age`, `good20_of_age`). Beside the wall the kit proves that the top 8 and top 20 cells of an aged row are among its good bands (`top8_from_age_eight`, `top20_from_age_twenty_four`). Applied to a single window, whose band is the line's band at age 0, they give the same for the line. Beside the wall, rows narrower than the band need their own finite check. On the line the band is always full, so that case does not arise.
3. **Below a good band, a predecessor resets** (`prun_reset8`, `prun_reset20`, `edge_of_reset`). A predecessor is fixed to the left by its image: `z (p - 1) = y p ⊕ (z p ∨ z (p + 1))`. Run outward over a good band from any two cells, this inverse rule ends in two white cells. The tables, 2 × 4 cases for the 8-band and 6 × 4 for the 20-band, are checked by `decide`. Outward from two white cells over a white image, the predecessor is white, and the image's edge cell makes the next cell black.
4. **Two ticks** (`predecessor_of_good20`). Over a good 20-band the same run also shows that the predecessor's own 8 cells from its edge form a good band, so step 3 applies again.
5. **The witness at age 23** (`two_step_predecessor_edge_fails_at_age_twenty_three`). The row at age 23 is computed once by the kernel, through rows written as lists (`evol_listRow`, `R23_eq`). The 61 middle cells of each predecessor are checked by kernel computation. The four tails are proved by hand: white images left of −23 and right of 37 (`evol_eq_false_of_lt`, `evol_eq_false_of_gt`), the black left tail of `V23`, and its period-three right tail, whose image is black at every phase.
6. **The least ages** (`one_tick_least_age`, `two_tick_least_age`). From `8 ≤ a` or `24 ≤ a`, steps 3 and 4 give the conclusion at every later age. Below, the threshold covers age 7 or age 23, where the witness refutes it.
7. **Every k** (`kTick_edge_line`). In the kit's every-k bit order the line's band evolves by the kit's `stepK` (`bandK_step`). Pigeonhole on its `2 ^ w` values puts it on a cycle by age `2 ^ w` (`on_cycle`), and the kit's `capacity_on_cycle` gives a period whose reset schedule reaches `K1 w`. The kit's cascade (`scheduled_layer`, `earlier_step`) then fixes the edge of every `k`-tick predecessor. The kit's `scheduled_edge` reads its layers as rows of the zero-boundary left half. Here `scheduled_edge_rows` takes any chain of rows each driven by the next. The layers of a predecessor on the line, read in depth from a point right of the band, are such a chain at every depth (`drives_line`).
8. **The chain** (`every_k_line_of_cap`, `every_k_line_of_dlMinusOne`). `CAP` supplies the width. The kit's `cap_of_unbounded_resets` and `lInfinity_of_dlMinusOne` give `CAP` from `LInfinity` and from `DLMinusOne`.

## 5. Prior art and credit

- **Hughes's inverse theorems** are the kit's `Rule30AgeEightInverse` and `Rule30AgeTwentyFourInverse`, with `Rule30LateTwins`. They are stated for finite rows beside the white wall. Their good bands and tables are reused here unchanged, through their public theorems. The kit's inverse steps, such as `back_zero_from_top8`, are private and work on rows beside the wall, so the inverse run below a good band is restated here for the line. The kit's catalogue records Hughes's sharpness controls beside the wall, a cofinite predecessor at age 7 and a two-step ancestor at age 23. They are not among the kit's Lean theorems. `predecessor_edge_fails_at_age_seven` and `two_step_predecessor_edge_fails_at_age_twenty_three` are the two controls on the line, proved in Lean. Quint and Gemini's entry R30-20261111-f8023c sharpens these results, also beside the wall.
- **The reset schedule and its cascade** are Lowry's (kit PR #60), in `Rule30EveryKCascade`. `K1`, `CAP` and the inverse-tick target are in `Rule30EveryKStatement`, and the conditional every-k theorem beside the wall is in `Rule30EveryKInverse` (our entry R30-20261119-ccc65f). `LInfinity ⇒ CAP` and `DLMinusOne ⇒ LInfinity` are our entries R30-20261120-eb2bcc and R30-20261120-8dc0b3.
- **Configurations with a leftmost black cell** are the setting of the kit's `Rule30FiniteConfigs` (Jen; Kopra; Condrey), whose edge lemmas are used here.
- **Since the first version.** In the kit, Quint and Gemini's entry R30-20261123-98c017 extends `Rule30EveryKLine`: every k on the line from the single-interval doubling lemma and the pairwise agreement of `k`-tick predecessors up to the edge (`every_k_line_of_dl_and_edge_agreement`). This entry carries the module as first submitted.
- **Search.** We searched the portal's list of 435 entries, the kit's catalogue and its open pull requests for a predecessor or inverse theorem stated for configurations of the line, or without the wall, and for a sharpness result at age 23 on the line. We found none, apart from this entry's first version.

## 6. What is not proved

- `CAP`, `LInfinity` and `DLMinusOne` are not proved, so the every-k statements are conditional, as before.
- For small k there is a way round them that is not part of this entry. Quint and Gemini's entry R30-20261120-2a993b proves `K1 300 = 25`. Applied to `kTick_edge_line`, it gives the line statement for every k ≤ 25 from age `2 ^ 300`, with no hypothesis. Our reader checked this combination in Lean (in the rule30reset record). The kit took that entry's collapse of `K1` to sixteen phases and left the values at width 300 out, as per-width certificates.
- Three ticks are not settled. The least age for three-tick predecessors on the line is open. A finite search over seeds of width at most 17 finds failures at ages 24, 25 and 26, and none from 27 to 50.
- Nothing here concerns the centre column. Problem 1 and `Q01` are not decided.

## The formal proof

The module is core Lean. It imports the kit's `Rule30ZeroBoundary`, `Rule30UniversalLeftSide`, `Rule30AgedLeftDiagonals`, `Rule30LeftUnbounded`, `Rule30FiniteConfigs` and `Rule30Prize`, all present at the verifier's kit revision. Eleven kit modules that the revision lacks are carried, as they stand at kit commit `40017e8`, each in its own namespace inside `Rule30Submission`:
- Hughes's three: `Rule30LateTwins`, `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`;
- the three every-k modules: `Rule30EveryKStatement`, `Rule30EveryKCascade`, `Rule30EveryKInverse`;
- the five behind reset capacity: `Rule30RootedWhiteReturns`, `Rule30ThreePhaseReturn`, `Rule30RecurrentStrip`, `Rule30ResetCompactness`, `Rule30RelaxedWindows`.

Two modules of ours follow: `Rule30TwoSidedInverse` (Hughes's ages on the line, the witnesses at ages 7 and 23, and the least ages) and `Rule30EveryKLine` (every k on the line). The nine headlines are in `Rule30Submission`.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The nine headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.predecessor_edge_from_age_eight", "Rule30Submission.predecessor_edge_fails_at_age_seven", "Rule30Submission.two_step_predecessor_edge_from_age_twenty_four", "Rule30Submission.two_step_predecessor_edge_fails_at_age_twenty_three", "Rule30Submission.one_tick_least_age", "Rule30Submission.two_tick_least_age", "Rule30Submission.kTick_edge_line", "Rule30Submission.every_k_line_of_cap", "Rule30Submission.every_k_line_of_dlMinusOne"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

Hughes's good 8-bands, as Lean holds them; the step that makes the band at the edge update by itself; the band is good from age 8; and below a good band the inverse rule ends in two white cells, from any two cells:

```wl
{rule30Submission["Rule30Submission.Rule30AgeEightInverse.EdgeGood8"]["TermForm"], rule30Submission["Rule30Submission.Rule30TwoSidedInverse.band_step"]["TypeForm"], rule30Submission["Rule30Submission.Rule30TwoSidedInverse.good8_of_age"]["TypeForm"], rule30Submission["Rule30Submission.Rule30TwoSidedInverse.prun_reset8"]["TypeForm"]}
```

The seed of the age-23 witness, and the two-tick conclusion whose least age is 24, as Lean holds them:

```wl
{rule30Submission["Rule30Submission.Rule30TwoSidedInverse.seed23"]["TermForm"], rule30Submission["Rule30Submission.Rule30TwoSidedInverse.TwoTickEdge"]["TermForm"]}
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.every_k_line_of_dlMinusOne"]["KernelCheck"]
```
