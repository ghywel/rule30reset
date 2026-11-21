module

public import Ruliology.CellularAutomata.Rule30ResetFreeThree
public import Ruliology.CellularAutomata.Rule30PlantedSurvivor

/-!
# Three-row spatial resets in the planted survivor

For a positive planting depth, a flip requires stripe agreement at depths one
and two. Together with the white wall this is already the reset word 010,
and the planting preserves these three cells. Every other start is fixed by
the relabelling, so its inverse is the same finite nonzero start. The planted
image of the infinite stripe falls in the first case and resets at time zero.
-/

@[expose] public section

namespace Ruliology.CellularAutomata.Rule30PlantedReset

open Rule30ZeroBoundary Rule30PlantedSurvivor

/-- The spatial witness in `Rule30ResetFreeThree.finite_nonzero_reset_in_three`. -/
abbrev HasReset (x : Nat → Bool) : Prop :=
  ∃ i n, n % 3 = 1 ∧ x i = false ∧ x (i+n+1) = false ∧
    ∀ j, j < n → x (i+j+1) = true

private theorem prefix_reset {x : Nat → Bool} (wall : x 0 = false)
    (black : x 1 = true) (white : x 2 = false) : HasReset x := by
  refine ⟨0, 1, rfl, wall, white, ?_⟩
  intro j hj
  simpa [show j = 0 by omega] using black

private theorem fixed_of_no_prefix (L : Nat) (hL : 1 ≤ L) (x : Nat → Bool)
    (h : ¬ (x 1 = true ∧ x 2 = false)) : psi L x = x := by
  funext k
  unfold psi
  cases hs : site L k with
  | false => simp
  | true =>
    have hk := (of_decide_eq_true hs : k % 2 = 1 ∧ 2*L+1 ≤ k)
    have hp : pf x k = false := by
      cases flag : pf x k with
      | false => rfl
      | true =>
        have agree := (pf_iff x k).1 flag
        exact False.elim (h ⟨agree 1 (by decide) (by omega), agree 2 (by decide) (by omega)⟩)
    simp [hp]

/-- A spatial reset exists on a white-wall row exactly when one exists after relabelling. -/
theorem psi_preserves_reset (L : Nat) (hL : 1 ≤ L) (x : Nat → Bool) (wall : x 0 = false) :
    HasReset (psi L x) ↔ HasReset x := by
  by_cases hpref : x 1 = true ∧ x 2 = false
  · have a := prefix_reset wall hpref.1 hpref.2
    have b := prefix_reset ((psi_low L x 0 (by omega)).trans wall)
      ((psi_low L x 1 (by omega)).trans hpref.1) ((psi_low L x 2 (by omega)).trans hpref.2)
    exact ⟨fun _ => a, fun _ => b⟩
  · rw [fixed_of_no_prefix L hL x hpref]

private theorem iterate_eq (L : Nat) (y : Nat → Bool) (wall : y 0 = false) (t : Nat) :
    Tn L y t = psi L (zrow (psiInv L y) t) := by
  funext k
  cases k with
  | zero =>
    rw [psi_low L _ 0 (by omega), zrow_wall]
    cases t with
    | zero => exact wall
    | succ t =>
      unfold Tn T
      rw [psi_low L _ 0 (by omega), zrow_wall]
  | succ k => exact Tn_eq L y t (k+1) (by omega)

/-- At each tick the two conjugate trajectories agree on the existence of a spatial reset. -/
theorem reset_at_time_iff (L : Nat) (hL : 1 ≤ L) (y : Nat → Bool)
    (wall : y 0 = false) (t : Nat) :
    HasReset (Tn L y t) ↔ HasReset (zrow (psiInv L y) t) := by
  rw [iterate_eq L y wall]
  exact psi_preserves_reset L hL _ (zrow_wall _ t)

/-- Every nonzero finite white-wall planted start has a spatial reset at time zero, one or two. -/
theorem finite_nonzero_reset_in_three (L : Nat) (hL : 1 ≤ L) (y : Nat → Bool)
    (wall : y 0 = false) (finite : FinSupp y) (nonzero : ∃ p, 1 ≤ p ∧ y p = true) :
    ∃ t : Fin 3, HasReset (Tn L y t.val) := by
  by_cases hpref : y 1 = true ∧ y 2 = false
  · exact ⟨0, prefix_reset wall hpref.1 hpref.2⟩
  · have fixed := fixed_of_no_prefix L hL y hpref
    have inv : psiInv L y = y := (congrArg (psiInv L) fixed).symm.trans (psiInv_psi L y)
    obtain ⟨t, reset⟩ := Rule30ResetFreeThree.finite_nonzero_reset_in_three y finite nonzero
    refine ⟨t, ?_⟩
    rwa [reset_at_time_iff L hL y wall, inv]

/-- The adjacent black pair first displays a reset at time two for every planting depth. -/
theorem pair_sharp (L : Nat) (hL : 1 ≤ L) :
    let y := Rule30ResetFreeThree.pairAt 1
    ¬ HasReset (Tn L y 0) ∧ ¬ HasReset (Tn L y 1) ∧ HasReset (Tn L y 2) := by
  let y := Rule30ResetFreeThree.pairAt 1
  have wall : y 0 = false := by decide
  have fixed : psi L y = y := fixed_of_no_prefix L hL y (by decide)
  have inv : psiInv L y = y := (congrArg (psiInv L) fixed).symm.trans (psiInv_psi L y)
  have transfer (t : Nat) : HasReset (Tn L y t) ↔ HasReset (zrow y t) := by
    rw [reset_at_time_iff L hL y wall, inv]
  have no_reset {x : Nat → Bool} (h : Rule30ResetFreeRuns.AvoidReset x) : ¬ HasReset x := by
    rintro ⟨i, n, residue, left, right, black⟩
    exact h i n left right black residue
  obtain ⟨finite, _, a, b⟩ := Rule30ResetFreeThree.sharpness_two_rows
  have c := (Rule30ResetFreeThree.finSupp_three_avoid_iff_zero_and_pairAt_reset_two y finite).2
  exact ⟨fun h => no_reset a ((transfer 0).1 h), fun h => no_reset b ((transfer 1).1 h),
    (transfer 2).2 (Rule30ResetFreeThree.not_avoid_witness _ c)⟩

end Ruliology.CellularAutomata.Rule30PlantedReset
