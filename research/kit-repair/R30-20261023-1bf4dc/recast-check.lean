import Mathlib

/-- The recast of `Finite210`: Mathlib's `(R : ℤ) < |i|` is core's `R < i.natAbs`. -/
theorem lt_abs_iff_lt_natAbs (R : ℕ) (i : ℤ) : ((R : ℤ) < |i|) ↔ R < i.natAbs := by
  rw [Int.abs_eq_natAbs]; exact_mod_cast Iff.rfl

theorem lt_abs_iff_lt_natAbs' (R T : ℕ) (i : ℤ) : (((R + T : ℕ) : ℤ) < |i|) ↔ R + T < i.natAbs :=
  lt_abs_iff_lt_natAbs (R + T) i

#print axioms lt_abs_iff_lt_natAbs
