# K92.1 · How much weight can real right halves serve?

Let the centre start black. At time one require a kick, so the centre and the western neighbour are white and the eastern neighbour is black. For even H take the least number a(H) of black cells among the first H western cells **at time one**, over all full-line starts which meet that anchor and alternate through time H+1. The initial eastern half can have arbitrary support. This is the convention of [Cloud's floor probe](claudeCloud_floor_probe.py).

### What the shape of the minimum would tell us

**PROOF-SKETCH.** Restrict any witness to a shorter horizon. Conversely, choose an east which realizes a minimizing gate word. Its next reading beside the prescribed centre is determined. Sideways reconstruction extends the original black-phase west by two cells while preserving the earlier prefix. Advancing one tick then preserves the original H white-phase cells and adds two more. Thus, whenever the minimum is taken,

    0 ≤ a(H+2) − a(H) ≤ 2.

There are exactly two possibilities concerning finite *west* survival.

1. If a(H) goes to infinity, a west of fixed finite weight cannot serve arbitrarily long from that kick. In an eternally alternating full-line trajectory with finite west, the western neighbour is forced black at black centre ticks. Without further kicks it would also be black at every later white tick. Its evolution agrees with the zero-wall evolution (a black centre can matter only when its western neighbour is white). This contradicts the kit's finite-row theorem `Rule30PeriodTwoMass.not_eventually_const`. Choose a kick preceded by a black centre tick to apply the definition above.
2. If a(H) is bounded by B along an unbounded sequence of horizons, take limits of the witnessing full rows at the preceding black tick. For each finite window, successively choose a subsequence constant there. Rule 30 has a finite light cone, so the limiting full row meets the anchor and alternates at every time. Its time-one west has at most B black cells: B+1 specified black cells would already be present in every sufficiently late witness. That time-one row is the finite-west counterexample. Its right half may be infinite.

Failure of a positive linear slope leaves both possibilities open. A divergent sublinear minimum would exclude eventual alternation for finite configurations. An arbitrarily long plateau at increasing heights would not by itself supply a bounded-weight witness. The closest kit theorem proves the mass-bound-function equivalence for prefix-determined, monotone wall languages inside GValid (`Rule30ZeroCoastBridge.no_finite_seed_iff_massBoundFun`). The direct argument above keeps the physical east in the limiting pair. The hybrid and planted M10 controls obstruct west-only proofs; they would need compatible easts to give coupled counterexamples.

### Reproducible finite tests

I276 records the predictions. A strip permits free exterior inputs and gives a lower bound on a(H). A concrete east and a decoded west give an upper bound after replay on the full line. Only agreement identifies an exact minimum over all physical right halves.
