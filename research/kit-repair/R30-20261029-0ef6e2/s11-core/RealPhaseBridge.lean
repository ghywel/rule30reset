import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Push
import Ruliology.CellularAutomata.Rule30GoldenHalfCircle

/-! Companion check for S11. The catalogue result uses integer arithmetic alone.
This file identifies its hypothesis with the strict discrepancy inequality for
the real golden slope and recovers the posted physical statement verbatim up to
unfolding the parity word. -/
namespace GoldenRealPhaseBridge
open Ruliology.CellularAutomata.Rule30GoldenHalfCircle

private theorem ltSqrt5_iff (x y : ℤ) :
    LtSqrt5 x y ↔ (x : ℝ) < y * Real.sqrt 5 := by
  have ds := Real.sq_sqrt (show (0:ℝ) ≤ 5 by norm_num)
  have dp : 0 < Real.sqrt 5 := Real.sqrt_pos.mpr (by norm_num)
  have sq : ((y:ℝ)*Real.sqrt 5)^2 = 5*y*y := by rw [mul_pow,ds]; ring
  have tr : (x*x < 5*y*y) ↔ (x:ℝ)^2 < ((y:ℝ)*Real.sqrt 5)^2 := by
    rw [sq,pow_two]; exact_mod_cast Iff.rfl
  have tl : (5*y*y < x*x) ↔ ((y:ℝ)*Real.sqrt 5)^2 < (x:ℝ)^2 := by
    rw [sq,pow_two]; exact_mod_cast Iff.rfl
  unfold LtSqrt5
  rw [tr,tl]
  by_cases hx : x < 0
  · have xn : (x:ℝ) < 0 := by exact_mod_cast hx
    by_cases hy : 0 ≤ y
    · have yn : (0:ℝ) ≤ y := by exact_mod_cast hy
      simp [hx,hy,lt_of_lt_of_le xn (mul_nonneg yn dp.le)]
    · have yn : (y:ℝ) < 0 := by exact_mod_cast (show y < 0 by omega)
      have hn := mul_neg_of_neg_of_pos yn dp
      have cmp := sq_lt_sq₀ (neg_nonneg.mpr hn.le) (neg_nonneg.mpr xn.le)
      simp [hx,hy,show ¬ 0 ≤ x by omega] at ⊢
      simpa using cmp
  · have xn : (0:ℝ) ≤ x := by exact_mod_cast (show 0 ≤ x by omega)
    by_cases hy : 0 < y
    · have yn : (0:ℝ) < y := by exact_mod_cast hy
      simpa [hx,hy,show 0 ≤ x by omega] using (sq_lt_sq₀ xn (mul_pos yn dp).le)
    · have yn : (y:ℝ) ≤ 0 := by exact_mod_cast (show y ≤ 0 by omega)
      simp [hx,hy,not_lt_of_ge (le_trans (mul_nonpos_of_nonpos_of_nonneg yn dp.le) xn)]

theorem real_phase_goldenLine (θ : ℝ) :
    GoldenLine (fun t => ⌊θ + (t:ℝ)*(Real.sqrt 5-1)⌋) := by
  intro s t
  apply (ltSqrt5_iff _ _).mpr
  push_cast
  linarith [Int.floor_le (θ + (s:ℝ)*(Real.sqrt 5-1)),Int.lt_floor_add_one (θ + (t:ℝ)*(Real.sqrt 5-1))]

open Ruliology.CellularAutomata.Rule30Realization

theorem no_eventual_real_golden_neighbour (x : ℤ → Bool) (L T H : ℕ) (θ : ℝ)
    (hleft : x (-(L:ℤ)) = true) (hzero : ∀ j < -(L:ℤ), x j = false)
    (clock : ∀ t, T ≤ t → evol x t 0 = decide (t%2 = 1))
    (visible : ∀ t, H ≤ t → evol x (2*t) 1 = decide (⌊θ+(t:ℝ)*(Real.sqrt 5-1)⌋%2=1)) : False :=
  no_eventual_golden_neighbour x L T H _ (real_phase_goldenLine θ) hleft hzero clock visible

end GoldenRealPhaseBridge
