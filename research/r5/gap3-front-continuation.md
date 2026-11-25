# R5 after S21

**Parked, 25 November 2026 (R125).** S21 is Human Verified and in the kit. It proves that the finite-half entry slope of three is optimal beside both primitive period-three drives. I244’s companion proves that neither constant gate beside `011` can persist on a finite right half. The remaining question is whether a nonconstant periodic gate can persist or be forced by a finite-width trap. [S21 kit merge](https://github.com/WolframInstitute/Rule30PrizeKit/pull/425) · [I244 proof and strip results](periodic-gate-011.md)

## Pure gap 3

The gate repeats `011` on the white ticks of the imposed wall `011`. Its masked sideways reconstruction has a 14-column transient and a far-west background of spatial period 135 and temporal period 9. The front is the leftmost disagreement with that background. Each state records the time phase, the position of that disagreement and whether the next bit also disagrees.

The finite-cone test splits a candidate transition into three, six or nine ticks. Each retained edge has one physical cone realising its two endpoint states. A path in the resulting graph may combine edges from different initial rows.

| Physical ticks per edge | Candidate endpoint edges | Edges with a physical cone | One cone for the selected graph cycle |
|---:|---:|---:|---|
| 3 | 15,354 | 11,205 | 27 ticks replay. The fourth turn at 36 ticks is impossible, as in I244. |
| 6 | 42,786 | 19,485 | A new local cycle fails at 18 ticks, its first full turn. |
| 9 | 83,970 | 28,026 | A phase-zero return at site 3 replays for all eight turns tested, through 72 ticks. |

Both LRAT checkers accepted the 36- and 18-tick obstructions. Those obstructions concern the selected cycles. The nine-tick result confirms that longer cones alone still leave bounded position paths. The 50-step calculation on endpoint graphs gives no uniform leftward displacement bound.

## A finite half holds the front for over a thousand ticks

The nine-tick witness starts `1100` followed by black. Starting with a wholly black eastern tail gives `00111` followed by white after the first tick. Start with that five-site seed at phase 1 beside the reconstructed wall `111011110`. Literal and bit-packed evolutions agree on these first failures, measured from the phase-zero start.

| Property | First failure at a physical tick |
|---|---:|
| Full phase-specific front schedule | 1144 |
| Front return sampled only at phase zero | 1152 |
| Agreement at the white ticks of the reconstructed wall | 1160 |

At tick 1144 the front is still at site 3, with the next bit now agreeing. A phase-zero front is at site 1 at tick 1152. At tick 1160 the first eastern bit changes on a white wall phase. Until that last failure the reconstructed wall can be an interior column because the right input matters only on its white ticks. Testing all local eastern inputs at each tick for widths 4 through 30 found a path that breaks the front schedule from the seed prefix at every width. At width 30 the first such path takes 63 steps.

This is a stall beside a reconstructed nine-tick wall. The target is the wall `011011011` with successive white readings `011`, and its 14-column transient must also be realised. The witness has no indefinite seam even at its own wall. The nine-tick survival forecast held, while the 72-tick failure, 10,000-tick persistence and width-30 closure forecasts failed.

**Reopen** for an invariant that controls front motion through the actual 14-column seam for every finite right half, or for a repeatable physical construction that crosses that seam and preserves a nonconstant periodic gate on the original `011` wall. A new result on the whole class of gates would also reopen it.

## Replay

Run from the repository root with python-sat installed.

```sh
python3 research/r5/gptM5-gap3-front.py /tmp/r5-gap3-replay 3 6 9
python3 research/r5/gptM5-gap3-seam.py
```

The replay archive `share-scratch/gptM5/R5/r5-gap3-R125.zip` contains the checked instances and proofs, selected cycles, witnesses and logs. SHA-256 `6990ee911c36db47de1f43241d12804d7e83e8f0ae075af671424cbf75ac85b8`. To replay either obstruction, pass the corresponding `.cnf` and `.lrat` to `lrat-check` and `cake_lpr`.
