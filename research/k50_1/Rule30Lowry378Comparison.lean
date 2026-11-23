module

public import Ruliology.CellularAutomata.Rule30LockedSeedEdge
public import Rule30Lock7CertificateCenter

/-! Private comparison with Troy Lowry's PR #378 at 0aa79bef. The candidate
family certificate itself imports only existing research modules and merged kit
definitions. This comparison additionally imports the author's exact PR head. -/
@[expose] public section

namespace Ruliology.CellularAutomata.Rule30Lowry378Comparison
open Rule30Lock7Compactness Rule30SidewaysLocks Rule30LockedSeedEdge
open Rule30Lock7Certificate Rule30Lock7CenterDeadline

/-- Lowry's published entry proof discharges the family test without evaluating
its 2^45 compatible initial cones. -/
theorem checkCover_from_pr : checkCover 80 prefix364 47 = true := by
  apply (checkCover_spec 80 prefix364 47).mpr
  exact fun R pref => ⟨6, prefix_enters_lock7 pref⟩

/-- The single-leaf certificate gives the same phase-6 conclusion directly. -/
theorem prefix_entry_from_leaf {R : Nat → Bool} (pref : HasPrefix 80 prefix364 R) :
    winW 30 R 95 ∈ cls 30 lock7Codes 6 :=
  accepted_phase (j := 47) (k := 6) lowry_one_leaf pref

/-- At every genuine singleton age with the specified right prefix, the centre
breaks the proposed black-first alternation by absolute tick 2A+190. -/
theorem centre_bound_at_matching_ages {A : Nat} (pref : HasPrefix 80 prefix364 (rightAt A)) :
    ∃ h, A+h ≤ 2*A+190 ∧ Rule30Jen.cell (A+h) 0 ≠ Rule30PeriodTwoCoupled.altCol h := by
  obtain ⟨h,bound,miss⟩ := actual_break_of_checkCover checkCover_from_pr pref
  exact ⟨h,by omega,miss⟩

/-- The eleven-leaf proof gives the same bound with the first 77 cells. -/
theorem centre_bound_at_77_cells {A : Nat} (pref : HasPrefix 77 prefix364 (rightAt A)) :
    ∃ h, A+h ≤ 2*A+190 ∧ Rule30Jen.cell (A+h) 0 ≠ Rule30PeriodTwoCoupled.altCol h := by
  obtain ⟨h,bound,miss⟩ := Rule30Lock7CertificateCenter.centre_bound_of_certificate lowry_77_passes pref
  change A+h ≤ 2*(A+1+2*47) at bound
  exact ⟨h,by omega,miss⟩

end Ruliology.CellularAutomata.Rule30Lowry378Comparison
