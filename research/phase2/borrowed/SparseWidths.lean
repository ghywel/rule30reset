-- Build the published R30-20261126-e2e0e2 source as ImmortalThreshold.lean.
import ImmortalThreshold

namespace PhaseTwo

open Rule30Submission
open Ruliology.CellularAutomata.Rule30ZeroBoundary
open Ruliology.CellularAutomata.Rule30ZeroBoundary.IntegerForm

/-- There are fewer than 4096 distinct rows of exact width w passing k even-time checks. -/
def SparseWidth (w k : Nat) : Prop :=
  ¬ ∃ f : Fin 4096 → Nat, (∀ ⦃i j⦄, f i = f j → i = j) ∧
    ∀ i, Top (f i) (w - 1) ∧ ∀ s < k, zrow (rowOfNat (f i)) (2*s) 1 = true

/-- A direct contrapositive of Benboubakeur et al.'s amplification theorem.
    The tested width and its finite observation horizon may both depend on the requested cutoff. -/
theorem q01_of_sparse_widths
    (sparse : ∀ parity < 2, ∀ bound, ∃ w ≥ bound, w % 2 = parity ∧ ∃ k, SparseWidth w k) :
    Q01 := by
  apply Classical.byContradiction
  intro h
  obtain ⟨Y, hY, _⟩ := many_immortal_rows_small h
  let width := Y.log2 + 1
  obtain ⟨w, hw, hp, k, few⟩ :=
    sparse (width % 2) (Nat.mod_lt _ (by decide)) (width + 389)
  obtain ⟨f, inj, survive⟩ := immortal_rows_4096 hY w hw hp
  exact few ⟨f, inj, fun i => ⟨(survive i).1, fun s _ => (survive i).2 s⟩⟩

end PhaseTwo
