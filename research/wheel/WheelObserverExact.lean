module
public import WheelObserverProof
public import WheelObserverAllPages
public import WheelObserverCleanup

/-! A complete single-column observer for every physical period-two gate trap entry. -/
@[expose] public section
namespace Ruliology.CellularAutomata.WheelObserverExact
open WheelGateObserver WheelObserverTransport WheelObserverProof Rule30GateTrapWords
open Rule30PeriodTwoSideways

/-- Forty-eight consecutive white-time samples free of the five forbidden factors
place the terminal physical window in the trap, for any initial right half. -/
theorem sound_48 : Sound 47 :=
  sound_of_cut (cut_of_top WheelObserverCheck.top_pass)

theorem enter_iff_some_clean_48 (R : Nat → Bool) :
    (∃ a, InTrap R a) ↔ ∃ s, Clean (u R) s 48 :=
  entry_iff_clean sound_48 R

/-- The right-half dichotomy becomes an eventual occurrence question in one bit. -/
theorem rd_iff_clean_48 :
    Rule30PeriodTwoWidth13.RD ↔ ∀ R : Nat → Bool, Rule30ZeroBoundary.FinSupp R →
      ¬ Rule30Jen.EventuallyPeriodic (u R) → ∃ s, Clean (u R) s 48 :=
  rd_iff_event sound_48

theorem outside_iff_defect_in_every_48 (R : Nat → Bool) :
    (∀ a, ¬InTrap R a) ↔ ∀ s, ∃ off w, w ∈ forbidden ∧ off+w.length ≤ 48 ∧
      Reads (u R) (s+off) w :=
  outside_iff_bounded_defects sound_48 R

end Ruliology.CellularAutomata.WheelObserverExact
