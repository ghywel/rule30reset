module
public import Rule30QuietCornerClock
public import Ruliology.CellularAutomata.Rule30EtherThreeLeft

@[expose] public section
namespace Ruliology.CellularAutomata.Rule30QuietCorner
open Rule30Jen (cell)
open Rule30EtherThree

theorem kit_tail_iff (f : Nat → Bool) : Tail011 f ↔
    ∃ s, ∀ t, s≤t → f t=wordAt3 w011 (t-s) := by
  constructor
  · rintro ⟨s,h⟩
    refine ⟨s, fun t ht => ?_⟩
    let k := (t-s)/3
    obtain ⟨a,b,c⟩ := h k
    rw [wordAt3_011]
    have form : t=s+3*k ∨ t=s+3*k+1 ∨ t=s+3*k+2 := by dsimp [k]; omega
    rcases form with e|e|e
    · rw [e,a]; simp
    · rw [e,b]; simp; omega
    · rw [e,c]; simp; omega
  · rintro ⟨s,h⟩
    refine ⟨s,fun k=> ?_⟩
    rw [h _ (by omega),h _ (by omega),h _ (by omega),wordAt3_011,wordAt3_011,wordAt3_011]
    simp; omega

/-- The kit's finite-left obstruction for the two-black class forces the
exposed one-third count to be unbounded at the bond starting at −2. -/
theorem unbounded_of_C3w0 (h : C3w0 w011) :
    ∀ B : Int, ∃ n, B < deficit cell (-2) 0 n := by
  intro B
  apply Classical.byContradiction
  intro bad
  have ub : ∀ n, deficit cell (-2) 0 n ≤ B := fun n => by
    apply Int.le_of_not_gt
    exact fun ex => bad ⟨n,ex⟩
  have clock := (singleton_bounded_iff (-2)).mp ⟨B,ub⟩
  exact not_eventually_011_of_C3w0 h ((kit_tail_iff _).mp clock)
end Ruliology.CellularAutomata.Rule30QuietCorner
