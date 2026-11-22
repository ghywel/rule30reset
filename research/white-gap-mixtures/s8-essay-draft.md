---
Template: ComputationalEssay
Name: Every periodic sparse column of Rule 30 contains the gaps 12, 10, 9
Author: {AUTHORS}
Date: 2026-11-22
Description: At any column of a Rule 30 row with a leftmost black cell, an eventually periodic pattern of isolated black pulses with gaps of at least nine must contain the consecutive gaps 12, 10, 9.
Abstract: {ABSTRACT}
Keywords: [Rule 30, sparse column, white gaps, leftmost black cell, eventual period, masked Jen, Lean]
Sources: ["[Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[AIOvernight's ResetMixtures](https://github.com/WolframInstitute/Rule30PrizeKit/blob/dd2a220/lean/Ruliology/CellularAutomata/Rule30ResetMixtures.lean)", "[Lowry's FiniteStrips](https://github.com/WolframInstitute/Rule30PrizeKit/blob/dd2a220/lean/Ruliology/CellularAutomata/Rule30FiniteStrips.lean)"]
---

## Which gaps can a periodic sparse column repeat?

Watch one site of a Rule 30 row that has a leftmost black cell, as the single seed does. Suppose that from some time on the site shows isolated black pulses, each followed by a run of at least nine white ticks, its gap, and that the gaps repeat with some period. Every gap is then at most 16, by AIOvernight's reset argument applied at that site, so only the eight lengths 9 to 16 remain.

The main theorem says more. Reading the gaps in order, the three gaps 12, 10, 9 must occur consecutively after any time. Read cyclically, every period of the gap sequence contains them, including across its wrap. This holds at every site, at every onset and in every phase of the period.

The table counts the gap words of each period length and how many of them contain the factor cyclically. The theorem excludes every other one.

```wl
hasTriple[w_List] := With[{n = Length[w]}, AnyTrue[Range[n], w[[#]] == 12 && w[[Mod[#, n] + 1]] == 10 && w[[Mod[# + 1, n] + 1]] == 9 &]];
TableForm[Table[With[{k = Count[Tuples[Range[9, 16], n], _?hasTriple]}, {n, 8^n, k, 8^n - k, N[(8^n - k)/8^n, 4]}], {n, 3, 6}], TableHeadings -> {None, {"gaps per period", "gap words", "contain 12, 10, 9", "excluded", "fraction excluded"}}]
```

The fraction excluded falls slowly as the period lengthens, since a long word is more likely to contain the factor somewhere. The theorem excludes nothing that contains it.

## Why the factor is forced

Record the 19 cells to the right of the site at each pulse. One gap of q white ticks carries this window to its value at the next pulse.

- **Following every history.** The proof follows sets of windows through each gap, tick by tick. At every tick it admits either value of the cell just beyond the window. So every ordinary history, whatever lies further right, stays inside the sets.
- **Forbidding the factor.** A three-state monitor records how much of 12, 10, 9 has just been read, and forbids the gap that would complete it.
  - From all 524,288 windows, seven gaps leave 35,507.
  - Four bands, closed under every allowed gap, split them. Three are of one observed colour throughout.
  - The fourth is covered by six classes whose labelled moves are closed.
- **A forced period.** Within each class, take two runs that read the same gaps from the same window and meet again later. They show the same observed colour all the way: the right neighbour's reading on the second white tick after each pulse. So the gaps and the windows at both ends determine the observations, and a periodic gap sequence forces that reading to repeat with the period.
- **The contradiction.** The kit's finite-left masked Jen theorem forbids exactly such a periodic reading on a row with a leftmost black cell. So no period that avoids 12, 10, 9 can occur.
- **The computation.** Lean computes every intermediate set with the kit's bit-parallel strip image (`fimage`), and checks each inclusion with a kernel decision. The 46 starting and destination sets are stored as packed numbers.

## Ten three-gap words that reset every right half

AIOvernight's set G of sixteen eight-cell windows absorbs every later gap of at least nine. Among the 512 words of three gaps from 9 to 16, exactly ten force every right half, at every site and age, into G:

- (q, 16, 16) for each q from 9 to 16;
- (16, 10, 15) and (16, 10, 16).

**The proof.**
- **The ten.** Each starts from every strip window at width 14 or 18, with either exterior bit at every tick.
- **The other 502.** Each has a concrete right row that escapes. The kit's realization theorem makes that row part of an ordinary full-line history.
- **After G.** The right neighbour's reading at the white ticks is fixed for any later gaps: white, white, then black (`forever`).

With masked Jen this rules out a periodic column containing one of the ten words. That last step is not stated as a separate theorem here.

## Credit and scope

**Credit.**
- AIOvernight: the absorbing set G and its closure (`Rule30ResetMixtures`), and the bit-parallel strip image (`Rule30FastImage`).
- Lowry: the finite strip encoding (`Rule30FiniteStrips`).
- The kit: the finite-left masked Jen theorem and the realization theorem.

**Earlier results.**
- `Rule30ResetMixtures` and `Rule30GrammarRuns` exclude families of sparse words on the single seed's centre column.
- `Rule30WhiteEnd` and `Rule30WhiteEndNine` exclude a constant gap.

**What is new here** is a consecutive factor that every periodic gap word of every length must contain, at every site of every row with a leftmost black cell.

**What is not proved.**
- Whether any periodic sparse column occurs at all.
- Lower bounds on the length of such a period, which come from separate calculations.
- Nothing here settles Problem 1.

## Formal statements and kernel replay

```wl
Needs["Wolfram`LeanLink`"];
$Rule30PrizeKit = Environment["RULE30PRIZE_KIT"];
DirectoryQ[$Rule30PrizeKit]
```

{LEAN_IMPORT_CELL}

```wl
heads = {"Rule30Submission.mandatory_factor", "Rule30Submission.mandatory_cyclic_factor", "Rule30Submission.mandatory_rotated_factor", "Rule30Submission.sparse_cyclic_factor", "Rule30Submission.sparse_rotated_factor", "Rule30Submission.no_residue_44_47", "Rule30Submission.classification", "Rule30Submission.known_forces", "Rule30Submission.forever"};
AssociationMap[rule30Submission[#]["TypeForm"] &, heads]
```

```wl
AssociationMap[rule30Submission[#]["Axioms"] &, heads]
```

```wl
rule30Submission["Rule30Submission.mandatory_factor"]["KernelCheck"]
```
