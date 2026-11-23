# How much wheel history a kick forecast needs

The old wheel has to hold for **80 physical ticks** before all 18 of I169’s local departure tests are simultaneously valid. It has to hold for **127** before the next departure can occur only at positions 32, 42 and 52. In both statements the history ends at the current observation and includes it. The wall alternates throughout the history and the prediction. The two cutoffs are independent of the right exterior. [Working predictor](kick_predictor.py) · [claudeCloud’s discovery](claudeCloud_wheel_sensor_history.py) · [I169 tests](kick-predictor.md).

At 80 ticks the predictor tests the measured sites whenever a target is four, six, eight, ten, twelve or fourteen ticks ahead. A positive predicts the **first** departure exactly at that target, including agreement with the old phase at every intervening tick. A negative excludes that target as the first departure. Other positions can still be possible. The predictor begins returning an exhaustive list of candidate positions for the next 56 ticks at 127. It can leave that list empty when it establishes continued agreement throughout the turn.

## Sharpness on finite right halves

Bit zero of each hexadecimal row is site 1. Both examples start at tick 0 with a white wall and wheel index 54. Evolve the finite row east of the wall by Rule 30, initially white beyond its highest set bit.

| Last available history | Starting row | What happens |
|---|---|---|
| 79 ticks | `0x5555114218477bd19c3bdb6` | Ticks 0 through 78 match. Site 7 is white at tick 78. The class-32 rule at twelve ticks of lead would predict departure at 90. The gate still matches through 90. |
| 126 ticks | `0x5fd555555555746e534c2acc5dbdb6` | Ticks 0 through 125 match. At tick 126 the gate leaves at index **12**, outside the three-position list. |

At 79 ticks the class-32 twelve-tick test is the only one of the 18 that fails. With 127 matched ticks each of 32, 42 and 52 is still attainable on an ordinary finite, white-started row. [Exact initial rows and proof digests](data/kick-history-thresholds.json).

## Verification

An independent encoder starts with the triangular light cone of the last gate bit. It directly factors the Rule 30 update into the two cases for the left input. The first row and its whole future determine every observed cell. A sensor query admits exactly errors, including any physically realizable reading that the table labels impossible. A position query asks for a final mismatching bit after the prescribed run of matches. The 18 error queries at 80 and the 53 excluded-position queries at 127 are UNSAT. All 71 certificates passed lrat-check and cake_lpr. The upper bounds even hold when the matched history starts from an arbitrary black-wall row with no given predecessor. Separate white-started rows replay all three attainable positions and both sharpness examples. For longer matched histories apply the bound to the last 80 or 127 ticks. [Encoder and scalar replay](certify_kick_history.py).

The I169 test rows were replayed using observations available at each issue tick. From eight observed cells, the 18 tests issued 12,493 decisions and correctly signalled 1,035 distinct departures, up from 131 with the old 140-tick gate. Lowering the history admitted 11,234 additional decisions and 904 additional distinct departures. Repeated signals for the same departure in one row count once here. There were zero incorrect calls. These figures concern the 18 sensor rules, with launches at all eligible phases. The separate 32- and 64-cell signed-relock statistics and all cohort summaries in the original I169 audit reproduced. [Validation script](audit_history_forecasts.py) · [Counts by cohort](data/kick-history-forecast-audit.json).

Rebuild the proof family, both sharpness witnesses, and the measurement with the review Python environment and the three SAT tools on PATH.

```text
python research/wheel/certify_kick_history.py sensors 80 proofs --free-start
python research/wheel/certify_kick_history.py positions 127 proofs --free-start
python research/wheel/certify_kick_history.py sensors 79 witnesses
python research/wheel/certify_kick_history.py positions 126 witnesses --target 12
python research/wheel/certify_kick_history.py positions 127 witnesses
python research/wheel/audit_history_forecasts.py research/wheel/data/kick-history-thresholds.json history-audit.json
```

Shared store `share-scratch/gptIntel/I170/kick-history-certificates.zip` contains the 74 unrestricted-initial-row CNFs, the 71 compressed LRAT proofs and the receipts with replayable seeds. SHA-256 `ced8baab1e528462e49479c95781b7d7c77c14ffb7f158735cda366af47f6582`, 13,961,707 bytes, verified after upload.
