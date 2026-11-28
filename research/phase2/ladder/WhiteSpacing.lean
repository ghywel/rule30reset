import Ruliology.CellularAutomata.Rule30AgedLeftDiagonals

namespace PhaseTwo.WhiteSpacing
open Ruliology.CellularAutomata.Rule30AgedLeftDiagonals

def EventuallyColor (c : Nat → Bool) (v : Bool) : Prop :=
  ∃ T, ∀ t, T ≤ t → c t = v

private theorem blackEdge {b : Nat → Nat → Bool} (rec : Recurrence b) (edge : b 0 0 = true)
    (t : Nat) : b 0 t = true := by
  induction t with
  | zero => exact edge
  | succ t ih => exact (rec.1 t).trans ih

private theorem noAdjacent {b : Nat → Nat → Bool} (rec : Recurrence b) (edge : b 0 0 = true)
    (j : Nat) : ¬ (EventuallyColor (b j) false ∧ EventuallyColor (b (j+1)) false) := by
  induction j with
  | zero =>
    rintro ⟨⟨T, h⟩, _⟩
    have := h T (by omega)
    rw [blackEdge rec edge T] at this
    contradiction
  | succ j ih =>
    rintro ⟨⟨T, middle⟩, ⟨U, right⟩⟩
    apply ih
    refine ⟨⟨max T U, ?_⟩, T, middle⟩
    intro t ht
    have h := rec.2.2 j t
    rw [right _ (by omega), middle _ (by omega), right _ (by omega)] at h
    simpa using h.symm

private theorem childVaries {b : Nat → Nat → Bool} (rec : Recurrence b) (edge : b 0 0 = true)
    {j : Nat} (white : EventuallyColor (b j) false) (v : Bool) :
    ¬ EventuallyColor (b (j+1)) v := by
  obtain ⟨T, hw⟩ := white
  intro ⟨U, hc⟩
  cases j with
  | zero =>
    have := hw T (by omega)
    rw [blackEdge rec edge T] at this
    contradiction
  | succ j =>
    apply noAdjacent rec edge j
    refine ⟨⟨max T U, ?_⟩, T, hw⟩
    intro t ht
    have h := rec.2.2 j t
    rw [hc _ (by omega), hw _ (by omega), hc _ (by omega)] at h
    cases v <;> cases e : b j t <;> simp [e] at h ⊢

/-- From any eventually white wheel the second successor eventually latches black. -/
theorem white_latches_two {b : Nat → Nat → Bool} (rec : Recurrence b) (edge : b 0 0 = true)
    {j : Nat} (white : EventuallyColor (b j) false) : EventuallyColor (b (j+2)) true := by
  obtain ⟨T, hw⟩ := white
  have someBlack : ∃ t ≥ T, b (j+1) t = true := by
    apply Classical.byContradiction
    intro no
    apply childVaries rec edge ⟨T, hw⟩ false
    refine ⟨T, fun t ht => ?_⟩
    cases e : b (j+1) t with
    | false => rfl
    | true => exact (no ⟨t, ht, e⟩).elim
  obtain ⟨u, hu, hblack⟩ := someBlack
  have latch (n : Nat) : b (j+2) ((u+1)+n) = true := by
    induction n with
    | zero => rw [Nat.add_zero, rec.2.2, hw _ hu, hblack]; simp
    | succ n ih =>
      rw [← Nat.add_assoc, rec.2.2, hw _ (by omega), ih]
      simp
  exact ⟨u+1, fun t ht => by simpa [show u+1+(t-(u+1)) = t by omega] using latch (t-(u+1))⟩

/-- Eventual white wheels in a black-headed strip have spatial gap at least five.
    No temporal periodicity assumption is needed. -/
theorem white_gap_five {b : Nat → Nat → Bool} (rec : Recurrence b) (edge : b 0 0 = true)
    {j k : Nat} (hj : EventuallyColor (b j) false) (hk : EventuallyColor (b k) false)
    (lt : j < k) : j+5 ≤ k := by
  apply Classical.byContradiction
  intro near
  have successor3 : ∀ v, ¬ EventuallyColor (b (j+3)) v := by
    intro v ⟨V, hv⟩
    obtain ⟨B, hb⟩ := white_latches_two rec edge hj
    apply childVaries rec edge hj (!v)
    refine ⟨max B V, fun t ht => ?_⟩
    have h := rec.2.2 (j+1) t
    rw [hv _ (by omega), hb _ (by omega)] at h
    cases v <;> cases e : b (j+1) t <;> simp [e] at h ⊢
  have cases_k : k = j+1 ∨ k = j+2 ∨ k = j+3 ∨ k = j+4 := by omega
  rcases cases_k with e | e | e | e <;> subst k
  · exact childVaries rec edge hj false hk
  · obtain ⟨W, hw⟩ := hk
    obtain ⟨B, hb⟩ := white_latches_two rec edge hj
    have h := hw (max W B) (by omega)
    rw [hb _ (by omega)] at h
    contradiction
  · exact successor3 false hk
  · obtain ⟨W, hw⟩ := hk
    obtain ⟨B, hb⟩ := white_latches_two rec edge hj
    apply successor3 true
    refine ⟨max W B, fun t ht => ?_⟩
    have h := rec.2.2 (j+2) t
    rw [hw _ (by omega), hb _ (by omega), hw _ (by omega)] at h
    cases e : b (j+3) t <;> simp [e] at h ⊢

end PhaseTwo.WhiteSpacing
