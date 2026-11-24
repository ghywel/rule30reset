module

public import Rule30ArrivalsLight

/-! Consequences of the two branches of the alternating right-half theorem. -/

@[expose] public section

namespace Rule30ArrivalsPeriodicity
open Ruliology.CellularAutomata Rule30Ether Rule30Jen Rule30ArrivalsLight

/-- If the gate eventually kicks once in four white samples, the white net
alternates and the odd-kick indicator vanishes on that same tail. -/
theorem four_tail {F : Nat → Nat → Bool} {T φ N : Nat} (hF : IsR30 F) (h : Alt F T)
    (four : ∀ k, N ≤ k → gate F T k = decide ((k+φ)%4 = 0)) (k : Nat) (hk : N ≤ k) :
    net F T k = decide ((k+φ)%2 = 0) ∧ oddKick F T k = false := by
  let d := 4 - (k+φ)%4
  have next : NextKick F T k d := by
    refine ⟨by dsimp [d]; omega, ?_, ?_⟩
    · rw [four (k+d) (by omega)]
      apply decide_eq_true; dsimp [d]; omega
    · intro i hi hd
      rw [four (k+i) (by omega)]
      apply decide_eq_false; dsimp [d] at hd; omega
  have parity := net_of_return hF h next
  have phase : d % 2 = (k+φ)%2 := by dsimp [d]; omega
  rw [phase] at parity
  refine ⟨parity, ?_⟩
  unfold oddKick
  rw [four k hk, parity]
  by_cases kick : (k+φ)%4 = 0
  · simp [kick, show (k+φ)%2 = 0 by omega]
  · simp [kick]

/-- For every right half under an alternating boundary, eventual periodicity
of the gate, white net and odd-kick indicator is equivalent. Periodicity of the
black net also suffices. -/
theorem periodic_together_of_alt {F : Nat → Nat → Bool} {T : Nat} (hF : IsR30 F) (h : Alt F T) :
    (EventuallyPeriodic (gate F T) ↔ EventuallyPeriodic (net F T)) ∧
    (EventuallyPeriodic (net F T) ↔ EventuallyPeriodic (oddKick F T)) ∧
    (EventuallyPeriodic (blackNet F T) → EventuallyPeriodic (gate F T)) := by
  rcases enters_or_four hF h with ⟨k, inside⟩ | ⟨φ, N, four⟩
  · exact periodic_together hF h inside
  · have G : EventuallyPeriodic (gate F T) := by
      refine ⟨N, 4, by decide, fun k hk => ?_⟩
      rw [four k hk, four (k+4) (by omega), show (k+4+φ)%4 = (k+φ)%4 by omega]
    have tail := four_tail hF h four
    have A : EventuallyPeriodic (net F T) := by
      refine ⟨N, 2, by decide, fun k hk => ?_⟩
      rw [(tail k hk).1, (tail (k+2) (by omega)).1, show (k+2+φ)%2 = (k+φ)%2 by omega]
    have O := odd_periodic_of_net hF h A
    exact ⟨⟨fun _ => A, fun _ => G⟩, ⟨fun _ => O, fun _ => A⟩, fun _ => G⟩

open Rule30DrivenPrefix (step)
open Rule30PeriodTwoCoupled (altCol)

/-- Black-first alternating evolution from a finite row. Bit zero encodes site one. -/
def seedRun (x : Nat) := drv altCol (fun p => x.testBit (p-1))

private theorem seed_cell (x k j : Nat) :
    seedRun x (0+2*k+1) (j+1) = (rows false true (step true x) k).testBit j := by
  have rule : IsR30 (seedRun x) := drv_isR30 _ _
  have clock := alt_drv (fun p => x.testBit (p-1))
  have white : Fits (seedRun x) 1 (step true x) (j+1+2*k) := by
    apply fits_step rule (t := 0) (clock 0).1
    intro i _
    rw [seedRun, drv_init _ _ _ (by omega), Nat.add_sub_cancel]
  have f := fits_rows rule (t := 1) (n := k) (L := j+1) (clock.drive 0 k) white k (Nat.le_refl k)
  simpa only [show 0+2*k+1 = 1+2*k by omega] using (f j (by omega)).symm

/-- The two finite rows read the same nine white nets, but the kick at sample six differs. -/
theorem nine_collision :
    (∀ i : Fin 9, net (seedRun 56) 0 i = net (seedRun 9) 0 i) ∧
    gate (seedRun 56) 0 6 = false ∧ gate (seedRun 9) 0 6 = true := by
  have n (x k : Nat) : net (seedRun x) 0 k =
      xor ((rows false true (step true x) k).testBit 0) ((rows false true (step true x) k).testBit 1) := by
    unfold net
    rw [seed_cell x k 0, seed_cell x k 1]
  have g (x k : Nat) : gate (seedRun x) 0 k = (rows false true (step true x) k).testBit 0 :=
    seed_cell x k 0
  simp only [n, g]
  decide +kernel

theorem no_unrestricted_nine : ¬ ∃ read : (Fin 9 → Bool) → Bool, ∀ x,
    read (fun i => net (seedRun x) 0 i) = gate (seedRun x) 0 6 := by
  rintro ⟨read, correct⟩
  obtain ⟨same, off, on⟩ := nine_collision
  have e := congrArg read (funext same)
  rw [correct 56, correct 9, off, on] at e
  contradiction

end Rule30ArrivalsPeriodicity
