---
Template: ComputationalEssay
Name: Inverse ticks beside every wall: one depth-two age decides both starts for every k, and ages for every k force unique recurrent parents
Author: {AUTHORS}
Date: 2026-11-26
Description: Core Lean. Beside an arbitrary prescribed wall of Rule 30's left half, for every number k of inverse ticks, depth-two exactness at age T ≥ 2 decides the two uniform cutoffs T and T + 1. If every k has such an age, every recurrent row with a leftmost black cell has at most one full-line predecessor.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, inverse ticks, predecessors, driven left half, prescribed wall, left permutivity, exact edge, reset capacity, recurrent rows, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)", "[Hughes's inverse ticks beside every wall: ages 8 and 24, or 9 and 25 next to the wall, all sharp](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-2e7cd2)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

The kit's driven half `Rule30DrivenLeft.L wall s` runs Rule 30 on the negative sites, with an arbitrary prescribed column `wall` at site 0 and a start `s`. A start at depth `m` has its leftmost black cell at `−m`. Go back `k` inverse ticks from the row at age `t`. Each predecessor satisfies the Rule 30 equation at every negative site and chooses its own bit at site 0. `ExactAt k m t` says that, under every wall, every such `k`-th predecessor has its leftmost black cell at `−m − t + k`, the edge of the row `k` ticks earlier.

**The theorems**, in `Rule30Submission`:
- `two_classes`: for every `k` and every `T ≥ 2`, two uniform statements are each equivalent to `ExactAt k 2 T`, depth two at the single age `T`:
  - every start at depth at least two is exact at every age from `T`;
  - the adjacent start, at depth one, is exact at every age from `T + 1`.

  Exactness is monotone in age within each class. The one-tick offset applies to the cutoffs in the stated range. At zero inverse ticks both unrestricted least ages are zero. Its three steps are `L_column`, `exactAt_of_two` and `exactAt_two_of_one`.
- `unique_parent_of_every_k`: suppose every `k` has a depth-two age. Then every recurrent row with a leftmost black cell has at most one full-line Rule 30 predecessor. Here recurrent means that every finite band at its edge lies on a cycle of the band map. The steps are `parent_band_history`, `parent_band_on_cycle`, `realize_recurrent`, `parent_edge_of_one` and `recurrent_parent_of_every_k`.

**By hand, outside Lean.** A full-line predecessor whose edge is at site 1, read from its edge, is an odd preimage of the row read from its edge. For a recurrent row, a unique odd preimage is the same as arbitrarily deep complete resets; that equivalence is argued by hand and read in the rule30reset record. Arbitrarily deep resets at every recurrent row are the kit's `Rule30ResetCompactness.LInfinity`, which gives the reset capacity `CAP` (`cap_of_unbounded_resets`). So a depth-two age for every `k` would give `CAP`. The converse is not shown.

## 2. Where it sits

| | Wall | Inverse ticks | What is proved |
|---|---|---|---|
| `Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse` (Scott Hughes, in the kit) | white | 1 and 2 | exact edges from ages 8 and 24 |
| `Rule30DrivenLeftInverse` (R30-20261126-2e7cd2, ours, in the kit) | any | 1 and 2 | ages 8 and 24, and 9 and 25 beside the wall, each case by itself |
| `Rule30EveryKInverse`, `Rule30EveryKLine` (ours, in the kit) | white, or none | every k | an age for every k, from `CAP` |
| this entry | any | every k | the two classes reduce to one statement; ages for every k force unique recurrent parents |

Quint and Gemini prove the white-wall target unconditionally through `k = 25` (R30-20261120-2a993b). Nothing in the kit or on the portal relates the two start classes for any `k` beyond two, or derives uniqueness of parents from uniform ages.

## 3. Exploration

**The least ages, computed.** A start at depth two under every wall reaches few rows: a row is a number whose bit `j` is site `−(j + 1)`, and one tick with wall bit `c` sends `r` to `(r >> 1) XOR (r OR (r << 1) OR c)`. A row passes if, for all `4^k` choices of the predecessors' bits at sites `−1` and `0`, the `k`-th predecessor has the exact edge and white beyond it. The least passing age, for one to three inverse ticks, at depth two and at depth one:

```wl
step[r_, w_] := BitXor[BitShiftRight[r, 1], BitOr[r, BitShiftLeft[r, 1], w]];
passQ[k_, row_, width_] := Module[{img = Reverse[IntegerDigits[row, 2, width]], cur, nxt, new, deep, off},
   If[width < k, Return[False]];
   Catch[Do[
     cur = Table[BitGet[reg, 2 i], {i, 0, k - 1}]; nxt = Table[BitGet[reg, 2 i + 1], {i, 0, k - 1}];
     deep = <|width -> nxt[[k]], (width - 1) -> cur[[k]]|>;
     Do[new = BitXor[Prepend[Most[cur], img[[col + 1]]], BitOr[cur, nxt]]; nxt = cur; cur = new;
      off = width - (col + 2); If[off <= k, deep[off] = cur[[k]]], {col, 0, width - 1}];
     If[! (deep[k] == 1 && AllTrue[Range[0, k - 1], deep[#] == 0 &] && Total[cur] == 0 && Total[nxt] == 0),
      Throw[False]], {reg, 0, 4^k - 1}]; True]];
leastAge[k_, m_] := Module[{rows = Table[BitOr[2^(m - 1), j], {j, 0, 2^(m - 1) - 1}], age = 0},
   While[! AllTrue[rows, passQ[k, #, m + age] &], rows = Union[Flatten[Outer[step, rows, {0, 1}]]]; age++]; age];
Grid[Prepend[Table[{k, leastAge[k, 2], leastAge[k, 1]}, {k, 1, 3}], {"inverse ticks k", "depth two", "adjacent start"}], Frame -> All]
```

The adjacent start is exactly one tick later each time, as `two_classes` says it must be. The first two rows are Hughes's ages, which the kit proves beside any wall case by case.

**Further ages.** The same search at depth two, run by two independent programs in the rule30reset record, gives these least ages. Neither theorem here computes them; they are what the first theorem reduces to.

```wl
Dataset[MapThread[<|"inverse ticks k" -> #1, "least depth-two age" -> #2, "adjacent start" -> #2 + 1|> &, {Range[8], {8, 24, 31, 72, 81, 108, 131, 132}}]]
```

At four ticks, 14 of the 9,662 rows at age 71 fail, and all 10,582 rows at age 72 pass. The failing rows share one 63-cell word at the edge, and at age 72 neither of its two needed extensions is reachable.

## 4. The proof

1. **A column as a wall** (`L_column`). West of any column `j ≤ 0`, the driven half from time `a` on is the half driven by that column, started from the row at time `a`. Since the wall is arbitrary, any column of a driven half is itself a wall.
2. **Depth two decides** (`exactAt_of_two`). A start at depth `m ≥ 1`, aged `t ≥ T` with `m + t ≥ T + 2`, is restarted at time `t − T`. The column two sites east of its leftmost black cell is the new wall, and the row at that time is a depth-two start.
3. **The adjacent start** (`exactAt_two_of_one`). After one tick the depth-one start is the depth-two start with `−1` black. At age two the depth-two start with `−1` white gives the same rows as the one with `−1` black, under a changed second wall bit. So depth two at age `T ≥ 2` is depth one at age `T + 1`.
4. **Finite histories** (`parent_band_history`, `parent_band_on_cycle`). Any predecessor on the negative half has a further predecessor there, solved westward from white bits at `−1` and `0` by left permutivity. If depth two is exact for `n + 1` ticks, the deepest layer is white west of its edge. Its band of width `w` then runs forward `n` steps under the autonomous band map to the first predecessor's band, as long as `w + n ≤ t`. For `n ≥ 2^w` that band lies on a cycle (`on_cycle`, by pigeonhole).
5. **Realization** (`realize_recurrent`). Go `t` steps back along the cycle of a recurrent row's band of width `t + 2`, and start a full-line row with those bits. The column two sites in is a wall, and the driven half at age `t` is the target row, from a depth-two start. The age is chosen after the width, so the room `w + n ≤ t` of step 4 is always there.
6. **Uniqueness** (`parent_edge_of_one`, `recurrent_parent_of_every_k`, `unique_parent_of_every_k`). The one-tick age puts every full-line predecessor's edge at site 1. Step 4 at `k = 2^w + 1` makes every band of every predecessor periodic. Two periodic bands with the same image are equal, and both predecessors are white west of the edge, so they are equal.

## 5. What is not shown

- **That an age exists for every k**, or `CAP`.
- **The converse**, from `CAP` to ages beside every wall. The kit's every-k theorem for the line does not transfer directly, because each inverse layer's bit at site 0 is free.
- **Any least age beyond three ticks in Lean.** The ages in §3 for four to eight ticks are computed. The lower bounds 72 and 73 at four ticks are proved in Lean in the rule30reset record, not here.

## 6. Prior art and credit

- **Scott Hughes**, with OpenAI Codex: the white-wall ages 8 and 24 and their twins (`Rule30AgeEightInverse`, `Rule30AgeTwentyFourInverse`, in the kit).
- **Our entries:** R30-20261126-2e7cd2, the same ages beside any wall (`Rule30DrivenLeftInverse`); R30-20261119-ccc65f and R30-20261126-523aad, every `k` from `CAP` beside the white wall and on the line (`Rule30EveryKInverse`, `Rule30EveryKLine`, whose band lemmas are carried here); R30-20261120-eb2bcc, deep resets give `CAP` (`Rule30ResetCompactness`).
- **Troy Lowry**: the reset schedule and cascade behind every `k` (`Rule30EveryKCascade`, kit pull request #60). `K1`, `CAP` and the every-k statement are the kit's (`Rule30EveryKStatement`).
- **G.P.J.W. Quint and Gemini**: the white-wall target through `k = 25` (R30-20261120-2a993b).
- **Authorship.** The two-class theorem is Claude's and the uniqueness theorem GPT's, each read by the other model.
- **Search.** We searched the kit's catalogue at `389bede` and the portal's 452 entries for unique parents and predecessors, columns as walls, depth two and inverse ages. We found the entries above and none with either statement.

## The formal proof

The source imports the kit's `Rule30DrivenLeft`, `Rule30UniversalLeftSide`, `Rule30FiniteConfigs` and `Rule30FiniteDiagonals`, all present at the verifier's kit revision. That revision predates the kit's `Rule30EveryKLine`, so the band lemmas used from it are carried first, unchanged, in their own namespace `Rule30Submission.KitEveryKLine`.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The ten headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.L_column", "Rule30Submission.exactAt_of_two", "Rule30Submission.exactAt_two_of_one", "Rule30Submission.two_classes", "Rule30Submission.parent_band_history", "Rule30Submission.parent_band_on_cycle", "Rule30Submission.realize_recurrent", "Rule30Submission.parent_edge_of_one", "Rule30Submission.recurrent_parent_of_every_k", "Rule30Submission.unique_parent_of_every_k"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.unique_parent_of_every_k"]["KernelCheck"]
```
