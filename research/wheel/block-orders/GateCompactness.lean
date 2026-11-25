import Rule30Equivalents.RandomConfigurations

/-! M181. A physical half for every finite prefix gives one for the infinite
target. The initial half may depend on the requested order. -/

namespace M181Gate

open Ruliology.CellularAutomata Rule30Realization
open Rule30Equivalents Genericity RandomConfigurations

/-- The driven half is realized by the kit's full configuration with precisely
this prescribed wall and these initial positive cells. White-first alternation
uses wall(t) = (t % 2 == 1) and sample(j) = 2*j. -/
noncomputable def gate (wall : ℕ → Bool) (sample : ℕ → ℕ) (r : ℕ → Bool)
    (j : ℕ) : Bool := evol (traceRightHalf.symm (wall,r)) (sample j) 1

theorem continuous_gate (wall : ℕ → Bool) (sample : ℕ → ℕ) :
    Continuous (gate wall sample) :=
  continuous_pi fun j => (continuous_evol (sample j) 1).comp
    (traceRightHalf.symm.continuous.comp (continuous_const.prodMk continuous_id))

theorem closed_gate_language (wall : ℕ → Bool) (sample : ℕ → ℕ) :
    IsClosed (Set.range (gate wall sample)) :=
  (isCompact_range (continuous_gate wall sample)).isClosed

theorem physical_iff_prefixes (wall target : ℕ → Bool) (sample : ℕ → ℕ) :
    (∃ r, gate wall sample r = target) ↔
      ∀ n, ∃ r, ∀ j < n, gate wall sample r j = target j := by
  constructor
  · rintro ⟨r, hr⟩ n
    exact ⟨r, fun j _ => congrFun hr j⟩
  · intro h
    let F : ℕ → Set (ℕ → Bool) := fun n => {r | ∀ j < n, gate wall sample r j = target j}
    have hc : ∀ n, IsClosed (F n) := fun n => by
      simp only [F, Set.ofPred_forall]
      refine isClosed_iInter fun j => isClosed_iInter fun _ => ?_
      exact (isClosed_discrete {target j}).preimage
        ((continuous_apply j).comp (continuous_gate wall sample))
    have hm : ∀ n, F (n+1) ⊆ F n := fun n _ hr j hj => hr j (by omega)
    obtain ⟨r, hr⟩ := IsCompact.nonempty_iInter_of_sequence_nonempty_isCompact_isClosed
      F hm h (hc 0).isCompact hc
    exact ⟨r, funext fun j => (Set.mem_iInter.mp hr (j+1)) j (by omega)⟩

/-- For a chosen block order, a cone at every seam suffices. A string of n
nonempty blocks has at least n readings; the lengths need not be equal. -/
theorem physical_iff_seams (wall target : ℕ → Bool) (sample cut : ℕ → ℕ)
    (long : ∀ n, n ≤ cut n) :
    (∃ r, gate wall sample r = target) ↔
      ∀ n, ∃ r, ∀ j < cut n, gate wall sample r j = target j := by
  constructor
  · rintro ⟨r, hr⟩ n
    exact ⟨r, fun j _ => congrFun hr j⟩
  · intro h
    apply (physical_iff_prefixes wall target sample).2
    intro n
    obtain ⟨r, hr⟩ := h n
    exact ⟨r, fun j hj => hr j (lt_of_lt_of_le hj (long n))⟩

end M181Gate
