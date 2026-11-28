/-!
# Two falling residues in every 27 columns of the single seed, at every modulus from two

A column of Rule 30 from a single black cell *falls* at tick `t` when it is black at `t` and white at `t + 1`
(`Fall`). `Cofinal i r` says that column `i` falls at ticks congruent to `r` modulo `m` after every cutoff.

* `PhaseFalls.Moduli.two_cofinal_every_modulus_from_two`: for every modulus `m ≥ 2` and every integer `i`, one of
  the 27 columns `i, …, i + 26` has cofinal falls at two different residues modulo `m`.
* `PhaseFalls.Moduli.two_parities_every_27`: the case `m = 2`, falls on even ticks and on odd ticks.
* `PhaseFalls.Moduli.two_cofinal_every_modulus`: six columns suffice for every `m ≥ 3`.
* `PhaseFalls.Moduli.not_good_parity`: why modulus two needs more. A four-row loop of the six-cell strip has every
  fall on an even tick, and no adjacent pair repeats at lag two. The loop has period four, so it is no obstacle to
  Jen's theorem, which needs only some period.

The proof. If every column of a strip kept its late falls to one residue, the strip would follow a graph with both
exterior cells free. Rank certificates show that every such run has an adjacent pair of columns that is eventually
periodic, and Jen's theorem forbids that on the single seed. For `m ≥ 3` the pair repeats every `m` ticks on six
columns (`good3`, …, `good17`, with a slot deletion and divisibility). For `m = 2` the pair repeats with some lag
(`GoodAny`): fifteen certificates of widths 4 to 20 (`good_0011`, …), checked over the whole strip graph or over
the product of where the two halves of a strip eventually stay (`checkProd`), and a classification of every
assignment by its substrips up to width 27 (`goodAny27`). The data modules use a checker on raw `Nat` operations
(`checkFast`, `checkLag`), proved sound in the source.

The modules are in their build order. The seven data modules for `m ≥ 3` sit in nested namespaces `Data3`, …,
`Data17`, since they reuse the same private names, and each exports its one theorem.
-/
