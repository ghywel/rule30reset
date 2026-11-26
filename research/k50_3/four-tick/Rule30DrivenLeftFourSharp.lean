module

public import Ruliology.CellularAutomata.Rule30DrivenLeftDepthTwo
public import Ruliology.CellularAutomata.Rule30DrivenLeftFourLower

/-!
# Four inverse ticks beside a prescribed wall: sharp, given one finite check

`ExactAt 4 2 72` is a finite check: every row at age 72 of a depth-two start under any wall,
against all 256 choices of the four predecessors' bits at sites `-1` and `0`. It passes by
exhaustive computation over the 10,582 rows (two independent programs in the record, N30). Given
it, `four_tick_least_ages` gives the sharp ages 72 and 73, with the witnesses of
`Rule30DrivenLeftFourLower`. This is one term of the chain in `k`, kept in the record as data.
-/

@[expose] public section

namespace Ruliology.CellularAutomata
namespace Rule30DrivenLeftFourSharp

open Rule30Jen Rule30DrivenLeft Rule30EveryKLine Rule30DrivenLeftDepthTwo Rule30DrivenLeftFourLower

/-- `FourTickAt` from `ExactAt 4`: the four predecessors as the rows `1, …, 4` of a chain. -/
theorem fourTickAt_of_exactAt {lo A : Nat} (h : ∀ m t, lo ≤ m → A ≤ t → ExactAt 4 m t) :
    FourTickAt lo A := by
  intro m hm t ht wall s a b c d hs1 hs0 ha hb hc hd
  have key := h m t hm ht wall s
    (fun i => match i with | 0 => L wall s t | 1 => a | 2 => b | 3 => c | _ => d)
    hs1 hs0 (fun p _ => rfl) (fun i hi p hp => by
      match i, hi with
      | 0, _ => exact ha p hp
      | 1, _ => exact hb p hp
      | 2, _ => exact hc p hp
      | 3, _ => exact hd p hp)
  exact key

/-- **Four inverse ticks beside a prescribed wall, sharp, given the depth-two check at age 72.**
From age 72 every fourth predecessor of a start at depth at least two has its leftmost black
cell at `f + 4`, and from age 73 for the adjacent start; no smaller uniform ages work. -/
theorem four_tick_least_ages (h : ExactAt 4 2 72) :
    FourTickAt 2 72 ∧ FourTickAt 1 73 ∧ (∀ A, FourTickAt 2 A → 72 ≤ A) ∧
      (∀ A, FourTickAt 1 A → 73 ≤ A) :=
  ⟨fourTickAt_of_exactAt fun _ _ hm ht => exactAt_of_two h (by omega) ht (by omega),
   fourTickAt_of_exactAt fun _ _ hm ht => exactAt_of_two h (by omega) (by omega) (by omega),
   four_tick_age_nonadjacent, four_tick_age_adjacent⟩

end Rule30DrivenLeftFourSharp
end Ruliology.CellularAutomata
