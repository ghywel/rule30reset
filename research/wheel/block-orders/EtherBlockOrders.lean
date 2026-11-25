import Ruliology.CellularAutomata.Rule30PeriodTwoCoupled

namespace M181BlockOrders

open Ruliology.CellularAutomata
open Rule30PeriodTwoCoupled
open Rule30Ether (drv)

/-- The white-time readings of the kit's physical periodic right half. -/
theorem ether_white (s : Nat) :
    drv altCol (etherRight 1) (2 * s + 1) 1 = !(s % 2 == 1) := by
  have h := congrArg Bool.not (ether_coupled_witness.2 s)
  rw [ether_free_bits] at h
  simpa using h.symm

def seam (length : Bool → Nat) (order : Nat → Bool) : Nat → Nat
  | 0 => 0
  | n + 1 => seam length order n + length (order n)

theorem seam_even (length : Bool → Nat) (even : ∀ b, length b % 2 = 0)
    (order : Nat → Bool) (n : Nat) : seam length order n % 2 = 0 := by
  induction n with
  | zero => rfl
  | succ n ih => simp [seam, Nat.add_mod, ih, even]

/-- Every ordering of any two even-length repetitions of the word 10 is
    physically read beside the alternating boundary by the same right half. -/
theorem ether_even_blocks (length : Bool → Nat) (even : ∀ b, length b % 2 = 0)
    (order : Nat → Bool) (n y : Nat) (_hy : y < length (order n)) :
    drv altCol (etherRight 1) (2 * (seam length order n + y) + 1) 1 = !(y % 2 == 1) := by
  rw [ether_white]
  simp [Nat.add_mod, seam_even length even order n]

/-- The commuting control can even use the same lengths as the silver example. -/
theorem ether_18_28 (order : Nat → Bool) (n y : Nat)
    (hy : y < (if order n then 28 else 18)) :
    drv altCol (etherRight 1)
      (2 * (seam (fun b => if b then 28 else 18) order n + y) + 1) 1 = !(y % 2 == 1) :=
  ether_even_blocks _ (by intro b; cases b <;> decide) order n y hy

end M181BlockOrders
