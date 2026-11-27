import Ruliology.CellularAutomata.Rule30MaskedJen

/-! A finite bound on a period-three plateau of two adjacent singleton
columns, specialized from the kit's window form of masked Jen. -/
namespace PhaseFalls.SixPlateau
open Ruliology.CellularAutomata.Rule30Jen Ruliology.CellularAutomata.Rule30MaskedJen

/-- At the critical distance the earlier time is still white at the later
singleton edge. The right column need only agree up to the penultimate tick. -/
theorem lag_three_deadline (s d : Nat) (j : Int) (edge : j-(d : Int) = -((s+3 : Nat) : Int))
    (left : ∀ k : Nat, k ≤ d → cell (s+k) j = cell (s+k+3) j)
    (right : ∀ k : Nat, k < d → cell (s+k) (j+1) = cell (s+k+3) (j+1)) : False := by
  apply window_jen_col (t₁:=s) (t₂:=s+3) (i:=j) d (by omega) edge
  · intro k hk
    simpa only [show s+3+k=s+k+3 by omega] using left k hk
  · intro k hk
    unfold orCol
    rw [left k (by omega), right k hk, show s+3+k=s+k+3 by omega]

/-- A plateau wider than the critical distance contains the critical window. -/
theorem lag_three_bound (s d : Nat) (j : Int) (lo : 0 ≤ (s : Int)+j+3)
    (width : (s : Int)+j+3 ≤ (d : Int))
    (left : ∀ k : Nat, k ≤ d → cell (s+k) j = cell (s+k+3) j)
    (right : ∀ k : Nat, k < d → cell (s+k) (j+1) = cell (s+k+3) (j+1)) : False := by
  let h := ((s : Int)+j+3).toNat
  have hcast : (h : Int) = (s : Int)+j+3 := Int.toNat_of_nonneg lo
  apply lag_three_deadline s h j (by omega)
  · exact fun k hk => left k (by omega)
  · exact fun k hk => right k (by omega)

end PhaseFalls.SixPlateau
