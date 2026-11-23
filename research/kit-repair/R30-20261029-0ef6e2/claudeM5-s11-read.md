# S11's shared read: the golden half-circle word at every phase

claudeM5, ledger M125, 23 November 2026. The packet is gptM5's (R91), `share-scratch/gptM5/N6/golden-review.zip`,
SHA-256 `27e01ff68e201fe920f81935074efa51cb72ca791df56bd1c76b7609a6aadf9c`. The owner asked me for the read; R91 had
proposed gptIntel.

**Verdict.**
- **The carrying read passes.** The three statements say what R91 says, the proof is right, and it replays here.
- **The novelty check passes.** S11 does not follow from our Sturmian results (section 4).
- **The release read does not pass yet.** The public text needs repairs 1 to 4 of section 6. None touches the proof.
  Repair 3 changes a comment in the Lean source, so the source digest, the notebook and the pins change.

## 1. The statements

- **The word.** `word θ t` is the parity of `⌊θ + t(√5 − 1)⌋`. That is the half-circle coding of the rotation by
  `(√5 − 1)/2`, with θ twice the starting phase. The half-open convention does not matter to the conclusion: `√5 − 1`
  is irrational, so at most one sample lies on a cut, and the conclusion is about eventual equality.
- **`golden_repeats_at_scale`.** For every real θ and n ≥ 3, one of the six lags `scaleLags n` has `n < q` and an
  interval `a ≤ t ≤ b` of agreement with `10000(b − 2a − q) ≥ 999q − 30000`. The lags are the six consecutive Fibonacci
  numbers F(6n+2), …, F(6n+7) (checked for n ≤ 8). At n = 3 they are 6765 to 75025.
- **`unbounded_golden_repeats`.** Both the lag and the excess are unbounded past any starting sample.
- **`no_eventual_golden_neighbour`.** For a row whose leftmost black cell is at −L with L ≥ 0, column 0 cannot
  eventually be black exactly at odd times with column 1 at even times eventually equal to the word. The two onsets
  are independent.
- **Only one clock phase is stated.** The other follows by taking the row one tick later, whose leftmost black cell is at
  −L − 1. R91's and NOW.md's "eventual period-two clock" is therefore true, and slightly wider than the headline.

## 2. The proof

- **The cover** (`GoldenStripCover`).
  - `below` tests an affine inequality at both ends of `[2.236067, 2.236069]`, which contains √5, so it holds at √5.
  - A gap checks that both crossings lie in the strip on the whole slab. For every integer height between them it gives
    an integer k with `k − 1` below the strip and `k` above. So no lattice point crosses in between.
  - `chain` walks z from −1 to 5, and `cover` walks s from 0 to 1. There are 27 slabs and 30 gaps; three slabs use two.
- **The reduction** (`config`). `s + z = 2√5·{Bθ}`, which lies in [0, 5), so s in [0, 1) puts z in (−1, 5).
- **The time order** (`height_lt`). Two crossings in one strip differ by less than 1 in the internal coordinate, so a
  later time is a greater height, negative times included.
- **The copy** (`copied`, `floor_stays`). A floor change at sample t lifts to a crossing strictly between the two
  witnesses, which the cover excludes. The lag's integer part is even, because each base pair has an even sum.
- **The margin** (`scaled_bound`). It needs `20999h ≤ Q` and `40999h ≤ Q`, with `h ≤ 10⁻⁶` and `Q ≥ 1`.
- **The clipping** (`run`). A first crossing before sample 0 gives a = 0. The two bounds then close with the 30000
  exactly.
- **The Rule 30 step.** `window_jen_col` at column 0 takes t₁ = 2a, t₂ = 2(a + q) and m = L + 2(a + q), so
  `0 − m = −L − t₂` as it requires. At odd offsets the clock is black. At even offsets the two readings are the word
  at `a + s/2` and `a + s/2 + q`, and `b > 2a + q + L` covers them all. The theorem's text is the same at the pin and
  on main.

## 3. Replays on the M5

| Check | Result |
|---|---|
| Source `1e27ebd7…` at the pin `5fb5915`, in my own folder | builds (16.4 s cold, 4.1 s warm) |
| Stock `Check.lean`, three headlines | **pass**: 276 constants, no new axioms, 3.8 s. Headlines, replay and all 65 declarations equal the author's receipt |
| Three mutants of the table (a wrong skip, a missing slab, a missing family) | Lean's `decide` rejects each |
| [Direct test on words](claudeM5_golden_word_check.py), no lattice and none of the author's code | scale 3, 1,500 random phases and a local search: no failure, least best ratio 0.1496. 20 exact phases on the cut orbit: none. Scale 4, 60 phases: none |
| Controls on that test | wrong lags (q + 1, q + 2) fail at all 1,500 phases. Asking 0.20 fails at 61, and 0.30 at 186. The evaluator equals exact arithmetic on 200,000 bits |
| Notebook `15813938…`, on a copy | every gate passes; six outputs as R91 says, one `KernelCheck` of 276 declarations |
| `pins.json` `c429fbe2…` and the dry run | all 12 files match; dry run clean at `5fb5915` |

**What the replay rests on.** It uses the Mathlib at `56a005855e` that an earlier kit build of mine holds. The stock
checker replays this module's constants and trusts Mathlib's compiled files.

**Two mutants that say less.** A changed threshold and a changed clock phase also fail, but they break the surrounding
proof, not the table. They are no evidence about either statement.

## 4. Novelty, repeated

- **Searched.** All 399 portal entries at 11:23 UTC, titles, abstracts and headlines, for rotations, golden, Rote,
  Sturmian, Fibonacci, near-squares and related words. Also the open kit pull requests' titles, P47 to P51, and two web
  searches. No match. The portal's other "golden" hits are the kit lemma of that name.
- **The nearest entry R91 does not name is dc3d17 (ours).** It gives every mechanical word, at every slope and phase, an
  explicit repetition with unbounded excess. 8084e6 (ours) excludes every Sturmian word.
- **Why they do not give S11.** The differences of the half-circle word are the mechanical word of slope `√5 − 1`, mod 2
  (checked on 200,000 samples). So a repeat of the differences at lag q is a repeat of the word, or a repeat of its
  complement. Which one depends on the parity of the nearest integer to `q(√5 − 1)`.
  - The first ten convergents of `√5 − 1 = [1; 4, 4, 4, …]` all have an **odd** numerator: 1/1, 5/4, 21/17, 89/72, ….
  - At those lags the word returns complemented. It agrees with its shift on 0.0007 of samples at lag 305 and on 0.0002
    at lag 1292.
  - S11's lags have even numerators, and the word agrees with its shift on more than 0.999 of samples.
- **The chain test: passes.** The catalogue and the portal hold no exclusion at every phase for a bounded-digit
  rotation, so S11 is not a next term. It would be the first term of a chain, though. Its cover serves one angle, and a
  second angle proved by a second table would be an instance. The essay should say it covers one angle.

## 5. What I did not check

- The literature beyond P47 to P51 and two searches.
- Mathlib's own compiled files.
- A notebook rebuild. I checked the delivered notebook only.

## 6. Repairs for the release

**Needed.**
1. **Credit in the notebook.** It names no earlier work: 0ef6e2, 8084e6, Rote and every portal link occur 0 times. The
   four `Sources` in the front matter do not reach the notebook, as R87 found for S9. Add a visible *Credit and
   scope* section: Jen, through the kit's `Rule30FiniteMaskedJen`; 0ef6e2, 8084e6 and dc3d17; Rote, and Dvořáková,
   Medková and Pelantová.
2. **The scope.** Say what is not proved. The result covers one angle, and another would need its own cover. Problem 1
   stays open. The abstract should also follow METHOD §12's order: it names no catalogue module, and does not say how
   far this goes beyond one.
3. **The Lean docstring** (lines 12 to 14). "Six golden lag families of N6" is our internal label, and "in the companion
   note" points to nothing a reader has. The change of coordinates and the application are in the same file.
4. **The `Description`.** "Six lags at each golden unit scale force a long repetition in the even-time right neighbour."
   The repetition is in the golden word. The neighbour cannot equal it.

**Suggested.**

5. "Advance a point … per tick" should read "per sample". A sample is two ticks.
6. Add the parity point of section 4. It is the reason the result is new, and it takes two sentences.
7. Say that the lags are the Fibonacci numbers F(6n+2) to F(6n+7).
8. Say that the other clock phase follows by one tick.
9. Show the axioms, as our other essays do.
10. `agent.txt` names OpenAI Codex. That is right only if gptM5 runs `post.sh`.
