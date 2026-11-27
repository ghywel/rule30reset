import ModulusCompress
import ModulusSingleton
import ModulusData3
import ModulusData4
import ModulusData5
import ModulusData7
import ModulusData11
import ModulusData13
import ModulusData17

namespace PhaseFalls.Moduli

private def checkedDivisor (m : Nat) : Prop :=
  3 ∣ m ∨ 4 ∣ m ∨ 5 ∣ m ∨ 7 ∣ m ∨ 11 ∣ m ∨ 13 ∣ m ∨ 17 ∣ m

private instance (m : Nat) : Decidable (checkedDivisor m) := by
  unfold checkedDivisor
  infer_instance

private theorem checkedDivisors :
    (List.range 19).all (fun m => decide (m < 3 ∨ checkedDivisor m)) = true := by decide +kernel

theorem good_small (m : Nat) (hm : 3 ≤ m) (hb : m ≤ 18) (a : Nat → Nat)
    (_ : Valid 6 m a) : Good 6 m a := by
  have h := of_decide_eq_true (List.all_eq_true.mp checkedDivisors m (List.mem_range.mpr (by omega)))
  rcases h with h | h
  · omega
  rcases h with h | h | h | h | h | h | h
  · exact good_of_dvd h (good3 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good4 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good5 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good7 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good11 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good13 fun j _ => Nat.mod_lt _ (by decide))
  · exact good_of_dvd h (good17 fun j _ => Nat.mod_lt _ (by decide))

/-- For each modulus at least three, every six consecutive singleton Rule 30
columns contain a fixed column with cofinal falls on two distinct residues. -/
theorem two_cofinal_every_modulus (m : Nat) (hm : 3 ≤ m) (i : Int) :
    ∃ (j : Fin 6) (r q : Fin m), r ≠ q ∧ Cofinal (i+j.val) r ∧ Cofinal (i+j.val) q :=
  two_cofinal_from_good (by omega : 0 < m) i fun _ ha => good_of_small hm ha good_small

end PhaseFalls.Moduli
