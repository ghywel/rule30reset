import Ruliology.CellularAutomata.Rule30CoupledEmptyRight
import Ruliology.CellularAutomata.Rule30FiniteConfigs

namespace BlockedErosion
open Ruliology.CellularAutomata Rule30Realization Rule30FiniteConfigs

def endpoints (t : Nat) (a b : Bool) (p : Int) : Bool :=
  if p = -(t:Int) then a else if p = (t:Int) then b else false

/-- The two extreme cells of an otherwise white cone realize XOR at its apex. -/
theorem endpoint_xor (t : Nat) (ht : 0 < t) (a b : Bool) :
    evol (endpoints t a b) t 0 = xor a b := by
  have apart : (t:Int) ≠ -(t:Int) := by omega
  have base : evol (endpoints t false b) t 0 = b := by
    cases b with
    | false =>
      exact evol_eq_false_of_lt (lo := (t:Int)+1)
        (x := endpoints t false false) (fun p _ => by simp [endpoints]) t 0 (by omega)
    | true =>
      have hit := evol_left_edge (lo := (t:Int)) (x := endpoints t false true)
        (by simp [endpoints, apart]) (fun p hp => by simp [endpoints, Int.ne_of_lt hp]) t
      simpa using hit
  have flip := (Rule30CoupledEmptyRight.evol_diff_front (p₀ := -(t:Int))
    (x := endpoints t true b) (x' := endpoints t false b)
    (fun p hp => by simp [endpoints, Int.ne_of_gt hp]) (by simp [endpoints]) t).2
  rw [show -(t:Int)+(t:Int)=0 by omega, base] at flip
  cases a with
  | false => simpa using base
  | true => cases b <;> simp_all

/-- Even after complementing either input and/or the output, the endpoint
restriction fails the implication required by the coordinatewise Boolean order. -/
theorem signed_obstruction (t : Nat) (ht : 0 < t) (s₁ s₂ out : Bool) :
    ∃ a b c d : Bool, (a = true → c = true) ∧ (b = true → d = true) ∧
      xor out (evol (endpoints t (xor s₁ a) (xor s₂ b)) t 0) = true ∧
      xor out (evol (endpoints t (xor s₁ c) (xor s₂ d)) t 0) = false := by
  simp only [endpoint_xor t ht]
  cases s₁ <;> cases s₂ <;> cases out <;> decide

end BlockedErosion
