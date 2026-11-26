---
Template: ComputationalEssay
Name: Run Transitions in Every Column of Rule 30: Sharp Two-Run Cutoffs, Chosen Letter by Letter beside Kurtuluş's Windows
Author: {AUTHORS}
Date: 2026-11-26
Description: Core Lean. The least black run before a single white that fixes the next right-hand reading, for each last run, sharp even from finite rows; with Kurtuluş's windows, chosen at each white letter, it excludes eventual words in every column of every configuration with a leftmost black cell, at every period length.
Abstract: {ABSTRACT}
Keywords: [rule 30, Rule 30 Prize, run transitions, black runs, eventual period, column words, every column, leftmost black cell, masked Jen theorem, strip certificate, sharp cutoffs, Lean 4, LeanLink, partial result]
Sources: ["[The Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[The rule30reset record](https://github.com/ghywel/rule30reset)"]
Links: ["[Rule 30 Prizes](https://rule30prize.org/)"]
---

## 1. The statement

Black is 1 and white is 0. `evol x t j` is the cell at site `j` and tick `t` of rule 30 run from the row `x`. A word `w` is the eventual word of column `j` when, from some tick `T` on, the column reads `w` over and over (`Rule30FiniteStrips.EventuallyWord x j w`). A row has a leftmost black cell `lo` when `x lo` is black and every cell west of it is white. Nonzero finite rows and the single seed are such rows.

**Windows.** Column `j` reads `v` from tick `s` (`Driven x j s v`) when `evol x (s + i) j` is letter `i` of `v` for each `i < length v`. The window `v` forces the colour `b` (`Force v b`) when, in every row, at every site and from every tick at which column `j` reads `v`, the next cell of column `j + 1` is `b`. The rows here are arbitrary: nothing is assumed about them.

**The theorems**, all in the namespace `Rule30Submission`:
- `exact_pair`: let `piece a r` be `a` blacks, one white, then `r` blacks, with `r ≥ 1`. It forces a colour exactly when `age r ≤ a`, where `age` is 8 at `r` = 1, 2, 3 and 5, 15 at 4, 16 at 6, 4 at 7, 14 at 8, and 0 from 9 on.
- `pair_forces`: the colour forced is black when `r` is 2, 4 or 6, and white otherwise.
- `both_colours_below`: when `a < age r`, for every site `j` and each colour `b`, some nonzero finite row with a leftmost black cell has column `j` reading `piece a r` with `b` next to it at the next tick. So every cutoff is sharp, even among finite rows.
- `old_forcing_window`: each of Kurtuluş's windows in `Rule30RunTransitions` forces its colour in every row, at every site. The windows at a white letter are `1⁹`, `1⁴01⁷`, `1⁸01²`; `1⁸01ʳ`, `1⁴01²01ʳ`, `1⁴01⁶01ʳ`, `1⁸01⁴01ʳ` for odd `r`; and `1⁸0101ʳ` for even `r`. The kit proves them on the seed's centre column.
- `not_eventually_combined`: let `w` be a nonempty word, and suppose each white letter of `w` is preceded, reading `w` cyclically, by one of Kurtuluş's windows (`Good`) or by `piece (age r) r` for some `r` from 1 to 8 (`PairGood`). Different white letters may use different kinds. Then no column of any row with a leftmost black cell is eventually `w`.
- `exclude_of_windows`: the general form. Any choice of forcing windows of bounded length, one at each white letter, excludes `w` in the same way.
- `mixedExample_requires_both`: for the 49-letter word with black runs 16, 4, 9, 1, 4, 9, each followed by one white, the white after the first 4 (letter 21) has a pair window and no window of Kurtuluş's. The white after the second 4 (letter 38) has one of Kurtuluş's windows and no pair window. The word satisfies `Combined` (`mixedExample_combined`).

## 2. Where it sits

| | Which columns | Windows | Sharp |
|---|---|---|---|
| Kurtuluş, the kit's `Rule30RunTransitions` | the seed's centre column | eight windows on five-cell strips, and the black-run parity step | not stated |
| this entry | every column of every row with a leftmost black cell | Kurtuluş's windows, and the pair windows `piece (age r) r`, chosen at each white letter | each pair cutoff is the least, even from finite rows |

The pair cutoffs 8 at `r` = 1, 2, 3, 5, 4 at `r = 7`, and 0 at `r ≥ 9` are Kurtuluş's windows `1⁸01ʳ`, `1⁴01⁷` and `1⁹`. The cutoffs 15, 16 and 14, at `r` = 4, 6 and 8, are new.

## 3. Exploration

**The cutoffs, from the whole light cone.** At a tick `n` after the window starts, column `j + 1` depends only on the window and on the cells `j + 1` to `j + n + 1` of the starting row. So the forced colours of a window are the colours over all `2ⁿ⁺¹` such cells. Here they are, one below each cutoff and at it:

```wl
forcedColours[w_List] := Module[{n = Length[w], v},
   v = Range[0, 2^(n + 1) - 1];
   Do[v = BitAnd[BitXor[BitOr[BitShiftLeft[v, 1], w[[t]]], BitOr[v, BitShiftRight[v, 1]]], 2^(n + 1) - 1], {t, n}];
   Union[BitAnd[v, 1]]];
pairWindow[a_Integer, r_Integer] := Join[ConstantArray[1, a], {0}, ConstantArray[1, r]];
cutoff = <|1 -> 8, 2 -> 8, 3 -> 8, 4 -> 15, 5 -> 8, 6 -> 16, 7 -> 4, 8 -> 14|>;
Dataset[KeyValueMap[<|"r" -> #1, "cutoff" -> #2,
     "colours one below" -> forcedColours[pairWindow[#2 - 1, #1]],
     "colours at the cutoff" -> forcedColours[pairWindow[#2, #1]]|> &, cutoff]]
```

Bit `i` of each number is the cell `j + 1 + i`, and the whole range of numbers is every starting row of the cone. One below each cutoff both colours occur; at it, one does. Lean proves the upper half on a seven-cell strip, and the lower half from these witnesses clipped to finite rows.

**The mixed example.** Kurtuluş's windows and the pair windows, coded from their statements, at each white letter of the 49-letter word and of the words with more 9s appended:

```wl
ones[n_Integer] := ConstantArray[1, n];
runsWord[rs_List] := Flatten[Join[ones[#], {0}] & /@ rs];
endsWith[w_List, j_Integer, v_List] := Table[w[[Mod[j - Length[v] + k, Length[w]] + 1]], {k, 0, Length[v] - 1}] === v;
kitWindows[len_Integer] := Join[{ones[9], Join[ones[4], {0}, ones[7]], Join[ones[8], {0}, ones[2]]},
   Flatten[Table[Join[p, ones[2 n + 1]], {p, {Join[ones[8], {0}], Join[ones[4], {0}, ones[2], {0}], Join[ones[4], {0}, ones[6], {0}], Join[ones[8], {0}, ones[4], {0}]}}, {n, 0, len - 1}], 1],
   Table[Join[ones[8], {0, 1, 0}, ones[2 n]], {n, 0, len - 1}]];
kitGood[w_List, j_Integer] := AnyTrue[kitWindows[Length[w]], endsWith[w, j, #] &];
pairGood[w_List, j_Integer] := AnyTrue[Range[8], endsWith[w, j, pairWindow[cutoff[#], #]] &];
family[n_Integer] := runsWord[Join[{16, 4, 9, 1, 4, 9}, ConstantArray[9, n]]];
Table[With[{u = family[n]}, With[{whites = Flatten[Position[u, 0]] - 1},
    <|"appended 9s" -> n, "length" -> Length[u], "every white covered" -> AllTrue[whites, kitGood[u, #] || pairGood[u, #] &],
     "no window of Kurtuluş's" -> Select[whites, ! kitGood[u, #] &], "no pair window" -> Select[whites, ! pairGood[u, #] &]|>]], {n, 0, 3}] // Dataset
```

Only letter 21 lacks one of Kurtuluş's windows, and among the short runs only letter 38 lacks a pair window. The other whites without a pair window follow runs of 9 or more, which `1⁹` covers.

**One black run and one white.** Among the words of one black run of length `b` and one white, the theorem covers `b = 7` and `b ≥ 9`:

```wl
Table[With[{u = Join[ones[b], {0}]}, b -> (kitGood[u, b] || pairGood[u, b])], {b, 1, 12}]
```

Runs of 9 or more are in Dyer's every-column classification of these words, R30-20261124-cacfbd. The run of 7 is among its 81 exceptions, as the pair (7, 1). Read cyclically, the word ends with Kurtuluş's window `1⁴01⁷` at its white letter, so `not_eventually_combined` excludes it in every column of every configuration with a leftmost black cell. On the seed's centre column his theorem already did. This is a consequence of the headline, not a separate Lean statement.

## 4. The proof

1. **The pair windows** (`pair_forces`). For `r ≤ 8` the window `piece (age r) r` is checked on a strip of seven cells, with the cell beyond free, from all 128 states. Here `applyWord` and its soundness `enc_applyWord` come from the kit's `Rule30StripCertificates` and `Rule30FiniteStrips`, at any site of any row. Nine blacks force white on a five-cell strip. A longer window forces whatever its end forces (`prefix_irrelevant`).
2. **The witnesses** (`exact_pair`, `both_colours_below`). For each `r ≤ 8`, two starting cones of width `age r + r + 1` give opposite colours after `piece (age r - 1) r`, checked by kernel computation. Starting later shortens `a`. To make a row finite with a leftmost black cell, keep the cells of the cone, put one black just west of it, and make the rest white. That black spreads east at speed one and never reaches the observed cells (`evol_local`). A translation moves the site.
3. **Kurtuluş's windows** (`old_forcing_window`). His five-cell checks and his parity step are restated for column `j` of an arbitrary row. While column `j` is black, `a(1) ∨ a(2)` makes `a(1)` white at the next tick, and a white `a(1)` makes `a(1) ∨ a(2)` hold. Every window has length at most `3·length w + 16`.
4. **The exclusion** (`exclude_of_windows`, `not_eventually_combined`). Suppose column `i` is eventually `w`, from tick `T`. Take a white tick `t` from `T + B` on, where `B` bounds the window lengths. The window chosen for its letter lies inside the periodic part, wrapping round `w` if it is longer, so it forces column `i + 1` at `t`. It forces the same colour at `t + length w`, which has the same letter. So column `i + 1` is periodic with the period of `w` on the white ticks of column `i`. The kit's finite-left masked Jen theorem (`Rule30FiniteMaskedJen.masked_jen`) says this cannot happen.
5. **The example** (`mixedExample_combined`, `mixedExample_requires_both`) is checked by kernel computation.

**The family.** Appending any number `n` of 9s, each followed by one white, keeps both failures: the windows at letters 21 and 38 lie in the first 39 letters, which do not change. Every run of 9 or more is covered by `1⁹`, and the word has one 16, so it is primitive. This argument is by hand; Lean checks the case `n = 0`, and the second cell checks `n` up to 3. Independent scripts in the record check `n` up to 40.

## 5. Prior art and credit

- **Katip Kurtuluş's `Rule30RunTransitions`** (the kit, with Claude, ChatGPT and Gemini) proves the window theorem for the seed's centre column, with eight windows on five-cell strips and the parity step. Its windows and their checks are used here, its parity step is proved again for column `j` of an arbitrary row, and its definitions `Good`, `EndsWith`, `ones` and `runsWord` are carried unchanged.
- **Lifting strip exclusions to every column** is the method of Troy Lowry's `Rule30FiniteStrips` (with OpenAI Codex), whose `EventuallyWord` this entry uses, and of Jacob Dyer's every-column ranked soundness, R30-20261123-e99565. Both work word by word or grammar by grammar. The exclusion uses the kit's `Rule30FiniteMaskedJen`, with G.P.J.W. Quint and Gemini's finite forms.
- **Dyer's every-column grammars.** R30-20261124-cacfbd, R30-20261123-2b846f, R30-20261123-18585c and R30-20261123-9c655c treat words with one black run and one white run. R30-20261123-cade33 excludes free mixtures of blocks of `r` blacks and `q` whites from seven categories, every one with `q ≥ 8`. The words here with two or more black runs, single whites between them, lie outside all five. For the words with one black run and one white, see section 3.
- **Dusty Galindo's mixed-gap theorem**, R30-20261124-29afb4, in the kit, lets white gaps of 7 and of at least 9 after single black ticks come in any cyclic order, on the seed's centre column. Its words have single blacks and long white runs; the words here have single whites and black runs.
- **Pull request #416** of the kit lists 324 primitive words of lengths 14 to 18 by strip certificates. The maintainers asked there for a general rule or an infinite family. This is one, at every length.
- **The pair table** was first computed in the rule30reset record, in a review of Kurtuluş's pull request. It is made sharp on finite rows, and joined to his windows, here.
- **Search.** We searched the portal's 436 entries, the kit's catalogue and its open pull requests for run-transition or two-run forcing results in every column. We found the entries above and no other.

## 6. What is not proved

- A word whose white letter has neither kind of window is not excluded. For example, a single white after `1²01⁴` has neither.
- The cutoffs are for one white between two black runs. Longer white runs are not treated.
- The family of all lengths `49 + 10n` is proved by hand, from the Lean theorem and the Lean check at `n = 0`.
- Nothing here concerns the centre column of the seed beyond the theorem itself. Problem 1 is not decided.

## The formal proof

The module is core Lean. It imports the kit's `Rule30FiniteStrips` and `Rule30FiniteConfigs`, both present at the verifier's kit revision. Kurtuluş's `Rule30RunTransitions`, which that revision lacks, is carried in part: its window definitions and their eight five-cell checks, in their own namespace, as in the kit at `71151d0`. Then comes the module of this entry, in `Rule30Submission`, which holds the seven headlines.

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

## The formal checks

The seven headline theorems, as Lean prints them:

```wl
heads = {"Rule30Submission.not_eventually_combined", "Rule30Submission.exact_pair", "Rule30Submission.pair_forces", "Rule30Submission.both_colours_below", "Rule30Submission.old_forcing_window", "Rule30Submission.exclude_of_windows", "Rule30Submission.mixedExample_requires_both"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

Their axioms:

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

The kernel accepts every declaration of the module again. This is the replay the verifier runs. It comes last because it resets LeanLink's elaboration state:

```wl
rule30Submission["Rule30Submission.mixedExample_requires_both"]["KernelCheck"]
```
