import Ruliology.CellularAutomata.Rule30WallDeadlines
import Ruliology.CellularAutomata.Rule30ResetFreeThree

/-! The spatial reset test for the two uniform linear controls. -/
namespace Ruliology.CellularAutomata.Rule30UniformReset

open Rule30WallDeadlines Rule30ZeroBoundary
open Rule30ResetFreeRuns (AvoidReset)
open Rule30ResetFreeThree (pairAt pair_avoid)

private theorem white_tail {h : Bool → Bool → Bool} (quiet : h false false = false)
    {L : Nat → Bool} {W : Nat} (tail : ∀ k, W < k → L k = false) :
    ∀ t k, W + t < k → zr h L t k = false := by
  intro t
  induction t with
  | zero =>
    intro k hk
    simp [zr, show k ≠ 0 by omega, tail k (by omega)]
  | succ t ih =>
    intro k hk
    simp [zr, show k ≠ 0 by omega, ih k (by omega), ih (k + 1) (by omega),
      ih (k - 1) (by omega), quiet]

private theorem deepest {L : Nat → Bool} {W : Nat} (tail : ∀ k, W < k → L k = false)
    (nonzero : ∃ p, 1 ≤ p ∧ L p = true) : ∃ k, L (k + 1) = true ∧ ∀ j, k + 1 < j → L j = false := by
  induction W with
  | zero =>
    obtain ⟨p, pos, black⟩ := nonzero
    have white := tail p (by omega)
    simp [black] at white
  | succ W ih =>
    cases last : L (W + 1) with
    | true => exact ⟨W, last, tail⟩
    | false =>
      apply ih
      intro j hj
      by_cases h : j = W + 1
      · simpa [h] using last
      · exact tail j (by omega)

/-- At exact top depth k+1 the edge is either isolated already or advances to an isolated cell. -/
theorem rule150_isolated_at_edge {L : Nat → Bool} {k : Nat} (top : L (k + 1) = true)
    (tail : ∀ p, k + 1 < p → L p = false) :
    ∃ t, t ≤ 1 ∧ zr h150 L t (k + t) = false ∧ zr h150 L t (k + t + 1) = true ∧
      ∀ p, k + t + 1 < p → zr h150 L t p = false := by
  cases inner : zr h150 L 0 k with
  | false =>
    exact ⟨0, by decide, inner, top, fun p hp => white_tail (h := h150) rfl tail 0 p hp⟩
  | true =>
    have outer := zr150_succ L 0 k
    have edge := zr150_succ L 0 (k + 1)
    rw [zr_zero, zr_zero, inner, top, tail (k + 2) (by omega)] at outer
    rw [zr_zero, zr_zero, zr_zero, top, tail (k + 2) (by omega), tail _ (by omega)] at edge
    exact ⟨1, by decide, outer, edge, fun p hp =>
      white_tail (h := h150) rfl tail 1 p (by omega)⟩

/-- Every finite nonzero seed under rule 150 displays a spatial reset at time zero or one. -/
theorem rule150_reset_in_two {L : Nat → Bool} (finite : FinSupp L)
    (nonzero : ∃ p, 1 ≤ p ∧ L p = true) : ∃ t, t ≤ 1 ∧ ¬ AvoidReset (zr h150 L t) := by
  obtain ⟨_, bound⟩ := finite
  obtain ⟨k, top, tail⟩ := deepest bound nonzero
  obtain ⟨t, ht, white, black, outside⟩ := rule150_isolated_at_edge top tail
  refine ⟨t, ht, fun avoid => avoid (k + t) 1 white (outside _ (by omega)) ?_ rfl⟩
  intro j hj
  simpa [show j = 0 by omega] using black

/-- Two adjacent black cells first reset after one tick. -/
theorem rule150_bound_sharp : AvoidReset (zr h150 (pairAt 1) 0) ∧ ¬ AvoidReset (zr h150 (pairAt 1) 1) := by
  have initial : zr h150 (pairAt 1) 0 = pairAt 1 := by
    funext k
    cases k <;> rfl
  have avoid : AvoidReset (zr h150 (pairAt 1) 0) := by rw [initial]; exact pair_avoid 1
  refine ⟨avoid, ?_⟩
  obtain ⟨t, ht, reset⟩ := rule150_reset_in_two (L := pairAt 1)
    ⟨2, Rule30ResetFreeThree.pair_finite⟩ ⟨1, by decide, by decide⟩
  rcases (show t = 0 ∨ t = 1 by omega) with h | h
  · exact False.elim (reset (h ▸ avoid))
  · exact h ▸ reset

/-- The rule 90 witness has black cells at depths two, three and four. -/
def seed90 (k : Nat) : Bool := decide (2 ≤ k ∧ k ≤ 4)

/-- Under rule 90 the nonzero seed of width four avoids every reset word for three rows. -/
theorem rule90_three_reset_free : FinSupp seed90 ∧ seed90 2 = true ∧
    ∀ t : Fin 3, AvoidReset (zr h90 seed90 t.val) := by
  have tail : ∀ k, 4 < k → seed90 k = false := fun k hk =>
    decide_eq_false (show ¬(2 ≤ k ∧ k ≤ 4) by omega)
  have check : ∀ t : Fin 3, ∀ i n : Fin 7, zr h90 seed90 t.val i.val = false →
      zr h90 seed90 t.val (i.val + n.val + 1) = false →
      (∀ j : Fin n.val, zr h90 seed90 t.val (i.val + j.val + 1) = true) →
      n.val % 3 ≠ 1 := by decide
  refine ⟨⟨4, tail⟩, by decide, ?_⟩
  intro t i n left right ones modone
  have positive : 0 < n := by omega
  have last := ones (n - 1) (by omega)
  have within : i + n ≤ 4 + t.val := by
    by_cases h : i + n ≤ 4 + t.val
    · exact h
    · rw [white_tail (h := h90) rfl tail t.val _ (by omega)] at last
      cases last
  have ht := t.isLt
  exact check t ⟨i, by omega⟩ ⟨n, by omega⟩ left right (fun j => ones j j.isLt) modone

end Ruliology.CellularAutomata.Rule30UniformReset
