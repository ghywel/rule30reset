module

public import Ruliology.CellularAutomata.Rule30PeriodTwoSideways

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30PeriodTwoSideways

open Rule30Realization Rule30ZeroBoundary Rule30PeriodTwoCoupled

/-- The centre record through tick `T`, including both endpoints, determines
exactly the first `T` western bits once the driven right half is fixed. -/
theorem alternates_through_iff_prefix (L R : Nat → Bool) (T : Nat) :
    (∀ t, t ≤ T → evol (glue L R) t 0 = altCol t) ↔
      ∀ d, 1 ≤ d → d ≤ T → L d = Psi R d := by
  rw [alternates_iff_meets]
  constructor
  · intro h d
    induction d using Nat.strongRecOn with
    | ind d ih =>
      intro hd hT
      by_cases heq : L d = Psi R d
      · exact heq
      · have earlier : ∀ i, 1 ≤ i → i < d → L i = Psi R i :=
          fun i hi hid => ih i hid hi (by omega)
        exact False.elim ((exact_death hd earlier heq).2 (h (d - 1) (by omega)))
  · intro h t ht
    unfold Meets
    rw [← Psi_col]
    exact zrow_light_cone t 1 (fun d hd hdt => h d hd (by omega))

/-- A west of depth at most `B` works through tick `T` precisely when the
corresponding section beyond `B` of the required west is white. -/
theorem supported_west_iff_white_section (R : Nat → Bool) (B T : Nat) :
    (∃ L : Nat → Bool, (∀ d, B < d → L d = false) ∧
      (∀ t, t ≤ T → evol (glue L R) t 0 = altCol t)) ↔
      ∀ d, B < d → d ≤ T → Psi R d = false := by
  constructor
  · rintro ⟨L, hL, h⟩ d hd hT
    rw [← (alternates_through_iff_prefix L R T).mp h d (by omega) hT]
    exact hL d hd
  · intro h
    refine ⟨fun d => if d ≤ B then Psi R d else false, fun d hd => ?_, ?_⟩
    · simp [show ¬ d ≤ B by omega]
    · apply (alternates_through_iff_prefix _ R T).mpr
      intro d hd hT
      by_cases hb : d ≤ B
      · simp [hb]
      · simp [hb, h d (by omega) hT]

/-- Equality of the physical gate words is exactly equality of the decoded
west prefixes. A step from an even tick uses no additional gate reading. -/
theorem required_west_prefix_iff_gate_prefix (R R' : Nat → Bool) (T : Nat) :
    (∀ d, 1 ≤ d → d ≤ T → Psi R d = Psi R' d) ↔
      ∀ s, 2 * s + 1 < T → u R s = u R' s := by
  constructor
  · intro h s hs
    have hz := zrow_light_cone (L := Psi R) (L' := Psi R') (2 * s + 1) 1
      (fun d hd hdt => h d hd (by omega))
    rw [Psi_col, Psi_col, alt_odd, alt_odd] at hz
    simpa using hz
  · intro h
    apply (alternates_through_iff_prefix (Psi R) R' T).mp
    apply (alternates_iff_meets (Psi R) R' T).mpr
    intro t ht
    unfold Meets
    rw [Psi_col]
    obtain ⟨s, rfl | rfl⟩ : ∃ s, t = 2 * s ∨ t = 2 * s + 1 := ⟨t / 2, by omega⟩
    · rw [alt_even, alt_even]
    · rw [alt_odd, alt_odd, h s ht]

end Ruliology.CellularAutomata.Rule30PeriodTwoSideways
