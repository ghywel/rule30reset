import Rule30PeriodThreeGateChanges
import Ruliology.CellularAutomata.Rule30Coupled

/-! A two-sided Rule 30 evolution with prescribed centre 011 and two cofinal
falling phases one column west. The initial right half is all white. -/

namespace PhaseFalls.RealizedFlank
open Ruliology.CellularAutomata Rule30Realization Rule30EtherThree Rule30PeriodThreeEntry

/-- The phase-0 and phase-2 falls both occur in every window [U, 4U+49). -/
theorem exists_011_flank_bounded :
    ∃ x : Int → Bool, (∀ p, 1 ≤ p → x p = false) ∧
      (∀ t, evol x t 0 = wordAt3 w011 t) ∧
      (∀ r : Nat, (∀ N, ∃ t, N ≤ t ∧ t % 3 = r ∧
        evol x t (-1) = true ∧ evol x (t+1) (-1) = false) ↔ r = 0 ∨ r = 2) ∧
      ∀ U, ∃ t u, U ≤ t ∧ t ≤ 4*U+45 ∧ U ≤ u ∧ u ≤ 4*U+48 ∧
        t%3 = 0 ∧ evol x t (-1) = true ∧ evol x (t+1) (-1) = false ∧
        u%3 = 2 ∧ evol x u (-1) = true ∧ evol x (u+1) (-1) = false := by
  let x := conf (fun _ => false) (wordAt3 w011)
  obtain ⟨white, centre⟩ := realize (fun _ => false) (wordAt3 w011)
  refine ⟨x, white, centre, ?_⟩
  have drive : (fun t => evol x t 0) = (fun t => wordAt3 w011 (t+0)) := funext centre
  have gates (N : Nat) (b : Bool) : ∃ t, N ≤ t ∧ t ≤ 4*N+45 ∧ t%3 = 0 ∧ evol x t 1 = b := by
    obtain ⟨t, late, hi, phase, gate⟩ := Rule30PeriodThreeGateChanges.opposite_011
      (R := fun p => x (p : Int)) (D := 0) (φ := 0) (T := N) (fun p hp => white _ (by omega)) (!b)
    refine ⟨t, late, by omega, phase, ?_⟩
    rw [show evol x t 1 = _ from Rule30Coupled.right_eq_drv x t 1, drive]
    change half w011 (fun p => x (p : Int)) 0 t 1 = b
    simpa only [Bool.not_not] using gate
  have west (t : Nat) : evol x t (-1) =
      xor (wordAt3 w011 (t+1)) (wordAt3 w011 t || evol x t 1) := by
    rw [← centre, ← centre]
    exact rule_left _ _ _
  have at0 (t : Nat) (ht : t % 3 = 0) : evol x t (-1) = !(evol x t 1) := by
    rw [west, wordAt3_011, wordAt3_011, show (t+1)%3=1 by omega, ht]
    cases evol x t 1 <;> rfl
  have at1 (t : Nat) (ht : t % 3 = 1) : evol x t (-1) = false := by
    rw [west, wordAt3_011, wordAt3_011, show (t+1)%3=2 by omega, ht]
    cases evol x t 1 <;> rfl
  have at2 (t : Nat) (ht : t % 3 = 2) : evol x t (-1) = true := by
    rw [west, wordAt3_011, wordAt3_011, show (t+1)%3=0 by omega, ht]
    cases evol x t 1 <;> rfl
  have fall0 (U : Nat) : ∃ t, U ≤ t ∧ t ≤ 4*U+45 ∧ t%3 = 0 ∧
      evol x t (-1) = true ∧ evol x (t+1) (-1) = false := by
    obtain ⟨t, late, hi, phase, gate⟩ := gates U false
    exact ⟨t, late, hi, phase, by rw [at0 _ phase, gate]; rfl, at1 _ (by omega)⟩
  have fall2 (U : Nat) : ∃ t, U ≤ t ∧ t ≤ 4*U+48 ∧ t%3 = 2 ∧
      evol x t (-1) = true ∧ evol x (t+1) (-1) = false := by
    obtain ⟨t, late, hi, phase, gate⟩ := gates (U+1) true
    refine ⟨t-1, by omega, by omega, by omega, at2 _ (by omega), ?_⟩
    rw [show t-1+1 = t by omega, at0 _ phase, gate]
    rfl
  constructor
  · intro r
    constructor
    · intro h
      obtain ⟨t, _, hr, black, _⟩ := h 0
      have ne : t % 3 ≠ 1 := by
        intro eq
        rw [at1 _ eq] at black
        contradiction
      omega
    · rintro (rfl | rfl) N
      · obtain ⟨t, late, _, fall⟩ := fall0 N
        exact ⟨t, late, fall⟩
      · obtain ⟨t, late, _, fall⟩ := fall2 N
        exact ⟨t, late, fall⟩
  · intro U
    obtain ⟨t, lo, hi, ph, black, white⟩ := fall0 U
    obtain ⟨u, lo', hi', fall⟩ := fall2 U
    exact ⟨t, u, lo, hi, lo', hi', ph, black, white, fall⟩

theorem exists_011_flank :
    ∃ x : Int → Bool, (∀ p, 1 ≤ p → x p = false) ∧
      (∀ t, evol x t 0 = wordAt3 w011 t) ∧
      ∀ r : Nat, (∀ N, ∃ t, N ≤ t ∧ t % 3 = r ∧
        evol x t (-1) = true ∧ evol x (t+1) (-1) = false) ↔ r = 0 ∨ r = 2 := by
  obtain ⟨x, white, centre, cofinal, _⟩ := exists_011_flank_bounded
  exact ⟨x, white, centre, cofinal⟩

end PhaseFalls.RealizedFlank
