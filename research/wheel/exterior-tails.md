# Three possible gate patterns outside the wheel's trap

At an alternating Rule 30 column, sample its immediate right neighbour whenever the column is white. A black sample is a *kick*. Suppose that after some time kicks continue forever, with successive gaps of either 3 or 5 samples. If the 16 cells to the right stay outside the kit's 829-window trap, the gap sequence eventually repeats **`3`, `33355` or `333355`**, up to rotation. The October rotating 84-ring realizes the first pattern. The existence of an infinite physical right half for either mixed pattern is open. This continues claudeCloud's [K75 wheel study](claudeCloud-tails.md) and the [exterior grammars of R69](../m9/exterior-grammars.md).

On a full line initially having a leftmost black cell, including the single seed, suppose the centre eventually alternates. Then **the gate eventually has only 3- and 5-gaps exactly when it enters the trap during that alternating tail**. Entry gives the gap law by closure. Conversely, if the tail stays outside, the classification gives an eventually periodic white-time reading. Masked Jen excludes that reading. An eventual end of all kicks would also give an eventually periodic reading. Whether the singleton acquires the gap law is open. [Kit trap and gap laws](https://github.com/WolframInstitute/Rule30PrizeKit/blob/7c764eff648a5e795aa3d4afe346db243b6db337/lean/Ruliology/CellularAutomata/Rule30GateTrapWords.lean) · [Finite masked Jen](https://github.com/WolframInstitute/Rule30PrizeKit/blob/7c764eff648a5e795aa3d4afe346db243b6db337/lean/Ruliology/CellularAutomata/Rule30FiniteMaskedJen.lean) · [Lean specialization to white samples](WheelThreeGapExterior.lean).

## Why 31 columns suffice

Observe columns 1 through W at a white tick. Allow the bit just beyond the window to be independently chosen on each of the next two physical updates. Every real right half gives a path in this finite graph. Drop windows whose first 16 cells are in the trap. Record the number of white samples since the last kick, allowing a return to zero only after a gap of 3 or 5.

Every infinite path in a finite graph eventually stays in a single strongly connected component. Within such a component, take the distance of each vertex from a fixed root. The gcd of the differences `distance(u) + 1 − distance(v)` over all edges gives its period. Along an edge the distance residue advances by one. When all vertices in each residue class emit the same bit, every path in the component emits the same repeating word up to its starting phase.

A cycle at width W+1 projects to a closed walk at width W. To compute the wider cyclic components it therefore suffices to try both one-bit extensions of every vertex lying on a narrower cycle, restore every valid edge between these vertices, and take cyclic components again. Direct exhaustive computations at widths 16, 18, 20, 22 and 24 also recover K75's five sample-window counts. An independent implementation jumps directly between kicks and computes the components with SciPy. At these widths the light cone of the first five future gate readings fits inside the starting window, so it fixes the next gap. The second implementation enumerates every choice of the exterior bits up to that next kick. Trap closure justifies testing the endpoints. The two computations agree on the component output types at every width from 16 through 43. [White-sample graph](exterior_gap_core.py) · [Independent kick graph](audit_exterior_gaps.py) · [Counts by width](data/exterior-tail-checks.json).

At width 30, at least one cyclic component still gives variable output. Width 31 is the first width of this window model at which each component fixes its output. Its five components contain 8,376 sample states, including 2,685 kick windows. All three words survive in the window model through width 43.

| Repeating gaps | Components at width 31 | White samples per repetition | Physical ticks per repetition |
|---|---:|---:|---:|
| `3` | 2 | 3 | 6 |
| `33355` | 1 | 19 | 38 |
| `333355` | 2 | 22 | 44 |

## The physical example with gaps of three

For temporal columns `b,c`, Rule 30 determines the column immediately to their west by `D(b,c)[t] = b[t+1] XOR (b[t] OR c[t])`. At the alternating centre, only the white-time east readings enter this expression. Start at a white tick with the six temporal centre bits encoded as 42, low bit first, and the white-time kick pattern `100`. The forced western column is 62. Iterating the pair `(62,42)` west returns for the first time after 84 columns. Reading the cycle east gives the rotating 84-ring already exhibited by the project in October. The black-first cut is a shift by 65 of the archived row, and the ring rotates 14 cells to the right per tick. [Original ring in *Bricks, Rulers and Fronts*](https://www.wolframcollatzmahler.com/rule30/bricks.html) · [Archived ring in Lean](../source-density/Rule30ClockDensityExamples.lean) · [Construction and scalar replay](three_gap_ring.py).

The three white-time windows are 14583, 30138 and 63448, all exterior. One fixed infinite right row therefore sustains gaps of three forever. For every prescribed finite duration, a finite-support truncation gives the same observation by the light cone. This leaves open whether one fixed finite-support row does so forever. In K75's 100-sample row, all twelve near-wall cells match this ring at every physical tick from 70 to 190 inclusive. The ring also supplies an explicit model for all 512,650 clauses of K75's unresolved 200-sample instance. The stock Lean checker passes four headlines covering the physical ring, its exterior gate, arbitrary finite truncations and the full-line masked-Jen corollary, with 40 constants and zero new axioms. [Lean source](WheelThreeGapExterior.lean) · [Ring, CNF and checker receipts](data/exterior-tail-checks.json).

## Why the mixed words require complexity farther east

Ask whether W positive cells can all repeat with the gate's own physical period p. Evolve every one of these cells by Rule 30, wrap time modulo p, fix the alternating wall and its white-time gate, and leave the input from cell W+1 free at each tick. The test applies even if we drop the trap condition. Width is monotone under restriction. Direct evolution checks the last possible strip, including its seam in time. Two LRAT checkers verify the first impossible width. [Encoder](periodic_exterior_strips.py) · [Boundary rows and proof digests](data/exterior-tail-checks.json).

| Gate | p | Largest possible W | First impossible W |
|---|---:|---:|---:|
| `33355` | 38 | 54 | 55 |
| `333355` | 44 | 37 | 38 |

The two boundaries respond differently when the eastern columns are allowed twice as long to repeat. For `33355`, a 76-tick strip still stops at 54 columns. Both checkers verified the obstruction at 55. For `333355`, an 88-tick strip **does** reach column 38. The gate repeats every 44 ticks, while the evolved strip has least period 88. In this particular witness column 13 is the first to differ after 44 ticks. All white-time 16-cell windows in both doubled-period witnesses stay outside. Each row records the wall at bit zero, then the W evolved cells and one free eastern input. [Rows and proof digests](data/doubled-strips.json).

There is a stronger consequence. Suppose every column of a physical realizing right half eventually repeats with a common period L. Their starting times may differ. Take a common multiple of L and p, and use it as the temporal modulus. Each column gives a well-defined stabilized word on this modulus. Each local update still holds, since it uses only three columns and their starting times have a finite maximum.

On the finite set of ordered word pairs use the map `F(b,c) = (D(b,c),b)`. The forced pair immediately west of the centre consists of p-periodic words: the centre has period two, and the white-time gate fixes the only bits of its neighbour used in D. The physical right half supplies arbitrarily long predecessor chains for this pair under F. A repeated pair in one sufficiently long chain shows that the forced pair lies on a cycle. All forward iterates of the forced pair remain p-periodic, so reversing its cycle supplies an infinite p-periodic right extension. Its centre is the same, and at every white tick its forced west and centre recover the specified east bit uniquely. Such an extension would contain the first impossible strip in the table.

Thus any physical infinite realization of either mixed word would need an aperiodic column somewhere to the east, or eventual column periods with no finite upper bound. Within the first 55 or 38 cells respectively, at least one column must already fail to acquire the gate's own period. The finite obstructions are LRAT-checked. The period argument above is a hand proof.

There is an exact compactness test for what remains. A physical infinite exterior with a specified repeating gate exists **if and only if** the finite free-east window graph has a closed walk spelling that gate at arbitrarily large widths. For the forward direction, include the position in the gate word in the state. Any infinite physical path repeats a state and phase in each finite graph, giving the walk. Conversely, repeat each walk in time and align the same kick at tick zero. Each finite space-time rectangle has finitely many fillings. Choose a subsequence agreeing on the first rectangle, then the next, and take a diagonal subsequence as widths grow. The limit satisfies every Rule 30 update at positive sites, the alternating wall, every gate reading and exterior membership. Its initial row is the desired right half. Thus a disappearance at any width settles nonexistence, while a construction at unbounded widths would settle existence.

## Which short readings can actually certify entry

For all 254 words of one through seven 3/5-gaps, K75's original CNF digests match. All 200 outside models replay cell by cell. For each of the other 54 words, CaDiCaL produced a text LRAT proof that ending outside is impossible. Two checkers verified every proof. A second encoding, with the terminal window unrestricted, separates these 54 cases into **43 words that occur and force entry** and **11 physically impossible words**. Of K75's 25 minimal forcing factors, 22 are attainable. The three impossible minimal factors are `3353353`, `5553353` and `5555335`. [Audit](audit_gap_observers.py) · [All eleven impossible words and shortest witness](data/exterior-tail-checks.json).

The unique shortest attainable kick-to-kick certificate over this alphabet is **`53535`**, with kicks at samples 0, 5, 8, 13, 16 and 21. Its witness ends at trap code 6247. The assertion covers longer words too: eight gaps already take at least 25 samples including both endpoints. K75's finite-sample mean run of 5.0015 is a measurement on its stated cohort. It plays no part in these implications.

## Reproduction

Run from the research repository with kit `7c764eff648a5e795aa3d4afe346db243b6db337`. The Python environment uses NumPy, NetworkX, SciPy and python-sat. The two proof-producing commands use CaDiCaL, lrat-check and CakeML's cake_lpr. Each accepts `--cadical`, `--lrat` and `--cake` for explicit executable paths.

```text
python research/wheel/audit_gap_observers.py Rule30PrizeKit wheel-observers
python research/wheel/three_gap_ring.py Rule30PrizeKit
python research/wheel/exterior_gap_core.py Rule30PrizeKit 16 --lift-through 43
python research/wheel/exterior_gap_core.py Rule30PrizeKit 16 18 20 22 24
python research/wheel/audit_exterior_gaps.py Rule30PrizeKit 43
python research/wheel/periodic_exterior_strips.py wheel-strips
python research/wheel/periodic_exterior_strips.py wheel-double --width 55 --gaps 3335533355
python research/wheel/periodic_exterior_strips.py wheel-double --width 38 --gaps 333355333355
python research/wheel/replay.py Rule30PrizeKit wheel-exterior-lean --exterior
```

The shared-store packet `share-scratch/gptIntel/I162/wheel-exterior-evidence.zip` (11,343,033 bytes, SHA-256 `e9cd9a8ea8635a2698ecfbbb92d87e173469a0aecb77972f705440f0d42ab890`) contains the 67 DIMACS/LRAT pairs, the witness and graph outputs, and the stock Lean receipt. Decompress each `.lrat.gz` and run either checker on the matching `.cnf` and `.lrat`. The [tracked summary](data/exterior-tail-checks.json) includes the SAT boundary rows and the finite 200-sample witness.

The separate doubled-period packet `share-scratch/gptIntel/I166/doubled-strip-evidence.zip` (2,020,911 bytes, SHA-256 `2bd327963daa0c49ddded231d981b94df8aec779971556717f4184749eb61d69`) includes the 76-tick width-55 CNF and LRAT, and both finite strip models.
