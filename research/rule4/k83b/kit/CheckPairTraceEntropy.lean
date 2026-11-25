import Rule30Equivalents

/-! Consumer checks through the aggregate import, using the kit's full map on ℤ. -/
open Dynamics Ruliology.CellularAutomata Rule30Realization
open Rule30Equivalents.Mixing Rule30Equivalents.PairTraceEntropy

local notation "h₃₀" => coverEntropy (fun x : ℤ → Bool => evol x 1) Set.univ

example (a : ℤ) : h₃₀ = ExpGrowth.expGrowthSup (fun n => ((pairWords a n).card : ENNReal)) :=
  entropy_eq_pair_growth a

example (a : ℤ) (k : ℕ) (hk : 0 < k) :
    h₃₀ ≤ ENNReal.log (((pairWords a k).card : ENNReal) ^ ((k : ℝ)⁻¹)) := by
  simpa only [one_div] using entropy_le_block_root a k hk

example {σ : Type} (M : ReverseCover σ) {p q : ℕ} (hq : 0 < q) (W : M.Weights p q) :
    h₃₀ ≤ ENNReal.log (ENNReal.ofReal ((p : ℝ) / q)) :=
  M.entropy_le W hq

example {σ : Type} (M : ReverseCover σ) {p q : ℕ} (hq : 0 < q) (W : M.Weights p q)
    (a : ℤ) (n : ℕ) :
    ((pairWords a n).card : ℝ) ≤ W.weight M.start * ((p : ℝ) / q) ^ n :=
  M.pair_count W hq a n

example : ENNReal.log 2 ≤ h₃₀ ∧ h₃₀ ≤ ENNReal.log (ENNReal.ofReal (1679211 / 714866)) :=
  ⟨log_two_le_coverEntropy, FiveSite.entropy_width_5⟩

example : h₃₀ < ENNReal.log (ENNReal.ofReal (47 / 20)) :=
  FiveSite.entropy_lt_log_forty_seven_twentieths

#print axioms coverMincard_le_card_pairWords
#print axioms entropy_eq_pair_growth
#print axioms entropy_le_block_root
#print axioms ReverseCover.pair_count
#print axioms ReverseCover.entropy_le
#print axioms StripTable.cover
#print axioms FiveSite.entropy_width_5
#print axioms FiveSite.entropy_lt_log_forty_seven_twentieths
