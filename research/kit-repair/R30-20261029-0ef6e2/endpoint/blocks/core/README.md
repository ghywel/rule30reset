# S27's core port

claudeM5, 26 November 2026: part 1 in M209 and part 2 in M210, at the owner's word ("And do the core port", "Carry on
with part 2"). The goal is S27 (R30-20261126-8c236d, Mathlib) as a core module beside the kit's `Rule30RotationBlocks`,
under METHOD §12, Mathlib, rules 3 and 5. **Both parts are done.** The whole theorem is in core: every phase, every
arc, and any two nonempty blocks. gptIntel's read passed (I274), and the module is kit pull request
[#446](https://github.com/WolframInstitute/Rule30PrizeKit/pull/446) (M211).

## The module: [Rule30RotationFreePhase.lean](Rule30RotationFreePhase.lean)

The module is core Lean in `module` form. It imports `Rule30RotationBlocks` and `Rule30FiniteMaskedJen`.

- **Hash and size.** SHA-256 `7385a3b4…`, 860 lines: the reviewed `eeb51197…` with one line of the introduction
  reworded at the reviewer's suggestion ("above six by a fixed positive margin"). Part 1 alone was `531224c6…`, 426 lines.
- **Build.** At kit main `6df813b` it builds with no warnings, and so does `lake build Ruliology` (382 jobs).
- **Stock check.** The partial check passes fourteen headlines, with 295 constants, 48 declarations and standard axioms
  only ([receipt](check-Rule30RotationFreePhase.json), at `6df813b`).
- **Controls.** A missing headline is refused. `leanchecker` passes.
- **Source.** There is no `sorry`, `native_decide`, `bv_decide`, `axiom`, `implemented_by` or `extern`.

### Part 1 (M209): every phase, given envelopes

- **No real numbers.** The angle is S19's `IrrationalLine g`. The arc at phase `θ` is read off two `PhaseLine`s `f₁`, `f₂`
  of `g` (for `⌊θ + tα⌋` and `⌊θ + tα − γ⌋`) as `arcWord f₁ f₂ t = decide (f₁ t − f₂ t = 1)`.
- `three_failures`: the integer form of S27's step. A letter that differs from the letter `d` later is a failure of
  one of the two lines at lag `d` (`fails_of_differs`), and S19's `Farey.gap` keeps two failures of one line `D`
  apart. So three such letters span at least `D`.
- `repeat_of_span`, `visible_window`, `excludes_blocks`, `slack_of_envelopes`: S27's own, already integer.
- `above_six_of_envelopes`: S27's `above_six` with the hypothesis on approximants as S19's `Farey` pairs
  (`(6 gear + 16) d ≤ gear D`), and the reading clock's linear envelopes (`Envelopes`) as a hypothesis.
- `equal_envelopes`, `above_six_equal`: blocks of one length have exact envelopes.
- `ten_irrational`, `sixes_line`, `six_pairs`, `sixes_farey`, `sixes_equal`: the angle `√10 − 3` as
  `isqrt (10 t²) − 3 t`, its convergents `(p, q) ↦ (q, 6q + p)`, and their sides from `(3q + p)² = 10 q² ± 1`.

### Part 2 (M210): blocks of different lengths, with no envelopes

The two lines are at most one apart (`between : f₂ t ≤ f₁ t ≤ f₂ t + 1`, the integer form of `0 < γ < 1`). S27's
Mathlib proof bounds the window counts at the first scale `q` by Hermite's identity on a grid. The port does not.
It takes a **second, smaller Farey pair** of the angle, chosen for the size of `q`:

- `isum`, `isum_sparse`: integer sums. Terms in `[−1, 1]` whose nonzero ones are `s₀` apart sum, over `k s₀` places,
  to at most `k` in size.
- `window_drift`: for Farey neighbours `u / b`, `U / d`, the number of letters inside the arc in a window of `b`
  moves, per step, by the difference of the two lines' carries `f (t + b) − f t − u`. Each carry is in `[−1, 1]`,
  and `Farey.gap` keeps one line's nonzero carries `d` apart. So over `k d` steps the window count moves by at most `2k`.
- `block_balance`: two stretches of `n` letters at most `k d` apart differ in that number by at most
  `2 k (n / b) + b`.
- `farey_level`: past some level, for every level `M` the angle has Farey neighbours `b`, `d` with both at least
  a given `K`, both at most `M`, and `b + d > M`. The proof descends by mediants from `exists_farey`.
- `readings`: the readings of `n` letters are `n · len false + (len true − len false) · inside`.
- `rate_room`, `above_six`: take the second pair at the level `M = q / (8 L gear)`, with `L = len true + len false`.
  The repeat found by `repeat_of_span` starts at some `a ≤ 10 q`. The two stretches from `0` and `a` then differ in
  readings by at most `L (2 (a / d + 1)(a / b) + b)`. Since `2bd ≥ K(b + d) > KM`, this and the cutoff fit in the
  surplus `q / gear`.
- `sixes_excluded`: the same at `√10 − 3`, with gear 128.

Before this route, two single-scale ones were tested numerically and ruled out:

- **Alternation.** The two lines' failures do not alternate. In 293 random cases two failures of one line came in a
  row in 115 ([claudeM5_alternation.py](claudeM5_alternation.py)).
- **One line at a time.** A single line's failures are not balanced over windows: 317 of 392 cases
  ([claudeM5_balance.py](claudeM5_balance.py)).

## By hand, outside Lean

The essay's hand steps still apply:

- the real angle, phase and arc as `IrrationalLine` and two `PhaseLine`s;
- the continued-fraction form of the hypothesis;
- the alignment of the reading's start, the clock's phase and the half-open convention.

`Rule30RotationBlocks` states its angles the same way.

## Status

1. gptIntel's read passed: [I274](gptIntel-s27-review.md), with its own exact-integer controls.
2. Kit pull request [#446](https://github.com/WolframInstitute/Rule30PrizeKit/pull/446), from the branch `rotation-free-phase` on `6df813b`, opened at the owner's word
   (M211). It adds the module, its catalogue row and the import, and the count goes from 378 to 379.
