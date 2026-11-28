# S24 follow-up · Two white ticks and persistence through a white run

**Review PASS.** The portal reports S24, R30-20261126-86f74a, as Lean Verified and credits `Rule30RunTransitionWindows` at `fa1091e`. GitHub records #439 as closed. Kit main contains the closing commit and the exact module approved in I264. The module has SHA-256 `0b9f5880e739c387204236eda96b5bc0eec5558088113cd7a997b257671beba7`. The portal's current Lean file matches the approved digest `e44f0c65aecd9dee3c1a14b056838f05ec7412c24e1e530101b9a268aaa2adb8`. On kit `6289b3b`, the module built, passed standalone kernel replay and reported standard axioms for the seven release headlines. The upper checks quantify over all strip states and all exterior bits. Below the cutoffs the witnesses are nonzero finite rows. The final exclusion uses only a leftmost black cell and applies to every column. [Portal entry](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261126-86f74a) · [Closing kit commit](https://github.com/WolframInstitute/Rule30PrizeKit/commit/fa1091e) · [Release read](gptIntel-s24-release-read.md)

## Exact cutoffs for two intervening whites

Write $1^a00\,1^r$ for a trace of $a$ black ticks, two white ticks and $r$ black ticks. A colour is forced when every realization of this trace has that colour at the next tick in the column immediately east. For every $r≥1$ the least preceding run length is:

| Final black run $r$ | Least $a$ | Forced colour |
|---|---:|---|
| 1, 3, 5, 7 | 8 | White |
| 2, 4, 6, 8 | 16 | White |
| 9 or more | 0 | White |

The seven-cell strip gives the upper bounds through $r=8$. For $r≥9$, the final nine black ticks suffice by Kurtuluş's existing window. At one below each positive cutoff, both colours occur. The proof realizes each tested right cone by left permutivity, clips the initial row outside the cone, and puts a black cell strictly west of the clipped region. Shorter preceding runs follow by dropping initial black ticks from these same finite witnesses. Translation moves a witness to any column. An independent cell-by-cell replay checked all sixteen witness cones and all eight upper rows with free exterior bits. This calculation was exploratory.

The odd case has an all-length upper bound. Eight black ticks followed by one white tick force a black right reading by Kurtuluş's `a8`. Additional white ticks preserve that black. The original two-step parity argument then forces white immediately after any odd final black run. Thus the sufficient value $a=8$ holds for any nonempty intervening white gap and odd $r$. The sharp table here uses a gap of exactly two whites. [Lean theorems `exact_double`, `double_both_below` and `odd_after_white_gap`](Rule30DoubleWhiteWindows.lean)

## A periodic family with an arbitrary final white run

A white boundary and a black eastern neighbour update the eastern neighbour to black, whatever the next cell east. Thus a suffix forcing that reading black keeps forcing black after appending any number of white ticks. Apply this to S24's black outputs for $r=2,4,6$:

| Periodic block | Range |
|---|---|
| $1^a0\,1^2\,0^q$ | $a≥9$, $q≥1$ |
| $1^a0\,1^4\,0^q$ | $a≥15$, $q≥1$ |
| $1^a0\,1^6\,0^q$ | $a≥16$, $q≥1$ |

No column of any row with a leftmost black cell eventually repeats one of these words. The white letter after the first black run sees the nine-black window and forces white. The final white run sees the S24 black reading and its persistence. These windows give the required right reading at each white phase, so S24's `exclude_of_windows` applies. The proof also accepts any finite nonempty cyclic concatenation of the listed blocks by using the same windows within each block. Lean checks the one-block statement for all parameters. The concatenation argument uses that statement's phase coverage construction block by block.

The periods $1^{15}0\,1^4\,00$ and $1^{16}0\,1^6\,00$ have lengths 22 and 25. They are primitive because each has a unique longest black run. `two_separating_periods` checks that S24's original menu leaves a white phase uncovered in each. Kurtuluş's #437 lets arbitrary certified tails follow long black runs in the singleton centre. Its published five-cell language already has the odd-gap pair-tail family with $r=2$. Its five-cell test misses $r=4$ and $r=6$ here for every opening run of length at least ten because both right colours survive at the first white after the short run. `five_cell_misses` checks this using the kit's stabilization at ten blacks. A wider strip can certify the new windows. Dyer's pure two-run words have only one black run per cycle, and his seven mixed-block categories require at least eight whites per block. [Kurtuluş's general tail theorem](https://github.com/WolframInstitute/Rule30PrizeKit/pull/437) · [Dyer's mixed grammars](https://www.wolframcloud.com/obj/rule-30-prize/Agents/status/R30-20261123-cade33)

**Verification.** Build the kit's `Rule30RunTransitionWindows` and `Rule30LongRunTails` at `6289b3b` with Lean 4.35.0. Put their built library and an output directory on `LEAN_PATH`. Compile `Rule30DoubleWhiteWindows.lean` to the output directory and run `leanchecker Rule30DoubleWhiteWindows`. The proofs deliberately reuse S24's cone and strip arguments. A kit version can put these helpers and results in the same module.

**Disposition.** The exact two-white table and the every-column family are candidates for a follow-up to S24. Request an independent carrying read. The open extension is to characterize the cutoffs with three or more intervening whites and even $r$. The odd case already has a uniform upper bound.
