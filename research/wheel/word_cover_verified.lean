module
public import word_cover_adaptive
public import word_cover_nine
public import word_cover_third

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open Rule30GateTrapWords Rule30PeriodTwoSideways WheelGateObserver

private theorem ten {w : List Bool} (mem : w∈extra::markers) :
    ∃ k, (PureThreeExit.layers w true k).head? = some [] := by
  rcases List.mem_cons.mp mem with rfl|other
  · exact ⟨_,cut5⟩
  · exact nine_cuts other

/-- Each listed marker certifies trap entry at its own endpoint. -/
theorem ten_markers_force_entry {R : Nat → Bool} {s : Nat} {w : List Bool}
    (member : w∈extra::markers) (read : Reads (u R) s w) :
    InTrap R (s+(w.length-1)) := by
  obtain ⟨k,cut⟩ := ten member
  exact marker_enters cut read

/-- Every clean exterior reading of length 47 is the same exceptional word. -/
theorem only_clean_exterior_47 {R : Nat → Bool} {s : Nat}
    (clean : Clean (u R) s 47) (outside : ¬InTrap R (s+46)) :
    Reads (u R) s exceptional :=
  only_exception_of_markers (fun _ h => ten h) clean outside

/-- A clean block of 47 readings unequal to the exceptional word certifies entry. -/
theorem sound_47_except_one {R : Nat → Bool} {s : Nat}
    (clean : Clean (u R) s 47) (different : ¬Reads (u R) s exceptional) :
    InTrap R (s+46) := by
  apply Classical.byContradiction
  exact fun outside => different (only_clean_exterior_47 clean outside)

theorem adaptive_sound {R : Nat → Bool} {t : Nat} (hit : AdaptiveAt R t) : InTrap R t := by
  obtain ⟨s,rfl,clean,distinct⟩ := hit
  exact sound_47_except_one clean distinct
end Ruliology.CellularAutomata.WordCover
