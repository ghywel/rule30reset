# Run bounds in the trapped Rule 30 gate

Beside an alternating column, sample the adjacent cell every two ticks, starting at an odd tick when the right half's first sixteen cells are in the kit's trap. Write 3 and 5 for the numbers of samples between successive black cells. A closed run of four 5-gaps is bounded by a 3-gap on each side. Consecutive runs share their bounding gap.

| Gate word or witness | Physical right half | Kit ladder |
|---|---|---|
| `3 (55553)⁴`, 96 samples including both endpoints | Excluded from delay two onward | Excluded from delay two onward at every width from 45. For each width from 16 through 44 a path reads it at delay two. |
| `(55553)⁵`, 116 samples | Excluded from the trapped tick onward | Excluded from entry at every width from 45. The four-run word is its suffix starting at sample 20. |
| Four closed runs | A finite right half reads the word at delay one, with trap code 44920 at tick one | The width-44 witness for delay two extends to an infinite lift path. |
| Three closed runs | A finite right half reads the word at delay sixty, with trap code 40615 at tick one | |

## Physical proof

The [portal source](Rule30Submission.lean) is 110,633 bytes. Its SHA-256 is `5b3c97971d8ff64b414ad0c372232b2340075104f2b1914303167ed1a48fe2ff`. The four headline records agree with the [earlier M5 review](../data/claudeM5-m9-pin-check.json). The [M5 read of this source](../data/claudeM5-m9-compact-pin-check.json) covers the masks, two-bit lookahead, physical hypotheses and witnesses.

Each spatial prefix has a mask of possible sample times. The 829 trap windows carry time zero. Each allowed two-tick transition with the next required gate colour carries bit i to bit i+1. The union of the masks has no bit 97. The 98 frames span the two unrestricted starting samples and the 96-sample word. The [generator](build_masks.py) reproduces the 320 mask values and 9,350 internal nodes from the [sparse certificate](../data/trapped-runs-core.xz). Lean checks every bound and transfer on the embedded data.

## Exact ladder width

The kit permits independent exterior bits on each of the two ticks of a step. At width 45, pack the first exterior bit together with the current row. The first 44 output bits agree with the packed physical double step. With zero-based indices, the last cell is `mid[43] XOR (mid[44] OR exterior)`. The [boundary proof](TrappedRunBoundary.lean) reuses the physical transfer where the destination mask depends only on the first 44 bits. For deeper branches it verifies both values of the second exterior bit.

The [family module](Rule30TrappedRuns.lean) connects the exact rule to the kit's `LiftPath`. Its theorem `four_width_iff` covers every width W ≥ 16. Taking the first 45 cells carries the exclusion upward. Taking the first W cells of the positive width-44 path supplies a witness at every smaller trap width. The sharp-width assertion concerns the four-run word.

The [negative control](BoundaryControl.lean) checks the last-cell distinction independently in Lean. On input `15077656946332` a freely forced zero output would lose time 46 despite matching the first 44 output bits and the gate colour. Both physical exterior choices force a one in that cell and preserve the time bit.

## Reproduce the private kit patch

Stage the modules in a disposable checkout of kit commit `ac88b68cccd28d7ff3b1ee19e711f4d0c999cc26`. The staged catalogue has one family module and one certificate-data module. The date, credits and submission link in its catalogue row are placeholders for publication.

```powershell
py research/m9/compact/stage_kit.py C:/path/to/kit
Push-Location C:/path/to/kit/lean
lake build Ruliology
lake env lean --run ../Check.lean Ruliology.CellularAutomata.Rule30Certificates.TrappedRunMasks --claim partial --headline Ruliology.CellularAutomata.Rule30TrappedRunBoundary.no_frames45
lake env lean --run ../Check.lean Ruliology.CellularAutomata.Rule30TrappedRuns --claim partial --headline Ruliology.CellularAutomata.Rule30TrappedLiftRuns.four_width_iff
Pop-Location
```

| Clean changed modules, Lean 4.35.0 | Build | Stock kernel replay | Constants replayed |
|---|---:|---:|---:|
| Physical source, portal pin, Intel | 47.461 s | 47.728 s | 244 |
| Physical source, portal pin, M5 | 15.3 s | 15.0 s | 244 |
| Physical source, kit main, Intel | 44.905 s | 42.640 s | 244 |
| Kit certificate including the width-45 boundary, Intel | 44.009 s | 42.198 s | 211 |
| Kit family and all eight headlines, Intel | 8.384 s | 11.753 s | 138 |

The kit certificate's peak working sets were 2,749,509,632 bytes in the build and 3,400,638,464 bytes in replay. The checker reported zero new axioms in both kit modules. The physical source produced identical stock JSON on the portal pin and on this kit revision. The raw pinned output and kit measurements are in the [portal receipt](check-pin.json) and [kit receipt](checks.json).

The full staged catalogue built in 68.666 seconds, with all 315 Lake jobs successful and upstream cache reuse. The private patch is 134,751 bytes with SHA-256 `108ba8036e89ffeec619a53b047980680ffe498588482db7802246e5facb5f5d`.
