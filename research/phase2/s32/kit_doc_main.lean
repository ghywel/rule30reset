/-!
# Two falling residues in every six columns of the single seed, at every modulus from three

A column of Rule 30 from a single black cell *falls* at tick `t` when it is black at `t` and white at `t + 1`
(`Fall`). `Cofinal i r` says that column `i` falls at ticks congruent to `r` modulo `m` after every cutoff.

* `two_cofinal_every_modulus`: for every modulus `m ≥ 3` and every integer `i`, one of the six columns
  `i, …, i + 5` has cofinal falls at two different residues modulo `m`. The column and the residues may depend on
  `m` and `i`.
* `not_good_parity`: a control at modulus two. A four-row loop of the six-cell strip with free exterior cells has
  every fall on an even tick, and every adjacent pair changes under the lag-two shift. So the strip argument does
  not reach parity.

The proof. Suppose each of the six columns kept its late falls to one residue. Then the six cells follow a strip
graph with both exterior cells free and a calendar of `m` slots (`Run`, in `Rule30Certificates.FallResidueStrip`).
If three successive updates are quiet, the first leaves the strip unchanged (`quiet_eq`), so one slot can be deleted
from every period and any modulus above 18 reduces to 18 (`good_of_small`). Divisibility leaves the moduli 3, 4, 5,
7, 11, 13 and 17 (`good_of_dvd`), where rank certificates show that some adjacent pair of columns repeats every
period (`good3`, …, `good17`, in `Rule30Certificates.FallResidues3` to `FallResidues17`). Jen's theorem forbids that
on the single seed (`two_cofinal_from_good`, with `Rule30Jen.not_adjacent`).

The trapped window with freely chosen exterior cells is KDRonald3 and Claude's method (Rule 30 Prize submission
R30-20261115-2d4add); here the graph carries a clock.
-/
