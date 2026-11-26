# K92.5 · White tails in Rules 120, 180, 210 and 30

Rules 120 and 180 provide a nonlinear proof that an initially white left tail eventually passes every fixed observer. Rule 210 gives a different example in which a finite left half passes the one-sided clock condition and no finite full row sustains the clock. Each method has a short, explicit obstruction in Rule 30.

Use left, centre, right bits `l,c,r` in increasing spatial coordinate. Write the update as `l ⊕ cr ⊕ αc ⊕ βr`. The rule number lists outputs for triples 111, 110, …, 000, in that order.

| Rule | (α, β) | Truth table | Relevant conclusion |
|---|---|---|---|
| 120 | (0, 0) | 01111000 | From a leftmost black cell at L, every site below L + ⌊t/3⌋ is white at tick t. |
| 180 | (1, 0) | 10110100 | The same statement holds with ⌊t/2⌋. On finite full rows there is also an exact power-of-two spatial translation. |
| 210 | (0, 1) | 11010010 | The one-sided clock condition holds for the empty left start. The kit excludes an eventual two-phase alternating centre for every finite full row. |
| 30 | (1, 1) | 00011110 | The leftmost black moves left one site per tick. Exclusion of an eventual alternating centre for every finite full row remains open. |

## A direct leading-edge argument

**PROVED IN LEAN (full-line front).** For Rules 120 and 180, `f(0,0,r)=0` for either value of r, so a white left half-line stays white. Observe the word beginning at the leftmost black cell.

- Under Rule 120, `10` loses its leading black on the next tick. From `111` the first two sites become `10`. From `110` the first three become `111`, for either choice of the next bit. These cases exhaust the possibilities. Once that first site has become white, it stays white.
- Under Rule 180, `11` loses its leading black immediately. From `10` the first two sites become `11`, independently of the next bit.

Applying the argument at each newly exposed left edge proves the bounds in the table, including the case in which the row turns all white. Each fixed site is eventually permanently white, and the proof allows any infinite right half. The initial words `110` and `10` attain the respective three- and two-tick waits for the first site. These are bounds on one site's wait, with no assertion that a row attains the minimum advance at every later step.

Lean 4.35.0 checks the full-line induction and eventual whitening on arbitrary integer-indexed rows. The local step reduces 16 cases for Rule 120 and eight for Rule 180. Both public theorems use only `propext` and `Quot.sound`. [Full-line proof](SiblingFront.lean)

**PROOF-SKETCH (driven half-line).** The same decay rules out one-sided compatibility with an *imposed* alternating wall at position 0 for either rule. Until the left edge reaches −2, all the tested interior sites update normally. At −2 the Rule 120 case `110` uses the wall for its third bit. Its next value must be 1 because its current value is 0, just as required by the transition above. At −1 the last west cell remains black on a tick exactly when its right neighbour has the appropriate colour (black for Rule 120, white for Rule 180). The alternating wall supplies the opposite colour within two ticks. The west then stays empty. When the wall is white, producing black on the following tick would require a black west neighbour since both rules satisfy `f(l,0,r)=l`. This argument uses the wall's phase explicitly and also works with the opposite initial phase.

## Prior work and the Rule 30 test

Braga, Cattaneo, Flocchini and Quaranta Vogliotti classified pattern growth for finite perturbations of white and studied leading blocks, including Rule 120 and Rule 180. Cattaneo and Margara subsequently proved that for every finite Rule 180 configuration there exists a power of two M for which M updates shift the whole configuration right by M sites (Theorem 2.1). Theorem 4.4(i) gives convergence to the all-white row in the product topology, hence eventual white at every fixed site. The argument for Theorem 2.1 bounds the support in a moving interval and uses left permutivity to lift a return with at most one doubling. Their Rule 165 comparison serves a separate exact-period calculation. Condrey's kit theorem gives the exact full orbit of a single black cell. [Braga et al., Table 2 and §4](https://www.academia.edu/13940227/Pattern_growth_in_elementary_cellular_automata) · [Cattaneo and Margara, §§2 and 4.1](https://www.academia.edu/13971841/Generalized_Sub_Shifts_in_Elementary_Cellular_Automata_The_Strange_Case_of_Chaotic_Rule_180) · [Condrey's kit source](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30Rule180LoneSeed.lean)

Rule 30 fails the invariant at the initial edge itself. Both 30 and 210 have `f(0,0,1)=1`, so one new black appears immediately to the left of every leftmost black. Comparing by colour conjugacy also exposes the boundary condition. With C the global complement, direct substitution gives `C F180 C = F210`, which exchanges white and black tails. The relation `F30 = F120 C` complements only the input. Iterating Rule 120 on one initial row therefore does not reproduce a Rule 30 orbit.

For Rule 210, compatibility with the clock forces a checkerboard parity on black sites on its west. The gate `(1−c)r` then equals r there, giving Rule 90. The finite full-row proof additionally uses a clock realization of that west and follows the first deviation on the east. Rule 30 fails the parity argument on the single neighbourhood `010`. Its isolated black centre stays black one tick later, whereas Rule 210 makes it white. A candidate Rule 30 transfer would need a different invariant for a *deviation from a clock-compatible reference*, including a reason why a finite initial west necessarily differs from that reference. The left edge and permutivity alone meet neither requirement. [Rule 210 source and proof](https://github.com/WolframInstitute/Rule30PrizeKit/blob/0f957499e86fe008ca0ae75b5aef2e4df79144af/lean/Ruliology/CellularAutomata/Rule30Rule210Clock.lean) · [Rule 30 finite-support coupling](../../rule4/k84/K84FiniteSupport.lean)
