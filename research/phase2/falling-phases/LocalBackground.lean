import Ruliology.CellularAutomata.Rule30Jen

namespace PhaseFalls

open Ruliology.CellularAutomata.Rule30Jen

/-- The eastern cell of an adjacent black pair falls on the next update. -/
private theorem pair_falls {t : Nat} {i : Int}
    (hw : cell t (i-1) = true) (hb : cell t i = true) :
    cell (t+1) i = false := by
  simp [cell, rule, hw, hb]

/-- If a white cell turns black, one of its two neighbours was black. If that
neighbour stays black, the newborn cell and the neighbour form an adjacent
black pair. Its eastern cell falls on the following update. -/
theorem unchanged_inside {t : Nat} {i : Int}
    (quiet : ∀ j : Int, i-1 ≤ j → j ≤ i+1 →
      ¬ (cell t j = true ∧ cell (t+1) j = false))
    (later : ∀ j : Int, i ≤ j → j ≤ i+1 →
      ¬ (cell (t+1) j = true ∧ cell (t+2) j = false)) :
    cell (t+1) i = cell t i := by
  have stays (j : Int) (hl : i-1 ≤ j) (hr : j ≤ i+1) (h : cell t j = true) :
      cell (t+1) j = true := by
    cases hnext : cell (t+1) j with
    | true => rfl
    | false => exact (quiet j hl hr ⟨h,hnext⟩).elim
  cases hc : cell t i with
  | true => exact stays i (by omega) (by omega) hc
  | false =>
    cases hn : cell (t+1) i with
    | false => rfl
    | true =>
      by_cases hw : cell t (i-1) = true
      · exact (later i (by omega) (by omega)
          ⟨hn, pair_falls (stays (i-1) (by omega) (by omega) hw) hn⟩).elim
      · have he : cell t (i+1) = true := by simpa [cell, rule, hc, hw] using hn
        have he' := stays (i+1) (by omega) (by omega) he
        have west : cell (t+1) (i+1-1) = true := by simpa using hn
        exact (later (i+1) (by omega) (by omega) ⟨he',pair_falls west he'⟩).elim

/-- If two successive rows agree on an interval, one tick later they agree
on its interior. -/
private theorem propagate {t : Nat} {i L R : Int}
    (hl : L < i) (hr : i < R)
    (eq : ∀ j : Int, L ≤ j → j ≤ R → cell (t+1) j = cell t j) :
    cell (t+2) i = cell (t+1) i := by
  change rule (cell (t+1) (i-1)) (cell (t+1) i) (cell (t+1) (i+1)) =
    rule (cell t (i-1)) (cell t i) (cell t (i+1))
  rw [eq _ (by omega) (by omega), eq _ (by omega) (by omega), eq _ (by omega) (by omega)]

/-- On seven columns the two quiet ticks keep the middle site unchanged for
each of the next three updates. -/
theorem fixed_site (t : Nat) (i : Int)
    (h : ∀ k : Nat, k < 2 → ∀ j : Int, i-3 ≤ j → j ≤ i+3 →
      ¬ (cell (t+k) j = true ∧ cell (t+k+1) j = false)) :
    ∀ k : Nat, k < 3 → cell (t+k+1) i = cell (t+k) i := by
  have one (j : Int) (lo : i-2 ≤ j) (hi : j ≤ i+2) : cell (t+1) j = cell t j :=
    unchanged_inside (fun x hx hx' => h 0 (by decide) x (by omega) (by omega))
      (fun x hx hx' => h 1 (by decide) x (by omega) (by omega))
  have two (j : Int) (lo : i-1 ≤ j) (hi : j ≤ i+1) : cell (t+2) j = cell (t+1) j :=
    propagate (by omega) (by omega) one
  intro k hk
  rcases (show k=0 ∨ k=1 ∨ k=2 by omega) with rfl | rfl | rfl
  · exact one i (by omega) (by omega)
  · exact two i (by omega) (by omega)
  · exact propagate (t:=t+1) (by omega) (by omega) two

/-- Two ticks without a fall across eight columns keep the middle pair fixed
for three updates. Both members of the fixed pair cannot be black. -/
theorem block_at (t : Nat) (i : Int)
    (h : ∀ k : Nat, k < 2 → ∀ j : Int, i-3 ≤ j → j ≤ i+4 →
      ¬ (cell (t+k) j = true ∧ cell (t+k+1) j = false)) :
    ∃ a b : Bool, (a && b) = false ∧ ∀ k : Nat, k ≤ 3 →
      cell (t+k) i = a ∧ cell (t+k) (i+1) = b := by
  have one (j : Int) (lo : i-2 ≤ j) (hi : j ≤ i+3) : cell (t+1) j = cell t j :=
    unchanged_inside (fun x hx hx' => h 0 (by decide) x (by omega) (by omega))
      (fun x hx hx' => h 1 (by decide) x (by omega) (by omega))
  have two (j : Int) (lo : i-1 ≤ j) (hi : j ≤ i+2) : cell (t+2) j = cell (t+1) j :=
    propagate (by omega) (by omega) one
  have three (j : Int) (lo : i ≤ j) (hi : j ≤ i+1) : cell (t+3) j = cell (t+2) j :=
    propagate (t:=t+1) (by omega) (by omega) two
  refine ⟨cell t i, cell t (i+1), ?_, ?_⟩
  · cases a : cell t i <;> cases b : cell t (i+1) <;> try rfl
    have w : cell t (i+1-1) = true := by simpa using a
    exact (h 0 (by decide) (i+1) (by omega) (by omega) ⟨b,pair_falls w b⟩).elim
  · intro k hk
    have atSite (j : Int) (lo : i ≤ j) (hi : j ≤ i+1) : cell (t+k) j = cell t j := by
      rcases (show k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3 by omega) with rfl | rfl | rfl | rfl
      · rfl
      · exact one j (by omega) (by omega)
      · exact (two j (by omega) (by omega)).trans (one j (by omega) (by omega))
      · exact (three j lo hi).trans ((two j (by omega) (by omega)).trans (one j (by omega) (by omega)))
    exact ⟨atSite i (by omega) (by omega), atSite (i+1) (by omega) (by omega)⟩

theorem block (t : Nat)
    (h : ∀ k : Nat, k < 2 → ∀ i : Int, -10 ≤ i → i ≤ -3 →
      ¬ (cell (t+k) i = true ∧ cell (t+k+1) i = false)) :
    ∃ a b : Bool, (a && b) = false ∧ ∀ k : Nat, k ≤ 3 →
      cell (t+k) (-7) = a ∧ cell (t+k) (-6) = b :=
  block_at t (-7) h

end PhaseFalls
