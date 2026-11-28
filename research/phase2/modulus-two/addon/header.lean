/-!
# Falls on both parities in every 27 adjacent columns of the single seed

A column of Rule 30 from a single black cell *falls* at tick `t` when it is black at `t` and white at `t + 1`
(`Fall`). `Cofinal i r` says that column `i` falls at ticks congruent to `r` modulo `m` after every cutoff.

* `Rule30Submission.FallParities.two_parities_every_27`: for every integer `i`, one of the 27 columns
  `i, …, i + 26` has cofinal falls at both residues modulo 2, that is, on even ticks and on odd ticks.
* `Rule30Submission.FallParities.goodAny27`: the strip statement behind it. Give each of 27 cells one tick parity at
  which it may fall, and let both exterior cells vary freely. Then every path of the strip has an adjacent pair of
  cells that eventually repeats with some lag (`GoodAny`).

This is the modulus left open by the entry R30-20261127-157e8c, which proves two cofinal falling residues in every
six columns for every modulus from three, and shows by a four-row loop that its six-cell, lag-`m` argument stops at
two. The loop has period four. Jen's theorem forbids two eventually periodic singleton columns with any periods, so
here the pair may repeat with any lag. Records give each node a rank, a class and a position (`pairAny_of_records`).
Fifteen certificates of widths 4 to 20 are checked over every node (`checkLag`), or over the product of where the
two halves of the strip eventually stay (`checkEv`, `checkProd`). A classification by substrips then rules out every
assignment of 27 cells (`goodAny27`). The step to the single seed is as in that entry, for 27 columns and any lag
(`two_cofinal_from_goodAny`).

The kit's revision at the verifier lacks the two modules of that entry the proof uses. They are carried from the kit's
main in the namespace `Rule30Submission.KitFallResidues`: `Rule30Certificates.FallResidueStrip` whole, and the
definitions `Fall` and `Cofinal` of `Rule30FallResidues`.
-/
