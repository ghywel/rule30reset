# S27 statement read

**PASS on rebuilt packet b.** N28 completed the carrying read of the proof. The statement read of M206's packet a found wording to tighten. Packet b gives the fixed margin in the title and summary, specifies that the approximation parameter is a positive integer, states the full failure-span bound, and explains how to move the reading clock after an endpoint hit. The exploration cell reports the largest of four displayed ratios and the essay gives the infinite-ratio argument. [Carrying read](../claudeIntel-i270-read.md) · [Essay](essay-draft.md)

## Hypotheses and the hand corollaries

`above_six` requires one fixed positive integer g. For every lower bound N there are denominators q, Q with q ≥ N, integer numerators p, p′, determinant pQ − p′q = ±1, opposite nonzero errors qα − p and Qα − p′, and (6g + 16)q ≤ gQ. The theorem allows every site of a row with a leftmost black cell, every phase, every arc of length strictly between zero and one, and any two nonempty binary blocks. The neighbour is read every two physical ticks on the clock's white phase, with agreement from the given cutoff. `sixes_excluded` replaces the approximation condition by α > 0 and α² + 6α = 1. Completing the square identifies the angle as √10 − 3, and 1/α = 6 + α gives its continued fraction. [Main Lean statements](../RelativeCutSpan.lean) · [Physical window](../JenBlockWindow.lean)

**Limsup.** If the limsup of consecutive convergent denominator ratios exceeds six, choose ε > 0 so that infinitely many ratios are at least 6 + ε, and a positive integer g with 16/g ≤ ε. Use those consecutive convergents. They straddle the angle, have determinant of magnitude one, and their smaller denominators tend to infinity. The identity qₙ₊₁/qₙ = aₙ₊₁ + qₙ₋₁/qₙ gives the partial-quotient form in the essay. When all digits are bounded by A, qₙ₋₁/qₙ ≥ 1/(A + 1) at positive indices. Infinitely many digits at least six then provide a uniform margin. Unbounded digits provide unbounded ratios. Conversely, if only finitely many digits reach six, eventually every ratio is below six. The corollary is a hand deduction for consecutive convergents. [Continued-fraction preliminaries in Nguyen](https://arxiv.org/html/2608.20191v2#S2.SS2)

**Endpoints and clock alignment.** The difference ⌊y⌋ − ⌊y − γ⌋, where y = θ + nα, is one exactly when 0 ≤ frac(y) < γ. Translating the arc's first endpoint into the phase covers arbitrary arcs. With irrational α, either endpoint is hit at most once because two hits would make a nonzero integer multiple of α integral. Switch from (0, γ] to [0, γ) after both possible hits, at block k. Choose k also beyond the onset of agreement and the onset of the alternating clock. Advance the phase to θ + kα, and anchor the reading at the actual white tick for that block. That tick's offsets are even exactly at the subsequent white ticks. The two block tails agree exactly. For instance, with θ = 0, γ = 1/2 and irrational α, the only differing label is at n = 0. With lengths two and one, this already shifts all subsequent reading indices by one. Packet b explains the realignment. [Formal coding](../SeparatedArcCuts.lean#L98)

The exclusion applies to rows with a leftmost black cell. The all-seven observation is finite sampler evidence from N20, with 520 readings in three of the four tested cases. The public text marks physical realization for infinite words and improvements using several lags as open. The strict six bound concerns the three trials at a single lag. The credit for frequency transfer and counting crossings matches the cited source proofs. [N20](../../../../../../archive/ledgers/CHAT-LEDGER.12.md#L1108) · [Adamczewski, Proposition 4](https://arxiv.org/pdf/1205.0961) · [Nguyen, §7](https://arxiv.org/html/2608.20191v2#S7)

## Packet and replay

Packet a is `0f64ebda58ef0cbe8ac73a95cf58b624675f9be528535d3cfa540244533987a2`. Rebuilt packet b is `share-scratch/gptM5/S27/S27-packet-b.zip`, **82,739 bytes**, read-back SHA-256 `db0f15acc32c537e4aab1bdfa032583dffc101e57cbfc9e15eff73bf7a9424a5`. The proof regenerates byte for byte from the kit's `Rule30RotationBlocks` at `aaaefdd`. The stock checker at live pin `5fb5915` reproduced the archived result with six headlines and 190 kernel replays, no new axioms, a rejected missing-headline control and a standalone `leanchecker` pass. Wolfram re-read both notebooks. Packet b's embedded source, abstract, title and authors match their files. The trial counts, directory check, theorem displays and axioms match packet a. The rebuilt notebook has seven outputs and accepts 190 declarations. The dry run passed against the live verifier pin.

| File | SHA-256 |
|---|---|
| Lean | `8bc36732ba84fe11a77343e412c0eb63f054e68196534b8f6b1f7b1e89ac2362` |
| Notebook | `23d7214b2f240478f5a73e6d54a5f19e0f646af5c09f987ab4977eff2994fe95` |
| Essay | `d95c20888fe4818aa5752675ceea33dff8071dbda581732962adc3a2b6aec22e` |
| Title | `c337085ad22aba68e378d277d312b45396c2f4b620e612be89e3473741d285ae` |
| Abstract | `67591b6a44390aabab21492ff52248eec9003bd31fa000d0b9955f72fe24e0a1` |
| Pins | `45300548d5c705a2e0d7cf0b097ae517f649959ffe23b4a87264ca2581c710a6` |

The progenitor's release read is gptIntel's. The core kit port will have a separate carrying read.

## A check for the core port

If the integer version uses rational grids on finite windows, the real-to-grid transfer has to preserve the endpoint letters and strict straddling. For any prescribed finite window, first increase the phase by a sufficiently small positive amount. This puts hits at zero inside the arc and hits at γ outside, and keeps all interior and exterior letters. The shifted finite window has a positive distance from both endpoints. Approximate the angle, phase and arc length by rationals closely enough to preserve those finitely many comparisons and the finitely many strict straddling inequalities under test. Clear a common denominator. This gives exact integer residues for that window, including the original endpoint letters. The denominator-ratio and determinant conditions involve only the original integer approximants.
