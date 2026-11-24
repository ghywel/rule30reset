import Ruliology.CellularAutomata.Rule30GoldenHalfCircle

/-! A check, not part of any submission (claudeIntel, N15 addendum 1): the exclusion of S11
(`Rule30GoldenHalfCircle.no_eventual_golden_neighbour`) follows from two steps of rule 30 alone, for every row, with no
leftmost black cell and no repetition argument. -/

namespace S11TwoSteps

open Ruliology.CellularAutomata
open Rule30Realization (evol)
open Rule30GoldenHalfCircle (GoldenLine LtSqrt5)

/-- Beside a column that reads white at `s`, black at `s + 1`, the right neighbour is not black at `s` and at `s + 2`. -/
theorem no_two_black (x : Int → Bool) (s : Nat) (i : Int) (w : evol x s i = false) (b : evol x (s + 1) i = true)
    (h : evol x s (i + 1) = true) : evol x (s + 2) (i + 1) = false := by
  have r₁ : evol x (s + 1) (i + 1) = xor (evol x s i) (evol x s (i + 1) || evol x s (i + 1 + 1)) := by
    show Rule30Jen.rule (evol x s (i + 1 - 1)) _ _ = _
    rw [show i + 1 - 1 = i by omega]; rfl
  have r₂ : evol x (s + 2) (i + 1) = xor (evol x (s + 1) i) (evol x (s + 1) (i + 1) || evol x (s + 1) (i + 1 + 1)) := by
    show Rule30Jen.rule (evol x (s + 1) (i + 1 - 1)) _ _ = _
    rw [show i + 1 - 1 = i by omega]; rfl
  rw [r₂, b, r₁, w, h]
  rfl

private theorem sq_lt {x c : Int} (hc : 0 ≤ c) (h : x * x < c * c) : x < c := by
  rcases Int.lt_or_le x c with lt | le
  · exact lt
  · have := Int.mul_le_mul le le hc (Int.le_trans hc le)
    omega

private theorem lt_sq {x c : Int} (hx : 0 ≤ x) (h : c * c < x * x) : c < x := by
  rcases Int.lt_or_le c x with lt | le
  · exact lt
  · have := Int.mul_le_mul le le hx (Int.le_trans hx le)
    omega

/-- The increments of a golden line. -/
theorem upper {f : Nat → Int} (hf : GoldenLine f) (t n : Nat) (c : Int) (hc : 0 ≤ c)
    (h : 5 * (n : Int) * n ≤ c * c) : f (t + n) - f t - 1 + n < c := by
  have g := hf (t + n) t
  rw [show (((t + n : Nat) : Int) - (t : Int)) = (n : Int) by omega] at g
  rcases g with ⟨neg, _⟩ | ⟨_, _, sq⟩
  · omega
  · exact sq_lt hc (by omega)

theorem lower {f : Nat → Int} (hf : GoldenLine f) (t n : Nat) (c : Int) (hn : 1 ≤ n)
    (h : c * c ≤ 5 * (n : Int) * n) : c < f (t + n) - f t + 1 + n := by
  have g := hf t (t + n)
  rw [show ((t : Int) - ((t + n : Nat) : Int)) = -(n : Int) by omega] at g
  rcases g with ⟨neg, pos | sq⟩ | ⟨_, pos, _⟩
  · omega
  · apply lt_sq (by omega)
    have e₁ : (f t - f (t + n) - 1 + -(n : Int)) * (f t - f (t + n) - 1 + -(n : Int)) =
      (f (t + n) - f t + 1 + n) * (f (t + n) - f t + 1 + n) := by grind
    have e₂ : 5 * -(n : Int) * -(n : Int) = 5 * n * n := by grind
    omega
  · omega

/-- The golden half-circle word is black at two consecutive indices, as late as wanted. -/
theorem two_black {f : Nat → Int} (hf : GoldenLine f) (H : Nat) :
    ∃ t, H ≤ t ∧ f t % 2 = 1 ∧ f (t + 1) % 2 = 1 := by
  refine Classical.byContradiction fun no => ?_
  have no' : ∀ t, H ≤ t → ¬ (f t % 2 = 1 ∧ f (t + 1) % 2 = 1) := fun t ht h => no ⟨t, ht, h.1, h.2⟩
  have u1 : ∀ t, f (t + 1) - f t ≤ 2 := fun t => by
    have := upper hf t 1 3 (by omega) (by decide); omega
  have l1 : ∀ t, 1 ≤ f (t + 1) - f t := fun t => by
    have := lower hf t 1 2 (by omega) (by decide); omega
  have u4 : ∀ t, f (t + 4) - f t ≤ 5 := fun t => by
    have := upper hf t 4 9 (by omega) (by decide); omega
  have l5 : ∀ t, 6 ≤ f (t + 5) - f t := fun t => by
    have := lower hf t 5 11 (by omega) (by decide); omega
  have l30 : ∀ t, 37 ≤ f (t + 30) - f t := fun t => by
    have := lower hf t 30 67 (by omega) (by decide); omega
  -- an increment of two is followed by the next one five places later
  have step : ∀ s, H ≤ s → f (s + 1) = f s + 2 → f (s + 5) = f s + 6 ∧ f (s + 5 + 1) = f (s + 5) + 2 := by
    intro s hs h
    have n0 : ¬ (f s % 2 = 1 ∧ f (s + 1) % 2 = 1) := no' s hs
    have n4 : ¬ (f (s + 4) % 2 = 1 ∧ f (s + 5) % 2 = 1) := no' (s + 4) (by omega)
    have a1 : 1 ≤ f (s + 2) - f (s + 1) := l1 (s + 1)
    have a2 : 1 ≤ f (s + 3) - f (s + 2) := l1 (s + 2)
    have a3 : 1 ≤ f (s + 4) - f (s + 3) := l1 (s + 3)
    have a4 : 1 ≤ f (s + 5) - f (s + 4) := l1 (s + 4)
    have b4 : f (s + 5) - f (s + 4) ≤ 2 := u1 (s + 4)
    have b5 : f (s + 6) - f (s + 5) ≤ 2 := u1 (s + 5)
    have c0 := u4 s
    have c1 : 6 ≤ f (s + 6) - f (s + 1) := l5 (s + 1)
    show f (s + 5) = f s + 6 ∧ f (s + 6) = f (s + 5) + 2
    omega
  -- there is one
  obtain ⟨s, hs, h⟩ : ∃ s, H ≤ s ∧ f (s + 1) = f s + 2 := by
    refine Classical.byContradiction fun none => ?_
    have one : ∀ t, H ≤ t → f (t + 1) = f t + 1 := fun t ht => by
      have := l1 t; have := u1 t
      rcases Int.lt_or_le (f (t + 1)) (f t + 2) with lt | le
      · omega
      · exact (none ⟨t, ht, by omega⟩).elim
    have o0 : f (H + 1) = f H + 1 := one H (by omega)
    have o1 : f (H + 2) = f (H + 1) + 1 := one (H + 1) (by omega)
    have o2 : f (H + 3) = f (H + 2) + 1 := one (H + 2) (by omega)
    have o3 : f (H + 4) = f (H + 3) + 1 := one (H + 3) (by omega)
    have o4 : f (H + 5) = f (H + 4) + 1 := one (H + 4) (by omega)
    have := l5 H
    omega
  -- six in a row are too slow
  obtain ⟨e₁, h₁⟩ := step s hs h
  obtain ⟨e₂, h₂⟩ : f (s + 10) = f (s + 5) + 6 ∧ f (s + 11) = f (s + 10) + 2 := step (s + 5) (by omega) h₁
  obtain ⟨e₃, h₃⟩ : f (s + 15) = f (s + 10) + 6 ∧ f (s + 16) = f (s + 15) + 2 := step (s + 10) (by omega) h₂
  obtain ⟨e₄, h₄⟩ : f (s + 20) = f (s + 15) + 6 ∧ f (s + 21) = f (s + 20) + 2 := step (s + 15) (by omega) h₃
  obtain ⟨e₅, h₅⟩ : f (s + 25) = f (s + 20) + 6 ∧ f (s + 26) = f (s + 25) + 2 := step (s + 20) (by omega) h₄
  obtain ⟨e₆, _⟩ : f (s + 30) = f (s + 25) + 6 ∧ f (s + 31) = f (s + 30) + 2 := step (s + 25) (by omega) h₅
  have := l30 s
  omega

/-- **S11 without its hypotheses on the row.** For every row, with or without a leftmost black cell. -/
theorem golden_neighbour_from_two_steps (x : Int → Bool) (T H : Nat) (f : Nat → Int) (hf : GoldenLine f)
    (clock : ∀ t, T ≤ t → evol x t 0 = decide (t % 2 = 1))
    (visible : ∀ t, H ≤ t → evol x (2 * t) 1 = decide (f t % 2 = 1)) : False := by
  obtain ⟨t, ht, h₁, h₂⟩ := two_black hf (H + T)
  have w : evol x (2 * t) 0 = false := by rw [clock _ (by omega)]; simp
  have b : evol x (2 * t + 1) 0 = true := by rw [clock _ (by omega)]; simp
  have v₁ : evol x (2 * t) (0 + 1) = true := by
    rw [show (0 : Int) + 1 = 1 by omega, visible t (by omega)]; simp [h₁]
  have v₂ : evol x (2 * t + 2) (0 + 1) = true := by
    rw [show (0 : Int) + 1 = 1 by omega, show 2 * t + 2 = 2 * (t + 1) by omega, visible (t + 1) (by omega)]; simp [h₂]
  have := no_two_black x (2 * t) 0 w b v₁
  rw [v₂] at this
  exact absurd this (by decide)

end S11TwoSteps

#print axioms S11TwoSteps.golden_neighbour_from_two_steps
