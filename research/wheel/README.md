# The 17/56 wheel identifies the period-two gate trap

Forty-six consecutive white-time observations of the main wheel force the sixteen cells immediately to the right of an alternating column into the kit's 829-window trap by the last observation. This is sharp over all starting phases and all physical right rows. Forty-five observations can still end outside even when every intervening tick follows the wheel. Once inside, an aligned return to the old period-14 pattern can last at most sixteen physical ticks. A planted row attains sixteen. [Exact phase thresholds and witnesses](thresholds.json) · [Gate trap in the kit](https://github.com/WolframInstitute/Rule30PrizeKit/blob/8e1cc847a758a892ec4b51182cdf325b1c483f9a/lean/Ruliology/CellularAutomata/Rule30GateTrap.lean)

A [complete gate-only observer](complete-observer.md) recognizes entry from 48 white-time readings. Two physical rows prove that 47 readings cannot always distinguish the outside from the mature trap. On the exterior the only endless 3/5 tail eventually has all gaps three, realized by the October 84-ring. A [finite singleton deadline](exterior-budget.md) limits the duration of this behaviour while its own centre alternates. The earlier wheel-aligned threshold of 46 samples above uses a more specific hypothesis. [ClaudeCloud’s gap classification](claudeCloud-tails.md) · [Mixed-word proofs](mixed-cuts.md).

## What is observed

The wall is column 0. Column 1 is its immediate right neighbour. Start at a **white** tick of the wall and sample column 1 every two physical ticks. The original 56-tick word and its 28 white-time bits are

```text
U     00010011010001001101000100110100010011010001001101001101
gate  0001000010000100001000010010
```

Phase p means starting at gate index p, or physical index 2p in U. Its visible black indices are 3, 8, 13, 18, 23 and 26 modulo 28. Thus the wheel closes after five gaps of five double steps and one gap of three. The kit uses an odd absolute time for a white wall. The Vitruvian display counts a stretch of 56 physical ticks as a wheel sighting. [Vitruvian Rule 30](https://www.wolframcollatzmahler.com/rule30/vitruvian.html) · [Archived literal words and the October correction](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/lexicon/rule30_wheel_left.py)

## Three fragments give the sharp physical threshold

Each row of the table forces trap membership at its **last** sample for every physical right row. Only the centre values needed for the intervening updates are prescribed. Distant cells can be chosen arbitrarily.

| White starting phase | Samples | Observed column-one bits |
|---:|---:|---|
| 12 | 33 | `010000100001001000010000100001000` |
| 21 | 29 | `00100100001000010000100001000` |
| 26 | 29 | `10000100001000010000100001001` |

For a start at phase p, wait for any of the three fragments and take the first one to finish. The worst start is phase 27, which requires 46 samples, spanning 91 physical ticks including both endpoints. The best starts are phases 21 and 26, which require 29. Matching the black-time ticks as well gives the same answer at all 28 phases.

Three finite right rows prove sharpness at every phase. They start at phases 27, 13 and 22 and read respectively 45, 36 and 32 white samples, including every intervening tick of U. Their final windows are respectively 7772, 1016 and 48180, all outside. Starting later in any of these same evolutions supplies the lower bound at that later phase. In the 45-sample witness the next double step from 7772 enters the trap for every physical exterior choice. The column keeps spelling U across entry. A 56-tick sighting on the display can therefore still be outside. [Rows and all 28 thresholds](thresholds.json)

**Finite proof.** Use the triangle from an arbitrary initial right row to the final 16 cells. For n observations this takes 16+2(n−1) initial cells. Enforce the observations, Rule 30 at every update, and exclusion of each of the 829 trap codes on the final row. The first encoding uses the eight truth assignments per interior update. The second numbers the rows backwards and factors each update into OR and XOR. The independent encodings give the same three obstructions. CaDiCaL supplied LRAT, and both lrat-check and CakeML's cake_lpr verified the unsatisfiability proofs. All 56 phase/mode boundary cases also passed both checkers in the first encoding. Plain cell-by-cell evolution verifies the positive rows. [Phase sweep](physical_thresholds.py) · [Three-marker reduction and second encoding](audit_thresholds.py)

**Lean proof at 67 samples.** A separate proof allows an independent eastern bit on each of the two physical updates of a 16-cell window. The 40-sample word from phase 15 forces the trap in this larger graph. Every phase contains that marker within 67 samples. The certificate carries, for each window, the positions at which a suffix could still end outside. Its initial bits, terminal condition and all four transitions are checked against the kit's actual double step. The physical theorem applies also to a finite alternating stretch of the genuine singleton, with no hypothesis about earlier or later centre values. [Window certificate](WheelMarkerCheck.lean) · [Physical and singleton theorems](WheelMarker.lean)

## What the trap says about later kicks

The [kick predictor](kick-predictor.md) marks the physical cells responsible for a departure. At a trapped pulse, site 5 selects the next gap six ticks ahead. After 140 matched wheel ticks, one or two cells determine a departure fourteen ticks ahead. The same tool can certify the time and signed size of a new phase from a wider snapshot.

* Starting at a visible black pulse, column 1 spells exactly `110100` or `1101000100` before the next visible pulse. This determines the black-time readings too. The archived M106 right row spells U at **all 287 physical ticks from 200 through 486**, starting at physical phase 46. This is a concrete 17/56 run in the trap. [Full-tick proof](WheelTiles.lean) · [M106 right row](../m9/data/claudeM5-m80-runs-of-five-5x5-P100.json)
* Write g(s) for the neighbour at a white tick and b(s) for the neighbour on the immediately following black tick. Once samples s−3 through s are in the trap, **b(s) = g(s) OR g(s−1) OR g(s−3)**. In particular every later black-time reading is determined by observations available before that tick. All three inputs are necessary even on the permanent five-lock, when choosing among the four most recent white samples. Two traces on that clock can agree on the other three and differ on the following black tick. [Midpoint proof and the three necessity witnesses](WheelTiles.lean)
* The two certified seven-lock families at widths 30 and 45 both emit the old 14-tick comparison word `00010011001101`, up to an even rotation. The five-lock emits the ten-tick tile forever. In the trap both tiles begin `1101`. The 14-tick word demands `1100` at physical phase 6. Every aligned 17-tick interval contains that conflict. Seed 28998 in the five-lock shows that 16 is attainable. The October experiment recorded 193 transitions from a 14-tick reading to U and zero in the reverse direction. The theorem explains why a sufficiently long U run precludes a subsequent sustained return. The old classifier also counted shorter U sightings. [October transition log](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/lexicon/rule30_walls.py) · [Kit lock families](https://github.com/WolframInstitute/Rule30PrizeKit/blob/8e1cc847a758a892ec4b51182cdf325b1c483f9a/lean/Ruliology/CellularAutomata/Rule30SidewaysLocks.lean)
* G248/GC582 expresses the difference between its two kick readings, phase and charge, as 14 times the sum of the complete intervening zero-gap lengths modulo 28. Choose black endpoints in two wheel stretches after entry. Each zero gap between them now has length two or four. The two kick readings consequently agree modulo 28, even for a transient that changes several gaps. This gives a constraint across kicks. The October 16 class/size pairs at exactly 140 ticks all remain possible, since their witnesses already meet the new entry criterion. [G248 and its multi-gap extension](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/proofs/G248-a-single-wheel-seam-s-crossing-gap-parity.md)
* Entry also gives a route from visible observations into the existing forbidden-gap results. For example, ten white samples after an entry, two consecutive gaps of three are impossible. S10 gives further run exclusions inside the same trap. Jeongseop Lee's one-seed work and the kit's general forbidden words predate this observer. [Kit gap laws](https://github.com/WolframInstitute/Rule30PrizeKit/blob/8e1cc847a758a892ec4b51182cdf325b1c483f9a/lean/Ruliology/CellularAutomata/Rule30GateTrapWords.lean) · [Lee's portal entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261030-60990f) · [S10 on the portal](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-71bab6)

## The remaining period-two question

There is a finite test using **only column 1 of the genuine singleton**. Suppose it reads the main wheel at 46 white-time samples relative to a proposed centre phase, then later reads the aligned 14-tick pattern for 17 consecutive ticks. Somewhere from the first observation through the end of the return, the centre must disagree with the proposed alternating clock. Otherwise the first reading puts the window in the trap, the clock preserves it, and the second reading is impossible. The Lean statement checks this implication with the independent 67-sample observer, for a return starting on either colour of the clock. [Finite singleton centre break](WheelReturn.lean)

If the genuine singleton centre alternates during the observed segment, the same finite-cone implication holds. If it continues alternating, the trap persists. Masked Jen separately forces a white-time disagreement with the column-one reading 56 ticks earlier in every interval [n,2n) with n ≥ T+56, if the centre has period two from T. Together these give a conditional description of a wheel-bearing tail. Its pulse-gap sequence cannot become periodic, since a periodic sequence of six- and ten-tick tiles makes the neighbouring column eventually periodic. To turn this into an exclusion of period two, one still has to constrain which trapped gap sequences the singleton's left side can sustain, or rule out a tail that avoids the wheel marker altogether. The planted M106 row supplies no occurrence in the genuine singleton. [Masked Jen in the kit](https://github.com/WolframInstitute/Rule30PrizeKit/blob/8e1cc847a758a892ec4b51182cdf325b1c483f9a/lean/Ruliology/CellularAutomata/Rule30MaskedJen.lean)

## Reproducing the checks

The Python commands below run from the research repository. They use NumPy, CaDiCaL with text LRAT output, lrat-check and cake_lpr. The two output directories can be placed in local scratch. The second command recomputes both kinds of boundary at every phase. The third constructs the smaller proof independently.

```text
python research/wheel/wheel_bridge.py Rule30PrizeKit research/m9/data/claudeM5-m80-runs-of-five-5x5-P100.json
python research/wheel/physical_thresholds.py Rule30PrizeKit wheel-sweep
python research/wheel/audit_thresholds.py Rule30PrizeKit wheel-sweep wheel-compact
```

The shared-store packet `share-scratch/gptIntel/I155/wheel-thresholds.zip` contains the three DIMACS instances, their compressed text LRATs, every boundary receipt, and the original encoders. Its SHA-256 is `0def6ae149955a9b20e2ae9bf4ceec4735d7772957ad4a344d838ec27a987ec2`. Each decompressed proof can be checked directly with its DIMACS file, independently of the search.

For Lean 4.35.0 run `python research/wheel/replay.py Rule30PrizeKit wheel-lean` against kit `8e1cc84`. It builds the dependencies and the six research modules, then replays the physical headlines with the kit's stock checker. Lean checks sixteen batches of 4,096 windows sequentially. The table itself can be regenerated by `python research/wheel/make_marker.py Rule30PrizeKit output.lean`. The sharp physical result has its own, smaller LRAT replay above.

The three public theorem modules passed 14 stock headlines with zero new axioms. The original checker JSON and sources are in `share-scratch/gptIntel/I156/wheel-lean.zip`, SHA-256 `b0d8d1a420903bc2ded5674fdc3fcc0f6c5f375858caa253d8061ca1ea14594f`. [Source hashes, theorem names and replay times](replay.json)
