# S18 packet a release review

**The theorem and its scope pass. Packet a needs three release-text corrections.** This review is on M168's frozen archive `1407cc44c45e5ffe1f38757db5c71d6ee6039a3e8d4b2c75f44cb35beaf48c83`.

1. **Caption the kick raster accurately.** The essay says it shows the sharp example “up to the last outside window.” The code takes 48 samples, and the saved raster is 48 cells wide. The last outside sample has index 34. Keep the figure and say “The first 48 white samples are shown. The half enters at sample 35.” Alternatively, plot the first 35 samples to match the original caption.
2. **Describe the age bits as a forward invariant.** The essay defines a prefix's age set by when a row “can still be outside the set.” The module header and PR body also use “can be outside at age t.” The Lean checks an age bit for every actual row along the drive, including rows already in the closed set. The initial age bit holds universally and propagates by one on each white-to-white step. The bit for age 35 implies the separate membership bit. Use “Each prefix receives a set of allowed ages. Every initial row carries age zero, each checked step advances the age, and carrying age 35 forces membership.” In the discussion of widths 20 and 21, call 21 the least width **for this outside-cycle test** and identify the longest path as a path in the unpruned outside graph at width 21.
3. **Match the PR's byte count to the file.** The exact `Rule30UniformEntry.lean` in the patch is 18,704 bytes. The PR says 18,652. It can drop the byte count, which moves when the header is edited.

These corrections preserve the Lean statements and certificate. Changing the module introduction requires regenerating the portable Lean, notebook and affected digests as well as the kit text.

## Scope checked

White sample zero is at tick `T+1` after the black tick at `T`. The guaranteed sample 35 is at `T+71`, and the direct theorem from an arbitrary white row needs just 70 updates of the prescribed drive. The 82-cell initial prefix is exactly the twelve observed cells plus the 70-tick eastern cone. `uniform_entry` then uses closure to cover every later white sample. The witness starts at a black tick, has only sites 2, 7, 8, 11, 12, 14, 18 and 21 black, and lies outside at sample 34. Closure rules out any earlier entry. The witness lies inside at 35.

At or after sample 35, a kick has its next two gaps in the nine-pair list. That list excludes `(4,4)`, so an eventual once-in-four kick tail is impossible for any right half under the drive. The nine-net window begins at `k ≥ 35` and gives the kick at `k+6`. The first guaranteed target is 41. The black-net implication is one way, and the singleton corollary assumes its centre eventually alternates. None of these claims excludes an alternating singleton.

The older width-13 theorem about the gap language allows a pure-four mode and uses the finite left half when excluding it on the singleton. S17 supplies the 777 windows and closure. S18 gives the exact physical entry deadline for that fixed set, and removes pure fours on the right alone. The nearby open PRs concern exact strip exclusions for specific longer words, seven-white gaps, and marked gaps with white restarts. None supplies the same deadline. [S17 kit PR](https://github.com/WolframInstitute/Rule30PrizeKit/pull/418) · [Longer strip certificates, PR #416](https://github.com/WolframInstitute/Rule30PrizeKit/pull/416) · [Seven-white gaps, PR #417](https://github.com/WolframInstitute/Rule30PrizeKit/pull/417) · [Marked gaps, PR #419](https://github.com/WolframInstitute/Rule30PrizeKit/pull/419).

## Packet a evidence

All twelve advertised digests and every posting pin matched. The builder regenerated both Lean files byte for byte. The independent stock checker at `5fb5915` matched the whole author receipt with 11 headlines, 298 declared items and 582 replayed constants. The exact kit patch applies to #418 head `43e938c740eaa695eadfcc06fc695b09f366a655`. The kit module passed with 11 headlines, 13 declared items and 50 replayed constants, using the source-identical S17 modules from the earlier replay. Native `leanchecker` passed both proofs. Neither receipt adds an axiom. The notebook contains the exact source and abstract, twelve saved outputs and one successful kernel check. All four figures were inspected and the authenticated dry run passed.

A separate forward enumeration confirmed 1,699,328 exterior starts in the width-21 graph and an exterior path length of 35 windows. The two-direction core sizes for widths 12–22 are 47, 10, 9, 8, 9, 10, 8, 11, 9, 0 and 0. The eight-window width-20 cycle is among the nine surviving windows at that width. A literal truth-table evolution gave `3508 → 4082` for seed 1191106 and `2484 → 754` for seed 141962434 at indices 34 and 35. Both first enter at 35.

The read-back archive `share-scratch/gptM5/S18/R113/s18-a-review.zip`, SHA-256 `f742ca630bdec0582b086691d219de62e88a79fff0ee9f24abd5247a4ed31ee9`, contains the outputs, plots, reproduction and checker receipts.


## Packet b release read

**PASS** on M169's exact archive `f1927193dd9e9437d4873938cb5b2be712ff2041a526857ac7faa10295ed3c21`. The rebuilt essay describes what the 48-sample raster shows and marks entry at sample 35. The age bits now describe a forward invariant and the width claim is scoped to the exact outside-cycle test. The PR drops the stale byte count. Its theorem claims, sample indexing and credits agree with the source.

All twelve advertised digests and posting pins match. The notebook `508803f79882cf70eefb5c664a04d0f41237cb0a98c23f781ace506ee15d5500` contains the exact 248-word abstract and portable Lean source. Ten of twelve outputs are identical as notebook expressions, including the four figures, headline types and axiom lists. The two changed outputs are the rebuilt Lean environment and successful kernel-check summary. The dry run passed at `5fb5915`.

Both exact Lean sources differ from a only in their introductory comments. I rebuilt and reran stock and native checks on both. The portal passed all 11 headlines with 298 declared items and 582 replayed constants. The kit passed all 11 with 13 declared items and 50 replayed constants. No new axioms. Patch `1d1d5c616430953e68e97d0ac4683fe2c029d79ef9a27e290149c15b8361b9be` applies to #418's exact head `43e938c`, which was open on kit main `88fdac9` at the check. The kit module imports S17. The kit patch and PR text should be refreshed when that dependency enters main, as planned. The exact reviewed PR body is `8529fd29cf8b97a12dbaf2754193a7d77e180a92fb04ed1dff8c532910f6cf84`.

Read-back evidence `share-scratch/gptM5/S18/R113/s18-b-review.zip`, SHA-256 `08331059b2e8d2105cc2cf07fefdb481288bfbe0b028c444041b2f267998b081`.
