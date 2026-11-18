import Ruliology.CellularAutomata.Rule30AgedLeftDiagonals

/-! A pointed recurrent strip can choose black immediately beyond every white
wheel at time zero. Every finite prefix is periodic from that same origin. -/
namespace Rule30PointedWhiteFork
open Ruliology.CellularAutomata.Rule30AgedLeftDiagonals

private def child (a b : Nat → Bool) (s : Bool) : Nat → Bool
  | 0 => s
  | t+1 => xor (a t) (b t || child a b s t)

private theorem child_shift {a b : Nat → Bool} {p : Nat}
    (ha : PeriodFrom a 0 p) (hb : PeriodFrom b 0 p) (s : Bool) (t : Nat) :
    child a b s (t+p) = child a b (child a b s p) t := by
  induction t with
  | zero => simp [child]
  | succ t ih =>
    rw [show t+1+p = (t+p)+1 by omega]
    simp only [child, ha t (by omega), hb t (by omega), ih]

private theorem complement_at_white {a b : Nat → Bool} (hw : ∀ t, b t = false)
    (t : Nat) : child a b false t = !(child a b true t) := by
  induction t with
  | zero => rfl
  | succ t ih =>
    simp only [child, hw, Bool.false_or, ih]
    cases a t <;> cases child a b true t <;> rfl

private theorem lift_column {a b : Nat → Bool} {p : Nat}
    (ha : PeriodFrom a 0 p) (hb : PeriodFrom b 0 p) :
    ∃ s : Bool, PeriodFrom (child a b s) 0 (2*p) ∧ ((∀ t, b t = false) → s = true) := by
  let h := fun s => child a b s p
  have choice : ∃ s : Bool, h (h s) = s ∧ ((∀ t, b t = false) → s = true) := by
    by_cases hw : ∀ t, b t = false
    · refine ⟨true, ?_, fun _ => rfl⟩
      have hc : h false = !(h true) := complement_at_white hw p
      cases ht : h true <;> simp_all
    · have point : ∃ s, h (h s) = s := by
        cases hf : h false <;> cases ht : h true
        · exact ⟨false, by simp [hf]⟩
        · exact ⟨false, by simp [hf]⟩
        · exact ⟨true, by simp [ht, hf]⟩
        · exact ⟨true, by simp [ht]⟩
      obtain ⟨s, hs⟩ := point
      exact ⟨s, hs, fun bad => (hw bad).elim⟩
  obtain ⟨s, hs, hw⟩ := choice
  refine ⟨s, ?_, hw⟩
  intro t _
  rw [show t + 2*p = (t+p)+p by omega, child_shift ha hb, child_shift ha hb]
  change child a b (h (h s)) t = _
  rw [hs]

private structure Pair (n : Nat) where
  a : Nat → Bool
  b : Nat → Bool
  ha : PeriodFrom a 0 (2^n)
  hb : PeriodFrom b 0 (2^n)

private noncomputable def advance {n : Nat} (v : Pair n) : Pair (n+1) :=
  let s := (lift_column v.ha v.hb).choose
  { a := v.b, b := child v.a v.b s
    ha := by simpa [Nat.pow_succ, Nat.mul_comm] using period_double v.hb
    hb := by simpa [Nat.pow_succ, Nat.mul_comm] using (lift_column v.ha v.hb).choose_spec.1 }

private noncomputable def pairs : (n : Nat) → Pair n
  | 0 => ⟨fun _ => true, fun _ => true, fun _ _ => rfl, fun _ _ => rfl⟩
  | n+1 => advance (pairs n)

private noncomputable def strip (j : Nat) := (pairs j).a

/-- One phase works at all depths at once. Its entire width-(w+1) band
repeats from time zero with a common (possibly nonminimal) period. -/
theorem exists_pointed_strip :
    ∃ d : Nat → Nat → Bool, Recurrence d ∧ d 0 0 = true ∧
      (∀ w j, j ≤ w → PeriodFrom (d j) 0 (2^w)) ∧
      ∀ j, (∀ t, d j t = false) → d (j+1) 0 = true := by
  refine ⟨strip, ⟨fun _ => rfl, fun _ => rfl, fun _ _ => rfl⟩, rfl, ?_, ?_⟩
  · intro w
    induction w with
    | zero =>
      intro j hj
      obtain rfl : j = 0 := by omega
      exact (pairs 0).ha
    | succ w ih =>
      intro j hj
      by_cases he : j = w+1
      · subst j
        exact (pairs (w+1)).ha
      · simpa [Nat.pow_succ, Nat.mul_comm] using period_double (ih j (by omega))
  · intro j hw
    cases j with
    | zero => rfl
    | succ i => exact (lift_column (pairs i).ha (pairs i).hb).choose_spec.2 hw

open Ruliology.CellularAutomata.Rule30FiniteDiagonals (Ld)

/-- Truncating the initial row to [0,w] physically realizes its pointed band
at every tick. The finite seed may depend on w. -/
theorem finite_seed_prefix {d : Nat → Nat → Bool} (hd : Recurrence d) (w : Nat) :
    ∃ x : Int → Bool, (∀ i, i < 0 ∨ (w : Int) < i → x i = false) ∧
      ∀ t j, j ≤ w → Ld x 0 j t = d j t := by
  let x := fun i : Int => if 0 ≤ i ∧ i ≤ (w : Int) then d i.toNat 0 else false
  have outside : ∀ i, i < 0 ∨ (w : Int) < i → x i = false := by
    intro i hi
    simp [x, show ¬(0 ≤ i ∧ i ≤ (w : Int)) by omega]
  have hx := Ld_recurrence (x := x) (anchor := 0) (fun i hi => outside i (Or.inl hi))
  refine ⟨x, outside, ?_⟩
  intro t
  induction t with
  | zero =>
    intro j hj
    change x (0 - (0 : Int) + j) = d j 0
    simp [x, hj]
  | succ t ih =>
    intro j hj
    match j with
    | 0 => rw [hx.1, hd.1, ih 0 (by omega)]
    | 1 => rw [hx.2.1, hd.2.1, ih 0 (by omega), ih 1 (by omega)]
    | j+2 => rw [hx.2.2, hd.2.2, ih j (by omega), ih (j+1) (by omega), ih (j+2) hj]

#print axioms exists_pointed_strip
#print axioms finite_seed_prefix
end Rule30PointedWhiteFork
