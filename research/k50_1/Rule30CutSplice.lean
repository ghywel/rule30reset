import Ruliology.CellularAutomata.Rule30PeriodTwoSideways

/-! A cut of the seven-cell ether that preserves the reference first column
continues to do so after any number of whole spatial periods are prepended. -/
namespace Ruliology.CellularAutomata.Rule30CutSplice

open Rule30Ether Rule30PeriodTwoCoupled Rule30PeriodTwoSideways

/-- The first N ether cells to the right of column B4, then a white tail. -/
def cut (s N p : Nat) : Bool := if p ≤ N then ether (3+p) s else false

def Matches (s N : Nat) : Prop := ∀ t, drv altCol (cut s N) t 1 = ether 4 (s+t)

private def frame (s t p : Nat) := ether (3+p) (s+t)

private theorem frame_step (s t q : Nat) : frame s (t+1) (q+1) =
    Rule30Jen.rule (frame s t q) (frame s t (q+1)) (frame s t (q+2)) := by
  unfold frame
  rw [show s+(t+1) = (s+t)+1 by omega, ether_rule]
  congr 1
  exact ether_congr (by omega) rfl

private theorem frame_seven (s t : Nat) : frame s t 7 = frame s t 0 :=
  ether_congr rfl rfl

private theorem cut_translate (s N p : Nat) : cut s (N+7) (p+7) = cut s N p := by
  unfold cut
  by_cases h : p ≤ N
  · simp only [ite_eq_left h, ite_eq_left (by omega : p + 7 ≤ N + 7)]
    exact ether_congr (by omega) rfl
  · simp [h, show ¬p + 7 ≤ N + 7 by omega]

/-- The full orbit of the extended cut splits at column seven. On its left is the reference
ether; from column seven on is the original orbit, including its driver. -/
theorem splice (s N : Nat) (wall : ∀ t, altCol t = ether 3 (s+t)) (matchCol : Matches s N) :
    ∀ t, (∀ p, p ≤ 7 → drv altCol (cut s (N+7)) t p = ether (3+p) (s+t)) ∧
      (∀ p, drv altCol (cut s (N+7)) t (p+7) = drv altCol (cut s N) t p) := by
  intro t
  induction t with
  | zero =>
    have first (p : Nat) (hp : p ≤ 7) :
        drv altCol (cut s (N+7)) 0 p = frame s 0 p := by
      cases p with
      | zero => exact wall 0
      | succ p => rw [drv_init _ _ _ (by omega)]; simp [cut, frame, show p+1 ≤ N+7 by omega]
    refine ⟨first, ?_⟩
    intro p
    cases p with
    | zero => exact (first 7 (by decide)).trans ((frame_seven s 0).trans (wall 0).symm)
    | succ p => rw [drv_init _ _ _ (by omega), drv_init _ _ _ (by omega), cut_translate]
  | succ t ih =>
    have first (p : Nat) (hp : p ≤ 7) :
        drv altCol (cut s (N+7)) (t+1) p = frame s (t+1) p := by
      cases p with
      | zero => exact (drv_col0 _ _ _).trans (wall _)
      | succ q =>
        have right : drv altCol (cut s (N+7)) t (q+2) = frame s t (q+2) := by
          by_cases inner : q+2 ≤ 7
          · exact ih.1 _ inner
          · have eq : q = 6 := by omega
            subst q
            exact (ih.2 1).trans ((matchCol t).trans (ether_congr rfl rfl))
        rw [drv_isR30 _ _ t q, frame_step, ih.1 _ (by omega), ih.1 _ hp, right]
        rfl
    refine ⟨first, ?_⟩
    intro p
    cases p with
    | zero =>
      exact (first 7 (by decide)).trans ((frame_seven s _).trans ((wall _).symm.trans (drv_col0 _ _ _).symm))
    | succ p =>
      rw [show p+1+7 = (p+7)+1 by omega, drv_isR30 _ _ t (p+7), drv_isR30 _ _ t p,
        show p+7+1 = p+1+7 by omega, show p+7+2 = p+2+7 by omega, ih.2, ih.2, ih.2]

theorem matches_add_seven (s N : Nat) (wall : ∀ t, altCol t = ether 3 (s+t)) (h : Matches s N) :
    Matches s (N+7) := fun t => (splice s N wall h t).1 1 (by decide)

theorem matches_add_periods (s N : Nat) (wall : ∀ t, altCol t = ether 3 (s+t)) (h : Matches s N)
    (m : Nat) : Matches s (N + 7*m) := by
  induction m with
  | zero => simpa using h
  | succ m ih =>
    rw [Nat.mul_succ, ← Nat.add_assoc]
    exact matches_add_seven _ _ wall ih

/-- The first column of a matching cut is four-periodic, so its odd-time gate has period two. -/
theorem matches_gate_period (s N : Nat) (h : Matches s N) (n : Nat) :
    u (cut s N) (n+2) = u (cut s N) n := by
  unfold u
  rw [h, h]
  apply ether_congr rfl
  omega

end Ruliology.CellularAutomata.Rule30CutSplice
