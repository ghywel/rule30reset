import Mathlib
import Ruliology.CellularAutomata.Rule30RotationEndpoints

/-! Companion check, not part of the kit change. It identifies the integer hypotheses of `Rule30RotationEndpoints` with
the floors of lines of one irrational slope, and reads the exclusion as a statement about a circle rotation coded by one
arc and started on the orbit of either end. -/

namespace RotationRealBridge
open Ruliology.CellularAutomata.Rule30RotationEndpoints
open Ruliology.CellularAutomata.Rule30Realization (evol)

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

end RotationRealBridge

#print axioms RotationRealBridge.irrationalLine_iff
#print axioms RotationRealBridge.real_phase
#print axioms RotationRealBridge.rotation_excluded
