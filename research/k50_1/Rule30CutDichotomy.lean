import Rule30CutAnchors
import Ruliology.CellularAutomata.Rule30GateTrap

/-! RD on every cut of the reference ether, in both phases of the black-even wall.
The fourteen bases lift by spatial period seven. Below each base we exhibit both an
odd-time mismatch with the reference and entry in the literal kit trap by tick 293. -/
namespace Ruliology.CellularAutomata.Rule30CutDichotomy

open Rule30CutSplice Rule30CutAnchors Rule30DrivenPrefix Rule30Ether Rule30PeriodTwoCoupled
open Rule30GateTrap (trap trapCodes decode win)

private def trapTick (s N : Nat) : Nat :=
  if s = 1 then [293,293,293,293,293,43,43].getD N 0
  else [293,7,291,5,43,43,0,0,15,0,53,99,99,0,0,107,0,85,157,157,0,0,165,0,0,189,189,
        0,0,193,0,0,0,0,0,0,223].getD N 0

private def mismatchTick (s N : Nat) : Nat :=
  if s = 1 then [5,5,5,5,5,9,9].getD N 0
  else [1,3,3,7,7,7,0,0,15,0,19,71,71,0,0,47,0,63,123,123,0,0,111,0,0,167,167,
        0,0,159,0,0,0,0,0,0,203].getD N 0

private def checkShort (s N : Nat) : Bool :=
  let t := trapTick s N
  let u := mismatchTick s N
  decide (t ≤ 293 ∧ t%2 = 1 ∧ u%2 = 1) &&
    trapCodes.contains ((packed altCol (cutCode s N) t) % 2^16) &&
    ((packed altCol (cutCode s N) u).testBit 0 != ether 4 (s+u))

set_option maxRecDepth 8192 in
private theorem shortTable : ∀ i : Fin 43, ∀ s : Fin 4, s.val=1 ∨ s.val=3 →
    i.val < anchorWidth s.val (i.val%7) → checkShort s.val i.val = true := by decide +kernel

private theorem residues : ∀ r : Fin 7, ∀ s : Fin 4, s.val=1 ∨ s.val=3 →
    anchorWidth s.val r.val % 7 = r.val ∧ anchorWidth s.val r.val ≤ 43 := by decide +kernel

/-- Above the appropriate residue's base the physical column agrees at every tick. -/
theorem above_anchor (s N : Nat) (hs : s=1 ∨ s=3) (h : anchorWidth s (N%7) ≤ N) : Matches s N := by
  let r : Fin 7 := ⟨N%7, Nat.mod_lt _ (by decide)⟩
  have same := (residues r ⟨s, by omega⟩ hs).1
  have wall (t : Nat) : altCol t = ether 3 (s+t) := by
    rcases hs with rfl | rfl
    · simpa only [Nat.add_comm 1 t] using altCol_eq_B4 t
    · exact altCol_eq_B4_three t
  have sum : anchorWidth s r.val + 7 * ((N - anchorWidth s r.val)/7) = N := by
    dsimp [r] at *
    omega
  rw [← sum]
  exact matches_add_periods _ _ wall (anchor_matches s hs r) _

/-- Every cut below its base reaches the literal 829-window trap by tick 293 and has an odd
observation different from the uncut reference. A zero tick in the tables is an unused slot. -/
theorem below_anchor (s N : Nat) (hs : s=1 ∨ s=3) (h : N < anchorWidth s (N%7)) :
    (∃ t, t ≤ 293 ∧ t%2 = 1 ∧ win (cut s N) t ∈ trap) ∧
    (∃ u, u%2 = 1 ∧ drv altCol (cut s N) u 1 ≠ ether 4 (s+u)) := by
  have bound : anchorWidth s (N%7) ≤ 43 := (residues ⟨N%7, Nat.mod_lt _ (by decide)⟩ ⟨s, by omega⟩ hs).2
  have checked := shortTable ⟨N, by omega⟩ ⟨s, by omega⟩ hs h
  simp only [checkShort, Bool.and_eq_true, decide_eq_true_eq, List.contains_iff_mem,
    bne_iff_ne] at checked
  obtain ⟨⟨⟨ht, odd, hu⟩, code⟩, different⟩ := checked
  refine ⟨⟨_, ht, odd, ?_⟩, ⟨_, hu, ?_⟩⟩
  · apply List.mem_map.mpr
    refine ⟨_, code, ?_⟩
    unfold decode win rowOf
    apply Rule30Ether.seg_congr
    intro i hi
    rw [Nat.testBit_mod_two_pow, decide_eq_true hi, Bool.true_and, packed_cut, Nat.zero_add]
  · rwa [packed_cut] at different

/-- A sharp classification by phase, cut width and residue. -/
theorem matches_iff (s N : Nat) (hs : s=1 ∨ s=3) :
    Matches s N ↔ anchorWidth s (N%7) ≤ N := by
  refine ⟨fun hm => ?_, above_anchor s N hs⟩
  apply Nat.le_of_not_gt
  intro h
  obtain ⟨u, _, diff⟩ := (below_anchor s N hs h).2
  exact diff (hm u)

/-- RD restricted to this infinite family of finitely supported right halves. -/
theorem cut_dichotomy (s N : Nat) (hs : s=1 ∨ s=3) :
    (∃ t, t ≤ 293 ∧ t%2 = 1 ∧ win (cut s N) t ∈ trap) ∨
      Rule30Jen.EventuallyPeriodic (Rule30PeriodTwoSideways.u (cut s N)) := by
  by_cases h : anchorWidth s (N%7) ≤ N
  · exact Or.inr ⟨0, 2, by decide, fun n _ => matches_gate_period s N (above_anchor s N hs h) n⟩
  · exact Or.inl (below_anchor s N hs (by omega)).1

/-- Pointwise agreement holds from these widths in the two phases. Each lower endpoint is sharp. -/
theorem sharp_support_thresholds :
    (∀ N, 7 ≤ N → Matches 1 N) ∧ ¬ Matches 1 6 ∧
    (∀ N, 37 ≤ N → Matches 3 N) ∧ ¬ Matches 3 36 := by
  have large (s N : Nat) (hs : s=1 ∨ s=3) (h : 43 ≤ N) : Matches s N := by
    have hb : anchorWidth s (N%7) ≤ 43 :=
      (residues ⟨N%7, Nat.mod_lt _ (by decide)⟩ ⟨s, by omega⟩ hs).2
    exact above_anchor s N hs (by omega)
  have small : ∀ i : Fin 43,
      (7 ≤ i.val → anchorWidth 1 (i.val%7) ≤ i.val) ∧
      (37 ≤ i.val → anchorWidth 3 (i.val%7) ≤ i.val) := by decide +kernel
  refine ⟨fun N h => ?_, fun bad => ?_, fun N h => ?_, fun bad => ?_⟩
  · by_cases hN : N < 43
    · exact above_anchor 1 N (Or.inl rfl) ((small ⟨N,hN⟩).1 h)
    · exact large 1 N (Or.inl rfl) (by omega)
  · exact (by decide : ¬ anchorWidth 1 (6%7) ≤ 6) ((matches_iff 1 6 (Or.inl rfl)).mp bad)
  · by_cases hN : N < 43
    · exact above_anchor 3 N (Or.inr rfl) ((small ⟨N,hN⟩).2 h)
    · exact large 3 N (Or.inr rfl) (by omega)
  · exact (by decide : ¬ anchorWidth 3 (36%7) ≤ 36) ((matches_iff 3 36 (Or.inr rfl)).mp bad)

theorem cut_finite (s N : Nat) : Rule30ZeroBoundary.FinSupp (cut s N) :=
  ⟨N, fun p hp => by simp [cut, show ¬p ≤ N by omega]⟩

end Ruliology.CellularAutomata.Rule30CutDichotomy
