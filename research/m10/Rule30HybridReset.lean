import Ruliology.CellularAutomata.Rule30HybridWall
import Ruliology.CellularAutomata.Rule30ResetFreeThree

/-! An isolated black outer cell in the alternating 90/150 hybrid. -/
namespace Rule30HybridReset

open Ruliology.CellularAutomata
open Rule30HybridWall
open Rule30ResetFreeRuns (AvoidReset)
open Rule30ResetFreeThree (pairAt pair_avoid)

/-- The outermost black cell is at positive depth `k`, with a white inner neighbour. -/
def IsolatedTop (x : Row) (k : Nat) : Prop :=
  1 ≤ k ∧ x (k - 1) = false ∧ x k = true ∧ WidthLE k x

private theorem odd_top {x : Row} {k : Nat} (wall : x 0 = false) (odd : k % 2 = 1)
    (top : x k = true) (tail : Supp (k + 1) x) :
    IsolatedTop x k ∨ IsolatedTop (H x) (k + 1) := by
  have pos : 1 ≤ k := by omega
  cases inner : x (k - 1) with
  | false => exact Or.inl ⟨pos, inner, top, fun j hj => tail j hj⟩
  | true =>
    have neOne : k ≠ 1 := by
      intro one
      simp [one, wall] at inner
    have hk : 2 ≤ k := by omega
    have cancel : H x k = false := by
      simp [H, show k ≠ 0 by omega, hk, odd, top, inner, tail (k + 1) (by omega)]
    exact Or.inr ⟨by omega, by simpa using cancel, (H_top tail pos).trans top,
      fun j hj => supp_H tail j hj⟩

/-- From an exact top depth, the isolated cell occurs at the advancing edge by tick two. -/
theorem isolated_at_advancing_edge {x : Row} {k : Nat} (wall : x 0 = false)
    (pos : 1 ≤ k) (top : x k = true) (tail : Supp (k + 1) x) :
    ∃ t, t ≤ 2 ∧ IsolatedTop (iter H t x) (k + t) := by
  by_cases odd : k % 2 = 1
  · rcases odd_top wall odd top tail with now | later
    · exact ⟨0, by decide, now⟩
    · exact ⟨1, by decide, later⟩
  · have nextOdd : (k + 1) % 2 = 1 := by omega
    rcases odd_top (H_wall x) nextOdd ((H_top tail pos).trans top) (supp_H tail) with now | later
    · exact ⟨1, by decide, now⟩
    · exact ⟨2, by decide, later⟩

private theorem exists_top {x : Row} {W : Nat} (tail : WidthLE W x)
    (nonzero : ∃ p, 1 ≤ p ∧ x p = true) : ∃ k, 1 ≤ k ∧ x k = true ∧ Supp (k + 1) x := by
  induction W with
  | zero =>
    obtain ⟨p, pos, black⟩ := nonzero
    have white := tail p pos
    simp [black] at white
  | succ w ih =>
    cases last : x (w + 1) with
    | true => exact ⟨w + 1, by omega, last, supp_of_width tail⟩
    | false =>
      apply ih
      intro j hj
      by_cases h : j = w + 1
      · simpa [h] using last
      · exact tail j (by omega)

private theorem reset_of_isolated {x : Row} {k : Nat} (h : IsolatedTop x k) : ¬ AvoidReset x := by
  obtain ⟨pos, inner, black, tail⟩ := h
  intro avoid
  apply avoid (k - 1) 1 inner (tail _ (by omega)) _ rfl
  intro j hj
  rwa [show k - 1 + j + 1 = k by omega]

/-- Every nonzero finite white-wall hybrid row displays the kit's spatial reset word
at one of times 0, 1, 2. The witness always has precisely one black cell. -/
theorem finite_nonzero_reset_in_three {x : Row} {W : Nat} (wall : x 0 = false)
    (finite : WidthLE W x) (nonzero : ∃ p, 1 ≤ p ∧ x p = true) :
    ∃ t, t ≤ 2 ∧ ¬ AvoidReset (iter H t x) := by
  obtain ⟨k, pos, black, tail⟩ := exists_top finite nonzero
  obtain ⟨t, ht, isolated⟩ := isolated_at_advancing_edge wall pos black tail
  exact ⟨t, ht, reset_of_isolated isolated⟩

/-- The kit's immortal pair at depths one and two first has a reset at time two. -/
theorem immortal_pair_sharp :
    Immortal (rowOf 3) ∧ AvoidReset (rowOf 3) ∧ AvoidReset (H (rowOf 3)) ∧
      ¬ AvoidReset (iter H 2 (rowOf 3)) := by
  have finite : WidthLE 2 (rowOf 3) := rowOf_width (by decide)
  have small : ∀ k : Fin 4, rowOf 3 k = pairAt 1 k ∧ H (rowOf 3) k = pairAt 2 k := by
    decide
  have rows : ∀ k, rowOf 3 k = pairAt 1 k ∧ H (rowOf 3) k = pairAt 2 k := by
    intro k
    by_cases h : k < 4
    · exact small ⟨k, h⟩
    · rw [finite k (by omega), supp_H (supp_of_width finite) k (by omega)]
      simp [pairAt, show k ≠ 1 by omega, show k ≠ 2 by omega, show k ≠ 3 by omega]
  have row0 : rowOf 3 = pairAt 1 := funext fun k => (rows k).1
  have row1 : H (rowOf 3) = pairAt 2 := funext fun k => (rows k).2
  refine ⟨immortal_three, row0 ▸ pair_avoid 1, row1 ▸ pair_avoid 2, ?_⟩
  exact reset_of_isolated (k := 4) ⟨by decide, by decide, by decide,
    fun j hj => supp_iter_H (supp_of_width finite) 2 j hj⟩

end Rule30HybridReset
