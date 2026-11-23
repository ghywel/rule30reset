# The sole ambiguous clean 47-sample observation

There are 674 binary strings of length 47 avoiding `00000`, `11`, `101`, `10001` and `1001001`. Under the physical alternating wall, an observed one certifies that the 16-cell window at its endpoint lies in the trap, with exactly one exception. The exceptional string occurs both outside and deep inside the trap.

```text
00001001000010010000100001000010000100100001000
```

The finite black-first seed `0xa224d3200017fb5ccd115f23a59` reads it at samples 0–46 and ends outside. The finite seed `0x4319fc9fcd612848b70077729985e4b9` enters at sample 0 and reads the same string at samples 10–56. The low bit is site 1. The interior window is mature by both the six- and ten-sample conventions. The remaining 673 strings certify entry whenever observed. Physical realizability of each of those strings is a separate question. [Finite pair](word_cover_claims.lean) · [Physical theorem](word_cover_verified.lean)

The rolling rule “47 clean readings different from the exceptional one” confirms entry within **52 white intervals**, or 104 physical updates, when observations begin at entry. At least one of the windows ending at offsets 51 and 52 passes. The window starting at 6 is clean. If it reads the exception, its first four samples are zero, so the five-sample black coverage forces a black at offset 5. No forbidden factor can then start at 5. The window starting there is clean and begins with a black, which distinguishes it from the exception. The finite row `0x7fffff80fc` attains 52 because its factor `1001001` at offset 5 spoils all earlier complete windows. The 48-sample five-word filter has sharp delay 53 on the same row. [Sharp adaptive deadline](word_cover_adaptive.lean) · [48-sample deadline](WheelObserverCleanup.lean)

## How the wheel enters the proof

Every one of the 755 clean strings of length 48 contains at least one of the nine factors marked “48” below. Every clean string of length 47 other than the exception contains one of the ten. Each factor forces physical trap membership at its own endpoint, and the trap is closed. Three of the factors are the previously measured fragments of the 17/56 kicked wheel. Adding the phase-21 fragment to the nine is enough to distinguish the remaining 47-sample ambiguity. The binary strings below run forward in time. [Finite language proof](word_cover_language.lean) · [Earlier wheel fragments](claudeCloud_wheel_runs.py)

| ID | Samples | Readings | First empty strip width | Cover |
|---:|---:|---|---:|---|
| 0 | 20 | `10000100100001001000` | 18 | 47 and 48 |
| 1 | 23 | `01000010000100100001001` | 19 | 47 and 48 |
| 3 | 26 | `01000010010000100001001000` | 18 | 47 and 48 |
| 5 | 29 | `00100100001000010000100001000` | 23 | 47, wheel phase 21 |
| 6 | 29 | `10000100001000010000100001001` | 23 | 47 and 48, wheel phase 26 |
| 7 | 30 | `000100001001000010000100001001` | 16 | 47 and 48 |
| 9 | 30 | `100100001001000010000100001001` | 16 | 47 and 48 |
| 10 | 31 | `0001000010000100001000010000100` | 23 | 47 and 48 |
| 11 | 33 | `010000100001001000010000100001000` | 23 | 47 and 48, wheel phase 12 |
| 13 | 38 | `00100100001000010000100001001000010000` | 32 | 47 and 48 |

The width is the first empty layer of the stated forward/backward lift. The lift includes all four eastern continuations of the double update. The hypotheses place no bound on the support of the initial right half. A lookup in the 829-code trap is equivalent to one bit test in a kernel-checked table. The width checkpoints are computed during elaboration and verified independently by kernel reduction. [Physical realization](word_cover_transport.lean) · [Trap-table equivalence](word_cover_fast.lean) · [Checkpoint generation](word_cover_macro.lean)

## What the minimum counts mean

The discovery search considered fully specified, contiguous binary factors of the clean 48-sample strings. The discovery cone allows any spatial row at its first white tick. In this convention a factor forces entry if no run reading it can end outside. The cone tests found 16 factor-minimal forcing strings, meaning that no proper factor of each one forces entry. The search checked 1,223 SAT queries in addition to free-boundary width-16 exclusions. Each satisfying white-time row was independently stepped and its observed bits and final exterior code checked. The explicit exceptional pair above also has black-first predecessors. [Generator](word_cover.py) · [Results](word_cover_results.json)

Among these 16 candidates, the minimum cover of the 755 clean 48-sample strings uses nine factors. The minimum cover of the 673 clean 47-sample strings other than the exceptional word uses ten. There are two minimum choices in each case, interchanging IDs 4 and 9. The index records example strings whose only matching candidate is each of IDs 0, 1, 3, 6, 7, 10, 11 and 13, plus a string whose matching set is exactly {4, 9}. For length 47 an additional string has only candidate 5. These disjoint requirements explain the two minima. The counts concern covers by specified factors. Rules that also use wildcards, endpoint positions or a known earlier state have other inputs. [Witness strings and candidate list](word_cover_results.json)

## Replay

With the Rule30PrizeKit checkout at `f41bb494d64f120e0e6f07ab68d799a6018396cc` and its Lean 4.35.0 toolchain, run the following from the research repository. The first command builds the imports, the cover, and the kernel receipts. The optional second command regenerates the factor-minimal search and its positive finite-row checks. It uses NumPy and python-sat.

```text
python research/wheel/word_cover_replay.py Rule30PrizeKit word-cover-build
rule30-python research/wheel/word_cover.py Rule30PrizeKit word-cover-results.json --physical
```

The stock checker passed 27 headlines in twelve modules, replayed 727 constants and reported zero new axioms. The individual stock checks sum to 680.518 seconds on the Intel host. The proof has 61,547 bytes of new Lean source. Its two language-tree computations use the five forbidden factors and the selected markers directly. The numerical lift of every marker is over-approximating, with every intermediate checkpoint checked as a theorem. [Replay script](word_cover_replay.py) · [Stock receipt](word_cover_stock.json)
