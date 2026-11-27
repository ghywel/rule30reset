import Ruliology.CellularAutomata.Rule30TerminalCensus

namespace LateVocabulary
open Ruliology.CellularAutomata Rule30TerminalCensus Rule30HorizontalDiversity

/-- A logarithmic total per age suffices for a polynomial lower bound
at dyadic widths. The abundance of the required terminal forks is open. -/
theorem dyadic_quadratic {j N : Nat} (c : Census (2^j) N) (positive : 0 < N)
    (forks : j*N ≤ pairSum c.pairs (2^j)) :
    (2^j)^2 ≤ H (2^j) := by
  have raised : ((2^j)^2)^N ≤ (H (2^j))^N := by
    calc
      ((2^j)^2)^N = 4^(j*N) := by
        rw [Nat.pow_right_comm (2 : Nat) j 2, Nat.pow_mul]
      _ ≤ 4^(pairSum c.pairs (2^j)) := Nat.pow_le_pow_right (by decide) forks
      _ ≤ (H (2^j))^N := vocabulary_budget c
  exact Nat.le_of_not_lt (fun lt => Nat.not_lt_of_ge raised (Nat.pow_lt_pow_left lt (by omega)))

end LateVocabulary
