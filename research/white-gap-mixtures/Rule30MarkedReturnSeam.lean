import Ruliology.CellularAutomata.Rule30ThreeGapCapture

/-! A physical three-gap obstruction for four specified projected pulse domains.
The domains come from the recurrent-strip calculation for an early black mark.
The theorem consumes those domains as hypotheses and checks the intervening physics. -/

namespace Rule30MarkedReturnSeam
open Ruliology.CellularAutomata Rule30Realization Rule30ResetMixtures
open Rule30StripCertificates Rule30ThreeGapCapture.Driven Rule30ThreeGapCapture.Pos

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

private def successors (black : Bool) (rows : List Nat) : List Nat :=
  rows.flatMap fun r => [stripStep 30 black false r, stripStep 30 black true r]

private def evolveStrip : List Bool → List Nat → List Nat
  | [], rows => rows
  | a :: rest, rows => evolveStrip rest (successors a rows)

private theorem evolves {x j t word rows} (drive : Drive x j t word)
    (start : Frow x t j 30 ∈ rows) :
    Frow x (t + word.length) j 30 ∈ evolveStrip word rows := by
  induction word generalizing t rows with
  | nil => simpa [evolveStrip] using start
  | cons a rest ih =>
    have head : evol x t j = a := by simpa using drive 0 (by simp)
    have next : Frow x (t + 1) j 30 ∈ successors a rows := by
      unfold successors
      apply List.mem_flatMap.mpr
      refine ⟨_, start, ?_⟩
      unfold Frow
      rw [encRow_step, head]
      cases evol x t (j+1+30) <;> simp
    have tail : Drive x j (t+1) rest := by
      intro k hk
      simpa [Nat.add_assoc, Nat.add_comm 1 k] using drive (k+1) (by simp; omega)
    simpa [evolveStrip, Nat.add_assoc, Nat.add_comm 1] using ih tail next

private theorem projection (x : Int → Bool) (t : Nat) (j : Int) :
    Frow x t j 30 % 2^29 = Frow x t j 29 := by
  apply Nat.eq_of_testBit_eq
  intro b
  change (Rule30FiniteStrips.encRow x t j 30 % 2^29).testBit b =
    (Rule30FiniteStrips.encRow x t j 29).testBit b
  rw [Nat.testBit_mod_two_pow, Rule30FiniteStrips.testBit_encRow,
    Rule30FiniteStrips.testBit_encRow]
  by_cases h : b < 29
  · simp [h, show b < 30 by omega]
  · simp [h]

private def lift (rows : List Nat) : List Nat :=
  rows.flatMap fun r => [r, r + 2^29]

private theorem lifted {x t j rows} (low : Frow x t j 29 ∈ rows) :
    Frow x t j 30 ∈ lift rows := by
  have hbound := (Rule30FiniteStrips.enc_encRow (x:=x) 30 t j).1
  change Frow x t j 30 < 2^30 at hbound
  obtain same | upper : Frow x t j 30 = Frow x t j 29 ∨
      Frow x t j 30 = Frow x t j 29 + 2^29 := by
    have p := projection x t j
    omega
  · exact List.mem_flatMap.mpr ⟨_, low, by simpa using Or.inl same⟩
  · exact List.mem_flatMap.mpr ⟨_, low, by simpa using Or.inr upper⟩

private def selected (q : Nat) (source target : List Nat) : List Nat :=
  (evolveStrip (driver q) source).filter (fun r => target.contains (r % 2^29))

private def contained (source target : List Nat) : Bool :=
  source.all target.contains

private theorem propagate {x j t q source target allowed}
    (h : contained (selected q source target) allowed = true)
    (drive : Drive x j t (driver q)) (start : Frow x t j 30 ∈ source)
    (last : Frow x (t + (q+1)) j 29 ∈ target) :
    Frow x (t + (q+1)) j 30 ∈ allowed := by
  have hist := evolves drive start
  rw [driver_length] at hist
  have inSelection : Frow x (t + (q+1)) j 30 ∈ selected q source target := by
    apply List.mem_filter.mpr
    exact ⟨hist, by rw [projection]; simpa using last⟩
  have yes := List.all_eq_true.mp h _ inSelection
  simpa using yes

private def at0 := [25205029, 377526565, 427858213]
private def at13 := [397669413, 515109925]
private def at26 := [204655685, 405982277]
private def at37 := [38068261, 71622693]
private def first := [934540325, 1051980837]
private def second := [741526597]

private theorem first_check :
    contained (selected 12 (lift at0) at13) first = true := by decide +kernel

private theorem second_check :
    contained (selected 12 first at26) second = true := by decide +kernel

private theorem third_check :
    contained (selected 10 second at37) [] = true := by decide +kernel

/-- The four 29-cell pulse domains cannot occur in one physical history driven
by two twelve-white gaps followed by one ten-white gap. -/
theorem no_continuous_seam (x : Int → Bool) (j : Int) (t : Nat)
    (d0 : Drive x j t (driver 12))
    (d1 : Drive x j (t + 13) (driver 12))
    (d2 : Drive x j (t + 26) (driver 10))
    (h0 : Frow x t j 29 ∈ [25205029, 377526565, 427858213])
    (h1 : Frow x (t + 13) j 29 ∈ [397669413, 515109925])
    (h2 : Frow x (t + 26) j 29 ∈ [204655685, 405982277])
    (h3 : Frow x (t + 37) j 29 ∈ [38068261, 71622693]) : False := by
  have a := propagate first_check d0 (lifted h0) h1
  have b := propagate second_check d1 a
    (show Frow x (t+13+(12+1)) j 29 ∈ at26 by
      simpa only [at26, Nat.add_assoc] using h2)
  have c := propagate third_check d2
    (show Frow x (t+26) j 30 ∈ second by simpa [Nat.add_assoc] using b)
    (show Frow x (t+26+(10+1)) j 29 ∈ at37 by
      simpa only [at37, Nat.add_assoc] using h3)
  simp at c

end Rule30MarkedReturnSeam
