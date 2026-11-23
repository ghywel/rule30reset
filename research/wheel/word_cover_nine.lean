module
public import word_cover_transport
public import word_cover_short
public import word_cover_long
public import word_cover_hard

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open Rule30GateTrapWords Rule30PeriodTwoSideways WheelGateObserver

theorem nine_cuts {w : List Bool} (mem : w∈markers) :
    ∃ k, (PureThreeExit.layers w true k).head? = some [] := by
  simp only [markers,List.mem_cons,List.not_mem_nil,or_false] at mem
  rcases mem with rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl|rfl
  · exact ⟨_,cut0⟩
  · exact ⟨_,cut1⟩
  · exact ⟨_,cut3⟩
  · exact ⟨_,cut6⟩
  · exact ⟨_,cut7⟩
  · exact ⟨_,cut9⟩
  · exact ⟨_,cut10⟩
  · exact ⟨_,cut11⟩
  · exact ⟨_,cut13⟩

/-- All clean 48-bit observations end inside the physical trap. -/
theorem sound_48 : Sound 47 := sound_of_markers (fun _ h => nine_cuts h)

end Ruliology.CellularAutomata.WordCover
