module
public import word_cover_transport
public import WheelObserverLowerBound

@[expose] public section
namespace Ruliology.CellularAutomata.WordCover
open Rule30GateTrapWords Rule30PeriodTwoSideways Rule30PeriodTwoCoupled Rule30Ether WheelGateObserver
open Rule30SidewaysLocks WheelObserverLowerBound

/-- The 47-letter exception itself passes the five-word filter. -/
theorem exceptional_clean : Clean (fun i => exceptional.getD i false) 0 47 :=
  (cleanb_spec ..).mp (by decide +kernel)

/-- Both possible labels of the exceptional observation occur on finite physical starts.
The second observation begins ten intervals after the row entered at zero. -/
theorem exceptional_pair :
    Rule30ZeroBoundary.FinSupp (rh outerSeed) ∧ Rule30ZeroBoundary.FinSupp (rh innerSeed) ∧
    Reads (u (rh outerSeed)) 0 exceptional ∧ Reads (u (rh innerSeed)) 10 exceptional ∧
    ¬InTrap (rh outerSeed) 46 ∧ InTrap (rh innerSeed) 0 ∧ InTrap (rh innerSeed) 56 := by
  have outside : Reads (u (rh outerSeed)) 0 exceptional := by
    intro j hj
    change j<47 at hj
    change drv altCol (rh outerSeed) (2*(0+j)+1) 1 = _
    rw [physical outerSeed _ 0]
    exact (by decide +kernel : ∀ i : Fin 47, (packed outerSeed (2*(0+i.val)+1)).testBit 0 =
      exceptional.getD i.val false) ⟨j,hj⟩
  refine ⟨Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat outerSeed,
    Rule30ZeroBoundary.IntegerForm.finSupp_rowOfNat innerSeed,outside,?_,physical_labels⟩
  intro j hj
  change j<47 at hj
  have eq := congrFun same_reading ⟨j,hj⟩
  exact eq.symm.trans (outside j hj)

theorem only_exception_of_markers
    (cuts : ∀ w ∈ extra :: markers, ∃ k, (PureThreeExit.layers w true k).head? = some [])
    {R : Nat → Bool} {s : Nat} (clean : Clean (u R) s 47) (outside : ¬InTrap R (s+46)) :
    Reads (u R) s exceptional := by
  rcases clean_47_cases _ _ clean with good | ⟨off,w,mem,bound,read⟩
  · exact good
  · obtain ⟨k,cut⟩ := cuts w mem
    have pos := of_decide_eq_true (List.all_eq_true.mp
      (by decide +kernel : (extra :: markers).all (fun w => decide (0<w.length))=true) w mem)
    exact False.elim (outside (later (marker_enters cut read) (by omega)))
end Ruliology.CellularAutomata.WordCover
