# Carrying read of I270: free phases above denominator ratio six

claudeIntel, N28, 26 November 2026. It answers I270's request and the owner's "Yes, read I270". Packet `share-scratch/gptIntel/N6/I270-six-carrying-read.zip`,
`3b5dc759…`, 48,160 bytes, read back. Its nine sources equal the committed ones in this folder.

## Verdict

**PASS.** The Lean says what [relative-cut-span.md](relative-cut-span.md) and M204 say. The four points asked all hold: the relative-span proof, the direct
physical window, the all-six instance, and the hand construction at equality. I found no gap. The hand steps M204 lists stay hand steps, and two of them are for
gptM5's statement read.

## 1. Replay (mine)

- The portal source regenerates byte for byte from kit `c7c2207` with `build_relative_cut_span.py`: `8bc36732…`, 40,239 bytes.
- At the verifier pin `5fb5915` it compiles in 35 s with no warnings.
- The stock checker passes all six headlines (`visible_window`, `excludes_blocks`, `repeat_of_span`, `three_failures`, `above_six`, `sixes_excluded`):
  **190 constants**, standard axioms only, none new. That is gptIntel's count.
- A missing headline fails, and `leanchecker` passes in 85 s. [Receipt](data/claudeIntel-i270-receipt.json).

## 2. The four points

**The relative span (`repeat_of_span`, `three_failures`). Right.**
- `repeat_of_span` is purely combinatorial. A trial at a fails when some t in [a, 2a + S) has c(t + q) ≠ c(t), with S = q + extra. The trials run at H, then
  just after each failure, giving u ≤ 2H + S − 1, v ≤ 2u + S + 1 and z ≤ 2v + S + 1. So z − u ≤ 3u + 3S + 3 ≤ 6(H + S).
- Every trial start used stays inside 2a + S ≤ 8H + 7S. The start after v is at most 4H + 3S, and twice that plus S is 8H + 7S.
- If three failures within that span are impossible, some a in range has the repeat c(a + s) = c(a + q + s) for every s < a + S.
- `three_failures` shifts the phase to u, so the three mismatches sit at 0, v − u and z − u. It then applies I252's `separated_on_window` to the window of
  length Q. Two mismatches crossing the same cut are at least Q apart, so three within a span below Q are impossible. The third mismatch may lie past the absolute
  time Q; the shift handles that, as the note says.
- The hypothesis is any unimodular pair p/q, p'/Q with errors of opposite sign, not only consecutive convergents. That generality is sound: every k with 0 < k < Q
  has ‖kα‖ ≥ |qα − p|, by writing k = aq + bQ.
- In `above_six`, with extra = ⌊q/g⌋ and E = 2·extra, the bounds (6g + 16)q ≤ gQ and 8gH ≤ q give 6(H + q + E) < Q. I followed that arithmetic and agree.

**The direct physical window (`visible_window`, `excludes_blocks`). Right.**
- `window_jen_col` in the kit asks for m with i − m = lo − t₂. It also asks for column i to agree at t₁ + s and t₂ + s for every s ≤ m, and for `orCol` (column i
  OR column i + 1) to agree for every s < m.
- `visible_window` sets m = i − lo + start + 2b. Column i agrees because it alternates from `start` and the two times have equal parity. `orCol` agrees on
  the black ticks automatically. On the white ticks it is the neighbour's reading, which is where the repeated readings are used, with s/2 < l from m ≤ 2l.
- `excludes_blocks` turns a letter repeat into a reading repeat through `locate` and `total_shift`. Two conditions make the window fit:
  - The surplus C = (lo − i)⁺ + (i − lo + start)⁺ + 1 with C ≤ b − a gives 0 ≤ m.
  - total(a) + total(b) + C ≤ total(a + l) gives m ≤ 2l.
- Every reading used lies past the cutoff, since total(a) ≥ a ≥ H = cutoff. Any site i is allowed, including sites west of the seed.

**The all-six instance (`sixes_excluded`). Right.**
- Its hypotheses, α > 0 and α² = 1 − 6α, determine α = √10 − 3 = [0; 6, 6, …].
- `six_pairs` produces (p, q) ↦ (q, 6q + p) with (p(6q + p) − q²)² = 1 and q ≤ 7p. With gear 128 the margin (6·128 + 16)q ≤ 128(6q + p) is 16q ≤ 128p.
- The opposite signs follow from (6q + p)α − q = −α(qα − p).
- In my check these pairs are exactly the convergents 1/6, 6/37, 37/228, 228/1405, …, and the ratio tends to 3 + √10 ≈ 6.162, above 6 + 16/128 = 6.125.

**The construction at equality (PROOF-SKETCH in the note). Right, and checked.**
- Put u = 2H + S − 1, v = 4H + 3S − 1 and z = u + Q, with 3(H + S) ≤ Q ≤ 6(H + S).
- The first cut is placed so the points at u and z sit at −(δ + Δ)/2 and −(δ − Δ)/2 relative to it. Both lie strictly inside its crossing strip, whose centre is
  −δ/2 and half-width |δ|/2, because |Δ| < |δ|.
- Crossing gaps of at least Q leave u and z as that cut's only crossings in [H, z], and v as the second cut's only crossing.
- The argument is a little stronger than stated: *every* trial start in the theorem's range [H, 4H + 3S] fails, not only the three greedy ones:
  - a start up to u reaches u, since 2a + S > u;
  - a start up to v reaches v;
  - a later start reaches z, since 8H + 7S > z exactly when Q ≤ 6(H + S).
- So the quantitative conclusion of `repeat_of_span` is false at Q = 6(H + S) for that lag. As the note says, this says nothing about joint tests at several lags,
  and the endpoints depend on the lag.

## 3. My own check (COMPUTED, no shared code)

[claudeIntel_six_span_check.py](claudeIntel_six_span_check.py) uses Lean's coding (letter n is true iff frac(θ + nα) < γ) in 80-digit decimals.
[Output](data/claudeIntel-six-span-check.txt).

1. The all-six pairs are unimodular, satisfy q ≤ 7p and the gear-128 margin, have opposite signs, and equal the convergents of √10 − 3.
2. For 320 random arcs and phases at the angles [0; 3, …], [0; 5, …], [0; 6, …] and [0; 7, …], no three lag-q mismatches lie within a span below Q. Also, no
   pair (p' + kp)/(Q + kq) straddles the angle, so Q is the largest partner a lag-q pair can have.
3. At the all-six lags, whenever 6(H + S) < Q, some trial in range succeeds: 570 random arcs and phases.
4. **The construction.** At all six, q = 37, Q = 228, H = 0, E = 1, where Q = 6(H + S) exactly, the mismatches in [H, z] are exactly 37, 113 and 265, I270's
   numbers, and every trial in range fails. The same holds in all 1,418 further cases at digits 3 to 9 with H up to 5, 14 of them at equality.

## 4. Scope, for the essay and the statement read

- **Hand steps.** The following are not in Lean, and the essay should mark them:
  - the limsup form "limsup Q/q > 6";
  - moving a general onset inside a block to the `reads` alignment;
  - choosing the phase of the clock;
  - the reverse half-open convention.

  The first and the half-open point are gptM5's to check in the statement read.
- **The class may be empty.** No right half is shown to read any such word, as the owner said of S11 and S19.
- **Credit.** As P85 and M204 say, the frequency transfer is Adamczewski's idea, made phase-uniform by N20's envelopes, and the crossing count is Nguyen's. The new
  step is ratio six for the three-trial repeat at every phase with unequal blocks, and its sharpness at a single lag.
- **M205 sends S27 to core.** This read covers the Mathlib form. The integer core port will need its own carrying read when it exists. The things to recheck
  there are the restated approximation hypothesis and the floor-free coding.
