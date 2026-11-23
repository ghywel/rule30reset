# A complete 48-sample observer for the period-two gate trap

Watch column 1 whenever its alternating neighbour at column 0 is white. Write 1 for black and 0 for white. If **48 consecutive readings** contain none of the five words below, then the final 16-cell spatial window belongs to the kit’s gate trap. Every right half that enters the trap eventually passes this test. It applies to any eastern continuation and requires no measurements beyond column 1.

| Forbidden word | What it would show |
|---|---|
| `00000` | Five consecutive white gate samples |
| `11`, `101`, `10001` | Consecutive black pulses one, two or four samples apart |
| `1001001` | Two successive three-gaps |

The test recognizes the trap in which the 17/56 wheel runs. A positive observation certifies the hidden state at its endpoint. The wheel can already have slipped into another phase, or the trapped gate can have another admissible rhythm. On the physical clock 48 samples span 94 updates. The project’s signed-kick predictor reads different information and answers when the phase will change. [Streaming observer](trap_observer.py) · [Signed-kick predictor](kick-predictor.md)

## Why 47 readings cannot do the job

These two finite rows produce the same 47 readings. In hexadecimal, site 1 is the low bit and all higher unlisted sites are white. The initial wall is black.

| Finite starting row | Beginning of the comparison | Actual trap membership |
|---|---|---|
| `0xa224d3200017fb5ccd115f23a59` | First white sample | Outside at the last sample, code 362 |
| `0x4319fc9fcd612848b70077729985e4b9` | Ten white sample intervals after the first | Inside from the first white sample onward |

Their common word is `00001001000010010000100001000010000100100001000`. Every classifier given just these 47 bits must give the same answer on both runs. Shorter suffixes inherit the ambiguity. Thus 48 is the least fixed window length that can accept every mature inside window and reject every outside endpoint, regardless of how the classifier is designed. Maturity here means that the window starts at least ten white samples after entry. The classifier uses only the window, without a reset time, seed or older observations. [Kernel-checked physical pair and lower bound](WheelObserverLowerBound.lean) · [Independent row replay](observer_controls.py).

Of all 674 clean 47-bit strings, this is the only one that can end outside. Any of the other 673 certifies trap membership if observed. Ten short forcing words prove this, including three fragments of the original wheel. The optional 47-sample detector accepts clean windows other than this exception. Its sharp worst-case first confirmation is 52 white intervals after entry (104 physical ticks), against 53 for the fixed 48-sample filter. [Factor proof and witnesses](word_cover.md) · [Stock receipt](word_cover_stock.json).

## Why 48 suffice, and how quickly the test fires

Assume a block is clean and the last window is outside. A physical light cone for its last 16 cells has 110 initially relevant sites and 94 updates. Two encodings gave contradictions. The first encodes the update directly and excludes the trap at each sample, using its closure. The second factors OR and XOR separately and imposes trap exclusion at the endpoint alone. Both LRAT proofs passed lrat-check and cake_lpr. The 47-bit exterior witness also has a physical black-first predecessor. [Encoder](complete_observer.py) · [Hashes and witness](data/complete-observer.json).

For the other direction the kit proves gap sizes three or five, black coverage in every five samples, and the eventual exclusion of two consecutive threes. Ten samples after entry these imply that all subsequent blocks are clean. The sharp settling bound is **six**. At an entry only `1001001` can still occur. The finite trap graph has 6 possible starting windows for that pattern, and its successive sets of predecessors within the trap have 4, 4, 3, 2, 1 and finally 0 members. A physical black-first seed `0x7fffff80fc` realizes the last possible start, offset 5. Therefore a detector supplied data beginning at entry fires by offset **53 white samples**, or 106 physical ticks, and this delay is attained. [Finite physical control](data/observer-controls.json) · [Kit gap theorem](https://github.com/WolframInstitute/Rule30PrizeKit/blob/f41bb494d64f120e0e6f07ab68d799a6018396cc/lean/Ruliology/CellularAutomata/Rule30GateTrapWords.lean).

The compactness issue in turning the positive result into a kit proof is the eastern input of a strip. An unrestricted 16-column strip can stay outside and pass this filter for ever. A direct 22-column strip dies by 61 samples. On the full 48-layer interval, keeping both possible pasts and possible futures while lifting one spatial column at a time also gives a finite cut. The [transport proof](WheelObserverTransport.lean) reduces arbitrary physical rows at any white sample to a check of a concrete finite graph. [Independent strip computation](observer_strip.py) · [Gate-only implications in Lean](WheelGateObserver.lean).

Two independent stock Lean proofs establish the positive 48-sample implication. One checks every surviving state in a bidirectional strip lift ending at width 30. The other shows that every clean 48-sample string contains one of nine shorter words, any one of which forces the trap. Both transport their checks to every physical right half. [Direct kernel proof](observer-bilift.md) · [Four physical headlines](data/observer-exact-stock.json) · [Nine-factor proof](word_cover_nine.lean).

## What this changes for the prize

The right-half dichotomy RD in the kit asserts that every finite driven right half enters the trap or has an eventually periodic gate. It is now equivalent to a statement about one observable bit: **every finite driven right half with an aperiodic gate eventually produces one clean 48-sample block.** An outside trajectory must display at least one of the five defects in every such block. The remaining step is to use finite support to force a clean block or periodicity. The large variable components X and Y of K78 have survived the tested widths. If an aperiodic gate stays outside indefinitely, the single pattern `101` must eventually occur in every 43-sample block. [Exterior recurrence and its five-site spatial cause](exterior-defects.md). The kit also needs its separate left-side hypothesis Q01Gap (or its gap-word version) to deduce CQ01 this way. [Kit reduction](https://github.com/WolframInstitute/Rule30PrizeKit/blob/f41bb494d64f120e0e6f07ab68d799a6018396cc/lean/Ruliology/CellularAutomata/Rule30PeriodTwoWidth13.lean) · [Finite singleton deadline](exterior-budget.md).

## Reproduce

```text
python research/wheel/trap_observer.py 00001001000010010000100001000010000100100001000
python research/wheel/trap_observer.py 00001001000010010000100001000010000100100001000 --adaptive
python research/wheel/complete_observer.py Rule30PrizeKit --certify observer48
python research/wheel/observer_controls.py Rule30PrizeKit observer-controls.json
python research/wheel/observer_strip.py Rule30PrizeKit 16 22
```

The first two commands leave this exceptional 47-bit input undecided. The remaining commands require the project’s research Python environment. The two proof pairs are in `share-scratch/gptIntel/I172/observer48.zip`, 10,875,511 bytes, SHA-256 `e6bbe101a81840b5938c9db6aef480627fbf7656a92f137f6536b9050a9cd87a`. The certificates and witnesses use the kit at `f41bb49`.
