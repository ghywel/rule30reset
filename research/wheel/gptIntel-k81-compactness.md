# When the gate repeats, the nearby row must change

A turn of the 17/56 wheel has the cyclic gap word `355555`. The other long train in K81, three 5-gaps between successive 3-gaps, has cyclic word `3555`. A gap counts white-wall samples, two physical ticks apart. The two trains turn in 56 and 36 ticks respectively. The only boundary hypothesis below is an alternating column throughout the observed turn. The right half may have any support.

| Visible rhythm | Physical ticks per turn | Largest returning strip with a free eastern input | First width at which return is impossible |
|---|---:|---:|---:|
| Three 5-gaps per run (`3555`) | 36 | 87 | 88 |
| Five 5-gaps per run (`355555`, the wheel) | 56 | 70 | 71 |

**COMPUTED, with a hand implication.** Suppose the gate repeats the wheel for a whole turn from one kick to the corresponding kick. At least one of **sites 2 through 71** has a different colour at those two kicks. For the 36-tick train the range is **sites 2 through 88**. The visible rhythm can stay in phase while its neighbouring row changes every turn. The changed cell may depend on the turn. Neither statement requires prior entry into the 829-window trap.

## The sharp physical bound at the kick before the short gap

At the kick which starts the unique 3-gap in the turn, the physical bound is smaller. **A 56-tick wheel turn changes at least one of sites 2 through 66, and 66 is sharp. A 36-tick `3555` turn changes at least one of sites 2 through 83, and 83 is sharp.** These are upper bounds on the *first* site that changes. They do not identify which cell will change on another row. The two finite seeds below attain equality, even when the imposed boundary starts black a tick before the first measured kick.

| Gap word starting at the marked kick | Finite black-first seed (site 1 is the low bit) | Physical kick times counting from the first white tick | First site that changes |
|---|---|---|---:|
| `355555` | `0x132de5367e51340be8ed284d1caf0c` | 0, 6, 16, 26, 36, 46, 56 | 66 |
| `3555` | `0xd89bb127675d88b1f61ca44aa050c` | 0, 6, 16, 26, 36 | 83 |

The [one-turn test](k81_physical_turn.py) evolves the full radius-one light cone for P updates from an arbitrary row at the marked white kick. It constrains every white reading through the final kick and asks whether the first k sites can simultaneously agree at the endpoints. Every physical half restricts to the finite cone and every assignment to its initial row extends by white cells. The I188 prediction that the last free-input strip widths (70 and 87) would be physically attainable failed in both cases. Bisection located consecutive passing and failing widths at 65/66 and 82/83. Both negative certificates were verified independently by lrat-check and CakeML. Separate scalar evolution using the eight-entry truth table reproduced the kicks and first differing cells for both black-first seeds above. The physical cuts use only the masked gate. The wheel extremizer actually matches the [original full word U](README.md) at all 57 physical readings from the first through the next marked kick, including black-wall ticks. Reading the least-significant bit after each update gives `110100110100010011010001001101000100110100010011010001001`, equal to the 57 bits starting at physical index 46 in repeated U (white phase 23). Thus 66 is sharp even when that full wheel turn is required.

## Why a cyclic computation detects change in a finite physical turn

Let P and W be the period and the first impossible width in the table. The finite instance sets the wall alternately white and black on a circle of P physical ticks. On the P/2 white ticks it sets site 1 to the gate word starting at a kick; all black-time readings are free. It enforces the Rule 30 update at sites 1 through W across every tick, including the last to the first. The input from site W+1 is arbitrary at every tick.

If the first W positive cells of a physical right half were equal at both ends of a P-tick observation, take its P rows and its actual eastern inputs during these ticks. The assumed equality supplies the last update across the seam, giving the refused cylinder. Rotating those P rows to a canonical white kick makes the same argument valid at **every** physical starting phase. It uses the P/2 white readings among ticks t through t+P−1. The gate need not be separately constrained at t+P. When the endpoints are white and both report their prescribed bit, site 1 agrees, giving the ranges in the headline. If the full physical 56-bit word repeats, site 1 agrees at black endpoints as well.

Thus throughout a sustained train, for every sliding P-tick interval at least one of the W sites differs at its endpoints. For an infinite wheel this would give some fixed site among 2 through 71 whose colour differs from one turn ago on an upper asymptotic fraction of at least 1/70 of the white ticks. Indeed the sum of the 70 mismatch indicators is at least one at every white tick; some site attains the bound along a subsequence of the running averages. For the shorter train the analogous fraction is 1/87.

## Which infinite realizations this excludes

Suppose all positive columns eventually become periodic and their least periods have a finite upper bound, allowing different onset times. Their periods then divide a common multiple L which we may take divisible by P. Record their eventual words on the L-tick circle. Local Rule 30 updates hold because each uses only three columns. For neighbouring words b,c the west neighbour is forced by D(b,c)(t) = b(t+1) XOR (b(t) OR c(t)). The alternating centre and its masked gate therefore determine a pair (west, centre) of P-periodic words, even if site 1 itself has greater period.

The deterministic map F(b,c) = (D(b,c),b) has only finitely many pairs of L-tick words. The infinitely many columns to the east give arbitrarily long predecessor chains for the forced pair. A repetition in one sufficiently long chain places that pair on an F-cycle. All forward iterates from it are P-periodic, and reversing this cycle constructs an arbitrarily wide P-periodic strip. The update at the centre recovers precisely the prescribed east bit at white ticks. Either row of the table contradicts that construction. This is the [I166 forced-pair argument](exterior-tails.md#why-the-mixed-words-require-complexity-farther-east) applied to the two surviving K81 rhythms.

Every infinite realization would consequently need an eastern column with an aperiodic tail, or eventual column periods unbounded across the half. Neither the finite-prefix change nor this corollary rules out such a realization. In particular, an arbitrary finite right seed is free to develop aperiodic columns. Whether a single right half can sustain either train forever remains open.

## Receipts and reproduction

Both I187 cuts use the [time-cylinder encoder](periodic_exterior_strips.py), SHA-256 `540a30c82d631d4d4916b5e0629c94807fa60c9ed644160d13bdb53c3213b1af`. The accepted thinner strip is checked cell by cell, including the time seam. CaDiCaL produced each LRAT, and both lrat-check and the verified CakeML checker accepted it. The archive `share-scratch/gptIntel/I187/wheel-turn-cylinders.zip` (10,020,452 bytes, read-back SHA-256 `c99aee7091ff6681f6a06547155f9a9acd427c9df8c4179a30b374ceb155911f`) contains the last strip's complete phase rows and the first obstruction for each rhythm.

| Gate | Rejected CNF SHA-256 | Uncompressed LRAT SHA-256 |
|---|---|---|
| `3555` | `e280f0b9777b19d358d96fd770663633700f925dcd0e9015d5e234cc808a24ef` | `fcffdb3f33d636d512e9e6e8749dc70fdfd3ddc00f015285913a370d4916fdcf` |
| `355555` | `a13b809eb906740c5281d9203b61a379ae57095beb63c53c0e28cdae63572c27` | `d167be6de7de97aaad1f3042dc5cceb7bb7b074e71d240b2060a50bbd9ce835b` |

From the research repository run `python research/wheel/periodic_exterior_strips.py scratch --width 128 --gaps 3555 355555` with CaDiCaL, lrat-check and cake_lpr on the path. A strip witness permits any eastern input on its time circle. A physical witness needs control of the entire one-turn light cone.

The second archive `share-scratch/gptIntel/I188/wheel-turn-physical.zip` (10,718,404 bytes, read-back SHA-256 `340ea947151de5ab2de68d233d66d534144244ef95dfc01ceab95097a3185ad9`) contains the physical CNFs, LRATs for the two sharp upper bounds, the two extremizers, scalar black-first controls and all bisection receipts. Run `k81_physical_turn.py GAPS WIDTH scratch --cadical CADICAL --lrat LRAT_CHECK --cake CAKE_LPR` from its directory on each side of the claimed threshold. The frozen script SHA-256 is `f54c91f8914bc0d9c953e7cf5fb1e8a2b0d98eaa22eb7a25aca2ecd4effa97c8`.

| Gate | Rejected physical width | CNF SHA-256 | Uncompressed LRAT SHA-256 |
|---|---:|---|---|
| `3555` | 83 | `181b0cb0b0cedf9574679f4db34da87b2437ec9860d89c1c5778b5cd12c5441c` | `bf5c7e9ea84763b68ad3c8463952c86291933a13007c41e4592abc36c5465f7b` |
| `355555` | 66 | `dbafaf8af575c9910402683ec5d08499e13511c466d88374949e7f2e30471328` | `c37bc1e6bf6ae9ea37b71bb8c28bf9c1fe5e8a3c7e5f6fc66c60ec9bf73aa07d` |
