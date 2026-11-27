/-!
# The strip with free exterior cells and one permitted fall residue per site

Support for `Rule30FallResidues`. A node is a row of `w` cells, and an edge is one Rule 30 update with both exterior
cells free in which only the sites assigned to the current slot of an `m`-slot calendar may fall (`Run`). `Good`
says that on every such path some adjacent pair eventually repeats every `m` ticks.

* `quiet_eq`: among three successive quiet updates of a six-cell strip, the first is idle.
* `good_of_dvd`: one residue modulo `m` is one residue modulo a divisor, and a repeating pair lifts back.
* The rank check (`check`, `Certificate`): each node has a rank that no edge raises, and each rank names an adjacent
  pair with its reading at each slot.
* `Classifies`: the assignments still possible at a width, built from the two narrower restrictions.
-/
