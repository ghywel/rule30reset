---
Template: ComputationalEssay
Name: Sparse periodic Rule 30 columns require gaps 12, 10, 9 when the initial row has a leftmost black cell
Author: {AUTHORS}
Date: 2026-11-22
Description: At any column of a Rule 30 row with a leftmost black cell, an eventually periodic pattern of isolated black pulses with gaps of at least nine must contain the consecutive gaps 12, 10, 9.
Abstract: {ABSTRACT}
Keywords: [Rule 30, sparse column, white gaps, leftmost black cell, eventual period, masked Jen, Lean]
Sources: ["[Rule 30 Prize kit](https://github.com/WolframInstitute/Rule30PrizeKit)", "[AIOvernight's ResetMixtures](https://github.com/WolframInstitute/Rule30PrizeKit/blob/dd2a220/lean/Ruliology/CellularAutomata/Rule30ResetMixtures.lean)", "[Lowry's FiniteStrips](https://github.com/WolframInstitute/Rule30PrizeKit/blob/dd2a220/lean/Ruliology/CellularAutomata/Rule30FiniteStrips.lean)"]
---

## Which gaps can a periodic sparse column repeat?

Watch one site of a Rule 30 row that has a leftmost black cell, as the single seed does. Suppose that from some time on the site shows isolated black pulses, each followed by a run of at least nine white ticks, its gap, and that the gaps repeat with some period. The all-sites long-gap exclusion applies AIOvernight's reset argument through the kit's finite strips and finite-left masked Jen theorem. It bounds every gap by 16, leaving the eight lengths 9 through 16.

The main theorem says more. Reading the gaps in order, the three gaps 12, 10, 9 must occur consecutively after any time. Read cyclically, every period of the gap sequence contains them. An occurrence may cross the period boundary. This holds at every site, at every onset and in every phase of the period.

The table counts ordered gap words of each length over 9 through 16, with a marked starting pulse. It gives the number containing the factor when read cyclically and the number excluded by that test.

```wl
hasTriple[w_List] := With[{n = Length[w]}, AnyTrue[Range[n], w[[#]] == 12 && w[[Mod[#, n] + 1]] == 10 && w[[Mod[# + 1, n] + 1]] == 9 &]];
TableForm[Table[With[{k = Count[Tuples[Range[9, 16], n], _?hasTriple]}, {n, 8^n, k, 8^n - k, N[(8^n - k)/8^n, 4]}], {n, 3, 6}], TableHeadings -> {None, {"gaps per period", "gap words", "contain 12, 10, 9", "excluded", "fraction excluded"}}]
```

For the four lengths shown, the fraction excluded falls as the period lengthens. Containing the factor is a necessary condition for realization.

## Why the factor is forced

Record the 19 cells to the right of the site at each pulse. One gap of q white ticks carries this window to its value at the next pulse.

- **Following every history.** The proof follows sets of windows through each gap, tick by tick. At every tick it admits either value of the cell just beyond the window. So every ordinary history, whatever lies further right, stays inside the sets.
- **Forbidding the factor.** A three-state monitor records how much of 12, 10, 9 has just been read, and forbids the gap that would complete it.
  - Starting from all 524,288 windows in each of the three monitor states, seven allowed gaps leave 35,507 pairs of a window and a monitor state.
  - Nested forward-invariant sets give four bands. Moves can stay in a band or enter a higher one. Each of the three higher bands has a single second-white reading, so a path entering them eventually has a constant reading.
  - Within the remaining band, the allowed moves are covered by a graph on six classes, each with a fixed second-white reading.
- **A forced period.** In a strongly connected component of the six-class graph, two paths with the same starting class, ending class and gap labels have the same readings of the right neighbour at the second white tick after each pulse. Any infinite path eventually stays inside one component. With periodic input, the finite graph and this agreement force the sampled reading to repeat eventually with a positive multiple of the input gap period.
- **The contradiction.** The warm-up law turns that periodic sampled reading into a periodic masked column. The kit’s finite-left masked Jen theorem rules it out for a row with a leftmost black cell. Every sparse gap period therefore contains 12, 10, 9.
- **The computation.** Lean computes every intermediate set with the kit's bit-parallel strip image (`fimage`), and checks each inclusion with a kernel decision. The 46 starting and destination sets are stored as packed numbers.

## Ten three-gap words that reset every right half

AIOvernight's set G consists of sixteen eight-cell windows. Starting a gap in G at its pulse keeps the window in G at the next pulse, for any gap of at least nine. Among the 512 words of three gaps from 9 to 16, exactly ten force the eight-cell window into G immediately after the three pulse-and-gap blocks, for every driven right half at every site and age.

- (q, 16, 16) for each q from 9 to 16;
- (16, 10, 15) and (16, 10, 16).

**The proof.**
- **The ten.** Lean checks the image of every starting strip window at width 14 or 18, with either value of the right exterior bit at every tick.
- **The other 502.** Each has a concrete right row whose final eight-cell window lies outside G. The kit's realization theorem embeds each witness into an ordinary full-line history carrying the given word.
- **After G.** The right neighbour is white on the first two white ticks of each later gap and black on its remaining white ticks (`forever`). For a periodic sparse drive this gives an eventual periodic masked reading. Combined with finite-left masked Jen, it gives a further exclusion for histories with a leftmost black cell. The formal statements below give the capture classification and the subsequent readings.

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
- The separate five- and six-pulse lower bounds are outside this packet.
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
