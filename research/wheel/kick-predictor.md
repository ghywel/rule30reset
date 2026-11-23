# Where a kick reaches the 17/56 wheel

**At a black pulse beside a white wall, look four cells farther right.** In the kit's closed trap, the colour of site 5 now is the colour site 1 will show six physical ticks later. The old wheel phase specifies which colour it expects. If site 5 disagrees, the wheel will first leave that phase exactly six ticks from now. No knowledge of the farther right half is needed for this decision. The rule also works outside the trap whenever the first four positive cells read `1110`. [Lean proof](WheelKickRelay.lean) · [Working predictor](kick_predictor.py).

The wall is site 0, white at even ticks. The wheel is read at site 1. A *pulse* is a black reading at a white-wall tick. A *departure* is the first bit disagreeing with the established wheel phase. The Vitruvian display counts a *kick* when site 1 takes up a different even phase and sustains it for 56 ticks. A departure and the next kick can have different timestamps. The display looks 55 ticks ahead to recognize a new lock at its first tick. All forecasts below use data available when issued. [Original display](https://www.wolframcollatzmahler.com/rule30/vitruvian.html).

## From a pulse to the next two returns

Read site 1 at a white centre tick. If it is black, from the second white tick of the alternating run the pair **(site 2, site 5)** gives the exact next black pulse. The four readings 00, 01, 10 and 11 give physical delays **8, 4, 10 and 6 ticks**, respectively. The same rule applies before wheel lock, inside the trap and outside it. If the clock has only reached its first white tick, sites 2 through 5 still determine that first return.

Inside the trap, read sites **7, 8 and 9 now**. The *second* gap is six physical ticks precisely when site 9 is black and either site 7 is black or site 8 is white. Otherwise the second gap is ten ticks. With site 5 as well, this dates both returns and determines the intervening physical readings. On a known phase, compare those readings with the expected wheel bits to date the first departure. The signed phase reached after that departure can still vary. [Two-return proof and comparison](pulse-forecast.md) · [Exact first-return proof](WheelPulsePredictor.lean).

The pulse tool accepts unmeasured sites as `?`. Site 1 comes first in the argument. Sample index zero is the first white reading. The first example predicts a pulse in ten ticks. The second predicts a pulse in ten ticks, another six ticks later, and gives 22 consecutive gate readings starting at the present tick.

```text
python research/wheel/pulse_predictor.py "11??0" --white-sample 1
python research/wheel/pulse_predictor.py "11100??01" --white-sample 1 --trapped
```

## The six-tick signal

At a white-wall tick t suppose sites 1 through 4 are black, black, black, white. Write b for site 5. In the following table every marked bit is determined for every eastern continuation.

| Tick | Carrying site | Bit at that site | Site 1 |
|---|---:|---|---|
| t | 5 | b | black |
| t+1 | 4 | complement of b | black |
| t+2 | 3 | complement of b | white |
| t+3 | 4 | b | black |
| t+4 | 3 | complement of b | white |
| t+5 | 2 | complement of b | white |
| t+6 | 1 | b | b |

This relay follows directly from Rule 30, including the intermediate step back to site 4. Flipping site 5 alone reverses the final bit in every seven-cell completion of `1110`, leaving all six preceding gate readings intact. All 188 pulse windows in the 829-window trap begin with these four cells. Of the 188 different windows, 41 select the short gap. These are counts of states. The frequency on a physical run depends on which states it visits. Of sites 1 through 7, only site 5 alone determines the branch on the whole trap. [Scalar exhaustive control](audit_kick_predictor.py) · [Stock Lean theorem](WheelKickRelay.lean).

The wheel's white-wall pulse indices in its 56-bit word are 6, 16, 26, 36, 46 and 52. Only the pulse at **46** expects black six ticks later. At any other pulse a black site 5 brings the next pulse forward. At 46 a white site 5 suppresses the expected pulse. In the trap these choices set the next pulse at **t+6 or t+10**, respectively for a black or a white site 5. The first disagreement is at t+6 in either direction of error. [Two physical pulse tiles](WheelTiles.lean).

## Fourteen ticks of advance notice on an established wheel

**Updated after K77.** The sensor rules below apply after **80** matched ticks. The exhaustive three-position list applies after **127**. Both cutoffs are sharp for their respective claims. The original 140-tick experiment and its scores follow. [Shorter histories and physical counterexamples](kick-history.md).

Suppose the 140 physical ticks **through the issue tick** already matched the same wheel phase. The October work excluded all first-departure positions except 32, 42 and 52 on the old 56-tick word. Its departure signatures identified characteristic cells four and ten ticks upstream. To ask what predicts an event, we also need the observations when the wheel continues, and must include the possibility of a departure at an intervening tick. [October phase and precursor certificates, §8.107](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/rule30-prize/RULE30-PRIZE-8.3.md#8107-s8-certified-the-kicks-local-alphabet-four-and-ten-rows-back-2026-10-14-1803-bst-cloud).

Fourteen ticks before one of those positions, the following tests are **necessary and sufficient for the first departure to occur at that target tick**. A false test rules out that target as the first departure. Some other target may still fire.

| Target index in the old word | Notch on the 17/56 drawing | Exact test on the current row, 14 ticks earlier |
|---:|---:|---|
| 32 | 40 | Site 7 is black. |
| 42 | 42 | Site 7 is black. |
| 52 | 44 | Site 3 is black and site 7 is white. |

The notch is `17 × index mod 56`. At ten ticks of lead the test is even simpler. For targets 32 and 42, site 5 must be black. For 52 it must be white. When only the old phase is available, 32, 42 and 52 give three possible departure times on the next turn, spaced 10, 10 and then 36 ticks around the circle. Several turns can pass without a departure. The archive separately bars an **immediate** class-42 phase change after 560 uninterrupted ticks on the old phase when the proposed new phase lasts at least 21 readings. [All 18 sensor rules](data/kick-sensors.json) · [October 560-tick exclusion](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/lexicon/rule30_kick_class42_560.py).

There is a direct connection to the particle in the October domain study. Its most frequent observed shape first showed a defect at site 5 **eight ticks before** it reached site 1. The eight-tick rules test exactly that cell at exactly that time. Once the old phase has lasted 140 ticks, black there selects a departure at index 32 or 42 when that is the upcoming target, and white selects one at index 52. The same tests identify continuations at those positions. The domain study also found several less frequent shapes. This test needs only the colour and the old phase. [Observed particle and its shape, §8.7](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/rule30-prize/RULE30-PRIZE-8.1.md#87-a-slip-is-one-particle-2026-10-05) · [Eight-tick tests](data/kick-sensors.json).

**Verification.** Start with every one of the 65,536 possible width-16 windows. Match the past gate, allowing a fresh eastern input on every update. For leads up to 14 the true future gate depends only on cells inside the current window. Label a state positive only if it stays on the old phase at every intervening tick and departs at the target. Search fixed subsets of the causal sites for labels separating every positive from every negative. Every real right half projects to this graph. A second program independently encoded the full strip in CNF and asked for any incorrect prediction, with all past and future updates included. Both lrat-check and CakeML's cake_lpr verified the 18 two-way results and the 10 sufficiency implications for October's earlier markers. Its physical necessity proofs provide the other direction for those earlier markers. State counts or nonphysical paths in the window model are not estimates of prevalence. [Window computation](kick_sensor_windows.py) · [Independent CNF](certify_kick_sensors.py).

## Which phase the wheel takes up

For an established phase, enter the measured positive-site prefix at a single tick. The predictor evolves known black, known white and unknown cells. Rule 30's OR can establish a value when one of its inputs is still unknown. This often certifies a longer trace than the simple one-cell-per-tick cone estimate. The predictor stops its common trace at the first undetermined gate bit. It reports the first signed change only when the necessary 56-bit confirmation and the display's intervening phase decisions all follow from the known trace. A blank kick forecast leaves the sign and time undetermined. [Predictor](kick_predictor.py).

For example, in a physical 24-cell seed generated by the display's random-number generator, the following call uses only the prefix at tick 274 and the established phase offset 24. It predicts departure at 280 **and a +4 kick at 280**, into phase offset 40. All 32-bit prefix completions give that result.

```text
python research/wheel/kick_predictor.py 11101001101000100000011010110110 --tick 274 --phase 24
```

If you know only the first five cells, `11101` at that same tick still certifies the departure at 280. Supply the observed run length with `--matched-ticks` to enable the sensors at 80 ticks and the candidate positions at 127. Alternatively, `--history` accepts the site-one history from physical tick zero and computes the confirmed phase and its age from the past. [Recorded inputs and outcomes](data/kick-delivery.json).

**A controlled cause of the signed size.** At tick 274 of that same physical row, flip only site **25**. Both rows have a black site 5 and leave the old phase at tick 280. The wheel relocks immediately in both experiments. The single flip changes the kick from **+4 to +3**. A separate pair of unmodified finite seeds shares **the first 25 spatial cells**, the old relative phase and the selector, yet gives immediate kicks of −6 and −4. Another pair agrees on **203 consecutive gate readings** in the same relative phase, then takes opposite six-tick decisions. [Complete intervention row and physical witnesses](data/kick-delivery.json) · [203-tick pair](data/kick-forecast-audit.json).

## Prospective validation

The held-out data comprise 32 independent width-24 finite seeds (1000–1031 with the display's generator) and 32 rows with a random far field covering the full measured light cone (2000–2031). Scoring covers ticks 140–3071 in each run. The outcome reader independently implements the display's phase search. A forecast is issued at a visible pulse only after the earlier display state and 56 **already observed** bits establish the current phase. Future bits enter only the score. The exact bounds apply whenever their hypotheses hold. The coverage figures also reflect those issue conditions and the 160-tick prefix forecast horizon.

| Positive cells observed | Distinct signed kicks called / 2,099 displayed | False calls | Median best advance per called kick | Largest advance |
|---:|---:|---:|---:|---:|
| 8 | 0 | 0 | — | — |
| 16 | 28 | 0 | 6 ticks | 6 ticks |
| 32 | 1,331 | 0 | 16 ticks | 46 ticks |
| 64 | 1,455 | 0 | 26 ticks | 102 ticks |

The six-tick relay separately called 1,456 of the 2,101 display **departures**, with 5,401 eligible pulse decisions and zero false alarms. The older four-tick marker picked all 1,644 positive cases from 8,458 phase-matched opportunities. The older ten-tick marker picked all 57 positives from its 84 mature class-52 opportunities. Among the mature class-42 opportunities in this sample there were no positive 14-tick calls. The 287-tick planted wheel from M106 produced 31 eligible pulse decisions and zero false alarms. The October 84-ring produced zero display kicks in 512 ticks despite a black pulse every third white sample. [Results and launch records](data/kick-forecast-audit.json) · [Independent display and controls](audit_kick_predictor.py).

For a positive class-42 control, start a white wall with the finite right row `0xd53fffeffff7ffffc009eb4b069bdfdf1df664`, positive site 1 in the low bit. The gate matches phase 0 from ticks 0 through 153. Site 7 is black at tick 140, and the gate departs at 154, wheel index 42. A physical light-cone SAT model supplied the row. [Direct replay](kick_delivery.py).

The earlier domain-filter study observed a defect moving inward from the irregular interior. Several signed jumps shared the most common local shape. The earlier right-edge-ruler intervention found that changing the far field can change individual trajectories, while removing the finite right edge produced similar aggregate kick rates and no detected dyadic rhythm. The present results identify an exact local relay, several longer-lead signals, and one specific farther-east cause of a change in signed size. The upstream origin of every such bit across all trajectories remains open. In the actual single-seed prize problem the wall is supplied by the evolution itself. These forecasts apply on a stretch where its centre supplies the alternating boundary for the required physical ticks. [October domain study, §8.7](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/reports/rule30-prize/RULE30-PRIZE-8.1.md#87-a-slip-is-one-particle-2026-10-05) · [Right-edge-ruler controls](https://github.com/ghywel/placego/blob/a5ed5e4d595845b7fb50b6fd76da80a41e6f4981/archived/tests/probes/lexicon/rule30_cloud_ruler_kicks.py).

## Reproduction

The predictor itself uses only Python's standard library and the adjacent sensor table. The audits use NumPy and python-sat. The proof-producing command also needs CaDiCaL, lrat-check and cake_lpr. Use kit `b686c1d2547d27c4451f5691861a63f3cc4caf9f` and Lean 4.35.0.

```text
python research/wheel/kick_sensor_windows.py sensor-table.json
python research/wheel/certify_kick_sensors.py sensor-table.json sensor-proofs
python research/wheel/audit_kick_predictor.py Rule30PrizeKit forecast-audit.json
python research/wheel/kick_delivery.py delivery.json
python research/wheel/replay.py Rule30PrizeKit kick-lean --kick
```

The three relay headlines pass the kit's stock checker with 12 constants and zero new axioms. The separate 28-proof packet contains the DIMACS inputs, compressed LRAT proofs, checker and model receipts, and the held-out results. Shared store `share-scratch/gptIntel/I169/wheel-kick-predictor.zip`, 2,878,172 bytes, SHA-256 `bae955bb58cd601766860701d349d49cc935dbe513d02c273c4c13735180d36d`. The relay is kernel-checked. The 14-tick equivalences have independent SAT certificates. A different worker's carrying read is pending.
