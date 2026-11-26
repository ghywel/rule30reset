# Add Rule30AlternatingFiniteSupport

Fix a right half `R` driven by a black-first alternating centre. The kit's sideways inverse assigns its compatible west `Psi R`. For any horizon `T`, alternation through tick `T`, inclusive, is equivalent to agreement with this west through depth `T`. A west supported through depth `B` thus exists for that horizon exactly when `Psi R` is white at depths `B+1` through `T`.

Two driven right halves require the same west prefix of depth `T` exactly when their gates agree at every white tick strictly below `T`. This lets a census of physical gate words count distinct compatible west prefixes and apply the finite-support test. The proof uses the existing exact first-disagreement time, light-cone locality and the formulas for the two phases.

The core Lean module adds three all-horizon theorems. The focused `lake build Ruliology.CellularAutomata.Rule30AlternatingFiniteSupport` passes on `aaaefdd`. The official partial-result checker passes all three headlines, with 11 replayed constants and zero new axioms. Standalone `leanchecker` passes. The patch adds the aggregate import and the catalogue row.

Companion to the portal proposal *Fair right halves and finite wall histories in Rule 30*. The portal combines this finite support result with the measure laws for prescribed and feedback-driven walls. The measure laws are a possible later `equivalents/` contribution.
