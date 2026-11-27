import ModulusStrip

namespace PhaseFalls.Moduli

open Ruliology.CellularAutomata Rule30StripCertificates

def slice (w k s : Nat) : Nat := (s >>> k) % 2^w

theorem slice_bit {w k s j : Nat} (hj : j < w) :
    (slice w k s).testBit j = s.testBit (k+j) := by
  simp [slice, Nat.testBit_mod_two_pow, Nat.testBit_shiftRight, hj]

private theorem slice_step {w v k s : Nat} (hk : k+v ≤ w)
    (hs : s < 2^w) (l r : Bool) :
    slice v k (stripStep w l r s) =
      stripStep v (if k = 0 then l else s.testBit (k-1))
        (if k+v = w then r else s.testBit (k+v)) (slice v k s) := by
  apply Nat.eq_of_testBit_eq
  intro j
  have small : slice v k s < 2^v := Nat.mod_lt _ (Nat.two_pow_pos v)
  by_cases hj : j < v
  · rw [slice_bit hj, testBit_stripStep _ _ _ _ hs _ (by omega),
      testBit_stripStep _ _ _ _ small _ hj, slice_bit hj]
    congr 1
    · by_cases h : j=0
      · subst j
        simp
      · rw [ite_eq_right h, slice_bit (show j-1 < v by omega)]
        rw [ite_eq_right (show k+j ≠ 0 by omega), show k+(j-1)=k+j-1 by omega]
    · by_cases h : j+1=v
      · rw [ite_eq_left h, show k+j+1=k+v by omega]
      · rw [ite_eq_right h, slice_bit (show j+1 < v by omega)]
        rw [ite_eq_right (show k+j+1 ≠ w by omega), Nat.add_assoc]
  · have le : 2^v ≤ 2^j := Nat.pow_le_pow_right (by decide : 0<2) (by omega)
    have left : slice v k (stripStep w l r s) < 2^j :=
      Nat.lt_of_lt_of_le (Nat.mod_lt _ (Nat.two_pow_pos v)) le
    have right := Nat.lt_of_lt_of_le (stripStep_lt v
      (if k = 0 then l else s.testBit (k-1))
      (if k+v = w then r else s.testBit (k+v)) (slice v k s)) le
    rw [Nat.testBit_lt_two_pow left, Nat.testBit_lt_two_pow right]

theorem slice_run {w v k m : Nat} {a x : Nat → Nat} (hk : k+v ≤ w)
    (run : Run w m a x) : Run v m (fun j => a (k+j)) (fun t => slice v k (x t)) := by
  refine ⟨fun _ => Nat.mod_lt _ (Nat.two_pow_pos v), fun t => ?_⟩
  obtain ⟨l,r,lr⟩ := mem_successors.mp (run.edge t).1
  refine ⟨mem_successors.mpr ⟨_,_,lr ▸ slice_step hk (run.bounded t) l r⟩,
    (fits_iff _ _ _).mpr ?_⟩
  intro j on off
  by_cases hj : j < v
  · rw [slice_bit hj] at on off
    have e := (fits_iff _ _ _).mp (run.edge t).2 (k+j) on off
    rw [permit_bit, decide_eq_true_eq] at e ⊢
    exact ⟨hj,e.2⟩
  · have no : (slice v k (x t)).testBit j = false :=
      Nat.testBit_lt_two_pow (Nat.lt_of_lt_of_le (Nat.mod_lt _ (Nat.two_pow_pos v))
        (Nat.pow_le_pow_right (by decide : 0<2) (by omega : v ≤ j)))
    simp [no] at on

theorem pair_bits {s d j : Nat} (h : (s >>> j) % 4 = (d >>> j) % 4) :
    s.testBit j = d.testBit j ∧ s.testBit (j+1) = d.testBit (j+1) := by
  change (s >>> j)%(2^2) = (d >>> j)%(2^2) at h
  constructor
  · simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight, Nat.add_zero,
      decide_eq_true (by decide : 0<2), Bool.true_and] using
      congrArg (fun n : Nat => n.testBit 0) h
  · simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight,
      decide_eq_true (by decide : 1<2), Bool.true_and] using
      congrArg (fun n : Nat => n.testBit 1) h

private theorem pair_eq_of_bits {s d j : Nat} (h₁ : s.testBit j = d.testBit j)
    (h₂ : s.testBit (j+1) = d.testBit (j+1)) : (s >>> j)%4 = (d >>> j)%4 := by
  change (s >>> j)%(2^2) = (d >>> j)%(2^2)
  apply Nat.eq_of_testBit_eq
  intro k
  cases k with
  | zero => simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight, Nat.add_zero,
      decide_eq_true (by decide : 0<2), Bool.true_and] using h₁
  | succ k =>
    cases k with
    | zero => simpa only [Nat.testBit_mod_two_pow, Nat.testBit_shiftRight,
        decide_eq_true (by decide : 1<2), Bool.true_and] using h₂
    | succ k =>
      simp only [Nat.testBit_mod_two_pow, decide_eq_false (show ¬ (k+1+1 < 2) by omega), Bool.false_and]

/-- A certificate on any contiguous substrip supplies a pair in the full strip. -/
theorem good_of_slice {w v k m : Nat} {a : Nat → Nat} (hk : k+v ≤ w)
    (good : Good v m (fun j => a (k+j))) : Good w m a := by
  intro x hx
  obtain ⟨j,N,hj,h⟩ := good _ (slice_run hk hx)
  refine ⟨k+j,N,by omega,fun t ht => ?_⟩
  obtain ⟨p,q⟩ := pair_bits (h t ht)
  rw [slice_bit (show j < v by omega), slice_bit (show j < v by omega)] at p
  rw [slice_bit hj, slice_bit hj, ← Nat.add_assoc] at q
  exact pair_eq_of_bits p q

end PhaseFalls.Moduli
