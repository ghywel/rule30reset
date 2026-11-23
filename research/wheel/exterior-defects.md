# Twenty gate readings distinguish the two variable exterior components

Suppose a white-time window path stays in X or Y of gptM5's R69, at any one of widths 40 through 43. Read the immediate right neighbour of the alternating column at 20 consecutive white samples. **If the reading contains `10001` or `10101`, it came from Y. Otherwise it came from X.** Nineteen readings can be identical on two actual finite right halves. The test applies to an interval entirely spent in a component. A word collected while entering, leaving or between components can share these same readings. [R69 grammar and regeneration](../m9/exterior-grammars.md) · [R65 finite-window setup](../k50_1/right-dichotomy.md).

## Counting the samples

A digit in a *gap word* counts white-to-white intervals between successive black gate readings. R69's X words are built from `A = 25` and `E = 33535555`, with at least four copies of A separating excursions E. There is no gap 4 and there are no two consecutive gaps 2. Thus X has neither binary marker.

R69's Y excursions are `S = 45` and `L = 4525`, separated by 3 to 22 successive gaps of 2. Mark the start of a 4-gap and the start of each adjacent pair of 2-gaps. These are exactly the two binary markers, each five samples long. From the 4 at the beginning of S or L, the next mark starts 9 or 16 intervals later at the beginning of the first pair of 2s. Marks within the separator start two intervals apart. From the final pair to the next 4 costs four intervals. Hence consecutive mark starts are at most 16 apart. A window starting just after a mark needs at most 15 intervals to reach the next start and four more to read the marker's end. Twenty samples suffice. Any finite path inside a strongly connected component extends in that graph in both directions, so the counting argument includes partial gaps at either end.

Only L gives the largest spacing. Start one sample after its 4 and stop one sample before the *end* of the next marker. The resulting 19 samples are `0001000010100001010`. They give the sole Y word of that length avoiding both markers. The two finite rows below also prove that this word occurs in X.

## Which of the five defects recur?

The five binary words of the wheel entry observer are `00000`, `11`, `101`, `10001`, and `1001001`. At each of widths 40–43 the following are the minimum guaranteed interval lengths, including both endpoints. “Optional” means that the marker occurs on some graph paths and can be avoided forever on another. [Entry observer](complete-observer.md) · [Checked maximal avoiding words](data/exterior-defect-words.json).

| Component | `00000` | `11` | `101` | `10001` | `1001001` |
|---|---|---|---:|---:|---|
| X | absent | absent | every 43 samples | absent | optional |
| Y | absent | absent | every 13 samples | every 57 samples | absent |

Both components always have gaps between 2 and 5. In X the adjacent threes occur in E, while the repeating A path avoids them. The 2-gap starts are seven intervals apart in successive A blocks. Across an E the start spacing grows to 7 + 34 = 41, giving 43 samples to include an entire `101`. In Y the greatest start spacing for 2-gaps is 2 + 4 + 5 = 11, giving 13 samples. The greatest start spacing for 4-gaps is 4 + 5 + 22 × 2 = 53 after S. The longest allowed return after L has just three separator twos and lasts 22 intervals. The R69 `S–22–S` realization gives equality for the 53 bound and hence 57 samples to include the full `10001`. The exact finite-strip result gives the 57-sample upper bound and a 56-sample strip witness. The 43- and 13-sample bounds are also sharp on physical visits. At the initial black tick, take finite rows `0x12a2f059fdb` and `0x924924204dc09d4f` respectively. The first then spends 42 consecutive white samples in X without a `101`, and the second spends 12 in Y without one. The scalar replay below checks every physical window of both controls.

## Two genuine black-first finite rows

Encode the first positive cell in bit 0 and continue east, assigning zero beyond the highest bit. Evolve each row under a clamped alternating left wall, starting black in the kit convention. Its first white-wall sample occurs one physical tick later.

| Core | Finite row at the initial black tick | Row one tick later | Consecutive W43 windows in core |
|---|---|---|---:|
| X | `0x312556d4b13` | `0x5bfd52579bc` | 19 |
| Y | `0x239781348a5` | `0x74f0c3d7dbc` | 19 |

Both runs emit `0001000010100001010` on physical ticks 1, 3, …, 37. A scalar simulation computes all 38 window codes and looks up each of them in its exact, digest-checked component. R69 builds the component tables by lifting the full W24 decomposition. Intel independently rebuilt W24 and all eight X/Y tables at widths 40–43, matching all published membership hashes. These finite rows establish the lower bound for the observable classifier during genuine component visits. The existence of a finite right half staying indefinitely in either core *with an aperiodic gate* remains open. [Finite controls and window codes](data/exterior-defect-controls.json) · [Scalar replay](exterior_defect_witness.py).

## Consequence for period two

For an aperiodic gate, nonentry into the 829-window trap, arbitrarily late occurrences of `101`, and eventual occurrence of `101` inside **every** 43-sample window are equivalent. If the path stays outside, the finite W43 graph eventually stays in one component. R65 and K78 identify X and Y as its only possible recurrent components with a variable gate. Both have the required recurrence. In the opposite direction, the kit proves that from trap entry the gaps are 3 or 5, eliminating `101`. The onset of recurrence depends on the right half.

The finite-right dichotomy RD therefore holds exactly when every finite right half with an aperiodic sampled gate has arbitrarily late 43-sample intervals without `101`. Establishing that condition for finite right halves remains open. The Lean bridge isolates the finite-graph input as an explicit hypothesis. [R65](../k50_1/right-dichotomy.md) · [K78 component check](claudeCloud_exterior_cores.cpp) · [Stock gate and gap results](../../Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30GateTrap.lean) · [Logical bridge](WheelTwoGapRecurrence.lean).

At a white-wall reading the temporal marker `101` has a spatial cause visible four physical ticks before its last bit. Sites 1, 2 and 3 must read `100`, and either site 4 or site 5 must be black. This local equivalence holds throughout the half-line model, including transits. Reading only the first four sites loses information. From the empty black-first row and from the row with only site six black, the first four positive sites agree at the first white tick but the two-gap forecasts differ. The kit’s ether-wall witness, supported through site 19, gives `101010…` at every white tick forever. Its periodic gate shows why proving disappearance of the marker from finite support alone would fail. R65 had already recognized recurring two-gaps in both known periodic destinations. [Seven stock Lean headlines](data/two-gap-recurrence-stock.json) · [R65’s finite controls](../k50_1/right-dichotomy.md#where-the-58-seeds-went).

## Replay

Use the extracted R69 archive `share-scratch/gptM5/M9/R69-exterior-grammars.tar.gz`, SHA-256 `6977dbd029b8c7d6b77c4205cfaa92d456c5e08534db63f8f7f6c7ce9611a0eb`, as the directory supplied to the first command. Alternatively rebuild the machines using R69's C++17 and Python commands. The factor reader takes an incoming partial gap and an outgoing partial gap into account, and enumerates a prefix-closed language until the first empty length. It recomputes the separating length, the three sharp waiting times, the possible defect words and the two-marker test independently at all four widths. [R69 rebuild commands](../m9/exterior-grammars.md#reading-and-reproducing-the-machines) · [Factor reader](exterior_defect_words.py).

For the second command, the R69 rebuild's `windows` and `cores` stages suffice. Pass the directory containing their `X43.bin` and `Y43.bin` outputs. The scalar replay needs Python 3.11+ with its standard library. Run both commands from the repository root.

```sh
python research/wheel/exterior_defect_words.py /path/to/R69 /path/to/defect-result.json
python research/wheel/exterior_defect_witness.py /path/to/rebuilt-cores
```
