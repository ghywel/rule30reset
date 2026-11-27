import Ruliology.CellularAutomata.Rule30FiniteConfigs
import Ruliology.CellularAutomata.Rule30FiniteMaskedJen
import Ruliology.CellularAutomata.Rule30Problem3Bounds

namespace PhaseTwo.ColumnCost

open Ruliology.CellularAutomata Rule30Jen Rule30Realization Rule30Problem3
  Rule30Problem3Bounds

/-- On a single index in every canonical window, the head reaches cell k and
every halting time is at least k + 1. T can be any correct time allowance. -/
def WindowCost (f : Nat → Bool) : Prop :=
  ∀ (M : Machine) (T : Nat → Nat), Computes M f T → ∀ k : Nat, 1 ≤ k →
    ∃ r : Nat, 2 ^ (k - 1) ≤ r ∧ r < 2 ^ (k - 1) + 2 ^ k ∧
      k + 1 ≤ RightSpan M r (T r) ∧
      ∀ (s : Nat) (b : Bool), M.run r s = .inl b → k + 1 ≤ s

private theorem span_after_halt {M : Machine} {r s : Nat} {b : Bool}
    (h : M.run r s = .inl b) (d : Nat) :
    RightSpan M r (s + d) = RightSpan M r s := by
  induction d with
  | zero => rfl
  | succ d ih => rw [Nat.add_succ, RightSpan, Machine.run_add h d, ih]

/-- Quint and Gemini's canonical-window right-span theorem gives the same
input for both bounds since the span stops growing as soon as the machine halts. -/
theorem windowCost_of_no_dyadic_period {f : Nat → Bool}
    (hf : ∀ k : Nat, ¬ Rule30LeftReset.EvPer f (2 ^ k)) :
    WindowCost f := by
  intro M T hM k _
  obtain ⟨r, hlo, hhi, hspan⟩ := canon_window_rightSpan_ge_of_not_evPer_two_pow hM (hf k)
  refine ⟨r, hlo, hhi, hspan, ?_⟩
  intro s b hb
  by_cases hs : s ≤ T r
  · have h := span_after_halt hb (T r - s)
    rw [Nat.add_sub_of_le hs] at h
    rw [h] at hspan
    exact Nat.le_trans hspan (rightSpan_le_steps M r s)
  · exact Nat.le_trans (Nat.le_trans hspan (rightSpan_le_steps M r (T r))) (by omega)

theorem windowCost_of_aperiodic {f : Nat → Bool} (hf : ¬ EventuallyPeriodic f) :
    WindowCost f :=
  windowCost_of_no_dyadic_period fun k ⟨t, h⟩ => hf ⟨t, 2 ^ k, Nat.two_pow_pos k, h⟩

def AtMostOne (P : Int → Prop) : Prop := ∀ i j, P i → P j → i = j

/-- For every row with a leftmost black, at most one fixed site can miss
the all-scale cost property. This includes all nonempty finite starts. -/
theorem at_most_one_exception {x : Int → Bool} {lo : Int} (black : x lo = true)
    (west : ∀ p, p < lo → x p = false) :
    AtMostOne (fun i => ¬ WindowCost (fun t => evol x t i)) := by
  intro i j hi hj
  apply Rule30FiniteConfigs.periodic_column_unique black west i j
  · exact Classical.byContradiction (fun h => hi (windowCost_of_aperiodic h))
  · exact Classical.byContradiction (fun h => hj (windowCost_of_aperiodic h))

/-- The exceptional-site formulation for the actual single black cell. -/
theorem single_seed_at_most_one_exception :
    AtMostOne (fun i => ¬ WindowCost (fun t => cell t i)) := by
  have hw : ∀ p : Int, p < 0 → seed p = false := by
    intro p hp
    simp [seed, Int.ne_of_lt hp]
  simpa only [evol_seed] using at_most_one_exception (x := seed) (lo := 0) (by decide) hw

private theorem periodic_channels {f g : Nat → Bool}
    (h : EventuallyPeriodic (Rule30LeftAntiPeriod.interleave f g)) :
    EventuallyPeriodic f ∧ EventuallyPeriodic g := by
  let z := Rule30LeftAntiPeriod.interleave f g
  obtain ⟨T, P, hp, h⟩ := h
  have shift (j t : Nat) (ht : T ≤ t) : z (2 * (t + P) + j) = z (2 * t + j) := by
    rw [show 2 * (t + P) + j = 2 * t + j + 2 * P by omega]
    exact periodic_mul h 2 (2 * t + j) (by omega)
  have even (t : Nat) : z (2 * t) = f t := by
    simp [z, Rule30LeftAntiPeriod.interleave, Nat.mul_comm 2 t]
  have odd (t : Nat) : z (2 * t + 1) = g t := by
    simp [z, Rule30LeftAntiPeriod.interleave,
      show (2 * t + 1) % 2 = 1 by omega, show (2 * t + 1) / 2 = t by omega]
  exact ⟨⟨T, P, hp, fun t ht => by simpa only [Nat.add_zero, even] using shift 0 t ht⟩,
    ⟨T, P, hp, fun t ht => by simpa only [odd] using shift 1 t ht⟩⟩

/-- Masked Jen supplies two channels at any named bond: its west cell and
the OR of its two cells. Interleaving them gives one indexed Boolean sequence. -/
theorem bond_windowCost {x : Int → Bool} {lo : Int} (black : x lo = true)
    (west : ∀ p, p < lo → x p = false) (i : Int) :
    WindowCost (Rule30LeftAntiPeriod.interleave (fun t => evol x t i)
      (Rule30FiniteMaskedJen.orCol x i)) := by
  apply windowCost_of_aperiodic
  intro hp
  obtain ⟨hc, ho⟩ := periodic_channels hp
  exact Rule30FiniteMaskedJen.orCol_not_eventuallyPeriodic black west i hc ho

/-- On the actual singleton, index 2t asks for the centre and 2t+1 for the
OR across sites 0 and 1. The single combined sequence pays both window costs. -/
theorem seed_center_bond_windowCost :
    WindowCost (Rule30LeftAntiPeriod.interleave Rule30Prize.center
      (fun t => Rule30Prize.center t || cell t 1)) := by
  have hw : ∀ p : Int, p < 0 → seed p = false := by
    intro p hp
    simp [seed, Int.ne_of_lt hp]
  have h := bond_windowCost (x := seed) (lo := 0) (by decide) hw 0
  change WindowCost (Rule30LeftAntiPeriod.interleave (fun t => evol seed t 0)
    (fun t => evol seed t 0 || evol seed t 1)) at h
  change WindowCost (Rule30LeftAntiPeriod.interleave (fun t => cell t 0)
    (fun t => cell t 0 || cell t 1))
  simpa only [evol_seed] using h

/-- The all-white start gives a constant trace at every site. The kit's
one-step constant machine already violates the k = 1 time requirement. -/
theorem not_windowCost_constant (b : Bool) : ¬ WindowCost (fun _ => b) := by
  intro h
  obtain ⟨r, _, _, _, htime⟩ :=
    h (constMachine b) (fun _ => 1) (computes_constMachine b) 1 (by decide)
  have := htime 1 b (computes_constMachine b r)
  omega

end PhaseTwo.ColumnCost
