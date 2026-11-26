# S27's core port

claudeM5, 26 November 2026, M209, at the owner's word ("And do the core port"). The goal is S27
(R30-20261126-8c236d, Mathlib) as a core module beside the kit's `Rule30RotationBlocks`, under METHOD §12, Mathlib,
rules 3 and 5.

## Part 1, done: [Rule30RotationFreePhase.lean](Rule30RotationFreePhase.lean)

Core Lean, `module` form, importing `Rule30RotationBlocks` and `Rule30FiniteMaskedJen`. SHA-256 `531224c6…`, 426
lines. At kit main `aaaefdd` it builds with no warnings. The stock partial check passes nine headlines, with 145
constants and standard axioms only ([receipt](check-Rule30RotationFreePhase.json)). A missing headline is refused,
and `leanchecker` passes.

- **No real numbers.** The angle is S19's `IrrationalLine g`. The arc at phase `θ` is read off two `PhaseLine`s `f₁`, `f₂`
  of `g` (for `⌊θ + tα⌋` and `⌊θ + tα − γ⌋`) as `arcWord f₁ f₂ t = decide (f₁ t − f₂ t = 1)`.
- `three_failures`: the integer form of S27's step. A letter that differs from the letter `d` later is a failure of
  one of the two lines at lag `d` (`fails_of_differs`), and S19's `Farey.gap` keeps two failures of one line `D`
  apart. So three such letters span at least `D`. No `0 ≤ f₁ − f₂ ≤ 1` hypothesis is needed for this.
- `repeat_of_span`, `visible_window`, `excludes_blocks`, `slack_of_envelopes`: S27's own, already integer.
- `above_six_of_envelopes`: S27's `above_six` with the hypothesis on approximants as S19's `Farey` pairs
  (`(6 gear + 16) d ≤ gear D`). The reading clock's linear envelopes (`Envelopes`) become a hypothesis.
- `equal_envelopes`, `above_six_equal`: blocks of one length have exact envelopes. So for them the theorem is
  complete in core: every phase, every arc, any bits.
- `ten_irrational`, `sixes_line`, `six_pairs`, `sixes_farey`, `sixes_equal`: the angle `√10 − 3` as
  `isqrt (10 t²) − 3 t`, its convergents `(p, q) ↦ (q, 6q + p)`, and their sides from `(3q + p)² = 10 q² ± 1`.

## Part 2, open: the envelopes for blocks of unequal lengths

S27 gets the envelopes (`SeparatedArcCuts.envelopes`) from `visits`: the number of letters in the arc, over any `q`
consecutive steps, varies by at most 7 with the position. Its proof is Hermite's identity on a grid of `q` points,
with real `x` and `α`. The integer form needed is:

> For Farey neighbours `u / q`, `U / Q` of `g`, and two phase lines `f₁`, `f₂` of `g` with `0 ≤ f₁ − f₂ ≤ 1`, the window
> count `N(s) = Σ_{j<q} (f₁ − f₂)(s + j)` varies by a bounded amount over all `s`.

Then S27's `envelope` lemma (already integer) gives `Envelopes` for any two lengths.

- **What does not work.** `N(s + 1) − N(s)` is the failure of line 1 at `s` minus that of line 2. `Farey.gap`
  bounds each line's failures by one per `Q` steps, but over long ranges that only gives a drift of order `s / Q`. The
  failures of the two lines do not alternate either. In 293 random cases (angle, phase, arc, and a convergent pair
  with `q ≥ 10`), two failures of one line came in a row in 115 cases. The spread of the difference never exceeded 2
  ([claudeM5_alternation.py](claudeM5_alternation.py)).
- **What it needs.** `q` consecutive orbit points have one point in each cell of width `1 / q`. In integers, the
  cell of `jα` is `k_j = j u − q g(j)`, a bijection onto `[0, q)`. The carries `f(s + j) − f(s) − g(j)` are monotone in
  `k_j`; this follows from `g`'s carries, and is checked on paper. That gives each window's structure, but not how
  the two lines' thresholds move together. That needs the position within a cell, at the next Farey scale `Q`, or an
  integer form of the phase as a cut through `Above`.
- **Estimate.** A new piece of integer theory of a few hundred lines, at the size of S19's `Scale` section.
