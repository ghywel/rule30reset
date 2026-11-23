import Rule30Submission

open Ruliology.CellularAutomata Rule30EtherThree
open Rule30Submission.Rule30EtherThreeGate

namespace S14SecondRead

/-- With no observed cells, only the three drive phases remain. The labels are 0, 1, 2
and either exterior bit takes a state to the next phase. -/
def emptyStrip : PTrap :=
  { w := w001, b := 0, m := 3, n := 3, lb := 2, ib := 2, u := 0,
    R := 0, L := 36, S := 165 }

example : emptyStrip.check = true ∧ emptyStrip.w = w001 ∧ emptyStrip.b = 0 := by decide +kernel

theorem enters_now (x : Nat → Bool) (φ : Nat) :
    ∃ i, i < emptyStrip.n ∧ (0 + φ) % 3 = emptyStrip.lab i % 3 ∧
      EncF (half x φ) emptyStrip.b 0 0 (emptyStrip.st i) := by
  have phase : ∀ p : Fin 3, emptyStrip.lab p.val % 3 = p.val := by decide +kernel
  let i : Fin 3 := ⟨φ % 3, Nat.mod_lt _ (by decide)⟩
  refine ⟨i.val, i.isLt, by simpa only [Nat.zero_add] using (phase i).symm, ?_⟩
  exact ⟨emptyStrip.st_lt i, fun _ hk => (Nat.not_lt_zero _ hk).elim⟩

example (x : Nat → Bool) (φ : Nat) : Enters emptyStrip x φ := ⟨0, enters_now x φ⟩

end S14SecondRead
