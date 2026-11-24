import Rule30PrizeKit
import Mathlib

/-!
# Rotation words of one arc, started at an end, beside a Rule 30 clock

Turn a circle by a fixed irrational angle and write down, at each step, whether the point is in a fixed arc. Start
the point on the orbit of either end of the arc. Suppose a row of Rule 30 has a leftmost black cell and one of its
columns eventually reads `0101…`. Then the column to its right, on the white ticks, does not eventually read such a
word, nor any sliding block code of it. Every irrational angle is covered, every arc, both ends, and every translate
along their orbits. Coding by finitely many arcs whose ends lie on the two orbits is a block code of this kind (a
remark, not formalized).

* `arc_near_squares`: for every irrational slope and every second line of that slope, the difference of the two
  sequences of floors has near-squares of some fixed slack at unbounded lags, from every start.
* `arc_excluded`, `one_arc_excluded`, `no_eventual_arc_neighbour`: the exclusion, at any column of a row with a
  leftmost black cell, for block codes and for the word itself.
* `half_circle_near_squares`, `half_circle_block_excluded`, `half_circle_excluded`: for half-circles the slack is
  two, for every irrational angle. The word is the parity of `⌊t β⌋`, with `β` twice the angle in turns.
* `sturmian_excluded`: the characteristic Sturmian word of every irrational slope, from any index on (the second
  line is the first one, moved).
* `sqrt_line`, `silver_excluded`: the floors of `t √m` for `m` not the square of a fraction, and `m = 2` as an
  example.

**No real numbers.** `IrrationalLine g` says that the intervals `[g n / n, (g n + 1) / n]` meet pairwise and that no
rational number lies in all of them. For a real irrational `α`, `g n = ⌊n α⌋` satisfies it: for all `m, n ≥ 1`, `g m
/ m < α < (g n + 1) / n`, and a rational number different from `α` leaves the interval of a large `n`. Conversely
the supremum of the `g n / n` is then irrational and `g n` is the floor of its `n`-th multiple. (`irrationalLine_iff`.) `PhaseLine g f` says that every
increment of `f` over `n` ticks is `g n` or `g n + 1`, as for `f t = ⌊t α + θ⌋` with any real `θ`. The arc `[0, γ)`
of the circle of length one contains `t α` exactly when `⌊t α⌋ - ⌊t α - γ⌋ = 1`. `Above g h k` is `h < k α`, read
off one interval.

**Method.** A fraction below `α` and a fraction above it, with determinant one, are Farey neighbours `u / d` and `U
/ D` (`Farey`, in either order). Adding `d` to the time adds `u` to the floor at every time `1 ≤ t < D`
(`Farey.step`), since no lattice vector is nearer the slope before `D` (`bound`). For a second line the same holds
except at times at least `D` apart (`Farey.gap`). The mediant replaces one neighbour and keeps the other
(`Farey.mediant`), and neither is kept for ever (`Farey.switch`), so there are neighbours with both denominators as
large as wanted (`exists_farey`).

*Half-circles.* The two numerators are not both even. If the neighbour with an even numerator is kept, its
denominator is a lag at which an initial stretch repeats, longer than the lag by as much as wanted. If not, the next
two mediants decide between three near-squares: at the difference of the two denominators when the larger is kept,
at their sum, or at twice the smaller when it is kept three times.

*One arc.* Take a neighbour `u / d` at the last time it is kept, next to `(x + u) / (r + d)` (`Scale`). If the
second line copies up to `d`, the start repeats at lag `d`. If it fails at `m < d` and `2 m ≤ r`, the word after `m`
does. If neither holds at two consecutive scales, the second failing time is `m + d` (`Scale.carry`). If neither
holds at three, then the middle one has `r' = r + 2 d`, and the shortfall `2 m - r` is the same there. So either one
of the two repeats occurs at infinitely many scales, or the shortfall is constant from some scale on, and the word
after `m` repeats with that slack.

Then `Rule30ClockNearSquares.corollary_F` applies to the row at a late time.

Beside the kit: `Rule30GoldenHalfCircle` excludes every phase of the half-circle word at the golden angle.
`Rule30ClockNearSquares` excludes the characteristic Sturmian words beside a clock from time zero, through their
standard words.

**Credit.** Farey neighbours and the copying of `⌊t α⌋` up to the next denominator are classical. Interval tests for
the sequences `⌊n α⌋` go back to R. L. Graham, S. Lin and C.-S. Lin, *Spectra of numbers*, Math. Mag. 51 (1978).
That the coding of a rotation by one arc from an end repeats not far from its beginning is in B. Adamczewski, *On
powers of words occurring in binary codings of rotations*, Adv. Appl. Math. 34 (2005).
-/

set_option Elab.async false

namespace Rule30Submission

open Ruliology.CellularAutomata
open Ruliology.CellularAutomata.Rule30Jen
open Ruliology.CellularAutomata.Rule30Prize
open Ruliology.CellularAutomata.Rule30Realization

lemma evol_succ (x0 : ℤ → Bool) (t : ℕ) (i : ℤ) :
    evol x0 (t + 1) i = xor (evol x0 t (i - 1)) (evol x0 t i || evol x0 t (i + 1)) := rfl

lemma edge (x0 : ℤ → Bool) (e : ℤ) (he : x0 e = true) (hl : ∀ j < e, x0 j = false) (t : ℕ) :
    evol x0 t (e - t) = true ∧ ∀ j < e - t, evol x0 t j = false := by
  induction t with
  | zero => simpa using ⟨he, hl⟩
  | succ t ih =>
    obtain ⟨h1, h2⟩ := ih
    constructor
    · rw [evol_succ]
      have a1 : evol x0 t (e - ↑(t + 1) - 1) = false := h2 _ (by push_cast; omega)
      have a2 : evol x0 t (e - ↑(t + 1)) = false := h2 _ (by push_cast; omega)
      have a3 : e - ↑(t + 1) + 1 = e - ↑t := by push_cast; ring
      rw [a1, a2, a3, h1]; rfl
    · intro j hj
      rw [evol_succ]
      have b1 : evol x0 t (j - 1) = false := h2 _ (by push_cast at hj; omega)
      have b2 : evol x0 t j = false := h2 _ (by push_cast at hj; omega)
      have b3 : evol x0 t (j + 1) = false := h2 _ (by push_cast at hj; omega)
      rw [b1, b2, b3]; rfl

/-- Diagonal k at time t. -/
def D (x0 : ℤ → Bool) (e : ℤ) (k : ℤ) (t : ℕ) : Bool := evol x0 t (e - t + k)

lemma D_succ (x0 : ℤ → Bool) (e j : ℤ) (t : ℕ) :
    D x0 e j (t + 1) = xor (D x0 e (j - 2) t) (D x0 e (j - 1) t || D x0 e j t) := by
  unfold D
  rw [evol_succ]
  rw [show e - ((t + 1 : ℕ) : ℤ) + j - 1 = e - t + (j - 2) by push_cast; ring,
    show e - ((t + 1 : ℕ) : ℤ) + j = e - t + (j - 1) by push_cast; ring,
    show e - (t : ℤ) + (j - 1) + 1 = e - t + j by ring]

/-! ### One bit forced by periodic inputs -/

section forced
variable (a b x : ℕ → Bool) (T p : ℕ) (ha : ∀ t, T ≤ t → a (t + p) = a t) (hb : ∀ t, T ≤ t → b (t + p) = b t)
  (hx : ∀ t, x (t + 1) = xor (a t) (b t || x t))

include ha in
lemma per_iter : ∀ m t, T ≤ t → a (t + m * p) = a t := by
  intro m
  induction m with
  | zero => intro t _; simp
  | succ m ih =>
    intro t ht
    rw [show t + (m + 1) * p = (t + m * p) + p by ring, ha _ (le_trans ht (Nat.le_add_right _ _)), ih t ht]

include ha hb hx in
/-- Equal states with equal (periodic) inputs have equal futures. -/
lemma det (m : ℕ) (s : ℕ) (hs : T ≤ s) (h0 : x s = x (s + m * p)) : ∀ k, x (s + k) = x (s + m * p + k) := by
  intro k
  induction k with
  | zero => simpa using h0
  | succ k ih =>
    rw [show s + (k + 1) = (s + k) + 1 by ring, show s + m * p + (k + 1) = (s + m * p + k) + 1 by ring, hx, hx,
      ← ih, show s + m * p + k = (s + k) + m * p by ring, per_iter a T p ha m (s + k) (by omega),
      per_iter b T p hb m (s + k) (by omega)]

lemma pigeon (u v w : Bool) : u = v ∨ u = w ∨ v = w := by
  cases u <;> cases v <;> cases w <;> simp

include ha hb hx in
/-- Period 2p from T + p. -/
lemma forced_periodic : ∀ t, T + p ≤ t → x (t + 2 * p) = x t := by
  have key : x (T + p) = x (T + p + 2 * p) := by
    rcases pigeon (x T) (x (T + p)) (x (T + 2 * p)) with h | h | h
    · -- x T = x (T + p)
      have d := det a b x T p ha hb hx 1 T le_rfl (by simpa using h)
      have e1 := d p
      have e2 := d (2 * p)
      rw [show T + 1 * p + p = T + 2 * p by ring] at e1
      rw [show T + 1 * p + 2 * p = T + p + 2 * p by ring] at e2
      rw [e1, e2]
    · -- x T = x (T + 2p)
      have d := det a b x T p ha hb hx 2 T le_rfl (by simpa using h)
      have e1 := d p
      rw [show T + 2 * p + p = T + p + 2 * p by ring] at e1
      exact e1
    · -- x (T + p) = x (T + 2p)
      have d := det a b x T p ha hb hx 1 (T + p) (Nat.le_add_right _ _) (by
        rw [show T + p + 1 * p = T + 2 * p by ring]; exact h)
      have e1 := d p
      rw [show T + p + p = T + 2 * p by ring, show T + p + 1 * p + p = T + p + 2 * p by ring] at e1
      rw [h, e1]
  have d := det a b x T p ha hb hx 2 (T + p) (Nat.le_add_right _ _) key
  intro t ht
  have := d (t - (T + p))
  rw [show T + p + (t - (T + p)) = t by omega, show T + p + 2 * p + (t - (T + p)) = t + 2 * p by omega] at this
  exact this.symm

end forced

/-! ### The diagonals -/

section diagonals
variable (x0 : ℤ → Bool) (e : ℤ) (he : x0 e = true) (hl : ∀ j < e, x0 j = false)
include he hl

lemma D0 (t : ℕ) : D x0 e 0 t = true := by
  unfold D; simpa using (edge x0 e he hl t).1

lemma Dneg (k : ℤ) (hk : k < 0) (t : ℕ) : D x0 e k t = false := by
  unfold D; exact (edge x0 e he hl t).2 _ (by omega)

lemma D1 (t : ℕ) (ht : 1 ≤ t) : D x0 e 1 t = true := by
  obtain ⟨s, rfl⟩ : ∃ s, t = s + 1 := ⟨t - 1, by omega⟩
  rw [D_succ, Dneg x0 e he hl _ (by norm_num), show (1 : ℤ) - 1 = 0 by norm_num, D0 x0 e he hl]; rfl

lemma D2 (t : ℕ) (ht : 2 ≤ t) : D x0 e 2 t = false := by
  obtain ⟨s, rfl⟩ : ∃ s, t = s + 1 := ⟨t - 1, by omega⟩
  rw [D_succ, show (2 : ℤ) - 2 = 0 by norm_num, show (2 : ℤ) - 1 = 1 by norm_num, D0 x0 e he hl,
    D1 x0 e he hl s (by omega)]; rfl

/-- The left diagonals' periods: every diagonal k ≤ j + 2 has period 2^j from some time on. -/
theorem jen_pow2 : ∀ j : ℕ, ∃ T : ℕ, ∀ k : ℤ, k ≤ j + 2 → ∀ t, T ≤ t → D x0 e k (t + 2 ^ j) = D x0 e k t := by
  intro j
  induction j with
  | zero =>
    refine ⟨2, fun k hk t ht => ?_⟩
    simp only [pow_zero]
    rcases (show k < 0 ∨ k = 0 ∨ k = 1 ∨ k = 2 by push_cast at hk; omega) with h | h | h | h
    · rw [Dneg x0 e he hl k h, Dneg x0 e he hl k h]
    · subst h; rw [D0 x0 e he hl, D0 x0 e he hl]
    · subst h; rw [D1 x0 e he hl _ (by omega), D1 x0 e he hl _ (by omega)]
    · subst h; rw [D2 x0 e he hl _ (by omega), D2 x0 e he hl _ (by omega)]
  | succ j ih =>
    obtain ⟨T, hT⟩ := ih
    have hp : 1 ≤ 2 ^ j := Nat.one_le_two_pow
    refine ⟨T + 2 ^ j, fun k hk t ht => ?_⟩
    rw [pow_succ]
    rcases (show k ≤ (j : ℤ) + 2 ∨ k = (j : ℤ) + 3 by push_cast at hk; omega) with h | h
    · -- already periodic with 2^j, hence with 2 · 2^j
      rw [show t + 2 ^ j * 2 = (t + 2 ^ j) + 2 ^ j by ring, hT k h (t + 2 ^ j) (by omega), hT k h t (by omega)]
    · -- the new diagonal, forced by two periodic ones
      have F := forced_periodic (fun t => D x0 e (k - 2) t) (fun t => D x0 e (k - 1) t) (fun t => D x0 e k t)
        T (2 ^ j) (fun t ht => hT (k - 2) (by omega) t ht) (fun t ht => hT (k - 1) (by omega) t ht)
        (fun t => D_succ x0 e k t) t ht
      rw [show 2 ^ j * 2 = 2 * 2 ^ j by ring]
      exact F

end diagonals

/-! ### Lemma B3's sharp form (as in LemmaB3.lean) and the run bound -/

lemma constraint (x0 : ℤ → Bool) (e k : ℤ) (τ : ℕ) (h : D x0 e k (τ + 1) = false) :
    D x0 e (k - 2) τ = (D x0 e (k - 1) τ || D x0 e k τ) := by
  rw [D_succ] at h
  revert h
  cases D x0 e (k - 2) τ <;> cases (D x0 e (k - 1) τ || D x0 e k τ) <;> simp

lemma back (x0 : ℤ → Bool) (e g M' : ℤ) (τ : ℕ) (hgM : g + 1 ≤ M') (hg : D x0 e g (τ + 1) = true)
    (hw : ∀ k, g + 1 ≤ k → k ≤ M' → D x0 e k (τ + 1) = false) :
    ((∀ k, g - 1 ≤ k → k ≤ M' → D x0 e k τ = false) ∧ D x0 e (g - 2) τ = true) ∨
    ((∀ k, g - 1 ≤ k → k ≤ M' - 2 → D x0 e k τ = true) ∧ (D x0 e (M' - 1) τ = true ∨ D x0 e M' τ = true)) := by
  by_cases hall : ∀ k, g - 1 ≤ k → k ≤ M' → D x0 e k τ = false
  · left
    refine ⟨hall, ?_⟩
    have := hg
    rw [D_succ, hall (g - 1) le_rfl (by omega), hall g (by omega) (by omega)] at this
    simpa using this
  · right
    push Not at hall
    obtain ⟨k0, hk0a, hk0b, hk0⟩ := hall
    have hk0' : D x0 e k0 τ = true := by simpa using hk0
    have top : D x0 e (M' - 1) τ = true ∨ D x0 e M' τ = true := by
      by_contra hn
      push Not at hn
      have h1 : D x0 e (M' - 1) τ = false := by simpa using hn.1
      have h2 : D x0 e M' τ = false := by simpa using hn.2
      have down : ∀ n : ℕ, ∀ k, k = M' - n → g - 1 ≤ k → D x0 e k τ = false := by
        intro n
        induction n using Nat.strong_induction_on with
        | _ n ih =>
          intro k hk hkg
          rcases n with _ | _ | n
          · rw [hk]; simpa using h2
          · rw [hk]; simpa using h1
          · have c := constraint x0 e (k + 2) τ (hw (k + 2) (by omega) (by omega))
            rw [show k + 2 - 2 = k by ring, show k + 2 - 1 = k + 1 by ring,
              ih (n + 1) (by omega) (k + 1) (by push_cast at hk ⊢; omega) (by omega),
              ih n (by omega) (k + 2) (by push_cast at hk ⊢; omega) (by omega)] at c
            simpa using c
      have := down (M' - k0).toNat k0 (by omega) hk0a
      rw [hk0'] at this; exact absurd this (by decide)
    have downB : ∀ n : ℕ, ∀ k, k = M' - 2 - n → g - 1 ≤ k → D x0 e k τ = true := by
      intro n
      induction n with
      | zero =>
        intro k hk hkg
        have c := constraint x0 e (k + 2) τ (hw (k + 2) (by omega) (by omega))
        rw [show k + 2 - 2 = k by ring, show k + 2 - 1 = k + 1 by ring] at c
        rw [c]
        rcases top with h | h
        · rw [show k + 1 = M' - 1 by push_cast at hk; omega, h]; rfl
        · rw [show k + 2 = M' by push_cast at hk; omega, h]; simp
      | succ n ih =>
        intro k hk hkg
        have c := constraint x0 e (k + 2) τ (hw (k + 2) (by omega) (by push_cast at hk; omega))
        rw [show k + 2 - 2 = k by ring, show k + 2 - 1 = k + 1 by ring] at c
        rw [c, ih (k + 1) (by push_cast at hk ⊢; omega) (by omega)]; rfl
    exact ⟨fun k hk1 hk2 => downB (M' - 2 - k).toNat k (by omega) hk1, top⟩

lemma fwd (x0 : ℤ → Bool) (e g M' : ℤ) (τ0 : ℕ) (hw : ∀ k, g + 1 ≤ k → k ≤ M' → D x0 e k τ0 = false) :
    ∀ r : ℕ, ∀ k, g + 1 + 2 * r ≤ k → k ≤ M' → D x0 e k (τ0 + r) = false := by
  intro r
  induction r with
  | zero => intro k h1 h2; simpa using hw k (by simpa using h1) h2
  | succ r ih =>
    intro k h1 h2
    rw [show τ0 + (r + 1) = (τ0 + r) + 1 by ring, D_succ, ih (k - 2) (by push_cast at h1; omega) (by omega),
      ih (k - 1) (by push_cast at h1; omega) (by omega), ih k (by push_cast at h1; omega) h2]
    rfl

theorem lemma_B3_sharp (x0 : ℤ → Bool) (e : ℤ) (t P : ℕ) (g M' M : ℤ) (hP : 1 ≤ P) (htP : P ≤ t)
    (hgM : g + 1 ≤ M') (hM : M' ≤ M) (hper : ∀ k, k ≤ M → D x0 e k (t - P) = D x0 e k t)
    (hg : D x0 e g t = true) (hw : ∀ k, g + 1 ≤ k → k ≤ M' → D x0 e k t = false) : M' - g ≤ 2 * P - 1 := by
  let A : ℕ → Prop := fun s => (∀ k, g - 2 * s + 1 ≤ k → k ≤ M' → D x0 e k (t - s) = false) ∧
    D x0 e (g - 2 * s) (t - s) = true
  let B : ℕ → Prop := fun s0 => (∀ k, g - 2 * s0 - 1 ≤ k → k ≤ M' - 2 → D x0 e k (t - s0 - 1) = true) ∧
    (D x0 e (M' - 1) (t - s0 - 1) = true ∨ D x0 e M' (t - s0 - 1) = true)
  have chain : ∀ s : ℕ, s ≤ P → A s ∨ ∃ s0, s0 < s ∧ B s0 := by
    intro s
    induction s with
    | zero => intro _; left; exact ⟨fun k h1 h2 => by simpa using hw k (by simpa using h1) h2, by simpa using hg⟩
    | succ s ih =>
      intro hs
      rcases ih (by omega) with hA | ⟨s0, hs0, hB⟩
      · obtain ⟨hAw, hAb⟩ := hA
        have ht : t - s = (t - s - 1) + 1 := by omega
        rw [ht] at hAw hAb
        rcases back x0 e (g - 2 * s) M' (t - s - 1) (by omega) hAb hAw with ⟨hw2, hb2⟩ | ⟨hB, htop⟩
        · left
          refine ⟨fun k h1 h2 => ?_, ?_⟩
          · rw [show t - (s + 1) = t - s - 1 by omega]; exact hw2 k (by push_cast at h1; omega) h2
          · rw [show t - (s + 1) = t - s - 1 by omega, show g - 2 * ((s + 1 : ℕ) : ℤ) = g - 2 * s - 2 by
              push_cast; ring]; exact hb2
        · right
          exact ⟨s, by omega, fun k h1 h2 => hB k (by omega) h2, htop⟩
      · right; exact ⟨s0, by omega, hB⟩
  rcases chain P le_rfl with hA | ⟨s0, hs0, hB⟩
  · exfalso
    have := hA.1 g (by omega) (by omega)
    rw [hper g (by omega), hg] at this
    exact absurd this (by decide)
  · obtain ⟨-, hBt⟩ := hB
    have hw0 : ∀ k, g + 1 ≤ k → k ≤ M' → D x0 e k (t - P) = false := fun k h1 h2 => by
      rw [hper k (by omega)]; exact hw k h1 h2
    have F := fwd x0 e g M' (t - P) hw0 (P - s0 - 1)
    rw [show t - P + (P - s0 - 1) = t - s0 - 1 by omega] at F
    by_contra hlong
    push Not at hlong
    rcases hBt with h | h
    · rw [F (M' - 1) (by omega) (by omega)] at h
      exact absurd h (by decide)
    · rw [F M' (by omega) le_rfl] at h
      exact absurd h (by decide)

/-- From some time on, every white run in the diagonals up to j + 2 is at most 2^(j+1) - 1 long. -/
theorem run_bound (x0 : ℤ → Bool) (e : ℤ) (he : x0 e = true) (hl : ∀ j < e, x0 j = false) (j : ℕ) :
    ∃ T : ℕ, ∀ t, T ≤ t → ∀ g M' : ℤ, g + 1 ≤ M' → M' ≤ j + 2 → D x0 e g t = true →
      (∀ k, g + 1 ≤ k → k ≤ M' → D x0 e k t = false) → M' - g ≤ 2 ^ (j + 1) - 1 := by
  obtain ⟨T, hT⟩ := jen_pow2 x0 e he hl j
  refine ⟨T + 2 ^ j, fun t ht g M' hgM hM hg hw => ?_⟩
  have hp : 1 ≤ 2 ^ j := Nat.one_le_two_pow
  have := lemma_B3_sharp x0 e t (2 ^ j) g M' ((j : ℤ) + 2) hp (by omega) hgM hM (fun k hk => by
    have := hT k hk (t - 2 ^ j) (by omega)
    rw [show t - 2 ^ j + 2 ^ j = t by omega] at this
    exact this.symm) hg hw
  rw [pow_succ]
  push_cast at this ⊢
  linarith

/-! ### Periods combine by gcd, and the v2 run bound (settled form) -/

section gcdper
variable (x : ℕ → Bool) (T : ℕ)

lemma per_mul (p : ℕ) (hp : ∀ t, T ≤ t → x (t + p) = x t) : ∀ m t, T ≤ t → x (t + m * p) = x t := by
  intro m
  induction m with
  | zero => intro t _; simp
  | succ m ih =>
    intro t ht
    rw [show t + (m + 1) * p = (t + m * p) + p by ring, hp _ (le_trans ht (Nat.le_add_right _ _)), ih t ht]

lemma per_sub (p q : ℕ) (hp : ∀ t, T ≤ t → x (t + p) = x t) (hq : ∀ t, T ≤ t → x (t + q) = x t) (hqp : q ≤ p) :
    ∀ t, T ≤ t → x (t + (p - q)) = x t := by
  intro t ht
  rw [← hq (t + (p - q)) (by omega), show t + (p - q) + q = t + p by omega, hp t ht]

/-- Two periods give their gcd (Euclid on periods). -/
lemma per_gcd : ∀ m n : ℕ, (∀ t, T ≤ t → x (t + m) = x t) → (∀ t, T ≤ t → x (t + n) = x t) →
    ∀ t, T ≤ t → x (t + Nat.gcd m n) = x t := by
  intro m n
  induction m, n using Nat.gcd.induction with
  | H0 n => intro _ hn; simpa using hn
  | H1 m n _ ih =>
    intro hm hn
    rw [Nat.gcd_rec]
    apply ih _ hm
    have hmod : n % m = n - m * (n / m) := Nat.eq_sub_of_add_eq (Nat.mod_add_div n m)
    rw [hmod]
    exact per_sub x T n (m * (n / m)) hn
      (fun t ht => by rw [mul_comm]; exact per_mul x T m hm (n / m) t ht) (Nat.mul_div_le n m)

end gcdper

/-- The v2 bound, settled form: if the diagonals up to j + 2 have period P from some time, then from some later time
every white run there is at most 2 gcd(P, 2^j) - 1 long (so at most 1 for odd P). -/
theorem run_bound_gcd (x0 : ℤ → Bool) (e : ℤ) (he : x0 e = true) (hl : ∀ j < e, x0 j = false) (j P T0 : ℕ)
    (hset : ∀ k : ℤ, k ≤ j + 2 → ∀ t, T0 ≤ t → D x0 e k (t + P) = D x0 e k t) :
    ∃ T : ℕ, ∀ t, T ≤ t → ∀ g M' : ℤ, g + 1 ≤ M' → M' ≤ j + 2 → D x0 e g t = true →
      (∀ k, g + 1 ≤ k → k ≤ M' → D x0 e k t = false) → M' - g ≤ 2 * (Nat.gcd P (2 ^ j) : ℤ) - 1 := by
  obtain ⟨T1, hT1⟩ := jen_pow2 x0 e he hl j
  set c := Nat.gcd P (2 ^ j) with hc
  have hc1 : 1 ≤ c := Nat.gcd_pos_of_pos_right _ (Nat.two_pow_pos j)
  have hper : ∀ k : ℤ, k ≤ j + 2 → ∀ t, T0 + T1 ≤ t → D x0 e k (t + c) = D x0 e k t := by
    intro k hk
    exact per_gcd (fun t => D x0 e k t) (T0 + T1) P (2 ^ j)
      (fun t ht => hset k hk t (by omega)) (fun t ht => hT1 k hk t (by omega))
  refine ⟨T0 + T1 + c, fun t ht g M' hgM hM hg hw => ?_⟩
  exact lemma_B3_sharp x0 e t c g M' ((j : ℤ) + 2) hc1 (by omega) hgM hM (fun k hk => by
    have := hper k hk (t - c) (by omega)
    rw [show t - c + c = t by omega] at this
    exact this.symm) hg hw

/-! ### Lemma B2 and entry 9's corollary: infinitely many eventually white and eventually black diagonals -/

/-- The recurrence read backwards. -/
lemma D_back (x0 : ℤ → Bool) (e m : ℤ) (t : ℕ) :
    D x0 e (m - 2) t = xor (D x0 e m (t + 1)) (D x0 e (m - 1) t || D x0 e m t) := by
  rw [D_succ]
  cases D x0 e (m - 2) t <;> cases (D x0 e (m - 1) t || D x0 e m t) <;> rfl

/-- Two sequences with period P from T that agree on [T, T + P) agree from T on. -/
lemma ext_window (u v : ℕ → Bool) (T P : ℕ) (hP : 1 ≤ P) (hu : ∀ t, T ≤ t → u (t + P) = u t)
    (hv : ∀ t, T ≤ t → v (t + P) = v t) (hw : ∀ s, s < P → u (T + s) = v (T + s)) :
    ∀ t, T ≤ t → u t = v t := by
  intro t
  induction t using Nat.strong_induction_on with
  | _ t ih =>
    intro ht
    by_cases h : t < T + P
    · have := hw (t - T) (by omega)
      rwa [show T + (t - T) = t by omega] at this
    · have e1 := hu (t - P) (by omega)
      have e2 := hv (t - P) (by omega)
      rw [show t - P + P = t by omega] at e1 e2
      rw [e1, e2, ih (t - P) (by omega) (by omega)]

/-- A black input resets: once D_(k-1) is black at a time t0 ≥ T, D_k inherits its inputs' period p. -/
lemma reset (a b x : ℕ → Bool) (T p : ℕ) (ha : ∀ t, T ≤ t → a (t + p) = a t) (hb : ∀ t, T ≤ t → b (t + p) = b t)
    (hx : ∀ t, x (t + 1) = xor (a t) (b t || x t)) (t0 : ℕ) (ht0 : T ≤ t0) (hb1 : b t0 = true) :
    ∀ t, t0 + 1 ≤ t → x (t + p) = x t := by
  have h1 : x (t0 + 1 + 1 * p) = x (t0 + 1) := by
    simp only [show t0 + 1 + 1 * p = (t0 + p) + 1 by ring, hx, ha t0 ht0, hb t0 ht0, hb1, Bool.true_or]
  have d := det a b x T p ha hb hx 1 (t0 + 1) (by omega) h1.symm
  intro t ht
  have := d (t - (t0 + 1))
  rw [show t0 + 1 + (t - (t0 + 1)) = t by omega, show t0 + 1 + 1 * p + (t - (t0 + 1)) = t + p by omega] at this
  exact this.symm

/-- Eventually white / eventually black (as in LemmaB1.lean). -/
def EvW (x0 : ℤ → Bool) (e j : ℤ) : Prop := ∃ T : ℕ, ∀ t, T ≤ t → D x0 e j t = false
def EvB (x0 : ℤ → Bool) (e j : ℤ) : Prop := ∃ T : ℕ, ∀ t, T ≤ t → D x0 e j t = true

section band
variable (x0 : ℤ → Bool) (e : ℤ) (he : x0 e = true) (hl : ∀ j < e, x0 j = false)
include he hl

/-- Lemma B2, quantitative: some diagonal k ≤ 4^P + 1 does not have eventual period P (the form of Nersissian's
m + 2 ≤ 4^(Q_m), here for every configuration with a leftmost black cell). -/
theorem lemma_B2_quant (P : ℕ) (hP : 1 ≤ P) :
    ¬ ∀ k : ℕ, k ≤ 4 ^ P + 1 → ∃ T : ℕ, ∀ t, T ≤ t → D x0 e k (t + P) = D x0 e k t := by
  intro h
  have common : ∀ n : ℕ, n ≤ 4 ^ P + 1 →
      ∃ Ts, ∀ k : ℕ, k ≤ n → ∀ t, Ts ≤ t → D x0 e k (t + P) = D x0 e k t := by
    intro n
    induction n with
    | zero =>
      intro hn
      obtain ⟨T, hT⟩ := h 0 (by omega)
      exact ⟨T, fun k hk t ht => by
        have : k = 0 := by omega
        subst this; exact hT t ht⟩
    | succ n ih =>
      intro hn
      obtain ⟨T1, h1⟩ := ih (by omega)
      obtain ⟨T2, h2⟩ := h (n + 1) hn
      exact ⟨T1 + T2, fun k hk t ht => by
        rcases (show k ≤ n ∨ k = n + 1 by omega) with hk' | hk'
        · exact h1 k hk' t (by omega)
        · subst hk'; exact h2 t (by omega)⟩
  obtain ⟨Ts, hper⟩ := common (4 ^ P + 1) le_rfl
  have hper1 : ∀ k : ℕ, k ≤ 4 ^ P → ∀ t, Ts ≤ t → D x0 e ((k : ℤ) + 1) (t + P) = D x0 e ((k : ℤ) + 1) t := by
    intro k hk t ht
    have := hper (k + 1) (by omega) t ht
    push_cast at this
    exact this
  -- the windows (D_k, D_(k+1)) on [Ts, Ts + P)
  let f : Fin (4 ^ P + 1) → (Fin P → Bool) × (Fin P → Bool) :=
    fun k => (fun s => D x0 e ((k : ℕ) : ℤ) (Ts + s), fun s => D x0 e (((k : ℕ) : ℤ) + 1) (Ts + s))
  have hcard : Fintype.card ((Fin P → Bool) × (Fin P → Bool)) < Fintype.card (Fin (4 ^ P + 1)) := by
    simp only [Fintype.card_prod, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
    rw [← mul_pow]
    norm_num
  obtain ⟨a, b, hab, hfab⟩ := Fintype.exists_ne_map_eq_of_card_lt f hcard
  -- two equal windows at k1 < k2 give a contradiction
  have key : ∀ k1 k2 : ℕ, k1 < k2 → k2 ≤ 4 ^ P →
      (∀ s, s < P → D x0 e (k1 : ℤ) (Ts + s) = D x0 e (k2 : ℤ) (Ts + s)) →
      (∀ s, s < P → D x0 e ((k1 : ℤ) + 1) (Ts + s) = D x0 e ((k2 : ℤ) + 1) (Ts + s)) → False := by
    intro k1 k2 hlt hk2 w0 w1
    have E0 := ext_window (fun t => D x0 e (k1 : ℤ) t) (fun t => D x0 e (k2 : ℤ) t) Ts P hP
      (hper k1 (by omega)) (hper k2 (by omega)) w0
    have E1 := ext_window (fun t => D x0 e ((k1 : ℤ) + 1) t) (fun t => D x0 e ((k2 : ℤ) + 1) t) Ts P hP
      (hper1 k1 (by omega)) (hper1 k2 hk2) w1
    have Q : ∀ j : ℕ, ∀ t, Ts ≤ t → D x0 e ((k1 : ℤ) + 1 - j) t = D x0 e ((k2 : ℤ) + 1 - j) t ∧
        D x0 e ((k1 : ℤ) - j) t = D x0 e ((k2 : ℤ) - j) t := by
      intro j
      induction j with
      | zero => intro t ht; simpa using And.intro (E1 t ht) (E0 t ht)
      | succ j ih =>
        intro t ht
        obtain ⟨h1, h0⟩ := ih t ht
        obtain ⟨h1', -⟩ := ih (t + 1) (by omega)
        refine ⟨?_, ?_⟩
        · rw [show (k1 : ℤ) + 1 - ((j + 1 : ℕ) : ℤ) = k1 - j by push_cast; ring,
            show (k2 : ℤ) + 1 - ((j + 1 : ℕ) : ℤ) = k2 - j by push_cast; ring]
          exact h0
        · have b1 := D_back x0 e ((k1 : ℤ) + 1 - j) t
          have b2 := D_back x0 e ((k2 : ℤ) + 1 - j) t
          rw [show (k1 : ℤ) + 1 - j - 2 = k1 - ((j + 1 : ℕ) : ℤ) by push_cast; ring,
            show (k1 : ℤ) + 1 - j - 1 = k1 - j by ring] at b1
          rw [show (k2 : ℤ) + 1 - j - 2 = k2 - ((j + 1 : ℕ) : ℤ) by push_cast; ring,
            show (k2 : ℤ) + 1 - j - 1 = k2 - j by ring] at b2
          rw [b1, b2, h1', h0, h1]
    have := (Q k2 Ts le_rfl).2
    rw [Dneg x0 e he hl ((k1 : ℤ) - k2) (by omega), sub_self, D0 x0 e he hl] at this
    exact absurd this (by decide)
  have hv : (a : ℕ) ≠ (b : ℕ) := fun h => hab (Fin.ext h)
  have w0 : ∀ s, s < P → D x0 e ((a : ℕ) : ℤ) (Ts + s) = D x0 e ((b : ℕ) : ℤ) (Ts + s) :=
    fun s hs => congrFun (congrArg Prod.fst hfab) ⟨s, hs⟩
  have w1 : ∀ s, s < P → D x0 e (((a : ℕ) : ℤ) + 1) (Ts + s) = D x0 e (((b : ℕ) : ℤ) + 1) (Ts + s) :=
    fun s hs => congrFun (congrArg Prod.snd hfab) ⟨s, hs⟩
  rcases Nat.lt_or_gt_of_ne hv with hlt | hlt
  · exact key a b hlt (by omega) w0 w1
  · exact key b a hlt (by omega) (fun s hs => (w0 s hs).symm) (fun s hs => (w1 s hs).symm)

/-- Lemma B2: no P ≥ 1 is an eventual period of every diagonal. -/
theorem lemma_B2 (P : ℕ) (hP : 1 ≤ P) :
    ¬ ∀ k : ℕ, ∃ T : ℕ, ∀ t, T ≤ t → D x0 e k (t + P) = D x0 e k t :=
  fun h => lemma_B2_quant x0 e he hl P hP (fun k _ => h k)

/-- Entry 9's corollary: for every N some diagonal k ≥ N is eventually white. -/
theorem infinitely_many_white (N : ℕ) : ∃ k : ℕ, N ≤ k ∧ EvW x0 e k := by
  by_contra hno
  push Not at hno
  have hinf : ∀ k : ℕ, N ≤ k → ∀ T, ∃ t, T ≤ t ∧ D x0 e k t = true := by
    intro k hk T
    by_contra hc
    push Not at hc
    exact hno k hk ⟨T, fun t ht => by simpa using hc t ht⟩
  obtain ⟨T0, hT0⟩ := jen_pow2 x0 e he hl N
  have grow : ∀ m : ℕ, ∃ T, ∀ k : ℤ, k ≤ (N : ℤ) + 2 + m → ∀ t, T ≤ t → D x0 e k (t + 2 ^ N) = D x0 e k t := by
    intro m
    induction m with
    | zero => exact ⟨T0, fun k hk t ht => hT0 k (by simpa using hk) t ht⟩
    | succ m ih =>
      obtain ⟨T, hT⟩ := ih
      obtain ⟨t0, ht0, hb1⟩ := hinf (N + 2 + m) (by omega) T
      refine ⟨t0 + 1, fun k hk t ht => ?_⟩
      rcases (show k ≤ (N : ℤ) + 2 + m ∨ k = (N : ℤ) + 2 + m + 1 by push_cast at hk; omega) with h | h
      · exact hT k h t (by omega)
      · exact reset (fun t => D x0 e (k - 2) t) (fun t => D x0 e (k - 1) t) (fun t => D x0 e k t) T (2 ^ N)
          (fun t ht => hT (k - 2) (by omega) t ht) (fun t ht => hT (k - 1) (by omega) t ht)
          (fun t => D_succ x0 e k t) t0 ht0 (by
            show D x0 e (k - 1) t0 = true
            rw [show k - 1 = ((N + 2 + m : ℕ) : ℤ) by push_cast; omega]
            exact hb1) t ht
  exact lemma_B2 x0 e he hl (2 ^ N) Nat.one_le_two_pow (fun k => by
    obtain ⟨T, hT⟩ := grow k
    exact ⟨T, fun t ht => hT k (by omega) t ht⟩)

omit he hl in
lemma down (j : ℤ) (h0 : EvW x0 e j) (h1 : EvW x0 e (j + 1)) : EvW x0 e (j - 1) := by
  obtain ⟨T0, h0⟩ := h0
  obtain ⟨T1, h1⟩ := h1
  refine ⟨T0 + T1, fun t ht => ?_⟩
  have := h1 (t + 1) (by omega)
  rw [D_succ, show j + 1 - 2 = j - 1 by ring, show j + 1 - 1 = j by ring, h0 t (by omega), h1 t (by omega)] at this
  simpa using this

/-- B1 (1), as in LemmaB1.lean. -/
theorem no_adjacent_white (j : ℤ) (hj : 0 ≤ j) (h0 : EvW x0 e j) (h1 : EvW x0 e (j + 1)) : False := by
  have key : ∀ n : ℕ, ∀ j : ℤ, j = n → EvW x0 e j → EvW x0 e (j + 1) → False := by
    intro n
    induction n with
    | zero =>
      intro j hjn hw _
      obtain ⟨T, hT⟩ := hw
      have := hT T le_rfl
      rw [hjn, show ((0 : ℕ) : ℤ) = 0 by simp, D0 x0 e he hl] at this
      exact absurd this (by decide)
    | succ n ih =>
      intro j hjn hw hw1
      exact ih (j - 1) (by rw [hjn]; push_cast; ring) (down x0 e j hw hw1) (by simpa using hw)
  exact key j.toNat j (by omega) h0 h1

omit he hl in
lemma mono_eventually (j : ℤ) (T : ℕ) (hm : ∀ t, T ≤ t → D x0 e j t = true → D x0 e j (t + 1) = true) :
    EvW x0 e j ∨ EvB x0 e j := by
  by_cases h : ∃ t, T ≤ t ∧ D x0 e j t = true
  · obtain ⟨t0, ht0, hb⟩ := h
    right
    refine ⟨t0, fun t ht => ?_⟩
    induction t, ht using Nat.le_induction with
    | base => exact hb
    | succ t ht ih => exact hm t (by omega) ih
  · push Not at h
    left
    exact ⟨T, fun t ht => by simpa using h t ht⟩

/-- B1 (2), as in LemmaB1.lean. -/
theorem white_then_black (j : ℤ) (hj : 0 ≤ j) (h0 : EvW x0 e j) : EvB x0 e (j + 2) := by
  obtain ⟨T, hT⟩ := h0
  have hm : ∀ t, T ≤ t → D x0 e (j + 2) t = true → D x0 e (j + 2) (t + 1) = true := by
    intro t ht hb
    rw [D_succ, show j + 2 - 2 = j by ring, hT t ht, hb]; simp
  rcases mono_eventually x0 e (j + 2) T hm with hw | hb
  · exfalso
    obtain ⟨T2, h2⟩ := hw
    have h1 : EvW x0 e (j + 1) := ⟨T + T2, fun t ht => by
      have := h2 (t + 1) (by omega)
      rw [D_succ, show j + 2 - 2 = j by ring, show j + 2 - 1 = j + 1 by ring, hT t (by omega)] at this
      simp at this
      exact this.1⟩
    exact no_adjacent_white x0 e he hl j hj ⟨T, hT⟩ h1
  · exact hb

/-- Entry 9's corollary: for every N some diagonal k ≥ N is eventually black. -/
theorem infinitely_many_black (N : ℕ) : ∃ k : ℕ, N ≤ k ∧ EvB x0 e k := by
  obtain ⟨k, hk, hw⟩ := infinitely_many_white x0 e he hl N
  refine ⟨k + 2, by omega, ?_⟩
  have := white_then_black x0 e he hl k (by omega) hw
  push_cast
  exact this

end band

/-- Read right to left: x_t(j - 1) from x_(t+1)(j), x_t(j) and x_t(j + 1). -/
lemma step_inv (x0 : ℤ → Bool) (t : ℕ) (j : ℤ) :
    evol x0 t (j - 1) = xor (evol x0 (t + 1) j) (evol x0 t j || evol x0 t (j + 1)) := by
  rw [evol_succ]
  cases evol x0 t (j - 1) <;> cases (evol x0 t j || evol x0 t (j + 1)) <;> rfl

/-- Equal blocks on columns i and i + 1 at times a .. a + n - 1 and a′ .. a′ + n - 1 make the rows agree: the cell
m to the left of column i agrees at times a + s and a′ + s whenever s + m < n. -/
lemma agree (x0 : ℤ → Bool) (i : ℤ) (n a a' : ℕ)
    (hblock : ∀ s : ℕ, s < n → evol x0 (a + s) i = evol x0 (a' + s) i ∧ evol x0 (a + s) (i + 1) = evol x0 (a' + s) (i + 1)) :
    ∀ m s : ℕ, s + m < n → evol x0 (a + s) (i - m) = evol x0 (a' + s) (i - m) := by
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro s hs
    rcases m with _ | m
    · simpa using (hblock s (by omega)).1
    · -- the cell m + 1 to the left from the cells m and m - 1 to the left (or column i + 1 when m = 0)
      have h1 : evol x0 (a + s + 1) (i - m) = evol x0 (a' + s + 1) (i - m) := by
        have := ih m (by omega) (s + 1) (by omega)
        rwa [show a + (s + 1) = a + s + 1 by ring, show a' + (s + 1) = a' + s + 1 by ring] at this
      have h2 : evol x0 (a + s) (i - m) = evol x0 (a' + s) (i - m) := ih m (by omega) s (by omega)
      have h3 : evol x0 (a + s) (i - m + 1) = evol x0 (a' + s) (i - m + 1) := by
        rcases m with _ | m
        · simpa using (hblock s (by omega)).2
        · have := ih m (by omega) s (by omega)
          rwa [show i - ((m : ℕ) : ℤ) = i - ((m + 1 : ℕ) : ℤ) + 1 by push_cast; ring] at this
      rw [show i - ((m + 1 : ℕ) : ℤ) = (i - m) - 1 by push_cast; ring, step_inv x0 (a + s), step_inv x0 (a' + s), h1, h2, h3]

/-- Theorem A′. -/
theorem theorem_A' (x0 : ℤ → Bool) (i : ℤ) (L : ℕ) (hc : x0 (i - L) = true) (hl : ∀ j < i - L, x0 j = false)
    (n a a' : ℕ) (haa : a < a')
    (hblock : ∀ s : ℕ, s < n → evol x0 (a + s) i = evol x0 (a' + s) i ∧ evol x0 (a + s) (i + 1) = evol x0 (a' + s) (i + 1)) :
    n ≤ L + a' := by
  by_contra h
  push Not at h
  have hag := agree x0 i n a a' hblock (L + a') 0 (by omega)
  simp only [add_zero] at hag
  have E := edge x0 (i - L) hc hl
  have black : evol x0 a' (i - ((L + a' : ℕ) : ℤ)) = true := by
    have := (E a').1
    rwa [show i - (L : ℤ) - (a' : ℤ) = i - ((L + a' : ℕ) : ℤ) by push_cast; ring] at this
  have white : evol x0 a (i - ((L + a' : ℕ) : ℤ)) = false :=
    (E a).2 _ (by push_cast; omega)
  rw [white, black] at hag
  exact absurd hag (by decide)

/-- Theorem A‴ (entry 10): row a′ is white at the distances L + a + 1 .. n - 1 left of column i, which are its
diagonals L + a′ - n + 1 .. a′ - a - 1. -/
theorem theorem_A3_white (x0 : ℤ → Bool) (i : ℤ) (L : ℕ) (hc : x0 (i - L) = true) (hl : ∀ j < i - L, x0 j = false)
    (n a a' : ℕ)
    (hblock : ∀ s : ℕ, s < n → evol x0 (a + s) i = evol x0 (a' + s) i ∧ evol x0 (a + s) (i + 1) = evol x0 (a' + s) (i + 1)) :
    ∀ δ : ℕ, L + a + 1 ≤ δ → δ + 1 ≤ n → evol x0 a' (i - δ) = false := by
  intro δ h1 h2
  have hag := agree x0 i n a a' hblock δ 0 (by omega)
  simp only [add_zero] at hag
  rw [← hag]
  exact (edge x0 (i - L) hc hl a).2 _ (by omega)

/-- Theorem A‴'s corollary: if diagonal b (the cell b right of the moving left edge) is black at time a′ and
b < a′ - a, then n ≤ L + a′ - b. -/
theorem theorem_A3 (x0 : ℤ → Bool) (i : ℤ) (L : ℕ) (hc : x0 (i - L) = true) (hl : ∀ j < i - L, x0 j = false)
    (n a a' b : ℕ) (hb : b + a < a') (hblack : evol x0 a' (i - L - a' + b) = true)
    (hblock : ∀ s : ℕ, s < n → evol x0 (a + s) i = evol x0 (a' + s) i ∧ evol x0 (a + s) (i + 1) = evol x0 (a' + s) (i + 1)) :
    n ≤ L + a' - b := by
  by_contra h
  push Not at h
  have hw := theorem_A3_white x0 i L hc hl n a a' hblock (L + a' - b) (by omega) (by omega)
  rw [show i - ((L + a' - b : ℕ) : ℤ) = i - L - a' + b by push_cast [show b ≤ L + a' by omega]; ring] at hw
  rw [hw] at hblack
  exact absurd hblack (by decide)

/-! ## Corollary F: near-squares at the start are fatal -/

/-- Column `-1` under the clock: black at odd times, the complement of column `1` at even times. -/
lemma col_m1 (x0 : ℤ → Bool) (T0 : ℕ) (hclock : ∀ t, T0 ≤ t → evol x0 t 0 = decide (t % 2 = 1)) (t : ℕ)
    (ht : T0 ≤ t) :
    (t % 2 = 1 → evol x0 t (-1) = true) ∧ (t % 2 = 0 → evol x0 t (-1) = !(evol x0 t 1)) := by
  have h := evol_succ x0 t 0
  simp only [zero_sub, zero_add] at h
  constructor
  · intro ho
    have hA : evol x0 t 0 = true := by rw [hclock t ht]; simp only [decide_eq_true_eq]; omega
    have hB : evol x0 (t + 1) 0 = false := by rw [hclock (t + 1) (by omega)]; simp only [decide_eq_false_iff_not]; omega
    rw [hA, hB] at h
    revert h; cases evol x0 t (-1) <;> simp
  · intro he
    have hA : evol x0 t 0 = false := by rw [hclock t ht]; simp only [decide_eq_false_iff_not]; omega
    have hB : evol x0 (t + 1) 0 = true := by rw [hclock (t + 1) (by omega)]; simp only [decide_eq_true_eq]; omega
    rw [hA, hB] at h
    revert h; cases evol x0 t (-1) <;> cases evol x0 t 1 <;> simp

/-- Visible bits agreeing for `l` steps make columns `-1` and `0` agree for `2l` steps. -/
lemma blocks_of_visible (x0 : ℤ → Bool) (T0 : ℕ) (hclock : ∀ t, T0 ≤ t → evol x0 t 0 = decide (t % 2 = 1))
    (i i' l : ℕ) (hi : T0 ≤ 2 * i) (hii : i ≤ i')
    (hvis : ∀ s, s < l → evol x0 (2 * (i + s)) 1 = evol x0 (2 * (i' + s)) 1) :
    ∀ u : ℕ, u < 2 * l → evol x0 (2 * i + u) (-1) = evol x0 (2 * i' + u) (-1) ∧
      evol x0 (2 * i + u) 0 = evol x0 (2 * i' + u) 0 := by
  intro u hu
  have h1 : T0 ≤ 2 * i + u := by omega
  have h2 : T0 ≤ 2 * i' + u := by omega
  constructor
  · rcases Nat.mod_two_eq_zero_or_one u with he | ho
    · obtain ⟨s, rfl⟩ : ∃ s, u = 2 * s := ⟨u / 2, by omega⟩
      have e1 := (col_m1 x0 T0 hclock (2 * i + 2 * s) h1).2 (by omega)
      have e2 := (col_m1 x0 T0 hclock (2 * i' + 2 * s) h2).2 (by omega)
      rw [e1, e2, show 2 * i + 2 * s = 2 * (i + s) by ring, show 2 * i' + 2 * s = 2 * (i' + s) by ring,
        hvis s (by omega)]
    · rw [(col_m1 x0 T0 hclock _ h1).1 (by omega), (col_m1 x0 T0 hclock _ h2).1 (by omega)]
  · rw [hclock _ h1, hclock _ h2, show (2 * i + u) % 2 = (2 * i' + u) % 2 by omega]

/-- **Corollary F.** A configuration with a leftmost black cell `L ≥ 1` cells left of column `0`, whose column `0`
reads the clock `0101…` from time `T0`, has no near-squares at unbounded scales in its visible bits
`evol x0 (2 i) 1`: there are no `K` and pairs `i < i′` with `i′ - i` unbounded, `T0 ≤ 2 i`, and
`evol x0 (2 (i + s)) 1 = evol x0 (2 (i′ + s)) 1` for all `s + K < i′`. -/
theorem corollary_F (x0 : ℤ → Bool) (L : ℕ) (hL : 1 ≤ L) (hc : x0 (-(L : ℤ)) = true)
    (hl : ∀ j < -(L : ℤ), x0 j = false)
    (T0 : ℕ) (hclock : ∀ t, T0 ≤ t → evol x0 t 0 = decide (t % 2 = 1)) (K : ℕ)
    (hpairs : ∀ N : ℕ, ∃ i i' : ℕ, i < i' ∧ N ≤ i' - i ∧ T0 ≤ 2 * i ∧
      ∀ s, s + K < i' → evol x0 (2 * (i + s)) 1 = evol x0 (2 * (i' + s)) 1) : False := by
  obtain ⟨b, hb, tb, htb⟩ := infinitely_many_black x0 (-(L : ℤ)) hc hl (L + 2 * K)
  obtain ⟨i, i', hii, hN, hT0, hvis⟩ := hpairs (b + tb + 1)
  have hK : K < i' := by omega
  have hblock := blocks_of_visible x0 T0 hclock i i' (i' - K) hT0 hii.le (fun s hs => hvis s (by omega))
  have hblack : evol x0 (2 * i') ((-1 : ℤ) - ((L - 1 : ℕ) : ℤ) - ((2 * i' : ℕ) : ℤ) + ((b : ℕ) : ℤ)) = true := by
    have h := htb (2 * i') (by omega)
    unfold D at h
    have e : (-1 : ℤ) - ((L - 1 : ℕ) : ℤ) - ((2 * i' : ℕ) : ℤ) + ((b : ℕ) : ℤ) =
        -(L : ℤ) - ((2 * i' : ℕ) : ℤ) + ((b : ℕ) : ℤ) := by omega
    rw [e]; exact h
  have hA3 := theorem_A3 x0 (-1) (L - 1)
    (by rw [show (-1 : ℤ) - ((L - 1 : ℕ) : ℤ) = -(L : ℤ) by omega]; exact hc)
    (fun j hj => hl j (by omega)) (2 * (i' - K)) (2 * i) (2 * i') b (by omega) hblack
    (fun s hs => by simpa using hblock s hs)
  omega


/-! ## Rotation words of one arc, started at an end -/

namespace RotationEndpoints


/-! ### Integer floors of the multiples of an irrational number -/

/-- The floors of the positive multiples of an irrational number, in integers: the intervals
`[f n / n, (f n + 1) / n]` meet pairwise, and no rational number lies in all of them. -/
structure IrrationalLine (f : Nat → Int) : Prop where
  floors : ∀ m n : Nat, 1 ≤ m → 1 ≤ n → (n : Int) * f m < m * (f n + 1)
  irrational : ∀ (p : Int) (q : Nat), 1 ≤ q →
    ∃ n : Nat, 1 ≤ n ∧ ((n : Int) * p < q * f n ∨ q * (f n + 1) < (n : Int) * p)

/-- `h < k β`, read off one of the intervals. -/
def Above (f : Nat → Int) (h k : Int) : Prop :=
  ∃ n : Nat, 1 ≤ n ∧ (n : Int) * h < k * f n ∧ (n : Int) * h < k * (f n + 1)

variable {f : Nat → Int}

theorem not_above_zero : ¬ Above f 0 0 := by
  rintro ⟨n, _, h, _⟩
  simp at h

theorem floors_refine (hf : IrrationalLine f) (m n : Nat) (hm : 1 ≤ m) (hn : 1 ≤ n) :
    (m : Int) * f n ≤ f (m * n) ∧ f (m * n) + 1 ≤ m * (f n + 1) := by
  have hmn : 1 ≤ m * n := Nat.mul_pos hm hn
  have a := hf.floors n (m * n) hn hmn
  have b := hf.floors (m * n) n hmn hn
  have hn0 : (0 : Int) ≤ n := by omega
  rw [Int.natCast_mul] at a b
  have a' : (n : Int) * (m * f n) < n * (f (m * n) + 1) := by grind
  have b' : (n : Int) * f (m * n) < n * (m * (f n + 1)) := by grind
  have := Int.lt_of_mul_lt_mul_left a' hn0
  have := Int.lt_of_mul_lt_mul_left b' hn0
  omega

theorem above_refine (hf : IrrationalLine f) {h k : Int} {n : Nat} (hn : 1 ≤ n) (h₁ : (n : Int) * h < k * f n)
    (h₂ : (n : Int) * h < k * (f n + 1)) (m : Nat) (hm : 1 ≤ m) :
    ((m * n : Nat) : Int) * h < k * f (m * n) ∧ ((m * n : Nat) : Int) * h < k * (f (m * n) + 1) := by
  obtain ⟨lo, hi⟩ := floors_refine hf m n hm hn
  have hm0 : (0 : Int) < m := by omega
  have e₁ := Int.mul_lt_mul_of_pos_left h₁ hm0
  have e₂ := Int.mul_lt_mul_of_pos_left h₂ hm0
  rw [Int.natCast_mul]
  by_cases hk : 0 ≤ k
  · have := Int.mul_le_mul_of_nonneg_left lo hk
    constructor <;> grind
  · have := Int.mul_le_mul_of_nonneg_left hi (show 0 ≤ -k by omega)
    constructor <;> grind

theorem above_add (hf : IrrationalLine f) {h k h' k' : Int} (a : Above f h k) (b : Above f h' k') :
    Above f (h + h') (k + k') := by
  obtain ⟨n, hn, a₁, a₂⟩ := a
  obtain ⟨m, hm, b₁, b₂⟩ := b
  have A := above_refine hf hn a₁ a₂ m hm
  have B := above_refine hf hm b₁ b₂ n hn
  rw [Nat.mul_comm n m] at B
  exact ⟨m * n, Nat.mul_pos hm hn, by grind, by grind⟩

theorem above_smul {u d : Int} (a : Above f u d) {c : Int} (hc : 1 ≤ c) : Above f (c * u) (c * d) := by
  obtain ⟨n, hn, h₁, h₂⟩ := a
  have e₁ := Int.mul_lt_mul_of_pos_left h₁ (show 0 < c by omega)
  have e₂ := Int.mul_lt_mul_of_pos_left h₂ (show 0 < c by omega)
  exact ⟨n, hn, by grind, by grind⟩

theorem above_add_smul (hf : IrrationalLine f) {h k u d : Int} (a : Above f h k) (b : Above f u d) {c : Int}
    (hc : 0 ≤ c) : Above f (h + c * u) (k + c * d) := by
  by_cases h0 : c = 0
  · subst h0; simpa using a
  · exact above_add hf a (above_smul b (by omega))

theorem above_total (hf : IrrationalLine f) (h : Int) (k : Nat) (hk : 1 ≤ k) :
    Above f h k ∨ Above f (-h) (-(k : Int)) := by
  obtain ⟨n, hn, a | a⟩ := hf.irrational h k hk
  · exact Or.inl ⟨n, hn, a, by grind⟩
  · exact Or.inr ⟨n, hn, by grind, by grind⟩

theorem above_absurd (hf : IrrationalLine f) {h k : Int} (a : Above f h k) (b : Above f (-h) (-k)) : False := by
  have c := above_add hf a b
  rw [Int.add_right_neg, Int.add_right_neg] at c
  exact not_above_zero c

theorem le_floor (hf : IrrationalLine f) {h : Int} {t : Nat} (ht : 1 ≤ t) (a : Above f h t) : h ≤ f t := by
  obtain ⟨n, hn, h₁, _⟩ := a
  have b := hf.floors n t hn ht
  have := Int.lt_of_mul_lt_mul_left (show (n : Int) * h < n * (f t + 1) by omega) (by omega)
  omega

theorem floor_lt (hf : IrrationalLine f) {h : Int} {t : Nat} (ht : 1 ≤ t) (a : Above f (-h) (-(t : Int))) :
    f t < h := by
  obtain ⟨n, hn, _, h₂⟩ := a
  have b := hf.floors t n ht hn
  exact Int.lt_of_mul_lt_mul_left (show (n : Int) * f t < n * h by grind) (by omega)

theorem floor_above (hf : IrrationalLine f) {t : Nat} (ht : 1 ≤ t) : Above f (f t) t := by
  rcases above_total hf (f t) t ht with a | a
  · exact a
  · have := floor_lt hf ht a; omega

theorem floor_below (hf : IrrationalLine f) {t : Nat} (ht : 1 ≤ t) : Above f (-(f t + 1)) (-(t : Int)) := by
  rcases above_total hf (f t + 1) t ht with a | a
  · have := le_floor hf ht a; omega
  · exact a

/-- A positive amount outgrows every other. -/
theorem above_arch {a b : Int} (hab : Above f a b) (h k : Int) : ∃ c : Nat, Above f (h + c * a) (k + c * b) := by
  obtain ⟨n, hn, h₁, h₂⟩ := hab
  refine ⟨((n : Int) * h - k * f n).natAbs + ((n : Int) * h - k * (f n + 1)).natAbs + 1, n, hn, ?_, ?_⟩
  · have e : (((n : Int) * h - k * f n).natAbs : Int) ≥ (n : Int) * h - k * f n := by omega
    generalize hc : ((((n : Int) * h - k * f n).natAbs + ((n : Int) * h - k * (f n + 1)).natAbs + 1 : Nat) : Int) = c
    have hc' : (n : Int) * h - k * f n < c := by omega
    have hc0 : 0 ≤ c := by omega
    have := Int.mul_le_mul_of_nonneg_left (show 1 ≤ b * f n - n * a by omega) hc0
    grind
  · generalize hc : ((((n : Int) * h - k * f n).natAbs + ((n : Int) * h - k * (f n + 1)).natAbs + 1 : Nat) : Int) = c
    have hc' : (n : Int) * h - k * (f n + 1) < c := by omega
    have hc0 : 0 ≤ c := by omega
    have := Int.mul_le_mul_of_nonneg_left (show 1 ≤ b * (f n + 1) - n * a by omega) hc0
    grind

/-! ### Farey neighbours -/

/-- `u / d` and `U / D` are Farey neighbours, one on each side of the slope. -/
def Farey (f : Nat → Int) (u : Int) (d : Nat) (U : Int) (D : Nat) : Prop :=
  1 ≤ d ∧ 1 ≤ D ∧
    ((Above f u d ∧ Above f (-U) (-(D : Int)) ∧ U * d - u * D = 1) ∨
      (Above f (-u) (-(d : Int)) ∧ Above f U D ∧ u * D - U * d = 1))

theorem Farey.symm {u U : Int} {d D : Nat} (h : Farey f u d U D) : Farey f U D u d := by
  obtain ⟨a, b, ⟨c, e, g⟩ | ⟨c, e, g⟩⟩ := h
  · exact ⟨b, a, Or.inr ⟨e, c, g⟩⟩
  · exact ⟨b, a, Or.inl ⟨e, c, g⟩⟩

/-- The mediant replaces one of the two neighbours. -/
theorem Farey.mediant (hf : IrrationalLine f) {u U : Int} {d D : Nat} (h : Farey f u d U D) :
    Farey f u d (u + U) (d + D) ∨ Farey f (u + U) (d + D) U D := by
  obtain ⟨a, b, hh⟩ := h
  rcases above_total hf (u + U) (d + D) (by omega) with m | m <;> rcases hh with ⟨c, e, g⟩ | ⟨c, e, g⟩
  · exact Or.inr ⟨by omega, b, Or.inl ⟨m, e, by grind⟩⟩
  · exact Or.inl ⟨a, by omega, Or.inr ⟨c, m, by grind⟩⟩
  · exact Or.inl ⟨a, by omega, Or.inl ⟨c, m, by grind⟩⟩
  · exact Or.inr ⟨by omega, b, Or.inr ⟨m, e, by grind⟩⟩

/-- The basis argument: before the other denominator, every lattice vector is at least as far from the slope as
`u / d`. -/
theorem bound (hf : IrrationalLine f) {u U h t : Int} {d D : Int} (hd : 1 ≤ d) (hD : 1 ≤ D)
    (c : Above f u d) (e : Above f (-U) (-D)) (g : U * d - u * D = 1) (ht : 1 ≤ t) (htD : t < D)
    (lo : Above f (u - h) (d - t)) (hi : Above f (h + u) (t + d)) : False := by
  generalize ha : t * U - h * D = a
  generalize hb : h * d - t * u = b
  have eh : h = a * u + b * U := by subst ha hb; grind
  have et : t = a * d + b * D := by subst ha hb; grind
  by_cases h1 : 1 ≤ b
  · have a0 : a + 1 ≤ 0 := by
      have := Int.mul_le_mul_of_nonneg_right h1 (show 0 ≤ D by omega)
      by_cases hn : 0 ≤ a
      · have := Int.mul_nonneg hn (show 0 ≤ d by omega)
        omega
      · omega
    have s := above_add_smul hf (above_add_smul hf hi c (show 0 ≤ -(a + 1) by omega)) e (show 0 ≤ b by omega)
    rw [show h + u + -(a + 1) * u + b * -U = 0 by grind, show t + d + -(a + 1) * d + b * -D = 0 by grind] at s
    exact not_above_zero s
  · have a0 : 0 ≤ a - 1 := by
      have := Int.mul_nonneg (show 0 ≤ -b by omega) (show 0 ≤ D by omega)
      by_cases hn : 1 ≤ a
      · omega
      · have := Int.mul_nonneg (show 0 ≤ -a by omega) (show 0 ≤ d by omega)
        grind
    have s := above_add_smul hf (above_add_smul hf lo c a0) e (show 0 ≤ -b by omega)
    rw [show u - h + (a - 1) * u + -b * -U = 0 by grind, show d - t + (a - 1) * d + -b * -D = 0 by grind] at s
    exact not_above_zero s

theorem no_crossing (hf : IrrationalLine f) {u U h t : Int} {d D : Int} (hd : 1 ≤ d) (hD : 1 ≤ D)
    (c : Above f u d) (e : Above f (-U) (-D)) (g : U * d - u * D = 1) (ht : 1 ≤ t) (htD : t < D)
    (lo : Above f (-h) (-t)) (hi : Above f (h + u) (t + d)) : False :=
  bound hf hd hD c e g ht htD (by simpa only [Int.sub_eq_add_neg] using above_add hf c lo) hi

/-- The floors of the multiples of the opposite number. -/
theorem IrrationalLine.reflect (hf : IrrationalLine f) : IrrationalLine (fun n => -f n - 1) where
  floors := fun m n hm hn => by have := hf.floors n m hn hm; grind
  irrational := fun p q hq => by
    obtain ⟨n, hn, h | h⟩ := hf.irrational (-p) q hq
    · exact ⟨n, hn, Or.inr (by grind)⟩
    · exact ⟨n, hn, Or.inl (by grind)⟩

theorem above_reflect (f : Nat → Int) (h k : Int) : Above (fun n => -f n - 1) h k ↔ Above f h (-k) := by
  constructor <;> rintro ⟨n, hn, h₁, h₂⟩ <;> exact ⟨n, hn, by grind, by grind⟩

/-- **The step.** Moving by one Farey denominator adds its numerator to the floor, at every positive time before the
other denominator. -/
theorem Farey.step (hf : IrrationalLine f) {u U : Int} {d D : Nat} (h : Farey f u d U D) (t : Nat) (ht : 1 ≤ t)
    (htD : t < D) : f (t + d) = f t + u := by
  obtain ⟨hd, hD, ⟨c, e, g⟩ | ⟨c, e, g⟩⟩ := h
  · have lower := le_floor hf (h := f t + u) (t := t + d) (by omega) (by
      rw [Int.natCast_add]; exact above_add hf (floor_above hf ht) c)
    have upper : f (t + d) < f t + u + 1 := by
      rcases above_total hf (f t + u + 1) (t + d) (by omega) with a | a
      · refine (no_crossing hf (u := u) (U := U) (h := f t + 1) (t := t) (d := d) (D := D) (by omega) (by omega) c e g
          (by omega) (by omega) (floor_below hf ht) ?_).elim
        rw [show f t + 1 + u = f t + u + 1 by omega, ← Int.natCast_add]; exact a
      · exact floor_lt hf (by omega) a
    omega
  · have upper := floor_lt hf (h := f t + 1 + u) (t := t + d) (by omega) (by
      have := above_add hf (floor_below hf ht) c
      rw [show -(f t + 1 + u) = -(f t + 1) + -u by omega,
        show -((t + d : Nat) : Int) = -(t : Int) + -(d : Int) by omega]
      exact this)
    have lower : f t + u ≤ f (t + d) := by
      rcases above_total hf (f t + u) (t + d) (by omega) with a | a
      · exact le_floor hf (by omega) a
      · refine (no_crossing hf.reflect (u := -u) (U := -U) (h := -f t) (t := t) (d := d) (D := D) (by omega) (by omega)
          ?_ ?_ (by grind) (by omega) (by omega) ?_ ?_).elim
        · rw [above_reflect]; exact c
        · rw [above_reflect, Int.neg_neg, Int.neg_neg]; exact e
        · rw [above_reflect, Int.neg_neg, Int.neg_neg]; exact floor_above hf ht
        · rw [above_reflect, show -f t + -u = -(f t + u) by omega,
            show -((t : Int) + d) = -((t + d : Nat) : Int) by omega]
          exact a
    omega

/-- A neighbour is not kept for ever. -/
theorem Farey.switch (hf : IrrationalLine f) {u U : Int} {d D : Nat} (h : Farey f u d U D) :
    ∃ n : Nat, Farey f (u + n * U) (d + n * D) (u + (n + 1) * U) (d + (n + 1) * D) := by
  refine Classical.byContradiction fun no => ?_
  have keep : ∀ n : Nat, Farey f (u + n * U) (d + n * D) U D := by
    intro n
    induction n with
    | zero => simpa using h
    | succ n ih =>
      rcases ih.mediant hf with m | m
      · refine (no ⟨n, ?_⟩).elim
        rw [show u + ((n : Int) + 1) * U = u + n * U + U by grind, show d + (n + 1) * D = d + n * D + D by grind]
        exact m
      · rw [show u + ((n + 1 : Nat) : Int) * U = u + n * U + U by grind, show d + (n + 1) * D = d + n * D + D by grind]
        exact m
  obtain ⟨_, _, ⟨c, e, g⟩ | ⟨c, e, g⟩⟩ := h
  · obtain ⟨n, a⟩ := above_arch e (-u) (-(d : Int))
    obtain ⟨_, _, ⟨c', _, _⟩ | ⟨_, e', _⟩⟩ := keep n
    · refine above_absurd hf c' ?_
      rw [show -(u + (n : Int) * U) = -u + n * -U by grind,
        show -((d + n * D : Nat) : Int) = -(d : Int) + n * -(D : Int) by grind]
      exact a
    · exact above_absurd hf e' e
  · obtain ⟨n, a⟩ := above_arch e u d
    obtain ⟨_, _, ⟨_, e', _⟩ | ⟨c', _, _⟩⟩ := keep n
    · exact above_absurd hf e e'
    · refine above_absurd hf (h := u + n * U) (k := d + n * D) a ?_
      rw [show -((d : Int) + n * D) = -((d + n * D : Nat) : Int) by grind]
      exact c'

/-- Farey neighbours with large denominators on both sides. -/
theorem exists_farey (hf : IrrationalLine f) (M : Nat) :
    ∃ (u : Int) (d : Nat) (U : Int) (D : Nat), M ≤ d ∧ M ≤ D ∧ Farey f u d U D := by
  induction M with
  | zero =>
    refine ⟨f 1, 1, f 1 + 1, 1, by omega, by omega, by omega, by omega, Or.inl ⟨?_, ?_, by omega⟩⟩
    · exact floor_above hf (t := 1) (by omega)
    · exact floor_below hf (t := 1) (by omega)
  | succ M ih =>
    obtain ⟨u, d, U, D, hd, hD, h⟩ := ih
    obtain ⟨n, h₁⟩ := h.switch hf
    obtain ⟨m, h₂⟩ := h₁.symm.switch hf
    have p₁ := h.1
    have p₂ := h.2.1
    have e₁ : d + D ≤ d + (n + 1) * D := by
      have := Nat.mul_le_mul_right D (show 1 ≤ n + 1 by omega); omega
    refine ⟨_, _, _, _, ?_, ?_, h₂⟩
    · exact Nat.le_trans (by omega) (Nat.le_add_right _ _)
    · exact Nat.le_trans (by omega) (Nat.le_add_right _ _)

/-! ### Near-squares of the half-circle word -/

/-- **Near-squares of the half-circle word.** The parities of the floors repeat with slack two at unbounded lags and
from unbounded starts, for every irrational slope. -/
theorem half_circle_near_squares (hf : IrrationalLine f) (H N : Nat) :
    ∃ i j : Nat, H ≤ i ∧ i + N ≤ j ∧ ∀ s, s + 2 < j → f (i + s) % 2 = f (j + s) % 2 := by
  -- a neighbour `u / d` with an even numerator, kept once
  have even {u U : Int} {d D : Nat} (h : Farey f u d U D) (hu : u % 2 = 0) (hN : N ≤ d)
      (hD : d + 2 * H + 2 ≤ D) :
      ∃ i j : Nat, H ≤ i ∧ i + N ≤ j ∧ ∀ s, s + 2 < j → f (i + s) % 2 = f (j + s) % 2 := by
    refine ⟨H + 1, H + 1 + d, by omega, by omega, fun s hs => ?_⟩
    have := h.step hf (H + 1 + s) (by omega) (by omega)
    rw [show H + 1 + d + s = H + 1 + s + d by omega, this]
    omega
  obtain ⟨u, d, U, D, hd, hD, h⟩ := exists_farey hf (2 * H + N + 2)
  -- one odd and one even numerator
  obtain ⟨u, d, U, D, hd, hD, h, hu, hU⟩ : ∃ (u : Int) (d : Nat) (U : Int) (D : Nat),
      2 * H + N + 2 ≤ d ∧ 2 * H + N + 2 ≤ D ∧ Farey f u d U D ∧ u % 2 = 1 ∧ U % 2 = 0 := by
    by_cases hu : u % 2 = 1 <;> by_cases hU : U % 2 = 1
    · rcases h.mediant hf with m | m
      · exact ⟨u, d, u + U, d + D, hd, by omega, m, hu, by omega⟩
      · exact ⟨U, D, u + U, d + D, hD, by omega, m.symm, hU, by omega⟩
    · exact ⟨u, d, U, D, hd, hD, h, hu, by omega⟩
    · exact ⟨U, D, u, d, hD, hd, h.symm, hU, by omega⟩
    · exfalso
      have hu0 : 2 ∣ u := by omega
      have hU0 : 2 ∣ U := by omega
      obtain ⟨a, rfl⟩ := hu0
      obtain ⟨b, rfl⟩ := hU0
      obtain ⟨_, _, ⟨_, _, g⟩ | ⟨_, _, g⟩⟩ := h <;> grind
  rcases h.mediant hf with m | m
  · -- the odd one is kept: two odd numerators, `u` and `u + U`
    rcases m.mediant hf with m₂ | m₂
    · -- the smaller is kept again
      rcases m₂.mediant hf with m₃ | m₃
      · refine ⟨H + 1, H + 1 + 2 * d, by omega, by omega, fun s hs => ?_⟩
        have s₁ := m₃.step hf (H + 1 + s) (by omega) (by omega)
        have s₂ := m₃.step hf (H + 1 + s + d) (by omega) (by omega)
        rw [show H + 1 + 2 * d + s = H + 1 + s + d + d by omega, s₂, s₁]
        omega
      · exact even m₃.symm (by omega) (by omega) (by omega)
    · -- the larger is kept
      refine ⟨d + 1, d + D + 1, by omega, by omega, fun s hs => ?_⟩
      have s₁ := m.step hf (s + 1) (by omega) (by omega)
      have s₂ := m₂.symm.step hf (s + 1) (by omega) (by omega)
      rw [show d + 1 + s = s + 1 + d by omega, show d + D + 1 + s = s + 1 + (d + D) by omega, s₁, s₂]
      omega
  · exact even m.symm hU (by omega) (by omega)

/-! ### A second line of the same slope -/

/-- `f` is the sequence of floors of a line of the slope of `g`, with any phase. -/
def PhaseLine (g f : Nat → Int) : Prop :=
  ∀ t n : Nat, 1 ≤ n → f t + g n ≤ f (t + n) ∧ f (t + n) ≤ f t + g n + 1

variable {g : Nat → Int}

theorem PhaseLine.reflect (hf : PhaseLine g f) : PhaseLine (fun n => -g n - 1) (fun n => -f n - 1) := by
  intro t n hn
  have := hf t n hn
  constructor <;> dsimp only <;> omega

/-- Two lattice points on the two sides of the line, in the order of the slope. -/
theorem PhaseLine.sep (hg : IrrationalLine g) (hf : PhaseLine g f) {t s : Nat} {h k : Int} (ht : h ≤ f t)
    (hs : f s < k) : Above g (h - k) ((t : Int) - s) := by
  rcases Nat.lt_trichotomy t s with lt | rfl | gt
  · obtain ⟨n, rfl⟩ : ∃ n, s = t + n := ⟨s - t, by omega⟩
    have hn : 1 ≤ n := by omega
    rcases above_total hg (k - h) n hn with a | a
    · have := le_floor hg hn a
      have := hf t n hn
      omega
    · rw [show h - k = -(k - h) by omega, show (t : Int) - ((t + n : Nat) : Int) = -(n : Int) by omega]
      exact a
  · exact ⟨1, by omega, by omega, by omega⟩
  · obtain ⟨n, rfl⟩ : ∃ n, t = s + n := ⟨t - s, by omega⟩
    have hn : 1 ≤ n := by omega
    rcases above_total hg (h - k) n hn with a | a
    · rw [show ((s + n : Nat) : Int) - (s : Int) = (n : Int) by omega]
      exact a
    · have := floor_lt hg hn a
      have := hf s n hn
      omega

theorem Farey.reflect {u U : Int} {d D : Nat} (h : Farey g u d U D) : Farey (fun n => -g n - 1) (-u) d (-U) D := by
  obtain ⟨a, b, ⟨c, e, i⟩ | ⟨c, e, i⟩⟩ := h
  · refine ⟨a, b, Or.inr ⟨?_, ?_, by grind⟩⟩
    · rw [above_reflect, Int.neg_neg, Int.neg_neg]; exact c
    · rw [above_reflect]; exact e
  · refine ⟨a, b, Or.inl ⟨?_, ?_, by grind⟩⟩
    · rw [above_reflect]; exact c
    · rw [above_reflect, Int.neg_neg, Int.neg_neg]; exact e

private theorem gap_lower (hg : IrrationalLine g) (hf : PhaseLine g f) {u U : Int} {d D : Nat} (hd : 1 ≤ d)
    (hD : 1 ≤ D) (c : Above g u d) (e : Above g (-U) (-(D : Int))) (i : U * d - u * D = 1) {t s : Nat}
    (ht : f (t + d) ≠ f t + u) (hs : f (s + d) ≠ f s + u) (lt : t < s) : t + D ≤ s := by
  have up (t : Nat) (ht : f (t + d) ≠ f t + u) : f t + 1 + u ≤ f (t + d) := by
    have := le_floor hg hd c
    have := hf t d hd
    omega
  refine Classical.byContradiction fun no => ?_
  have a₁ := hf.sep hg (up s hs) (show f t < f t + 1 by omega)
  have a₂ := hf.sep hg (up t ht) (show f s < f s + 1 by omega)
  refine bound hg (u := u) (U := U) (h := f s - f t) (t := (s : Int) - t) (d := d) (D := D) (by omega) (by omega) c e i
    (by omega) (by omega) ?_ ?_
  · rw [show u - (f s - f t) = f t + 1 + u - (f s + 1) by omega,
      show (d : Int) - ((s : Int) - t) = ((t + d : Nat) : Int) - s by omega]
    exact a₂
  · rw [show f s - f t + u = f s + 1 + u - (f t + 1) by omega,
      show (s : Int) - t + d = ((s + d : Nat) : Int) - t by omega]
    exact a₁

/-- Times at which the second line fails to copy are far apart. -/
theorem Farey.gap (hg : IrrationalLine g) (hf : PhaseLine g f) {u U : Int} {d D : Nat} (h : Farey g u d U D)
    {t s : Nat} (ht : f (t + d) ≠ f t + u) (hs : f (s + d) ≠ f s + u) (lt : t < s) : t + D ≤ s := by
  obtain ⟨hd, hD, ⟨c, e, i⟩ | ⟨c, e, i⟩⟩ := h
  · exact gap_lower hg hf hd hD c e i ht hs lt
  · refine gap_lower hg.reflect hf.reflect (u := -u) (U := -U) hd hD ?_ ?_ (by grind) (by omega) (by omega) lt
    · rw [above_reflect]; exact c
    · rw [above_reflect, Int.neg_neg, Int.neg_neg]; exact e

/-! ### Scales -/

/-- A neighbour `u / d` kept for the last time: the other neighbour has just become `(x + u) / (r + d)`, and that one is
kept next. -/
def Scale (g : Nat → Int) (x : Int) (r : Nat) (u : Int) (d : Nat) : Prop :=
  Farey g x r u d ∧ Farey g u d (x + u) (r + d) ∧ Farey g (u + (x + u)) (d + (r + d)) (x + u) (r + d)

private theorem carry_lower (hg : IrrationalLine g) (hf : PhaseLine g f) {x u : Int} {r d : Nat} (h : Scale g x r u d)
    (c : Above g u d) {m t : Nat} (hm : 1 ≤ m) (hmd : m < d) (bm : f (m + d) ≠ f m + u) (ht : 1 ≤ t) (htD : t < r + d)
    (bt : f (t + (r + d)) ≠ f t + (x + u)) : t = m + d := by
  obtain ⟨h₀, h₁, h₂⟩ := h
  -- the orientation
  obtain ⟨hr, hd, ⟨_, c', _⟩ | ⟨cx, _, i₀⟩⟩ := h₀
  · exact (above_absurd hg c c').elim
  have i₀' : x * d - u * r = 1 := i₀
  obtain ⟨_, _, ⟨_, e, i₁⟩ | ⟨c', _, _⟩⟩ := h₁
  case inr.inr => exact (above_absurd hg c c').elim
  have m₂ : Above g (u + (x + u)) ((d + (r + d) : Nat) : Int) := by
    obtain ⟨_, _, ⟨a, _, _⟩ | ⟨_, a, _⟩⟩ := h₂
    · exact a
    · exact (above_absurd hg a e).elim
  have bt' : f (t + (r + d)) < f t + (x + u) := by
    have := floor_lt hg (t := r + d) (by omega) e
    have := hf t (r + d) (by omega)
    omega
  rcases Nat.lt_or_ge d t with gt | le
  · -- one denominator back it fails too, and there is only one such time
    obtain ⟨s, rfl⟩ : ∃ s, t = s + d := ⟨t - d, by omega⟩
    have bs : f (s + d) ≠ f s + u := by
      intro eq
      have a := hf.sep hg (show f s ≤ f s by omega) bt'
      refine above_absurd hg m₂ ?_
      rw [show -(u + (x + u)) = f s - (f (s + d) + (x + u)) by omega,
        show -((d + (r + d) : Nat) : Int) = (s : Int) - ((s + d + (r + d) : Nat) : Int) by omega]
      exact a
    have F : Farey g u d (x + u) (r + d) := ⟨by omega, by omega, Or.inl ⟨c, e, i₁⟩⟩
    rcases Nat.lt_trichotomy m s with lt | eq | gt'
    · have := F.gap hg hf bm bs lt; omega
    · omega
    · have := F.gap hg hf bs bm gt'; omega
  · -- too early: a lattice vector that is too short
    exfalso
    have up : f m + 1 + u ≤ f (m + d) := by
      have := le_floor hg hd c
      have := hf m d hd
      omega
    have s₁ := hf.sep hg (show f t ≤ f t by omega) (show f m < f m + 1 by omega)
    have s₂ := hf.sep hg up bt'
    have cx' : Above g (-x) (-(r : Int)) := cx
    rcases Nat.lt_trichotomy m t with lt | rfl | gt
    · refine bound hg.reflect (u := -x) (U := -u) (h := -(f t - (f m + 1))) (t := (t : Int) - m) (d := r) (D := d)
        (by omega) (by omega) ?_ ?_ (by grind) (by omega) (by omega) ?_ ?_
      · rw [above_reflect]; exact cx'
      · rw [above_reflect, Int.neg_neg, Int.neg_neg]; exact c
      · rw [above_reflect]
        have := above_add hg s₁ cx'
        rw [show -x - -(f t - (f m + 1)) = f t - (f m + 1) + -x by omega,
          show -((r : Int) - ((t : Int) - m)) = (t : Int) - m + -(r : Int) by omega]
        exact this
      · rw [above_reflect, show -(f t - (f m + 1)) + -x = f m + 1 + u - (f t + (x + u)) by omega,
          show -((t : Int) - m + r) = ((m + d : Nat) : Int) - ((t + (r + d) : Nat) : Int) by omega]
        exact s₂
    · have s₃ := above_add_smul hg (above_add_smul hg s₂ c (show (0 : Int) ≤ r by omega)) cx'
        (show (0 : Int) ≤ (d : Int) - 1 by omega)
      rw [show f m + 1 + u - (f m + (x + u)) + (r : Int) * u + ((d : Int) - 1) * -x = 0 by grind,
        show ((m + d : Nat) : Int) - ((m + (r + d) : Nat) : Int) + (r : Int) * d + ((d : Int) - 1) * -(r : Int) = 0 by
          grind] at s₃
      exact not_above_zero s₃
    · refine bound hg.reflect (u := -x) (U := -u) (h := f t - (f m + 1)) (t := (m : Int) - t) (d := r) (D := d)
        (by omega) (by omega) ?_ ?_ (by grind) (by omega) (by omega) ?_ ?_
      · rw [above_reflect]; exact cx'
      · rw [above_reflect, Int.neg_neg, Int.neg_neg]; exact c
      · rw [above_reflect, show -x - (f t - (f m + 1)) = f m + 1 + u - (f t + (x + u)) by omega,
          show -((r : Int) - ((m : Int) - t)) = ((m + d : Nat) : Int) - ((t + (r + d) : Nat) : Int) by omega]
        exact s₂
      · rw [above_reflect]
        have := above_add hg s₁ cx'
        rw [show f t - (f m + 1) + -x = f t - (f m + 1) + -x by omega,
          show -((m : Int) - t + r) = (t : Int) - m + -(r : Int) by omega]
        exact this

/-- **The carry.** If the second line fails to copy once before `d` at lag `d`, and once before `r + d` at lag `r + d`,
then the second time is the first plus `d`. -/
theorem Scale.carry (hg : IrrationalLine g) (hf : PhaseLine g f) {x u : Int} {r d : Nat} (h : Scale g x r u d)
    {m t : Nat} (hm : 1 ≤ m) (hmd : m < d) (bm : f (m + d) ≠ f m + u) (ht : 1 ≤ t) (htD : t < r + d)
    (bt : f (t + (r + d)) ≠ f t + (x + u)) : t = m + d := by
  rcases above_total hg u d (by omega) with c | c
  · exact carry_lower hg hf h c hm hmd bm ht htD bt
  · refine carry_lower hg.reflect hf.reflect (x := -x) (u := -u) (r := r) ?_ ?_ hm hmd (by omega) ht htD (by omega)
    · obtain ⟨h₀, h₁, h₂⟩ := h
      refine ⟨h₀.reflect, ?_, ?_⟩
      · have := h₁.reflect; rwa [Int.neg_add] at this
      · have := h₂.reflect; rwa [Int.neg_add, Int.neg_add] at this
    · rw [above_reflect]; exact c

/-- The mediant is on one side only. -/
theorem Farey.not_both (hg : IrrationalLine g) {u U : Int} {d D : Nat} (h : Farey g u d (u + U) (d + D))
    (h' : Farey g (u + U) (d + D) U D) : False := by
  obtain ⟨_, _, ⟨_, a, i⟩ | ⟨_, a, i⟩⟩ := h <;> obtain ⟨_, _, ⟨b, _, j⟩ | ⟨b, _, j⟩⟩ := h'
  · exact above_absurd hg b a
  · grind
  · grind
  · exact above_absurd hg a b

/-- How long a neighbour is kept. -/
theorem Farey.kept (hg : IrrationalLine g) {u U : Int} {d D : Nat} (h : Farey g u d U D) :
    ∃ n : Nat, (∀ i : Nat, i ≤ n → Farey g (u + i * U) (d + i * D) U D) ∧
      Farey g (u + n * U) (d + n * D) (u + (n + 1) * U) (d + (n + 1) * D) := by
  obtain ⟨n, hn⟩ := h.switch hg
  -- the least such `n`
  induction n using Nat.strongRecOn with
  | ind n ih =>
    by_cases ex : ∃ k, k < n ∧ Farey g (u + k * U) (d + k * D) (u + (k + 1) * U) (d + (k + 1) * D)
    · obtain ⟨k, hk, hF⟩ := ex
      exact ih k hk hF
    · refine ⟨n, fun i => ?_, hn⟩
      induction i with
      | zero => intro _; simpa using h
      | succ i ihi =>
        intro hi
        rcases (ihi (by omega)).mediant hg with m | m
        · refine (ex ⟨i, by omega, ?_⟩).elim
          rw [show u + ((i : Int) + 1) * U = u + i * U + U by grind, show d + (i + 1) * D = d + i * D + D by grind]
          exact m
        · rw [show u + ((i + 1 : Nat) : Int) * U = u + i * U + U by grind,
            show d + (i + 1) * D = d + i * D + D by grind]
          exact m

theorem scale_of_kept (hg : IrrationalLine g) {u U : Int} {d D : Nat} (h : Farey g u d U D)
    (h' : Farey g (u + U) (d + D) U D) : ∃ k : Nat, Scale g (u + k * U) (d + k * D) U D := by
  obtain ⟨n, keep, last⟩ := h.kept hg
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · refine (Farey.not_both hg (u := u) (U := U) (d := d) (D := D) ?_ h').elim
    simpa using last
  · obtain ⟨k, rfl⟩ : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
    refine ⟨k, keep k (by omega), ?_, ?_⟩
    · have := (keep (k + 1) (by omega)).symm
      rw [show u + ((k + 1 : Nat) : Int) * U = u + k * U + U by grind,
        show d + (k + 1) * D = d + k * D + D by grind] at this
      exact this
    · have := last.symm
      rw [show u + ((k + 1 : Nat) : Int) * U = u + k * U + U by grind, show d + (k + 1) * D = d + k * D + D by grind,
        show u + (((k + 1 : Nat) : Int) + 1) * U = U + (u + k * U + U) by grind,
        show d + (k + 1 + 1) * D = D + (d + k * D + D) by grind] at this
      exact this

theorem Scale.next (hg : IrrationalLine g) {x u : Int} {r d : Nat} (h : Scale g x r u d) :
    ∃ k : Nat, Scale g (u + k * (x + u)) (d + k * (r + d)) (x + u) (r + d) :=
  scale_of_kept hg h.2.1 h.2.2

theorem exists_scale (hg : IrrationalLine g) (M : Nat) :
    ∃ (x : Int) (r : Nat) (u : Int) (d : Nat), M ≤ d ∧ Scale g x r u d := by
  obtain ⟨u, d, U, D, hd, hD, h⟩ := exists_farey hg M
  rcases h.mediant hg with m | m
  · have m' := m.symm
    rw [Int.add_comm u U, Nat.add_comm d D] at m'
    obtain ⟨k, hk⟩ := scale_of_kept hg h.symm m'
    exact ⟨_, _, _, _, hd, hk⟩
  · obtain ⟨k, hk⟩ := scale_of_kept hg h m
    exact ⟨_, _, _, _, hD, hk⟩

/-! ### Near-squares of one arc -/

/-- Near-squares of slack `K` and lag at least `N`, from `H` on. -/
def NearSquare (c : Nat → Int) (H K N : Nat) : Prop :=
  ∃ i j : Nat, H ≤ i ∧ i + N ≤ j ∧ ∀ s, s + K < j → c (i + s) = c (j + s)

/-- If the second line copies up to `d`, the start repeats. -/
private theorem copy_first (hg : IrrationalLine g) {x u : Int} {r d H N : Nat} (h : Scale g x r u d) (hN : N ≤ d)
    (no : ∀ t, 1 ≤ t → t < d → f (t + d) = f t + u) : NearSquare (fun t => f t - g t) H (2 * H + 2) N := by
  refine ⟨H + 1, H + 1 + d, by omega, by omega, fun s hs => ?_⟩
  have s₁ := h.2.1.step hg (H + 1 + s) (by omega) (by omega)
  have s₂ := no (H + 1 + s) (by omega) (by omega)
  show f (H + 1 + s) - g (H + 1 + s) = f (H + 1 + d + s) - g (H + 1 + d + s)
  rw [show H + 1 + d + s = H + 1 + s + d by omega, s₁, s₂]
  omega

/-- If it fails once, at `m`, the word from `m + 1` on repeats up to `r + d`. -/
private theorem copy_second (hg : IrrationalLine g) (hf : PhaseLine g f) {x u : Int} {r d H N S m : Nat}
    (h : Scale g x r u d) (hN : N ≤ d) (hm : 1 ≤ m) (bm : f (m + d) ≠ f m + u) (hS : 2 * m ≤ r + S) :
    NearSquare (fun t => f t - g t) H (S + 2 * H + 2) N := by
  refine ⟨m + 1 + H, m + 1 + H + d, by omega, by omega, fun s hs => ?_⟩
  have s₁ := h.2.1.step hg (m + 1 + H + s) (by omega) (by omega)
  have s₂ : f (m + 1 + H + s + d) = f (m + 1 + H + s) + u := by
    refine Classical.byContradiction fun b => ?_
    have := h.2.1.gap hg hf bm b (by omega)
    omega
  show f (m + 1 + H + s) - g (m + 1 + H + s) = f (m + 1 + H + d + s) - g (m + 1 + H + d + s)
  rw [show m + 1 + H + d + s = m + 1 + H + s + d by omega, s₁, s₂]
  omega

/-- **Near-squares of one arc.** For every irrational slope and every second line of that slope, the difference of the
floors has near-squares of some fixed slack at unbounded lags, from any start. -/
theorem arc_near_squares (hg : IrrationalLine g) (hf : PhaseLine g f) (H : Nat) :
    ∃ K, ∀ N, NearSquare (fun t => f t - g t) H K N := by
  by_cases all : ∀ N, NearSquare (fun t => f t - g t) H (2 * H + 2) N
  · exact ⟨_, all⟩
  obtain ⟨N₀, no⟩ := Classical.not_forall.mp all
  -- from here on every scale fails
  have fail {x u : Int} {r d : Nat} (h : Scale g x r u d) (hd : N₀ ≤ d) :
      ∃ m, 1 ≤ m ∧ m < d ∧ f (m + d) ≠ f m + u ∧ r < 2 * m := by
    obtain ⟨m, hm⟩ : ∃ m, 1 ≤ m ∧ m < d ∧ f (m + d) ≠ f m + u := by
      refine Classical.byContradiction fun nm => no (copy_first hg h hd fun t h₁ h₂ => ?_)
      exact Classical.byContradiction fun b => nm ⟨t, h₁, h₂, b⟩
    refine ⟨m, hm.1, hm.2.1, hm.2.2, ?_⟩
    rcases Nat.lt_or_ge r (2 * m) with lt | ge
    · exact lt
    · have := copy_second (H := H) (S := 0) hg hf h hd hm.1 hm.2.2 (by omega)
      rw [Nat.zero_add] at this
      exact (no this).elim
  obtain ⟨x₀, r₀, u₀, d₀, hd₀, h₀⟩ := exists_scale hg N₀
  obtain ⟨m₀, hm₀, hmd₀, bm₀, lt₀⟩ := fail h₀ hd₀
  obtain ⟨S, hS⟩ : ∃ S, 2 * m₀ = r₀ + S := ⟨2 * m₀ - r₀, by omega⟩
  -- and the shortfall does not change
  have const : ∀ n : Nat, ∃ (x : Int) (r : Nat) (u : Int) (d m : Nat), n ≤ d ∧ N₀ ≤ d ∧ Scale g x r u d ∧ 1 ≤ m ∧
      m < d ∧ f (m + d) ≠ f m + u ∧ 2 * m = r + S := by
    intro n
    induction n with
    | zero => exact ⟨x₀, r₀, u₀, d₀, m₀, by omega, hd₀, h₀, hm₀, hmd₀, bm₀, hS⟩
    | succ n ih =>
      obtain ⟨x, r, u, d, m, hn, hd, h, hm, hmd, bm, e⟩ := ih
      have hr : 1 ≤ r := h.1.1
      obtain ⟨k, h'⟩ := h.next hg
      obtain ⟨m', hm', hmd', bm', lt'⟩ := fail h' (by omega)
      have e' := h.carry hg hf hm hmd bm hm' hmd' bm'
      obtain ⟨k', h''⟩ := h'.next hg
      obtain ⟨m'', hm'', hmd'', bm'', _⟩ := fail h'' (by omega)
      have e'' := h'.carry hg hf hm' hmd' bm' hm'' hmd'' bm''
      have hk : k = 1 := by
        rcases Nat.lt_trichotomy k 1 with lt | eq | gt
        · obtain rfl : k = 0 := by omega
          simp at hmd''
          omega
        · exact eq
        · have := Nat.mul_le_mul_right (r + d) (show 2 ≤ k by omega)
          omega
      subst hk
      refine ⟨_, _, _, _, m', ?_, ?_, h', hm', hmd', bm', ?_⟩ <;> omega
  refine ⟨S + 2 * H + 2, fun N => ?_⟩
  obtain ⟨x, r, u, d, m, hn, _, h, hm, _, bm, e⟩ := const N
  exact copy_second hg hf h hn hm bm (by omega)

/-! ### Beside a clock -/


/-- The row at time `a`, read from site `i`, evolves as the original row does. -/
theorem evol_frame (x : Int → Bool) (a : Nat) (i : Int) (t : Nat) :
    ∀ j, evol (fun p => evol x a (p + i)) t j = evol x (a + t) (j + i) := by
  induction t with
  | zero => intro j; rfl
  | succ t ih =>
    intro j
    show Rule30Jen.rule _ _ _ = Rule30Jen.rule _ _ _
    rw [ih, ih, ih, show j - 1 + i = j + i - 1 by omega, show j + 1 + i = j + i + 1 by omega]
    rfl

/-- **Corollary F at any column, for block codes.** In a row with a leftmost black cell, column `i` reads `0101…` from
time `a`. If a sequence has near-squares of fixed slack at unbounded lags from every start, then no block code of it is
read, from any index on, by column `i + 1` on the white ticks. -/
theorem no_near_squares (x : Int → Bool) (lo i : Int) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (c : Nat → Int) (hc : ∀ H, ∃ K, ∀ N, NearSquare c H K N) (a q r : Nat) (φ : (Nat → Int) → Bool)
    (hφ : ∀ v v' : Nat → Int, (∀ s, s < r → v s = v' s) → φ v = φ v')
    (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t, evol x (a + 2 * t) (i + 1) = φ (fun s => c (t + q + s))) : False := by
  obtain ⟨b, hb⟩ : ∃ b : Nat, lo - ((a + 2 * b : Nat) : Int) < i := ⟨(lo - i).toNat + 1, by omega⟩
  obtain ⟨L, hL⟩ : ∃ L : Nat, lo - ((a + 2 * b : Nat) : Int) = i - (L : Int) :=
    ⟨(i - (lo - ((a + 2 * b : Nat) : Int))).toNat, by omega⟩
  obtain ⟨black, white⟩ := Rule30Submission.edge x lo hlo hleft (a + 2 * b)
  have V : ∀ t, evol (fun p => evol x (a + 2 * b) (p + i)) (2 * t) 1 = φ (fun s => c (t + b + q + s)) := by
    intro t
    rw [evol_frame, show a + 2 * b + 2 * t = a + 2 * (t + b) by omega, show (1 : Int) + i = i + 1 by omega, visible]
  obtain ⟨K, hK⟩ := hc (b + q)
  refine Rule30Submission.corollary_F (fun p => evol x (a + 2 * b) (p + i)) L (by omega) ?_ ?_ 0 ?_ (r + K) ?_
  · show evol x (a + 2 * b) (-(L : Int) + i) = true
    rw [show -(L : Int) + i = lo - ((a + 2 * b : Nat) : Int) by omega]; exact black
  · intro j hj
    exact white _ (by omega)
  · intro t _
    rw [evol_frame, show a + 2 * b + t = a + (2 * b + t) by omega, show (0 : Int) + i = i by omega, clock,
      show (2 * b + t) % 2 = t % 2 by omega]
  · intro N
    obtain ⟨m, n, h₁, h₂, h₃⟩ := hK (N + 1)
    refine ⟨m - (b + q), n - (b + q), by omega, by omega, by omega, fun s hs => ?_⟩
    rw [V, V]
    apply hφ
    intro k hk
    have := h₃ (s + k) (by omega)
    rw [show m - (b + q) + s + b + q + k = m + (s + k) by omega,
      show n - (b + q) + s + b + q + k = n + (s + k) by omega, this]

/-- **One arc, from an end.** `g` gives the floors of `t α` and `f` those of `t α + θ`, for an irrational `α` and any
`θ`, so `f - g` codes the rotation by `α` by one arc and its complement and starts at an end. No block code of it, from
any index on, is read by the right neighbour of a column that alternates, on its white ticks, in a row with a leftmost
black cell. -/
theorem arc_excluded (x : Int → Bool) (lo i : Int) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (hg : IrrationalLine g) (hf : PhaseLine g f) (a q r : Nat) (φ : (Nat → Int) → Bool)
    (hφ : ∀ v v' : Nat → Int, (∀ s, s < r → v s = v' s) → φ v = φ v')
    (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t, evol x (a + 2 * t) (i + 1) = φ (fun s => f (t + q + s) - g (t + q + s))) : False :=
  no_near_squares x lo i hlo hleft (fun t => f t - g t) (arc_near_squares hg hf) a q r φ hφ clock visible

/-- The word of one arc itself: black when the difference of the floors is `e`. -/
theorem one_arc_excluded (x : Int → Bool) (lo i : Int) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (hg : IrrationalLine g) (hf : PhaseLine g f) (a q : Nat) (e : Int)
    (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t, evol x (a + 2 * t) (i + 1) = decide (f (t + q) - g (t + q) = e)) : False :=
  arc_excluded x lo i hlo hleft hg hf a q 1 (fun v => decide (v 0 = e))
    (fun v v' h => by show decide (v 0 = e) = decide (v' 0 = e); rw [h 0 (by omega)]) clock
    (fun t => by simpa using visible t)

/-- **Half-circles.** `f` gives the floors of `t β`, `β` twice the angle: block codes of their parities. -/
theorem half_circle_block_excluded (x : Int → Bool) (lo i : Int) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (hf : IrrationalLine f) (a q r : Nat) (φ : (Nat → Int) → Bool)
    (hφ : ∀ v v' : Nat → Int, (∀ s, s < r → v s = v' s) → φ v = φ v')
    (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t, evol x (a + 2 * t) (i + 1) = φ (fun s => f (t + q + s) % 2)) : False :=
  no_near_squares x lo i hlo hleft (fun t => f t % 2) (fun H => ⟨2, fun N => half_circle_near_squares hf H N⟩) a q r φ
    hφ clock visible

/-- The half-circle word itself (`b = 1`), or its letter exchange (`b = 0`). -/
theorem half_circle_excluded (x : Int → Bool) (lo i : Int) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (hf : IrrationalLine f) (a q : Nat) (b : Int) (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t, evol x (a + 2 * t) (i + 1) = decide (f (t + q) % 2 = b)) : False :=
  half_circle_block_excluded x lo i hlo hleft hf a q 1 (fun v => decide (v 0 = b))
    (fun v v' h => by show decide (v 0 = b) = decide (v' 0 = b); rw [h 0 (by omega)]) clock
    (fun t => by simpa using visible t)

/-- One arc at the centre, with eventual hypotheses: the word is started `q - p` steps along the orbit of an end. -/
theorem no_eventual_arc_neighbour (x : Int → Bool) (L T H : Nat) (hleft : x (-(L : Int)) = true)
    (hzero : ∀ j, j < -(L : Int) → x j = false) (hg : IrrationalLine g) (hf : PhaseLine g f) (p q : Nat) (e : Int)
    (clock : ∀ t, T ≤ t → evol x t 0 = decide (t % 2 = 1))
    (visible : ∀ t, H ≤ t → evol x (2 * (t + p)) 1 = decide (f (t + q) - g (t + q) = e)) : False := by
  refine one_arc_excluded x (-(L : Int)) 0 hleft hzero hg hf (2 * (H + T + p)) (H + T + q) e (fun t => ?_) (fun t => ?_)
  · rw [clock _ (by omega), show (2 * (H + T + p) + t) % 2 = t % 2 by omega]
  · rw [show 2 * (H + T + p) + 2 * t = 2 * (t + (H + T) + p) by omega, show (0 : Int) + 1 = 1 by omega,
      visible _ (by omega), show t + (H + T) + q = t + (H + T + q) by omega]

/-- A line and itself, moved. -/
theorem IrrationalLine.moved (hg : IrrationalLine g) (k : Nat) (hk : 1 ≤ k) : PhaseLine g (fun t => g (t + k)) := by
  intro t n hn
  have a := above_add hg (floor_above hg (t := t + k) (by omega)) (floor_above hg hn)
  have b := above_add hg (floor_below hg (t := t + k) (by omega)) (floor_below hg hn)
  rw [← Int.natCast_add] at a
  rw [show -(g (t + k) + 1) + -(g n + 1) = -(g (t + k) + g n + 2) by omega,
    show -((t + k : Nat) : Int) + -(n : Int) = -((t + k + n : Nat) : Int) by omega] at b
  have a' := le_floor hg (by omega) a
  have b' := floor_lt hg (by omega) b
  dsimp only
  rw [show t + n + k = t + k + n by omega]
  omega

/-- The characteristic Sturmian word of every irrational slope, or its letter exchange, from any index on. -/
theorem sturmian_excluded (x : Int → Bool) (lo i : Int) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (hg : IrrationalLine g) (a q : Nat) (e : Int) (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t, evol x (a + 2 * t) (i + 1) = decide (g (t + q + 1) - g (t + q) = e)) : False :=
  one_arc_excluded x lo i hlo hleft hg (hg.moved 1 (by omega)) a q e clock visible

/-! ### Square roots -/

/-- The integer square root. -/
def isqrt : Nat → Nat
  | 0 => 0
  | n + 1 => if (isqrt n + 1) * (isqrt n + 1) ≤ n + 1 then isqrt n + 1 else isqrt n

theorem isqrt_spec (n : Nat) : isqrt n * isqrt n ≤ n ∧ n < (isqrt n + 1) * (isqrt n + 1) := by
  induction n with
  | zero => decide
  | succ n ih =>
    unfold isqrt
    split
    · refine ⟨by assumption, ?_⟩
      grind
    · omega

private theorem lt_of_sq {a b : Nat} (h : a * a < b * b) : a < b := by
  rcases Nat.lt_or_ge a b with h' | h'
  · exact h'
  · have := Nat.mul_le_mul h' h'; omega

/-- The floors of the multiples of the square root of a number that is not the square of a fraction. -/
theorem sqrt_line (m : Nat) (hm : ∀ p q : Nat, 1 ≤ q → p * p ≠ m * (q * q)) :
    IrrationalLine (fun t => (isqrt (m * (t * t)) : Int)) where
  floors := fun s t hs ht => by
    obtain ⟨a, _⟩ := isqrt_spec (m * (s * s))
    obtain ⟨_, b⟩ := isqrt_spec (m * (t * t))
    generalize isqrt (m * (s * s)) = A at *
    generalize isqrt (m * (t * t)) = B at *
    have h : t * A < s * (B + 1) := by
      apply lt_of_sq
      have e₁ := Nat.mul_le_mul_left (t * t) a
      have e₂ := Nat.mul_lt_mul_of_pos_left b (Nat.mul_pos hs hs)
      grind
    exact_mod_cast h
  irrational := fun p q hq => by
    rcases Int.lt_or_le p 0 with hp | hp
    · refine ⟨1, by omega, Or.inl ?_⟩
      have := Int.mul_nonneg (show (0 : Int) ≤ q by omega) (show (0 : Int) ≤ (isqrt (m * (1 * 1)) : Int) by omega)
      omega
    obtain ⟨p, rfl⟩ : ∃ p' : Nat, p = (p' : Int) := ⟨p.toNat, by omega⟩
    refine ⟨2 * p * q + q + 1, by omega, ?_⟩
    generalize hn : 2 * p * q + q + 1 = n
    obtain ⟨a, b⟩ := isqrt_spec (m * (n * n))
    generalize isqrt (m * (n * n)) = A at *
    rcases Nat.lt_or_gt_of_ne (hm p q hq) with h | h
    · left
      have h' : n * p < q * A := by
        rcases Nat.lt_or_ge (n * p) (q * A) with h' | h'
        · exact h'
        exfalso
        -- m (q n)² < (q A + q)² ≤ (n p + q)², and m q² ≥ p² + 1
        have e₁ := Nat.mul_lt_mul_of_pos_left b (Nat.mul_pos hq hq)
        have e₂ : q * A + q ≤ n * p + q := by omega
        have e₃ := Nat.mul_le_mul e₂ e₂
        have e₄ := Nat.mul_le_mul_right (n * n) (show p * p + 1 ≤ m * (q * q) by omega)
        have e₅ : n * n = n * (2 * p * q) + n * q + n := by rw [← hn]; grind
        have e₆ : q * q ≤ n * q := Nat.mul_le_mul_right q (by omega)
        grind
      exact_mod_cast h'
    · right
      have h' : q * (A + 1) < n * p := by
        rcases Nat.lt_or_ge (q * (A + 1)) (n * p) with h' | h'
        · exact h'
        exfalso
        -- (n p - q)² ≤ (q A)² ≤ m (q n)², and m q² + 1 ≤ p²
        have e₁ := Nat.mul_le_mul_left (q * q) a
        have e₄ := Nat.mul_le_mul_right (n * n) (show m * (q * q) + 1 ≤ p * p by omega)
        have e₅ : n * n = n * (2 * p * q) + n * q + n := by rw [← hn]; grind
        have e₇ : n * p * (n * p) ≤ (q * A + q) * (n * p) := Nat.mul_le_mul_right _ (by grind)
        have e₈ : (q * A) * (n * p) ≤ (q * A) * (q * A + q) := Nat.mul_le_mul_left _ (by grind)
        have hA : q * A ≤ n * p := by
          rcases Nat.lt_or_ge (n * p) (q * A) with h'' | h''
          · have := Nat.mul_self_lt_mul_self h''
            grind
          · exact h''
        have e₉ := Nat.mul_le_mul_right q hA
        grind
      exact_mod_cast h'

theorem two_irrational (p q : Nat) (hq : 1 ≤ q) : p * p ≠ 2 * (q * q) := by
  induction q using Nat.strongRecOn generalizing p with
  | ind q ih =>
    intro h
    obtain ⟨k, rfl⟩ : ∃ k, p = 2 * k := by
      rcases Nat.mod_two_eq_zero_or_one p with e | e
      · exact ⟨p / 2, by omega⟩
      · obtain ⟨k, rfl⟩ : ∃ k, p = 2 * k + 1 := ⟨p / 2, by omega⟩
        grind
    have h' : q * q = 2 * (k * k) := by grind
    have hk : 1 ≤ k := by
      rcases Nat.eq_zero_or_pos k with rfl | hk
      · have := Nat.mul_pos hq hq; omega
      · exact hk
    have hkq : k < q := by
      apply lt_of_sq
      have := Nat.mul_pos hk hk
      omega
    exact ih k hkq q hk h'

/-- The silver half-circle word, from any index on: not the neighbour of an alternating column. -/
theorem silver_excluded (x : Int → Bool) (lo i : Int) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (a q : Nat) (b : Int) (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1)) :
    ¬ ∀ t, evol x (a + 2 * t) (i + 1) = decide ((isqrt (2 * ((t + q) * (t + q))) : Int) % 2 = b) :=
  fun h => half_circle_excluded x lo i hlo hleft (sqrt_line 2 two_irrational) a q b clock h


/-! ### Real numbers -/


theorem real_line (β : ℝ) (hβ : Irrational β) : IrrationalLine (fun t : ℕ => ⌊(t : ℝ) * β⌋) where
  floors := fun m n hm hn => by
    have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
    have hn' : (1 : ℝ) ≤ n := by exact_mod_cast hn
    have a := Int.floor_le ((m : ℝ) * β)
    have b := Int.lt_floor_add_one ((n : ℝ) * β)
    have h : ((n : ℝ) * ⌊(m : ℝ) * β⌋) < m * (⌊(n : ℝ) * β⌋ + 1) := by nlinarith
    exact_mod_cast h
  irrational := fun p q hq => by
    have hq' : (1 : ℝ) ≤ q := by exact_mod_cast hq
    have ne : (q : ℝ) * β ≠ p := by
      intro h
      apply hβ
      refine ⟨(p : ℚ) / q, ?_⟩
      push_cast
      rw [← h]
      field_simp
    rcases lt_or_gt_of_ne ne with h | h
    · obtain ⟨n, hn⟩ := exists_nat_gt ((q : ℝ) / (p - q * β))
      have pos : 0 < (p : ℝ) - q * β := by linarith
      have key : (q : ℝ) < n * (p - q * β) := by rwa [div_lt_iff₀ pos] at hn
      have hn1 : 1 ≤ n := by
        rcases Nat.eq_zero_or_pos n with rfl | h1
        · simp at key; linarith
        · exact h1
      refine ⟨n, hn1, Or.inr ?_⟩
      have fl := Int.floor_le ((n : ℝ) * β)
      have : (q : ℝ) * (⌊(n : ℝ) * β⌋ + 1) < n * p := by nlinarith
      exact_mod_cast this
    · obtain ⟨n, hn⟩ := exists_nat_gt ((q : ℝ) / (q * β - p))
      have pos : 0 < (q : ℝ) * β - p := by linarith
      have key : (q : ℝ) < n * (q * β - p) := by rwa [div_lt_iff₀ pos] at hn
      have hn1 : 1 ≤ n := by
        rcases Nat.eq_zero_or_pos n with rfl | h1
        · simp at key; linarith
        · exact h1
      refine ⟨n, hn1, Or.inl ?_⟩
      have fl := Int.lt_floor_add_one ((n : ℝ) * β)
      have : (n : ℝ) * p < q * ⌊(n : ℝ) * β⌋ := by nlinarith
      exact_mod_cast this

/-- Nothing else satisfies the integer hypothesis. -/
theorem line_real (f : ℕ → ℤ) (hf : IrrationalLine f) :
    ∃ β : ℝ, Irrational β ∧ ∀ t : ℕ, 1 ≤ t → f t = ⌊(t : ℝ) * β⌋ := by
  let S : Set ℝ := {y | ∃ n : ℕ, 1 ≤ n ∧ y = (f n : ℝ) / n}
  have bound : ∀ m : ℕ, 1 ≤ m → ∀ y ∈ S, y ≤ ((f m : ℝ) + 1) / m := by
    rintro m hm y ⟨n, hn, rfl⟩
    have hm' : (0 : ℝ) < m := by exact_mod_cast hm
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    have h := hf.floors n m hn hm
    have h' : (m : ℝ) * f n < n * (f m + 1) := by exact_mod_cast h
    rw [div_le_div_iff₀ hn' hm']
    nlinarith
  have ne : S.Nonempty := ⟨_, 1, le_refl 1, rfl⟩
  have bdd : BddAbove S := ⟨_, bound 1 le_rfl⟩
  have lo : ∀ n : ℕ, 1 ≤ n → (f n : ℝ) ≤ n * sSup S := by
    intro n hn
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    have := le_csSup bdd ⟨n, hn, rfl⟩
    rw [div_le_iff₀ hn'] at this
    linarith
  have hi : ∀ n : ℕ, 1 ≤ n → (n : ℝ) * sSup S ≤ f n + 1 := by
    intro n hn
    have hn' : (0 : ℝ) < n := by exact_mod_cast hn
    have := csSup_le ne (bound n hn)
    rw [le_div_iff₀ hn'] at this
    linarith
  have irr : Irrational (sSup S) := by
    rintro ⟨r, hr⟩
    have hd : (0 : ℝ) < r.den := by exact_mod_cast r.pos
    have e : (r.den : ℝ) * sSup S = r.num := by
      rw [← hr]
      have := Rat.den_mul_eq_num r
      exact_mod_cast this
    obtain ⟨n, hn, h | h⟩ := hf.irrational r.num r.den r.pos
    · have h' : (n : ℝ) * r.num < r.den * f n := by exact_mod_cast h
      have := lo n hn
      have : (r.den : ℝ) * f n ≤ r.den * (n * sSup S) := by nlinarith
      nlinarith
    · have h' : (r.den : ℝ) * (f n + 1) < n * r.num := by exact_mod_cast h
      have := hi n hn
      have : (r.den : ℝ) * (n * sSup S) ≤ r.den * (f n + 1) := by nlinarith
      nlinarith
  refine ⟨sSup S, irr, fun t ht => ?_⟩
  symm
  rw [Int.floor_eq_iff]
  refine ⟨lo t ht, lt_of_le_of_ne (hi t ht) fun h => ?_⟩
  apply irr
  have ht' : (t : ℝ) ≠ 0 := by
    have : (0 : ℝ) < t := by exact_mod_cast ht
    linarith
  refine ⟨((f t : ℚ) + 1) / t, ?_⟩
  push_cast
  rw [← h]
  field_simp

theorem irrationalLine_iff (f : ℕ → ℤ) :
    IrrationalLine f ↔ ∃ β : ℝ, Irrational β ∧ ∀ t : ℕ, 1 ≤ t → f t = ⌊(t : ℝ) * β⌋ := by
  refine ⟨line_real f, ?_⟩
  rintro ⟨β, hβ, h⟩
  have R := real_line β hβ
  refine ⟨fun m n hm hn => ?_, fun p q hq => ?_⟩
  · rw [h m hm, h n hn]; exact R.floors m n hm hn
  · obtain ⟨n, hn, hh⟩ := R.irrational p q hq
    refine ⟨n, hn, ?_⟩
    rw [h n hn]; exact hh

theorem real_phase (α θ : ℝ) : PhaseLine (fun t : ℕ => ⌊(t : ℝ) * α⌋) (fun t : ℕ => ⌊(t : ℝ) * α + θ⌋) := by
  intro t n _
  have e : (((t + n : ℕ) : ℝ) * α + θ) = ((t : ℝ) * α + θ) + (n : ℝ) * α := by push_cast; ring
  have a := Int.le_floor_add ((t : ℝ) * α + θ) ((n : ℝ) * α)
  have b := Int.le_floor_add_floor ((t : ℝ) * α + θ) ((n : ℝ) * α)
  dsimp only
  rw [e]
  omega

/-- The arc `[0, γ)`, in floors. -/
theorem arc_floor (y γ : ℝ) (h₀ : 0 < γ) (h₁ : γ < 1) : Int.fract y < γ ↔ ⌊y⌋ - ⌊y - γ⌋ = 1 := by
  have a := Int.floor_add_fract y
  have b := Int.fract_nonneg y
  have c := Int.fract_lt_one y
  constructor
  · intro h
    have : ⌊y - γ⌋ = ⌊y⌋ - 1 := by
      rw [Int.floor_eq_iff]; push_cast; constructor <;> linarith
    omega
  · intro h
    by_contra hn
    have hn' : γ ≤ Int.fract y := not_lt.mp hn
    have : ⌊y - γ⌋ = ⌊y⌋ := by
      rw [Int.floor_eq_iff]; constructor <;> linarith
    omega

/-- **The rotation form.** Code the rotation by an irrational `α` by the arc `[0, γ)`, or by its complement (`c = true`),
and start `d` steps along the orbit of the end `0` (`b = false`) or of the end `γ` (`b = true`). Beside a column that
reads `0101…` from time `a`, in a row with a leftmost black cell, the right neighbour on the white ticks from `a` on is
not this word. -/
theorem rotation_excluded (x : ℤ → Bool) (lo i : ℤ) (hlo : x lo = true) (hleft : ∀ j < lo, x j = false)
    (α γ : ℝ) (hα : Irrational α) (h₀ : 0 < γ) (h₁ : γ < 1) (d : ℤ) (b c : Bool) (a : ℕ)
    (clock : ∀ t, evol x (a + t) i = decide (t % 2 = 1))
    (visible : ∀ t : ℕ, evol x (a + 2 * t) (i + 1) =
      xor c (decide (Int.fract ((if b then γ else 0) + ((t : ℝ) + d) * α) < γ))) : False := by
  let k := d.natAbs
  obtain ⟨q, hq⟩ : ∃ q : ℕ, (k : ℤ) + d = q := ⟨((k : ℤ) + d).toNat, by omega⟩
  have shift (t : ℕ) : (((t + k : ℕ) : ℝ) + d) = ((t + q : ℕ) : ℝ) := by
    have : (k : ℝ) + d = q := by exact_mod_cast hq
    push_cast; linarith
  have clock' : ∀ t, evol x (a + 2 * k + t) i = decide (t % 2 = 1) := fun t => by
    rw [show a + 2 * k + t = a + (2 * k + t) by omega, clock, show (2 * k + t) % 2 = t % 2 by omega]
  cases b
  · refine arc_excluded x lo i hlo hleft (real_line α hα) (real_phase α (-γ)) (a + 2 * k) q 1
      (fun v => xor c (decide (v 0 = -1))) (fun v v' h => by rw [show v 0 = v' 0 from h 0 (by omega)]) clock'
      (fun t => ?_)
    rw [show a + 2 * k + 2 * t = a + 2 * (t + k) by omega, visible, shift]
    congr 1
    rw [decide_eq_decide, arc_floor _ γ h₀ h₁]
    simp only [Bool.false_eq_true, ite_false, zero_add, add_zero, sub_eq_add_neg]
    omega
  · refine arc_excluded x lo i hlo hleft (real_line α hα) (real_phase α γ) (a + 2 * k) q 1
      (fun v => xor c (decide (v 0 = 1))) (fun v v' h => by rw [show v 0 = v' 0 from h 0 (by omega)]) clock'
      (fun t => ?_)
    rw [show a + 2 * k + 2 * t = a + 2 * (t + k) by omega, visible, shift]
    congr 1
    rw [decide_eq_decide, arc_floor _ γ h₀ h₁]
    simp only [ite_true, add_zero]
    rw [add_comm γ, add_sub_cancel_right]


end RotationEndpoints

end Rule30Submission
