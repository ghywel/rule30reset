# M9's trapped-gate run bounds

[Rule30Submission.lean](Rule30Submission.lean) proves the four physical statements with Lean 4.35.0. Its only project imports come from the official kit. It constructs its finite tables during elaboration and the kernel checks the transfers that use them. The single source is 48,632 bytes, with SHA-256 `01d05d6aa7e7760501f270badf016869f417de3cbca887e5974df7f267b459b1`.

Read the gate of an arbitrary right half beside the alternating column. One sample is two physical ticks. A closed run of four is bounded by gaps of 3 and contains four gaps of 5.

| Headline | Statement |
|---|---|
| `no_four_runs_of_four` | From two samples after an odd trapped tick onward, the gate excludes the gap word `3 (55553)⁴`. |
| `no_five_runs_of_four` | From the trapped tick onward, the gate excludes `(55553)⁵`. |
| `four_one_sample` | A physical right half reads four closed runs one sample after a trapped tick. |
| `three_sixty_samples` | A physical right half reads three closed runs sixty samples after a trapped tick. |

The checker starts with the 829 possible low 16-bit trap windows at each sample. It imposes the whole word, including the white cells, and removes prefixes missing a predecessor or successor. Where the remaining set is small it admits both values of the next spatial bit and refines again. A physical occurrence must survive every one of the 30 rounds. The final round empties a sample. The five-block exclusion follows by taking the suffix starting at sample 20.

## Stock verification

In a disposable checkout of the official kit at the portal pin, put this source at the root as `Rule30Submission.lean` and run the following commands.

```powershell
lake build Rule30Submission
lake env lean --run Check.lean Rule30Submission --claim partial --headline Rule30Submission.no_four_runs_of_four --headline Rule30Submission.no_five_runs_of_four --headline Rule30Submission.four_one_sample --headline Rule30Submission.three_sixty_samples
```

The single file built from source in 848.4 seconds on the Windows Intel host at portal pin `5fb59158`. The stock checker replayed all 8,495 declarations there in 673.2 seconds, and replayed the same compiled file against freshly built kit-main imports at `ac88b68c` in 719.0 seconds. Both runs passed all four headlines and reported zero new axioms. The public compiled object is 25,174,280 bytes. The catalogue asks that one family's data module build in under a minute and 4 GB. Build time remains the obstacle to requesting ordinary catalogue inclusion. [Check receipts](checks.json) · [Catalogue rule](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ac88b68cccd28d7ff3b1ee19e711f4d0c999cc26/lean/README.md#certificate-data) · [Original issue](https://github.com/WolframInstitute/Rule30PrizeKit/issues/380)

## Standalone certificate

The [sparse certificate](../data/trapped-runs-core.xz) contains 28,573 exclusions of a particular spatial prefix at a particular sample. Each record follows from previous records and the known trap and word. The three allowed arguments enumerate the possible next prefixes, enumerate the previous prefixes, or exclude both one-bit extensions. The last records account for every possible middle trap code. The raw records occupy 342,880 bytes and compress to 74,336 bytes. The original binary LRAT occupied 45,546,893 bytes and compresses to 14,510,620 bytes with the same XZ preset. The reductions are 133-fold raw and 195-fold with matched compression.

From the research repository root, replay the certificate with standard-library Python. The measured run took 4.25 seconds. The reader rejected the delay-1 control and a stream missing its final record.

```powershell
py -S research/m9/gptIntel_refutation_core.py verify Rule30PrizeKit/lean/Ruliology/CellularAutomata/Rule30Certificates/GateTrap.lean research/m9/data/trapped-runs-core.xz
```

Using `build` in place of `verify` regenerates the same certificate with NumPy. The physical Lean submission uses its own bit-parallel proof. The standalone timing measures the sparse Python checker.

## The new kit ladder

The kit allows two independently chosen exterior bits at every double step. The [open-window proof](../Rule30RunOpen.lean) and [ladder bridge](../Rule30TrappedLiftRuns.lean) prove both exclusions on **every kit lift path of width at least 46**. At width 46, retain the first exterior bit as part of the input row. The second exterior bit can affect cell 46, and all the certified comparisons stop at cell 45. The same module supplies an actual width-44 lift path reading the four-run word at delay two. All three ladder headlines passed the stock checker at `ac88b68c`. Width 45 was also empty in the finite search. Its exclusion currently has computational evidence. [Kit ladder](https://github.com/WolframInstitute/Rule30PrizeKit/blob/ac88b68cccd28d7ff3b1ee19e711f4d0c999cc26/lean/Ruliology/CellularAutomata/Rule30GateTrapLadder.lean)
